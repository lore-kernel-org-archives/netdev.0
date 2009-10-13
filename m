From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] igb: Fix erroneous display of stats by
	ethtool -S
Date: Tue, 13 Oct 2009 17:16:29 +0530
Message-ID: <20091013114617.GA2296@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jef
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:60208 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759554AbZJMLrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 07:47:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 337e067d overlooked the way offsets for netdev stats were considered.
Because of this some of the stats shown by ethtool -S were wrong.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/igb/igb_ethtool.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d46c321..a6da32f 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -37,16 +37,22 @@
 
 #include "igb.h"
 
+enum {NETDEV_STATS, IGB_STATS};
+
 struct igb_stats {
 	char stat_string[ETH_GSTRING_LEN];
+	int type;
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define IGB_STAT(m) FIELD_SIZEOF(struct igb_adapter, m), \
-		      offsetof(struct igb_adapter, m)
-#define IGB_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
-		      offsetof(struct net_device, m)
+#define IGB_STAT(m)		IGB_STATS, \
+				FIELD_SIZEOF(struct igb_adapter, m), \
+				offsetof(struct igb_adapter, m)
+#define IGB_NETDEV_STAT(m)	NETDEV_STATS, \
+				FIELD_SIZEOF(struct net_device, m), \
+				offsetof(struct net_device, m)
+
 static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_packets", IGB_STAT(stats.gprc) },
 	{ "tx_packets", IGB_STAT(stats.gptc) },
@@ -1959,10 +1965,21 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	int stat_count_rx = sizeof(struct igb_rx_queue_stats) / sizeof(u64);
 	int j;
 	int i;
+	char *p = NULL;
 
 	igb_update_stats(adapter);
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
-		char *p = (char *)adapter+igb_gstrings_stats[i].stat_offset;
+		switch (igb_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *) netdev +
+					igb_gstrings_stats[i].stat_offset;
+			break;
+		case IGB_STATS:
+			p = (char *) adapter +
+					igb_gstrings_stats[i].stat_offset;
+			break;
+		}
+
 		data[i] = (igb_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-- 
1.6.0.4

