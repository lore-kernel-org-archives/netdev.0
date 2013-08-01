From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] ipv6: bump genid when delete/add address
Date: Thu, 1 Aug 2013 17:44:44 +0800
Message-ID: <1375350284-32725-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<jmorris@namei.org>, <hannes@stressinduktion.org>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62810 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab3HAJmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 05:42:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Server           Client
2001:1::803/64  <-> 2001:1::805/64
2001:2::804/64  <-> 2001:2::806/64

Server side fib binary tree looks like this:

                                   (2001:/64)
                                   /
                                  /
                   ffff88002103c380
                 /                 \
     (2)        /                   \
 (2001::803/128)                     ffff880037ac07c0
                                    /               \
                                   /                 \  (3)
                      ffff880037ac0640               (2001::806/128)
                       /             \
             (1)      /               \
        (2001::804/128)               (2001::805/128)

Delete 2001::804/64 won't cause prefix route deleted as well as rt in (3)
destinate to 2001::806 with source address as 2001::804/64. That's because
2001::803/64 is still alive, which make onlink=1 in ipv6_del_addr, this is
where the substantial difference between same prefix configuration and
different prefix configuration :) So packet are still transmitted out to
2001::806 with source address as 2001::804/64.

So bump genid will clear rt in (3), and up layer protocol will eventually
find the right one for themselves.

This problem arised from the discussion in here:
http://marc.info/?l=linux-netdev&m=137404469219410&w=4

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/addrconf.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cfdcf7b..e7780d7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4653,6 +4653,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		break;
 	}
 	atomic_inc(&net->ipv6.dev_addr_genid);
+	rt_genid_bump_ipv6(net);
 }
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
-- 
1.7.1
