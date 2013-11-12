From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Tue, 12 Nov 2013 14:39:13 -0800
Message-ID: <1384295953-8332-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Isaku Yamahata <yamahatanetdev@gmail.com>,
	Maciej Zenczykowski <zenczykowski@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36827 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab3KLWjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 17:39:17 -0500
Received: by mail-pd0-f173.google.com with SMTP id x10so2280490pdj.18
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 14:39:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 06a23fe31ca3
("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
and refactoring 64261f230a91
("dev: move skb_scrub_packet() after eth_type_trans()")

are forcing pkt_type to be PACKET_HOST when skb traverses veth.

which means that ip forwarding will kick in inside netns
even if skb->eth->h_dest != dev->dev_addr

Fix order of eth_type_trans() and skb_scrub_packet() in dev_forward_skb()
and in ip_tunnel_rcv()

Fixes: 06a23fe31ca3 ("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
CC: Isaku Yamahata <yamahatanetdev@gmail.com>
CC: Maciej Zenczykowski <zenczykowski@gmail.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

v2: fixing order in ip_tunnel_rcv() as suggested by Nicolas
Isaku's test still works fine.
not touching ipv6 since I don't have testbed for it

 net/core/dev.c       |    6 +-----
 net/ipv4/ip_tunnel.c |    4 ++--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3430b1e..2afc521 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1691,13 +1691,9 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-	skb->protocol = eth_type_trans(skb, dev);
 
-	/* eth_type_trans() can set pkt_type.
-	 * call skb_scrub_packet() after it to clear pkt_type _after_ calling
-	 * eth_type_trans().
-	 */
 	skb_scrub_packet(skb, true);
+	skb->protocol = eth_type_trans(skb, dev);
 
 	return netif_rx(skb);
 }
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 63a6d6d..254f11c 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -454,6 +454,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	tstats->rx_bytes += skb->len;
 	u64_stats_update_end(&tstats->syncp);
 
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
+
 	if (tunnel->dev->type == ARPHRD_ETHER) {
 		skb->protocol = eth_type_trans(skb, tunnel->dev);
 		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
@@ -461,8 +463,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
-	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
-
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
-- 
1.7.9.5
