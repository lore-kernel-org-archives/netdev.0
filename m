From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 4/7] gtp: consolidate gtp socket rx path
Date: Thu,  9 Mar 2017 17:42:59 +0100
Message-ID: <20170309164302.13550-5-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:39167 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932528AbdCIQnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:25 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add network device to gtp context in preparation for splitting
the TEID from the network device.

Use this to rework the socker rx path. Move the common RX part
of v0 and v1 into a helper. Also move the final rx part into
that helper as well.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 80 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 44 insertions(+), 36 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 74018eb..0c6707a 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -58,6 +58,8 @@ struct pdp_ctx {
 	struct in_addr		ms_addr_ip4;
 	struct in_addr		sgsn_addr_ip4;
 
+	struct net_device       *dev;
+
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
 };
@@ -175,6 +177,40 @@ static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 	return false;
 }
 
+static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen,
+		  bool xnet)
+{
+	struct pcpu_sw_netstats *stats;
+
+	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
+		netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
+		return 1;
+	}
+
+	/* Get rid of the GTP + UDP headers. */
+	if (iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet))
+		return -1;
+
+	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
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
 static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 			       bool xnet)
@@ -201,13 +237,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
-		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return 1;
-	}
-
-	/* Get rid of the GTP + UDP headers. */
-	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
+	return gtp_rx(pctx, skb, hdrlen, xnet);
 }
 
 static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
@@ -250,13 +280,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
-		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		return 1;
-	}
-
-	/* Get rid of the GTP + UDP headers. */
-	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
+	return gtp_rx(pctx, skb, hdrlen, xnet);
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -290,10 +314,9 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
  */
 static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct pcpu_sw_netstats *stats;
 	struct gtp_dev *gtp;
+	int ret = 0;
 	bool xnet;
-	int ret;
 
 	gtp = rcu_dereference_sk_user_data(sk);
 	if (!gtp)
@@ -319,33 +342,17 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -951,6 +958,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	if (pctx == NULL)
 		return -ENOMEM;
 
+	pctx->dev = gtp->dev;
 	ipv4_pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
-- 
2.10.2
