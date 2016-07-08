From: Varun Prakash <varun@chelsio.com>
Subject: [net-next 2/6] cxgb3i,cxgb4i,libcxgbi: remove iSCSI DDP support
Date: Fri,  8 Jul 2016 23:03:55 +0530
Message-ID: <73c3770a7b69e10c80b3f3a690c5819f735b1a28.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:46080 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755950AbcGHRgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 13:36:36 -0400
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old ddp code from cxgb3i,cxgb4i,libcxgbi.

Next two commits adds DDP support using
common iSCSI DDP Page Pod Manager.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c | 128 --------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 142 ---------
 drivers/scsi/cxgbi/libcxgbi.c      | 578 -------------------------------------
 drivers/scsi/cxgbi/libcxgbi.h      | 161 -----------
 4 files changed, 1009 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index e22a268..fda0234 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -1076,65 +1076,6 @@ static inline void ulp_mem_io_set_hdr(struct sk_buff *skb, unsigned int addr)
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_BYPASS));
 	req->cmd_lock_addr = htonl(V_ULP_MEMIO_ADDR(addr >> 5) |
 				   V_ULPTX_CMD(ULP_MEM_WRITE));
-	req->len = htonl(V_ULP_MEMIO_DATA_LEN(PPOD_SIZE >> 5) |
-			 V_ULPTX_NFLITS((PPOD_SIZE >> 3) + 1));
-}
-
-static int ddp_set_map(struct cxgbi_sock *csk, struct cxgbi_pagepod_hdr *hdr,
-			unsigned int idx, unsigned int npods,
-				struct cxgbi_gather_list *gl)
-{
-	struct cxgbi_device *cdev = csk->cdev;
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ddp->llimit;
-	int i;
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"csk 0x%p, idx %u, npods %u, gl 0x%p.\n",
-		csk, idx, npods, gl);
-
-	for (i = 0; i < npods; i++, idx++, pm_addr += PPOD_SIZE) {
-		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
-						PPOD_SIZE, 0, GFP_ATOMIC);
-
-		if (!skb)
-			return -ENOMEM;
-
-		ulp_mem_io_set_hdr(skb, pm_addr);
-		cxgbi_ddp_ppod_set((struct cxgbi_pagepod *)(skb->head +
-					sizeof(struct ulp_mem_io)),
-				   hdr, gl, i * PPOD_PAGES_MAX);
-		skb->priority = CPL_PRIORITY_CONTROL;
-		cxgb3_ofld_send(cdev->lldev, skb);
-	}
-	return 0;
-}
-
-static void ddp_clear_map(struct cxgbi_hba *chba, unsigned int tag,
-			  unsigned int idx, unsigned int npods)
-{
-	struct cxgbi_device *cdev = chba->cdev;
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ddp->llimit;
-	int i;
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"cdev 0x%p, idx %u, npods %u, tag 0x%x.\n",
-		cdev, idx, npods, tag);
-
-	for (i = 0; i < npods; i++, idx++, pm_addr += PPOD_SIZE) {
-		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
-						PPOD_SIZE, 0, GFP_ATOMIC);
-
-		if (!skb) {
-			pr_err("tag 0x%x, 0x%x, %d/%u, skb OOM.\n",
-				tag, idx, i, npods);
-			continue;
-		}
-		ulp_mem_io_set_hdr(skb, pm_addr);
-		skb->priority = CPL_PRIORITY_CONTROL;
-		cxgb3_ofld_send(cdev->lldev, skb);
-	}
 }
 
 static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
@@ -1203,82 +1144,14 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 }
 
 /**
- * t3_ddp_cleanup - release the cxgb3 adapter's ddp resource
- * @cdev: cxgb3i adapter
- * release all the resource held by the ddp pagepod manager for a given
- * adapter if needed
- */
-
-static void t3_ddp_cleanup(struct cxgbi_device *cdev)
-{
-	struct t3cdev *tdev = (struct t3cdev *)cdev->lldev;
-
-	if (cxgbi_ddp_cleanup(cdev)) {
-		pr_info("t3dev 0x%p, ulp_iscsi no more user.\n", tdev);
-		tdev->ulp_iscsi = NULL;
-	}
-}
-
-/**
  * ddp_init - initialize the cxgb3 adapter's ddp resource
  * @cdev: cxgb3i adapter
  * initialize the ddp pagepod manager for a given adapter
  */
 static int cxgb3i_ddp_init(struct cxgbi_device *cdev)
 {
-	struct t3cdev *tdev = (struct t3cdev *)cdev->lldev;
-	struct cxgbi_ddp_info *ddp = tdev->ulp_iscsi;
-	struct ulp_iscsi_info uinfo;
-	unsigned int pgsz_factor[4];
-	int i, err;
-
-	if (ddp) {
-		kref_get(&ddp->refcnt);
-		pr_warn("t3dev 0x%p, ddp 0x%p already set up.\n",
-			tdev, tdev->ulp_iscsi);
-		cdev->ddp = ddp;
-		return -EALREADY;
-	}
-
-	err = tdev->ctl(tdev, ULP_ISCSI_GET_PARAMS, &uinfo);
-	if (err < 0) {
-		pr_err("%s, failed to get iscsi param err=%d.\n",
-			 tdev->name, err);
-		return err;
-	}
-
-	err = cxgbi_ddp_init(cdev, uinfo.llimit, uinfo.ulimit,
-			uinfo.max_txsz, uinfo.max_rxsz);
-	if (err < 0)
-		return err;
-
-	ddp = cdev->ddp;
-
-	uinfo.tagmask = ddp->idx_mask << PPOD_IDX_SHIFT;
-	cxgbi_ddp_page_size_factor(pgsz_factor);
-	for (i = 0; i < 4; i++)
-		uinfo.pgsz_factor[i] = pgsz_factor[i];
-	uinfo.ulimit = uinfo.llimit + (ddp->nppods << PPOD_SIZE_SHIFT);
-
-	err = tdev->ctl(tdev, ULP_ISCSI_SET_PARAMS, &uinfo);
-	if (err < 0) {
-		pr_warn("%s unable to set iscsi param err=%d, ddp disabled.\n",
-			tdev->name, err);
-		cxgbi_ddp_cleanup(cdev);
-		return err;
-	}
-	tdev->ulp_iscsi = ddp;
-
 	cdev->csk_ddp_setup_digest = ddp_setup_conn_digest;
 	cdev->csk_ddp_setup_pgidx = ddp_setup_conn_pgidx;
-	cdev->csk_ddp_set = ddp_set_map;
-	cdev->csk_ddp_clear = ddp_clear_map;
-
-	pr_info("tdev 0x%p, nppods %u, bits %u, mask 0x%x,0x%x pkt %u/%u, "
-		"%u/%u.\n",
-		tdev, ddp->nppods, ddp->idx_bits, ddp->idx_mask,
-		ddp->rsvd_tag_mask, ddp->max_txsz, uinfo.max_txsz,
-		ddp->max_rxsz, uinfo.max_rxsz);
 	return 0;
 }
 
