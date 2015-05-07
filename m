From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 05/11] udp_tunnel: avoid to switch namespace for tunnel socket
Date: Thu, 7 May 2015 16:52:44 +0800
Message-ID: <1430988770-28907-6-git-send-email-ying.xue@windriver.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:35555 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbEGIxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:42 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no the race between put_net() and kernel socket creation, so
it's unnecessary to switch namespace for a kernel tunnel socket from
init_net to its desirable one.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/ipv4/udp_tunnel.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 6bb98cc..720ab82 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -15,11 +15,11 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 	struct socket *sock = NULL;
 	struct sockaddr_in udp_addr;
 
-	err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
+	err = __sock_create(net, AF_INET, SOCK_DGRAM, 0, &sock, 1);
 	if (err < 0)
 		goto error;
 
-	sk_change_net(sock->sk, net);
+	put_net(sock_net(sock->sk));
 
 	udp_addr.sin_family = AF_INET;
 	udp_addr.sin_addr = cfg->local_ip;
@@ -47,7 +47,8 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		get_net(sock_net(sock->sk));
+		sock_release(sock);
 	}
 	*sockp = NULL;
 	return err;
@@ -101,7 +102,8 @@ void udp_tunnel_sock_release(struct socket *sock)
 {
 	rcu_assign_sk_user_data(sock->sk, NULL);
 	kernel_sock_shutdown(sock, SHUT_RDWR);
-	sk_release_kernel(sock->sk);
+	get_net(sock_net(sock->sk));
+	sock_release(sock);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
 
-- 
1.7.9.5
