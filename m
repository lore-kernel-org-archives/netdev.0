From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] neigh: Pass neighbour entry to output ops.
Date: Mon, 18 Jul 2011 01:25:02 -0700 (PDT)
Message-ID: <20110718.012502.1121009219176482476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab1GRIZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6I8P2Ep028237
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:25:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will get us closer to being able to do "neigh stuff"
completely independent of the underlying dst_entry for
protocols (ipv4/ipv6) that wish to do so.

We will also be able to make dst entries neigh-less.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h   |   19 ++++++++++---------
 net/atm/clip.c            |    4 ++--
 net/bridge/br_netfilter.c |    4 ++--
 net/core/neighbour.c      |   25 ++++++++++++++-----------
 net/decnet/dn_neigh.c     |   18 ++++++------------
 net/decnet/dn_route.c     |   13 ++++++++++---
 net/ipv4/arp.c            |    6 +++---
 net/ipv6/ndisc.c          |    6 +++---
 8 files changed, 50 insertions(+), 45 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 334e92f..4ba8521 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -109,7 +109,7 @@ struct neighbour {
 	seqlock_t		ha_lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		hh;
-	int			(*output)(struct sk_buff *skb);
+	int			(*output)(struct neighbour *, struct sk_buff *);
 	const struct neigh_ops	*ops;
 	struct rcu_head		rcu;
 	struct net_device	*dev;
@@ -118,10 +118,10 @@ struct neighbour {
 
 struct neigh_ops {
 	int			family;
-	void			(*solicit)(struct neighbour *, struct sk_buff*);
-	void			(*error_report)(struct neighbour *, struct sk_buff*);
-	int			(*output)(struct sk_buff*);
-	int			(*connected_output)(struct sk_buff*);
+	void			(*solicit)(struct neighbour *, struct sk_buff *);
+	void			(*error_report)(struct neighbour *, struct sk_buff *);
+	int			(*output)(struct neighbour *, struct sk_buff *);
+	int			(*connected_output)(struct neighbour *, struct sk_buff *);
 };
 
 struct pneigh_entry {
@@ -203,9 +203,10 @@ extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 					     u32 flags);
 extern void			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
-extern int			neigh_resolve_output(struct sk_buff *skb);
-extern int			neigh_connected_output(struct sk_buff *skb);
-extern int			neigh_compat_output(struct sk_buff *skb);
+extern int			neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
+extern int			neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb);
+extern int			neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb);
+extern int			neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb);
 extern struct neighbour 	*neigh_event_ns(struct neigh_table *tbl,
 						u8 *lladdr, void *saddr,
 						struct net_device *dev);
@@ -348,7 +349,7 @@ static inline int neigh_output(struct neighbour *n, struct sk_buff *skb)
 	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
 		return neigh_hh_output(hh, skb);
 	else
-		return n->output(skb);
+		return n->output(n, skb);
 }
 
 static inline struct neighbour *
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 40d7368..c6cd531 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -271,8 +271,8 @@ static const struct neigh_ops clip_neigh_ops = {
 	.family =		AF_INET,
 	.solicit =		clip_neigh_solicit,
 	.error_report =		clip_neigh_error,
-	.output =		dev_queue_xmit,
-	.connected_output =	dev_queue_xmit,
+	.output =		neigh_direct_output,
+	.connected_output =	neigh_direct_output,
 };
 
 static int clip_constructor(struct neighbour *neigh)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 75ee421..1fe43fd 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -355,14 +355,14 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 		neigh_hh_bridge(&neigh->hh, skb);
 		skb->dev = nf_bridge->physindev;
 		return br_handle_frame_finish(skb);
-	} else if (dst->neighbour) {
+	} else {
 		/* the neighbour function below overwrites the complete
 		 * MAC header, so we save the Ethernet source address and
 		 * protocol number. */
 		skb_copy_from_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN), skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
 		/* tell br_dev_xmit to continue with forwarding */
 		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-		return dst->neighbour->output(skb);
