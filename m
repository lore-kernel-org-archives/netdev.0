From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 07/15] ethernet/realtek: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:09 -0400
Message-ID: <20161017195417.48259-8-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Realtek linux nic maintainers <nic_swsd@realtek.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45310 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758812AbcJQTyd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:54:33 -0400
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8139cp: min_mtu 60, max_mtu 4096

8139too: min_mtu 68, max_mtu 1770

r8169: min_mtu 60, max_mtu depends on chipset, 1500 to 9k-ish

CC: netdev@vger.kernel.org
CC: Realtek linux nic maintainers <nic_swsd@realtek.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c  |  8 ++++----
 drivers/net/ethernet/realtek/8139too.c | 13 ++++---------
 drivers/net/ethernet/realtek/r8169.c   |  8 ++++----
 3 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 5297bf7..b7c89eb 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1277,10 +1277,6 @@ static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct cp_private *cp = netdev_priv(dev);
 
-	/* check for invalid MTU, according to hardware limits */
-	if (new_mtu < CP_MIN_MTU || new_mtu > CP_MAX_MTU)
-		return -EINVAL;
-
 	/* if network interface not up, no need for complexity */
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
@@ -2010,6 +2006,10 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
+	/* MTU range: 60 - 4096 */
+	dev->min_mtu = CP_MIN_MTU;
+	dev->max_mtu = CP_MAX_MTU;
+
 	rc = register_netdev(dev);
 	if (rc)
 		goto err_out_iomap;
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index da4c2d8..9bc047a 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -924,19 +924,10 @@ static int rtl8139_set_features(struct net_device *dev, netdev_features_t featur
 	return 0;
 }
 
-static int rtl8139_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 68 || new_mtu > MAX_ETH_DATA_SIZE)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_open		= rtl8139_open,
 	.ndo_stop		= rtl8139_close,
 	.ndo_get_stats64	= rtl8139_get_stats64,
-	.ndo_change_mtu		= rtl8139_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= rtl8139_set_mac_address,
 	.ndo_start_xmit		= rtl8139_start_xmit,
@@ -1022,6 +1013,10 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 	dev->hw_features |= NETIF_F_RXALL;
 	dev->hw_features |= NETIF_F_RXFCS;
 
+	/* MTU range: 68 - 1770 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = MAX_ETH_DATA_SIZE;
+
 	/* tp zeroed and aligned in alloc_etherdev */
 	tp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e55638c..b698ea5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6673,10 +6673,6 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (new_mtu < ETH_ZLEN ||
-	    new_mtu > rtl_chip_infos[tp->mac_version].jumbo_max)
-		return -EINVAL;
-
 	if (new_mtu > ETH_DATA_LEN)
 		rtl_hw_jumbo_enable(tp);
 	else
@@ -8430,6 +8426,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hw_features |= NETIF_F_RXALL;
 	dev->hw_features |= NETIF_F_RXFCS;
 
+	/* MTU range: 60 - hw-specific max */
+	dev->min_mtu = ETH_ZLEN;
+	dev->max_mtu = rtl_chip_infos[chipset].jumbo_max;
+
 	tp->hw_start = cfg->hw_start;
 	tp->event_slow = cfg->event_slow;
 
-- 
2.10.0
