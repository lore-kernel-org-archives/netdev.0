From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] ixgb: Fix erroneous display of stats by
	ethtool -S
Date: Tue, 13 Oct 2009 17:16:56 +0530
Message-ID: <20091013114645.GA2453@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jef
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:60548 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759545AbZJMLrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 07:47:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5675f221 overlooked the way offsets for netdev stats were considered.
Because of this some of the stats shown by ethtool -S were wrong.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/ixgb/ixgb_ethtool.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index deeb25d..a4ed96c 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -34,16 +34,22 @@
 
 #define IXGB_ALL_RAR_ENTRIES 16
 
+enum {NETDEV_STATS, IXGB_STATS};
+
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
+	int type;
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define IXGB_STAT(m) FIELD_SIZEOF(struct ixgb_adapter, m), \
-		      offsetof(struct ixgb_adapter, m)
-#define IXGB_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
-		      offsetof(struct net_device, m)
+#define IXGB_STAT(m)		IXGB_STATS, \
+				FIELD_SIZEOF(struct ixgb_adapter, m), \
+				offsetof(struct ixgb_adapter, m)
+#define IXGB_NETDEV_STAT(m)	NETDEV_STATS, \
+				FIELD_SIZEOF(struct net_device, m), \
+				offsetof(struct net_device, m)
+
 static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"rx_packets", IXGB_NETDEV_STAT(stats.rx_packets)},
 	{"tx_packets", IXGB_NETDEV_STAT(stats.tx_packets)},
@@ -664,10 +670,21 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	int i;
+	char *p = NULL;
 
 	ixgb_update_stats(adapter);
 	for (i = 0; i < IXGB_STATS_LEN; i++) {
-		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;
+		switch (ixgb_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *) netdev +
+					ixgb_gstrings_stats[i].stat_offset;
+			break;
+		case IXGB_STATS:
+			p = (char *) adapter +
+					ixgb_gstrings_stats[i].stat_offset;
+			break;
+		}
+
 		data[i] = (ixgb_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-- 
1.6.0.4

