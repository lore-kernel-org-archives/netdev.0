From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [NETNS 2/4 net-2.6.25] Memory leak on network namespace stop.
Date: Fri, 18 Jan 2008 15:53:14 +0300
Message-ID: <1200660796-22737-2-git-send-email-den@openvz.org>
References: <4790A0E3.9080006@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59579 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757287AbYARMxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 07:53:13 -0500
In-Reply-To: <4790A0E3.9080006@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network namespace allocates 2 kernel netlink sockets, fibnl & rtnl. These
sockets should be disposed properly, i.e. by sock_release. Plain sock_put
is not enough.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Tested-by: Alexey Dobriyan <adobriyan@openvz.org>
---
 net/core/rtnetlink.c    |    2 +-
 net/ipv4/fib_frontend.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a07e83..2c1f665 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1381,7 +1381,7 @@ static void rtnetlink_net_exit(struct net *net)
 		 * free.
 		 */
 		sk->sk_net = get_net(&init_net);
-		sock_put(sk);
+		sock_release(net->rtnl->sk_socket);
 		net->rtnl = NULL;
 	}
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8ddcd3f..4e5216e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -881,7 +881,7 @@ static void nl_fib_lookup_exit(struct net *net)
 	 * initial network namespace. So the socket will  be safe to free.
 	 */
 	net->ipv4.fibnl->sk_net = get_net(&init_net);
-	sock_put(net->ipv4.fibnl);
+	sock_release(net->ipv4.fibnl->sk_socket);
 }
 
 static void fib_disable_ip(struct net_device *dev, int force)
-- 
1.5.3.rc5

