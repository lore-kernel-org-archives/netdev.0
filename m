From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH NEXT 1/6] netxen_nic: fix cdrp race condition
Date: Fri, 3 Feb 2012 13:35:10 -0800
Message-ID: <1328304915-12858-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:23418
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757990Ab2BCVvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:51:21 -0500
In-Reply-To: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Reading CRB registers(if reqd) before releasing the api lock.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   12 ++
 .../net/ethernet/qlogic/netxen/netxen_nic_ctx.c    |  149 ++++++++++----------
 2 files changed, 89 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index a876dff..1b09ba1 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -686,6 +686,18 @@ struct netxen_recv_context {
 	dma_addr_t phys_addr;
 };
 
+struct _cdrp_cmd {
+	u32 cmd;
+	u32 arg1;
+	u32 arg2;
+	u32 arg3;
+};
+
+struct netxen_cmd_args {
+	struct _cdrp_cmd req;
+	struct _cdrp_cmd rsp;
+};
+
 /* New HW context creation */
 
 #define NX_OS_CRB_RETRY_COUNT	4000
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index a925392..d46e8cb 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -48,28 +48,27 @@ netxen_poll_rsp(struct netxen_adapter *adapter)
 }
 
 static u32
-netxen_issue_cmd(struct netxen_adapter *adapter,
-	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd)
+netxen_issue_cmd(struct netxen_adapter *adapter, struct netxen_cmd_args *cmd)
 {
 	u32 rsp;
 	u32 signature = 0;
 	u32 rcode = NX_RCODE_SUCCESS;
 
-	signature = NX_CDRP_SIGNATURE_MAKE(pci_fn, version);
-
+	signature = NX_CDRP_SIGNATURE_MAKE(adapter->ahw.pci_func,
+						NXHAL_VERSION);
 	/* Acquire semaphore before accessing CRB */
 	if (netxen_api_lock(adapter))
 		return NX_RCODE_TIMEOUT;
 
 	NXWR32(adapter, NX_SIGN_CRB_OFFSET, signature);
 
-	NXWR32(adapter, NX_ARG1_CRB_OFFSET, arg1);
+	NXWR32(adapter, NX_ARG1_CRB_OFFSET, cmd->req.arg1);
 
-	NXWR32(adapter, NX_ARG2_CRB_OFFSET, arg2);
+	NXWR32(adapter, NX_ARG2_CRB_OFFSET, cmd->req.arg2);
 
-	NXWR32(adapter, NX_ARG3_CRB_OFFSET, arg3);
+	NXWR32(adapter, NX_ARG3_CRB_OFFSET, cmd->req.arg3);
 
-	NXWR32(adapter, NX_CDRP_CRB_OFFSET, NX_CDRP_FORM_CMD(cmd));
+	NXWR32(adapter, NX_CDRP_CRB_OFFSET, NX_CDRP_FORM_CMD(cmd->req.cmd));
 
 	rsp = netxen_poll_rsp(adapter);
 
@@ -83,8 +82,15 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 
 		printk(KERN_ERR "%s: failed card response code:0x%x\n",
 				netxen_nic_driver_name, rcode);
+	} else if (rsp == NX_CDRP_RSP_OK) {
+		if (cmd->rsp.arg2)
+			cmd->rsp.arg2 = NXRD32(adapter, NX_ARG2_CRB_OFFSET);
+		if (cmd->rsp.arg3)
+			cmd->rsp.arg3 = NXRD32(adapter, NX_ARG3_CRB_OFFSET);
 	}
 
+	if (cmd->rsp.arg1)
+		cmd->rsp.arg1 = NXRD32(adapter, NX_ARG1_CRB_OFFSET);
 	/* Release semaphore */
 	netxen_api_unlock(adapter);
 
@@ -96,15 +102,16 @@ nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu)
 {
 	u32 rcode = NX_RCODE_SUCCESS;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct netxen_cmd_args cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.cmd = NX_CDRP_CMD_SET_MTU;
+	cmd.req.arg1 = recv_ctx->context_id;
+	cmd.req.arg2 = mtu;
+	cmd.req.arg3 = 0;
 
 	if (recv_ctx->state == NX_HOST_CTX_STATE_ACTIVE)
-		rcode = netxen_issue_cmd(adapter,
-				adapter->ahw.pci_func,
-				NXHAL_VERSION,
-				recv_ctx->context_id,
-				mtu,
-				0,
-				NX_CDRP_CMD_SET_MTU);
+		netxen_issue_cmd(adapter, &cmd);
 
 	if (rcode != NX_RCODE_SUCCESS)
 		return -EIO;
@@ -116,15 +123,14 @@ int
 nx_fw_cmd_set_gbe_port(struct netxen_adapter *adapter,
 			u32 speed, u32 duplex, u32 autoneg)
 {
-
-	return netxen_issue_cmd(adapter,
-				adapter->ahw.pci_func,
-				NXHAL_VERSION,
-				speed,
-				duplex,
-				autoneg,
-				NX_CDRP_CMD_CONFIG_GBE_PORT);
-
+	struct netxen_cmd_args cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.cmd = NX_CDRP_CMD_CONFIG_GBE_PORT;
+	cmd.req.arg1 = speed;
+	cmd.req.arg2 = duplex;
+	cmd.req.arg3 = autoneg;
+	return netxen_issue_cmd(adapter, &cmd);
 }
 
 static int
@@ -139,6 +145,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	nx_cardrsp_sds_ring_t *prsp_sds;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
+	struct netxen_cmd_args cmd;
 
 	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
 	u64 phys_addr;
@@ -218,13 +225,12 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	}
 
 	phys_addr = hostrq_phys_addr;
