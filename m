From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/2] GENEVE: Support outer IPv4 Tx checksums by
 default
Date: Fri, 19 Feb 2016 11:26:24 -0800
Message-ID: <20160219192624.15687.55933.stgit@localhost.localdomain>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33500 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948908AbcBST00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 14:26:26 -0500
Received: by mail-pa0-f51.google.com with SMTP id fl4so55091666pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 11:26:26 -0800 (PST)
In-Reply-To: <20160219191806.15687.37621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that if UDP CSUM is not specified we will default
to enabling it.  The main motivation behind this is the fact that with the
use of outer checksum we can greatly improve the performance for GENEVE
tunnels on hardware that doesn't know how to parse them.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 1b5deaf7e3c8..2acaf2b209cd 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -76,7 +76,7 @@ struct geneve_dev {
 };
 
 /* Geneve device flags */
-#define GENEVE_F_UDP_CSUM		BIT(0)
+#define GENEVE_F_UDP_ZERO_CSUM_TX	BIT(0)
 #define GENEVE_F_UDP_ZERO_CSUM6_TX	BIT(1)
 #define GENEVE_F_UDP_ZERO_CSUM6_RX	BIT(2)
 
@@ -703,7 +703,7 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	struct genevehdr *gnvh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !!(flags & GENEVE_F_UDP_CSUM);
+	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM_TX);
 
 	skb_scrub_packet(skb, xnet);
 
@@ -944,9 +944,9 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 			opts = ip_tunnel_info_opts(info);
 
 		if (key->tun_flags & TUNNEL_CSUM)
-			flags |= GENEVE_F_UDP_CSUM;
+			flags &= ~GENEVE_F_UDP_ZERO_CSUM_TX;
 		else
-			flags &= ~GENEVE_F_UDP_CSUM;
+			flags |= GENEVE_F_UDP_ZERO_CSUM_TX;
 
 		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
 				       info->options_len, opts, flags, xnet);
@@ -972,7 +972,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
 			    tos, ttl, df, sport, geneve->dst_port,
 			    !net_eq(geneve->net, dev_net(geneve->dev)),
-			    !(flags & GENEVE_F_UDP_CSUM));
+			    !!(flags & GENEVE_F_UDP_ZERO_CSUM_TX));
 
 	return NETDEV_TX_OK;
 
@@ -1412,8 +1412,8 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 		metadata = true;
 
 	if (data[IFLA_GENEVE_UDP_CSUM] &&
-	    nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
-		flags |= GENEVE_F_UDP_CSUM;
+	    !nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
+		flags |= GENEVE_F_UDP_ZERO_CSUM_TX;
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
 	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
@@ -1483,7 +1483,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	}
 
 	if (nla_put_u8(skb, IFLA_GENEVE_UDP_CSUM,
-		       !!(geneve->flags & GENEVE_F_UDP_CSUM)) ||
+		       !(geneve->flags & GENEVE_F_UDP_ZERO_CSUM_TX)) ||
 	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
 		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_TX)) ||
 	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
