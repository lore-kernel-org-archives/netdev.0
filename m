From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 8/8] cxgb4: Decode link down reason code obtained from firmware
Date: Tue, 26 Apr 2016 20:10:29 +0530
Message-ID: <1461681629-28275-9-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:29693 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752233AbcDZOgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:43 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h    |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c    | 34 +++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  5 ++++
 3 files changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 911fe11d32c6..6af5242e6d21 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -396,6 +396,7 @@ struct link_config {
 	unsigned char  fc;               /* actual link flow control */
 	unsigned char  autoneg;          /* autonegotiating? */
 	unsigned char  link_ok;          /* link up? */
+	unsigned char  link_down_rc;     /* link down reason */
 };
 
 #define FW_LEN16(fw_struct) FW_CMD_LEN16_V(sizeof(fw_struct) / 16)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cf3efbf4a37a..7907d85efa4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7103,6 +7103,32 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 }
 
 /**
+ *	t4_link_down_rc_str - return a string for a Link Down Reason Code
+ *	@adap: the adapter
+ *	@link_down_rc: Link Down Reason Code
+ *
+ *	Returns a string representation of the Link Down Reason Code.
+ */
+static const char *t4_link_down_rc_str(unsigned char link_down_rc)
+{
+	static const char * const reason[] = {
+		"Link Down",
+		"Remote Fault",
+		"Auto-negotiation Failure",
+		"Reserved",
+		"Insufficient Airflow",
+		"Unable To Determine Reason",
+		"No RX Signal Detected",
+		"Reserved",
+	};
+
+	if (link_down_rc >= ARRAY_SIZE(reason))
+		return "Bad Reason Code";
+
+	return reason[link_down_rc];
+}
+
+/**
  *	t4_handle_get_port_info - process a FW reply message
  *	@pi: the port info
  *	@rpl: start of the FW message
@@ -7142,6 +7168,14 @@ void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl)
 	}
 	if (link_ok != lc->link_ok || speed != lc->speed ||
 	    fc != lc->fc) {	/* something changed */
+		if (!link_ok && lc->link_ok) {
+			unsigned char rc = FW_PORT_CMD_LINKDNRC_G(stat);
+
+			lc->link_down_rc = rc;
+			dev_warn(adap->pdev_dev,
+				 "Port %d link down, reason: %s\n",
+				 pi->port_id, t4_link_down_rc_str(rc));
+		}
 		lc->link_ok = link_ok;
 		lc->speed = speed;
 		lc->fc = fc;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 7ad6d4e75b2a..392d6644fdd8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -2510,6 +2510,11 @@ struct fw_port_cmd {
 #define FW_PORT_CMD_PTYPE_G(x)	\
 	(((x) >> FW_PORT_CMD_PTYPE_S) & FW_PORT_CMD_PTYPE_M)
 
+#define FW_PORT_CMD_LINKDNRC_S		5
+#define FW_PORT_CMD_LINKDNRC_M		0x7
+#define FW_PORT_CMD_LINKDNRC_G(x)	\
+	(((x) >> FW_PORT_CMD_LINKDNRC_S) & FW_PORT_CMD_LINKDNRC_M)
+
 #define FW_PORT_CMD_MODTYPE_S		0
 #define FW_PORT_CMD_MODTYPE_M		0x1f
 #define FW_PORT_CMD_MODTYPE_V(x)	((x) << FW_PORT_CMD_MODTYPE_S)
-- 
2.3.4
