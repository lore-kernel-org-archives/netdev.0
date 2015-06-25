From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 7/9] bnx2x: Fix statistics gathering on link change
Date: Thu, 25 Jun 2015 15:19:27 +0300
Message-ID: <1435234769-5625-8-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51061 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbbFYMUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:14 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <Ariel.Elior@qlogic.com>

Since driver statistics flow access MACs and those might reset during
link re-configurations, when we're about to change link properties we
have to make sure that statistics are not operational.
Statisics would be re-enabled [i.e., gathering of statistics would
re-commence] once physical link is achieved again.

Since driver employs a link-flap avoidance scheme, there are scenarios
where driver will receive no indication that the new link is up, and
as a result the statistics would not be re-enabled.

Preventing LFA from working in such cases would guarantee that we'll
always receive such indications and thus will fix statistics gathering.

Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 733b0fc..caf6b31 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -658,6 +658,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	bp->link_params.multi_phy_config = new_multi_phy_config;
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+		bnx2x_force_link_reset(bp);
 		bnx2x_link_set(bp);
 	}
 
@@ -1969,6 +1970,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+		bnx2x_force_link_reset(bp);
 		bnx2x_link_set(bp);
 	}
 
-- 
1.9.3
