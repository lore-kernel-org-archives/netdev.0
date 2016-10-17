From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 14/15] ethernet/toshiba: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:16 -0400
Message-ID: <20161017195417.48259-15-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Geoff Levand <geoff@infradead.org>,
        Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gelic_net: min_mtu 64, max_mtu 1518
- remove gelic_net_change_mtu now that it is redundant

spidernet: min_Mtu 64, max_mtu 2294
- remove spiter_net_change_mtu now that it is redundant

CC: netdev@vger.kernel.org
CC: Geoff Levand <geoff@infradead.org>
CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c      | 23 ++++------------------
 drivers/net/ethernet/toshiba/ps3_gelic_net.h      |  1 -
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c |  1 -
 drivers/net/ethernet/toshiba/spider_net.c         | 24 ++++-------------------
 4 files changed, 8 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 272f2b1..345316c 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1114,24 +1114,6 @@ static int gelic_net_poll(struct napi_struct *napi, int budget)
 	}
 	return packets_done;
 }
-/**
- * gelic_net_change_mtu - changes the MTU of an interface
- * @netdev: interface device structure
- * @new_mtu: new MTU value
- *
- * returns 0 on success, <0 on failure
- */
-int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
-	 * and mtu is outbound only anyway */
-	if ((new_mtu < GELIC_NET_MIN_MTU) ||
-	    (new_mtu > GELIC_NET_MAX_MTU)) {
-		return -EINVAL;
-	}
-	netdev->mtu = new_mtu;
-	return 0;
-}
 
 /**
  * gelic_card_interrupt - event handler for gelic_net
@@ -1446,7 +1428,6 @@ static const struct net_device_ops gelic_netdevice_ops = {
 	.ndo_stop = gelic_net_stop,
 	.ndo_start_xmit = gelic_net_xmit,
 	.ndo_set_rx_mode = gelic_net_set_multi,
-	.ndo_change_mtu = gelic_net_change_mtu,
 	.ndo_tx_timeout = gelic_net_tx_timeout,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
@@ -1513,6 +1494,10 @@ int gelic_net_setup_netdev(struct net_device *netdev, struct gelic_card *card)
 		netdev->features |= NETIF_F_VLAN_CHALLENGED;
 	}
 
+	/* MTU range: 64 - 1518 */
+	netdev->min_mtu = GELIC_NET_MIN_MTU;
+	netdev->max_mtu = GELIC_NET_MAX_MTU;
+
 	status = register_netdev(netdev);
 	if (status) {
 		dev_err(ctodev(card), "%s:Couldn't register %s %d\n",
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.h b/drivers/net/ethernet/toshiba/ps3_gelic_net.h
index 8505196..003d045 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.h
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.h
@@ -373,7 +373,6 @@ int gelic_net_stop(struct net_device *netdev);
 int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev);
 void gelic_net_set_multi(struct net_device *netdev);
 void gelic_net_tx_timeout(struct net_device *netdev);
-int gelic_net_change_mtu(struct net_device *netdev, int new_mtu);
 int gelic_net_setup_netdev(struct net_device *netdev, struct gelic_card *card);
 
 /* shared ethtool ops */
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 446ea58..b3abd02 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -2558,7 +2558,6 @@ static const struct net_device_ops gelic_wl_netdevice_ops = {
 	.ndo_stop = gelic_wl_stop,
 	.ndo_start_xmit = gelic_net_xmit,
 	.ndo_set_rx_mode = gelic_net_set_multi,
-	.ndo_change_mtu = gelic_net_change_mtu,
 	.ndo_tx_timeout = gelic_net_tx_timeout,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 36a6e8b..cb341df 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -1279,25 +1279,6 @@ static int spider_net_poll(struct napi_struct *napi, int budget)
 }
 
 /**
- * spider_net_change_mtu - changes the MTU of an interface
- * @netdev: interface device structure
- * @new_mtu: new MTU value
- *
- * returns 0 on success, <0 on failure
- */
-static int
-spider_net_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
-	 * and mtu is outbound only anyway */
-	if ( (new_mtu < SPIDER_NET_MIN_MTU ) ||
-		(new_mtu > SPIDER_NET_MAX_MTU) )
-		return -EINVAL;
-	netdev->mtu = new_mtu;
-	return 0;
-}
-
-/**
  * spider_net_set_mac - sets the MAC of an interface
  * @netdev: interface device structure
  * @ptr: pointer to new MAC address
@@ -2229,7 +2210,6 @@ static const struct net_device_ops spider_net_ops = {
 	.ndo_start_xmit		= spider_net_xmit,
 	.ndo_set_rx_mode	= spider_net_set_multi,
 	.ndo_set_mac_address	= spider_net_set_mac,
-	.ndo_change_mtu		= spider_net_change_mtu,
 	.ndo_do_ioctl		= spider_net_do_ioctl,
 	.ndo_tx_timeout		= spider_net_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2299,6 +2279,10 @@ spider_net_setup_netdev(struct spider_net_card *card)
 	/* some time: NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
 	 *		NETIF_F_HW_VLAN_CTAG_FILTER */
 
+	/* MTU range: 64 - 2294 */
+	netdev->min_mtu = SPIDER_NET_MIN_MTU;
+	netdev->max_mtu = SPIDER_NET_MAX_MTU;
+
 	netdev->irq = card->pdev->irq;
 	card->num_rx_ints = 0;
 	card->ignore_rx_ramfull = 0;
-- 
2.10.0