@@ -1325,7 +1198,6 @@ static void cxgb3i_dev_open(struct t3cdev *t3dev)
 	cdev->rx_credit_thres = cxgb3i_rx_credit_thres;
 	cdev->skb_tx_rsvd = CXGB3I_TX_HEADER_LEN;
 	cdev->skb_rx_extra = sizeof(struct cpl_iscsi_hdr_norss);
-	cdev->dev_ddp_cleanup = t3_ddp_cleanup;
 	cdev->itp = &cxgb3i_iscsi_transport;
 
 	err = cxgb3i_ddp_init(cdev);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 339f6b7..2911214 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1543,110 +1543,6 @@ int cxgb4i_ofld_init(struct cxgbi_device *cdev)
 	return 0;
 }
 
-/*
- * functions to program the pagepod in h/w
- */
-#define ULPMEM_IDATA_MAX_NPPODS	4 /* 256/PPOD_SIZE */
-static inline void ulp_mem_io_set_hdr(struct cxgb4_lld_info *lldi,
-				struct ulp_mem_io *req,
-				unsigned int wr_len, unsigned int dlen,
-				unsigned int pm_addr)
-{
-	struct ulptx_idata *idata = (struct ulptx_idata *)(req + 1);
-
-	INIT_ULPTX_WR(req, wr_len, 0, 0);
-	if (is_t4(lldi->adapter_type))
-		req->cmd = htonl(ULPTX_CMD_V(ULP_TX_MEM_WRITE) |
-					(ULP_MEMIO_ORDER_F));
-	else
-		req->cmd = htonl(ULPTX_CMD_V(ULP_TX_MEM_WRITE) |
-					(T5_ULP_MEMIO_IMM_F));
-	req->dlen = htonl(ULP_MEMIO_DATA_LEN_V(dlen >> 5));
-	req->lock_addr = htonl(ULP_MEMIO_ADDR_V(pm_addr >> 5));
-	req->len16 = htonl(DIV_ROUND_UP(wr_len - sizeof(req->wr), 16));
-
-	idata->cmd_more = htonl(ULPTX_CMD_V(ULP_TX_SC_IMM));
-	idata->len = htonl(dlen);
-}
-
-static int ddp_ppod_write_idata(struct cxgbi_device *cdev, unsigned int port_id,
-				struct cxgbi_pagepod_hdr *hdr, unsigned int idx,
-				unsigned int npods,
-				struct cxgbi_gather_list *gl,
-				unsigned int gl_pidx)
-{
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
-	struct sk_buff *skb;
-	struct ulp_mem_io *req;
-	struct ulptx_idata *idata;
-	struct cxgbi_pagepod *ppod;
-	unsigned int pm_addr = idx * PPOD_SIZE + ddp->llimit;
-	unsigned int dlen = PPOD_SIZE * npods;
-	unsigned int wr_len = roundup(sizeof(struct ulp_mem_io) +
-				sizeof(struct ulptx_idata) + dlen, 16);
-	unsigned int i;
-
-	skb = alloc_wr(wr_len, 0, GFP_ATOMIC);
-	if (!skb) {
-		pr_err("cdev 0x%p, idx %u, npods %u, OOM.\n",
-			cdev, idx, npods);
-		return -ENOMEM;
-	}
-	req = (struct ulp_mem_io *)skb->head;
-	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
-
-	ulp_mem_io_set_hdr(lldi, req, wr_len, dlen, pm_addr);
-	idata = (struct ulptx_idata *)(req + 1);
-	ppod = (struct cxgbi_pagepod *)(idata + 1);
-
-	for (i = 0; i < npods; i++, ppod++, gl_pidx += PPOD_PAGES_MAX) {
-		if (!hdr && !gl)
-			cxgbi_ddp_ppod_clear(ppod);
-		else
-			cxgbi_ddp_ppod_set(ppod, hdr, gl, gl_pidx);
-	}
-
-	cxgb4_ofld_send(cdev->ports[port_id], skb);
-	return 0;
-}
-
-static int ddp_set_map(struct cxgbi_sock *csk, struct cxgbi_pagepod_hdr *hdr,
-			unsigned int idx, unsigned int npods,
-			struct cxgbi_gather_list *gl)
-{
-	unsigned int i, cnt;
-	int err = 0;
-
-	for (i = 0; i < npods; i += cnt, idx += cnt) {
-		cnt = npods - i;
-		if (cnt > ULPMEM_IDATA_MAX_NPPODS)
-			cnt = ULPMEM_IDATA_MAX_NPPODS;
-		err = ddp_ppod_write_idata(csk->cdev, csk->port_id, hdr,
-					idx, cnt, gl, 4 * i);
-		if (err < 0)
-			break;
-	}
-	return err;
-}
-
-static void ddp_clear_map(struct cxgbi_hba *chba, unsigned int tag,
-			  unsigned int idx, unsigned int npods)
-{
-	unsigned int i, cnt;
-	int err;
-
-	for (i = 0; i < npods; i += cnt, idx += cnt) {
-		cnt = npods - i;
-		if (cnt > ULPMEM_IDATA_MAX_NPPODS)
-			cnt = ULPMEM_IDATA_MAX_NPPODS;
-		err = ddp_ppod_write_idata(chba->cdev, chba->port_id, NULL,
-					idx, cnt, NULL, 0);
-		if (err < 0)
-			break;
-	}
-}
-
 static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk, unsigned int tid,
 				int pg_idx, bool reply)
 {
@@ -1712,46 +1608,8 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 
 static int cxgb4i_ddp_init(struct cxgbi_device *cdev)
 {
-	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	unsigned int tagmask, pgsz_factor[4];
-	int err;
-
-	if (ddp) {
-		kref_get(&ddp->refcnt);
-		pr_warn("cdev 0x%p, ddp 0x%p already set up.\n",
-			cdev, cdev->ddp);
-		return -EALREADY;
-	}
-
-	err = cxgbi_ddp_init(cdev, lldi->vr->iscsi.start,
-			lldi->vr->iscsi.start + lldi->vr->iscsi.size - 1,
-			lldi->iscsi_iolen, lldi->iscsi_iolen);
-	if (err < 0)
-		return err;
-
-	ddp = cdev->ddp;
-
-	tagmask = ddp->idx_mask << PPOD_IDX_SHIFT;
-	cxgbi_ddp_page_size_factor(pgsz_factor);
-	cxgb4_iscsi_init(lldi->ports[0], tagmask, pgsz_factor);
-
 	cdev->csk_ddp_setup_digest = ddp_setup_conn_digest;
 	cdev->csk_ddp_setup_pgidx = ddp_setup_conn_pgidx;
-	cdev->csk_ddp_set = ddp_set_map;
-	cdev->csk_ddp_clear = ddp_clear_map;
-
-	pr_info("cxgb4i 0x%p tag: sw %u, rsvd %u,%u, mask 0x%x.\n",
-		cdev, cdev->tag_format.sw_bits, cdev->tag_format.rsvd_bits,
-		cdev->tag_format.rsvd_shift, cdev->tag_format.rsvd_mask);
-	pr_info("cxgb4i 0x%p, nppods %u, bits %u, mask 0x%x,0x%x pkt %u/%u, "
-		" %u/%u.\n",
-		cdev, ddp->nppods, ddp->idx_bits, ddp->idx_mask,
-		ddp->rsvd_tag_mask, ddp->max_txsz, lldi->iscsi_iolen,
-		ddp->max_rxsz, lldi->iscsi_iolen);
-	pr_info("cxgb4i 0x%p max payload size: %u/%u, %u/%u.\n",
-		cdev, cdev->tx_max_size, ddp->max_txsz, cdev->rx_max_size,
-		ddp->max_rxsz);
 	return 0;
 }
 
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index ead83a2..f389d34 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -113,12 +113,6 @@ static inline void cxgbi_device_destroy(struct cxgbi_device *cdev)
 		"cdev 0x%p, p# %u.\n", cdev, cdev->nports);
 	cxgbi_hbas_remove(cdev);
 	cxgbi_device_portmap_cleanup(cdev);
