From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 08/47] lro: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:10 +0200
Message-ID: <1311173689-17419-9-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656Ab1GTOzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:09 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- remove useless vlan parameters and pointers

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/inet_lro.h |    2 --
 net/ipv4/inet_lro.c      |   39 +++++++++++----------------------------
 2 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index b27e773..2cf55af 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -50,7 +50,6 @@ struct net_lro_desc {
 	struct skb_frag_struct *next_frag;
 	struct iphdr *iph;
 	struct tcphdr *tcph;
-	struct vlan_group *vgrp;
 	__wsum  data_csum;
 	__be32 tcp_rcv_tsecr;
 	__be32 tcp_rcv_tsval;
@@ -60,7 +59,6 @@ struct net_lro_desc {
 	u16 ip_tot_len;
 	u16 tcp_saw_tstamp; 		/* timestamps enabled */
 	__be16 tcp_window;
-	u16 vlan_tag;
 	int pkt_aggr_cnt;		/* counts aggregated packets */
 	int vlan_packet;
 	int mss;
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 5cf0759..ef7ae60 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -146,8 +146,7 @@ static __wsum lro_tcp_data_csum(struct iphdr *iph, struct tcphdr *tcph, int len)
 }
 
 static void lro_init_desc(struct net_lro_desc *lro_desc, struct sk_buff *skb,
-			  struct iphdr *iph, struct tcphdr *tcph,
-			  u16 vlan_tag, struct vlan_group *vgrp)
+			  struct iphdr *iph, struct tcphdr *tcph)
 {
 	int nr_frags;
 	__be32 *ptr;
@@ -173,8 +172,6 @@ static void lro_init_desc(struct net_lro_desc *lro_desc, struct sk_buff *skb,
 	}
 
 	lro_desc->mss = tcp_data_len;
-	lro_desc->vgrp = vgrp;
-	lro_desc->vlan_tag = vlan_tag;
 	lro_desc->active = 1;
 
 	lro_desc->data_csum = lro_tcp_data_csum(iph, tcph,
@@ -309,29 +306,17 @@ static void lro_flush(struct net_lro_mgr *lro_mgr,
 
 	skb_shinfo(lro_desc->parent)->gso_size = lro_desc->mss;
 
-	if (lro_desc->vgrp) {
-		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(lro_desc->parent,
-						 lro_desc->vgrp,
-						 lro_desc->vlan_tag);
-		else
-			vlan_hwaccel_rx(lro_desc->parent,
-					lro_desc->vgrp,
-					lro_desc->vlan_tag);
-
-	} else {
-		if (lro_mgr->features & LRO_F_NAPI)
-			netif_receive_skb(lro_desc->parent);
-		else
-			netif_rx(lro_desc->parent);
-	}
+	if (lro_mgr->features & LRO_F_NAPI)
+		netif_receive_skb(lro_desc->parent);
+	else
+		netif_rx(lro_desc->parent);
 
 	LRO_INC_STATS(lro_mgr, flushed);
 	lro_clear_desc(lro_desc);
 }
 
 static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
-			  struct vlan_group *vgrp, u16 vlan_tag, void *priv)
+			  void *priv)
 {
 	struct net_lro_desc *lro_desc;
 	struct iphdr *iph;
@@ -360,7 +345,7 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 			goto out;
 
 		skb->ip_summed = lro_mgr->ip_summed_aggr;
-		lro_init_desc(lro_desc, skb, iph, tcph, vlan_tag, vgrp);
+		lro_init_desc(lro_desc, skb, iph, tcph);
 		LRO_INC_STATS(lro_mgr, aggregated);
 		return 0;
 	}
@@ -433,8 +418,7 @@ static struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
 static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 					  struct skb_frag_struct *frags,
 					  int len, int true_size,
-					  struct vlan_group *vgrp,
-					  u16 vlan_tag, void *priv, __wsum sum)
+					  void *priv, __wsum sum)
 {
 	struct net_lro_desc *lro_desc;
 	struct iphdr *iph;
@@ -480,7 +464,7 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 		tcph = (void *)((u8 *)skb->data + vlan_hdr_len
 				+ IP_HDR_LEN(iph));
 
-		lro_init_desc(lro_desc, skb, iph, tcph, 0, NULL);
+		lro_init_desc(lro_desc, skb, iph, tcph);
 		LRO_INC_STATS(lro_mgr, aggregated);
 		return NULL;
 	}
@@ -514,7 +498,7 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv)
 {
-	if (__lro_proc_skb(lro_mgr, skb, NULL, 0, priv)) {
+	if (__lro_proc_skb(lro_mgr, skb, priv)) {
 		if (lro_mgr->features & LRO_F_NAPI)
 			netif_receive_skb(skb);
 		else
@@ -529,8 +513,7 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 {
 	struct sk_buff *skb;
 
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, NULL, 0,
-				 priv, sum);
+	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);
 	if (!skb)
 		return;
 
-- 
1.7.6