-	err = netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			(u32)(phys_addr >> 32),
-			(u32)(phys_addr & 0xffffffff),
-			rq_size,
-			NX_CDRP_CMD_CREATE_RX_CTX);
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = (u32)(phys_addr >> 32);
+	cmd.req.arg2 = (u32)(phys_addr & 0xffffffff);
+	cmd.req.arg3 = rq_size;
+	cmd.req.cmd = NX_CDRP_CMD_CREATE_RX_CTX;
+	err = netxen_issue_cmd(adapter, &cmd);
 	if (err) {
 		printk(KERN_WARNING
 			"Failed to create rx ctx in firmware%d\n", err);
@@ -273,15 +279,15 @@ static void
 nx_fw_cmd_destroy_rx_ctx(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct netxen_cmd_args cmd;
 
-	if (netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			recv_ctx->context_id,
-			NX_DESTROY_CTX_RESET,
-			0,
-			NX_CDRP_CMD_DESTROY_RX_CTX)) {
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = recv_ctx->context_id;
+	cmd.req.arg2 = NX_DESTROY_CTX_RESET;
+	cmd.req.arg3 = 0;
+	cmd.req.cmd = NX_CDRP_CMD_DESTROY_RX_CTX;
 
+	if (netxen_issue_cmd(adapter, &cmd)) {
 		printk(KERN_WARNING
 			"%s: Failed to destroy rx ctx in firmware\n",
 			netxen_nic_driver_name);
@@ -302,6 +308,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct netxen_cmd_args cmd;
 
 	rq_size = SIZEOF_HOSTRQ_TX(nx_hostrq_tx_ctx_t);
 	rq_addr = pci_alloc_consistent(adapter->pdev,
@@ -345,13 +352,12 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	phys_addr = rq_phys_addr;
-	err = netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			(u32)(phys_addr >> 32),
-			((u32)phys_addr & 0xffffffff),
-			rq_size,
-			NX_CDRP_CMD_CREATE_TX_CTX);
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = (u32)(phys_addr >> 32);
+	cmd.req.arg2 = ((u32)phys_addr & 0xffffffff);
+	cmd.req.arg3 = rq_size;
+	cmd.req.cmd = NX_CDRP_CMD_CREATE_TX_CTX;
+	err = netxen_issue_cmd(adapter, &cmd);
 
 	if (err == NX_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
@@ -380,14 +386,14 @@ out_free_rq:
 static void
 nx_fw_cmd_destroy_tx_ctx(struct netxen_adapter *adapter)
 {
-	if (netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			adapter->tx_context_id,
-			NX_DESTROY_CTX_RESET,
-			0,
-			NX_CDRP_CMD_DESTROY_TX_CTX)) {
-
+	struct netxen_cmd_args cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = adapter->tx_context_id;
+	cmd.req.arg2 = NX_DESTROY_CTX_RESET;
+	cmd.req.arg3 = 0;
+	cmd.req.cmd = NX_CDRP_CMD_DESTROY_TX_CTX;
+	if (netxen_issue_cmd(adapter, &cmd)) {
 		printk(KERN_WARNING
 			"%s: Failed to destroy tx ctx in firmware\n",
 			netxen_nic_driver_name);
@@ -398,34 +404,33 @@ int
 nx_fw_cmd_query_phy(struct netxen_adapter *adapter, u32 reg, u32 *val)
 {
 	u32 rcode;
-
-	rcode = netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			reg,
-			0,
-			0,
-			NX_CDRP_CMD_READ_PHY);
-
+	struct netxen_cmd_args cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = reg;
+	cmd.req.arg2 = 0;
+	cmd.req.arg3 = 0;
+	cmd.req.cmd = NX_CDRP_CMD_READ_PHY;
+	cmd.rsp.arg1 = 1;
+	rcode = netxen_issue_cmd(adapter, &cmd);
 	if (rcode != NX_RCODE_SUCCESS)
 		return -EIO;
 
-	return NXRD32(adapter, NX_ARG1_CRB_OFFSET);
+	return cmd.rsp.arg1;
 }
 
 int
 nx_fw_cmd_set_phy(struct netxen_adapter *adapter, u32 reg, u32 val)
 {
 	u32 rcode;
-
-	rcode = netxen_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			NXHAL_VERSION,
-			reg,
-			val,
-			0,
-			NX_CDRP_CMD_WRITE_PHY);
-
+	struct netxen_cmd_args cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.req.arg1 = reg;
+	cmd.req.arg2 = val;
+	cmd.req.arg3 = 0;
+	cmd.req.cmd = NX_CDRP_CMD_WRITE_PHY;
+	rcode = netxen_issue_cmd(adapter, &cmd);
 	if (rcode != NX_RCODE_SUCCESS)
 		return -EIO;
 
-- 
1.7.3.3
