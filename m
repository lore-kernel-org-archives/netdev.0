From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 3/3] rds: tcp: Sequence teardown of listen and acceptor sockets to avoid races
Date: Sat,  4 Mar 2017 08:57:35 -0800
Message-ID: <7ac5232b552ce9177b5e11a66d1be4b195dc542c.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Cc: syzkaller@googlegroups.com, rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        santosh.shilimkar@oracle.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35695 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752401AbdCEMR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:17:56 -0500
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a93d01f5777e ("RDS: TCP: avoid bad page reference in
rds_tcp_listen_data_ready") added the function
rds_tcp_listen_sock_def_readable()  to handle the case when a
partially set-up acceptor socket drops into rds_tcp_listen_data_ready().
However, if the listen socket (rtn->rds_tcp_listen_sock) is itself going
through a tear-down via rds_tcp_listen_stop(), the (*ready)() will be
null and we would hit a panic  of the form
  BUG: unable to handle kernel NULL pointer dereference at   (null)
  IP:           (null)
   :
  ? rds_tcp_listen_data_ready+0x59/0xb0 [rds_tcp]
  tcp_data_queue+0x39d/0x5b0
  tcp_rcv_established+0x2e5/0x660
  tcp_v4_do_rcv+0x122/0x220
  tcp_v4_rcv+0x8b7/0x980
    :
In the above case, it is not fatal to encounter a NULL value for
ready- we should just drop the packet and let the flush of the
acceptor thread finish gracefully.

In general, the tear-down sequence for listen() and accept() socket
that is ensured by this commit is:
     rtn->rds_tcp_listen_sock = NULL; /* prevent any new accepts */
     In rds_tcp_listen_stop():
         serialize with, and prevent, further callbacks using lock_sock()
         flush rds_wq
         flush acceptor workq
         sock_release(listen socket)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c        |   15 ++++++++++-----
 net/rds/tcp.h        |    2 +-
 net/rds/tcp_listen.c |    9 +++++++--
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index fbf807a..2256900 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -484,9 +484,10 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
 	 * we do need to clean up the listen socket here.
 	 */
 	if (rtn->rds_tcp_listen_sock) {
-		rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
+		struct socket *lsock = rtn->rds_tcp_listen_sock;
+
 		rtn->rds_tcp_listen_sock = NULL;
-		flush_work(&rtn->rds_tcp_accept_w);
+		rds_tcp_listen_stop(lsock, &rtn->rds_tcp_accept_w);
 	}
 }
 
@@ -523,10 +524,10 @@ static void rds_tcp_kill_sock(struct net *net)
 	struct rds_tcp_connection *tc, *_tc;
 	LIST_HEAD(tmp_list);
 	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+	struct socket *lsock = rtn->rds_tcp_listen_sock;
 
-	rds_tcp_listen_stop(rtn->rds_tcp_listen_sock);
 	rtn->rds_tcp_listen_sock = NULL;
-	flush_work(&rtn->rds_tcp_accept_w);
+	rds_tcp_listen_stop(lsock, &rtn->rds_tcp_accept_w);
 	spin_lock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
 		struct net *c_net = tc->t_cpath->cp_conn->c_net;
@@ -546,8 +547,12 @@ static void rds_tcp_kill_sock(struct net *net)
 void *rds_tcp_listen_sock_def_readable(struct net *net)
 {
 	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+	struct socket *lsock = rtn->rds_tcp_listen_sock;
+
+	if (!lsock)
+		return NULL;
 
-	return rtn->rds_tcp_listen_sock->sk->sk_user_data;
+	return lsock->sk->sk_user_data;
 }
 
 static int rds_tcp_dev_event(struct notifier_block *this,
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 9a1cc89..56ea662 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -66,7 +66,7 @@ void rds_tcp_restore_callbacks(struct socket *sock,
 
 /* tcp_listen.c */
 struct socket *rds_tcp_listen_init(struct net *);
-void rds_tcp_listen_stop(struct socket *);
+void rds_tcp_listen_stop(struct socket *sock, struct work_struct *acceptor);
 void rds_tcp_listen_data_ready(struct sock *sk);
 int rds_tcp_accept_one(struct socket *sock);
 int rds_tcp_keepalive(struct socket *sock);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 67d0929..2c69a50 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -223,6 +223,9 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 	 * before it has been accepted and the accepter has set up their
 	 * data_ready.. we only want to queue listen work for our listening
 	 * socket
+	 *
+	 * (*ready)() may be null if we are racing with netns delete, and
+	 * the listen socket is being torn down.
 	 */
 	if (sk->sk_state == TCP_LISTEN)
 		rds_tcp_accept_work(sk);
@@ -231,7 +234,8 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
-	ready(sk);
+	if (ready)
+		ready(sk);
 }
 
 struct socket *rds_tcp_listen_init(struct net *net)
@@ -271,7 +275,7 @@ struct socket *rds_tcp_listen_init(struct net *net)
 	return NULL;
 }
 
-void rds_tcp_listen_stop(struct socket *sock)
+void rds_tcp_listen_stop(struct socket *sock, struct work_struct *acceptor)
 {
 	struct sock *sk;
 
@@ -292,5 +296,6 @@ void rds_tcp_listen_stop(struct socket *sock)
 
 	/* wait for accepts to stop and close the socket */
 	flush_workqueue(rds_wq);
+	flush_work(acceptor);
 	sock_release(sock);
 }
-- 
1.7.1
