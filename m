From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] qede: Fix statistics' strings for Tx/Rx queues
Date: Sun, 30 Oct 2016 10:25:42 +0200
Message-ID: <1477815942-9486-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:56843 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750951AbcJ3IZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 04:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an interface is configured to use Tx/Rx-only queues,
the length of the statistics would be shortened to accomodate only the
statistics required per-each queue, and the values would be provided
accordingly.
However, the strings provided would still contain both Tx and Rx strings
for each one of the queues [regardless of its configuration], which might
lead to out-of-bound access when filling the buffers as well as incorrect
statistics presented.

Fixes: 9a4d7e86acf3 ("qede: Add support for Tx/Rx-only queues.")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index d230742..8c2bbb2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -177,16 +177,23 @@ static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 	for (i = 0, k = 0; i < QEDE_QUEUE_CNT(edev); i++) {
 		int tc;
 
-		for (j = 0; j < QEDE_NUM_RQSTATS; j++)
-			sprintf(buf + (k + j) * ETH_GSTRING_LEN,
-				"%d:   %s", i, qede_rqstats_arr[j].string);
-		k += QEDE_NUM_RQSTATS;
-		for (tc = 0; tc < edev->num_tc; tc++) {
-			for (j = 0; j < QEDE_NUM_TQSTATS; j++)
+		if (edev->fp_array[i].type & QEDE_FASTPATH_RX) {
+			for (j = 0; j < QEDE_NUM_RQSTATS; j++)
 				sprintf(buf + (k + j) * ETH_GSTRING_LEN,
-					"%d.%d: %s", i, tc,
-					qede_tqstats_arr[j].string);
-			k += QEDE_NUM_TQSTATS;
+					"%d:   %s", i,
+					qede_rqstats_arr[j].string);
+			k += QEDE_NUM_RQSTATS;
+		}
+
+		if (edev->fp_array[i].type & QEDE_FASTPATH_TX) {
+			for (tc = 0; tc < edev->num_tc; tc++) {
+				for (j = 0; j < QEDE_NUM_TQSTATS; j++)
+					sprintf(buf + (k + j) *
+						ETH_GSTRING_LEN,
+						"%d.%d: %s", i, tc,
+						qede_tqstats_arr[j].string);
+				k += QEDE_NUM_TQSTATS;
+			}
 		}
 	}
 
-- 
1.9.3
