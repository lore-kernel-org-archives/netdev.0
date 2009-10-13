From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] ixgbe: Fix erroneous display of stats by
	ethtool -S
Date: Tue, 13 Oct 2009 17:17:33 +0530
Message-ID: <20091013114721.GA2671@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jef
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:60971 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759538AbZJMLsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 07:48:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 59aa3cc4 overlooked the way offsets for netdev stats were considered.
Because of this some of the stats shown by ethtool -S were wrong.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 987b41c..08eccf4 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -40,16 +40,22 @@
 
 #define IXGBE_ALL_RAR_ENTRIES 16
 
+enum {NETDEV_STATS, IXGBE_STATS};
+
 struct ixgbe_stats {
 	char stat_string[ETH_GSTRING_LEN];
+	int type;
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define IXGBE_STAT(m) sizeof(((struct ixgbe_adapter *)0)->m), \
-                             offsetof(struct ixgbe_adapter, m)
-#define IXGBE_NETDEV_STAT(m) sizeof(((struct net_device *)0)->m), \
-                             offsetof(struct net_device, m)
+#define IXGBE_STAT(m)		IXGBE_STATS, \
+				sizeof(((struct ixgbe_adapter *)0)->m), \
+				offsetof(struct ixgbe_adapter, m)
+#define IXGBE_NETDEV_STAT(m)	NETDEV_STATS, \
+				sizeof(((struct net_device *)0)->m), \
+				offsetof(struct net_device, m)
+
 static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBE_NETDEV_STAT(stats.rx_packets)},
 	{"tx_packets", IXGBE_NETDEV_STAT(stats.tx_packets)},
@@ -931,10 +937,21 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	int j, k;
 	int i;
+	char *p = NULL;
 
 	ixgbe_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
-		char *p = (char *)adapter + ixgbe_gstrings_stats[i].stat_offset;
+		switch (ixgbe_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *) netdev +
+					ixgbe_gstrings_stats[i].stat_offset;
+			break;
+		case IXGBE_STATS:
+			p = (char *) adapter +
+					ixgbe_gstrings_stats[i].stat_offset;
+			break;
+		}
+
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-- 
1.6.0.4

