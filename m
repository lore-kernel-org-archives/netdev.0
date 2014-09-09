From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2 5/8] net: pxa168_eth: get and set the mac address on the Ethernet controller
Date: Tue,  9 Sep 2014 16:44:05 +0200
Message-ID: <1410273848-24663-6-git-send-email-antoine.tenart@free-electrons.com>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58141 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757179AbaIIOoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 10:44:15 -0400
In-Reply-To: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing the MAC address, in addition to updating the dev_addr in
the net_device structure, this patch also update the MAC address
registers (high and low) of the Ethernet controller with the new MAC.
The address stored in these registers is used for IEEE 802.3x Ethernet
flow control, which is already enabled.

This patch also tries reading the MAC address stored in these registers
when probing the driver, to use the MAC address set by the bootloader
and avoid using a random one.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 36 +++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 10422f2df6cc..0ecbb3903b71 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -60,6 +60,8 @@
 #define PORT_COMMAND		0x0410
 #define PORT_STATUS		0x0418
 #define HTPR			0x0428
+#define MAC_ADDR_LOW		0x0430
+#define MAC_ADDR_HIGH		0x0438
 #define SDMA_CONFIG		0x0440
 #define SDMA_CMD		0x0448
 #define INT_CAUSE		0x0450
@@ -604,16 +606,42 @@ static void pxa168_eth_set_rx_mode(struct net_device *dev)
 		update_hash_table_mac_address(pep, NULL, ha->addr);
 }
 
+static void pxa168_eth_get_mac_address(struct net_device *dev,
+				       unsigned char *addr)
+{
+	struct pxa168_eth_private *pep = netdev_priv(dev);
+	unsigned int mac_h = rdl(pep, MAC_ADDR_HIGH);
+	unsigned int mac_l = rdl(pep, MAC_ADDR_LOW);
+
+	addr[0] = (mac_h >> 24) & 0xff;
+	addr[1] = (mac_h >> 16) & 0xff;
+	addr[2] = (mac_h >> 8) & 0xff;
+	addr[3] = mac_h & 0xff;
+	addr[4] = (mac_l >> 8) & 0xff;
+	addr[5] = mac_l & 0xff;
+}
+
 static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	unsigned char oldMac[ETH_ALEN];
+	u32 mac_h, mac_l;
 
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+
+	mac_h = sa->sa_data[0] << 24;
+	mac_h |= sa->sa_data[1] << 16;
+	mac_h |= sa->sa_data[2] << 8;
+	mac_h |= sa->sa_data[3];
+	mac_l = sa->sa_data[4] << 8;
+	mac_l |= sa->sa_data[5];
+	wrl(pep, MAC_ADDR_HIGH, mac_h);
+	wrl(pep, MAC_ADDR_LOW, mac_l);
+
 	netif_addr_lock_bh(dev);
 	update_hash_table_mac_address(pep, oldMac, dev->dev_addr);
 	netif_addr_unlock_bh(dev);
@@ -1494,8 +1522,12 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
-	dev_info(&pdev->dev, "Using random mac address\n");
-	eth_hw_addr_random(dev);
+	/* try reading the mac address, if set by the bootloader */
+	pxa168_eth_get_mac_address(dev, dev->dev_addr);
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		dev_info(&pdev->dev, "Using random mac address\n");
+		eth_hw_addr_random(dev);
+	}
 
 	pep->rx_ring_size = NUM_RX_DESCS;
 	pep->tx_ring_size = NUM_TX_DESCS;
-- 
1.9.1
