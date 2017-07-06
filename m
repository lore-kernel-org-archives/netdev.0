From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 1/2] rds: tcp: use sock_create_lite() to create the accept socket
Date: Thu,  6 Jul 2017 08:15:06 -0700
Message-ID: <6918d62064a34e62638f7bb47e4dcdf7de943549.1499352757.git.sowmini.varadhan@oracle.com>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45620 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdGFPR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 11:17:57 -0400
In-Reply-To: <cover.1499352757.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1499352757.git.sowmini.varadhan@oracle.com>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two problems with calling sock_create_kern() from
rds_tcp_accept_one()
1. it sets up a new_sock->sk that is wasteful, because this ->sk
   is going to get replaced by inet_accept() in the subsequent ->accept()
2. The new_sock->sk is a leaked reference in sock_graft() which
   expects to find a null parent->sk

Avoid these problems by calling sock_create_lite().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_listen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index c6dc8ca..c061d6e 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -136,7 +136,7 @@ int rds_tcp_accept_one(struct socket *sock)
 	if (!sock) /* module unload or netns delete in progress */
 		return -ENETUNREACH;
 
-	ret = sock_create_kern(sock_net(sock->sk), sock->sk->sk_family,
+	ret = sock_create_lite(sock->sk->sk_family,
 			       sock->sk->sk_type, sock->sk->sk_protocol,
 			       &new_sock);
 	if (ret)
-- 
1.7.1
