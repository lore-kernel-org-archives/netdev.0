From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH] cxgbi: bug fixes and code cleanup
Date: Tue, 21 Sep 2010 09:09:17 -0700
Message-ID: <201009211609.o8LG9HPm014568@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCNvLk8fsDxC6sePkBBoE_TzVQA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

[PATCH] cxgbi: bug fixes and code cleanup

From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

The patch includes the following changes.
- removed un-used code
- renamed alloc_cpl() to alloc_wr().
- fixed connecting over VLAN.
- updated cxgb4i connection setting and pagepod programming.

Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c |   65 ++++++++++++++-----
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |  126 +++++++++++++++++++-----------------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h |    5 +
 drivers/scsi/cxgbi/libcxgbi.c      |   94 +++++++++++++--------------
 drivers/scsi/cxgbi/libcxgbi.h      |   18 +----
 5 files changed, 172 insertions(+), 136 deletions(-)


diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index a01c1e2..a129a17 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -320,7 +320,7 @@ static u32 send_rx_credits(struct cxgbi_sock *csk, u32 credits)
 		"csk 0x%p,%u,0x%lx,%u, credit %u, dack %u.\n",
 		csk, csk->state, csk->flags, csk->tid, credits, dack);
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(*req), 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_info("csk 0x%p, credit %u, OOM.\n", csk, credits);
 		return 0;
