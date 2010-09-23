From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH 4/4] cxgb4i: connection and ddp setting update
Date: Thu, 23 Sep 2010 16:43:23 -0700
Message-ID: <201009232343.o8NNhN0Q006467@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCNvLk8fsDxCmzO_kBBoEi8W44Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

[PATCH 4/4] cxgb4i: connection and ddp setting update
          
From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
          
This patch updated cxgb4i connection setting and pagepod programming.

Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |  128 +++++++++++++++++++-----------------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h |    5 +
 drivers/scsi/cxgbi/libcxgbi.h      |   10 ---
 3 files changed, 71 insertions(+), 72 deletions(-)


diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 1056d97..99f2b8c 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -34,8 +34,8 @@ static unsigned int dbg_level;
 
 #define	DRV_MODULE_NAME		"cxgb4i"
 #define DRV_MODULE_DESC		"Chelsio T4 iSCSI Driver"
-#define	DRV_MODULE_VERSION	"0.9.0"
-#define	DRV_MODULE_RELDATE	"May 2010"
+#define	DRV_MODULE_VERSION	"0.9.1"
+#define	DRV_MODULE_RELDATE	"Aug. 2010"
 
 static char version[] =
 	DRV_MODULE_DESC " " DRV_MODULE_NAME
@@ -396,7 +396,7 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 		htonl(FW_WR_LEN16(DIV_ROUND_UP(72, 16)) |
 				FW_WR_FLOWID(csk->tid));
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
-	flowc->mnemval[0].val = htonl(0);
+	flowc->mnemval[0].val = htonl(csk->cdev->pfvf);
 	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
 	flowc->mnemval[1].val = htonl(csk->tx_chan);
 	flowc->mnemval[2].mnemonic = FW_FLOWC_MNEM_PORT;
@@ -568,6 +568,12 @@ static void do_act_establish(struct cxgbi_device *cdev, struct sk_buff *skb)
 		goto rel_skb;
 	}
 
+	if (csk->atid != atid) {
+		pr_err("bad conn atid %u, csk 0x%p,%u,0x%lx,tid %u, atid %u.\n",
+			atid, csk, csk->state, csk->flags, csk->tid, csk->atid);
+		goto rel_skb;
+	}
+
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p,%u,0x%lx, tid %u, atid %u, rseq %u.\n",
 		csk, csk->state, csk->flags, tid, atid, rcv_isn);
@@ -681,9 +687,10 @@ static void do_act_open_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 		goto rel_skb;
 	}
 
-	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
-		"csk 0x%p,%u,0x%lx, status %u, atid %u, tid %u.\n",
-			csk, csk->state, csk->flags, status, atid, tid);
+	pr_info("%pI4:%u-%pI4:%u, atid %u,%u, status %u, csk 0x%p,%u,0x%lx.\n",
+		&csk->saddr.sin_addr.s_addr, ntohs(csk->saddr.sin_port),
+		&csk->daddr.sin_addr.s_addr, ntohs(csk->daddr.sin_port),
+		atid, tid, status, csk, csk->state, csk->flags);
 
 	if (status && status != CPL_ERR_TCAM_FULL &&
 	    status != CPL_ERR_CONN_EXIST &&
@@ -846,7 +853,6 @@ static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 	unsigned int tid = GET_TID(cpl);
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
 	struct tid_info *t = lldi->tids;
-	struct sk_buff *lskb;
 
 	csk = lookup_tid(t, tid);
 	if (unlikely(!csk)) {
@@ -872,6 +878,8 @@ static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 	}
 
 	cxgbi_skcb_tcp_seq(skb) = ntohl(cpl->seq);
+	cxgbi_skcb_flags(skb) = 0;
+
 	skb_reset_transport_header(skb);
 	__skb_pull(skb, sizeof(*cpl));
 	__pskb_trim(skb, ntohs(cpl->len));
@@ -884,17 +892,16 @@ static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 			"csk 0x%p,%u,0x%lx, tid %u, skb 0x%p header.\n",
 			csk, csk->state, csk->flags, csk->tid, skb);
 		csk->skb_ulp_lhdr = skb;
-		lskb = csk->skb_ulp_lhdr;
-		cxgbi_skcb_set_flag(lskb, SKCBF_RX_HDR);
+		cxgbi_skcb_set_flag(skb, SKCBF_RX_HDR);
 