-	if (cdev->dev_ddp_cleanup)
-		cdev->dev_ddp_cleanup(cdev);
-	else
-		cxgbi_ddp_cleanup(cdev);
-	if (cdev->ddp)
-		cxgbi_ddp_cleanup(cdev);
 	if (cdev->pmap.max_connect)
 		cxgbi_free_big_mem(cdev->pmap.port_csk);
 	kfree(cdev);
@@ -1183,504 +1177,6 @@ out_err:
 }
 
 /*
- * Direct Data Placement -
- * Directly place the iSCSI Data-In or Data-Out PDU's payload into pre-posted
- * final destination host-memory buffers based on the Initiator Task Tag (ITT)
- * in Data-In or Target Task Tag (TTT) in Data-Out PDUs.
- * The host memory address is programmed into h/w in the format of pagepod
- * entries.
- * The location of the pagepod entry is encoded into ddp tag which is used as
- * the base for ITT/TTT.
- */
-
-static unsigned char ddp_page_order[DDP_PGIDX_MAX] = {0, 1, 2, 4};
-static unsigned char ddp_page_shift[DDP_PGIDX_MAX] = {12, 13, 14, 16};
-static unsigned char page_idx = DDP_PGIDX_MAX;
-
-static unsigned char sw_tag_idx_bits;
-static unsigned char sw_tag_age_bits;
-
-/*
- * Direct-Data Placement page size adjustment
- */
-static int ddp_adjust_page_table(void)
-{
-	int i;
-	unsigned int base_order, order;
-
-	if (PAGE_SIZE < (1UL << ddp_page_shift[0])) {
-		pr_info("PAGE_SIZE 0x%lx too small, min 0x%lx\n",
-			PAGE_SIZE, 1UL << ddp_page_shift[0]);
-		return -EINVAL;
-	}
-
-	base_order = get_order(1UL << ddp_page_shift[0]);
-	order = get_order(1UL << PAGE_SHIFT);
-
-	for (i = 0; i < DDP_PGIDX_MAX; i++) {
-		/* first is the kernel page size, then just doubling */
-		ddp_page_order[i] = order - base_order + i;
-		ddp_page_shift[i] = PAGE_SHIFT + i;
-	}
-	return 0;
-}
-
-static int ddp_find_page_index(unsigned long pgsz)
-{
-	int i;
-
-	for (i = 0; i < DDP_PGIDX_MAX; i++) {
-		if (pgsz == (1UL << ddp_page_shift[i]))
-			return i;
-	}
-	pr_info("ddp page size %lu not supported.\n", pgsz);
-	return DDP_PGIDX_MAX;
-}
-
-static void ddp_setup_host_page_size(void)
-{
-	if (page_idx == DDP_PGIDX_MAX) {
-		page_idx = ddp_find_page_index(PAGE_SIZE);
-
-		if (page_idx == DDP_PGIDX_MAX) {
-			pr_info("system PAGE %lu, update hw.\n", PAGE_SIZE);
-			if (ddp_adjust_page_table() < 0) {
-				pr_info("PAGE %lu, disable ddp.\n", PAGE_SIZE);
-				return;
-			}
-			page_idx = ddp_find_page_index(PAGE_SIZE);
-		}
-		pr_info("system PAGE %lu, ddp idx %u.\n", PAGE_SIZE, page_idx);
-	}
-}
-
-void cxgbi_ddp_page_size_factor(int *pgsz_factor)
-{
-	int i;
-
-	for (i = 0; i < DDP_PGIDX_MAX; i++)
-		pgsz_factor[i] = ddp_page_order[i];
-}
-EXPORT_SYMBOL_GPL(cxgbi_ddp_page_size_factor);
-
-/*
- * DDP setup & teardown
- */
-
-void cxgbi_ddp_ppod_set(struct cxgbi_pagepod *ppod,
-			struct cxgbi_pagepod_hdr *hdr,
-			struct cxgbi_gather_list *gl, unsigned int gidx)
-{
-	int i;
-
-	memcpy(ppod, hdr, sizeof(*hdr));
-	for (i = 0; i < (PPOD_PAGES_MAX + 1); i++, gidx++) {
-		ppod->addr[i] = gidx < gl->nelem ?
-				cpu_to_be64(gl->phys_addr[gidx]) : 0ULL;
-	}
-}
-EXPORT_SYMBOL_GPL(cxgbi_ddp_ppod_set);
-
-void cxgbi_ddp_ppod_clear(struct cxgbi_pagepod *ppod)
-{
-	memset(ppod, 0, sizeof(*ppod));
-}
-EXPORT_SYMBOL_GPL(cxgbi_ddp_ppod_clear);
-
-static inline int ddp_find_unused_entries(struct cxgbi_ddp_info *ddp,
-					unsigned int start, unsigned int max,
-					unsigned int count,
-					struct cxgbi_gather_list *gl)
-{
-	unsigned int i, j, k;
-
-	/*  not enough entries */
-	if ((max - start) < count) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"NOT enough entries %u+%u < %u.\n", start, count, max);
-		return -EBUSY;
-	}
-
-	max -= count;
-	spin_lock(&ddp->map_lock);
-	for (i = start; i < max;) {
-		for (j = 0, k = i; j < count; j++, k++) {
-			if (ddp->gl_map[k])
-				break;
-		}
-		if (j == count) {
-			for (j = 0, k = i; j < count; j++, k++)
-				ddp->gl_map[k] = gl;
-			spin_unlock(&ddp->map_lock);
-			return i;
-		}
-		i += j + 1;
-	}
-	spin_unlock(&ddp->map_lock);
-	log_debug(1 << CXGBI_DBG_DDP,
-		"NO suitable entries %u available.\n", count);
-	return -EBUSY;
-}
-
-static inline void ddp_unmark_entries(struct cxgbi_ddp_info *ddp,
-						int start, int count)
-{
-	spin_lock(&ddp->map_lock);
-	memset(&ddp->gl_map[start], 0,
-		count * sizeof(struct cxgbi_gather_list *));
-	spin_unlock(&ddp->map_lock);
-}
-
-static inline void ddp_gl_unmap(struct pci_dev *pdev,
-					struct cxgbi_gather_list *gl)
-{
-	int i;
-
-	for (i = 0; i < gl->nelem; i++)
-		dma_unmap_page(&pdev->dev, gl->phys_addr[i], PAGE_SIZE,
-				PCI_DMA_FROMDEVICE);
-}
-
-static inline int ddp_gl_map(struct pci_dev *pdev,
-				    struct cxgbi_gather_list *gl)
-{
-	int i;
-
-	for (i = 0; i < gl->nelem; i++) {
-		gl->phys_addr[i] = dma_map_page(&pdev->dev, gl->pages[i], 0,
-						PAGE_SIZE,
-						PCI_DMA_FROMDEVICE);
-		if (unlikely(dma_mapping_error(&pdev->dev, gl->phys_addr[i]))) {
-			log_debug(1 << CXGBI_DBG_DDP,
-				"page %d 0x%p, 0x%p dma mapping err.\n",
-				i, gl->pages[i], pdev);
-			goto unmap;
-		}
-	}
-	return i;
-unmap:
-	if (i) {
-		unsigned int nelem = gl->nelem;
-
-		gl->nelem = i;
-		ddp_gl_unmap(pdev, gl);
-		gl->nelem = nelem;
-	}
-	return -EINVAL;
-}
-
-static void ddp_release_gl(struct cxgbi_gather_list *gl,
-				  struct pci_dev *pdev)
-{
-	ddp_gl_unmap(pdev, gl);
-	kfree(gl);
-}
-
-static struct cxgbi_gather_list *ddp_make_gl(unsigned int xferlen,
-						    struct scatterlist *sgl,
-						    unsigned int sgcnt,
-						    struct pci_dev *pdev,
-						    gfp_t gfp)
-{
-	struct cxgbi_gather_list *gl;
-	struct scatterlist *sg = sgl;
-	struct page *sgpage = sg_page(sg);
-	unsigned int sglen = sg->length;
-	unsigned int sgoffset = sg->offset;
-	unsigned int npages = (xferlen + sgoffset + PAGE_SIZE - 1) >>
-				PAGE_SHIFT;
-	int i = 1, j = 0;
-
-	if (xferlen < DDP_THRESHOLD) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"xfer %u < threshold %u, no ddp.\n",
-			xferlen, DDP_THRESHOLD);
-		return NULL;
-	}
-
-	gl = kzalloc(sizeof(struct cxgbi_gather_list) +
-		     npages * (sizeof(dma_addr_t) +
-		     sizeof(struct page *)), gfp);
-	if (!gl) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"xfer %u, %u pages, OOM.\n", xferlen, npages);
-		return NULL;
-	}
-
-	 log_debug(1 << CXGBI_DBG_DDP,
-		"xfer %u, sgl %u, gl max %u.\n", xferlen, sgcnt, npages);
-
-	gl->pages = (struct page **)&gl->phys_addr[npages];
-	gl->nelem = npages;
-	gl->length = xferlen;
-	gl->offset = sgoffset;
-	gl->pages[0] = sgpage;
-
-	for (i = 1, sg = sg_next(sgl), j = 0; i < sgcnt;
-		i++, sg = sg_next(sg)) {
-		struct page *page = sg_page(sg);
-
-		if (sgpage == page && sg->offset == sgoffset + sglen)
-			sglen += sg->length;
-		else {
-			/*  make sure the sgl is fit for ddp:
-			 *  each has the same page size, and
-			 *  all of the middle pages are used completely
-			 */
-			if ((j && sgoffset) || ((i != sgcnt - 1) &&
-			    ((sglen + sgoffset) & ~PAGE_MASK))) {
-				log_debug(1 << CXGBI_DBG_DDP,
-					"page %d/%u, %u + %u.\n",
-					i, sgcnt, sgoffset, sglen);
-				goto error_out;
-			}
-
-			j++;
-			if (j == gl->nelem || sg->offset) {
-				log_debug(1 << CXGBI_DBG_DDP,
-					"page %d/%u, offset %u.\n",
-					j, gl->nelem, sg->offset);
-				goto error_out;
-			}
-			gl->pages[j] = page;
-			sglen = sg->length;
-			sgoffset = sg->offset;
-			sgpage = page;
-		}
-	}
-	gl->nelem = ++j;
-
-	if (ddp_gl_map(pdev, gl) < 0)
-		goto error_out;
-
-	return gl;
-
-error_out:
-	kfree(gl);
-	return NULL;
-}
-
-static void ddp_tag_release(struct cxgbi_hba *chba, u32 tag)
-{
-	struct cxgbi_device *cdev = chba->cdev;
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	u32 idx;
-
-	idx = (tag >> PPOD_IDX_SHIFT) & ddp->idx_mask;
-	if (idx < ddp->nppods) {
-		struct cxgbi_gather_list *gl = ddp->gl_map[idx];
-		unsigned int npods;
-
-		if (!gl || !gl->nelem) {
-			pr_warn("tag 0x%x, idx %u, gl 0x%p, %u.\n",
-				tag, idx, gl, gl ? gl->nelem : 0);
-			return;
-		}
-		npods = (gl->nelem + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
-		log_debug(1 << CXGBI_DBG_DDP,
-			"tag 0x%x, release idx %u, npods %u.\n",
-			tag, idx, npods);
-		cdev->csk_ddp_clear(chba, tag, idx, npods);
-		ddp_unmark_entries(ddp, idx, npods);
-		ddp_release_gl(gl, ddp->pdev);
-	} else
-		pr_warn("tag 0x%x, idx %u > max %u.\n", tag, idx, ddp->nppods);
-}
-
-static int ddp_tag_reserve(struct cxgbi_sock *csk, unsigned int tid,
-			   u32 sw_tag, u32 *tagp, struct cxgbi_gather_list *gl,
-			   gfp_t gfp)
-{
-	struct cxgbi_device *cdev = csk->cdev;
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	struct cxgbi_tag_format *tformat = &cdev->tag_format;
-	struct cxgbi_pagepod_hdr hdr;
-	unsigned int npods;
-	int idx = -1;
-	int err = -ENOMEM;
-	u32 tag;
-
-	npods = (gl->nelem + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
-	if (ddp->idx_last == ddp->nppods)
-		idx = ddp_find_unused_entries(ddp, 0, ddp->nppods,
-							npods, gl);
-	else {
-		idx = ddp_find_unused_entries(ddp, ddp->idx_last + 1,
-							ddp->nppods, npods,
-							gl);
-		if (idx < 0 && ddp->idx_last >= npods) {
-			idx = ddp_find_unused_entries(ddp, 0,
-				min(ddp->idx_last + npods, ddp->nppods),
-							npods, gl);
-		}
-	}
-	if (idx < 0) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"xferlen %u, gl %u, npods %u NO DDP.\n",
-			gl->length, gl->nelem, npods);
-		return idx;
-	}
-
-	tag = cxgbi_ddp_tag_base(tformat, sw_tag);
-	tag |= idx << PPOD_IDX_SHIFT;
-
-	hdr.rsvd = 0;
-	hdr.vld_tid = htonl(PPOD_VALID_FLAG | PPOD_TID(tid));
-	hdr.pgsz_tag_clr = htonl(tag & ddp->rsvd_tag_mask);
-	hdr.max_offset = htonl(gl->length);
-	hdr.page_offset = htonl(gl->offset);
-
-	err = cdev->csk_ddp_set(csk, &hdr, idx, npods, gl);
-	if (err < 0)
-		goto unmark_entries;
-
-	ddp->idx_last = idx;
-	log_debug(1 << CXGBI_DBG_DDP,
-		"xfer %u, gl %u,%u, tid 0x%x, tag 0x%x->0x%x(%u,%u).\n",
-		gl->length, gl->nelem, gl->offset, tid, sw_tag, tag, idx,
-		npods);
-	*tagp = tag;
-	return 0;
-
-unmark_entries:
-	ddp_unmark_entries(ddp, idx, npods);
-	return err;
-}
-
-int cxgbi_ddp_reserve(struct cxgbi_sock *csk, unsigned int *tagp,
-			unsigned int sw_tag, unsigned int xferlen,
-			struct scatterlist *sgl, unsigned int sgcnt, gfp_t gfp)
-{
-	struct cxgbi_device *cdev = csk->cdev;
-	struct cxgbi_tag_format *tformat = &cdev->tag_format;
-	struct cxgbi_gather_list *gl;
-	int err;
-
-	if (page_idx >= DDP_PGIDX_MAX || !cdev->ddp ||
-	    xferlen < DDP_THRESHOLD) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"pgidx %u, xfer %u, NO ddp.\n", page_idx, xferlen);
-		return -EINVAL;
-	}
-
-	if (!cxgbi_sw_tag_usable(tformat, sw_tag)) {
-		log_debug(1 << CXGBI_DBG_DDP,
-			"sw_tag 0x%x NOT usable.\n", sw_tag);
-		return -EINVAL;
-	}
-
-	gl = ddp_make_gl(xferlen, sgl, sgcnt, cdev->pdev, gfp);
-	if (!gl)
-		return -ENOMEM;
-
-	err = ddp_tag_reserve(csk, csk->tid, sw_tag, tagp, gl, gfp);
-	if (err < 0)
-		ddp_release_gl(gl, cdev->pdev);
-
-	return err;
-}
-
-static void ddp_destroy(struct kref *kref)
-{
-	struct cxgbi_ddp_info *ddp = container_of(kref,
-						struct cxgbi_ddp_info,
-						refcnt);
-	struct cxgbi_device *cdev = ddp->cdev;
-	int i = 0;
-
-	pr_info("kref 0, destroy ddp 0x%p, cdev 0x%p.\n", ddp, cdev);
-
-	while (i < ddp->nppods) {
-		struct cxgbi_gather_list *gl = ddp->gl_map[i];
-
-		if (gl) {
-			int npods = (gl->nelem + PPOD_PAGES_MAX - 1)
-					>> PPOD_PAGES_SHIFT;
-			pr_info("cdev 0x%p, ddp %d + %d.\n", cdev, i, npods);
-			kfree(gl);
-			i += npods;
-		} else
-			i++;
-	}
-	cxgbi_free_big_mem(ddp);
-}
-
-int cxgbi_ddp_cleanup(struct cxgbi_device *cdev)
-{
-	struct cxgbi_ddp_info *ddp = cdev->ddp;
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"cdev 0x%p, release ddp 0x%p.\n", cdev, ddp);
-	cdev->ddp = NULL;
-	if (ddp)
-		return kref_put(&ddp->refcnt, ddp_destroy);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(cxgbi_ddp_cleanup);
-
-int cxgbi_ddp_init(struct cxgbi_device *cdev,
-		   unsigned int llimit, unsigned int ulimit,
-		   unsigned int max_txsz, unsigned int max_rxsz)
-{
-	struct cxgbi_ddp_info *ddp;
-	unsigned int ppmax, bits;
-
-	ppmax = (ulimit - llimit + 1) >> PPOD_SIZE_SHIFT;
-	bits = __ilog2_u32(ppmax) + 1;
-	if (bits > PPOD_IDX_MAX_SIZE)
-		bits = PPOD_IDX_MAX_SIZE;
-	ppmax = (1 << (bits - 1)) - 1;
-
-	ddp = cxgbi_alloc_big_mem(sizeof(struct cxgbi_ddp_info) +
-				ppmax * (sizeof(struct cxgbi_gather_list *) +
-					 sizeof(struct sk_buff *)),
-				GFP_KERNEL);
-	if (!ddp) {
-		pr_warn("cdev 0x%p, ddp ppmax %u OOM.\n", cdev, ppmax);
-		return -ENOMEM;
-	}
-	ddp->gl_map = (struct cxgbi_gather_list **)(ddp + 1);
-	cdev->ddp = ddp;
-
-	spin_lock_init(&ddp->map_lock);
-	kref_init(&ddp->refcnt);
-
-	ddp->cdev = cdev;
-	ddp->pdev = cdev->pdev;
-	ddp->llimit = llimit;
-	ddp->ulimit = ulimit;
-	ddp->max_txsz = min_t(unsigned int, max_txsz, ULP2_MAX_PKT_SIZE);
-	ddp->max_rxsz = min_t(unsigned int, max_rxsz, ULP2_MAX_PKT_SIZE);
-	ddp->nppods = ppmax;
-	ddp->idx_last = ppmax;
-	ddp->idx_bits = bits;
-	ddp->idx_mask = (1 << bits) - 1;
-	ddp->rsvd_tag_mask = (1 << (bits + PPOD_IDX_SHIFT)) - 1;
-
-	cdev->tag_format.sw_bits = sw_tag_idx_bits + sw_tag_age_bits;
-	cdev->tag_format.rsvd_bits = ddp->idx_bits;
-	cdev->tag_format.rsvd_shift = PPOD_IDX_SHIFT;
-	cdev->tag_format.rsvd_mask = (1 << cdev->tag_format.rsvd_bits) - 1;
-
-	pr_info("%s tag format, sw %u, rsvd %u,%u, mask 0x%x.\n",
-		cdev->ports[0]->name, cdev->tag_format.sw_bits,
-		cdev->tag_format.rsvd_bits, cdev->tag_format.rsvd_shift,
-		cdev->tag_format.rsvd_mask);
-
-	cdev->tx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
-				ddp->max_txsz - ISCSI_PDU_NONPAYLOAD_LEN);
-	cdev->rx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
-				ddp->max_rxsz - ISCSI_PDU_NONPAYLOAD_LEN);
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"%s max payload size: %u/%u, %u/%u.\n",
-		cdev->ports[0]->name, cdev->tx_max_size, ddp->max_txsz,
-		cdev->rx_max_size, ddp->max_rxsz);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(cxgbi_ddp_init);
-
-/*
  * APIs interacting with open-iscsi libraries
  */
 
