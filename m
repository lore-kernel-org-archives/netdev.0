From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] core, nfqueue,
	openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Tue, 18 Mar 2014 21:17:35 +0000
Message-ID: <1395177455-2077-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>,
 kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
 Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 Paul Durrant <Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

skb_zerocopy can copy elements of the frags array between skbs, but it doesn't
orphan them. Also, it doesn't handle errors, so this patch takes care of that
as well.

Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03db95a..35c4e85 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2508,8 +2508,8 @@ int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    unsigned int flags);
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
-void skb_zerocopy(struct sk_buff *to, const struct sk_buff *from,
-		  int len, int hlen);
+int skb_zerocopy(struct sk_buff *to, const struct sk_buff *from,
+		 int len, int hlen);
 void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
 int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
 void skb_scrub_packet(struct sk_buff *skb, bool xnet);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3f14c63..60f623c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2127,25 +2127,36 @@ EXPORT_SYMBOL_GPL(skb_zerocopy_headlen);
  *
  *	The `hlen` as calculated by skb_zerocopy_headlen() specifies the
  *	headroom in the `to` buffer.
+ *
+ *	Return value:
+ *	0: everything is OK
+ *	-ENOMEM: couldn't orphan frags of from due to lack of memory
+ *	-EFAULT: skb_copy_bits() found some problem with geometry
  */
-void
+int
 skb_zerocopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
 {
 	int i, j = 0;
 	int plen = 0; /* length of skb->head fragment */
+	int ret;
 	struct page *page;
 	unsigned int offset;
 
 	BUG_ON(!from->head_frag && !hlen);
 
 	/* dont bother with small payloads */
-	if (len <= skb_tailroom(to)) {
-		skb_copy_bits(from, 0, skb_put(to, len), len);
-		return;
+	if (len <= skb_tailroom(to))
+		return skb_copy_bits(from, 0, skb_put(to, len), len);
+
+	if (unlikely(skb_orphan_frags(to, GFP_ATOMIC))) {
+		skb_tx_error(to);
+		return -ENOMEM;
 	}
 
 	if (hlen) {
-		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
+		ret = skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
+		if (unlikely(ret))
+			return ret;
 		len -= hlen;
 	} else {
 		plen = min_t(int, skb_headlen(from), len);
@@ -2173,6 +2184,8 @@ skb_zerocopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
 		j++;
 	}
 	skb_shinfo(to)->nr_frags = j;
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(skb_zerocopy);
 
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index f072fe8..ea02d16 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -488,7 +488,8 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
-		skb_zerocopy(skb, entskb, data_len, hlen);
+		if (skb_zerocopy(skb, entskb, data_len, hlen))
+			goto nla_put_failure;
 	}
 
 	nlh->nlmsg_len = skb->len;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c53fe0c..9a9f668 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -464,7 +464,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	}
 	nla->nla_len = nla_attr_size(skb->len);
 
-	skb_zerocopy(user_skb, skb, skb->len, hlen);
+	err = skb_zerocopy(user_skb, skb, skb->len, hlen);
+	if (err)
+		goto out;
 
 	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
 	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
