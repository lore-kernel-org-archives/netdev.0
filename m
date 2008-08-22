From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] LRO: fix return code propogation
Date: Thu, 21 Aug 2008 17:51:24 -0700
Message-ID: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:46104 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429AbYHVAvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 20:51:25 -0400
Received: by wa-out-1112.google.com with SMTP id j37so75424waf.23
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 17:51:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

LRO code needs to propogate the return values from the netif_rx and
netif_receive_skb calls specifically to allow drivers that need that
information to react correctly.  Some places in the code couldn't
return the result of the upcall to the stack, so I added the dropped
counter, which just completes the cache line of the stats struct (on
64-bit), so shouldn't be a big deal.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/inet_lro.h |    9 +++---
 net/ipv4/inet_lro.c      |   68 +++++++++++++++++++++++++++-------------------
 2 files changed, 45 insertions(+), 32 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index c4335fa..06380ec 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -39,6 +39,7 @@ struct net_lro_stats {
 	unsigned long aggregated;
 	unsigned long flushed;
 	unsigned long no_desc;
+	unsigned long dropped;
 };
 
 /*
@@ -132,7 +133,7 @@ struct net_lro_mgr {
  *        (for example get_tcp_ip_hdr)
  */
 
-void lro_receive_skb(struct net_lro_mgr *lro_mgr,
+int lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv);
 
@@ -140,7 +141,7 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
  * Processes a SKB with VLAN HW acceleration support
  */
 
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
+int lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
 				  struct sk_buff *skb,
 				  struct vlan_group *vgrp,
 				  u16 vlan_tag,
@@ -161,11 +162,11 @@ void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
  *        (for example get_tcp_ip_hdr)
  */
 
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
+int lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
+int lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
 				    struct skb_frag_struct *frags,
 				    int len, int true_size,
 				    struct vlan_group *vgrp,
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index cfd034a..918a3a1 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -301,9 +301,11 @@ out:
 	return lro_desc;
 }
 
