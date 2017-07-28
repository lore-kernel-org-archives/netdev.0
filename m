From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] ipv4: fib: Fix NULL pointer deref during fib_sync_down_dev()
Date: Fri, 28 Jul 2017 23:27:44 +0300
Message-ID: <20170728202744.2729-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mirq-linux@rere.qmqm.pl,
        xiyou.wangcong@gmail.com, Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0066.outbound.protection.outlook.com ([104.47.0.66]:64384
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752596AbdG1U2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 16:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michał reported a NULL pointer deref during fib_sync_down_dev() when
unregistering a netdevice. The problem is that we don't check for
'in_dev' being NULL, which can happen in very specific cases.

Usually routes are flushed upon NETDEV_DOWN sent in either the netdev or
the inetaddr notification chains. However, if an interface isn't
configured with any IP address, then it's possible for host routes to be
flushed following NETDEV_UNREGISTER, after NULLing dev->ip_ptr in
inetdev_destroy().

To reproduce:
$ ip link add type dummy
$ ip route add local 1.1.1.0/24 dev dummy0
$ ip link del dev dummy0

Fix this by checking for the presence of 'in_dev' before referencing it.

Fixes: 982acb97560c ("ipv4: fib: Notify about nexthop status changes")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
Please consider this for -stable.
---
 net/ipv4/fib_semantics.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 22210010..b8d1817 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1452,7 +1452,7 @@ static int call_fib_nh_notifiers(struct fib_nh *fib_nh,
 		return call_fib_notifiers(dev_net(fib_nh->nh_dev), event_type,
 					  &info.info);
 	case FIB_EVENT_NH_DEL:
-		if ((IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
+		if ((in_dev && IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
 		     fib_nh->nh_flags & RTNH_F_LINKDOWN) ||
 		    (fib_nh->nh_flags & RTNH_F_DEAD))
 			return call_fib_notifiers(dev_net(fib_nh->nh_dev),
-- 
2.9.4
