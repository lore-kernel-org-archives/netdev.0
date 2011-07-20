From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 09/47] amd8111e: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:11 +0200
Message-ID: <1311173689-17419-10-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab1GTOzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:10 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill lp->vlgrp and amd8111e_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/amd8111e.c |   34 ++++++----------------------------
 drivers/net/amd8111e.h |    3 ---
 2 files changed, 6 insertions(+), 31 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index db6d2da..78002ef 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -661,15 +661,6 @@ static void amd8111e_free_ring(struct amd8111e_priv* lp)
 	}
 
 }
-#if AMD8111E_VLAN_TAG_USED
-/*
-This is the receive indication function for packets with vlan tag.
-*/
-static int amd8111e_vlan_rx(struct amd8111e_priv *lp, struct sk_buff *skb, u16 vlan_tag)
-{
-	return vlan_hwaccel_receive_skb(skb, lp->vlgrp,vlan_tag);
-}
-#endif
 
 /*
 This function will free all the transmit skbs that are actually transmitted by the device. It will check the ownership of the skb before freeing the skb.
@@ -764,7 +755,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 #if AMD8111E_VLAN_TAG_USED
 			vtag = status & TT_MASK;
 			/*MAC will strip vlan tag*/
-			if(lp->vlgrp != NULL && vtag !=0)
+			if (vtag != 0)
 				min_pkt_len =MIN_PKT_LEN - 4;
 			else
 #endif
@@ -799,12 +790,12 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			skb->protocol = eth_type_trans(skb, dev);
 
 #if AMD8111E_VLAN_TAG_USED
-			if(lp->vlgrp != NULL && (vtag == TT_VLAN_TAGGED)){
-				amd8111e_vlan_rx(lp, skb,
-					 le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info));
-			} else
+			if (vtag == TT_VLAN_TAGGED){
+				u16 vlan_tag = le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info);
+				__vlan_hwaccel_put_tag(skb, vlan_tag);
+			}
 #endif
-				netif_receive_skb(skb);
+			netif_receive_skb(skb);
 			/*COAL update rx coalescing parameters*/
 			lp->coal_conf.rx_packets++;
 			lp->coal_conf.rx_bytes += pkt_len;
@@ -1598,16 +1589,6 @@ static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 	return err;
 }
 
-#if AMD8111E_VLAN_TAG_USED
-static void amd8111e_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct  amd8111e_priv *lp = netdev_priv(dev);
-	spin_lock_irq(&lp->lock);
-	lp->vlgrp = grp;
-	spin_unlock_irq(&lp->lock);
-}
-#endif
-
 static int amd8111e_enable_magicpkt(struct amd8111e_priv* lp)
 {
 	writel( VAL1|MPPLBA, lp->mmio + CMD3);
@@ -1822,9 +1803,6 @@ static const struct net_device_ops amd8111e_netdev_ops = {
 	.ndo_set_mac_address	= amd8111e_set_mac_address,
 	.ndo_do_ioctl		= amd8111e_ioctl,
 	.ndo_change_mtu		= amd8111e_change_mtu,
-#if AMD8111E_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= amd8111e_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	 = amd8111e_poll,
 #endif
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index b5926af..2ff2e7a 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -783,9 +783,6 @@ struct amd8111e_priv{
 	struct net_device *next;
 	int mii;
 	struct mii_if_info mii_if;
-#if AMD8111E_VLAN_TAG_USED
-	struct vlan_group		*vlgrp;
-#endif
 	char opened;
 	unsigned int drv_rx_errors;
 	struct amd8111e_coalesce_conf coal_conf;
-- 
1.7.6

