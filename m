From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/8] cxgb4: Restore L1 cfg, if FW rejects new L1 cfg settings
Date: Wed, 21 Oct 2015 14:39:52 +0530
Message-ID: <1445418597-771-4-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:8012 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754102AbbJUJKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:03 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ethtool set_settings() routine we need to remember our old L1
Configuration in case the firmware rejects the request and then restore
that.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 1487c57..b7b8c46 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -612,6 +612,8 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct port_info *p = netdev_priv(dev);
 	struct link_config *lc = &p->link_cfg;
 	u32 speed = ethtool_cmd_speed(cmd);
+	struct link_config old_lc;
+	int ret;
 
 	if (cmd->duplex != DUPLEX_FULL)     /* only full-duplex supported */
 		return -EINVAL;
@@ -626,6 +628,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 	}
 
+	old_lc = *lc;
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		cap = speed_to_caps(speed);
 
@@ -642,10 +645,14 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 	lc->autoneg = cmd->autoneg;
 
-	if (netif_running(dev))
-		return t4_link_l1cfg(p->adapter, p->adapter->pf, p->tx_chan,
-				     lc);
-	return 0;
+	/* If the firmware rejects the Link Configuration request, back out
+	 * the changes and report the error.
+	 */
+	ret = t4_link_l1cfg(p->adapter, p->adapter->mbox, p->tx_chan, lc);
+	if (ret)
+		*lc = old_lc;
+
+	return ret;
 }
 
 static void get_pauseparam(struct net_device *dev,
-- 
2.3.4
