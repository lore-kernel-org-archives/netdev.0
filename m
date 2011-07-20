From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 30/47] ns83820: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:32 +0200
Message-ID: <1311173689-17419-31-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090Ab1GTOzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:52 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill dev->vlgrp and ns83820_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ns83820.c |   33 ++++-----------------------------
 1 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index d3afb45..e736aec 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -430,10 +430,6 @@ struct ns83820 {
 	struct pci_dev		*pci_dev;
 	struct net_device	*ndev;
 
-#ifdef NS83820_VLAN_ACCEL_SUPPORT
-	struct vlan_group	*vlgrp;
-#endif
-
 	struct rx_info		rx_info;
 	struct tasklet_struct	rx_tasklet;
 
@@ -494,22 +490,6 @@ static inline void kick_rx(struct net_device *ndev)
 #define start_tx_okay(dev)	\
 	(((NR_TX_DESC-2 + dev->tx_done_idx - dev->tx_free_idx) % NR_TX_DESC) > MIN_TX_DESC_FREE)
 
-
-#ifdef NS83820_VLAN_ACCEL_SUPPORT
-static void ns83820_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
-{
-	struct ns83820 *dev = PRIV(ndev);
-
-	spin_lock_irq(&dev->misc_lock);
-	spin_lock(&dev->tx_lock);
-
-	dev->vlgrp = grp;
-
-	spin_unlock(&dev->tx_lock);
-	spin_unlock_irq(&dev->misc_lock);
-}
-#endif
-
 /* Packet Receiver
  *
  * The hardware supports linked lists of receive descriptors for
@@ -930,14 +910,12 @@ static void rx_irq(struct net_device *ndev)
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
 			if(extsts & EXTSTS_VPKT) {
 				unsigned short tag;
+
 				tag = ntohs(extsts & EXTSTS_VTG_MASK);
-				rx_rc = vlan_hwaccel_rx(skb,dev->vlgrp,tag);
-			} else {
-				rx_rc = netif_rx(skb);
+				__vlan_hwaccel_put_tag(skb, tag);
 			}
-#else
-			rx_rc = netif_rx(skb);
 #endif
+			rx_rc = netif_rx(skb);
 			if (NET_RX_DROP == rx_rc) {
 netdev_mangle_me_harder_failed:
 				ndev->stats.rx_dropped++;
@@ -1961,11 +1939,8 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_change_mtu		= ns83820_change_mtu,
 	.ndo_set_multicast_list = ns83820_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_tx_timeout		= ns83820_tx_timeout,
-#ifdef NS83820_VLAN_ACCEL_SUPPORT
-	.ndo_vlan_rx_register	= ns83820_vlan_rx_register,
-#endif
 };
 
 static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
-- 
1.7.6