-static void lro_flush(struct net_lro_mgr *lro_mgr,
+static int lro_flush(struct net_lro_mgr *lro_mgr,
 		      struct net_lro_desc *lro_desc)
 {
+	int ret = NET_RX_SUCCESS;
+
 	if (lro_desc->pkt_aggr_cnt > 1)
 		lro_update_tcp_ip_header(lro_desc);
 
@@ -311,23 +313,25 @@ static void lro_flush(struct net_lro_mgr *lro_mgr,
 
 	if (lro_desc->vgrp) {
 		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(lro_desc->parent,
-						 lro_desc->vgrp,
-						 lro_desc->vlan_tag);
+			ret = vlan_hwaccel_receive_skb(lro_desc->parent,
+						       lro_desc->vgrp,
+						       lro_desc->vlan_tag);
 		else
-			vlan_hwaccel_rx(lro_desc->parent,
-					lro_desc->vgrp,
-					lro_desc->vlan_tag);
+			ret = vlan_hwaccel_rx(lro_desc->parent,
+					      lro_desc->vgrp,
+					      lro_desc->vlan_tag);
 
 	} else {
 		if (lro_mgr->features & LRO_F_NAPI)
-			netif_receive_skb(lro_desc->parent);
+			ret = netif_receive_skb(lro_desc->parent);
 		else
-			netif_rx(lro_desc->parent);
+			ret = netif_rx(lro_desc->parent);
 	}
 
 	LRO_INC_STATS(lro_mgr, flushed);
 	lro_clear_desc(lro_desc);
+
+	return ret;
 }
 
 static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
@@ -376,12 +380,14 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 
 	if ((lro_desc->pkt_aggr_cnt >= lro_mgr->max_aggr) ||
 	    lro_desc->parent->len > (0xFFFF - lro_mgr->dev->mtu))
-		lro_flush(lro_mgr, lro_desc);
+		if (lro_flush(lro_mgr, lro_desc) == NET_RX_DROP)
+			LRO_INC_STATS(lro_mgr, dropped);
 
 	return 0;
 
 out2: /* send aggregated SKBs to stack */
-	lro_flush(lro_mgr, lro_desc);
+	if (lro_flush(lro_mgr, lro_desc) == NET_RX_DROP)
+		LRO_INC_STATS(lro_mgr, dropped);
 
 out:
 	return 1;
@@ -401,8 +407,10 @@ static struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
 	int hdr_len = min(len, hlen);
 
 	skb = netdev_alloc_skb(lro_mgr->dev, hlen + lro_mgr->frag_align_pad);
-	if (!skb)
+	if (!skb) {
+		LRO_INC_STATS(lro_mgr, dropped);
 		return NULL;
+	}
 
 	skb_reserve(skb, lro_mgr->frag_align_pad);
 	skb->len = len;
@@ -496,12 +504,14 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 
 	if ((skb_shinfo(lro_desc->parent)->nr_frags >= lro_mgr->max_aggr) ||
 	    lro_desc->parent->len > (0xFFFF - lro_mgr->dev->mtu))
-		lro_flush(lro_mgr, lro_desc);
+		if (lro_flush(lro_mgr, lro_desc) == NET_RX_DROP)
+			LRO_INC_STATS(lro_mgr, dropped);
 
 	return NULL;
 
 out2: /* send aggregated packets to the stack */
-	lro_flush(lro_mgr, lro_desc);
+	if (lro_flush(lro_mgr, lro_desc) == NET_RX_DROP)
+		LRO_INC_STATS(lro_mgr, dropped);
 
 out1:  /* Original packet has to be posted to the stack */
 	skb = lro_gen_skb(lro_mgr, frags, len, true_size, mac_hdr,
@@ -510,20 +520,21 @@ out:
 	return skb;
 }
 
-void lro_receive_skb(struct net_lro_mgr *lro_mgr,
+int lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv)
 {
 	if (__lro_proc_skb(lro_mgr, skb, NULL, 0, priv)) {
 		if (lro_mgr->features & LRO_F_NAPI)
-			netif_receive_skb(skb);
+			return netif_receive_skb(skb);
 		else
-			netif_rx(skb);
+			return netif_rx(skb);
 	}
+	return NET_RX_SUCCESS;
 }
 EXPORT_SYMBOL(lro_receive_skb);
 
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
+int lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
 				  struct sk_buff *skb,
 				  struct vlan_group *vgrp,
 				  u16 vlan_tag,
@@ -531,14 +542,15 @@ void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
 {
 	if (__lro_proc_skb(lro_mgr, skb, vgrp, vlan_tag, priv)) {
 		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
+			return vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
 		else
-			vlan_hwaccel_rx(skb, vgrp, vlan_tag);
+			return vlan_hwaccel_rx(skb, vgrp, vlan_tag);
 	}
+	return NET_RX_SUCCESS;
 }
 EXPORT_SYMBOL(lro_vlan_hwaccel_receive_skb);
 
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
+int lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum)
 {
@@ -547,16 +559,16 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, NULL, 0,
 				 priv, sum);
 	if (!skb)
-		return;
+		return NET_RX_SUCCESS;
 
 	if (lro_mgr->features & LRO_F_NAPI)
-		netif_receive_skb(skb);
+		return netif_receive_skb(skb);
 	else
-		netif_rx(skb);
+		return netif_rx(skb);
 }
 EXPORT_SYMBOL(lro_receive_frags);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
+int lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
 				    struct skb_frag_struct *frags,
 				    int len, int true_size,
 				    struct vlan_group *vgrp,
@@ -567,12 +579,12 @@ void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
 	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, vgrp,
 				 vlan_tag, priv, sum);
 	if (!skb)
-		return;
+		return NET_RX_SUCCESS;
 
 	if (lro_mgr->features & LRO_F_NAPI)
-		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
+		return vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
 	else
-		vlan_hwaccel_rx(skb, vgrp, vlan_tag);
+		return vlan_hwaccel_rx(skb, vgrp, vlan_tag);
 }
 EXPORT_SYMBOL(lro_vlan_hwaccel_receive_frags);
 

