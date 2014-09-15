From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v3 5/9] net: pxa168_eth: get and set the mac address on the Ethernet controller
Date: Mon, 15 Sep 2014 16:01:49 +0200
Message-ID: <1410789713-15341-6-git-send-email-antoine.tenart@free-electrons.com>
References: <1410789713-15341-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410789713-15341-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When changing the MAC address, in addition to updating the dev_addr in
the net_device structure, this patch also update the MAC address
registers (high and low) of the Ethernet controller with the new MAC.
The address stored in these registers is used for IEEE 802.3x Ethernet
flow control, which is already enabled.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 5aa2ce2625b4..d9f4f7d05a1e 100644
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
-- 
1.9.1
