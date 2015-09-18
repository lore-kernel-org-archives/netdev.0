From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] ip6tunnel: make rx/tx bytes counters consistent
Date: Fri, 18 Sep 2015 11:47:41 +0200
Message-ID: <1442569661-5528-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:46679 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbIRJsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 05:48:18 -0400
In-Reply-To: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the previous patch, which fixes ipv4 tunnels, here is the ipv6 part.

Before the patch, the external ipv6 header + gre header were included on
tx.

After the patch:
$ ping -c1 192.168.6.121 ; ip -s l ls dev ip6gre1
PING 192.168.6.121 (192.168.6.121) 56(84) bytes of data.
64 bytes from 192.168.6.121: icmp_req=1 ttl=64 time=1.92 ms

--- 192.168.6.121 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.923/1.923/1.923/0.000 ms
7: ip6gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1440 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/gre6 20:01:06:60:30:08:c1:c3:00:00:00:00:00:00:01:23 peer 20:01:06:60:30:08:c1:c3:00:00:00:00:00:00:01:21
    RX: bytes  packets  errors  dropped overrun mcast
    84         1        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    84         1        0       0       0       0
$ ping -c1 192.168.1.121 ; ip -s l ls dev ip6tnl1
PING 192.168.1.121 (192.168.1.121) 56(84) bytes of data.
64 bytes from 192.168.1.121: icmp_req=1 ttl=64 time=2.28 ms

--- 192.168.1.121 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.288/2.288/2.288/0.000 ms
8: ip6tnl1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1452 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/tunnel6 2001:660:3008:c1c3::123 peer 2001:660:3008:c1c3::121
    RX: bytes  packets  errors  dropped overrun mcast
    84         1        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    84         1        0       0       0       0

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_tunnel.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 65c2a9397b3c..fa915fa0f703 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -86,7 +86,7 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 	struct net_device_stats *stats = &dev->stats;
 	int pkt_len, err;
 
-	pkt_len = skb->len;
+	pkt_len = skb->len - skb_inner_network_offset(skb);
 	err = ip6_local_out_sk(sk, skb);
 
 	if (net_xmit_eval(err) == 0) {
-- 
2.4.2
