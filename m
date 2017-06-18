From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 1/3] net: introduce __skb_put_[zero, data, u8]
Date: Sun, 18 Jun 2017 22:48:17 +0800
Message-ID: <1497797297-25387-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:33214 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752888AbdFROsx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 10:48:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

follow Johannes Berg, semantic patch file as below,
@@
identifier p, p2;
expression len;
expression skb;
type t, t2;
@@
(
-p = __skb_put(skb, len);
+p = __skb_put_zero(skb, len);
|
-p = (t)__skb_put(skb, len);
+p = __skb_put_zero(skb, len);
)
... when != p
(
p2 = (t2)p;
-memset(p2, 0, len);
|
-memset(p, 0, len);
)

@@
identifier p;
expression len;
expression skb;
type t;
@@
(
-t p = __skb_put(skb, len);
+t p = __skb_put_zero(skb, len);
)
... when != p
(
-memset(p, 0, len);
)

@@
type t, t2;
identifier p, p2;
expression skb;
@@
t *p;
...
(
-p = __skb_put(skb, sizeof(t));
+p = __skb_put_zero(skb, sizeof(t));
|
-p = (t *)__skb_put(skb, sizeof(t));
+p = __skb_put_zero(skb, sizeof(t));
)
... when != p
(
p2 = (t2)p;
-memset(p2, 0, sizeof(*p));
|
-memset(p, 0, sizeof(*p));
)

@@
expression skb, len;
@@
-memset(__skb_put(skb, len), 0, len);
+__skb_put_zero(skb, len);

@@
expression skb, len, data;
@@
-memcpy(__skb_put(skb, len), data, len);
+__skb_put_data(skb, data, len);

@@
expression SKB, C, S;
typedef u8;
identifier fn = {__skb_put};
fresh identifier fn2 = fn ## "_u8";
@@
- *(u8 *)fn(SKB, S) = C;
+ fn2(SKB, C);

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/crypto/chelsio/chcr_algo.c                | 15 +++++----------
 drivers/infiniband/hw/cxgb4/cm.c                  |  6 ++----
 drivers/infiniband/hw/cxgb4/cq.c                  |  6 ++----
 drivers/infiniband/hw/cxgb4/mem.c                 |  6 ++----
 drivers/infiniband/hw/cxgb4/qp.c                  |  3 +--
 drivers/isdn/gigaset/asyncdata.c                  |  4 ++--
 drivers/isdn/gigaset/isocdata.c                   |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c   | 12 ++++--------
 drivers/net/ethernet/chelsio/cxgb3/sge.c          |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c |  3 +--
 drivers/net/usb/int51x1.c                         |  2 +-
 drivers/staging/octeon/ethernet-tx.c              |  3 +--
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 12 ++++--------
 include/linux/skbuff.h                            | 22 ++++++++++++++++++++++
 lib/test_bpf.c                                    |  2 +-
 net/802/garp.c                                    |  2 +-
 net/bluetooth/bnep/core.c                         | 15 ++++++---------
 net/bluetooth/bnep/netdev.c                       | 12 ++++++------
 net/bridge/br_stp_bpdu.c                          |  2 +-
 19 files changed, 64 insertions(+), 67 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 92185ab..b75b8be 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -604,8 +604,7 @@ static struct sk_buff
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
-	chcr_req = __skb_put(skb, transhdr_len);
-	memset(chcr_req, 0, transhdr_len);
+	chcr_req = __skb_put_zero(skb, transhdr_len);
 	chcr_req->sec_cpl.op_ivinsrtofst =
 		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2, 1);
 
@@ -881,8 +880,7 @@ static struct sk_buff *create_hash_wr(struct ahash_request *req,
 		return skb;
 
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
-	chcr_req = __skb_put(skb, transhdr_len);
-	memset(chcr_req, 0, transhdr_len);
+	chcr_req = __skb_put_zero(skb, transhdr_len);
 
 	chcr_req->sec_cpl.op_ivinsrtofst =
 		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2, 0);
@@ -1447,8 +1445,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
 	/* Write WR */
-	chcr_req = __skb_put(skb, transhdr_len);
-	memset(chcr_req, 0, transhdr_len);
+	chcr_req = __skb_put_zero(skb, transhdr_len);
 
 	stop_offset = (op_type == CHCR_ENCRYPT_OP) ? 0 : authsize;
 
@@ -1779,8 +1776,7 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
-	chcr_req = __skb_put(skb, transhdr_len);
-	memset(chcr_req, 0, transhdr_len);
+	chcr_req = __skb_put_zero(skb, transhdr_len);
 
 	fill_sec_cpl_for_aead(&chcr_req->sec_cpl, dst_size, req, op_type, ctx);
 
