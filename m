From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] e1000: Fix erroneous display of stats by
	ethtool -S
Date: Tue, 13 Oct 2009 17:15:48 +0530
Message-ID: <20091013114536.GA2276@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jef
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:59682 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759481AbZJMLqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 07:46:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 23d26497 overlooked the way offsets for netdev stats were considered.
Because of this some of the stats shown by ethtool -S were wrong.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/e1000/e1000_ethtool.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index e25b339..ffbae0a 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -31,16 +31,22 @@
 #include "e1000.h"
 #include <asm/uaccess.h>
 
+enum {NETDEV_STATS, E1000_STATS};
+
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
+	int type;
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define E1000_STAT(m) FIELD_SIZEOF(struct e1000_adapter, m), \
-		      offsetof(struct e1000_adapter, m)
-#define E1000_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
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
@@ -1832,10 +1838,21 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
+	char *p = NULL;
 
 	e1000_update_stats(adapter);
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

