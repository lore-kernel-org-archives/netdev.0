From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 4/5] tg3: Fix race condition in tg3_get_stats64()
Date: Sun, 29 Jul 2012 22:15:44 -0700
Message-ID: <1343625345-5155-4-git-send-email-mchan@broadcom.com>
References: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
 <1343625345-5155-2-git-send-email-mchan@broadcom.com>
 <1343625345-5155-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2425 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028Ab2G3FDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 01:03:49 -0400
In-Reply-To: <1343625345-5155-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spinlock should be taken before checking for tp->hw_stats.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 50045ed..f03614b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12524,10 +12524,12 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (!tp->hw_stats)
+	spin_lock_bh(&tp->lock);
+	if (!tp->hw_stats) {
+		spin_unlock_bh(&tp->lock);
 		return &tp->net_stats_prev;
+	}
 
-	spin_lock_bh(&tp->lock);
 	tg3_get_nstats(tp, stats);
 	spin_unlock_bh(&tp->lock);
 
-- 
1.7.1
