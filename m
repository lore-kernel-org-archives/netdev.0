From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/5] RDS: TCP: Reduce code duplication in rds_tcp_reset_callbacks()
Date: Thu, 14 Jul 2016 03:51:02 -0700
Message-ID: <39bd0c2fc800c6bb908310bcb51c5e5f568025f5.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42537 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGNKv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:27 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some code duplication in rds_tcp_reset_callbacks() can be avoided
by having the function call rds_tcp_restore_callbacks() and
rds_tcp_set_callbacks().

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |   22 ++++------------------
 1 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 37321f1..a4a67f6 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -168,35 +168,21 @@ void rds_tcp_reset_callbacks(struct socket *sock,
 	wait_event(cp->cp_waitq, !test_bit(RDS_IN_XMIT, &cp->cp_flags));
 	lock_sock(osock->sk);
 	/* reset receive side state for rds_tcp_data_recv() for osock  */
+	cancel_delayed_work_sync(&cp->cp_send_w);
+	cancel_delayed_work_sync(&cp->cp_recv_w);
 	if (tc->t_tinc) {
 		rds_inc_put(&tc->t_tinc->ti_inc);
 		tc->t_tinc = NULL;
 	}
 	tc->t_tinc_hdr_rem = sizeof(struct rds_header);
 	tc->t_tinc_data_rem = 0;
-	tc->t_sock = NULL;
-
-	write_lock_bh(&osock->sk->sk_callback_lock);
-
-	osock->sk->sk_user_data = NULL;
-	osock->sk->sk_data_ready = tc->t_orig_data_ready;
-	osock->sk->sk_write_space = tc->t_orig_write_space;
-	osock->sk->sk_state_change = tc->t_orig_state_change;
-	write_unlock_bh(&osock->sk->sk_callback_lock);
+	rds_tcp_restore_callbacks(osock, tc);
 	release_sock(osock->sk);
 	sock_release(osock);
 newsock:
 	rds_send_path_reset(cp);
 	lock_sock(sock->sk);
-	write_lock_bh(&sock->sk->sk_callback_lock);
-	tc->t_sock = sock;
-	tc->t_cpath = cp;
-	sock->sk->sk_user_data = cp;
-	sock->sk->sk_data_ready = rds_tcp_data_ready;
-	sock->sk->sk_write_space = rds_tcp_write_space;
-	sock->sk->sk_state_change = rds_tcp_state_change;
-
-	write_unlock_bh(&sock->sk->sk_callback_lock);
+	rds_tcp_set_callbacks(sock, cp);
 	release_sock(sock->sk);
 }
 
-- 
1.7.1
