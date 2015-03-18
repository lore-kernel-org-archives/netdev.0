From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/3] tipc: withdraw tipc topology server name when namespace is deleted
Date: Wed, 18 Mar 2015 09:32:59 +0800
Message-ID: <1426642379-20503-4-git-send-email-ying.xue@windriver.com>
References: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <cwang@twopensource.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47030 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387AbbCRBda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:33:30 -0400
In-Reply-To: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TIPC topology server is a per namespace service associated with the
tipc name {1, 1}. When a namespace is deleted, that name must be withdrawn
before we call sk_release_kernel because the kernel socket release is
done in init_net and trying to withdraw a TIPC name published in another
namespace will fail with an error as:

[  170.093264] Unable to remove local publication
[  170.093264] (type=1, lower=1, ref=2184244004, key=2184244005)

We fix this by breaking the association between the topology server name
and socket before calling sk_release_kernel.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/server.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index a57c840..ab6183c 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -90,6 +90,7 @@ static void tipc_clean_outqueues(struct tipc_conn *con);
 static void tipc_conn_kref_release(struct kref *kref)
 {
 	struct tipc_conn *con = container_of(kref, struct tipc_conn, kref);
+	struct sockaddr_tipc *saddr = con->server->saddr;
 	struct socket *sock = con->sock;
 	struct sock *sk;
 
@@ -99,6 +100,8 @@ static void tipc_conn_kref_release(struct kref *kref)
 			__module_get(sock->ops->owner);
 			__module_get(sk->sk_prot_creator->owner);
 		}
+		saddr->scope = -TIPC_NODE_SCOPE;
+		kernel_bind(sock, (struct sockaddr *)saddr, sizeof(*saddr));
 		sk_release_kernel(sk);
 		con->sock = NULL;
 	}
-- 
1.7.9.5
