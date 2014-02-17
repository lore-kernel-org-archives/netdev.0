From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] gre: add link local route when local addr is any
Date: Mon, 17 Feb 2014 14:22:21 +0100
Message-ID: <1392643341-4288-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5301E59F.5090506@6wind.com>
Cc: hannes@stressinduktion.org, itk-intern@samfundet.no,
	davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: sesse@samfundet.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:33411 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbaBQNYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 08:24:20 -0500
In-Reply-To: <5301E59F.5090506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was reported by Steinar H. Gunderson and was introduced by commit
f7cb8886335d ("sit/gre6: don't try to add the same route two times").

root@morgental:~# ip tunnel add foo mode gre remote 1.2.3.4 ttl 64
root@morgental:~# ip link set foo up mtu 1468
root@morgental:~# ip -6 route show dev foo
fe80::/64  proto kernel  metric 256

but after the above commit, no such route shows up.

There is no link local route because dev->dev_addr is 0 (because local ipv4
address is 0), hence no link local address is configured.

In this scenario, the link local address is added manually: 'ip -6 addr add
fe80::1 dev foo' and because prefix is /128, no link local route is added by the
kernel.

Even if the right things to do is to add the link local address with a /64
prefix, we need to restore the previous behavior to avoid breaking userpace.

Reported-by: Steinar H. Gunderson <sesse@samfundet.no>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad235690684c..fdbfeca36d63 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2783,6 +2783,8 @@ static void addrconf_gre_config(struct net_device *dev)
 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
 	if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
 		addrconf_add_linklocal(idev, &addr);
+	else
+		addrconf_prefix_route(&addr, 64, dev, 0, 0);
 }
 #endif
 
-- 
1.8.5.4
