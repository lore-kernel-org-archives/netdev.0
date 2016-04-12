From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] rxrpc: Use the listen() system call to move to
 listening state
Date: Tue, 12 Apr 2016 16:05:54 +0100
Message-ID: <20160412150554.20637.7932.stgit@warthog.procyon.org.uk>
References: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the listen() system call to move to listening state and to set the
socket backlog queue size.  A limit is placed on the maximum queue size by
way of:

	/proc/sys/net/rxrpc/max_backlog

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c          |   34 +++++++++++++++++++---------------
 net/rxrpc/af_rxrpc.c    |   26 ++++++++++++++------------
 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/misc.c        |    6 ++++++
 net/rxrpc/sysctl.c      |   10 ++++++++++
 5 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 63cd9f939f19..4832de84d52c 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -85,18 +85,14 @@ int afs_open_socket(void)
 
 	skb_queue_head_init(&afs_incoming_calls);
 
+	ret = -ENOMEM;
 	afs_async_calls = create_singlethread_workqueue("kafsd");
-	if (!afs_async_calls) {
-		_leave(" = -ENOMEM [wq]");
-		return -ENOMEM;
-	}
+	if (!afs_async_calls)
+		goto error_0;
 
 	ret = sock_create_kern(&init_net, AF_RXRPC, SOCK_DGRAM, PF_INET, &socket);
-	if (ret < 0) {
-		destroy_workqueue(afs_async_calls);
-		_leave(" = %d [socket]", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto error_1;
 
 	socket->sk->sk_allocation = GFP_NOFS;
 
@@ -111,18 +107,26 @@ int afs_open_socket(void)
 	       sizeof(srx.transport.sin.sin_addr));
 
 	ret = kernel_bind(socket, (struct sockaddr *) &srx, sizeof(srx));
-	if (ret < 0) {
-		sock_release(socket);
-		destroy_workqueue(afs_async_calls);
-		_leave(" = %d [bind]", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto error_2;
+
+	ret = kernel_listen(socket, INT_MAX);
+	if (ret < 0)
+		goto error_2;
 
 	rxrpc_kernel_intercept_rx_messages(socket, afs_rx_interceptor);
 
 	afs_socket = socket;
 	_leave(" = 0");
 	return 0;
+
+error_2:
+	sock_release(socket);
+error_1:
+	destroy_workqueue(afs_async_calls);
+error_0:
+	_leave(" = %d", ret);
+	return ret;
 }
 
 /*
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index dd462352a79c..7b1aedd79b7c 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -31,8 +31,6 @@ unsigned int rxrpc_debug; // = RXRPC_DEBUG_KPROTO;
 module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
 MODULE_PARM_DESC(debug, "RxRPC debugging mask");
 
-static int sysctl_rxrpc_max_qlen __read_mostly = 10;
-
 static struct proto rxrpc_proto;
 static const struct proto_ops rxrpc_rpc_ops;
 
@@ -191,7 +189,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 	struct rxrpc_sock *rx = rxrpc_sk(sk);
 	int ret;
 
-	_enter("%p,%d", rx, backlog);
+	_enter("%p{%d},%d", rx, rx->sk.sk_state, backlog);
 
 	lock_sock(&rx->sk);
 
@@ -199,16 +197,20 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 	case RXRPC_UNBOUND:
 		ret = -EADDRNOTAVAIL;
 		break;
-	case RXRPC_CLIENT_UNBOUND:
-	case RXRPC_CLIENT_BOUND:
-	default:
-		ret = -EBUSY;
-		break;
 	case RXRPC_SERVER_BOUND:
 		ASSERT(rx->local != NULL);
-		sk->sk_max_ack_backlog = backlog;
-		rx->sk.sk_state = RXRPC_SERVER_LISTENING;
-		ret = 0;
+		if (backlog == INT_MAX)
+			backlog = rxrpc_max_backlog;
+		if (backlog > rxrpc_max_backlog) {
+			ret = -EINVAL;
+		} else {
+			sk->sk_max_ack_backlog = backlog;
+			rx->sk.sk_state = RXRPC_SERVER_LISTENING;
+			ret = 0;
+		}
+		break;
+	default:
+		ret = -EBUSY;
 		break;
 	}
 
@@ -549,7 +551,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	sock_init_data(sock, sk);
 	sk->sk_state		= RXRPC_UNBOUND;
 	sk->sk_write_space	= rxrpc_write_space;
-	sk->sk_max_ack_backlog	= sysctl_rxrpc_max_qlen;
+	sk->sk_max_ack_backlog	= 0;
 	sk->sk_destruct		= rxrpc_sock_destructor;
 
 	rx = rxrpc_sk(sk);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index bbf2443af875..4c29cf236dea 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -640,6 +640,7 @@ extern const struct rxrpc_security rxrpc_no_security;
 /*
  * misc.c
  */
+extern unsigned int rxrpc_max_backlog __read_mostly;
 extern unsigned int rxrpc_requested_ack_delay;
 extern unsigned int rxrpc_soft_ack_delay;
 extern unsigned int rxrpc_idle_ack_delay;
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 1afe9876e79f..bdc5e42fe600 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -15,6 +15,12 @@
 #include "ar-internal.h"
 
 /*
+ * The maximum listening backlog queue size that may be set on a socket by
+ * listen().
+ */
+unsigned int rxrpc_max_backlog __read_mostly = 10;
+
+/*
  * How long to wait before scheduling ACK generation after seeing a
  * packet with RXRPC_REQUEST_ACK set (in jiffies).
  */
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index d20ed575acf4..a99690a8a3da 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -18,6 +18,7 @@ static struct ctl_table_header *rxrpc_sysctl_reg_table;
 static const unsigned int zero = 0;
 static const unsigned int one = 1;
 static const unsigned int four = 4;
+static const unsigned int thirtytwo = 32;
 static const unsigned int n_65535 = 65535;
 static const unsigned int n_max_acks = RXRPC_MAXACKS;
 
@@ -100,6 +101,15 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 
 	/* Non-time values */
 	{
+		.procname	= "max_backlog",
+		.data		= &rxrpc_max_backlog,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&four,
+		.extra2		= (void *)&thirtytwo,
+	},
+	{
 		.procname	= "rx_window_size",
 		.data		= &rxrpc_rx_window_size,
 		.maxlen		= sizeof(unsigned int),
