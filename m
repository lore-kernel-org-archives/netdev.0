From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 07/11] l2tp: avoid to switch namespace for l2tp tunnel socket
Date: Thu, 7 May 2015 16:52:46 +0800
Message-ID: <1430988770-28907-8-git-send-email-ying.xue@windriver.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <herbert@gondor.apana.org.au>,
	<xemul@openvz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35580 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbEGIxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:52 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As there is no the race between put_net() and kernel socket creation,
it's unnecessary to switch namespace for a kernel tunnel socket from
init_net to its desirable one.

Cc: James Chapman <jchapman@katalix.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/l2tp/l2tp_core.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index a29a504..aa01daac 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1336,7 +1336,8 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	} else {
 		if (sock)
 			kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sk);
+		get_net(sock_net(sk));
+		sock_release(sock);
 	}
 
 	l2tp_tunnel_sock_put(sk);
@@ -1399,12 +1400,12 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (cfg->local_ip6 && cfg->peer_ip6) {
 			struct sockaddr_l2tpip6 ip6_addr = {0};
 
-			err = sock_create_kern(AF_INET6, SOCK_DGRAM,
-					  IPPROTO_L2TP, &sock);
+			err = __sock_create(net, AF_INET6, SOCK_DGRAM,
+					    IPPROTO_L2TP, &sock, 1);
 			if (err < 0)
 				goto out;
 
-			sk_change_net(sock->sk, net);
+			put_net(sock_net(sock->sk));
 
 			ip6_addr.l2tp_family = AF_INET6;
 			memcpy(&ip6_addr.l2tp_addr, cfg->local_ip6,
@@ -1429,12 +1430,12 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		{
 			struct sockaddr_l2tpip ip_addr = {0};
 
-			err = sock_create_kern(AF_INET, SOCK_DGRAM,
-					  IPPROTO_L2TP, &sock);
+			err = __sock_create(net, AF_INET, SOCK_DGRAM,
+					    IPPROTO_L2TP, &sock, 1);
 			if (err < 0)
 				goto out;
 
-			sk_change_net(sock->sk, net);
+			put_net(sock_net(sock->sk));
 
 			ip_addr.l2tp_family = AF_INET;
 			ip_addr.l2tp_addr = cfg->local_ip;
@@ -1462,7 +1463,8 @@ out:
 	*sockp = sock;
 	if ((err < 0) && sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		get_net(sock_net(sock->sk));
+		sock_release(sock);
 		*sockp = NULL;
 	}
 
-- 
1.7.9.5
