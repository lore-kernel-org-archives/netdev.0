From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 26/45] bna: Ethfn LPU DMA Read Fix
Date: Mon, 18 Jul 2011 01:22:46 -0700
Message-ID: <1310977385-5268-16-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37805 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753670Ab1GRIYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:18 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - In new HW, LPU cannot perform DMA read from host memory for PFs with
   Ethernet functionality. As a result, BFI_ENET command processing (which
   uses the msgq implementation and relies on LPU doing DMA read from host
   memoty) will not work
 - To fix this, msgq sends mailbox message to Host to request data from a
   specified memory area, Host copies the data from specifies memory area
   to mailbox and notifies the LPU, LPU upon receiving all fragments of
   data, continues processing Enet commands
 - Host processes LPU mailbox read status interrupt and schedules mailbox
   poll routine. Host implements handler for BFI_MSGQ_I2H_CMDQ_COPY_REQ
   message and uses BFI_MSGQ_H2I_CMDQ_COPY_RSP message to send data to LPU.
   Msgq module in FW implements mailbox based cmdq read routine

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   30 ++++++++++++++++++------------
 drivers/net/bna/bfa_ioc.h |    5 +++++
 2 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 216d0d1..beb63f9 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -2058,22 +2058,28 @@ bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc)
 	struct bfi_mbmsg m;
 	int				mc;
 
-	if (!bfa_ioc_msgget(ioc, &m))
-		return;
+	if (bfa_ioc_msgget(ioc, &m)) {
+		/**
+		 * Treat IOC message class as special.
+		 */
+		mc = m.mh.msg_class;
+		if (mc == BFI_MC_IOC) {
+			bfa_ioc_isr(ioc, &m);
+			return;
+		}
 
-	/**
-	 * Treat IOC message class as special.
-	 */
-	mc = m.mh.msg_class;
-	if (mc == BFI_MC_IOC) {
-		bfa_ioc_isr(ioc, &m);
-		return;
+		if ((mc >= BFI_MC_MAX) || (mod->mbhdlr[mc].cbfn == NULL))
+			return;
+
+		mod->mbhdlr[mc].cbfn(mod->mbhdlr[mc].cbarg, &m);
 	}
 
-	if ((mc >= BFI_MC_MAX) || (mod->mbhdlr[mc].cbfn == NULL))
-		return;
+	bfa_ioc_lpu_read_stat(ioc);
 
-	mod->mbhdlr[mc].cbfn(mod->mbhdlr[mc].cbarg, &m);
+	/**
+	 * Try to send pending mailbox commands
+	 */
+	bfa_ioc_mbox_poll(ioc);
 }
 
 void
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 07e1a9d..a9f24e2 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -281,6 +281,11 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 #define	bfa_ioc_ownership_reset(__ioc)				\
 			((__ioc)->ioc_hwif->ioc_ownership_reset(__ioc))
 
+#define bfa_ioc_lpu_read_stat(__ioc) do {				\
+		if ((__ioc)->ioc_hwif->ioc_lpu_read_stat)		\
+			((__ioc)->ioc_hwif->ioc_lpu_read_stat(__ioc));	\
+} while (0)
+
 void bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc);
 void bfa_nw_ioc_set_ct2_hwif(struct bfa_ioc *ioc);
 
-- 
1.7.1