@@ -1892,8 +1888,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	/* NIC driver is going to write the sge hdr. */
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
-	chcr_req = __skb_put(skb, transhdr_len);
-	memset(chcr_req, 0, transhdr_len);
+	chcr_req = __skb_put_zero(skb, transhdr_len);
 
 	if (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106)
 		req->assoclen -= 8;
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 76fb394..e49b34c 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1900,8 +1900,7 @@ static int send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	int win;
 
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
-	req = __skb_put(skb, sizeof(*req));
-	memset(req, 0, sizeof(*req));
+	req = __skb_put_zero(skb, sizeof(*req));
 	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR));
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.filter = cpu_to_be32(cxgb4_select_ntuple(
@@ -3803,8 +3802,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	req_skb = alloc_skb(sizeof(struct fw_ofld_connection_wr), GFP_KERNEL);
 	if (!req_skb)
 		return;
-	req = __skb_put(req_skb, sizeof(*req));
-	memset(req, 0, sizeof(*req));
+	req = __skb_put_zero(req_skb, sizeof(*req));
 	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL_F);
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.version_cpl = htonl(FW_OFLD_CONNECTION_WR_CPL_F);
diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 394cfe2..e16fcaf 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -44,8 +44,7 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	wr_len = sizeof *res_wr + sizeof *res;
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = __skb_put(skb, wr_len);
-	memset(res_wr, 0, wr_len);
+	res_wr = __skb_put_zero(skb, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
 			FW_RI_RES_WR_NRES_V(1) |
@@ -114,8 +113,7 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = __skb_put(skb, wr_len);
-	memset(res_wr, 0, wr_len);
+	res_wr = __skb_put_zero(skb, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
 			FW_RI_RES_WR_NRES_V(1) |
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index ca992e4..5332f06 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -81,8 +81,7 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	req = __skb_put(skb, wr_len);
-	memset(req, 0, wr_len);
+	req = __skb_put_zero(skb, wr_len);
 	INIT_ULPTX_WR(req, wr_len, 0, 0);
 	req->wr.wr_hi = cpu_to_be32(FW_WR_OP_V(FW_ULPTX_WR) |
 			(wait ? FW_WR_COMPL_F : 0));
@@ -142,8 +141,7 @@ static int _c4iw_write_mem_inline(struct c4iw_rdev *rdev, u32 addr, u32 len,
 		}
 		set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-		req = __skb_put(skb, wr_len);
-		memset(req, 0, wr_len);
+		req = __skb_put_zero(skb, wr_len);
 		INIT_ULPTX_WR(req, wr_len, 0, 0);
 
 		if (i == (num_wqe-1)) {
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index b23a0b0..bfc7759 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -293,8 +293,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = __skb_put(skb, wr_len);
-	memset(res_wr, 0, wr_len);
+	res_wr = __skb_put_zero(skb, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
 			FW_RI_RES_WR_NRES_V(2) |
diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 4caecdc..bc20855 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -264,7 +264,7 @@ static unsigned hdlc_loop(unsigned numbytes, struct inbuf_t *inbuf)
 				/* skip remainder of packet */
 				bcs->rx_skb = skb = NULL;
 			} else {
-				*(u8 *)__skb_put(skb, 1) = c;
+				__skb_put_u8(skb, c);
 				fcs = crc_ccitt_byte(fcs, c);
 			}
 		}
@@ -315,7 +315,7 @@ static unsigned iraw_loop(unsigned numbytes, struct inbuf_t *inbuf)
 
 		/* regular data byte: append to current skb */
 		inputstate |= INS_have_data;
-		*(u8 *)__skb_put(skb, 1) = bitrev8(c);
+		__skb_put_u8(skb, bitrev8(c));
 	}
 
 	/* pass data up */
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 74e2506..97e00118 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -511,7 +511,7 @@ static inline void hdlc_putbyte(unsigned char c, struct bc_state *bcs)
 		bcs->rx_skb = NULL;
 		return;
 	}
-	*(u8 *)__skb_put(bcs->rx_skb, 1) = c;
+	__skb_put_u8(bcs->rx_skb, c);
 }
 
 /* hdlc_flush
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index e1a50c8..0bc6a4f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -471,8 +471,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = __skb_put(skb, sizeof(*req));
-		memset(req, 0, sizeof(*req));
+		req = __skb_put_zero(skb, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, i));
 		req->mtu_idx = NMTUS - 1;
@@ -495,8 +494,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = __skb_put(skb, sizeof(*req));
-		memset(req, 0, sizeof(*req));
+		req = __skb_put_zero(skb, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ, i));
 		req->params = htonl(V_L2T_W_IDX(i));
@@ -518,8 +516,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = __skb_put(skb, sizeof(*req));
-		memset(req, 0, sizeof(*req));
+		req = __skb_put_zero(skb, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RTE_WRITE_REQ, i));
 		req->l2t_idx = htonl(V_L2T_W_IDX(i));
@@ -538,8 +535,7 @@ static int init_tp_parity(struct adapter *adap)
 	if (!skb)
 		goto alloc_skb_fail;
 
-	greq = __skb_put(skb, sizeof(*greq));
-	memset(greq, 0, sizeof(*greq));
+	greq = __skb_put_zero(skb, sizeof(*greq));
 	greq->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(greq) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, 0));
 	greq->mask = cpu_to_be64(1);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 1b9d154..e2d3426 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2282,7 +2282,7 @@ static int process_responses(struct adapter *adap, struct sge_qset *qs,
 			if (!skb)
 				goto no_mem;
 
-			memcpy(__skb_put(skb, AN_PKT_SIZE), r, AN_PKT_SIZE);
+			__skb_put_data(skb, r, AN_PKT_SIZE);
 			skb->data[0] = CPL_ASYNC_NOTIF;
 			rss_hi = htonl(CPL_ASYNC_NOTIF << 24);
 			q->async_notif++;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index a0fab65..45b5853 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -231,8 +231,7 @@ int set_filter_wr(struct adapter *adapter, int fidx)
 		}
 	}
 
-	fwr = __skb_put(skb, sizeof(*fwr));
-	memset(fwr, 0, sizeof(*fwr));
+	fwr = __skb_put_zero(skb, sizeof(*fwr));
 
 	/* It would be nice to put most of the following in t4_hw.c but most
 	 * of the work is translating the cxgbtool ch_filter_specification
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index be63a82..ae2b256 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -110,7 +110,7 @@ static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
 	*len = cpu_to_le16(pack_len);
 
 	if(need_tail)
-		memset(__skb_put(skb, need_tail), 0, need_tail);
+		__skb_put_zero(skb, need_tail);
 
 	return skb;
 }
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index ff4119e..31f3502 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -251,8 +251,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 
 				if ((skb_tail_pointer(skb) + add_bytes) <=
 				    skb_end_pointer(skb))
-					memset(__skb_put(skb, add_bytes), 0,
-					       add_bytes);
+					__skb_put_zero(skb, add_bytes);
 			}
 		}
 	}
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 15cd1e3..e583dd8 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -1085,8 +1085,7 @@ cxgbit_pass_accept_rpl(struct cxgbit_sock *csk, struct cpl_pass_accept_req *req)
 		return;
 	}
 
-	rpl5 = __skb_put(skb, len);
-	memset(rpl5, 0, len);
+	rpl5 = __skb_put_zero(skb, len);
 
 	INIT_TP_WR(rpl5, csk->tid);
 	OPCODE_TID(rpl5) = cpu_to_be32(MK_OPCODE_TID(CPL_PASS_ACCEPT_RPL,
@@ -1367,8 +1366,7 @@ u32 cxgbit_send_tx_flowc_wr(struct cxgbit_sock *csk)
 	flowclen16 = cxgbit_tx_flowc_wr_credits(csk, &nparams, &flowclen);
 
 	skb = __skb_dequeue(&csk->skbq);
-	flowc = __skb_put(skb, flowclen);
-	memset(flowc, 0, flowclen);
+	flowc = __skb_put_zero(skb, flowclen);
 
 	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP_V(FW_FLOWC_WR) |
 					   FW_FLOWC_WR_NPARAMS_V(nparams));
@@ -1439,8 +1437,7 @@ int cxgbit_setup_conn_digest(struct cxgbit_sock *csk)
 		return -ENOMEM;
 
 	/*  set up ulp submode */
