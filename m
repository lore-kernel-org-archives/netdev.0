From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 1/2] RDS: TCP: rds_tcp_accept_worker() must exit gracefully when terminating rds-tcp
Date: Wed, 18 May 2016 10:06:23 -0700
Message-ID: <73ccad462f8f54dfa9c71576c3f5d48ea2b1dc12.1463579486.git.sowmini.varadhan@oracle.com>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38440 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932251AbcERRG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:06:56 -0400
In-Reply-To: <cover.1463579486.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1463579486.git.sowmini.varadhan@oracle.com>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two instances where we want to terminate RDS-TCP: when
exiting the netns or during module unload. In either case, the
termination sequence is to stop the listen socket, mark the
rtn->rds_tcp_listen_sock as null, and flush any accept workqs.
Thus any workqs that get flushed at this point will encounter a
null rds_tcp_listen_sock, and must exit gracefully to allow
the RDS-TCP termination to complete successfully.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_listen.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index be263cd..e10b422 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -80,6 +80,9 @@ int rds_tcp_accept_one(struct socket *sock)
 	int conn_state;
 	struct sock *nsk;
 
+	if (!sock) /* module unload or netns delete in progress */
+		return -ENETUNREACH;
+
 	ret = sock_create_kern(sock_net(sock->sk), sock->sk->sk_family,
 			       sock->sk->sk_type, sock->sk->sk_protocol,
 			       &new_sock);
-- 
1.7.1
