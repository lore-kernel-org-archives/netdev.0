From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 2/2] Fix reference counting by socket timers
Date: Fri, 21 Jul 2006 11:36:40 -0400
Message-ID: <20060721153640.GA16379@linux-mips.org>
References: <20060721152946.GA16317@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:28383 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750886AbWGUPgp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 11:36:45 -0400
Received: from localhost.localdomain ([127.0.0.1]:59597 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133897AbWGUPgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 16:36:44 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060721152946.GA16317@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With struct sock and ax25_cb in a unified data structure it now is
possible to fix the reference counting by using the sk_reset_timer
and sk_stop_timer helper function - the previous implementation was
based simply on "principle hope".

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h    |    5 +++
 include/net/rose.h    |    1 
 net/ax25/af_ax25.c    |   55 ++++++++++++++++++---------------
 net/ax25/ax25_timer.c |   82 ++++++++++++++++++++------------------------------
 net/netrom/nr_timer.c |   29 +++++++++--------
 net/rose/af_rose.c    |    6 +--
 net/rose/rose_timer.c |   79 +++++++++++++++++++-----------------------------
 7 files changed, 120 insertions(+), 137 deletions(-)

Index: linux-net/net/ax25/af_ax25.c
===================================================================
--- linux-net.orig/net/ax25/af_ax25.c	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/net/ax25/af_ax25.c	2006-07-14 01:36:04.000000000 +0100
@@ -49,8 +49,6 @@
 #include <net/ip.h>
 #include <net/arp.h>
 
-
-
 HLIST_HEAD(ax25_list);
 DEFINE_SPINLOCK(ax25_list_lock);
 
@@ -261,13 +259,10 @@ void ax25_destroy_socket(struct ax25_soc
  */
 static void ax25_destroy_timer(unsigned long data)
 {
-	struct ax25_sock *ax25 = (struct ax25_sock *)data;
-	struct sock *sk;
-	
-	sk=ax25->sk;
-	
+	struct ax25_sock *ax25 = (struct ax25_sock *) data;
+	struct sock *sk = ax25->sk;
+
 	bh_lock_sock(sk);
-	sock_hold(sk);
 	ax25_destroy_socket(ax25);
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -281,6 +276,7 @@ static void ax25_destroy_timer(unsigned 
  */
 void ax25_destroy_socket(struct ax25_sock *ax25)
 {
+	struct sock *sk = ax25->sk;
 	struct sk_buff *skb;
 
 	ax25_cb_del(ax25);
@@ -293,9 +289,9 @@ void ax25_destroy_socket(struct ax25_soc
 
 	ax25_clear_queues(ax25);	/* Flush the queues */
 
-	if (ax25->sk != NULL) {
+	if (sk) {
 		while ((skb = skb_dequeue(&ax25->sk->sk_receive_queue)) != NULL) {
-			if (skb->sk != ax25->sk) {
+			if (skb->sk != sk) {
 				/* A pending connection */
 				struct ax25_sock *sax25 = ax25_sk(skb->sk);
 
@@ -308,23 +304,14 @@ void ax25_destroy_socket(struct ax25_soc
 
 			kfree_skb(skb);
 		}
-		skb_queue_purge(&ax25->sk->sk_write_queue);
-	}
+		skb_queue_purge(&sk->sk_write_queue);
 
-	if (ax25->sk != NULL) {
-		if (atomic_read(&ax25->sk->sk_wmem_alloc) ||
-		    atomic_read(&ax25->sk->sk_rmem_alloc)) {
+		if (atomic_read(&sk->sk_wmem_alloc) ||
+		    atomic_read(&sk->sk_rmem_alloc)) {
 			/* Defer: outstanding buffers */
-			init_timer(&ax25->dtimer);
-			ax25->dtimer.expires  = jiffies + 2 * HZ;
-			ax25->dtimer.function = ax25_destroy_timer;
-			ax25->dtimer.data     = (unsigned long)ax25;
-			add_timer(&ax25->dtimer);
-		} else {
-			struct sock *sk=ax25->sk;
-			ax25->sk=NULL;
+			sk_reset_timer(sk, &ax25->dtimer, jiffies + 2 * HZ);
+		} else
 			sock_put(sk);
-		}
 	} else {
 		sock_put(&ax25->sock);
 	}
@@ -497,11 +484,29 @@ struct ax25_sock *ax25_alloc_sock(struct
 	skb_queue_head_init(&ax25->ack_queue);
 	skb_queue_head_init(&ax25->reseq_queue);
 
-	init_timer(&ax25->timer);
 	init_timer(&ax25->t1timer);
+	ax25->t1timer.function	= &ax25_t1timer_expiry;
+	ax25->t1timer.data	= (unsigned long) ax25;
+
 	init_timer(&ax25->t2timer);
+	ax25->t2timer.function	= &ax25_t2timer_expiry;
+	ax25->t2timer.data	= (unsigned long) ax25;
+
 	init_timer(&ax25->t3timer);
+	ax25->t3timer.function	= &ax25_t3timer_expiry;
+	ax25->t3timer.data	= (unsigned long) ax25;
+
 	init_timer(&ax25->idletimer);
+	ax25->idletimer.function= &ax25_idletimer_expiry;
+	ax25->idletimer.data	= (unsigned long) ax25;
+
+	init_timer(&ax25->timer);
+	ax25->timer.function	= &ax25_heartbeat_expiry;
+	ax25->timer.data	= (unsigned long) ax25;
+
+	init_timer(&ax25->dtimer);
+	ax25->dtimer.function	= ax25_destroy_timer;
+	ax25->dtimer.data	= (unsigned long)ax25;
 
 	ax25_fillin_cb(ax25, NULL);
 
Index: linux-net/net/ax25/ax25_timer.c
===================================================================
--- linux-net.orig/net/ax25/ax25_timer.c	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/net/ax25/ax25_timer.c	2006-07-14 01:36:04.000000000 +0100
@@ -34,94 +34,70 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 
-static void ax25_heartbeat_expiry(unsigned long);
-static void ax25_t1timer_expiry(unsigned long);
-static void ax25_t2timer_expiry(unsigned long);
-static void ax25_t3timer_expiry(unsigned long);
-static void ax25_idletimer_expiry(unsigned long);
-
 void ax25_start_heartbeat(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->timer);
-
-	ax25->timer.data     = (unsigned long)ax25;
-	ax25->timer.function = &ax25_heartbeat_expiry;
-	ax25->timer.expires  = jiffies + 5 * HZ;
+	struct sock *sk = &ax25->sock;
 
-	add_timer(&ax25->timer);
+	sk_reset_timer(sk, &ax25->timer, jiffies + 5 * HZ);
 }
 
 void ax25_start_t1timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t1timer);
-
-	ax25->t1timer.data     = (unsigned long)ax25;
-	ax25->t1timer.function = &ax25_t1timer_expiry;
-	ax25->t1timer.expires  = jiffies + ax25->t1;
+	struct sock *sk = &ax25->sock;
 
-	add_timer(&ax25->t1timer);
+	sk_reset_timer(sk, &ax25->t1timer, jiffies + ax25->t1);
 }
 
 void ax25_start_t2timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t2timer);
+	struct sock *sk = &ax25->sock;
 
-	ax25->t2timer.data     = (unsigned long)ax25;
-	ax25->t2timer.function = &ax25_t2timer_expiry;
-	ax25->t2timer.expires  = jiffies + ax25->t2;
-
-	add_timer(&ax25->t2timer);
+	sk_reset_timer(sk, &ax25->t2timer, jiffies + ax25->t2);
 }
 
 void ax25_start_t3timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t3timer);
+	struct sock *sk = &ax25->sock;
 
-	if (ax25->t3 > 0) {
-		ax25->t3timer.data     = (unsigned long)ax25;
-		ax25->t3timer.function = &ax25_t3timer_expiry;
-		ax25->t3timer.expires  = jiffies + ax25->t3;
+	sk_stop_timer(sk, &ax25->t3timer);
 
-		add_timer(&ax25->t3timer);
-	}
+	if (ax25->t3 > 0)
+		sk_reset_timer(sk, &ax25->t3timer, jiffies + ax25->t3);
 }
 
 void ax25_start_idletimer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->idletimer);
+	struct sock *sk = &ax25->sock;
 
-	if (ax25->idle > 0) {
-		ax25->idletimer.data     = (unsigned long)ax25;
-		ax25->idletimer.function = &ax25_idletimer_expiry;
-		ax25->idletimer.expires  = jiffies + ax25->idle;
+	sk_stop_timer(sk, &ax25->idletimer);
 
-		add_timer(&ax25->idletimer);
-	}
+	if (ax25->idle > 0)
+		sk_reset_timer(sk, &ax25->idletimer, jiffies + ax25->idle);
 }
 
 void ax25_stop_heartbeat(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->timer);
+	sk_stop_timer(&ax25->sock, &ax25->timer);
 }
 
 void ax25_stop_t1timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t1timer);