@@ -1688,77 +1184,15 @@ static unsigned char padding[4];
 
 static void task_release_itt(struct iscsi_task *task, itt_t hdr_itt)
 {
-	struct scsi_cmnd *sc = task->sc;
-	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
-	struct cxgbi_conn *cconn = tcp_conn->dd_data;
-	struct cxgbi_hba *chba = cconn->chba;
-	struct cxgbi_tag_format *tformat = &chba->cdev->tag_format;
-	u32 tag = ntohl((__force u32)hdr_itt);
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		   "cdev 0x%p, release tag 0x%x.\n", chba->cdev, tag);
-	if (sc &&
-	    (scsi_bidi_cmnd(sc) || sc->sc_data_direction == DMA_FROM_DEVICE) &&
-	    cxgbi_is_ddp_tag(tformat, tag))
-		ddp_tag_release(chba, tag);
 }
 
 static int task_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt)
 {
-	struct scsi_cmnd *sc = task->sc;
-	struct iscsi_conn *conn = task->conn;
-	struct iscsi_session *sess = conn->session;
-	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
-	struct cxgbi_conn *cconn = tcp_conn->dd_data;
-	struct cxgbi_hba *chba = cconn->chba;
-	struct cxgbi_tag_format *tformat = &chba->cdev->tag_format;
-	u32 sw_tag = (sess->age << cconn->task_idx_bits) | task->itt;
-	u32 tag = 0;
-	int err = -EINVAL;
-
-	if (sc &&
-	    (scsi_bidi_cmnd(sc) || sc->sc_data_direction == DMA_FROM_DEVICE)) {
-		err = cxgbi_ddp_reserve(cconn->cep->csk, &tag, sw_tag,
-					scsi_in(sc)->length,
-					scsi_in(sc)->table.sgl,
-					scsi_in(sc)->table.nents,
-					GFP_ATOMIC);
-		if (err < 0)
-			log_debug(1 << CXGBI_DBG_DDP,
-				"csk 0x%p, R task 0x%p, %u,%u, no ddp.\n",
-				cconn->cep->csk, task, scsi_in(sc)->length,
-				scsi_in(sc)->table.nents);
-	}
-
-	if (err < 0)
-		tag = cxgbi_set_non_ddp_tag(tformat, sw_tag);
-	/*  the itt need to sent in big-endian order */
-	*hdr_itt = (__force itt_t)htonl(tag);
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"cdev 0x%p, task 0x%p, 0x%x(0x%x,0x%x)->0x%x/0x%x.\n",
-		chba->cdev, task, sw_tag, task->itt, sess->age, tag, *hdr_itt);
 	return 0;
 }
 
 void cxgbi_parse_pdu_itt(struct iscsi_conn *conn, itt_t itt, int *idx, int *age)
 {
-	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
-	struct cxgbi_conn *cconn = tcp_conn->dd_data;
-	struct cxgbi_device *cdev = cconn->chba->cdev;
-	u32 tag = ntohl((__force u32) itt);
-	u32 sw_bits;
-
-	sw_bits = cxgbi_tag_nonrsvd_bits(&cdev->tag_format, tag);
-	if (idx)
-		*idx = sw_bits & ((1 << cconn->task_idx_bits) - 1);
-	if (age)
-		*age = (sw_bits >> cconn->task_idx_bits) & ISCSI_AGE_MASK;
-
-	log_debug(1 << CXGBI_DBG_DDP,
-		"cdev 0x%p, tag 0x%x/0x%x, -> 0x%x(0x%x,0x%x).\n",
-		cdev, tag, itt, sw_bits, idx ? *idx : 0xFFFFF,
-		age ? *age : 0xFF);
 }
 EXPORT_SYMBOL_GPL(cxgbi_parse_pdu_itt);
 
