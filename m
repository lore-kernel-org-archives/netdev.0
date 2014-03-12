From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCHv6 net-next 20/31] iw_cxgb4: adjust tcp snd/rcv window based on link speed
Date: Wed, 12 Mar 2014 16:29:27 -0500
Message-ID: <008d01cf3e3a$257edc90$707c95b0$@opengridcomputing.com>
References: <1394639446-6504-21-git-send-email-hariprasad@chelsio.com>	<20140312.155017.118512327402563943.davem@davemloft.net>	<008801cf3e2e$d8679b00$8936d100$@opengridcomputing.com> <20140312.162348.2225551653125401290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: "'David Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140312.162348.2225551653125401290.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >> You can just use the TCP settings the kernel already provides for
> >> the real TCP stack.
> >
> > Do you mean use sysctl_tcp_*mem, sysctl_tcp_timestamps, sysctl_tcp_window_scaling,
etc?
> > I'll look into this.
> 
> And the socket memory limits, which we use to compute default window
> sizes.

How's this look (compile-tested only)?  Note I had to export some of the tcp limits.

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index e2fe4a2..ff95fa3 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -81,19 +81,6 @@ int c4iw_max_read_depth = 8;
 module_param(c4iw_max_read_depth, int, 0644);
 MODULE_PARM_DESC(c4iw_max_read_depth, "Per-connection max ORD/IRD (default=8)");
 
-static int enable_tcp_timestamps;
-module_param(enable_tcp_timestamps, int, 0644);
-MODULE_PARM_DESC(enable_tcp_timestamps, "Enable tcp timestamps (default=0)");
-
-static int enable_tcp_sack;
-module_param(enable_tcp_sack, int, 0644);
-MODULE_PARM_DESC(enable_tcp_sack, "Enable tcp SACK (default=0)");
-
-static int enable_tcp_window_scaling = 1;
-module_param(enable_tcp_window_scaling, int, 0644);
-MODULE_PARM_DESC(enable_tcp_window_scaling,
-		 "Enable tcp window scaling (default=1)");
-
 int c4iw_debug;
 module_param(c4iw_debug, int, 0644);
 MODULE_PARM_DESC(c4iw_debug, "Enable debug logging (default=0)");
@@ -126,19 +113,6 @@ static int crc_enabled = 1;
 module_param(crc_enabled, int, 0644);
 MODULE_PARM_DESC(crc_enabled, "Enable MPA CRC (default(1)=enabled)");
 
-static int rcv_win = 256 * 1024;
-module_param(rcv_win, int, 0644);
-MODULE_PARM_DESC(rcv_win, "TCP receive window in bytes (default=256KB)");
-
-static int snd_win = 128 * 1024;
-module_param(snd_win, int, 0644);
-MODULE_PARM_DESC(snd_win, "TCP send window in bytes (default=128KB)");
-
-static int adjust_win = 1;
-module_param(adjust_win, int, 0644);
-MODULE_PARM_DESC(adjust_win,
-		 "Adjust TCP window based on link speed (default=1)");
-
 static struct workqueue_struct *workq;
 
 static struct sk_buff_head rxq;
@@ -572,7 +546,7 @@ static int send_connect(struct c4iw_ep *ep)
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, ep->ctrlq_idx);
 
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
-	wscale = compute_wscale(rcv_win);
+	wscale = compute_wscale(ep->rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
@@ -596,11 +570,11 @@ static int send_connect(struct c4iw_ep *ep)
 	opt2 = RX_CHANNEL(0) |
 	       CCTRL_ECN(enable_ecn) |
 	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
-	if (enable_tcp_timestamps)
+	if (sysctl_tcp_timestamps)
 		opt2 |= TSTAMPS_EN(1);
-	if (enable_tcp_sack)
+	if (sysctl_tcp_sack)
 		opt2 |= SACK_EN(1);
-	if (wscale && enable_tcp_window_scaling)
+	if (wscale && sysctl_tcp_window_scaling)
 		opt2 |= WND_SCALE_EN(1);
 	t4_set_arp_err_handler(skb, NULL, act_open_req_arp_failure);
 
@@ -1652,7 +1626,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int
atid)
 	req->tcb.tx_max = (__force __be32) jiffies;
 	req->tcb.rcv_adv = htons(1);
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
-	wscale = compute_wscale(rcv_win);
+	wscale = compute_wscale(ep->rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
@@ -1679,11 +1653,11 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int
atid)
 		RX_CHANNEL(0) |
 		CCTRL_ECN(enable_ecn) |
 		RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid));
