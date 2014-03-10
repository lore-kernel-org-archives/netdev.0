From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 20/31] iw_cxgb4: adjust tcp snd/rcv window based on link speed
Date: Mon, 10 Mar 2014 22:38:17 +0530
Message-ID: <1394471308-4304-21-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11865 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753941AbaCJRSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:18:08 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

40G devices need a bigger windows, so default 40G devices to snd 512K
rcv 1024K.

Fixed a bug that shows up with recv window sizes that exceed the size of
the RCV_BUFSIZ field in opt0 (>= 1024K :).  If the recv window exceeds
this, then we specify the max possible in opt0, add add the rest in via
a RX_DATA_ACK credits.

Added module option named adjust_win, defaulted to 1, that allows
disabling the 40G window bump.  This allows a user to specify the exact
default window sizes via module options snd_win and rcv_win.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c            | 63 +++++++++++++++++++++++++++--
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h      |  2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |  1 +
 3 files changed, 62 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index c839303..f6891b8 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -134,6 +134,11 @@ static int snd_win = 128 * 1024;
 module_param(snd_win, int, 0644);
 MODULE_PARM_DESC(snd_win, "TCP send window in bytes (default=128KB)");
 
+static int adjust_win = 1;
+module_param(adjust_win, int, 0644);
+MODULE_PARM_DESC(adjust_win,
+		 "Adjust TCP window based on link speed (default=1)");
+
 static struct workqueue_struct *workq;
 
 static struct sk_buff_head rxq;
@@ -465,7 +470,7 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 	flowc->mnemval[5].mnemonic = FW_FLOWC_MNEM_RCVNXT;
 	flowc->mnemval[5].val = cpu_to_be32(ep->rcv_seq);
 	flowc->mnemval[6].mnemonic = FW_FLOWC_MNEM_SNDBUF;
-	flowc->mnemval[6].val = cpu_to_be32(snd_win);
+	flowc->mnemval[6].val = cpu_to_be32(ep->snd_win);
 	flowc->mnemval[7].mnemonic = FW_FLOWC_MNEM_MSS;
 	flowc->mnemval[7].val = cpu_to_be32(ep->emss);
 	/* Pad WR to 16 byte boundary */
@@ -547,6 +552,7 @@ static int send_connect(struct c4iw_ep *ep)
 	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
 	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
 	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
+	int win;
 
 	wrlen = (ep->com.remote_addr.ss_family == AF_INET) ?
 			roundup(sizev4, 16) :
@@ -564,6 +570,15 @@ static int send_connect(struct c4iw_ep *ep)
 
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
 	wscale = compute_wscale(rcv_win);
+
+	/*
+	 * Specify the largest window that will fit in opt0. The
+	 * remainder will be specified in the rx_data_ack.
+	 */
+	win = ep->rcv_win >> 10;
+	if (win > RCV_BUFSIZ_MASK)
+		win = RCV_BUFSIZ_MASK;
+
 	opt0 = (nocong ? NO_CONG(1) : 0) |
 	       KEEP_ALIVE(1) |
 	       DELACK(1) |
@@ -574,7 +589,7 @@ static int send_connect(struct c4iw_ep *ep)
 	       SMAC_SEL(ep->smac_idx) |
 	       DSCP(ep->tos) |
 	       ULP_MODE(ULP_MODE_TCPDDP) |
-	       RCV_BUFSIZ(rcv_win>>10);
+	       RCV_BUFSIZ(win);
 	opt2 = RX_CHANNEL(0) |
 	       CCTRL_ECN(enable_ecn) |
 	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
@@ -1134,6 +1149,14 @@ static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 		return 0;
 	}
 
+	/*
+	 * If we couldn't specify the entire rcv window at connection setup
+	 * due to the limit in the number of bits in the RCV_BUFSIZ field,
+	 * then add the overage in to the credits returned.
+	 */
+	if (ep->rcv_win > RCV_BUFSIZ_MASK * 1024)
+		credits += ep->rcv_win - RCV_BUFSIZ_MASK * 1024;
+
 	req = (struct cpl_rx_data_ack *) skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	INIT_TP_WR(req, ep->hwtid);
@@ -1592,6 +1615,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	unsigned int mtu_idx;
 	int wscale;
 	struct sockaddr_in *sin;
+	int win;
 
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(skb, sizeof(*req));
@@ -1616,6 +1640,15 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	req->tcb.rcv_adv = htons(1);
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
 	wscale = compute_wscale(rcv_win);