@@ -2540,9 +1974,6 @@ int cxgbi_bind_conn(struct iscsi_cls_session *cls_session,
 	/*  setup ddp pagesize */
 	cep = ep->dd_data;
 	csk = cep->csk;
-	err = csk->cdev->csk_ddp_setup_pgidx(csk, csk->tid, page_idx, 0);
-	if (err < 0)
-		return err;
 
 	err = iscsi_conn_bind(cls_session, cls_conn, is_leading);
 	if (err)
@@ -2915,16 +2346,7 @@ EXPORT_SYMBOL_GPL(cxgbi_attr_is_visible);
 
 static int __init libcxgbi_init_module(void)
 {
-	sw_tag_idx_bits = (__ilog2_u32(ISCSI_ITT_MASK)) + 1;
-	sw_tag_age_bits = (__ilog2_u32(ISCSI_AGE_MASK)) + 1;
-
 	pr_info("%s", version);
-
-	pr_info("tag itt 0x%x, %u bits, age 0x%x, %u bits.\n",
-		ISCSI_ITT_MASK, sw_tag_idx_bits,
-		ISCSI_AGE_MASK, sw_tag_age_bits);
-
-	ddp_setup_host_page_size();
 	return 0;
 }
 
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 9842301..827afa7 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -84,91 +84,12 @@ static inline unsigned int cxgbi_ulp_extra_len(int submode)
 	return ulp2_extra_len[submode & 3];
 }
 
