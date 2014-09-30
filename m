From: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v6 05/10] net: pxa168_eth: set the mac address on the Ethernet controller
Date: Tue, 30 Sep 2014 16:28:11 +0200
Message-ID: <1412087296-18475-6-git-send-email-antoine.tenart@free-electrons.com>
References: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412087296-18475-1-git-send-email-antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When changing the MAC address, in addition to updating the dev_addr in
the net_device structure, this patch also update the MAC address
registers (high and low) of the Ethernet controller with the new MAC.
The address stored in these registers is used for IEEE 802.3x Ethernet
flow control, which is already enabled.

Signed-off-by: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 46b86714e9d7..6917904409b8 100644
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
@@ -609,11 +611,22 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
