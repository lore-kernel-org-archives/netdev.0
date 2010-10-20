From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 12/14] lro: Remove explicit vlan support.
Date: Wed, 20 Oct 2010 16:56:12 -0700
Message-ID: <1287618974-4714-13-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56144 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab0JTX4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:40 -0400
Received: by qyk12 with SMTP id 12so1776249qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:40 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the new vlan accleration model, LRO no longer needs to be
explicitly passed the vlan information because it is contained in
the skb.  Since all LRO did was pass the vlan through, this removes
that knowledge.

Signed-off-by: Jesse Gross <jesse@nicira.com>
--
This patch can only be applied once all drivers that use LRO and vlan acceleration
have been converted over to the new model.
---
 include/linux/inet_lro.h |   20 ------------
 net/ipv4/inet_lro.c      |   74 +++++++---------------------------------------
 2 files changed, 11 insertions(+), 83 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index c4335fa..667281a 100644
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
@@ -60,9 +59,7 @@ struct net_lro_desc {
 	u16 ip_tot_len;
 	u16 tcp_saw_tstamp; 		/* timestamps enabled */
 	__be16 tcp_window;
-	u16 vlan_tag;
 	int pkt_aggr_cnt;		/* counts aggregated packets */
-	int vlan_packet;
 	int mss;
 	int active;
 };
@@ -137,16 +134,6 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     void *priv);
 
 /*
- * Processes a SKB with VLAN HW acceleration support
- */
-
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
-				  struct sk_buff *skb,
-				  struct vlan_group *vgrp,
-				  u16 vlan_tag,
-				  void *priv);
-
-/*
  * Processes a fragment list
  *
  * This functions aggregate fragments and generate SKBs do pass
@@ -165,13 +152,6 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
-				    int len, int true_size,
-				    struct vlan_group *vgrp,
-				    u16 vlan_tag,
-				    void *priv, __wsum sum);
-
 /*
  * Forward all aggregated SKBs held by lro_mgr to network stack
  */
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 47038cb..8945a1d 100644
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
@@ -523,29 +507,13 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 }
 EXPORT_SYMBOL(lro_receive_skb);
 
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
-				  struct sk_buff *skb,
-				  struct vlan_group *vgrp,
-				  u16 vlan_tag,
-				  void *priv)
-{
-	if (__lro_proc_skb(lro_mgr, skb, vgrp, vlan_tag, priv)) {
-		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
-		else
-			vlan_hwaccel_rx(skb, vgrp, vlan_tag);
-	}
-}
-EXPORT_SYMBOL(lro_vlan_hwaccel_receive_skb);
-
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum)
 {
 	struct sk_buff *skb;
 
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, NULL, 0,
-				 priv, sum);
+	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);
 	if (!skb)
 		return;
 
@@ -556,26 +524,6 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 }
 EXPORT_SYMBOL(lro_receive_frags);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
-				    int len, int true_size,
-				    struct vlan_group *vgrp,
-				    u16 vlan_tag, void *priv, __wsum sum)
-{
-	struct sk_buff *skb;
-
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, vgrp,
-				 vlan_tag, priv, sum);
-	if (!skb)
-		return;
-
-	if (lro_mgr->features & LRO_F_NAPI)
-		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
-	else
-		vlan_hwaccel_rx(skb, vgrp, vlan_tag);
-}
-EXPORT_SYMBOL(lro_vlan_hwaccel_receive_frags);
-
 void lro_flush_all(struct net_lro_mgr *lro_mgr)
 {
 	int i;
-- 
1.7.1

