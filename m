From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/5] RDS: TCP: avoid bad page reference in rds_tcp_listen_data_ready
Date: Thu, 14 Jul 2016 03:51:01 -0700
Message-ID: <71578278c042c6c15a2ec06040115e75b842def1.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42534 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcGNKv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:27 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the existing comments in rds_tcp_listen_data_ready() indicate,
it is possible under some race-windows to get to this function with the
accept() socket. If that happens, we could run into a sequence whereby

   thread 1				thread 2

rds_tcp_accept_one() thread
sets up new_sock via ->accept().
The sk_user_data is now
sock_def_readable
					data comes in for new_sock,
					->sk_data_ready is called, and
					we land in rds_tcp_listen_data_ready
rds_tcp_set_callbacks()
takes the sk_callback_lock and
sets up sk_user_data to be the cp
					read_lock sk_callback_lock
					ready = cp
					unlock sk_callback_lock
					page fault on ready

In the above sequence, we end up with a panic on a bad page reference
when trying to execute (*ready)(). Instead we need to call
sock_def_readable() safely, which is what this patch achieves.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c        |    7 +++++++
 net/rds/tcp.h        |    1 +
 net/rds/tcp_listen.c |    2 ++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index d278432..37321f1 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -551,6 +551,13 @@ static void rds_tcp_kill_sock(struct net *net)
 	}
 }
 
+void *rds_tcp_listen_sock_def_readable(struct net *net)
+{
+	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
+
+	return rtn->rds_tcp_listen_sock->sk->sk_user_data;
+}
+
 static int rds_tcp_dev_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
 {
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 1c3160f..9a1cc89 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -70,6 +70,7 @@ void rds_tcp_listen_stop(struct socket *);
 void rds_tcp_listen_data_ready(struct sock *sk);
 int rds_tcp_accept_one(struct socket *sock);
 int rds_tcp_keepalive(struct socket *sock);
+void *rds_tcp_listen_sock_def_readable(struct net *net);
 
 /* tcp_recv.c */
 int rds_tcp_recv_init(void);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index ca975a2..73040e3 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -183,6 +183,8 @@ void rds_tcp_listen_data_ready(struct sock *sk)
 	 */
 	if (sk->sk_state == TCP_LISTEN)
 		rds_tcp_accept_work(sk);
+	else
+		ready = rds_tcp_listen_sock_def_readable(sock_net(sk));
 
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
-- 
1.7.1
