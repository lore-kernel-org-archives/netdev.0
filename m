From: divy@chelsio.com
Subject: [PATCH 2.6.21 3/4] cxgb3 - Tighten xgmac workaround
Date: Sat, 31 Mar 2007 00:23:24 -0700
Message-ID: <20070331072324.4730.2410.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27462 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbXCaHX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 03:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Run the watchdog task when the link is up.
Flush the XGMAC Tx FIFO when the link drops.

Also remove a statistics update that should have gone
in the previous modification of xgmac.c.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   16 +++++++++++++---
 drivers/net/cxgb3/regs.h       |    4 ++++
 drivers/net/cxgb3/xgmac.c      |    1 -
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 145b67c..512daf7 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -185,16 +185,26 @@ void t3_os_link_changed(struct adapter *
 			int speed, int duplex, int pause)
 {
 	struct net_device *dev = adapter->port[port_id];
+	struct port_info *pi = netdev_priv(dev);
+	struct cmac *mac = &pi->mac;
 
 	/* Skip changes from disabled ports. */
 	if (!netif_running(dev))
 		return;
 
 	if (link_stat != netif_carrier_ok(dev)) {
-		if (link_stat)
+		if (link_stat) {
+			t3_set_reg_field(adapter,
+					 A_XGM_TXFIFO_CFG + mac->offset,
+					 F_ENDROPPKT, 0);
 			netif_carrier_on(dev);
-		else
+		} else {
 			netif_carrier_off(dev);
+			t3_set_reg_field(adapter,
+					 A_XGM_TXFIFO_CFG + mac->offset,
+					 F_ENDROPPKT, F_ENDROPPKT);
+		}
+
 		link_report(dev);
 	}
 }
@@ -2119,7 +2129,7 @@ static void check_t3b2_mac(struct adapte
 			continue;
 
 		status = 0;
-		if (netif_running(dev))
+		if (netif_running(dev) && netif_carrier_ok(dev))
 			status = t3b2_mac_watchdog_task(&p->mac);
 		if (status == 1)
 			p->mac.stats.num_toggled++;
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index b38629a..f8be41c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1940,6 +1940,10 @@
 
 #define V_TXFIFOTHRESH(x) ((x) << S_TXFIFOTHRESH)
 
+#define S_ENDROPPKT    21
+#define V_ENDROPPKT(x) ((x) << S_ENDROPPKT)
+#define F_ENDROPPKT    V_ENDROPPKT(1U)
+
 #define A_XGM_SERDES_CTRL 0x890
 #define A_XGM_SERDES_CTRL0 0x8e0
 
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 2b42c13..94aaff0 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -471,7 +471,6 @@ const struct mac_stats *t3_mac_update_st
 	RMON_UPDATE(mac, rx_symbol_errs, RX_SYM_CODE_ERR_FRAMES);
 
 	RMON_UPDATE(mac, rx_too_long, RX_OVERSIZE_FRAMES);
-	mac->stats.rx_too_long += RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 
 	v = RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 	if (mac->adapter->params.rev == T3_REV_B2)
