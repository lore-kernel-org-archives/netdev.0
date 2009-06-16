From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 03:47:52 -0700 (PDT)
Message-ID: <20090616.034752.226811527.davem@davemloft.net>
References: <20090615.050449.144947903.davem@davemloft.net>
	<20090616091538.GA4184@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbZFPKrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 06:47:49 -0400
In-Reply-To: <20090616091538.GA4184@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 16 Jun 2009 11:15:38 +0200

> 
> hm, FYI, these bits caused widespread scheduling-while-atomic 
> problems on most of my test-systems:
> 
> BUG: sleeping function called from invalid context at net/core/sock.c:1851
> in_atomic(): 1, irqs_disabled(): 0, pid: 544, name: rcu_torture_rea
> 1 lock held by rcu_torture_rea/544:
>  #0:  (&sk->sk_timer){......}, at: [<ffffffff81060560>] run_timer_softirq+0x120/0x2e0
> Pid: 544, comm: rcu_torture_rea Tainted: G        W  2.6.30-tip #54067
> Call Trace:
>  [<ffffffff810820c3>] ? __debug_show_held_locks+0x13/0x30
>  [<ffffffff810489e6>] __might_sleep+0xf6/0x120
>  [<ffffffff81b3921d>] lock_sock_nested+0x3d/0x120
>  [<ffffffff81c1a7d2>] x25_destroy_socket+0x22/0x180

Please give this patch a try.

diff --git a/include/net/x25.h b/include/net/x25.h
index fc3f03d..2cda040 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -187,7 +187,7 @@ extern int  x25_addr_ntoa(unsigned char *, struct x25_address *,
 extern int  x25_addr_aton(unsigned char *, struct x25_address *,
 			  struct x25_address *);
 extern struct sock *x25_find_socket(unsigned int, struct x25_neigh *);
-extern void x25_destroy_socket(struct sock *);
+extern void x25_destroy_socket_from_timer(struct sock *);
 extern int  x25_rx_call_request(struct sk_buff *, struct x25_neigh *, unsigned int);
 extern void x25_kill_by_neigh(struct x25_neigh *);
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index ed80af8..c51f309 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -332,14 +332,14 @@ static unsigned int x25_new_lci(struct x25_neigh *nb)
 /*
  *	Deferred destroy.
  */
-void x25_destroy_socket(struct sock *);
+static void __x25_destroy_socket(struct sock *);
 
 /*
  *	handler for deferred kills.
  */
 static void x25_destroy_timer(unsigned long data)
 {
-	x25_destroy_socket((struct sock *)data);
+	x25_destroy_socket_from_timer((struct sock *)data);
 }
 
 /*
@@ -349,12 +349,10 @@ static void x25_destroy_timer(unsigned long data)
  *	will touch it and we are (fairly 8-) ) safe.
  *	Not static as it's used by the timer
  */
-void x25_destroy_socket(struct sock *sk)
+static void __x25_destroy_socket(struct sock *sk)
 {
 	struct sk_buff *skb;
 
-	sock_hold(sk);
-	lock_sock(sk);
 	x25_stop_heartbeat(sk);
 	x25_stop_timer(sk);
 
@@ -385,7 +383,22 @@ void x25_destroy_socket(struct sock *sk)
 		/* drop last reference so sock_put will free */
 		__sock_put(sk);
 	}
+}
 
+void x25_destroy_socket_from_timer(struct sock *sk)
+{
+	sock_hold(sk);
+	bh_lock_sock(sk);
+	__x25_destroy_socket(sk);
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+static void x25_destroy_socket(struct sock *sk)
+{
+	sock_hold(sk);
+	lock_sock(sk);
+	__x25_destroy_socket(sk);
 	release_sock(sk);
 	sock_put(sk);
 }
diff --git a/net/x25/x25_timer.c b/net/x25/x25_timer.c
index d3e3e54..5c5db1a 100644
--- a/net/x25/x25_timer.c
+++ b/net/x25/x25_timer.c
@@ -113,7 +113,7 @@ static void x25_heartbeat_expiry(unsigned long param)
 			    (sk->sk_state == TCP_LISTEN &&
 			     sock_flag(sk, SOCK_DEAD))) {
 				bh_unlock_sock(sk);
-				x25_destroy_socket(sk);
+				x25_destroy_socket_from_timer(sk);
 				return;
 			}
 			break;