-	if (enable_tcp_timestamps)
+	if (sysctl_tcp_timestamps)
 		req->tcb.opt2 |= (__force __be32) TSTAMPS_EN(1);
-	if (enable_tcp_sack)
+	if (sysctl_tcp_sack)
 		req->tcb.opt2 |= (__force __be32) SACK_EN(1);
-	if (wscale && enable_tcp_window_scaling)
+	if (wscale && sysctl_tcp_window_scaling)
 		req->tcb.opt2 |= (__force __be32) WND_SCALE_EN(1);
 	req->tcb.opt0 = cpu_to_be64((__force u64) req->tcb.opt0);
 	req->tcb.opt2 = cpu_to_be32((__force u32) req->tcb.opt2);
@@ -1712,11 +1686,14 @@ static int is_neg_adv(unsigned int status)
 
 static void set_tcp_window(struct c4iw_ep *ep, struct port_info *pi)
 {
+	u32 snd_win = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
+	u32 rcv_win = max_t(u32, sysctl_tcp_wmem[2], sysctl_wmem_max);
+
 	ep->snd_win = snd_win;
 	ep->rcv_win = rcv_win;
-	if (adjust_win && pi->link_cfg.speed == 40000) {
-		ep->snd_win *= 4;
-		ep->rcv_win *= 4;
+	if (pi->link_cfg.speed == 40000) {
+		ep->snd_win = min_t(u32, ep->snd_win * 4, snd_win);
+		ep->rcv_win = min_t(u32, ep->rcv_win * 4, rcv_win);
 	}
 	PDBG("%s snd_win %d rcv_win %d\n", __func__, ep->snd_win, ep->rcv_win);
 }
@@ -2026,7 +2003,7 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	skb_trim(skb, sizeof(*rpl));
 	skb_get(skb);
 	cxgb4_best_mtu(ep->com.dev->rdev.lldi.mtus, ep->mtu, &mtu_idx);
-	wscale = compute_wscale(rcv_win);
+	wscale = compute_wscale(ep->rcv_win);
 
 	/*
 	 * Specify the largest window that will fit in opt0. The
@@ -2049,11 +2026,11 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	opt2 = RX_CHANNEL(0) |
 	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
 
-	if (enable_tcp_timestamps && req->tcpopt.tstamp)
+	if (sysctl_tcp_timestamps && req->tcpopt.tstamp)
 		opt2 |= TSTAMPS_EN(1);
-	if (enable_tcp_sack && req->tcpopt.sack)
+	if (sysctl_tcp_sack && req->tcpopt.sack)
 		opt2 |= SACK_EN(1);
-	if (wscale && enable_tcp_window_scaling)
+	if (wscale && sysctl_tcp_window_scaling)
 		opt2 |= WND_SCALE_EN(1);
 	if (enable_ecn) {
 		const struct tcphdr *tcph;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 227cba7..65ed4e8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -76,8 +76,11 @@
 #include <net/netdma.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
+EXPORT_SYMBOL(sysctl_tcp_timestamps);
 int sysctl_tcp_window_scaling __read_mostly = 1;
+EXPORT_SYMBOL(sysctl_tcp_window_scaling);
 int sysctl_tcp_sack __read_mostly = 1;
+EXPORT_SYMBOL(sysctl_tcp_sack);
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
 EXPORT_SYMBOL(sysctl_tcp_reordering);

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
