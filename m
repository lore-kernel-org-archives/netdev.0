From: Roland Dreier <rdreier@cisco.com>
Subject: Re: i386 allmodconfig, current mainline
Date: Mon, 09 Aug 2010 21:52:40 -0700
Message-ID: <ada62zjyspz.fsf@roland-alpha.cisco.com>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	Phillip Lougher <phillip@lougher.demon.co.uk>,
	Faisal Latif <faisal.latif@intel.com>,
	Chien Tung <chien.tin.tung@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Samuel Ortiz <samuel.ortiz@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, x86@kernel.org,
	linux-rdma@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:38057 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab0HJEwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 00:52:44 -0400
In-Reply-To: <20100809164346.6e30cf8c.akpm@linux-foundation.org> (Andrew
	Morton's message of "Mon, 9 Aug 2010 16:43:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will queue up fixes as below:

 > drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_alloc_fast_reg_page_list':
 > drivers/infiniband/hw/nes/nes_verbs.c:477: warning: cast to pointer from integer of different size
 > drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_post_send':
 > drivers/infiniband/hw/nes/nes_verbs.c:3486: warning: cast to pointer from integer of different size
 > drivers/infiniband/hw/nes/nes_verbs.c:3486: warning: cast to pointer from integer of different size

--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -476,9 +476,9 @@ static struct ib_fast_reg_page_list *nes_alloc_fast_reg_page_list(
 	}
 	nes_debug(NES_DBG_MR, "nes_alloc_fast_reg_pbl: nes_frpl = %p, "
 		  "ibfrpl = %p, ibfrpl.page_list = %p, pbl.kva = %p, "
-		  "pbl.paddr= %p\n", pnesfrpl, &pnesfrpl->ibfrpl,
+		  "pbl.paddr = %llx\n", pnesfrpl, &pnesfrpl->ibfrpl,
 		  pnesfrpl->ibfrpl.page_list, pnesfrpl->nes_wqe_pbl.kva,
-		  (void *)pnesfrpl->nes_wqe_pbl.paddr);
+		  (unsigned long long) pnesfrpl->nes_wqe_pbl.paddr);
 
 	return pifrpl;
 }
@@ -3483,13 +3483,13 @@ static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
 			for (i = 0; i < ib_wr->wr.fast_reg.page_list_len; i++)
 				dst_page_list[i] = cpu_to_le64(src_page_list[i]);
 
-			nes_debug(NES_DBG_IW_TX, "SQ_FMR: iova_start: %p, "
-				  "length: %d, rkey: %0x, pgl_paddr: %p, "
+			nes_debug(NES_DBG_IW_TX, "SQ_FMR: iova_start: %llx, "
+				  "length: %d, rkey: %0x, pgl_paddr: %llx, "
 				  "page_list_len: %u, wqe_misc: %x\n",
-				  (void *)ib_wr->wr.fast_reg.iova_start,
+				  (unsigned long long) ib_wr->wr.fast_reg.iova_start,
 				  ib_wr->wr.fast_reg.length,
 				  ib_wr->wr.fast_reg.rkey,
-				  (void *)pnesfrpl->nes_wqe_pbl.paddr,
+				  (unsigned long long) pnesfrpl->nes_wqe_pbl.paddr,
 				  ib_wr->wr.fast_reg.page_list_len,
 				  wqe_misc);
 			break;

 > drivers/infiniband/hw/cxgb4/cq.c: In function 'destroy_cq':
 > drivers/infiniband/hw/cxgb4/cq.c:58: warning: cast from pointer to integer of different size
 > drivers/infiniband/hw/cxgb4/cq.c: In function 'create_cq':
 > drivers/infiniband/hw/cxgb4/cq.c:135: warning: cast from pointer to integer of different size

There were a few more here, will queue:

--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -2323,7 +2323,7 @@ static int fw6_msg(struct c4iw_dev *dev, struct sk_buff *skb)
 	switch (rpl->type) {
 	case 1:
 		ret = (int)((be64_to_cpu(rpl->data[0]) >> 8) & 0xff);
-		wr_waitp = (__force struct c4iw_wr_wait *)rpl->data[1];
+		wr_waitp = (struct c4iw_wr_wait *)(__force unsigned long) rpl->data[1];
 		PDBG("%s wr_waitp %p ret %u\n", __func__, wr_waitp, ret);
 		if (wr_waitp) {
 			wr_waitp->ret = ret;
diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index b3daf39..af684fc 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -55,7 +55,7 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 			V_FW_RI_RES_WR_NRES(1) |
 			FW_WR_COMPL(1));
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
-	res_wr->cookie = (u64)&wr_wait;
+	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
 	res->u.cq.restype = FW_RI_RES_TYPE_CQ;
 	res->u.cq.op = FW_RI_RES_OP_RESET;
@@ -132,7 +132,7 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 			V_FW_RI_RES_WR_NRES(1) |
 			FW_WR_COMPL(1));
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
-	res_wr->cookie = (u64)&wr_wait;
+	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
 	res->u.cq.restype = FW_RI_RES_TYPE_CQ;
 	res->u.cq.op = FW_RI_RES_OP_WRITE;
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -71,7 +71,7 @@ static int write_adapter_mem(struct c4iw_rdev *rdev, u32 addr, u32 len,
 		if (i == (num_wqe-1)) {
 			req->wr.wr_hi = cpu_to_be32(FW_WR_OP(FW_ULPTX_WR) |
 						    FW_WR_COMPL(1));
-			req->wr.wr_lo = (__force __be64)&wr_wait;
+			req->wr.wr_lo = (__force __be64)(unsigned long) &wr_wait;
 		} else
 			req->wr.wr_hi = cpu_to_be32(FW_WR_OP(FW_ULPTX_WR));
 		req->wr.wr_mid = cpu_to_be32(
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -144,7 +144,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 			V_FW_RI_RES_WR_NRES(2) |
 			FW_WR_COMPL(1));
 	res_wr->len16_pkd = cpu_to_be32(DIV_ROUND_UP(wr_len, 16));
-	res_wr->cookie = (u64)&wr_wait;
+	res_wr->cookie = (unsigned long) &wr_wait;
 	res = res_wr->res;
 	res->u.sqrq.restype = FW_RI_RES_TYPE_SQ;
 	res->u.sqrq.op = FW_RI_RES_OP_WRITE;
@@ -985,7 +985,7 @@ static int rdma_fini(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 	wqe->flowid_len16 = cpu_to_be32(
 		FW_WR_FLOWID(ep->hwtid) |
 		FW_WR_LEN16(DIV_ROUND_UP(sizeof *wqe, 16)));
-	wqe->cookie = (u64)&wr_wait;
+	wqe->cookie = (unsigned long) &wr_wait;
 
 	wqe->u.fini.type = FW_RI_TYPE_FINI;
 	c4iw_init_wr_wait(&wr_wait);
@@ -1060,7 +1060,7 @@ static int rdma_init(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 		FW_WR_FLOWID(qhp->ep->hwtid) |
 		FW_WR_LEN16(DIV_ROUND_UP(sizeof *wqe, 16)));
 
-	wqe->cookie = (u64)&wr_wait;
+	wqe->cookie = (unsigned long) &wr_wait;
 
 	wqe->u.init.type = FW_RI_TYPE_INIT;
 	wqe->u.init.mpareqbit_p2ptype =


-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
