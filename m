From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4vf: Add 40G support for cxgb4vf driver
Date: Thu,  9 Oct 2014 05:48:46 +0530
Message-ID: <1412813927-24951-3-git-send-email-hariprasad@chelsio.com>
References: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59660
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755212AbaJIAOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:14:35 -0400
In-Reply-To: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 40G support for cxgb4vf driver. ethtool speed values are just numbers of
megabits and there is no SPEED_40000 in ethtool speed values. To be consistent,
use integer constants directly for all speeds.

Use is_x_10g_port()("is 10Gb/s or higher") in cfg_queues() instead of
is_10g_port() ("is exactly 10Gb/s"). Else we will end up using a single
"Queue Set" on 40Gb/s adapters.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   12 ++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    6 ++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   10 +++++++---
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 8498a64..bfa398d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -163,15 +163,19 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 		netif_carrier_on(dev);
 
 		switch (pi->link_cfg.speed) {
-		case SPEED_10000:
+		case 40000:
+			s = "40Gbps";
+			break;
+
+		case 10000:
 			s = "10Gbps";
 			break;
 
-		case SPEED_1000:
+		case 1000:
 			s = "1000Mbps";
 			break;
 
-		case SPEED_100:
+		case 100:
 			s = "100Mbps";
 			break;
 
@@ -2351,7 +2355,7 @@ static void cfg_queues(struct adapter *adapter)
 		struct port_info *pi = adap2pinfo(adapter, pidx);
 
 		pi->first_qset = qidx;
-		pi->nqsets = is_10g_port(&pi->link_cfg) ? q10g : 1;
+		pi->nqsets = is_x_10g_port(&pi->link_cfg) ? q10g : 1;
 		qidx += pi->nqsets;
 	}
 	s->ethqsets = qidx;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index f412d0f..95df61d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -228,6 +228,12 @@ static inline bool is_10g_port(const struct link_config *lc)
 	return (lc->supported & SUPPORTED_10000baseT_Full) != 0;
 }
 
+static inline bool is_x_10g_port(const struct link_config *lc)
+{
+	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0 ||
+		(lc->supported & FW_PORT_CAP_SPEED_40G) != 0;
+}
+
 static inline unsigned int core_ticks_per_usec(const struct adapter *adapter)
 {
 	return adapter->params.vpd.cclk / 1000;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 25dfeb8..e984fdc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -327,6 +327,8 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 		v |= SUPPORTED_1000baseT_Full;
 	if (word & FW_PORT_CAP_SPEED_10G)
 		v |= SUPPORTED_10000baseT_Full;
+	if (word & FW_PORT_CAP_SPEED_40G)
+		v |= SUPPORTED_40000baseSR4_Full;
 	if (word & FW_PORT_CAP_ANEG)
 		v |= SUPPORTED_Autoneg;
 	init_link_config(&pi->link_cfg, v);
@@ -1352,11 +1354,13 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		if (word & FW_PORT_CMD_TXPAUSE)
 			fc |= PAUSE_TX;
 		if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
-			speed = SPEED_100;
+			speed = 100;
 		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
-			speed = SPEED_1000;
+			speed = 1000;
 		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
-			speed = SPEED_10000;
+			speed = 10000;
+		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_40G))
+			speed = 40000;
 
 		/*
 		 * Scan all of our "ports" (Virtual Interfaces) looking for
-- 
1.7.1