@@ -572,7 +572,7 @@ static void act_open_retry_timer(unsigned long data)
 
 	cxgbi_sock_get(csk);
 	spin_lock_bh(&csk->lock);
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
 	if (!skb)
 		cxgbi_sock_fail_act_open(csk, -ENOMEM);
 	else {
@@ -589,9 +589,10 @@ static int do_act_open_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	struct cxgbi_sock *csk = ctx;
 	struct cpl_act_open_rpl *rpl = cplhdr(skb);
 
-	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
-		"csk 0x%p,%u,0x%lx,%u, status %u.\n",
-		csk, csk->state, csk->flags, csk->atid, rpl->status);
+	pr_info("csk 0x%p,%u,0x%lx,%u, status %u, %pI4:%u-%pI4:%u.\n",
+		csk, csk->state, csk->flags, csk->atid, rpl->status,
+		&csk->saddr.sin_addr.s_addr, ntohs(csk->saddr.sin_port),
+		&csk->daddr.sin_addr.s_addr, ntohs(csk->daddr.sin_port));
 
 	if (rpl->status != CPL_ERR_TCAM_FULL &&
 	    rpl->status != CPL_ERR_CONN_EXIST &&
@@ -662,8 +663,7 @@ static int abort_status_to_errno(struct cxgbi_sock *csk, int abort_reason,
 	switch (abort_reason) {
 	case CPL_ERR_BAD_SYN: /* fall through */
 	case CPL_ERR_CONN_RESET:
-		return csk->state > CTP_ESTABLISHED ?
-			-EPIPE : -ECONNRESET;
+		return csk->state > CTP_ESTABLISHED ? -EPIPE : -ECONNRESET;
 	case CPL_ERR_XMIT_TIMEDOUT:
 	case CPL_ERR_PERSIST_TIMEDOUT:
 	case CPL_ERR_FINWAIT2_TIMEDOUT:
@@ -881,16 +881,16 @@ static int do_wr_ack(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
  */
 static int alloc_cpls(struct cxgbi_sock *csk)
 {
-	csk->cpl_close = alloc_cpl(sizeof(struct cpl_close_con_req), 0,
+	csk->cpl_close = alloc_wr(sizeof(struct cpl_close_con_req), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_close)
 		return -ENOMEM;
-	csk->cpl_abort_req = alloc_cpl(sizeof(struct cpl_abort_req), 0,
+	csk->cpl_abort_req = alloc_wr(sizeof(struct cpl_abort_req), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_abort_req)
 		goto free_cpl_skbs;
 
-	csk->cpl_abort_rpl = alloc_cpl(sizeof(struct cpl_abort_rpl), 0,
+	csk->cpl_abort_rpl = alloc_wr(sizeof(struct cpl_abort_rpl), 0,
 					GFP_KERNEL);
 	if (!csk->cpl_abort_rpl)
 		goto free_cpl_skbs;
@@ -945,17 +945,44 @@ static void release_offload_resources(struct cxgbi_sock *csk)
 	csk->cdev = NULL;
 }
 
+static void update_address(struct cxgbi_hba *chba)
+{
+	if (chba->ipv4addr) {
+		if (chba->vdev &&
+		    chba->ipv4addr != cxgb3i_get_private_ipv4addr(chba->vdev)) {
+			cxgb3i_set_private_ipv4addr(chba->vdev, chba->ipv4addr);
+			cxgb3i_set_private_ipv4addr(chba->ndev, 0);
+			pr_info("%s set %pI4.\n",
+				chba->vdev->name, &chba->ipv4addr);
+		} else if (chba->ipv4addr !=
+				cxgb3i_get_private_ipv4addr(chba->ndev)) {
+			cxgb3i_set_private_ipv4addr(chba->ndev, chba->ipv4addr);
+			pr_info("%s set %pI4.\n",
+				chba->ndev->name, &chba->ipv4addr);
+		}
+	} else if (cxgb3i_get_private_ipv4addr(chba->ndev)) {
+		if (chba->vdev)
+			cxgb3i_set_private_ipv4addr(chba->vdev, 0);
+		cxgb3i_set_private_ipv4addr(chba->ndev, 0);
+	}
+}
+
 static int init_act_open(struct cxgbi_sock *csk)
 {
 	struct dst_entry *dst = csk->dst;
 	struct cxgbi_device *cdev = csk->cdev;
 	struct t3cdev *t3dev = (struct t3cdev *)cdev->lldev;
 	struct net_device *ndev = cdev->ports[csk->port_id];
+	struct cxgbi_hba *chba = cdev->hbas[csk->port_id];
 	struct sk_buff *skb = NULL;
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p,%u,0x%lx.\n", csk, csk->state, csk->flags);
 
+	update_address(chba);
+	if (chba->ipv4addr)
+		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
+
 	csk->rss_qid = 0;
 	csk->l2t = t3_l2t_get(t3dev, dst->neighbour, ndev);
 	if (!csk->l2t) {
@@ -972,7 +999,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
 	if (!skb)
 		goto rel_resource;
 	skb->sk = (struct sock *)csk;
@@ -984,6 +1011,12 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_reset_wr_list(csk);
 	csk->err = 0;
 
+	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
+		"csk 0x%p,%u,0x%lx, %pI4:%u-%pI4:%u.\n",
+		csk, csk->state, csk->flags,
+		&csk->saddr.sin_addr.s_addr, ntohs(csk->saddr.sin_port),
+		&csk->daddr.sin_addr.s_addr, ntohs(csk->daddr.sin_port));
+
 	cxgbi_sock_set_state(csk, CTP_ACTIVE_OPEN);
 	send_act_open_req(csk, skb, csk->l2t);
 	return 0;
@@ -1141,11 +1174,11 @@ static int ddp_alloc_gl_skb(struct cxgbi_ddp_info *ddp, int idx,
 		"ddp 0x%p, idx %d, cnt %d.\n", ddp, idx, cnt);
 
 	for (i = 0; i < cnt; i++) {
-		struct sk_buff *skb = alloc_cpl(sizeof(struct ulp_mem_io) +
+		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
 						PPOD_SIZE, 0, gfp);
-		if (skb) {
+		if (skb)
 			ddp->gl_skb[idx + i] = skb;
-		} else {
+		else {
 			ddp_free_gl_skb(ddp, idx, i);
 			return -ENOMEM;
 		}
@@ -1156,7 +1189,7 @@ static int ddp_alloc_gl_skb(struct cxgbi_ddp_info *ddp, int idx,
 static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
 				       unsigned int tid, int pg_idx, bool reply)
 {
-	struct sk_buff *skb = alloc_cpl(sizeof(struct cpl_set_tcb_field), 0,
+	struct sk_buff *skb = alloc_wr(sizeof(struct cpl_set_tcb_field), 0,
 					GFP_KERNEL);
 	struct cpl_set_tcb_field *req;
 	u64 val = pg_idx < DDP_PGIDX_MAX ? pg_idx : 0;
@@ -1193,7 +1226,7 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
 static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 			     int hcrc, int dcrc, int reply)
 {
-	struct sk_buff *skb = alloc_cpl(sizeof(struct cpl_set_tcb_field), 0,
+	struct sk_buff *skb = alloc_wr(sizeof(struct cpl_set_tcb_field), 0,
 					GFP_KERNEL);
 	struct cpl_set_tcb_field *req;
 	u64 val = (hcrc ? 1 : 0) | (dcrc ? 2 : 0);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index b375a68..8b6ada8 100644
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
@@ -332,7 +332,7 @@ static u32 send_rx_credits(struct cxgbi_sock *csk, u32 credits)
 		"csk 0x%p,%u,0x%lx,%u, credit %u.\n",
 		csk, csk->state, csk->flags, csk->tid, credits);
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(*req), 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_info("csk 0x%p, credit %u, OOM.\n", csk, credits);
 		return 0;
@@ -388,7 +388,7 @@ static inline void send_tx_flowc_wr(struct cxgbi_sock *csk)
 	int flowclen, i;
 
 	flowclen = 80;
-	skb = alloc_cpl(flowclen, 0, GFP_ATOMIC);
+	skb = alloc_wr(flowclen, 0, GFP_ATOMIC);
 	flowc = (struct fw_flowc_wr *)skb->head;
 	flowc->op_to_nparams =
 		htonl(FW_WR_OP(FW_FLOWC_WR) | FW_FLOWC_WR_NPARAMS(8));
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
@@ -651,7 +657,7 @@ static void csk_act_open_retry_timer(unsigned long data)
 
 	cxgbi_sock_get(csk);
 	spin_lock_bh(&csk->lock);
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_ATOMIC);
 	if (!skb)
 		cxgbi_sock_fail_act_open(csk, -ENOMEM);
 	else {
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
@@ -1073,18 +1080,18 @@ static void do_set_tcb_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 
 static int alloc_cpls(struct cxgbi_sock *csk)
 {
-	csk->cpl_close = alloc_cpl(sizeof(struct cpl_close_con_req),
-					0, GFP_NOIO);
+	csk->cpl_close = alloc_wr(sizeof(struct cpl_close_con_req),
+					0, GFP_KERNEL);
 	if (!csk->cpl_close)
 		return -ENOMEM;
 
-	csk->cpl_abort_req = alloc_cpl(sizeof(struct cpl_abort_req),
-					0, GFP_NOIO);
+	csk->cpl_abort_req = alloc_wr(sizeof(struct cpl_abort_req),
+					0, GFP_KERNEL);
 	if (!csk->cpl_abort_req)
 		goto free_cpls;
 
-	csk->cpl_abort_rpl = alloc_cpl(sizeof(struct cpl_abort_rpl),
-					0, GFP_NOIO);
+	csk->cpl_abort_rpl = alloc_wr(sizeof(struct cpl_abort_rpl),
+					0, GFP_KERNEL);
 	if (!csk->cpl_abort_rpl)
 		goto free_cpls;
 	return 0;
@@ -1158,7 +1165,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	}
 	cxgbi_sock_get(csk);
 
-	skb = alloc_cpl(sizeof(struct cpl_act_open_req), 0, GFP_NOIO);
+	skb = alloc_wr(sizeof(struct cpl_act_open_req), 0, GFP_KERNEL);
 	if (!skb)
 		goto rel_resource;
 	skb->sk = (struct sock *)csk;
@@ -1234,41 +1241,41 @@ int cxgb4i_ofld_init(struct cxgbi_device *cdev)
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
-	skb = alloc_cpl(sizeof(*req) + sizeof(*sgl), dlen, GFP_ATOMIC);
+	skb = alloc_wr(wr_len, 0, GFP_ATOMIC);
 	if (!skb) {
 		pr_err("cdev 0x%p, idx %u, npods %u, OOM.\n",
 			cdev, idx, npods);
@@ -1277,10 +1284,9 @@ static int ddp_ppod_write_sgl(struct cxgbi_device *cdev, unsigned int port_id,
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
@@ -1302,9 +1308,9 @@ static int ddp_set_map(struct cxgbi_sock *csk, struct cxgbi_pagepod_hdr *hdr,
 
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
@@ -1320,9 +1326,9 @@ static void ddp_clear_map(struct cxgbi_hba *chba, unsigned int tag,
 
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
@@ -1334,26 +1340,22 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk, unsigned int tid,
 {
 	struct sk_buff *skb;
 	struct cpl_set_tcb_field *req;
-	u64 val = pg_idx < DDP_PGIDX_MAX ? pg_idx : 0;
 
-	if (!pg_idx)
+	if (!pg_idx || pg_idx >= DDP_PGIDX_MAX)
 		return 0;
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
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
@@ -1368,25 +1370,25 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 {
 	struct sk_buff *skb;
 	struct cpl_set_tcb_field *req;
-	u64 val = (hcrc ? ULP_CRC_HEADER : 0) | (dcrc ? ULP_CRC_DATA : 0);
 
-	val = TCB_ULP_RAW(val);
-	val |= TCB_ULP_TYPE(ULP2_MODE_ISCSI);
+	if (!hcrc && !dcrc)
+		return 0;
 
-	skb = alloc_cpl(sizeof(*req), 0, GFP_KERNEL);
+	skb = alloc_wr(sizeof(*req), 0, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
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
@@ -1477,6 +1479,10 @@ static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 	cdev->skb_rx_extra = sizeof(struct cpl_iscsi_hdr);
 	cdev->itp = &cxgb4i_iscsi_transport;
 
+	cdev->pfvf = FW_VIID_PFN_GET(cxgb4_port_viid(lldi->ports[0])) << 8;
+	pr_info("cdev 0x%p,%s, pfvf %u.\n",
+		cdev, lldi->ports[0]->name, cdev->pfvf);
+
 	rc = cxgb4i_ddp_init(cdev);
 	if (rc) {
 		pr_info("t4 0x%p ddp init failed.\n", cdev);
@@ -1516,7 +1522,7 @@ static int t4_uld_rx_handler(void *handle, const __be64 *rsp,
 	if (pgl == NULL) {
 		unsigned int len = 64 - sizeof(struct rsp_ctrl) - 8;
 
-		skb = alloc_cpl(len, 0, GFP_ATOMIC);
+		skb = alloc_wr(len, 0, GFP_ATOMIC);
 		if (!skb)
 			goto nomem;
 		skb_copy_to_linear_data(skb, &rsp[1], len);
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
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index db9d08a..b29e77d 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -195,16 +195,22 @@ EXPORT_SYMBOL_GPL(cxgbi_device_find_by_lldev);
 static struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 							int *port)
 {
+	struct net_device *vdev = NULL;
 	struct cxgbi_device *cdev, *tmp;
 	int i;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
+		vdev = ndev;
 		ndev = vlan_dev_real_dev(ndev);
+		log_debug(1 << CXGBI_DBG_DEV,
+			"vlan dev %s -> %s.\n", vdev->name, ndev->name);
+	}
 
 	mutex_lock(&cdev_mutex);
 	list_for_each_entry_safe(cdev, tmp, &cdev_list, list_head) {
 		for (i = 0; i < cdev->nports; i++) {
 			if (ndev == cdev->ports[i]) {
+				cdev->hbas[i]->vdev = vdev;
 				mutex_unlock(&cdev_mutex);
 				if (port)
 					*port = i;
@@ -218,24 +224,6 @@ static struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 	return NULL;
 }
 
-struct cxgbi_hba *cxgbi_hba_find_by_netdev(struct net_device *dev,
-					struct cxgbi_device *cdev)
-{
-	int i;
-
-	if (dev->priv_flags & IFF_802_1Q_VLAN)
-		dev = vlan_dev_real_dev(dev);
-
-	for (i = 0; i < cdev->nports; i++) {
-		if (cdev->hbas[i]->ndev == dev)
-			return cdev->hbas[i];
-	}
-	log_debug(1 << CXGBI_DBG_DEV,
-		"ndev 0x%p, %s, cdev 0x%p, NO match found.\n",
-		dev, dev->name, cdev);
-	return NULL;
-}
-
 void cxgbi_hbas_remove(struct cxgbi_device *cdev)
 {
 	int i;
@@ -532,12 +520,6 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 			dst->neighbour->dev->name, ndev->name, mtu);
 	}
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
-		ndev = vlan_dev_real_dev(ndev);
-		pr_info("rt dev %s, vlan -> %s.\n",
-			dst->neighbour->dev->name, ndev->name);
-	}
-
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
 	if (!cdev) {
 		pr_info("dst %pI4, %s, NOT cxgbi device.\n",
@@ -561,10 +543,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	csk->dst = dst;
 	csk->daddr.sin_addr.s_addr = daddr->sin_addr.s_addr;
 	csk->daddr.sin_port = daddr->sin_port;
-	if (cdev->hbas[port]->ipv4addr)
-		csk->saddr.sin_addr.s_addr = cdev->hbas[port]->ipv4addr;
-	else
-		csk->saddr.sin_addr.s_addr = rt->rt_src;
+	csk->saddr.sin_addr.s_addr = rt->rt_src;
 
 	return csk;
 
@@ -593,11 +572,11 @@ static void cxgbi_inform_iscsi_conn_closing(struct cxgbi_sock *csk)
 		csk, csk->state, csk->flags, csk->user_data);
 
 	if (csk->state != CTP_ESTABLISHED) {
-		read_lock(&csk->callback_lock);
+		read_lock_bh(&csk->callback_lock);
 		if (csk->user_data)
 			iscsi_conn_failure(csk->user_data,
 					ISCSI_ERR_CONN_FAILED);
-		read_unlock(&csk->callback_lock);
+		read_unlock_bh(&csk->callback_lock);
 	}
 }
 
@@ -1712,12 +1691,10 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 			"csk 0x%p, conn 0x%p, id %d, suspend_rx %lu!\n",
 			csk, conn, conn ? conn->id : 0xFF,
 			conn ? conn->suspend_rx : 0xFF);
-		read_unlock(&csk->callback_lock);
 		return;
 	}
 
 	while (!err) {
-		read_lock(&csk->callback_lock);
 		skb = skb_peek(&csk->receive_queue);
 		if (!skb ||
 		    !(cxgbi_skcb_test_flag(skb, SKCBF_RX_STATUS))) {
@@ -1725,11 +1702,9 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 				log_debug(1 << CXGBI_DBG_PDU_RX,
 					"skb 0x%p, NOT ready 0x%lx.\n",
 					skb, cxgbi_skcb_flags(skb));
-			read_unlock(&csk->callback_lock);
 			break;
 		}
 		__skb_unlink(skb, &csk->receive_queue);
-		read_unlock(&csk->callback_lock);
 
 		read += cxgbi_skcb_rx_pdulen(skb);
 		log_debug(1 << CXGBI_DBG_PDU_RX,
@@ -1739,18 +1714,37 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 
 		if (cxgbi_skcb_test_flag(skb, SKCBF_RX_COALESCED)) {
 			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0)
+			if (err < 0) {
+				pr_err("coalesced bhs, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
 				break;
+			}
 			err = skb_read_pdu_data(conn, skb, skb,
 						err + cdev->skb_rx_extra);
+			if (err < 0) {
+				pr_err("coalesced data, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
+				break;
+			}
 		} else {
 			err = skb_read_pdu_bhs(conn, skb);
-			if (err < 0)
+			if (err < 0) {
+				pr_err("bhs, csk 0x%p, skb 0x%p,%u, "
+					"f 0x%lx, plen %u.\n",
+					csk, skb, skb->len,
+					cxgbi_skcb_flags(skb),
+					cxgbi_skcb_rx_pdulen(skb));
 				break;
+			}
 			if (cxgbi_skcb_test_flag(skb, SKCBF_RX_DATA)) {
 				struct sk_buff *dskb;
 
-				read_lock(&csk->callback_lock);
 				dskb = skb_peek(&csk->receive_queue);
 				if (!dskb) {
 					read_unlock(&csk->callback_lock);
@@ -1759,9 +1753,16 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 					break;
 				}
 				__skb_unlink(dskb, &csk->receive_queue);
-				read_unlock(&csk->callback_lock);
 
 				err = skb_read_pdu_data(conn, skb, dskb, 0);
+				if (err < 0)
+					pr_err("data, csk 0x%p, skb 0x%p,%u, "
+						"f 0x%lx, plen %u, dskb 0x%p,"
+						"%u.\n",
+						csk, skb, skb->len,
+						cxgbi_skcb_flags(dskb),
+						cxgbi_skcb_rx_pdulen(skb),
+						dskb, dskb->len);
 				__kfree_skb(dskb);
 			} else
 				err = skb_read_pdu_data(conn, skb, skb, 0);
@@ -1780,7 +1781,8 @@ void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
 	}
 
 	if (err < 0) {
-		pr_info("csk 0x%p, 0x%p, rx failed %d.\n", csk, conn, err);
+		pr_info("csk 0x%p, 0x%p, rx failed %d, read %u.\n",
+			csk, conn, err, read);
 		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
 	}
 }
@@ -1861,7 +1863,7 @@ int cxgbi_conn_alloc_pdu(struct iscsi_task *task, u8 opcode)
 	struct cxgbi_device *cdev = cconn->chba->cdev;
 	struct iscsi_conn *conn = task->conn;
 	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = task->dd_data + sizeof(*tcp_task);
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct scsi_cmnd *sc = task->sc;
 	int headroom = SKB_TX_ISCSI_PDU_HEADER_MAX;
 
@@ -1916,8 +1918,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 			      unsigned int count)
 {
 	struct iscsi_conn *conn = task->conn;
-	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct sk_buff *skb = tdata->skb;
 	unsigned int datalen = count;
 	int i, padlen = iscsi_padding(count);
@@ -2019,8 +2020,7 @@ int cxgbi_conn_xmit_pdu(struct iscsi_task *task)
 {
 	struct iscsi_tcp_conn *tcp_conn = task->conn->dd_data;
 	struct cxgbi_conn *cconn = tcp_conn->dd_data;
-	struct iscsi_tcp_task *tcp_task = task->dd_data;
-	struct cxgbi_task_data *tdata = tcp_task->dd_data;
+	struct cxgbi_task_data *tdata = iscsi_task_cxgbi_data(task);
 	struct sk_buff *skb = tdata->skb;
 	unsigned int datalen;
 	int err;
@@ -2290,12 +2290,12 @@ int cxgbi_bind_conn(struct iscsi_cls_session *cls_session,
 	/*  calculate the tag idx bits needed for this conn based on cmds_max */
 	cconn->task_idx_bits = (__ilog2_u32(conn->session->cmds_max - 1)) + 1;
 
-	write_lock(&csk->callback_lock);
+	write_lock_bh(&csk->callback_lock);
 	csk->user_data = conn;
 	cconn->chba = cep->chba;
 	cconn->cep = cep;
 	cep->cconn = cconn;
-	write_unlock(&csk->callback_lock);
+	write_unlock_bh(&csk->callback_lock);
 
 	cxgbi_conn_max_xmit_dlength(conn);
 	cxgbi_conn_max_recv_dlength(conn);
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 40551f3..c57d59d 100644
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
@@ -410,16 +400,15 @@ static inline unsigned int cxgbi_sock_compute_wscale(unsigned int win)
 	return wscale;
 }
 
-static inline struct sk_buff *alloc_cpl(int cpl_len, int dlen, gfp_t gfp)
+static inline struct sk_buff *alloc_wr(int wrlen, int dlen, gfp_t gfp)
 {
-	int wrlen = roundup(cpl_len, 16);
 	struct sk_buff *skb = alloc_skb(wrlen + dlen, gfp);
 
 	if (skb) {
 		__skb_put(skb, wrlen);
 		memset(skb->head, 0, wrlen + dlen);
 	} else
-		pr_info("alloc cpl skb %u+%u, OOM.\n", cpl_len, dlen);
+		pr_info("alloc cpl wr skb %u+%u, OOM.\n", wrlen, dlen);
 	return skb;
 }
 
@@ -501,6 +490,7 @@ void cxgbi_sock_free_cpl_skbs(struct cxgbi_sock *);
 
 struct cxgbi_hba {
 	struct net_device *ndev;
+	struct net_device *vdev;	/* vlan dev */
 	struct Scsi_Host *shost;
 	struct cxgbi_device *cdev;
 	__be32 ipv4addr;
@@ -593,6 +583,8 @@ struct cxgbi_task_data {
 	unsigned int count;
 	unsigned int sgoffset;
 };
+#define iscsi_task_cxgbi_data(task) \
+	((task)->dd_data + sizeof(struct iscsi_tcp_task))
 
 static inline int cxgbi_is_ddp_tag(struct cxgbi_tag_format *tformat, u32 tag)
 {

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
