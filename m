From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 1/2] ip6_gre: Fix MTU setting for ip6gretap
Date: Wed, 18 May 2016 18:05:51 +0800
Message-ID: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When creat an ip6gretap interface with an unreachable route,
the MTU is about 14 bytes larger than what was needed.

If the remote address is reachable:
ping6 2001:0:130::1 -c 2
PING 2001:0:130::1(2001:0:130::1) 56 data bytes
64 bytes from 2001:0:130::1: icmp_seq=1 ttl=64 time=1.46 ms
64 bytes from 2001:0:130::1: icmp_seq=2 ttl=64 time=81.1 ms

--- 2001:0:130::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 1.465/41.316/81.167/39.851 ms

ip link add ip6gretap1 type ip6gretap\
 local 2001:0:130::2 remote 2001:0:130::1
ip link show ip6gretap1
11: ip6gretap1@NONE: <BROADCAST,MULTICAST> mtu 1434 ...
    link/ether c2:f3:f8:c1:2c:bf brd ff:ff:ff:ff:ff:ff

The MTU value 1434 is right. But if we delete the direct route:
ip -6 route del 2001:0:130::/64
ping6 2001:0:130::1 -c 2
connect: Network is unreachable
ip link add ip6gretap1 type ip6gretap\
 local 2001:0:130::2 remote 2001:0:130::1
ip link show ip6gretap1
12: ip6gretap1@NONE: <BROADCAST,MULTICAST> mtu 1448 ...
    link/ether 7e:e1:d2:c4:06:5e brd ff:ff:ff:ff:ff:ff

Now, the MTU value 1448 is larger than what was needed.

This patch fix the issue in this situation.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_gre.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 4541fa5..8ea5a4d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1029,6 +1029,8 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 
 	dev->hard_header_len = LL_MAX_HEADER + t_hlen;
 	dev->mtu = ETH_DATA_LEN - t_hlen;
+	if (dev->type == ARPHRD_ETHER)
+		dev->mtu -= ETH_HLEN;
 	if (!(tunnel->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		dev->mtu -= 8;
 
-- 
1.8.3.1
