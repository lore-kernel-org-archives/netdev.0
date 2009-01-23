From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 18/21] [next] qlge: Add new firmware event handlers for SFP.
Date: Fri, 23 Jan 2009 07:16:36 -0800
Message-ID: <1232723799-8620-18-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbZAWPSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:05 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add handler for SFP insertion, SFP removal, and
lost event reporting.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   63 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index fd8cdac..e113263 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -90,6 +90,57 @@ static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	ql_link_off(qdev);
 }
 
+static int ql_sfp_in(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 5;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "SFP in AEN broken!\n");
+	else
+		QPRINTK(qdev, DRV, ERR, "SFP insertion detected.\n");
+
+	return status;
+}
+
+static int ql_sfp_out(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 1;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "SFP out AEN broken!\n");
+	else
+		QPRINTK(qdev, DRV, ERR, "SFP removal detected.\n");
+
+	return status;
+}
+
+static int ql_aen_lost(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 6;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "Lost AEN broken!\n");
+	else {
+		int i;
+		QPRINTK(qdev, DRV, ERR, "Lost AEN detected.\n");
+		for (i = 0; i < mbcp->out_count; i++)
+			QPRINTK(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
+					i, mbcp->mbox_out[i]);
+
+	}
+
+	return status;
+}
+
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status;
@@ -147,6 +198,18 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		ql_init_fw_done(qdev, mbcp);
 		break;
 
+	case AEN_AEN_SFP_IN:
+		ql_sfp_in(qdev, mbcp);
+		break;
+
+	case AEN_AEN_SFP_OUT:
+		ql_sfp_out(qdev, mbcp);
+		break;
+
+	case AEN_AEN_LOST:
+		ql_aen_lost(qdev, mbcp);
+		break;
+
 	case AEN_FW_INIT_FAIL:
 	case AEN_SYS_ERR:
 	case MB_CMD_STS_ERR:
-- 
1.6.0.2

