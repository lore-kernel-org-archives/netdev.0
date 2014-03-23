From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] bnx2x: Don't show port statistics for VFs
Date: Sun, 23 Mar 2014 18:12:26 +0200
Message-ID: <1395591147-26350-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:25904 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752448AbaCWQNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 12:13:51 -0400
In-Reply-To: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VFs are currently showing port statistics, although they can't really access
those - thus all such statistics will always show a value of 0.

This patch removes said statistics from the VF's view as to not confuse the
user.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 38fc794..b6de05e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2969,8 +2969,9 @@ static void bnx2x_self_test(struct net_device *dev,
 #define IS_PORT_STAT(i) \
 	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
 #define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
-#define IS_MF_MODE_STAT(bp) \
-			(IS_MF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS))
+#define HIDE_PORT_STAT(bp) \
+		((IS_MF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS)) || \
+		 IS_VF(bp))
 
 /* ethtool statistics are displayed for all regular ethernet queues and the
  * fcoe L2 queue if not disabled
@@ -2992,7 +2993,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 				      BNX2X_NUM_Q_STATS;
 		} else
 			num_strings = 0;
-		if (IS_MF_MODE_STAT(bp)) {
+		if (HIDE_PORT_STAT(bp)) {
 			for (i = 0; i < BNX2X_NUM_STATS; i++)
 				if (IS_FUNC_STAT(i))
 					num_strings++;
@@ -3047,7 +3048,7 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 		}
 
 		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-			if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
+			if (HIDE_PORT_STAT(bp) && IS_PORT_STAT(i))
 				continue;
 			strcpy(buf + (k + j)*ETH_GSTRING_LEN,
 				   bnx2x_stats_arr[i].string);
@@ -3105,7 +3106,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 
 	hw_stats = (u32 *)&bp->eth_stats;
 	for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-		if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
+		if (HIDE_PORT_STAT(bp) && IS_PORT_STAT(i))
 			continue;
 		if (bnx2x_stats_arr[i].size == 0) {
 			/* skip this counter */
-- 
1.8.1.227.g44fe835
