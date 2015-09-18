From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] iptunnel: make rx/tx bytes counters consistent
Date: Fri, 18 Sep 2015 11:47:40 +0200
Message-ID: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:46673 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbIRJsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 05:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was already done a long time ago in
commit 64194c31a0b6 ("inet: Make tunnel RX/TX byte counters more consistent")
but tx path was broken (at least since 3.10).

Before the patch the gre header was included on tx.

After the patch:
$ ping -c1 192.168.0.121 ; ip -s l ls dev gre1
PING 192.168.0.121 (192.168.0.121) 56(84) bytes of data.
64 bytes from 192.168.0.121: icmp_req=1 ttl=64 time=2.95 ms

--- 192.168.0.121 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.955/2.955/2.955/0.000 ms
7: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/gre 10.16.0.249 peer 10.16.0.121
    RX: bytes  packets  errors  dropped overrun mcast
    84         1        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    84         1        0       0       0       0

Reported-by: Julien Meunier <julien.meunier@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_tunnel_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 29ed6c5a5185..9b97204b8c81 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -51,7 +51,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
-	int pkt_len = skb->len;
+	int pkt_len = skb->len - skb_inner_network_offset(skb);
 	struct iphdr *iph;
 	int err;
 
-- 
2.4.2
