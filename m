From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/8] tg3: Move tg3_set_rx_mode
Date: Mon, 13 Feb 2012 12:20:08 -0800
Message-ID: <1329164412-24566-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1931 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757967Ab2BMUU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:20:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves __tg3_set_rx_mode above its first use and moves
tg3_set_rx_mode down closer to where the netdev_ops functions should be.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  199 +++++++++++++++++------------------
 1 files changed, 99 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7cf39b2..df04a58 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7847,7 +7847,6 @@ static void tg3_set_bdinfo(struct tg3 *tp, u32 bdinfo_addr,
 			      nic_addr);
 }
 
-static void __tg3_set_rx_mode(struct net_device *);
 static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 {
 	int i;
@@ -8084,6 +8083,93 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 		tw32(JMB_REPLENISH_LWM, bdcache_maxcnt);
 }
 
+static inline u32 calc_crc(unsigned char *buf, int len)
+{
+	u32 reg;
+	u32 tmp;
+	int j, k;
+
+	reg = 0xffffffff;
+
+	for (j = 0; j < len; j++) {
+		reg ^= buf[j];
+
+		for (k = 0; k < 8; k++) {
+			tmp = reg & 0x01;
+
+			reg >>= 1;
+
+			if (tmp)
+				reg ^= 0xedb88320;
+		}
+	}
+
+	return ~reg;
+}
+
+static void tg3_set_multi(struct tg3 *tp, unsigned int accept_all)
+{
+	/* accept or reject all multicast frames */
+	tw32(MAC_HASH_REG_0, accept_all ? 0xffffffff : 0);
+	tw32(MAC_HASH_REG_1, accept_all ? 0xffffffff : 0);
+	tw32(MAC_HASH_REG_2, accept_all ? 0xffffffff : 0);
+	tw32(MAC_HASH_REG_3, accept_all ? 0xffffffff : 0);
+}
+
+static void __tg3_set_rx_mode(struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 rx_mode;
+
+	rx_mode = tp->rx_mode & ~(RX_MODE_PROMISC |
+				  RX_MODE_KEEP_VLAN_TAG);
+
+#if !defined(CONFIG_VLAN_8021Q) && !defined(CONFIG_VLAN_8021Q_MODULE)
+	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
+	 * flag clear.
+	 */
+	if (!tg3_flag(tp, ENABLE_ASF))
+		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
+#endif
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Promiscuous mode. */
+		rx_mode |= RX_MODE_PROMISC;
+	} else if (dev->flags & IFF_ALLMULTI) {
+		/* Accept all multicast. */
+		tg3_set_multi(tp, 1);
+	} else if (netdev_mc_empty(dev)) {
+		/* Reject all multicast. */
+		tg3_set_multi(tp, 0);
+	} else {
+		/* Accept one or more multicast(s). */
+		struct netdev_hw_addr *ha;
+		u32 mc_filter[4] = { 0, };
+		u32 regidx;
+		u32 bit;
+		u32 crc;
+
+		netdev_for_each_mc_addr(ha, dev) {
+			crc = calc_crc(ha->addr, ETH_ALEN);
+			bit = ~crc & 0x7f;
+			regidx = (bit & 0x60) >> 5;
+			bit &= 0x1f;
+			mc_filter[regidx] |= (1 << bit);
+		}
+
+		tw32(MAC_HASH_REG_0, mc_filter[0]);
+		tw32(MAC_HASH_REG_1, mc_filter[1]);
+		tw32(MAC_HASH_REG_2, mc_filter[2]);
+		tw32(MAC_HASH_REG_3, mc_filter[3]);
+	}
+
+	if (rx_mode != tp->rx_mode) {
+		tp->rx_mode = rx_mode;
+		tw32_f(MAC_RX_MODE, rx_mode);
+		udelay(10);
+	}
+}
+
 static void tg3_rss_init_dflt_indir_tbl(struct tg3 *tp)
 {
 	int i;
@@ -9967,105 +10053,6 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 	return stats;
 }
 