-/*
- * struct pagepod_hdr, pagepod - pagepod format
- */
-
 #define CPL_RX_DDP_STATUS_DDP_SHIFT	16 /* ddp'able */
 #define CPL_RX_DDP_STATUS_PAD_SHIFT	19 /* pad error */
 #define CPL_RX_DDP_STATUS_HCRC_SHIFT	20 /* hcrc error */
 #define CPL_RX_DDP_STATUS_DCRC_SHIFT	21 /* dcrc error */
 
-struct cxgbi_pagepod_hdr {
-	u32 vld_tid;
-	u32 pgsz_tag_clr;
-	u32 max_offset;
-	u32 page_offset;
-	u64 rsvd;
-};
-
-#define PPOD_PAGES_MAX			4
-struct cxgbi_pagepod {
-	struct cxgbi_pagepod_hdr hdr;
-	u64 addr[PPOD_PAGES_MAX + 1];
-};
-
-struct cxgbi_tag_format {
-	unsigned char sw_bits;
-	unsigned char rsvd_bits;
-	unsigned char rsvd_shift;
-	unsigned char filler[1];
-	u32 rsvd_mask;
-};
-
-struct cxgbi_gather_list {
-	unsigned int tag;
-	unsigned int length;
-	unsigned int offset;
-	unsigned int nelem;
-	struct page **pages;
-	dma_addr_t phys_addr[0];
-};
-
-struct cxgbi_ddp_info {
-	struct kref refcnt;
-	struct cxgbi_device *cdev;
-	struct pci_dev *pdev;
-	unsigned int max_txsz;
-	unsigned int max_rxsz;
-	unsigned int llimit;
-	unsigned int ulimit;
-	unsigned int nppods;
-	unsigned int idx_last;
-	unsigned char idx_bits;
-	unsigned char filler[3];
-	unsigned int idx_mask;
-	unsigned int rsvd_tag_mask;
-	spinlock_t map_lock;
-	struct cxgbi_gather_list **gl_map;
-};
-
 #define DDP_PGIDX_MAX		4
