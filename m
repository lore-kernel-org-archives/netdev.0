From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 10/14] gtp: Add support for devnet
Date: Mon, 18 Sep 2017 17:39:00 -0700
Message-ID: <20170919003904.5124-11-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:55703 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdISAj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:56 -0400
Received: by mail-pf0-f171.google.com with SMTP id r71so1099533pfe.12
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:56 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a net field to gtp that is derived from src_net. Use net_eq to make
cross net argument for transmit functions.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1870469a4982..393f63cb2576 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -89,6 +89,7 @@ struct gtp_dev {
 	struct socket		*sock0;
 	struct socket		*sock1u;
 
+	struct net		*net;
 	struct net_device	*dev;
 
 	unsigned int		role;
@@ -271,6 +272,7 @@ static u16 ipver_to_eth(struct iphdr *iph)
 static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 		  unsigned int hdrlen, unsigned int role)
 {
+	struct gtp_dev *gtp = netdev_priv(pctx->dev);
 	struct pcpu_sw_netstats *stats;
 	u16 inner_protocol;
 
@@ -285,8 +287,7 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 
 	/* Get rid of the GTP + UDP headers. */
 	if (iptunnel_pull_header(skb, hdrlen, inner_protocol,
-				 !net_eq(sock_net(pctx->sk),
-					 dev_net(pctx->dev))))
+				 !net_eq(gtp->net, dev_net(pctx->dev))))
 		return -1;
 
 	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
@@ -532,6 +533,8 @@ static void gtp_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 		    struct pdp_ctx *pctx)
 {
+	struct gtp_dev *gtp = netdev_priv(dev);
+	bool xnet = !net_eq(gtp->net, dev_net(gtp->dev));
 	struct sock *sk = pctx->sk;
 	int err = 0;
 
@@ -564,7 +567,7 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 				    pctx->peer_addr_ip4.s_addr,
 				    0, ip4_dst_hoplimit(&rt->dst), 0,
 				    pctx->gtp_port, pctx->gtp_port,
-				    false, false);
+				    xnet, false);
 
 		netdev_dbg(dev, "gtp -> IP src: %pI4 dst: %pI4\n",
 			   &saddr, &pctx->peer_addr_ip4.s_addr);
@@ -782,6 +785,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 
 	gtp->role = role;
 	gtp->is_ipv6 = is_ipv6;
+	gtp->net = src_net;
 
 	gn = net_generic(dev_net(dev), gtp_net_id);
 	list_add_rcu(&gtp->list, &gn->gtp_dev_list);
-- 
2.11.0