-		if (cxgbi_skcb_tcp_seq(lskb) != csk->rcv_nxt) {
+		if (cxgbi_skcb_tcp_seq(skb) != csk->rcv_nxt) {
 			pr_info("tid %u, CPL_ISCSI_HDR, bad seq, 0x%x/0x%x.\n",
-				csk->tid, cxgbi_skcb_tcp_seq(lskb),
+				csk->tid, cxgbi_skcb_tcp_seq(skb),
 				csk->rcv_nxt);
 			goto abort_conn;
 		}
 
-		bhs = lskb->data;
+		bhs = skb->data;
 		hlen = ntohs(cpl->len);
 		dlen = ntohl(*(unsigned int *)(bhs + 4)) & 0xFFFFFF;
 
@@ -918,9 +925,9 @@ static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 			ntohl(*((unsigned int *)(bhs + 24))));
 
 	} else {
-		lskb = csk->skb_ulp_lhdr;
-		cxgbi_skcb_set_flag(lskb, SKCBF_RX_DATA);
+		struct sk_buff *lskb = csk->skb_ulp_lhdr;
 
+		cxgbi_skcb_set_flag(lskb, SKCBF_RX_DATA);
 		log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_PDU_RX,
 			"csk 0x%p,%u,0x%lx, skb 0x%p data, 0x%p.\n",
 			csk, csk->state, csk->flags, skb, lskb);
@@ -979,7 +986,6 @@ static void do_rx_data_ddp(struct cxgbi_device *cdev,
 	lskb = csk->skb_ulp_lhdr;
 	csk->skb_ulp_lhdr = NULL;
 
-	cxgbi_skcb_set_flag(lskb, SKCBF_RX_STATUS);
 	cxgbi_skcb_rx_ddigest(lskb) = ntohl(rpl->ulp_crc);
 
 	if (ntohs(rpl->len) != cxgbi_skcb_rx_pdulen(lskb))
@@ -987,15 +993,13 @@ static void do_rx_data_ddp(struct cxgbi_device *cdev,
 			csk->tid, ntohs(rpl->len), cxgbi_skcb_rx_pdulen(lskb));
 
 	if (status & (1 << CPL_RX_DDP_STATUS_HCRC_SHIFT)) {
-		log_debug(1 << CXGBI_DBG_PDU_RX,
-			"csk 0x%p, lhdr 0x%p, status 0x%x, hcrc bad.\n",
-			csk, lskb, status);
+		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, hcrc bad 0x%lx.\n",
+			csk, lskb, status, cxgbi_skcb_flags(lskb));
 		cxgbi_skcb_set_flag(lskb, SKCBF_RX_HCRC_ERR);
 	}
 	if (status & (1 << CPL_RX_DDP_STATUS_DCRC_SHIFT)) {
-		log_debug(1 << CXGBI_DBG_PDU_RX,
-			"csk 0x%p, lhdr 0x%p, status 0x%x, dcrc bad.\n",
-			csk, lskb, status);
+		pr_info("csk 0x%p, lhdr 0x%p, status 0x%x, dcrc bad 0x%lx.\n",
+			csk, lskb, status, cxgbi_skcb_flags(lskb));
 		cxgbi_skcb_set_flag(lskb, SKCBF_RX_DCRC_ERR);
 	}
 	if (status & (1 << CPL_RX_DDP_STATUS_PAD_SHIFT)) {
@@ -1015,6 +1019,7 @@ static void do_rx_data_ddp(struct cxgbi_device *cdev,
 		"csk 0x%p, lskb 0x%p, f 0x%lx.\n",
 		csk, lskb, cxgbi_skcb_flags(lskb));
 
+	cxgbi_skcb_set_flag(lskb, SKCBF_RX_STATUS);
 	cxgbi_conn_pdu_ready(csk);
 	spin_unlock_bh(&csk->lock);
 	goto rel_skb;
@@ -1234,41 +1239,41 @@ int cxgb4i_ofld_init(struct cxgbi_device *cdev)
 /*
  * functions to program the pagepod in h/w
  */
+#define ULPMEM_IDATA_MAX_NPPODS	4 /* 256/PPOD_SIZE */
 static inline void ulp_mem_io_set_hdr(struct ulp_mem_io *req,
-				unsigned int dlen, unsigned int pm_addr)
+				unsigned int wr_len, unsigned int dlen,
+				unsigned int pm_addr)
 {
-	struct ulptx_sgl *sgl;
-	unsigned int wr_len = roundup(sizeof(struct ulp_mem_io) +
-					sizeof(struct ulptx_sgl), 16);
+	struct ulptx_idata *idata = (struct ulptx_idata *)(req + 1);
 
 	INIT_ULPTX_WR(req, wr_len, 0, 0);
-	req->cmd = htonl(ULPTX_CMD(ULP_TX_MEM_WRITE));
+	req->cmd = htonl(ULPTX_CMD(ULP_TX_MEM_WRITE) | (1 << 23));
 	req->dlen = htonl(ULP_MEMIO_DATA_LEN(dlen >> 5));
 	req->lock_addr = htonl(ULP_MEMIO_ADDR(pm_addr >> 5));
 	req->len16 = htonl(DIV_ROUND_UP(wr_len - sizeof(req->wr), 16));
-	sgl = (struct ulptx_sgl *)(req + 1);
-	sgl->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_NSGE(1));
-	sgl->len0 = htonl(dlen);
+
+	idata->cmd_more = htonl(ULPTX_CMD(ULP_TX_SC_IMM));
+	idata->len = htonl(dlen);
 }
 
