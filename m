From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/6] mv643xx_eth: rework interrupt coalescing, and export via ethtool
Date: Fri, 13 Feb 2009 01:07:09 +0100
Message-ID: <20090213000709.GL17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43000 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZBMAHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:07:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
- increases the precision of the receive/transmit interrupt
  coalescing register value computations by using 64bit temporaries;
- adds functions to read the current hardware coalescing register
  values and convert them back to usecs;
- exports the {get,set} {rx,tx} coal methods via the standard
  ethtool coalescing interface.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  133 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 103 insertions(+), 30 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 7a67181..4a92d99 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1221,6 +1221,85 @@ static void mib_counters_timer_wrapper(unsigned long _mp)
 }
 
 
+/* interrupt coalescing *****************************************************/
+/*
+ * Hardware coalescing parameters are set in units of 64 t_clk
+ * cycles.  I.e.:
+ *
+ *	coal_delay_in_usec = 64000000 * register_value / t_clk_rate
+ *
+ *	register_value = coal_delay_in_usec * t_clk_rate / 64000000
+ *
+ * In the ->set*() methods, we round the computed register value
+ * to the nearest integer.
+ */
+static unsigned int get_rx_coal(struct mv643xx_eth_private *mp)
+{
+	u32 val = rdlp(mp, SDMA_CONFIG);
+	u64 temp;
+
+	if (mp->shared->extended_rx_coal_limit)
+		temp = ((val & 0x02000000) >> 10) | ((val & 0x003fff80) >> 7);
+	else
+		temp = (val & 0x003fff00) >> 8;
+
+	temp *= 64000000;
+	do_div(temp, mp->shared->t_clk);
+
+	return (unsigned int)temp;
+}
+
+static void set_rx_coal(struct mv643xx_eth_private *mp, unsigned int usec)
+{
+	u64 temp;
+	u32 val;
+
+	temp = (u64)usec * mp->shared->t_clk;
+	temp += 31999999;
+	do_div(temp, 64000000);
+
+	val = rdlp(mp, SDMA_CONFIG);
+	if (mp->shared->extended_rx_coal_limit) {
+		if (temp > 0xffff)
+			temp = 0xffff;
+		val &= ~0x023fff80;
+		val |= (temp & 0x8000) << 10;
+		val |= (temp & 0x7fff) << 7;
+	} else {
+		if (temp > 0x3fff)
+			temp = 0x3fff;
+		val &= ~0x003fff00;
+		val |= (temp & 0x3fff) << 8;
+	}
+	wrlp(mp, SDMA_CONFIG, val);
+}
+
+static unsigned int get_tx_coal(struct mv643xx_eth_private *mp)
+{
+	u64 temp;
+
+	temp = (rdlp(mp, TX_FIFO_URGENT_THRESHOLD) & 0x3fff0) >> 4;
+	temp *= 64000000;
+	do_div(temp, mp->shared->t_clk);
+
+	return (unsigned int)temp;
+}
+
+static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int usec)
+{
+	u64 temp;
+
+	temp = (u64)usec * mp->shared->t_clk;
+	temp += 31999999;
+	do_div(temp, 64000000);
+
+	if (temp > 0x3fff)
+		temp = 0x3fff;
+
+	wrlp(mp, TX_FIFO_URGENT_THRESHOLD, temp << 4);
+}
+
+
 /* ethtool ******************************************************************/
 struct mv643xx_eth_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -1384,6 +1463,28 @@ static u32 mv643xx_eth_get_link(struct net_device *dev)
 	return !!netif_carrier_ok(dev);
 }
 
+static int
+mv643xx_eth_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	ec->rx_coalesce_usecs = get_rx_coal(mp);
+	ec->tx_coalesce_usecs = get_tx_coal(mp);
+
+	return 0;
+}
+
+static int
+mv643xx_eth_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	set_rx_coal(mp, ec->rx_coalesce_usecs);
+	set_tx_coal(mp, ec->tx_coalesce_usecs);
+
+	return 0;
+}
+
 static void mv643xx_eth_get_strings(struct net_device *dev,
 				    uint32_t stringset, uint8_t *data)
 {
@@ -1438,6 +1539,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
 	.nway_reset		= mv643xx_eth_nway_reset,
 	.get_link		= mv643xx_eth_get_link,
+	.get_coalesce		= mv643xx_eth_get_coalesce,
+	.set_coalesce		= mv643xx_eth_set_coalesce,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
@@ -2053,36 +2156,6 @@ static void port_start(struct mv643xx_eth_private *mp)
 	}
 }
 
-static void set_rx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
-{
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
-	u32 val;
-
-	val = rdlp(mp, SDMA_CONFIG);
-	if (mp->shared->extended_rx_coal_limit) {
-		if (coal > 0xffff)
-			coal = 0xffff;
-		val &= ~0x023fff80;
-		val |= (coal & 0x8000) << 10;
-		val |= (coal & 0x7fff) << 7;
-	} else {
-		if (coal > 0x3fff)
-			coal = 0x3fff;
-		val &= ~0x003fff00;
-		val |= (coal & 0x3fff) << 8;
-	}
-	wrlp(mp, SDMA_CONFIG, val);
-}
-
-static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
-{
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
-
-	if (coal > 0x3fff)
-		coal = 0x3fff;
-	wrlp(mp, TX_FIFO_URGENT_THRESHOLD, (coal & 0x3fff) << 4);
-}
-
 static void mv643xx_eth_recalc_skb_size(struct mv643xx_eth_private *mp)
 {
 	int skb_size;
-- 
1.5.6.4
