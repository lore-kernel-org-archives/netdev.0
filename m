From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 05/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_best_mtu()
Date: Tue, 13 Sep 2016 21:24:00 +0530
Message-ID: <8b5ebd894ec2d5705d76966a77c53845a2a27287.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add cxgb_best_mtu() in libcxgb_cm.h to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 32 +++++++----------------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 18 +++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 20 +++-----------
 3 files changed, 30 insertions(+), 40 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index b35fdc0..c3c678f 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -677,20 +677,6 @@ static int send_abort(struct c4iw_ep *ep)
 	return c4iw_l2t_send(&ep->com.dev->rdev, req_skb, ep->l2t);
 }
 
-static void best_mtu(const unsigned short *mtus, unsigned short mtu,
-		     unsigned int *idx, int use_ts, int ipv6)
-{
-	unsigned short hdr_size = (ipv6 ?
-				   sizeof(struct ipv6hdr) :
-				   sizeof(struct iphdr)) +
-				  sizeof(struct tcphdr) +
-				  (use_ts ?
-				   round_up(TCPOLEN_TIMESTAMP, 4) : 0);
-	unsigned short data_size = mtu - hdr_size;
-
-	cxgb4_best_aligned_mtu(mtus, hdr_size, data_size, 8, idx);
-}
-
 static int send_connect(struct c4iw_ep *ep)
 {
 	struct cpl_act_open_req *req = NULL;
@@ -750,9 +736,9 @@ static int send_connect(struct c4iw_ep *ep)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, ep->ctrlq_idx);
 
-	best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
-		 enable_tcp_timestamps,
-		 (AF_INET == ep->com.remote_addr.ss_family) ? 0 : 1);
+	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
+		      enable_tcp_timestamps,
+		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
 	wscale = compute_wscale(rcv_win);
 
 	/*
@@ -1930,9 +1916,9 @@ static int send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 			htons(FW_OFLD_CONNECTION_WR_CPLRXDATAACK_F);
 	req->tcb.tx_max = (__force __be32) jiffies;
 	req->tcb.rcv_adv = htons(1);
-	best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
-		 enable_tcp_timestamps,
-		 (AF_INET == ep->com.remote_addr.ss_family) ? 0 : 1);
+	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
+		      enable_tcp_timestamps,
+		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
 	wscale = compute_wscale(rcv_win);
 
 	/*
@@ -2374,9 +2360,9 @@ static int accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_PASS_ACCEPT_RPL,
 						    ep->hwtid));
 
-	best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
-		 enable_tcp_timestamps && req->tcpopt.tstamp,
-		 (AF_INET == ep->com.remote_addr.ss_family) ? 0 : 1);
+	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
+		      enable_tcp_timestamps && req->tcpopt.tstamp,
+		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
 	wscale = compute_wscale(rcv_win);
 
 	/*
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 57fcc98..7fb4feb 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -33,6 +33,9 @@
 #ifndef __LIBCXGB_CM_H__
 #define __LIBCXGB_CM_H__
 
+
+#include <net/tcp.h>
+
 #include <cxgb4.h>
 #include <t4_msg.h>
 
@@ -56,4 +59,19 @@ static inline bool cxgb_is_neg_adv(unsigned int status)
 	       status == CPL_ERR_PERSIST_NEG_ADVICE ||
 	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
 }
+
+static inline void
+cxgb_best_mtu(const unsigned short *mtus, unsigned short mtu,
+	      unsigned int *idx, int use_ts, int ipv6)
+{
+	unsigned short hdr_size = (ipv6 ?
+				   sizeof(struct ipv6hdr) :
+				   sizeof(struct iphdr)) +
+				  sizeof(struct tcphdr) +
+				  (use_ts ?
+				   round_up(TCPOLEN_TIMESTAMP, 4) : 0);
+	unsigned short data_size = mtu - hdr_size;
+
+	cxgb4_best_aligned_mtu(mtus, hdr_size, data_size, 8, idx);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index c46bdd5..b09c09b 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -997,20 +997,6 @@ cxgbit_l2t_send(struct cxgbit_device *cdev, struct sk_buff *skb,
 	return ret < 0 ? ret : 0;
 }
 
-static void
-cxgbit_best_mtu(const unsigned short *mtus, unsigned short mtu,
-		unsigned int *idx, int use_ts, int ipv6)
-{
-	unsigned short hdr_size = (ipv6 ? sizeof(struct ipv6hdr) :
-				   sizeof(struct iphdr)) +
-				   sizeof(struct tcphdr) +
-				   (use_ts ? round_up(TCPOLEN_TIMESTAMP,
-				    4) : 0);
-	unsigned short data_size = mtu - hdr_size;
-
-	cxgb4_best_aligned_mtu(mtus, hdr_size, data_size, 8, idx);
-}
-
 static void cxgbit_send_rx_credits(struct cxgbit_sock *csk, struct sk_buff *skb)
 {
 	if (csk->com.state != CSK_STATE_ESTABLISHED) {
@@ -1135,9 +1121,9 @@ cxgbit_pass_accept_rpl(struct cxgbit_sock *csk, struct cpl_pass_accept_req *req)
 	INIT_TP_WR(rpl5, csk->tid);
 	OPCODE_TID(rpl5) = cpu_to_be32(MK_OPCODE_TID(CPL_PASS_ACCEPT_RPL,
 						     csk->tid));
-	cxgbit_best_mtu(csk->com.cdev->lldi.mtus, csk->mtu, &mtu_idx,
-			req->tcpopt.tstamp,
-			(csk->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
+	cxgb_best_mtu(csk->com.cdev->lldi.mtus, csk->mtu, &mtu_idx,
+		      req->tcpopt.tstamp,
+		      (csk->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
 	wscale = cxgbit_compute_wscale(csk->rcv_win);
 	/*
 	 * Specify the largest window that will fit in opt0. The
-- 
2.0.2
