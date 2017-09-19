From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 4/4] qed: iWARP - Add check for errors on a SYN packet
Date: Tue, 19 Sep 2017 20:26:19 +0300
Message-ID: <1505841979-26365-5-git-send-email-Michal.Kalderon@cavium.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0051.outbound.protection.outlook.com ([104.47.34.51]:32800
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751471AbdISR1j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 13:27:39 -0400
In-Reply-To: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A SYN packet which arrives with errors from FW should be dropped.
This required adding an additional field to the ll2
rx completion data.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 8 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   | 1 +
 include/linux/qed/qed_ll2_if.h              | 1 +
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 568e985..8fc9c811 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1733,6 +1733,14 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 
 	memset(&cm_info, 0, sizeof(cm_info));
 	ll2_syn_handle = p_hwfn->p_rdma_info->iwarp.ll2_syn_handle;
+
+	/* Check if packet was received with errors... */
+	if (data->err_flags) {
+		DP_NOTICE(p_hwfn, "Error received on SYN packet: 0x%x\n",
+			  data->err_flags);
+		goto err;
+	}
+
 	if (GET_FIELD(data->parse_flags,
 		      PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED) &&
 	    GET_FIELD(data->parse_flags, PARSING_AND_ERR_FLAGS_L4CHKSMERROR)) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index c06ad4f..250afa5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -413,6 +413,7 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *p_hwfn,
 				  struct qed_ll2_comp_rx_data *data)
 {
 	data->parse_flags = le16_to_cpu(p_cqe->rx_cqe_fp.parse_flags.flags);
+	data->err_flags = le16_to_cpu(p_cqe->rx_cqe_fp.err_flags.flags);
 	data->length.packet_length =
 	    le16_to_cpu(p_cqe->rx_cqe_fp.packet_length);
 	data->vlan = le16_to_cpu(p_cqe->rx_cqe_fp.vlan);
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index dd7a3b8..89fa0bb 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -101,6 +101,7 @@ struct qed_ll2_comp_rx_data {
 	void *cookie;
 	dma_addr_t rx_buf_addr;
 	u16 parse_flags;
+	u16 err_flags;
 	u16 vlan;
 	bool b_last_packet;
 	u8 connection_handle;
-- 
1.8.3.1