-#define DDP_THRESHOLD		2048
-
-#define PPOD_PAGES_SHIFT	2       /*  4 pages per pod */
-
-#define PPOD_SIZE               sizeof(struct cxgbi_pagepod)  /*  64 */
-#define PPOD_SIZE_SHIFT         6
-
-#define ULPMEM_DSGL_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
-#define ULPMEM_IDATA_MAX_NPPODS	4	/*  256/PPOD_SIZE */
-#define PCIE_MEMWIN_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
-
-#define PPOD_COLOR_SHIFT	0
-#define PPOD_COLOR(x)		((x) << PPOD_COLOR_SHIFT)
-
-#define PPOD_IDX_SHIFT          6
-#define PPOD_IDX_MAX_SIZE       24
-
-#define PPOD_TID_SHIFT		0
-#define PPOD_TID(x)		((x) << PPOD_TID_SHIFT)
-
-#define PPOD_TAG_SHIFT		6
-#define PPOD_TAG(x)		((x) << PPOD_TAG_SHIFT)
-
-#define PPOD_VALID_SHIFT	24
-#define PPOD_VALID(x)		((x) << PPOD_VALID_SHIFT)
-#define PPOD_VALID_FLAG		PPOD_VALID(1U)
 
 /*
  * sge_opaque_hdr -
@@ -548,15 +469,8 @@ struct cxgbi_device {
 	unsigned int tx_max_size;
 	unsigned int rx_max_size;
 	struct cxgbi_ports_map pmap;
-	struct cxgbi_tag_format tag_format;
-	struct cxgbi_ddp_info *ddp;
 
 	void (*dev_ddp_cleanup)(struct cxgbi_device *);
-	int (*csk_ddp_set)(struct cxgbi_sock *, struct cxgbi_pagepod_hdr *,
-				unsigned int, unsigned int,
-				struct cxgbi_gather_list *);
-	void (*csk_ddp_clear)(struct cxgbi_hba *,
-				unsigned int, unsigned int, unsigned int);
 	int (*csk_ddp_setup_digest)(struct cxgbi_sock *,
 				unsigned int, int, int, int);
 	int (*csk_ddp_setup_pgidx)(struct cxgbi_sock *,
@@ -600,78 +514,6 @@ struct cxgbi_task_data {
 #define iscsi_task_cxgbi_data(task) \
 	((task)->dd_data + sizeof(struct iscsi_tcp_task))
 
-static inline int cxgbi_is_ddp_tag(struct cxgbi_tag_format *tformat, u32 tag)
-{
-	return !(tag & (1 << (tformat->rsvd_bits + tformat->rsvd_shift - 1)));
-}
-
-static inline int cxgbi_sw_tag_usable(struct cxgbi_tag_format *tformat,
-					u32 sw_tag)
-{
-	sw_tag >>= (32 - tformat->rsvd_bits);
-	return !sw_tag;
-}
-
-static inline u32 cxgbi_set_non_ddp_tag(struct cxgbi_tag_format *tformat,
-					u32 sw_tag)
-{
-	unsigned char shift = tformat->rsvd_bits + tformat->rsvd_shift - 1;
-	u32 mask = (1 << shift) - 1;
-
-	if (sw_tag && (sw_tag & ~mask)) {
-		u32 v1 = sw_tag & ((1 << shift) - 1);
-		u32 v2 = (sw_tag >> (shift - 1)) << shift;
-
-		return v2 | v1 | 1 << shift;
-	}
-
-	return sw_tag | 1 << shift;
-}
-
-static inline u32 cxgbi_ddp_tag_base(struct cxgbi_tag_format *tformat,
-					u32 sw_tag)
-{
-	u32 mask = (1 << tformat->rsvd_shift) - 1;
-
-	if (sw_tag && (sw_tag & ~mask)) {
-		u32 v1 = sw_tag & mask;
-		u32 v2 = sw_tag >> tformat->rsvd_shift;
-
-		v2 <<= tformat->rsvd_bits + tformat->rsvd_shift;
-
-		return v2 | v1;
-	}
-
-	return sw_tag;
-}
-
-static inline u32 cxgbi_tag_rsvd_bits(struct cxgbi_tag_format *tformat,
-					u32 tag)
-{
-	if (cxgbi_is_ddp_tag(tformat, tag))
-		return (tag >> tformat->rsvd_shift) & tformat->rsvd_mask;
-
-	return 0;
-}
-
-static inline u32 cxgbi_tag_nonrsvd_bits(struct cxgbi_tag_format *tformat,
-					u32 tag)
-{
-	unsigned char shift = tformat->rsvd_bits + tformat->rsvd_shift - 1;
-	u32 v1, v2;
-
-	if (cxgbi_is_ddp_tag(tformat, tag)) {
-		v1 = tag & ((1 << tformat->rsvd_shift) - 1);
-		v2 = (tag >> (shift + 1)) << tformat->rsvd_shift;
-	} else {
-		u32 mask = (1 << shift) - 1;
-		tag &= ~(1 << shift);
-		v1 = tag & mask;
-		v2 = (tag >> 1) & ~mask;
-	}
-	return v1 | v2;
-}
-
 static inline void *cxgbi_alloc_big_mem(unsigned int size,
 					gfp_t gfp)
 {
@@ -749,7 +591,4 @@ int cxgbi_ddp_init(struct cxgbi_device *, unsigned int, unsigned int,
 			unsigned int, unsigned int);
 int cxgbi_ddp_cleanup(struct cxgbi_device *);
 void cxgbi_ddp_page_size_factor(int *);
-void cxgbi_ddp_ppod_clear(struct cxgbi_pagepod *);
-void cxgbi_ddp_ppod_set(struct cxgbi_pagepod *, struct cxgbi_pagepod_hdr *,
-			struct cxgbi_gather_list *, unsigned int);
 #endif	/*__LIBCXGBI_H__*/
-- 
2.0.2