+	sk_stop_timer(&ax25->sock, &ax25->t1timer);
 }
 
 void ax25_stop_t2timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t2timer);
+	sk_stop_timer(&ax25->sock, &ax25->t2timer);
 }
 
 void ax25_stop_t3timer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->t3timer);
+	sk_stop_timer(&ax25->sock, &ax25->t3timer);
 }
 
 void ax25_stop_idletimer(struct ax25_sock *ax25)
 {
-	del_timer(&ax25->idletimer);
+	sk_stop_timer(&ax25->sock, &ax25->idletimer);
 }
 
 int ax25_t1timer_running(struct ax25_sock *ax25)
@@ -139,7 +115,7 @@ unsigned long ax25_display_timer(struct 
 
 EXPORT_SYMBOL(ax25_display_timer);
 
-static void ax25_heartbeat_expiry(unsigned long param)
+void ax25_heartbeat_expiry(unsigned long param)
 {
 	int proto = AX25_PROTO_STD_SIMPLEX;
 	struct ax25_sock *ax25 = (struct ax25_sock *)param;
@@ -162,9 +138,11 @@ static void ax25_heartbeat_expiry(unsign
 		break;
 #endif
 	}
+
+	sock_put(&ax25->sock);
 }
 
-static void ax25_t1timer_expiry(unsigned long param)
+void ax25_t1timer_expiry(unsigned long param)
 {
 	struct ax25_sock *ax25 = (struct ax25_sock *)param;
 
@@ -181,9 +159,11 @@ static void ax25_t1timer_expiry(unsigned
 		break;
 #endif
 	}
+
+	sock_put(&ax25->sock);
 }
 
-static void ax25_t2timer_expiry(unsigned long param)
+void ax25_t2timer_expiry(unsigned long param)
 {
 	struct ax25_sock *ax25 = (struct ax25_sock *)param;
 
@@ -200,9 +180,11 @@ static void ax25_t2timer_expiry(unsigned
 		break;
 #endif
 	}
+
+	sock_put(&ax25->sock);
 }
 
-static void ax25_t3timer_expiry(unsigned long param)
+void ax25_t3timer_expiry(unsigned long param)
 {
 	struct ax25_sock *ax25 = (struct ax25_sock *)param;
 
@@ -221,9 +203,11 @@ static void ax25_t3timer_expiry(unsigned
 		break;
 #endif
 	}
+
+	sock_put(&ax25->sock);
 }
 
-static void ax25_idletimer_expiry(unsigned long param)
+void ax25_idletimer_expiry(unsigned long param)
 {
 	struct ax25_sock *ax25 = (struct ax25_sock *)param;
 
@@ -242,4 +226,6 @@ static void ax25_idletimer_expiry(unsign
 		break;
 #endif
 	}
+
+	sock_put(&ax25->sock);
 }
Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/include/net/ax25.h	2006-07-14 01:36:04.000000000 +0100
@@ -395,6 +395,11 @@ extern void ax25_stop_t1timer(struct ax2
 extern void ax25_stop_t2timer(struct ax25_sock *);
 extern void ax25_stop_t3timer(struct ax25_sock *);
 extern void ax25_stop_idletimer(struct ax25_sock *);
+extern void ax25_heartbeat_expiry(unsigned long);
+extern void ax25_t1timer_expiry(unsigned long);
+extern void ax25_t2timer_expiry(unsigned long);
+extern void ax25_t3timer_expiry(unsigned long);
+extern void ax25_idletimer_expiry(unsigned long);
 extern int  ax25_t1timer_running(struct ax25_sock *);
 extern unsigned long ax25_display_timer(struct timer_list *);
 
Index: linux-net/net/netrom/nr_timer.c
===================================================================
--- linux-net.orig/net/netrom/nr_timer.c	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/net/netrom/nr_timer.c	2006-07-14 01:37:19.000000000 +0100
@@ -65,21 +65,21 @@ void nr_start_t1timer(struct sock *sk)
 {
 	struct nr_sock *nr = nr_sk(sk);
 
-	mod_timer(&nr->t1timer, jiffies + nr->t1);
+	sk_reset_timer(sk, &nr->t1timer, jiffies + nr->t1);
 }
 
 void nr_start_t2timer(struct sock *sk)
 {
 	struct nr_sock *nr = nr_sk(sk);
 
-	mod_timer(&nr->t2timer, jiffies + nr->t2);
+	sk_reset_timer(sk, &nr->t2timer, jiffies + nr->t2);
 }
 
 void nr_start_t4timer(struct sock *sk)
 {
 	struct nr_sock *nr = nr_sk(sk);
 
-	mod_timer(&nr->t4timer, jiffies + nr->t4);
+	sk_reset_timer(sk, &nr->t4timer, jiffies + nr->t4);
 }
 
 void nr_start_idletimer(struct sock *sk)
@@ -87,37 +87,37 @@ void nr_start_idletimer(struct sock *sk)
 	struct nr_sock *nr = nr_sk(sk);
 
 	if (nr->idle > 0)
-		mod_timer(&nr->idletimer, jiffies + nr->idle);
+		sk_reset_timer(sk, &nr->idletimer, jiffies + nr->idle);
 }
 
 void nr_start_heartbeat(struct sock *sk)
 {
-	mod_timer(&sk->sk_timer, jiffies + 5 * HZ);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + 5 * HZ);
 }
 
 void nr_stop_t1timer(struct sock *sk)
 {
-	del_timer(&nr_sk(sk)->t1timer);
+	sk_stop_timer(sk, &nr_sk(sk)->t1timer);
 }
 
 void nr_stop_t2timer(struct sock *sk)
 {
-	del_timer(&nr_sk(sk)->t2timer);
+	sk_stop_timer(sk, &nr_sk(sk)->t2timer);
 }
 
 void nr_stop_t4timer(struct sock *sk)
 {
-	del_timer(&nr_sk(sk)->t4timer);
+	sk_stop_timer(sk, &nr_sk(sk)->t4timer);
 }
 
 void nr_stop_idletimer(struct sock *sk)
 {
-	del_timer(&nr_sk(sk)->idletimer);
+	sk_stop_timer(sk, &nr_sk(sk)->idletimer);
 }
 
 void nr_stop_heartbeat(struct sock *sk)
 {
-	del_timer(&sk->sk_timer);
+	sk_stop_timer(sk, &sk->sk_timer);
 }
 
 int nr_t1timer_running(struct sock *sk)
