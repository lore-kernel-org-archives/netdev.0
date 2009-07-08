From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/8 net-next-2.6] cxgb3: Drain Mac Tx fifo when the port goes
	down.
Date: Tue, 07 Jul 2009 22:48:32 -0700
Message-ID: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20968 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbZGHFsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Drain the MAC TX fifos when a port goes down.
Back pressure might otherwise occur, leading to both
ports of the same adapter to hang.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 538dda4..ef59921 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -172,6 +172,23 @@ static void link_report(struct net_device *dev)
 	}
 }
 
+static void enable_tx_fifo_drain(struct adapter *adapter,
+				 struct port_info *pi)
+{
+	t3_set_reg_field(adapter, A_XGM_TXFIFO_CFG + pi->mac.offset, 0,
+			 F_ENDROPPKT);
+	t3_write_reg(adapter, A_XGM_RX_CTRL + pi->mac.offset, 0);
+	t3_write_reg(adapter, A_XGM_TX_CTRL + pi->mac.offset, F_TXEN);
+	t3_write_reg(adapter, A_XGM_RX_CTRL + pi->mac.offset, F_RXEN);
+}
+
+static void disable_tx_fifo_drain(struct adapter *adapter,
+				  struct port_info *pi)
+{
+	t3_set_reg_field(adapter, A_XGM_TXFIFO_CFG + pi->mac.offset,
+			 F_ENDROPPKT, 0);
+}
+
 void t3_os_link_fault(struct adapter *adap, int port_id, int state)
 {
 	struct net_device *dev = adap->port[port_id];
@@ -185,6 +202,8 @@ void t3_os_link_fault(struct adapter *adap, int port_id, int state)
 
 		netif_carrier_on(dev);
 
+		disable_tx_fifo_drain(adap, pi);
+
 		/* Clear local faults */
 		t3_xgm_intr_disable(adap, pi->port_id);
 		t3_read_reg(adap, A_XGM_INT_STATUS +
@@ -200,9 +219,12 @@ void t3_os_link_fault(struct adapter *adap, int port_id, int state)
 		t3_xgm_intr_enable(adap, pi->port_id);
 
 		t3_mac_enable(mac, MAC_DIRECTION_TX);
-	} else
+	} else {
 		netif_carrier_off(dev);
 
+		/* Flush TX FIFO */
+		enable_tx_fifo_drain(adap, pi);
+	}
 	link_report(dev);
 }
 
@@ -232,6 +254,8 @@ void t3_os_link_changed(struct adapter *adapter, int port_id, int link_stat,
 
 	if (link_stat != netif_carrier_ok(dev)) {
 		if (link_stat) {
+			disable_tx_fifo_drain(adapter, pi);
+
 			t3_mac_enable(mac, MAC_DIRECTION_RX);
 
 			/* Clear local faults */
@@ -263,6 +287,9 @@ void t3_os_link_changed(struct adapter *adapter, int port_id, int link_stat,
 			t3_read_reg(adapter, A_XGM_INT_STATUS + pi->mac.offset);
 			t3_mac_disable(mac, MAC_DIRECTION_RX);
 			t3_link_start(&pi->phy, mac, &pi->link_config);
+
+			/* Flush TX FIFO */
+			enable_tx_fifo_drain(adapter, pi);
 		}
 
 		link_report(dev);

