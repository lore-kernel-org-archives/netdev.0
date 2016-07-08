From: Varun Prakash <varun@chelsio.com>
Subject: [net-next 4/6] cxgb3i: add iSCSI DDP support
Date: Fri,  8 Jul 2016 23:03:57 +0530
Message-ID: <b8815417e5558ee153025c39a4d19ac2e4434bf2.1467998293.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add iSCSI DDP support in cxgb3i driver
using common iSCSI DDP Page Pod Manager.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c | 119 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 118 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index fda0234..d9092c0 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -1076,6 +1076,70 @@ static inline void ulp_mem_io_set_hdr(struct sk_buff *skb, unsigned int addr)
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_BYPASS));
 	req->cmd_lock_addr = htonl(V_ULP_MEMIO_ADDR(addr >> 5) |
 				   V_ULPTX_CMD(ULP_MEM_WRITE));
+	req->len = htonl(V_ULP_MEMIO_DATA_LEN(IPPOD_SIZE >> 5) |
+			 V_ULPTX_NFLITS((IPPOD_SIZE >> 3) + 1));
+}
+
+static struct cxgbi_ppm *cdev2ppm(struct cxgbi_device *cdev)
+{
+	return ((struct t3cdev *)cdev->lldev)->ulp_iscsi;
+}
+
+static int ddp_set_map(struct cxgbi_ppm *ppm, struct cxgbi_sock *csk,
+		       struct cxgbi_task_tag_info *ttinfo)
+{
+	unsigned int idx = ttinfo->idx;
+	unsigned int npods = ttinfo->npods;
+	struct scatterlist *sg = ttinfo->sgl;
+	struct cxgbi_pagepod *ppod;
+	struct ulp_mem_io *req;
+	unsigned int sg_off;
+	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ppm->llimit;
+	int i;
+
+	for (i = 0; i < npods; i++, idx++, pm_addr += IPPOD_SIZE) {
+		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
+					       IPPOD_SIZE, 0, GFP_ATOMIC);
+
+		if (!skb)
+			return -ENOMEM;
+		ulp_mem_io_set_hdr(skb, pm_addr);
+		req = (struct ulp_mem_io *)skb->head;
+		ppod = (struct cxgbi_pagepod *)(req + 1);
+		sg_off = i * PPOD_PAGES_MAX;
+		cxgbi_ddp_set_one_ppod(ppod, ttinfo, &sg,
+				       &sg_off);
+		skb->priority = CPL_PRIORITY_CONTROL;
+		cxgb3_ofld_send(ppm->lldev, skb);
+	}
+	return 0;
+}
+
+static void ddp_clear_map(struct cxgbi_device *cdev, struct cxgbi_ppm *ppm,
+			  struct cxgbi_task_tag_info *ttinfo)
+{
+	unsigned int idx = ttinfo->idx;
+	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ppm->llimit;
+	unsigned int npods = ttinfo->npods;
+	int i;
+
+	log_debug(1 << CXGBI_DBG_DDP,
+		  "cdev 0x%p, clear idx %u, npods %u.\n",
+		  cdev, idx, npods);
+
+	for (i = 0; i < npods; i++, idx++, pm_addr += IPPOD_SIZE) {
+		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
+					       IPPOD_SIZE, 0, GFP_ATOMIC);
+
+		if (!skb) {
+			pr_err("cdev 0x%p, clear ddp, %u,%d/%u, skb OOM.\n",
+			       cdev, idx, i, npods);
+			continue;
+		}
+		ulp_mem_io_set_hdr(skb, pm_addr);
+		skb->priority = CPL_PRIORITY_CONTROL;
+		cxgb3_ofld_send(ppm->lldev, skb);
+	}
 }
 
 static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk,
@@ -1144,14 +1208,67 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 }
 
 /**
- * ddp_init - initialize the cxgb3 adapter's ddp resource
+ * cxgb3i_ddp_init - initialize the cxgb3 adapter's ddp resource
  * @cdev: cxgb3i adapter
  * initialize the ddp pagepod manager for a given adapter
  */
 static int cxgb3i_ddp_init(struct cxgbi_device *cdev)
 {
+	struct t3cdev *tdev = (struct t3cdev *)cdev->lldev;
+	struct net_device *ndev = cdev->ports[0];
+	struct cxgbi_tag_format tformat;
+	unsigned int ppmax, tagmask;
+	struct ulp_iscsi_info uinfo;
+	int i, err;
+
+	err = tdev->ctl(tdev, ULP_ISCSI_GET_PARAMS, &uinfo);
+	if (err < 0) {
+		pr_err("%s, failed to get iscsi param %d.\n",
+		       ndev->name, err);
+		return err;
+	}
+	if (uinfo.llimit >= uinfo.ulimit) {
+		pr_warn("T3 %s, iscsi NOT enabled %u ~ %u!\n",
+			ndev->name, uinfo.llimit, uinfo.ulimit);
+		return -EACCES;
+	}
+
+	ppmax = (uinfo.ulimit - uinfo.llimit + 1) >> PPOD_SIZE_SHIFT;
+
+	pr_info("T3 %s: 0x%x~0x%x, 0x%x, tagmask 0x%x -> 0x%x.\n",
+		ndev->name, uinfo.llimit, uinfo.ulimit, ppmax, uinfo.tagmask,
+		tagmask);
+
+	memset(&tformat, 0, sizeof(struct cxgbi_tag_format));
+	for (i = 0; i < 4; i++)
+		tformat.pgsz_order[i] = uinfo.pgsz_factor[i];
+	cxgbi_tagmask_check(tagmask, &tformat);
+
+	cxgbi_ddp_ppm_setup(&tdev->ulp_iscsi, cdev, &tformat, ppmax,
+			    uinfo.llimit, uinfo.llimit, 0);
+	if (!(cdev->flags & CXGBI_FLAG_DDP_OFF)) {
+		uinfo.tagmask = tagmask;
+		uinfo.ulimit = uinfo.llimit + (ppmax << PPOD_SIZE_SHIFT);
+
+		err = tdev->ctl(tdev, ULP_ISCSI_SET_PARAMS, &uinfo);
+		if (err < 0) {
+			pr_err("T3 %s fail to set iscsi param %d.\n",
+			       ndev->name, err);
+			cdev->flags |= CXGBI_FLAG_DDP_OFF;
+		}
+		err = 0;
+	}
+
 	cdev->csk_ddp_setup_digest = ddp_setup_conn_digest;
 	cdev->csk_ddp_setup_pgidx = ddp_setup_conn_pgidx;
+	cdev->csk_ddp_set_map = ddp_set_map;
+	cdev->csk_ddp_clear_map = ddp_clear_map;
+	cdev->cdev2ppm = cdev2ppm;
+	cdev->tx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
+				  uinfo.max_txsz - ISCSI_PDU_NONPAYLOAD_LEN);
+	cdev->rx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
+				  uinfo.max_rxsz - ISCSI_PDU_NONPAYLOAD_LEN);
+
 	return 0;
 }
 
-- 
2.0.2