@@ -137,10 +137,7 @@ static void nr_heartbeat_expiry(unsigned
 		   is accepted() it isn't 'dead' so doesn't get removed. */
 		if (sock_flag(sk, SOCK_DESTROY) ||
 		    (sk->sk_state == TCP_LISTEN && sock_flag(sk, SOCK_DEAD))) {
-			sock_hold(sk);
-			bh_unlock_sock(sk);
 			nr_destroy_socket(sk);
-			sock_put(sk);
 			return;
 		}
 		break;
@@ -161,7 +158,9 @@ static void nr_heartbeat_expiry(unsigned
 	}
 
 	nr_start_heartbeat(sk);
+
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void nr_t2timer_expiry(unsigned long param)
@@ -175,6 +174,7 @@ static void nr_t2timer_expiry(unsigned l
 		nr_enquiry_response(sk);
 	}
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void nr_t4timer_expiry(unsigned long param)
@@ -184,6 +184,7 @@ static void nr_t4timer_expiry(unsigned l
 	bh_lock_sock(sk);
 	nr_sk(sk)->condition &= ~NR_COND_PEER_RX_BUSY;
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void nr_idletimer_expiry(unsigned long param)
@@ -212,6 +213,7 @@ static void nr_idletimer_expiry(unsigned
 		sock_set_flag(sk, SOCK_DEAD);
 	}
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void nr_t1timer_expiry(unsigned long param)
@@ -257,4 +259,5 @@ static void nr_t1timer_expiry(unsigned l
 
 	nr_start_t1timer(sk);
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
Index: linux-net/include/net/rose.h
===================================================================
--- linux-net.orig/include/net/rose.h	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/include/net/rose.h	2006-07-14 01:36:04.000000000 +0100
@@ -218,6 +218,7 @@ extern int  rose_parse_facilities(unsign
 extern void rose_disconnect(struct sock *, int, int, int);
 
 /* rose_timer.c */
+extern void rose_init_timers(struct sock *sk);
 extern void rose_start_heartbeat(struct sock *);
 extern void rose_start_t1timer(struct sock *);
 extern void rose_start_t2timer(struct sock *);
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/net/rose/af_rose.c	2006-07-14 01:36:04.000000000 +0100
@@ -522,8 +522,7 @@ static int rose_create(struct socket *so
 	sock->ops    = &rose_proto_ops;
 	sk->sk_protocol = protocol;
 
-	init_timer(&rose->timer);
-	init_timer(&rose->idletimer);
+	rose_init_timers(sk);
 
 	rose->t1   = msecs_to_jiffies(sysctl_rose_call_request_timeout);
 	rose->t2   = msecs_to_jiffies(sysctl_rose_reset_request_timeout);
@@ -567,8 +566,7 @@ static struct sock *rose_make_new(struct
 	sk->sk_sleep    = osk->sk_sleep;
 	sock_copy_flags(sk, osk);
 
-	init_timer(&rose->timer);
-	init_timer(&rose->idletimer);
+	rose_init_timers(sk);
 
 	orose		= rose_sk(osk);
 	rose->t1	= orose->t1;
Index: linux-net/net/rose/rose_timer.c
===================================================================
--- linux-net.orig/net/rose/rose_timer.c	2006-07-14 01:34:39.000000000 +0100
+++ linux-net/net/rose/rose_timer.c	2006-07-14 01:36:04.000000000 +0100
@@ -5,7 +5,7 @@
  * (at your option) any later version.
  *
  * Copyright (C) Jonathan Naylor G4KLX (g4klx@g4klx.demon.co.uk)
- * Copyright (C) 2002 Ralf Baechle DO1GRB (ralf@gnu.org)
+ * Copyright (C) 2002, 06 Ralf Baechle DL5RB (ralf@gnu.org)
  */
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -33,97 +33,78 @@ static void rose_heartbeat_expiry(unsign
 static void rose_timer_expiry(unsigned long);
 static void rose_idletimer_expiry(unsigned long);
 
-void rose_start_heartbeat(struct sock *sk)
+void rose_init_timers(struct sock *sk)
 {
-	del_timer(&sk->sk_timer);
+	struct rose_sock *rose = rose_sk(sk);
 
-	sk->sk_timer.data     = (unsigned long)sk;
+	sk->sk_timer.data     = (unsigned long) sk;
 	sk->sk_timer.function = &rose_heartbeat_expiry;
-	sk->sk_timer.expires  = jiffies + 5 * HZ;
 
-	add_timer(&sk->sk_timer);
+	init_timer(&rose->timer);
+	rose->timer.data     = (unsigned long) sk;
+	rose->timer.function = &rose_timer_expiry;
+
+	init_timer(&rose->idletimer);
+	rose->idletimer.data     = (unsigned long) sk;
+	rose->idletimer.function = &rose_idletimer_expiry;
+}
+
+void rose_start_heartbeat(struct sock *sk)
+{
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + 5 * HZ);
 }
 
 void rose_start_t1timer(struct sock *sk)
 {
 	struct rose_sock *rose = rose_sk(sk);
 
-	del_timer(&rose->timer);
-
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
-	rose->timer.expires  = jiffies + rose->t1;
-
-	add_timer(&rose->timer);
+	sk_reset_timer(sk, &rose->timer, jiffies + rose->t1);
 }
 
 void rose_start_t2timer(struct sock *sk)
 {
 	struct rose_sock *rose = rose_sk(sk);
 
-	del_timer(&rose->timer);
-
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
-	rose->timer.expires  = jiffies + rose->t2;
-
-	add_timer(&rose->timer);
+	sk_reset_timer(sk, &rose->timer, jiffies + rose->t2);
 }
 
 void rose_start_t3timer(struct sock *sk)
 {
 	struct rose_sock *rose = rose_sk(sk);
 
-	del_timer(&rose->timer);
-
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
-	rose->timer.expires  = jiffies + rose->t3;
-
-	add_timer(&rose->timer);
+	sk_reset_timer(sk, &rose->timer, jiffies + rose->t3);
 }
 
 void rose_start_hbtimer(struct sock *sk)
 {
 	struct rose_sock *rose = rose_sk(sk);
 
-	del_timer(&rose->timer);
-
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
-	rose->timer.expires  = jiffies + rose->hb;
-
-	add_timer(&rose->timer);
+	sk_reset_timer(sk, &rose->timer, jiffies + rose->hb);
 }
 
 void rose_start_idletimer(struct sock *sk)
 {
 	struct rose_sock *rose = rose_sk(sk);
 
-	del_timer(&rose->idletimer);
-
-	if (rose->idle > 0) {
-		rose->idletimer.data     = (unsigned long)sk;
-		rose->idletimer.function = &rose_idletimer_expiry;
-		rose->idletimer.expires  = jiffies + rose->idle;
+	sk_stop_timer(sk, &rose->idletimer);
 
-		add_timer(&rose->idletimer);
-	}
+	if (rose->idle > 0)
+		sk_reset_timer(sk, &rose->idletimer, jiffies + rose->idle);
 }
 
 void rose_stop_heartbeat(struct sock *sk)
 {
-	del_timer(&sk->sk_timer);
+	sk_stop_timer(sk, &sk->sk_timer);
 }
 
 void rose_stop_timer(struct sock *sk)
 {
-	del_timer(&rose_sk(sk)->timer);
+	sk_stop_timer(sk, &rose_sk(sk)->timer);
 }
 
 void rose_stop_idletimer(struct sock *sk)
 {
-	del_timer(&rose_sk(sk)->idletimer);
+	sk_stop_timer(sk, &rose_sk(sk)->idletimer);
 }
 
 static void rose_heartbeat_expiry(unsigned long param)
@@ -138,9 +119,8 @@ static void rose_heartbeat_expiry(unsign
 		   is accepted() it isn't 'dead' so doesn't get removed. */
 		if (sock_flag(sk, SOCK_DESTROY) ||
 		    (sk->sk_state == TCP_LISTEN && sock_flag(sk, SOCK_DEAD))) {
-			bh_unlock_sock(sk);
 			rose_destroy_socket(sk);
-			return;
+			goto out_unlock;
 		}
 		break;
 
@@ -161,7 +141,10 @@ static void rose_heartbeat_expiry(unsign
 	}
 
 	rose_start_heartbeat(sk);
+
+out_unlock:
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void rose_timer_expiry(unsigned long param)
@@ -191,6 +174,7 @@ static void rose_timer_expiry(unsigned l
 		break;
 	}
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 static void rose_idletimer_expiry(unsigned long param)
@@ -214,4 +198,5 @@ static void rose_idletimer_expiry(unsign
 		sock_set_flag(sk, SOCK_DEAD);
 	}
 	bh_unlock_sock(sk);
+	sock_put(sk);
 }
