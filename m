From: greearb@candelatech.com
Subject: [RFC] Fix ip routing rules (partially revert b6c69d4b)
Date: Fri, 10 Dec 2010 16:04:02 -0800
Message-ID: <1292025842-14959-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44130 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616Ab0LKAEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:04:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Change 4465b469008bc03b98a1b8df4e9ae501b6c69d4b caused rules
to stop matching the input device properly because the
FLOWI_FLAG_MATCH_ANY_IIF is always defined in ip_dev_find().

This breaks rules such as:

ip rule add pref 512 lookup local
ip rule del pref 0 lookup local
ip link set eth2 up
ip -4 addr add 172.16.0.102/24 broadcast 172.16.0.255 dev eth2
ip rule add to 172.16.0.102 iif eth2 lookup local pref 10
ip rule add iif eth2 lookup 10001 pref 20
ip route add 172.16.0.0/24 dev eth2 table 10001
ip route add unreachable 0/0 table 10001

If you had a second interface 'eth0' that was on a different
subnet, pinging a system on that interface would fail:

 [root@ct503-60 ~]# ping 192.168.100.1
 connect: Invalid argument

This patch partially reverts the problematic patch by
NOT defining FLOWI_FLAG_MATCH_ANY_IIF.  This probably breaks
the feature that the original author intended to add, and
it could easily be that the entire patch should be reverted,
so this needs review before applying.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 eb6f69a... 5f73819... M	net/ipv4/fib_frontend.c
 net/ipv4/fib_frontend.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index eb6f69a..5f73819 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -163,7 +163,6 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 				.daddr = addr
 			}
 		},
-		.flags = FLOWI_FLAG_MATCH_ANY_IIF
 	};
 	struct fib_result res = { 0 };
 	struct net_device *dev = NULL;
-- 
1.7.2.3

