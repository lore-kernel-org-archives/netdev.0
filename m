From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 24/47] tehuti: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:26 +0200
Message-ID: <1311173689-17419-25-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	baum@tehutinetworks.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1GTOzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:46 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill priv->vlgrp and bdx_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/tehuti.c |   37 +++++++------------------------------
 drivers/net/tehuti.h |    1 -
 2 files changed, 7 insertions(+), 31 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 80fbee0..749bbf1 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -742,22 +742,6 @@ static void bdx_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
 	__bdx_vlan_rx_vid(ndev, vid, 0);
 }
 
-/*
- * bdx_vlan_rx_register - kernel hook for adding VLAN group
- * @ndev network device
- * @grp  VLAN group
- */
-static void
-bdx_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
-{
-	struct bdx_priv *priv = netdev_priv(ndev);
-
-	ENTER;
-	DBG("device='%s', group='%p'\n", ndev->name, grp);
-	priv->vlgrp = grp;
-	RET();
-}
-
 /**
  * bdx_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -1146,21 +1130,15 @@ NETIF_RX_MUX(struct bdx_priv *priv, u32 rxd_val1, u16 rxd_vlan,
 	     struct sk_buff *skb)
 {
 	ENTER;
-	DBG("rxdd->flags.bits.vtag=%d vlgrp=%p\n", GET_RXD_VTAG(rxd_val1),
-	    priv->vlgrp);
-	if (priv->vlgrp && GET_RXD_VTAG(rxd_val1)) {
-		DBG("%s: vlan rcv vlan '%x' vtag '%x', device name '%s'\n",
+	DBG("rxdd->flags.bits.vtag=%d\n", GET_RXD_VTAG(rxd_val1));
+	if (GET_RXD_VTAG(rxd_val1)) {
+		DBG("%s: vlan rcv vlan '%x' vtag '%x'\n",
 		    priv->ndev->name,
 		    GET_RXD_VLAN_ID(rxd_vlan),
-		    GET_RXD_VTAG(rxd_val1),
-		    vlan_group_get_device(priv->vlgrp,
-					  GET_RXD_VLAN_ID(rxd_vlan))->name);
-		/* NAPI variant of receive functions */
-		vlan_hwaccel_receive_skb(skb, priv->vlgrp,
-					 GET_RXD_VLAN_TCI(rxd_vlan));
-	} else {
-		netif_receive_skb(skb);
+		    GET_RXD_VTAG(rxd_val1));
+		__vlan_hwaccel_put_tag(skb, GET_RXD_VLAN_TCI(rxd_vlan));
 	}
+	netif_receive_skb(skb);
 }
 
 static void bdx_recycle_skb(struct bdx_priv *priv, struct rxd_desc *rxdd)
@@ -1877,7 +1855,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
 }
 
 static const struct net_device_ops bdx_netdev_ops = {
-	.ndo_open	 	= bdx_open,
+	.ndo_open		= bdx_open,
 	.ndo_stop		= bdx_close,
 	.ndo_start_xmit		= bdx_tx_transmit,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1885,7 +1863,6 @@ static const struct net_device_ops bdx_netdev_ops = {
 	.ndo_set_multicast_list = bdx_setmulti,
 	.ndo_change_mtu		= bdx_change_mtu,
 	.ndo_set_mac_address	= bdx_set_mac,
-	.ndo_vlan_rx_register	= bdx_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= bdx_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bdx_vlan_rx_kill_vid,
 };
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index c5642fe..709ebd6 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -250,7 +250,6 @@ struct bdx_priv {
 	struct rxf_fifo rxf_fifo0;
 	struct rxdb *rxdb;	/* rx dbs to store skb pointers */
 	int napi_stop;
-	struct vlan_group *vlgrp;
 
 	/* Tx FIFOs: 1 for data desc, 1 for empty (acks) desc */
 	struct txd_fifo txd_fifo0;
-- 
1.7.6

