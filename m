From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 20/22] xfrm offload v2: typhoon: add management of outbound bundles
Date: Mon, 10 Jan 2005 10:37:02 -0500
Message-ID: <20040110014300.29@ori.thedillows.org>
References: <20040110014300.28@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 01:05:38-05:00 dave@thedillows.org 
#   Add the offloading of outbound bundles.
#   
#   This is a tricky business, because there are restrictions on
#   the types and order of the xfrms we can offload. Some combinations
#   also yield incorrect results, so we have to reduce the amount of
#   offloading we do in those cases.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2005/01/10 01:05:20-05:00 dave@thedillows.org +167 -0
#   Add the offloading of outbound bundles.
#   
#   This is a tricky business, because there are restrictions on
#   the types and order of the xfrms we can offload. Some combinations
#   also yield incorrect results, so we have to reduce the amount of
#   offloading we do in those cases.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-01-10 01:16:43 -05:00
+++ b/drivers/net/typhoon.c	2005-01-10 01:16:43 -05:00
@@ -358,6 +358,12 @@
 #define TSO_OFFLOAD_ON		0
 #endif
 
+/* We need room for a maximum of 5 dst_entries -- the longest chain of
+ * headers we support for offloading is (inner -> outer):
+ * ESP AH IP2 ESP AH IP1 -- and IP2 is part of the second ESP dst
+ * (tunnel mode)
+ */
+#define TYPHOON_MAX_HEADERS	5
 #define IPSEC_NUM_DESCRIPTORS	1
 
 struct typhoon_xfrm_offload {
@@ -2584,6 +2590,167 @@
 					"offload (%d)\n", tp->name, -err);
 	}
 	spin_unlock_bh(&tp->offload_lock);
+}
+
+static int inline
+typhoon_bundle_list(struct dst_entry *bundle, struct dst_entry *dst_list[],
+						int max_entries)
+{
+	/* While putting the bundle into the dst_list so we can iterate it
+	 * in reverse, scan for problematic offload sequences. Skip over
+	 * the last xfrm in the sequence, so that we still offload as much
+	 * as possible.
+	 *
+	 * This list was generated using runtime 03.001.002, but the
+	 * problems are still present in 03.001.008. I have not re-investigated
+	 * the problems to determine if the symptoms have changed.
+	 *
+	 * inner AH tunnel, outer AH transport
+	 *	--> 3XP seems to put the inner hash at the wrong location
+	 * inner AH tunnel, outer ESP tunnel
+	 *	--> 3XP corrupts outer hash, maybe wrong place?
+	 * inner AH transport, outer ESP tunnel
+	 *	--> 3XP seems to encrypt the wrong portion of the packet
+	 * inner ESP transport, outer AH tunnel
+	 *	--> 3XP lockup, requires reset
+	 *
+	 * No problematic offloads start with ESP in tunnel mode, so pretend
+	 * that was the last one we looked at.
+	 */
+	int last_was_ah = 0, last_was_tunnel = 1;
+	struct dst_entry *dst = bundle;
+	struct xfrm_state *x;
+	int start = max_entries;
+	int bundle_size = 0;
+	int proto, problem;
+
+	while(bundle) {
+		x = bundle->xfrm;
+		proto = x ? x->type->proto : IPPROTO_IP;
+
+		problem = 0;
+		if(proto == IPPROTO_AH && !x->props.mode &&
+				(last_was_ah && last_was_tunnel))
+			problem = 1;
+		else if(proto == IPPROTO_AH && x->props.mode &&
+				!(last_was_ah || last_was_tunnel))
+			problem = 1;
+		else if(proto == IPPROTO_ESP && x->props.mode && last_was_ah)
+			problem = 1;
+
+		if(problem) {
+			/* We hit a snag -- forget about the xfrms we've
+			 * seen before the current one.
+			 */
+			bundle_size = 1;
+			dst = bundle;
+		} else {
+			bundle_size++;
+			if(bundle_size > max_entries)
+				dst = dst->child;
+		}
+
+		last_was_ah = (proto == IPPROTO_AH);
+		last_was_tunnel = x ? x->props.mode : 0;
+		bundle = bundle->child;
+	}
+
+	if(bundle_size < max_entries)
+		start = bundle_size;
+
+	bundle_size = 0;
+	while(dst) {
+		dst_list[--start] = dst;
+		dst = dst->child;
+		bundle_size++;
+	}
+
+	return bundle_size;
+}
+
+static void
+typhoon_xfrm_bundle_add(struct net_device *dev, struct dst_entry *bundle)
+{
+	/* Walk from the outermost dst back up the chain, offloading
+	 * until we hit something we cannot deal with.
+	 */
+	struct typhoon *tp = netdev_priv(dev);
+	struct xfrm_state *x;
+	struct xfrm_offload *xol;
+	struct typhoon_xfrm_offload *txo;
+	struct dst_entry *dst_list[TYPHOON_MAX_HEADERS];
+	struct dst_entry *dst;
+	int list_size;
+	int i, proto;
+	int level = 0;
+	int last = -1;
+
+	smp_rmb();
+	if(tp->card_state != Running)
+		return;
+
+	list_size = typhoon_bundle_list(bundle, dst_list, TYPHOON_MAX_HEADERS);
+
+	for(i = 0; i < list_size; i++) {
+		dst = dst_list[i];
+		x = dst->xfrm;
+
+		/* Only support IPv4 */
+		if(dst->ops->family != AF_INET)
+			goto cannot_offload;
+
+		proto = x ? x->type->proto : IPPROTO_IP;
+
+		switch(proto) {
+		case IPPROTO_IP:
+		case IPPROTO_IPIP:
+			if(last == IPPROTO_IP || last == IPPROTO_IPIP)
+				goto cannot_offload;
+			if(level)
+				level++;
+			last = proto;
+			continue;
+		case IPPROTO_ESP:
+			if(last != IPPROTO_AH)
+				level++;
+			break;
+		case IPPROTO_AH:
+			level++;
+			break;
+		default:
+			goto cannot_offload;
+		}
+
+		last = proto;
+
+		/* We only support two layers of IPSEC, seperated by
+		 * an IP header. Given AH3 IP3 AH2 IP2 AH1 IP1, only
+		 * offload AH1 and AH2, etc.
+		 */
+		if(level > 2)
+			goto cannot_offload;
+
+		if(dst->xfrm_offload)
+			continue;
+
+		xol = xfrm_offload_get(x, dev);
+		if(!xol) {
+			xol = typhoon_offload_ipsec(tp, x);
+			if(xol)
+				xfrm_offload_hold(xol);
+		}
+
+		if(!xol)
+			goto cannot_offload;
+
+		dst->xfrm_offload = xol;
+		txo = xfrm_offload_priv(xol);
+		if(txo->tunnel)
+			last = IPPROTO_IPIP;
+	}
+
+cannot_offload:
+	return;
 }
 
 static void
