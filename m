From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 06/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_compute_wscale()
Date: Tue, 13 Sep 2016 21:24:01 +0530
Message-ID: <2389edd129f73f4c7c22bcd45359d1fe2c69b989.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:35985 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759157AbcIMP5G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:57:06 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_compute_wscale() in libcxgb_cm.h to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 12 ++++++------
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h            |  9 ---------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h |  9 +++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 11 +----------
 4 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index c3c678f..b9d77df 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -689,7 +689,7 @@ static int send_connect(struct c4iw_ep *ep)
 	u64 opt0;
 	u32 opt2;
 	unsigned int mtu_idx;
-	int wscale;
+	u32 wscale;
 	int win, sizev4, sizev6, wrlen;
 	struct sockaddr_in *la = (struct sockaddr_in *)
 				 &ep->com.local_addr;
@@ -739,7 +739,7 @@ static int send_connect(struct c4iw_ep *ep)
 	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
 		      enable_tcp_timestamps,
 		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
-	wscale = compute_wscale(rcv_win);
+	wscale = cxgb_compute_wscale(rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
@@ -1891,7 +1891,7 @@ static int send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	struct sk_buff *skb;
 	struct fw_ofld_connection_wr *req;
 	unsigned int mtu_idx;
-	int wscale;
+	u32 wscale;
 	struct sockaddr_in *sin;
 	int win;
 
@@ -1919,7 +1919,7 @@ static int send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
 		      enable_tcp_timestamps,
 		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
-	wscale = compute_wscale(rcv_win);
+	wscale = cxgb_compute_wscale(rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
@@ -2339,7 +2339,7 @@ static int accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	unsigned int mtu_idx;
 	u64 opt0;
 	u32 opt2;
-	int wscale;
+	u32 wscale;
 	struct cpl_t5_pass_accept_rpl *rpl5 = NULL;
 	int win;
 	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
@@ -2363,7 +2363,7 @@ static int accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	cxgb_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx,
 		      enable_tcp_timestamps && req->tcpopt.tstamp,
 		      (ep->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
-	wscale = compute_wscale(rcv_win);
+	wscale = cxgb_compute_wscale(rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index aa47e0a..6a9bef1f 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -881,15 +881,6 @@ static inline struct c4iw_listen_ep *to_listen_ep(struct iw_cm_id *cm_id)
 	return cm_id->provider_data;
 }
 
-static inline int compute_wscale(int win)
-{
-	int wscale = 0;
-
-	while (wscale < 14 && (65535<<wscale) < win)
-		wscale++;
-	return wscale;
-}
-
 static inline int ocqp_supported(const struct cxgb4_lld_info *infop)
 {
 #if defined(__i386__) || defined(__x86_64__) || defined(CONFIG_PPC64)
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 7fb4feb..ecf3baa 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -74,4 +74,13 @@ cxgb_best_mtu(const unsigned short *mtus, unsigned short mtu,
 
 	cxgb4_best_aligned_mtu(mtus, hdr_size, data_size, 8, idx);
 }
+
+static inline u32 cxgb_compute_wscale(u32 win)
+{
+	u32 wscale = 0;
+
+	while (wscale < 14 && (65535 << wscale) < win)
+		wscale++;
+	return wscale;
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index b09c09b..cd29c91 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -1085,15 +1085,6 @@ out:
 	return -ENOMEM;
 }
 
-static u32 cxgbit_compute_wscale(u32 win)
-{
-	u32 wscale = 0;
-
-	while (wscale < 14 && (65535 << wscale) < win)
-		wscale++;
-	return wscale;
-}
-
 static void
 cxgbit_pass_accept_rpl(struct cxgbit_sock *csk, struct cpl_pass_accept_req *req)
 {
@@ -1124,7 +1115,7 @@ cxgbit_pass_accept_rpl(struct cxgbit_sock *csk, struct cpl_pass_accept_req *req)
 	cxgb_best_mtu(csk->com.cdev->lldi.mtus, csk->mtu, &mtu_idx,
 		      req->tcpopt.tstamp,
 		      (csk->com.remote_addr.ss_family == AF_INET) ? 0 : 1);
-	wscale = cxgbit_compute_wscale(csk->rcv_win);
+	wscale = cxgb_compute_wscale(csk->rcv_win);
 	/*
 	 * Specify the largest window that will fit in opt0. The
 	 * remainder will be specified in the rx_data_ack.
-- 
2.0.2
