From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/6] cxgb4: Rename t4_link_start() to t4_link_l1cfg
Date: Fri,  5 Jun 2015 14:24:49 +0530
Message-ID: <1433494492-7638-4-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17386 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932216AbbFEDlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:44 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

t4_link_start() was completely misnamed.  It does _not_ start up the
link. It merely does the L1 Configuration for the link. The Link Up
process is started automatically by the firmware when the number of
enabled Virtual Interfaces on a port goes from 0 to 1. So renaming
this routine to t4_link_l1cfg() for better documentation.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 4 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 1043d7a..4ab5a2d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1229,7 +1229,7 @@ void t4_intr_disable(struct adapter *adapter);
 int t4_slow_intr_handler(struct adapter *adapter);
 
 int t4_wait_dev_ready(void __iomem *regs);
-int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
+int t4_link_l1cfg(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc);
 int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 0194c91..687acf7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -646,7 +646,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	lc->autoneg = cmd->autoneg;
 
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, p->adapter->pf, p->tx_chan,
+		return t4_link_l1cfg(p->adapter, p->adapter->pf, p->tx_chan,
 				     lc);
 	return 0;
 }
@@ -679,7 +679,7 @@ static int set_pauseparam(struct net_device *dev,
 	if (epause->tx_pause)
 		lc->requested_fc |= PAUSE_TX;
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, p->adapter->pf, p->tx_chan,
+		return t4_link_l1cfg(p->adapter, p->adapter->pf, p->tx_chan,
 				     lc);
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3ca7e24..4cb7eed 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -481,7 +481,7 @@ static int link_start(struct net_device *dev)
 		}
 	}
 	if (ret == 0)
-		ret = t4_link_start(pi->adapter, mb, pi->tx_chan,
+		ret = t4_link_l1cfg(pi->adapter, mb, pi->tx_chan,
 				    &pi->link_cfg);
 	if (ret == 0) {
 		local_bh_disable();
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index e24f650..6d5b0f4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2579,7 +2579,7 @@ void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
 		     FW_PORT_CAP_ANEG)
 
 /**
- *	t4_link_start - apply link configuration to MAC/PHY
+ *	t4_link_l1cfg - apply link configuration to MAC/PHY
  *	@phy: the PHY to setup
  *	@mac: the MAC to setup
  *	@lc: the requested link configuration
@@ -2591,7 +2591,7 @@ void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
  *	- If auto-negotiation is off set the MAC to the proper speed/duplex/FC,
  *	  otherwise do it later based on the outcome of auto-negotiation.
  */
-int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
+int t4_link_l1cfg(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc)
 {
 	struct fw_port_cmd c;
-- 
2.3.4