+
+	/*
+	 * Specify the largest window that will fit in opt0. The
+	 * remainder will be specified in the rx_data_ack.
+	 */
+	win = ep->rcv_win >> 10;
+	if (win > RCV_BUFSIZ_MASK)
+		win = RCV_BUFSIZ_MASK;
+
 	req->tcb.opt0 = (__force __be64) (TCAM_BYPASS(1) |
 		(nocong ? NO_CONG(1) : 0) |
 		KEEP_ALIVE(1) |
@@ -1627,7 +1660,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 		SMAC_SEL(ep->smac_idx) |
 		DSCP(ep->tos) |
 		ULP_MODE(ULP_MODE_TCPDDP) |
-		RCV_BUFSIZ(rcv_win >> 10));
+		RCV_BUFSIZ(win));
 	req->tcb.opt2 = (__force __be32) (PACE(1) |
 		TX_QUEUE(ep->com.dev->rdev.lldi.tx_modq[ep->tx_chan]) |
 		RX_CHANNEL(0) |
@@ -1664,6 +1697,17 @@ static int is_neg_adv(unsigned int status)
 	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
 }
 
+static void set_tcp_window(struct c4iw_ep *ep, struct port_info *pi)
+{
+	ep->snd_win = snd_win;
+	ep->rcv_win = rcv_win;
+	if (adjust_win && pi->link_cfg.speed == 40000) {
+		ep->snd_win *= 4;
+		ep->rcv_win *= 4;
+	}
+	PDBG("%s snd_win %d rcv_win %d\n", __func__, ep->snd_win, ep->rcv_win);
+}
+
 #define ACT_OPEN_RETRY_COUNT 2
 
 static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
@@ -1712,6 +1756,7 @@ static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 		ep->ctrlq_idx = cxgb4_port_idx(pdev);
 		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
 			cxgb4_port_idx(pdev) * step];
+		set_tcp_window(ep, (struct port_info *)netdev_priv(pdev));
 		dev_put(pdev);
 	} else {
 		pdev = get_real_dev(n->dev);
@@ -1730,6 +1775,7 @@ static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 			cdev->rdev.lldi.nchan;
 		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
 			cxgb4_port_idx(n->dev) * step];
+		set_tcp_window(ep, (struct port_info *)netdev_priv(pdev));
 
 		if (clear_mpa_v1) {
 			ep->retry_with_mpa_v1 = 0;
@@ -1960,6 +2006,7 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	u64 opt0;
 	u32 opt2;
 	int wscale;
+	int win;
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	BUG_ON(skb_cloned(skb));
@@ -1967,6 +2014,14 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	skb_get(skb);
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
 	wscale = compute_wscale(rcv_win);
+
+	/*
+	 * Specify the largest window that will fit in opt0. The
+	 * remainder will be specified in the rx_data_ack.
+	 */
+	win = ep->rcv_win >> 10;
+	if (win > RCV_BUFSIZ_MASK)
+		win = RCV_BUFSIZ_MASK;
 	opt0 = (nocong ? NO_CONG(1) : 0) |
 	       KEEP_ALIVE(1) |
 	       DELACK(1) |
@@ -1977,7 +2032,7 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	       SMAC_SEL(ep->smac_idx) |
 	       DSCP(ep->tos >> 2) |
 	       ULP_MODE(ULP_MODE_TCPDDP) |
-	       RCV_BUFSIZ(rcv_win>>10);
+	       RCV_BUFSIZ(win);
 	opt2 = RX_CHANNEL(0) |
 	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
 
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index b75f8f5..3b6cea0 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -804,6 +804,8 @@ struct c4iw_ep {
 	u8 retry_with_mpa_v1;
 	u8 tried_with_mpa_v1;
 	unsigned int retry_count;
+	int snd_win;
+	int rcv_win;
 };
 
 static inline struct c4iw_ep *to_ep(struct iw_cm_id *cm_id)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index f2738c7..330bc14 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -227,6 +227,7 @@ struct cpl_pass_open_req {
 #define DELACK(x)     ((x) << 5)
 #define ULP_MODE(x)   ((x) << 8)
 #define RCV_BUFSIZ(x) ((x) << 12)
+#define RCV_BUFSIZ_MASK 0x3FFU
 #define DSCP(x)       ((x) << 22)
 #define SMAC_SEL(x)   ((u64)(x) << 28)
 #define L2T_IDX(x)    ((u64)(x) << 36)
-- 
1.8.4
