From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 7/8] cxgb4: Don't assume FW_PORT_CMD reply is always port info msg
Date: Tue, 26 Apr 2016 20:10:28 +0530
Message-ID: <1461681629-28275-8-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:51037 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752260AbcDZOgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:45 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware can send a set of asynchronous replies through FW_PORT_CMD
with DCBX information when that's negotiated with the Link Peer. The old
code always assumed that a FW_PORT_CMD reply was always a Get Port
Information message. This change conditionalizes the code to only handle
the Get Port Information messages and throws a warning if we don't
understand what we've been given.

Also refactor t4_handle_fw_rpl() so that core functionality performed by
t4_handle_get_port_info() for a specified port.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 110 +++++++++++++++++++----------
 2 files changed, 74 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index f69119bc5990..911fe11d32c6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1470,6 +1470,7 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int eqid);
 int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox);
+void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl);
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
 void t4_db_full(struct adapter *adapter);
 void t4_db_dropped(struct adapter *adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 1ebbbb9323e3..cf3efbf4a37a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7103,52 +7103,88 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 }
 
 /**
- *	t4_handle_fw_rpl - process a FW reply message
- *	@adap: the adapter
+ *	t4_handle_get_port_info - process a FW reply message
+ *	@pi: the port info
  *	@rpl: start of the FW message
  *
- *	Processes a FW message, such as link state change messages.
+ *	Processes a GET_PORT_INFO FW reply message.
+ */
+void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl)
+{
+	const struct fw_port_cmd *p = (const void *)rpl;
+	struct adapter *adap = pi->adapter;
+
+	/* link/module state change message */
+	int speed = 0, fc = 0;
+	struct link_config *lc;
+	u32 stat = be32_to_cpu(p->u.info.lstatus_to_modtype);
+	int link_ok = (stat & FW_PORT_CMD_LSTATUS_F) != 0;
+	u32 mod = FW_PORT_CMD_MODTYPE_G(stat);
+
+	if (stat & FW_PORT_CMD_RXPAUSE_F)
+		fc |= PAUSE_RX;
+	if (stat & FW_PORT_CMD_TXPAUSE_F)
+		fc |= PAUSE_TX;
+	if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
+		speed = 100;
+	else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
+		speed = 1000;
+	else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
+		speed = 10000;
+	else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
+		speed = 40000;
+
+	lc = &pi->link_cfg;
+
+	if (mod != pi->mod_type) {
+		pi->mod_type = mod;
+		t4_os_portmod_changed(adap, pi->port_id);
+	}
+	if (link_ok != lc->link_ok || speed != lc->speed ||
+	    fc != lc->fc) {	/* something changed */
+		lc->link_ok = link_ok;
+		lc->speed = speed;
+		lc->fc = fc;
+		lc->supported = be16_to_cpu(p->u.info.pcap);
+		t4_os_link_changed(adap, pi->port_id, link_ok);
+	}
+}
+
+/**
+ *      t4_handle_fw_rpl - process a FW reply message
+ *      @adap: the adapter
+ *      @rpl: start of the FW message
+ *
+ *      Processes a FW message, such as link state change messages.
  */
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 {
 	u8 opcode = *(const u8 *)rpl;
 
-	if (opcode == FW_PORT_CMD) {    /* link/module state change message */
-		int speed = 0, fc = 0;
-		const struct fw_port_cmd *p = (void *)rpl;
+	/* This might be a port command ... this simplifies the following
+	 * conditionals ...  We can get away with pre-dereferencing
+	 * action_to_len16 because it's in the first 16 bytes and all messages
+	 * will be at least that long.
+	 */
+	const struct fw_port_cmd *p = (const void *)rpl;
+	unsigned int action =
+		FW_PORT_CMD_ACTION_G(be32_to_cpu(p->action_to_len16));
+
+	if (opcode == FW_PORT_CMD && action == FW_PORT_ACTION_GET_PORT_INFO) {
+		int i;
 		int chan = FW_PORT_CMD_PORTID_G(be32_to_cpu(p->op_to_portid));
-		int port = adap->chan_map[chan];
-		struct port_info *pi = adap2pinfo(adap, port);
-		struct link_config *lc = &pi->link_cfg;
-		u32 stat = be32_to_cpu(p->u.info.lstatus_to_modtype);
-		int link_ok = (stat & FW_PORT_CMD_LSTATUS_F) != 0;
-		u32 mod = FW_PORT_CMD_MODTYPE_G(stat);
-
-		if (stat & FW_PORT_CMD_RXPAUSE_F)
-			fc |= PAUSE_RX;
-		if (stat & FW_PORT_CMD_TXPAUSE_F)
-			fc |= PAUSE_TX;
-		if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
-			speed = 100;
-		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
-			speed = 1000;
-		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
-			speed = 10000;
-		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
-			speed = 40000;
-
-		if (link_ok != lc->link_ok || speed != lc->speed ||
-		    fc != lc->fc) {                    /* something changed */
-			lc->link_ok = link_ok;
-			lc->speed = speed;
-			lc->fc = fc;
-			lc->supported = be16_to_cpu(p->u.info.pcap);
-			t4_os_link_changed(adap, port, link_ok);
-		}
-		if (mod != pi->mod_type) {
-			pi->mod_type = mod;
-			t4_os_portmod_changed(adap, port);
+		struct port_info *pi = NULL;
+
+		for_each_port(adap, i) {
+			pi = adap2pinfo(adap, i);
+			if (pi->tx_chan == chan)
+				break;
 		}
+
+		t4_handle_get_port_info(pi, rpl);
+	} else {
+		dev_warn(adap->pdev_dev, "Unknown firmware reply %d\n", opcode);
+		return -EINVAL;
 	}
 	return 0;
 }
-- 
2.3.4
