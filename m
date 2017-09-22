From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] e1000: avoid null pointer dereference on invalid stat type
Date: Fri, 22 Sep 2017 14:41:31 +0100
Message-ID: <20170922134131.12283-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently if the stat type is invalid then data[i] is being set
either by dereferencing a null pointer p, or it is reading from
an incorrect previous location if we had a valid stat type
previously.  Fix this by nullify pointer p if a stat type is
invalid and only setting data if p is not null.

Detected by CoverityScan, CID#113385 ("Explicit null dereferenced")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index ec8aa4562cc9..724c93a6ea92 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1824,7 +1824,7 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
-	char *p = NULL;
+	char *p;
 	const struct e1000_stats *stat = e1000_gstrings_stats;
 
 	e1000_update_stats(adapter);
@@ -1837,16 +1837,18 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 			p = (char *)adapter + stat->stat_offset;
 			break;
 		default:
+			p = NULL;
 			WARN_ONCE(1, "Invalid E1000 stat type: %u index %d\n",
 				  stat->type, i);
 			break;
 		}
 
-		if (stat->sizeof_stat == sizeof(u64))
-			data[i] = *(u64 *)p;
-		else
-			data[i] = *(u32 *)p;
-
+		if (p) {
+			if (stat->sizeof_stat == sizeof(u64))
+				data[i] = *(u64 *)p;
+			else
+				data[i] = *(u32 *)p;
+		}
 		stat++;
 	}
 /* BUG_ON(i != E1000_STATS_LEN); */
-- 
2.14.1
