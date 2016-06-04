From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 2/3] RDS: TCP: Retransmit half-sent datagrams when switching sockets in rds_tcp_reset_callbacks
Date: Sat,  4 Jun 2016 13:59:59 -0700
Message-ID: <8a0f92e2ba01c13011156aa1a6fe9d25e1184f7e.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41923 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbcFDVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 17:00:54 -0400
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we switch a connection's sockets in rds_tcp_rest_callbacks,
any partially sent datagram must be retransmitted on the new
socket so that the receiver can correctly reassmble the RDS
datagram. Use rds_send_reset() which is designed for this purpose.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |    1 +
 net/rds/tcp.c  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index c9cdb35..b1962f8 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -99,6 +99,7 @@ void rds_send_reset(struct rds_connection *conn)
 	list_splice_init(&conn->c_retrans, &conn->c_send_queue);
 	spin_unlock_irqrestore(&conn->c_lock, flags);
 }
+EXPORT_SYMBOL_GPL(rds_send_reset);
 
 static int acquire_in_xmit(struct rds_connection *conn)
 {
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 8faa0b1..7ab1b41 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -173,6 +173,7 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	release_sock(osock->sk);
 	sock_release(osock);
 newsock:
+	rds_send_reset(conn);
 	lock_sock(sock->sk);
 	write_lock_bh(&sock->sk->sk_callback_lock);
 	tc->t_sock = sock;
-- 
1.7.1
