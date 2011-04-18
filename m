From: David Miller <davem@davemloft.net>
Subject: [PATCH 30/42] bna: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:01 -0700 (PDT)
Message-ID: <20110417.173401.27811457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754111Ab1DRAeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2D09024C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'pgoff' is set but unused in bfa_nw_ioc_fwver_get()
and bfa_ioc_download_fw().

Similarly for 'cmd_h' in bna_mbox_flush_q and the entirety of
bna_rit_mod_uninit() is unused since variables are purely set but no
action is made using them.

Same for 'bna' in bna_rit_create() and 'ret' in bna_rx_create().

Just kill them off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bna/bfa_ioc.c  |    6 ++----
 drivers/net/bna/bna_ctrl.c |   21 ---------------------
 drivers/net/bna/bna_txrx.c |    7 ++-----
 3 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index e3de0b8..c1c9e70 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1272,13 +1272,12 @@ bfa_ioc_lpu_stop(struct bfa_ioc *ioc)
 void
 bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 {
-	u32	pgnum, pgoff;
+	u32	pgnum;
 	u32	loff = 0;
 	int		i;
 	u32	*fwsig = (u32 *) fwhdr;
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
-	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
 
 	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr) / sizeof(u32));
@@ -1509,7 +1508,7 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 		    u32 boot_param)
 {
 	u32 *fwimg;
-	u32 pgnum, pgoff;
+	u32 pgnum;
 	u32 loff = 0;
 	u32 chunkno = 0;
 	u32 i;
@@ -1522,7 +1521,6 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	fwimg = bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), chunkno);
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
-	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
 
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
 
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index e152747..53b1416 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -246,7 +246,6 @@ static void
 bna_mbox_flush_q(struct bna *bna, struct list_head *q)
 {
 	struct bna_mbox_qe *mb_qe = NULL;
-	struct bfi_mhdr *cmd_h;
 	struct list_head			*mb_q;
 	void 			(*cbfn)(void *arg, int status);
 	void 			*cbarg;
@@ -260,7 +259,6 @@ bna_mbox_flush_q(struct bna *bna, struct list_head *q)
 		bfa_q_qe_init(mb_qe);
 		bna->mbox_mod.msg_pending--;
 
-		cmd_h = (struct bfi_mhdr *)(&mb_qe->cmd.msg[0]);
 		if (cbfn)
 			cbfn(cbarg, BNA_CB_NOT_EXEC);
 	}
@@ -2774,23 +2772,6 @@ bna_rit_mod_init(struct bna_rit_mod *rit_mod,
 	}
 }
 
-static void
-bna_rit_mod_uninit(struct bna_rit_mod *rit_mod)
-{
-	struct bna_rit_segment *rit_segment;
-	struct list_head *qe;
-	int i;
-	int j;
-
-	for (i = 0; i < BFI_RIT_SEG_TOTAL_POOLS; i++) {
-		j = 0;
-		list_for_each(qe, &rit_mod->rit_seg_pool[i]) {
-			rit_segment = (struct bna_rit_segment *)qe;
-			j++;
-		}
-	}
-}
-
 /*
  * Public functions
  */
@@ -2977,8 +2958,6 @@ bna_uninit(struct bna *bna)
 
 	bna_ucam_mod_uninit(&bna->ucam_mod);
 
-	bna_rit_mod_uninit(&bna->rit_mod);
-
 	bna_ib_mod_uninit(&bna->ib_mod);
 
 	bna_rx_mod_uninit(&bna->rx_mod);
diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/bna/bna_txrx.c
index 58c7664..380085c 100644
--- a/drivers/net/bna/bna_txrx.c
+++ b/drivers/net/bna/bna_txrx.c
@@ -2229,14 +2229,11 @@ void
 bna_rit_create(struct bna_rx *rx)
 {
 	struct list_head	*qe_rxp;
-	struct bna *bna;
 	struct bna_rxp *rxp;
 	struct bna_rxq *q0 = NULL;
 	struct bna_rxq *q1 = NULL;
 	int offset;
 
-	bna = rx->bna;
-
 	offset = 0;
 	list_for_each(qe_rxp, &rx->rxp_q) {
 		rxp = (struct bna_rxp *)qe_rxp;
@@ -2830,7 +2827,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 	struct bna_mem_descr *dsqpt_mem;	/* s/w qpt for data */
 	struct bna_mem_descr *hpage_mem;	/* hdr page mem */
 	struct bna_mem_descr *dpage_mem;	/* data page mem */
-	int i, cpage_idx = 0, dpage_idx = 0, hpage_idx = 0, ret;
+	int i, cpage_idx = 0, dpage_idx = 0, hpage_idx = 0;
 	int dpage_count, hpage_count, rcb_idx;
 	struct bna_ib_config ibcfg;
 	/* Fail if we don't have enough RXPs, RXQs */
@@ -2924,7 +2921,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 		ibcfg.interpkt_timeo = BFI_RX_INTERPKT_TIMEO;
 		ibcfg.ctrl_flags = BFI_IB_CF_INT_ENABLE;
 
-		ret = bna_ib_config(rxp->cq.ib, &ibcfg);
+		bna_ib_config(rxp->cq.ib, &ibcfg);
 
 		/* Link rxqs to rxp */
 		_rxp_add_rxqs(rxp, q0, q1);
-- 
1.7.4.3