-	req = __skb_put(skb, len);
-	memset(req, 0, len);
+	req = __skb_put_zero(skb, len);
 
 	INIT_TP_WR(req, csk->tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, csk->tid));
@@ -1476,8 +1473,7 @@ int cxgbit_setup_conn_pgidx(struct cxgbit_sock *csk, u32 pg_idx)
 	if (!skb)
 		return -ENOMEM;
 
-	req = __skb_put(skb, len);
-	memset(req, 0, len);
+	req = __skb_put_zero(skb, len);
 
 	INIT_TP_WR(req, csk->tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, csk->tid));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 852feacf..a17e235 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1904,6 +1904,28 @@ static inline void *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
+static inline void *__skb_put_zero(struct sk_buff *skb, unsigned int len)
+{
+	void *tmp = __skb_put(skb, len);
+
+	memset(tmp, 0, len);
+	return tmp;
+}
+
+static inline void *__skb_put_data(struct sk_buff *skb, const void *data,
+				   unsigned int len)
+{
+	void *tmp = __skb_put(skb, len);
+
+	memcpy(tmp, data, len);
+	return tmp;
+}
+
+static inline void __skb_put_u8(struct sk_buff *skb, u8 val)
+{
+	*(u8 *)__skb_put(skb, 1) = val;
+}
+
 static inline void *skb_put_zero(struct sk_buff *skb, unsigned int len)
 {
 	void *tmp = skb_put(skb, len);
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index c871e0e..d9d5a41 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -5717,7 +5717,7 @@ static struct sk_buff *populate_skb(char *buf, int size)
 	if (!skb)
 		return NULL;
 
-	memcpy(__skb_put(skb, size), buf, size);
+	__skb_put_data(skb, buf, size);
 
 	/* Initialize a fake skb with test pattern. */
 	skb_reset_mac_header(skb);
diff --git a/net/802/garp.c b/net/802/garp.c
index a9a2665..2dac647 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -232,7 +232,7 @@ static int garp_pdu_append_end_mark(struct garp_applicant *app)
 {
 	if (skb_tailroom(app->pdu) < sizeof(u8))
 		return -1;
-	*(u8 *)__skb_put(app->pdu, sizeof(u8)) = GARP_END_MARK;
+	__skb_put_u8(app->pdu, GARP_END_MARK);
 	return 0;
 }
 
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index fbf251f..9a40013 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -374,25 +374,22 @@ static int bnep_rx_frame(struct bnep_session *s, struct sk_buff *skb)
 	/* Decompress header and construct ether frame */
 	switch (type & BNEP_TYPE_MASK) {
 	case BNEP_COMPRESSED:
-		memcpy(__skb_put(nskb, ETH_HLEN), &s->eh, ETH_HLEN);
+		__skb_put_data(nskb, &s->eh, ETH_HLEN);
 		break;
 
 	case BNEP_COMPRESSED_SRC_ONLY:
-		memcpy(__skb_put(nskb, ETH_ALEN), s->eh.h_dest, ETH_ALEN);
-		memcpy(__skb_put(nskb, ETH_ALEN), skb_mac_header(skb), ETH_ALEN);
+		__skb_put_data(nskb, s->eh.h_dest, ETH_ALEN);
+		__skb_put_data(nskb, skb_mac_header(skb), ETH_ALEN);
 		put_unaligned(s->eh.h_proto, (__be16 *) __skb_put(nskb, 2));
 		break;
 
 	case BNEP_COMPRESSED_DST_ONLY:
-		memcpy(__skb_put(nskb, ETH_ALEN), skb_mac_header(skb),
-								ETH_ALEN);
-		memcpy(__skb_put(nskb, ETH_ALEN + 2), s->eh.h_source,
-								ETH_ALEN + 2);
+		__skb_put_data(nskb, skb_mac_header(skb), ETH_ALEN);
+		__skb_put_data(nskb, s->eh.h_source, ETH_ALEN + 2);
 		break;
 
 	case BNEP_GENERAL:
-		memcpy(__skb_put(nskb, ETH_ALEN * 2), skb_mac_header(skb),
-								ETH_ALEN * 2);
+		__skb_put_data(nskb, skb_mac_header(skb), ETH_ALEN * 2);
 		put_unaligned(s->eh.h_proto, (__be16 *) __skb_put(nskb, 2));
 		break;
 	}
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 2b875ed..1d4d7d4 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -75,16 +75,16 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 		u8 start[ETH_ALEN] = { 0x01 };
 
 		/* Request all addresses */
-		memcpy(__skb_put(skb, ETH_ALEN), start, ETH_ALEN);
-		memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
+		__skb_put_data(skb, start, ETH_ALEN);
+		__skb_put_data(skb, dev->broadcast, ETH_ALEN);
 		r->len = htons(ETH_ALEN * 2);
 	} else {
 		struct netdev_hw_addr *ha;
 		int i, len = skb->len;
 
 		if (dev->flags & IFF_BROADCAST) {
-			memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
-			memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
+			__skb_put_data(skb, dev->broadcast, ETH_ALEN);
+			__skb_put_data(skb, dev->broadcast, ETH_ALEN);
 		}
 
 		/* FIXME: We should group addresses here. */
@@ -93,8 +93,8 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			if (i == BNEP_MAX_MULTICAST_FILTERS)
 				break;
-			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
-			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
+			__skb_put_data(skb, ha->addr, ETH_ALEN);
+			__skb_put_data(skb, ha->addr, ETH_ALEN);
 
 			i++;
 		}
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 5881fbc..1b75d6b 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -50,7 +50,7 @@ static void br_send_bpdu(struct net_bridge_port *p,
 	skb->priority = TC_PRIO_CONTROL;
 
 	skb_reserve(skb, LLC_RESERVE);
-	memcpy(__skb_put(skb, length), data, length);
+	__skb_put_data(skb, data, length);
 
 	llc_pdu_header_init(skb, LLC_PDU_TYPE_U, LLC_SAP_BSPAN,
 			    LLC_SAP_BSPAN, LLC_PDU_CMD);
-- 
2.7.4
