From: divy@chelsio.com
Subject: [PATCH 2.6.21 3/3] cxgb3 - missing CPL hanler and register setting.
Date: Mon, 09 Apr 2007 20:10:33 -0700
Message-ID: <20070410031032.12914.94210.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030316AbXDJDLJ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove specific CPL handler. 
Add missing CPL handler.
Add missing register setting when the interface is brought up.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c    |    2 ++
 drivers/net/cxgb3/cxgb3_offload.c |   14 ++------------
 drivers/net/cxgb3/regs.h          |    6 ++++++
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index d6eb982..67b4b21 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -770,6 +770,8 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		t3_write_reg(adap, A_ULPRX_TDDP_PSZ, V_HPZ0(PAGE_SHIFT - 12));
+		
 		err = setup_sge_qsets(adap);
 		if (err)
 			goto out;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index eed7a48..4864924 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -743,17 +743,6 @@ static int do_act_establish(struct t3cde
 	}
 }
 
-static int do_set_tcb_rpl(struct t3cdev *dev, struct sk_buff *skb)
-{
-	struct cpl_set_tcb_rpl *rpl = cplhdr(skb);
-
-	if (rpl->status != CPL_ERR_NONE)
-		printk(KERN_ERR
-		       "Unexpected SET_TCB_RPL status %u for tid %u\n",
-		       rpl->status, GET_TID(rpl));
-	return CPL_RET_BUF_DONE;
-}
-
 static int do_trace(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_trace_pkt *p = cplhdr(skb);
@@ -1215,7 +1204,8 @@ void __init cxgb3_offload_init(void)
 	t3_register_cpl_handler(CPL_CLOSE_CON_RPL, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_ABORT_REQ_RSS, do_abort_req_rss);
 	t3_register_cpl_handler(CPL_ACT_ESTABLISH, do_act_establish);
-	t3_register_cpl_handler(CPL_SET_TCB_RPL, do_set_tcb_rpl);
+	t3_register_cpl_handler(CPL_SET_TCB_RPL, do_hwtid_rpl);
+	t3_register_cpl_handler(CPL_GET_TCB_RPL, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_RDMA_TERMINATE, do_term);
 	t3_register_cpl_handler(CPL_RDMA_EC_STATUS, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_TRACE_PKT, do_trace);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index f8be41c..e5a5534 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1234,9 +1234,15 @@
 
 #define A_ULPRX_ISCSI_TAGMASK 0x514
 
+#define S_HPZ0    0
+#define M_HPZ0    0xf
+#define V_HPZ0(x) ((x) << S_HPZ0)
+#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+
 #define A_ULPRX_TDDP_LLIMIT 0x51c
 
 #define A_ULPRX_TDDP_ULIMIT 0x520
+#define A_ULPRX_TDDP_PSZ 0x528
 
 #define A_ULPRX_STAG_LLIMIT 0x52c
 