+		return neigh->output(neigh, skb);
 	}
 free_skb:
 	kfree_skb(skb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b031cf6..cefb8e5 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -98,7 +98,7 @@ static const struct file_operations neigh_stat_seq_fops;
 
 static DEFINE_RWLOCK(neigh_tbl_lock);
 
-static int neigh_blackhole(struct sk_buff *skb)
+static int neigh_blackhole(struct neighbour *neigh, struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return -ENETDOWN;
@@ -1158,7 +1158,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
 			if (skb_dst(skb) && skb_dst(skb)->neighbour)
 				n1 = skb_dst(skb)->neighbour;
-			n1->output(skb);
+			n1->output(n1, skb);
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
@@ -1214,7 +1214,7 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
  * but resolution is not made yet.
  */
 
-int neigh_compat_output(struct sk_buff *skb)
+int neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 
@@ -1231,13 +1231,12 @@ EXPORT_SYMBOL(neigh_compat_output);
 
 /* Slow and careful. */
 
-int neigh_resolve_output(struct sk_buff *skb)
+int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh;
 	int rc = 0;
 
-	if (!dst || !(neigh = dst->neighbour))
+	if (!dst)
 		goto discard;
 
 	__skb_pull(skb, skb_network_offset(skb));
@@ -1265,7 +1264,7 @@ out:
 	return rc;
 discard:
 	NEIGH_PRINTK1("neigh_resolve_output: dst=%p neigh=%p\n",
-		      dst, dst ? dst->neighbour : NULL);
+		      dst, neigh);
 out_kfree_skb:
 	rc = -EINVAL;
 	kfree_skb(skb);
@@ -1275,13 +1274,11 @@ EXPORT_SYMBOL(neigh_resolve_output);
 
 /* As fast as possible without hh cache */
 
-int neigh_connected_output(struct sk_buff *skb)
+int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	int err;
-	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	unsigned int seq;
+	int err;
 
 	__skb_pull(skb, skb_network_offset(skb));
 
@@ -1301,6 +1298,12 @@ int neigh_connected_output(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(neigh_connected_output);
 
+int neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb)
+{
+	return dev_queue_xmit(skb);
+}
+EXPORT_SYMBOL(neigh_direct_output);
+
 static void neigh_proxy_process(unsigned long arg)
 {
 	struct neigh_table *tbl = (struct neigh_table *)arg;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 84fee8a..5d61e89 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -51,9 +51,9 @@
 static int dn_neigh_construct(struct neighbour *);
 static void dn_long_error_report(struct neighbour *, struct sk_buff *);
 static void dn_short_error_report(struct neighbour *, struct sk_buff *);
-static int dn_long_output(struct sk_buff *);
-static int dn_short_output(struct sk_buff *);
-static int dn_phase3_output(struct sk_buff *);
+static int dn_long_output(struct neighbour *, struct sk_buff *);
+static int dn_short_output(struct neighbour *, struct sk_buff *);
+static int dn_phase3_output(struct neighbour *, struct sk_buff *);
 
 
 /*
@@ -218,10 +218,8 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int dn_long_output(struct sk_buff *skb)
+static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_long_packet) + 3;
 	unsigned char *data;
@@ -265,10 +263,8 @@ static int dn_long_output(struct sk_buff *skb)
 		       neigh->dev, dn_neigh_output_packet);
 }
 
-static int dn_short_output(struct sk_buff *skb)
+static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
 	struct dn_short_packet *sp;
@@ -309,10 +305,8 @@ static int dn_short_output(struct sk_buff *skb)
  * Phase 3 output is the same is short output, execpt that
  * it clears the area bits before transmission.
  */
-static int dn_phase3_output(struct sk_buff *skb)
+static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
 	struct dn_short_packet *sp;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index fceb86c..3b6400d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -705,6 +705,14 @@ out:
 	return NET_RX_DROP;
 }
 
+static int dn_to_neigh_output(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct neighbour *n = dst->neighbour;
+
+	return n->output(n, skb);
+}
+
 static int dn_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -733,7 +741,7 @@ static int dn_output(struct sk_buff *skb)
 	cb->hops = 0;
 
 	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, skb, NULL, dev,
-		       neigh->output);
+		       dn_to_neigh_output);
 
 error:
 	if (net_ratelimit())
@@ -750,7 +758,6 @@ static int dn_forward(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_dev *dn_db = rcu_dereference(dst->dev->dn_ptr);
 	struct dn_route *rt;
-	struct neighbour *neigh = dst->neighbour;
 	int header_len;
 #ifdef CONFIG_NETFILTER
 	struct net_device *dev = skb->dev;
@@ -783,7 +790,7 @@ static int dn_forward(struct sk_buff *skb)
 		cb->rt_flags |= DN_RT_F_IE;
 
 	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, skb, dev, skb->dev,
-		       neigh->output);
+		       dn_to_neigh_output);
 
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 8a21403..96a164a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -150,8 +150,8 @@ static const struct neigh_ops arp_hh_ops = {
 
 static const struct neigh_ops arp_direct_ops = {
 	.family =		AF_INET,
-	.output =		dev_queue_xmit,
-	.connected_output =	dev_queue_xmit,
+	.output =		neigh_direct_output,
+	.connected_output =	neigh_direct_output,
 };
 
 static const struct neigh_ops arp_broken_ops = {
@@ -250,7 +250,7 @@ static int arp_constructor(struct neighbour *neigh)
 	if (!dev->header_ops) {
 		neigh->nud_state = NUD_NOARP;
 		neigh->ops = &arp_direct_ops;
-		neigh->output = dev_queue_xmit;
+		neigh->output = neigh_direct_output;
 	} else {
 		/* Good devices (checked by reading texts, but only Ethernet is
 		   tested)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 482b970..e08ce55 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -120,8 +120,8 @@ static const struct neigh_ops ndisc_hh_ops = {
 
 static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
-	.output =		dev_queue_xmit,
-	.connected_output =	dev_queue_xmit,
+	.output =		neigh_direct_output,
+	.connected_output =	neigh_direct_output,
 };
 
 struct neigh_table nd_tbl = {
@@ -386,7 +386,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 	if (!dev->header_ops) {
 		neigh->nud_state = NUD_NOARP;
 		neigh->ops = &ndisc_direct_ops;
-		neigh->output = dev_queue_xmit;
+		neigh->output = neigh_direct_output;
 	} else {
 		if (is_multicast) {
 			neigh->nud_state = NUD_NOARP;
-- 
1.7.6