-static int ddp_ppod_write_sgl(struct cxgbi_device *cdev, unsigned int port_id,
+static int ddp_ppod_write_idata(struct cxgbi_device *cdev, unsigned int port_id,
 				struct cxgbi_pagepod_hdr *hdr, unsigned int idx,
 				unsigned int npods,
 				struct cxgbi_gather_list *gl,
 				unsigned int gl_pidx)
 {
 	struct cxgbi_ddp_info *ddp = cdev->ddp;
-	unsigned int dlen, pm_addr;
 	struct sk_buff *skb;
 	struct ulp_mem_io *req;
-	struct ulptx_sgl *sgl;
+	struct ulptx_idata *idata;
 	struct cxgbi_pagepod *ppod;
+	unsigned int pm_addr = idx * PPOD_SIZE + ddp->llimit;
+	unsigned int dlen = PPOD_SIZE * npods;
+	unsigned int wr_len = roundup(sizeof(struct ulp_mem_io) +
+				sizeof(struct ulptx_idata) + dlen, 16);
 	unsigned int i;
 
-	dlen = PPOD_SIZE * npods;
-	pm_addr = idx * PPOD_SIZE + ddp->llimit;
-
-	skb = alloc_wr(sizeof(*req) + sizeof(*sgl), dlen, GFP_ATOMIC);
+	skb = alloc_wr(wr_len, 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_err("cdev 0x%p, idx %u, npods %u, OOM.\n",
 			cdev, idx, npods);
@@ -1277,10 +1282,9 @@ static int ddp_ppod_write_sgl(struct cxgbi_device *cdev, unsigned int port_id,
 	req = (struct ulp_mem_io *)skb->head;
 	set_queue(skb, CPL_PRIORITY_CONTROL, NULL);
 
-	ulp_mem_io_set_hdr(req, dlen, pm_addr);
-	sgl = (struct ulptx_sgl *)(req + 1);
-	ppod = (struct cxgbi_pagepod *)(sgl + 1);
-	sgl->addr0 = cpu_to_be64(virt_to_phys(ppod));
+	ulp_mem_io_set_hdr(req, wr_len, dlen, pm_addr);
+	idata = (struct ulptx_idata *)(req + 1);
+	ppod = (struct cxgbi_pagepod *)(idata + 1);
 
 	for (i = 0; i < npods; i++, ppod++, gl_pidx += PPOD_PAGES_MAX) {
 		if (!hdr && !gl)
@@ -1302,9 +1306,9 @@ static int ddp_set_map(struct cxgbi_sock *csk, struct cxgbi_pagepod_hdr *hdr,
 
 	for (i = 0; i < npods; i += cnt, idx += cnt) {
 		cnt = npods - i;
-		if (cnt > ULPMEM_DSGL_MAX_NPPODS)
-			cnt = ULPMEM_DSGL_MAX_NPPODS;
-		err = ddp_ppod_write_sgl(csk->cdev, csk->port_id, hdr,
+		if (cnt > ULPMEM_IDATA_MAX_NPPODS)
+			cnt = ULPMEM_IDATA_MAX_NPPODS;
+		err = ddp_ppod_write_idata(csk->cdev, csk->port_id, hdr,
 					idx, cnt, gl, 4 * i);
 		if (err < 0)
 			break;
@@ -1320,9 +1324,9 @@ static void ddp_clear_map(struct cxgbi_hba *chba, unsigned int tag,
 
 	for (i = 0; i < npods; i += cnt, idx += cnt) {
 		cnt = npods - i;
-		if (cnt > ULPMEM_DSGL_MAX_NPPODS)
-			cnt = ULPMEM_DSGL_MAX_NPPODS;
-		err = ddp_ppod_write_sgl(chba->cdev, chba->port_id, NULL,
+		if (cnt > ULPMEM_IDATA_MAX_NPPODS)
+			cnt = ULPMEM_IDATA_MAX_NPPODS;
+		err = ddp_ppod_write_idata(chba->cdev, chba->port_id, NULL,
 					idx, cnt, NULL, 0);
 		if (err < 0)
 			break;
@@ -1334,26 +1338,22 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk, unsigned int tid,
 {
 	struct sk_buff *skb;
 	struct cpl_set_tcb_field *req;
-	u64 val = pg_idx < DDP_PGIDX_MAX ? pg_idx : 0;
 
-	if (!pg_idx)
+	if (!pg_idx || pg_idx >= DDP_PGIDX_MAX)
 		return 0;
 
 	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
-	/*  set up ulp submode and page size */
-	val = (val & 0x03) << 2;
-	val |= TCB_ULP_TYPE(ULP2_MODE_ISCSI);
-
+	/*  set up ulp page size */
 	req = (struct cpl_set_tcb_field *)skb->head;
 	INIT_TP_WR(req, csk->tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, csk->tid));
 	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
-	req->word_cookie = htons(TCB_WORD(W_TCB_ULP_RAW));
-	req->mask = cpu_to_be64(TCB_ULP_TYPE(TCB_ULP_TYPE_MASK));
-	req->val = cpu_to_be64(val);
+	req->word_cookie = htons(0);
+	req->mask = cpu_to_be64(0x3 << 8);
+	req->val = cpu_to_be64(pg_idx << 8);
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, csk->port_id);
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
@@ -1368,10 +1368,9 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 {
 	struct sk_buff *skb;
 	struct cpl_set_tcb_field *req;
-	u64 val = (hcrc ? ULP_CRC_HEADER : 0) | (dcrc ? ULP_CRC_DATA : 0);
 
-	val = TCB_ULP_RAW(val);
-	val |= TCB_ULP_TYPE(ULP2_MODE_ISCSI);
+	if (!hcrc && !dcrc)
+		return 0;
 
 	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
 	if (!skb)
@@ -1379,14 +1378,15 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 
 	csk->hcrc_len = (hcrc ? 4 : 0);
 	csk->dcrc_len = (dcrc ? 4 : 0);
-	/*  set up ulp submode and page size */
+	/*  set up ulp submode */
 	req = (struct cpl_set_tcb_field *)skb->head;
 	INIT_TP_WR(req, tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
 	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
-	req->word_cookie = htons(TCB_WORD(W_TCB_ULP_RAW));
-	req->mask = cpu_to_be64(TCB_ULP_RAW(TCB_ULP_RAW_MASK));
-	req->val = cpu_to_be64(val);
+	req->word_cookie = htons(0);
+	req->mask = cpu_to_be64(0x3 << 4);
+	req->val = cpu_to_be64(((hcrc ? ULP_CRC_HEADER : 0) |
+				(dcrc ? ULP_CRC_DATA : 0)) << 4);
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, csk->port_id);
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
@@ -1477,6 +1477,10 @@ static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 	cdev->skb_rx_extra = sizeof(struct cpl_iscsi_hdr);
 	cdev->itp = &cxgb4i_iscsi_transport;
 
+	cdev->pfvf = FW_VIID_PFN_GET(cxgb4_port_viid(lldi->ports[0])) << 8;
+	pr_info("cdev 0x%p,%s, pfvf %u.\n",
+		cdev, lldi->ports[0]->name, cdev->pfvf);
+
 	rc = cxgb4i_ddp_init(cdev);
 	if (rc) {
 		pr_info("t4 0x%p ddp init failed.\n", cdev);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
index 342263b..1096026 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
@@ -23,6 +23,11 @@
 #define CXGB4I_TX_HEADER_LEN \
 	(sizeof(struct fw_ofld_tx_data_wr) + sizeof(struct sge_opaque_hdr))
 
+struct ulptx_idata {
+	__be32 cmd_more;
+	__be32 len;
+};
+
 struct cpl_rx_data_ddp {
 	union opcode_tid ot;
 	__be16 urg;
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 43025b7..c57d59d 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -162,16 +162,6 @@ struct cxgbi_ddp_info {
 #define PPOD_VALID(x)		((x) << PPOD_VALID_SHIFT)
 #define PPOD_VALID_FLAG		PPOD_VALID(1U)
 
-#define W_TCB_ULP_TYPE          0
-#define TCB_ULP_TYPE_SHIFT      0
-#define TCB_ULP_TYPE_MASK       0xfULL
-#define TCB_ULP_TYPE(x)         ((x) << TCB_ULP_TYPE_SHIFT)
-
-#define W_TCB_ULP_RAW           0
-#define TCB_ULP_RAW_SHIFT       4
-#define TCB_ULP_RAW_MASK        0xffULL
-#define TCB_ULP_RAW(x)          ((x) << TCB_ULP_RAW_SHIFT)
-
 /*
  * sge_opaque_hdr -
  * Opaque version of structure the SGE stores at skb->head of TX_DATA packets

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
