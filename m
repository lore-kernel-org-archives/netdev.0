From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 07/12] gtp: udp recv clean up
Date: Tue, 26 Sep 2017 21:57:58 -0700
Message-ID: <20170927045803.2477-8-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:49101 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161066AbdI0E65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:57 -0400
Received: by mail-pg0-f41.google.com with SMTP id v23so7135258pgc.5
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:56 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create separate UDP receive functions for GTP version 0 and version 1.
Set encap_rcv appropriately when configuring a socket.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 100 ++++++++++++++++++++++++++----------------------------
 1 file changed, 49 insertions(+), 51 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 00e5ea5cb935..a6e2e0a1f424 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -225,14 +225,20 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 	return 0;
 }
 
-/* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
-static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+/* UDP encapsulation receive handler for GTPv0-U . See net/ipv4/udp.c.
+ * Return codes: 0: success, <0: error, >0: pass up to userspace UDP socket.
+ */
+static int gtp0_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct gtp_dev *gtp = rcu_dereference_sk_user_data(sk);
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp0_header);
 	struct gtp0_header *gtp0;
 	struct pdp_ctx *pctx;
 
+	if (!gtp)
+		goto pass;
+
 	if (!pskb_may_pull(skb, hdrlen))
 		goto drop;
 
@@ -244,26 +250,41 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	if (gtp0->type != GTP_TPDU)
 		goto pass;
 
+	netdev_dbg(gtp->dev, "received GTP0 packet\n");
+
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
 		goto pass;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+	if (!gtp_rx(pctx, skb, hdrlen, gtp->role)) {
+		/* Successfully received */
+		return 0;
+	}
+
 drop:
-	return -1;
+	kfree_skb(skb);
+	return 0;
+
 pass:
 	return 1;
 }
 
-static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+/* UDP encapsulation receive handler for GTPv0-U . See net/ipv4/udp.c.
+ * Return codes: 0: success, <0: error, >0: pass up to userspace UDP socket.
+ */
+static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct gtp_dev *gtp = rcu_dereference_sk_user_data(sk);
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp1_header);
 	struct gtp1_header *gtp1;
 	struct pdp_ctx *pctx;
 
+	if (!gtp)
+		goto pass;
+
 	if (!pskb_may_pull(skb, hdrlen))
 		goto drop;
 
@@ -275,6 +296,8 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	if (gtp1->type != GTP_TPDU)
 		goto pass;
 
+	netdev_dbg(gtp->dev, "received GTP1 packet\n");
+
 	/* From 29.060: "This field shall be present if and only if any one or
 	 * more of the S, PN and E flags are set.".
 	 *
@@ -296,9 +319,15 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 		goto drop;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+	if (!gtp_rx(pctx, skb, hdrlen, gtp->role)) {
+		/* Successfully received */
+		return 0;
+	}
+
 drop:
-	return -1;
+	kfree_skb(skb);
+	return 0;
+
 pass:
 	return 1;
 }
@@ -329,49 +358,6 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
 	gtp_encap_disable_sock(gtp->sk1u);
 }
 
-/* UDP encapsulation receive handler. See net/ipv4/udp.c.
- * Return codes: 0: success, <0: error, >0: pass up to userspace UDP socket.
- */
-static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
-{
-	struct gtp_dev *gtp;
-	int ret = 0;
-
-	gtp = rcu_dereference_sk_user_data(sk);
-	if (!gtp)
-		return 1;
-
-	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
-
-	switch (udp_sk(sk)->encap_type) {
-	case UDP_ENCAP_GTP0:
-		netdev_dbg(gtp->dev, "received GTP0 packet\n");
-		ret = gtp0_udp_encap_recv(gtp, skb);
-		break;
-	case UDP_ENCAP_GTP1U:
-		netdev_dbg(gtp->dev, "received GTP1U packet\n");
-		ret = gtp1u_udp_encap_recv(gtp, skb);
-		break;
-	default:
-		ret = -1; /* Shouldn't happen. */
-	}
-
-	switch (ret) {
-	case 1:
-		netdev_dbg(gtp->dev, "pass up to the process\n");
-		break;
-	case 0:
-		break;
-	case -1:
-		netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
-		kfree_skb(skb);
-		ret = 0;
-		break;
-	}
-
-	return ret;
-}
-
 static int gtp_dev_init(struct net_device *dev)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
@@ -824,9 +810,21 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 	sk = sock->sk;
 	sock_hold(sk);
 
+	switch (type) {
+	case UDP_ENCAP_GTP0:
+		tuncfg.encap_rcv = gtp0_udp_encap_recv;
+		break;
+	case UDP_ENCAP_GTP1U:
+		tuncfg.encap_rcv = gtp1u_udp_encap_recv;
+		break;
+	default:
+		pr_debug("Unknown encap type %u\n", type);
+		sk = ERR_PTR(-EINVAL);
+		goto out_sock;
+	}
+
 	tuncfg.sk_user_data = gtp;
 	tuncfg.encap_type = type;
-	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
 
 	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
-- 
2.11.0
