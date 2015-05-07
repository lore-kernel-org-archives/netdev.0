From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 06/11] ip6_udp_tunnel: avoid to switch namespace for tunnel socket
Date: Thu, 7 May 2015 16:52:45 +0800
Message-ID: <1430988770-28907-7-git-send-email-ying.xue@windriver.com>
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
Received: from mail.windriver.com ([147.11.1.11]:40647 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbEGIxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:47 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As there is no the race between put_net() and kernel socket creation,
it's unnecessary to switch namespace for a kernel tunnel socket from
init_net to its desirable one.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/ipv6/ip6_udp_tunnel.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index bba8903..4da0bc5 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -19,11 +19,11 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 	int err;
 	struct socket *sock = NULL;
 
-	err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
+	err = __sock_create(net, AF_INET6, SOCK_DGRAM, 0, &sock, 1);
 	if (err < 0)
 		goto error;
 
-	sk_change_net(sock->sk, net);
+	put_net(sock_net(sock->sk));
 
 	udp6_addr.sin6_family = AF_INET6;
 	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
@@ -55,7 +55,8 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		get_net(sock_net(sock->sk));
+		sock_release(sock);
 	}
 	*sockp = NULL;
 	return err;
-- 
1.7.9.5
