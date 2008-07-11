From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2: Support secondary MAC addresses.
Date: Thu, 10 Jul 2008 18:29:14 -0700
Message-ID: <1215739755-5495-5-git-send-email-mchan@broadcom.com>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2651 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757314AbYGKB0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:32 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuring secondary unicast addresses.  There
are 4 additional perfect match filters which can be used for
secondary unicast address support.

  *  Modified bnx2_set_mac_addr() to be more generic in handling
     the setting of the perfect match filters
  *  Changed bnx2_set_rx_mode() to handle the unicast dev_addr_list

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   35 +++++++++++++++++++++++++++--------
 drivers/net/bnx2.h |    5 +++++
 2 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2d0213e..0d0bb93 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2451,19 +2451,18 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 }
 
 static void
-bnx2_set_mac_addr(struct bnx2 *bp)
+bnx2_set_mac_addr(struct bnx2 *bp, u8 *mac_addr, u32 pos)
 {
 	u32 val;
-	u8 *mac_addr = bp->dev->dev_addr;
 
 	val = (mac_addr[0] << 8) | mac_addr[1];
 
-	REG_WR(bp, BNX2_EMAC_MAC_MATCH0, val);
+	REG_WR(bp, BNX2_EMAC_MAC_MATCH0 + (pos * 8), val);
 
 	val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		(mac_addr[4] << 8) | mac_addr[5];
 
-	REG_WR(bp, BNX2_EMAC_MAC_MATCH1, val);
+	REG_WR(bp, BNX2_EMAC_MAC_MATCH1 + (pos * 8), val);
 }
 
 static inline int
@@ -3223,6 +3222,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 rx_mode, sort_mode;
+	struct dev_addr_list *uc_ptr;
 	int i;
 
 	spin_lock_bh(&bp->phy_lock);
@@ -3278,6 +3278,25 @@ bnx2_set_rx_mode(struct net_device *dev)
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_HSH_EN;
 	}
 
+	uc_ptr = NULL;
+	if (dev->uc_count > BNX2_MAX_UNICAST_ADDRESSES) {
+		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
+		sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN |
+			     BNX2_RPM_SORT_USER0_PROM_VLAN;
+	} else if (!(dev->flags & IFF_PROMISC)) {
+		uc_ptr = dev->uc_list;
+
+		/* Add all entries into to the match filter list */
+		for (i = 0; i < dev->uc_count; i++) {
+			bnx2_set_mac_addr(bp, uc_ptr->da_addr,
+					  i + BNX2_START_UNICAST_ADDRESS_INDEX);
+			sort_mode |= (1 <<
+				      (i + BNX2_START_UNICAST_ADDRESS_INDEX));
+			uc_ptr = uc_ptr->next;
+		}
+
+	}
+
 	if (rx_mode != bp->rx_mode) {
 		bp->rx_mode = rx_mode;
 		REG_WR(bp, BNX2_EMAC_RX_MODE, rx_mode);
@@ -3562,7 +3581,7 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 			bp->autoneg = autoneg;
 			bp->advertising = advertising;
 
-			bnx2_set_mac_addr(bp);
+			bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
 
 			val = REG_RD(bp, BNX2_EMAC_MODE);
 
@@ -4472,7 +4491,7 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	bnx2_init_nvram(bp);
 
-	bnx2_set_mac_addr(bp);
+	bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
 
 	val = REG_RD(bp, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
@@ -7100,7 +7119,7 @@ bnx2_change_mac_addr(struct net_device *dev, void *p)
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev))
-		bnx2_set_mac_addr(bp);
+		bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
 
 	return 0;
 }
@@ -7643,7 +7662,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hard_start_xmit = bnx2_start_xmit;
 	dev->stop = bnx2_close;
 	dev->get_stats = bnx2_get_stats;
-	dev->set_multicast_list = bnx2_set_rx_mode;
+	dev->set_rx_mode = bnx2_set_rx_mode;
 	dev->do_ioctl = bnx2_ioctl;
 	dev->set_mac_address = bnx2_change_mac_addr;
 	dev->change_mtu = bnx2_change_mtu;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 7b882fd..bb7b5d5 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6440,6 +6440,11 @@ struct l2_fhdr {
 
 #define BNX2_MISC_ENABLE_DEFAULT	0x17ffffff
 
+#define BNX2_START_UNICAST_ADDRESS_INDEX	4
+#define BNX2_END_UNICAST_ADDRESS_INDEX		7
+#define BNX2_MAX_UNICAST_ADDRESSES     	(BNX2_END_UNICAST_ADDRESS_INDEX - \
+					 BNX2_START_UNICAST_ADDRESS_INDEX + 1)
+
 #define DMA_READ_CHANS	5
 #define DMA_WRITE_CHANS	3
 
-- 
1.5.5.GIT


