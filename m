From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/6] cxgb4: Add sge ec context flush service
Date: Fri,  5 Jun 2015 14:24:48 +0530
Message-ID: <1433494492-7638-3-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26260 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932123AbbFEDlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:42 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function to flush the sge ec context cache, and utilize
this new function in the driver

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  5 +----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 26 +++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  6 +++++-
 4 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 93e6cbc..1043d7a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1410,6 +1410,7 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int eqid);
 int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int eqid);
+int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox);
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
 void t4_db_full(struct adapter *adapter);
 void t4_db_dropped(struct adapter *adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e6abdb7..3ca7e24 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2007,11 +2007,8 @@ EXPORT_SYMBOL(cxgb4_iscsi_init);
 int cxgb4_flush_eq_cache(struct net_device *dev)
 {
 	struct adapter *adap = netdev2adap(dev);
-	int ret;
 
-	ret = t4_fwaddrspace_write(adap, adap->mbox,
-				   0xe1000000 + SGE_CTXT_CMD_A, 0x20000000);
-	return ret;
+	return t4_sge_ctxt_flush(adap, adap->mbox);
 }
 EXPORT_SYMBOL(cxgb4_flush_eq_cache);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 3a56254..e24f650 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4530,6 +4530,32 @@ void t4_sge_decode_idma_state(struct adapter *adapter, int state)
 }
 
 /**
+ *      t4_sge_ctxt_flush - flush the SGE context cache
+ *      @adap: the adapter
+ *      @mbox: mailbox to use for the FW command
+ *
+ *      Issues a FW command through the given mailbox to flush the
+ *      SGE context cache.
+ */
+int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox)
+{
+	int ret;
+	u32 ldst_addrspace;
+	struct fw_ldst_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	ldst_addrspace = FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_SGE_EGRC);
+	c.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+					FW_CMD_REQUEST_F | FW_CMD_READ_F |
+					ldst_addrspace);
+	c.cycles_to_len16 = cpu_to_be32(FW_LEN16(c));
+	c.u.idctxt.msg_ctxtflush = cpu_to_be32(FW_LDST_CMD_CTXTFLUSH_F);
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	return ret;
+}
+
+/**
  *      t4_fw_hello - establish communication with FW
  *      @adap: the adapter
  *      @mbox: mailbox to use for the FW command
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index aceb1e8..ab46746 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -772,7 +772,7 @@ struct fw_ldst_cmd {
 		} addrval;
 		struct fw_ldst_idctxt {
 			__be32 physid;
-			__be32 msg_pkd;
+			__be32 msg_ctxtflush;
 			__be32 ctxt_data7;
 			__be32 ctxt_data6;
 			__be32 ctxt_data5;
@@ -834,6 +834,10 @@ struct fw_ldst_cmd {
 #define FW_LDST_CMD_MSG_S       31
 #define FW_LDST_CMD_MSG_V(x)	((x) << FW_LDST_CMD_MSG_S)
 
+#define FW_LDST_CMD_CTXTFLUSH_S		30
+#define FW_LDST_CMD_CTXTFLUSH_V(x)	((x) << FW_LDST_CMD_CTXTFLUSH_S)
+#define FW_LDST_CMD_CTXTFLUSH_F		FW_LDST_CMD_CTXTFLUSH_V(1U)
+
 #define FW_LDST_CMD_PADDR_S     8
 #define FW_LDST_CMD_PADDR_V(x)	((x) << FW_LDST_CMD_PADDR_S)
 
-- 
2.3.4
