From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 04/14] gtp: udp recv clean up
Date: Mon, 18 Sep 2017 17:38:54 -0700
Message-ID: <20170919003904.5124-5-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:53059 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbdISAjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:42 -0400
Received: by mail-pf0-f176.google.com with SMTP id p87so1103621pfj.9
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:42 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create separate UDP receive functions for GTP version 0 and version 1.
Set encap_rcv appropriately when configuring a socket. Also, convert to
using gro_cells.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 130 +++++++++++++++++++++++++++++-------------------------
 1 file changed, 71 insertions(+), 59 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 95df3bcebbb2..1de2ea6217ea 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -80,6 +80,8 @@ struct gtp_dev {
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
+
+	struct gro_cells	gro_cells;
 };
 
 static unsigned int gtp_net_id __read_mostly;
@@ -217,55 +219,83 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&gtp->gro_cells, skb);
+
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
-		return -1;
+		goto drop;
 
 	gtp0 = (struct gtp0_header *)(skb->data + sizeof(struct udphdr));
 
 	if ((gtp0->flags >> 5) != GTP_V0)
-		return 1;
+		goto pass;
 
 	if (gtp0->type != GTP_TPDU)
-		return 1;
+		goto pass;
+
+	netdev_dbg(gtp->dev, "received GTP0 packet\n");
 
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return 1;
+		goto pass;
+	}
+
+	if (!gtp_rx(pctx, skb, hdrlen, gtp->role)) {
+		/* Successfully received */
+		return 0;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+drop:
+	kfree_skb(skb);
+	return 0;
+
+pass:
+	return 1;
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
-		return -1;
+		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
 	if ((gtp1->flags >> 5) != GTP_V1)
-		return 1;
+		goto pass;
 
 	if (gtp1->type != GTP_TPDU)
-		return 1;
+		goto pass;
+
+	netdev_dbg(gtp->dev, "received GTP1 packet\n");
 
 	/* From 29.060: "This field shall be present if and only if any one or
 	 * more of the S, PN and E flags are set.".
@@ -278,17 +308,27 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	/* Make sure the header is larger enough, including extensions. */
 	if (!pskb_may_pull(skb, hdrlen))
-		return -1;
+		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return 1;
+		goto pass;
+	}
+
+	if (!gtp_rx(pctx, skb, hdrlen, gtp->role)) {
+		/* Successfully received */
+		return 0;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+drop:
+	kfree_skb(skb);
+	return 0;
+
+pass:
+	return 1;
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -317,49 +357,6 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
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
@@ -627,6 +624,8 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct iphdr) +
 				  sizeof(struct udphdr) +
 				  sizeof(struct gtp0_header);
+
+	gro_cells_init(&gtp->gro_cells, dev);
 }
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
@@ -683,6 +682,7 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
+	gro_cells_destroy(&gtp->gro_cells);
 	gtp_encap_disable(gtp);
 	gtp_hashtable_free(gtp);
 	list_del_rcu(&gtp->list);
@@ -804,9 +804,21 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
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
