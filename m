From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/9] sit: TX path for sit/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:14:55 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162058410.2721@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:62151 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaGQEO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:14:56 -0400
Received: by mail-pd0-f202.google.com with SMTP id w10so497949pde.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2e9ba03..4a7adb0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -822,6 +822,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	int addr_type;
 	u8 ttl;
 	int err;
+	u8 protocol = IPPROTO_IPV6;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
@@ -905,6 +906,11 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 	tdev = rt->dst.dev;
 
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0) {
+		ip_rt_put(rt);
+		goto tx_error;
+	}
+
 	if (tdev == dev) {
 		ip_rt_put(rt);
 		dev->stats.collisions++;
@@ -976,7 +982,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
-			    IPPROTO_IPV6, tos, ttl, df,
+			    protocol, tos, ttl, df,
 			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
@@ -1135,6 +1141,12 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct ip_tunnel_6rd ip6rd;
 #endif
 
+	/* Try generic tunnel ioctls first */
+	err = __ip_tunnel_gen_ioctl(dev, sitn->fb_tunnel_dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
+	err = 0;
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 #ifdef CONFIG_IPV6_SIT_6RD
-- 
2.0.0.526.g5318336
