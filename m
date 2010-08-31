From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/pch_gbe: Cleanup stats use
Date: Tue, 31 Aug 2010 11:38:35 -0700
Message-ID: <1283279915.1797.66.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com>  <1283271009.1797.28.camel@Joe-Laptop>
	 <1283275514.1797.36.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1119 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548Ab0HaSii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 14:38:38 -0400
In-Reply-To: <1283275514.1797.36.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use c90 initializers
Use memset
Use FIELD_SIZEOF
Remove stat_ from struct pch_gbe_stats members
Save offset from start of struct pch_gbe_hw_stats

All stat members are u64, so maybe the size field can be removed

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pch_gbe/pch_gbe_ethtool.c |   32 +++++++++++++++++---------------
 drivers/net/pch_gbe/pch_gbe_main.c    |   28 +---------------------------
 2 files changed, 18 insertions(+), 42 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
index 25b9357..f61b314 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -31,13 +31,18 @@
  * pch_gbe_stats - Stats item infomation
  */
 struct pch_gbe_stats {
-	signed char stat_string[ETH_GSTRING_LEN];
-	int sizeof_stat;
-	int stat_offset;
+	signed char string[ETH_GSTRING_LEN];
+	size_t size;
+	size_t offset;
 };
-#define PCH_GBE_STAT(m)	{#m,\
-			 sizeof(((struct pch_gbe_adapter *)0)->stats.m),\
-			 offsetof(struct pch_gbe_adapter, stats.m)}
+
+#define PCH_GBE_STAT(m)						\
+{								\
+	.string = #m,						\
+	.size = FIELD_SIZEOF(struct pch_gbe_hw_stats, m),	\
+	.offset = offsetof(struct pch_gbe_hw_stats, m), 	\
+}
+
 /**
  * pch_gbe_gstrings_stats - ethtool information status name list
  */
@@ -545,7 +550,7 @@ static void pch_gbe_get_strings(struct net_device *netdev, u32 stringset,
 	switch (stringset) {
 	case (u32) ETH_SS_STATS:
 		for (i = 0; i < PCH_GBE_GLOBAL_STATS_LEN; i++) {
-			memcpy(p, pch_gbe_gstrings_stats[i].stat_string,
+			memcpy(p, pch_gbe_gstrings_stats[i].string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
@@ -564,16 +569,15 @@ static void pch_gbe_get_ethtool_stats(struct net_device *netdev,
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	int i;
+	const struct pch_gbe_stats *gstats = pch_gbe_gstrings_stats;
+	char *hw_stats = (char *)&adapter->stats;
 
 	FUNC_ENTER();
 	pch_gbe_update_stats(adapter);
 	for (i = 0; i < PCH_GBE_GLOBAL_STATS_LEN; i++) {
-		signed char *p =
-			(signed char *)adapter +
-			pch_gbe_gstrings_stats[i].stat_offset;
-		data[i] =
-			(pch_gbe_gstrings_stats[i].sizeof_stat ==
-			(int)sizeof(u64)) ? *(u64 *) p:(*(u32 *) p);
+		char *p = hw_stats + gstats->offset;
+		data[i] = gstats->size == sizeof(u64) ? *(u64 *)p : *(u32 *)p;
+		gstats++;
 	}
 }
 
@@ -614,5 +618,3 @@ void pch_gbe_set_ethtool_ops(struct net_device *netdev)
 {
 	SET_ETHTOOL_OPS(netdev, &pch_gbe_ethtool_ops);
 }
-
-
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 8195702..c35ad57 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -438,34 +438,8 @@ static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
  */
 static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter)
 {
-	struct pch_gbe_hw_stats *stats = &adapter->stats;
-
 	FUNC_ENTER();
-	stats->rx_packets = 0;
-	stats->tx_packets = 0;
-	stats->rx_bytes = 0;
-	stats->tx_bytes = 0;
-	stats->rx_errors = 0;
-	stats->tx_errors = 0;
-	stats->rx_dropped = 0;
-	stats->tx_dropped = 0;
-	stats->multicast = 0;
-	stats->collisions = 0;
-	stats->rx_crc_errors = 0;
-	stats->rx_frame_errors = 0;
-	stats->rx_alloc_buff_failed = 0;
-	stats->tx_length_errors = 0;
-	stats->tx_aborted_errors = 0;
-	stats->tx_carrier_errors = 0;
-	stats->tx_timeout_count = 0;
-	stats->tx_restart_count = 0;
-	stats->intr_rx_dsc_empty_count = 0;
-	stats->intr_rx_frame_err_count = 0;
-	stats->intr_rx_fifo_err_count = 0;
-	stats->intr_rx_dma_err_count = 0;
-	stats->intr_tx_fifo_err_count = 0;
-	stats->intr_tx_dma_err_count = 0;
-	stats->intr_tcpip_err_count = 0;
+	memset(&adapter->stats, 0, sizeof(adapter->stats));
 	return;
 }
 