-static inline u32 calc_crc(unsigned char *buf, int len)
-{
-	u32 reg;
-	u32 tmp;
-	int j, k;
-
-	reg = 0xffffffff;
-
-	for (j = 0; j < len; j++) {
-		reg ^= buf[j];
-
-		for (k = 0; k < 8; k++) {
-			tmp = reg & 0x01;
-
-			reg >>= 1;
-
-			if (tmp)
-				reg ^= 0xedb88320;
-		}
-	}
-
-	return ~reg;
-}
-
-static void tg3_set_multi(struct tg3 *tp, unsigned int accept_all)
-{
-	/* accept or reject all multicast frames */
-	tw32(MAC_HASH_REG_0, accept_all ? 0xffffffff : 0);
-	tw32(MAC_HASH_REG_1, accept_all ? 0xffffffff : 0);
-	tw32(MAC_HASH_REG_2, accept_all ? 0xffffffff : 0);
-	tw32(MAC_HASH_REG_3, accept_all ? 0xffffffff : 0);
-}
-
-static void __tg3_set_rx_mode(struct net_device *dev)
-{
-	struct tg3 *tp = netdev_priv(dev);
-	u32 rx_mode;
-
-	rx_mode = tp->rx_mode & ~(RX_MODE_PROMISC |
-				  RX_MODE_KEEP_VLAN_TAG);
-
-#if !defined(CONFIG_VLAN_8021Q) && !defined(CONFIG_VLAN_8021Q_MODULE)
-	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
-	 * flag clear.
-	 */
-	if (!tg3_flag(tp, ENABLE_ASF))
-		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
-#endif
-
-	if (dev->flags & IFF_PROMISC) {
-		/* Promiscuous mode. */
-		rx_mode |= RX_MODE_PROMISC;
-	} else if (dev->flags & IFF_ALLMULTI) {
-		/* Accept all multicast. */
-		tg3_set_multi(tp, 1);
-	} else if (netdev_mc_empty(dev)) {
-		/* Reject all multicast. */
-		tg3_set_multi(tp, 0);
-	} else {
-		/* Accept one or more multicast(s). */
-		struct netdev_hw_addr *ha;
-		u32 mc_filter[4] = { 0, };
-		u32 regidx;
-		u32 bit;
-		u32 crc;
-
-		netdev_for_each_mc_addr(ha, dev) {
-			crc = calc_crc(ha->addr, ETH_ALEN);
-			bit = ~crc & 0x7f;
-			regidx = (bit & 0x60) >> 5;
-			bit &= 0x1f;
-			mc_filter[regidx] |= (1 << bit);
-		}
-
-		tw32(MAC_HASH_REG_0, mc_filter[0]);
-		tw32(MAC_HASH_REG_1, mc_filter[1]);
-		tw32(MAC_HASH_REG_2, mc_filter[2]);
-		tw32(MAC_HASH_REG_3, mc_filter[3]);
-	}
-
-	if (rx_mode != tp->rx_mode) {
-		tp->rx_mode = rx_mode;
-		tw32_f(MAC_RX_MODE, rx_mode);
-		udelay(10);
-	}
-}
-
-static void tg3_set_rx_mode(struct net_device *dev)
-{
-	struct tg3 *tp = netdev_priv(dev);
-
-	if (!netif_running(dev))
-		return;
-
-	tg3_full_lock(tp, 0);
-	__tg3_set_rx_mode(dev);
-	tg3_full_unlock(tp);
-}
-
 static int tg3_get_regs_len(struct net_device *dev)
 {
 	return TG3_REG_BLK_SIZE;
@@ -11977,6 +11964,18 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
 };
 
+static void tg3_set_rx_mode(struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return;
+
+	tg3_full_lock(tp, 0);
+	__tg3_set_rx_mode(dev);
+	tg3_full_unlock(tp);
+}
+
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 			       int new_mtu)
 {
-- 
1.7.3.4
