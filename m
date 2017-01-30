From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 6/6] gtp: consolidate gtp socket rx path
Date: Mon, 30 Jan 2017 17:32:00 +0100
Message-ID: <20170130163200.17070-7-aschultz@tpip.net>
References: <20170130163200.17070-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:33326 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750887AbdA3QeX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:34:23 -0500
In-Reply-To: <20170130163200.17070-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add network device to gtp context in preparation for splitting
the TEID from the network device.

Use this to rework the socker rx path. Move the common RX part
of v0 and v1 into a helper. Also move the final rx part into
that helper as well.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 92 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 47 insertions(+), 45 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index ff00597..9c31e83 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -58,6 +58,7 @@ struct pdp_ctx {
 	struct in_addr		ms_addr_ip4;
 	struct in_addr		sgsn_addr_ip4;
 
+	struct net_device       *dev;
 	struct sock		*sk;
 
 	atomic_t		tx_seq;
@@ -179,9 +180,42 @@ static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 	return false;
 }
 
+static int gtp_rx(struct sk_buff *skb, struct pdp_ctx *pctx, unsigned int hdrlen)
+{
+	struct pcpu_sw_netstats *stats;
+
+	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+		pr_debug("No PDP ctx for this MS\n");
+		return 1;
+	}
+
+	/* Get rid of the GTP + UDP headers. */
+	if (iptunnel_pull_header(skb, hdrlen, skb->protocol,
+				 !net_eq(sock_net(pctx->sk), dev_net(pctx->dev))))
+		return -1;
+
+	pr_debug("forwarding packet from GGSN to uplink\n");
+
+	/* Now that the UDP and the GTP header have been removed, set up the
+	 * new network header. This is required by the upper layer to
+	 * calculate the transport header.
+	 */
+	skb_reset_network_header(skb);
+
+	skb->dev = pctx->dev;
+
+	stats = this_cpu_ptr(pctx->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+	return 0;
+}
+
 /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
-static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
-			       bool xnet)
+static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp0_header);
@@ -205,17 +239,10 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
-		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return 1;
-	}
-
-	/* Get rid of the GTP + UDP headers. */
-	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
+	return gtp_rx(skb, pctx, hdrlen);
 }
 
-static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
-				bool xnet)
+static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp1_header);
@@ -254,13 +281,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
-		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return 1;
-	}
-
-	/* Get rid of the GTP + UDP headers. */
-	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
+	return gtp_rx(skb, pctx, hdrlen);
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -294,10 +315,8 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
  */
 static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct pcpu_sw_netstats *stats;
 	struct gtp_dev *gtp;
-	bool xnet;
-	int ret;
+	int ret = 0;
 
 	gtp = rcu_dereference_sk_user_data(sk);
 	if (!gtp)
@@ -305,16 +324,14 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
 
-	xnet = !net_eq(sock_net(sk), dev_net(gtp->dev));
-
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
 		netdev_dbg(gtp->dev, "received GTP0 packet\n");
-		ret = gtp0_udp_encap_recv(gtp, skb, xnet);
+		ret = gtp0_udp_encap_recv(gtp, skb);
 		break;
 	case UDP_ENCAP_GTP1U:
 		netdev_dbg(gtp->dev, "received GTP1U packet\n");
-		ret = gtp1u_udp_encap_recv(gtp, skb, xnet);
+		ret = gtp1u_udp_encap_recv(gtp, skb);
 		break;
 	default:
 		ret = -1; /* Shouldn't happen. */
@@ -323,33 +340,17 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	switch (ret) {
 	case 1:
 		netdev_dbg(gtp->dev, "pass up to the process\n");
-		return 1;
+		break;
 	case 0:
-		netdev_dbg(gtp->dev, "forwarding packet from GGSN to uplink\n");
 		break;
 	case -1:
 		netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
 		kfree_skb(skb);
-		return 0;
+		ret = 0;
+		break;
 	}
 
-	/* Now that the UDP and the GTP header have been removed, set up the
-	 * new network header. This is required by the upper layer to
-	 * calculate the transport header.
-	 */
-	skb_reset_network_header(skb);
-
-	skb->dev = gtp->dev;
-
-	stats = this_cpu_ptr(gtp->dev->tstats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->syncp);
-
-	netif_rx(skb);
-
-	return 0;
+	return ret;
 }
 
 static int gtp_dev_init(struct net_device *dev)
@@ -930,6 +931,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 
 	sock_hold(sk);
 	pctx->sk = sk;
+	pctx->dev = gtp->dev;
 	ipv4_pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
-- 
2.10.2
