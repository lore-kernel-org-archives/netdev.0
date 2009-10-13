From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] e1000e: Fix erroneous display of stats by
	ethtool -S
Date: Tue, 13 Oct 2009 17:15:09 +0530
Message-ID: <20091013114454.GA2246@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jef
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:59102 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755345AbZJMLpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 07:45:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fd8235bb overlooked the way offsets for netdev stats were considered.
Because of this some of the stats shown by ethtool -S were wrong.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/e1000e/ethtool.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8a78a14..a70999b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -35,16 +35,22 @@
 
 #include "e1000.h"
 
+enum {NETDEV_STATS, E1000_STATS};
+
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
+	int type;
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
-		      offsetof(struct e1000_adapter, m)
-#define E1000_NETDEV_STAT(m) sizeof(((struct net_device *)0)->m), \
-		      offsetof(struct net_device, m)
+#define E1000_STAT(m)		E1000_STATS, \
+				sizeof(((struct e1000_adapter *)0)->m), \
+		      		offsetof(struct e1000_adapter, m)
+#define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
+				sizeof(((struct net_device *)0)->m), \
+				offsetof(struct net_device, m)
+
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
 	{ "tx_packets", E1000_STAT(stats.gptc) },
@@ -1906,10 +1912,21 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
+	char *p = NULL;
 
 	e1000e_update_stats(adapter);
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
-		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;
+		switch (e1000_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *) netdev +
+					e1000_gstrings_stats[i].stat_offset;
+			break;
+		case E1000_STATS:
+			p = (char *) adapter +
+					e1000_gstrings_stats[i].stat_offset;
+			break;
+		}
+
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-- 
1.6.0.4

