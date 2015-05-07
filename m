From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 04/11] inet: avoid unnecessary namespace switch during kernel socket creation
Date: Thu, 7 May 2015 16:52:43 +0800
Message-ID: <1430988770-28907-5-git-send-email-ying.xue@windriver.com>
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
Received: from mail.windriver.com ([147.11.1.11]:40580 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbbEGIxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:39 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the race between put_net() and kernel socket's creation is gone,
it's unnecessary to switch namespace for a kernel socket from init_net
to its desirable one. But as the kernel socket is part of a namespace,
we should not hold a reference counter to the namespace, otherwise,
probably modules relying on it cannot be stopped.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/net/inet_common.h |    3 ++-
 net/ipv4/af_inet.c        |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 4a92423..cedc7c7 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -41,7 +41,8 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
-	sk_release_kernel(sk);
+	get_net(sock_net(sk));
+	sock_release(sk->sk_socket);
 }
 
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8b47a4d..50e6292 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1430,7 +1430,7 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 struct net *net)
 {
 	struct socket *sock;
-	int rc = sock_create_kern(family, type, protocol, &sock);
+	int rc = __sock_create(net, family, type, protocol, &sock, 1);
 
 	if (rc == 0) {
 		*sk = sock->sk;
@@ -1441,7 +1441,7 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 		 */
 		(*sk)->sk_prot->unhash(*sk);
 
-		sk_change_net(*sk, net);
+		put_net(sock_net(*sk));
 	}
 	return rc;
 }
-- 
1.7.9.5
