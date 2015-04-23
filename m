From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/3] tipc: fix topology server broken issue
Date: Thu, 23 Apr 2015 09:37:38 -0400
Message-ID: <1429796260-14178-2-git-send-email-jon.maloy@ericsson.com>
References: <1429796260-14178-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:23991 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933949AbbDWNiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:38:19 -0400
In-Reply-To: <1429796260-14178-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When a new topology server is launched in a new namespace, its
listening socket is inserted into the "init ns" namespace's socket
hash table rather than the one owned by the new namespace. Although
the socket's namespace is forcedly changed to the new namespace later,
the socket is still stored in the socket hash table of "init ns"
namespace. When a client created in the new namespace connects
its own topology server, the connection is failed as its server's
socket could not be found from its own namespace's socket table.

If __sock_create() instead of original sock_create_kern() is used
to create the server's socket through specifying an expected namesapce,
the socket will be inserted into the specified namespace's socket
table, thereby avoiding to the topology server broken issue.

Fixes: 76100a8a64bc ("tipc: fix netns refcnt leak")

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/server.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index ab6183c..77ff03e 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -102,7 +102,7 @@ static void tipc_conn_kref_release(struct kref *kref)
 		}
 		saddr->scope = -TIPC_NODE_SCOPE;
 		kernel_bind(sock, (struct sockaddr *)saddr, sizeof(*saddr));
-		sk_release_kernel(sk);
+		sock_release(sock);
 		con->sock = NULL;
 	}
 
@@ -321,12 +321,9 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 	struct socket *sock = NULL;
 	int ret;
 
-	ret = sock_create_kern(AF_TIPC, SOCK_SEQPACKET, 0, &sock);
+	ret = __sock_create(s->net, AF_TIPC, SOCK_SEQPACKET, 0, &sock, 1);
 	if (ret < 0)
 		return NULL;
-
-	sk_change_net(sock->sk, s->net);
-
 	ret = kernel_setsockopt(sock, SOL_TIPC, TIPC_IMPORTANCE,
 				(char *)&s->imp, sizeof(s->imp));
 	if (ret < 0)
@@ -376,7 +373,7 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 
 create_err:
 	kernel_sock_shutdown(sock, SHUT_RDWR);
-	sk_release_kernel(sock->sk);
+	sock_release(sock);
 	return NULL;
 }
 
-- 
1.9.1
