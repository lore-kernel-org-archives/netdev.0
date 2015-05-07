From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 09/11] tipc: fix net leak issue
Date: Thu, 7 May 2015 16:52:48 +0800
Message-ID: <1430988770-28907-10-git-send-email-ying.xue@windriver.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:35592 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbbEGIx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:59 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After tipc internal server kernel socket is created with __sock_create(),
the reference counter to a namespace of the socket is held in sk_alloc().
This causes what the nemespace is never destroyed as the kernel socket is
released on namespace's shutdown. So, after the kernel socket's creation,
we should immediately put the net's reference counter.

Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/server.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index a91a2f7..29d9695 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -99,6 +99,7 @@ static void tipc_conn_kref_release(struct kref *kref)
 		if (test_bit(CF_SERVER, &con->flags)) {
 			__module_get(sock->ops->owner);
 			__module_get(sk->sk_prot_creator->owner);
+			get_net(sock_net(sock->sk));
 		}
 		saddr->scope = -TIPC_NODE_SCOPE;
 		kernel_bind(sock, (struct sockaddr *)saddr, sizeof(*saddr));
@@ -332,6 +333,9 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 				(char *)&s->imp, sizeof(s->imp));
 	if (ret < 0)
 		goto create_err;
+
+	put_net(sock_net(sock->sk));
+
 	ret = kernel_bind(sock, (struct sockaddr *)s->saddr, sizeof(*s->saddr));
 	if (ret < 0)
 		goto create_err;
@@ -377,6 +381,7 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 
 create_err:
 	kernel_sock_shutdown(sock, SHUT_RDWR);
+	get_net(sock_net(sock->sk));
 	sock_release(sock);
 	return NULL;
 }
-- 
1.7.9.5
