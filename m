From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/rose: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:49:56 -0700
Message-ID: <20171005004956.GA23147@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/rose/af_rose.c    | 13 +++++++------
 net/rose/rose_link.c  | 16 +++++++---------
 net/rose/rose_route.c |  8 ++++----
 net/rose/rose_timer.c | 30 +++++++++++++-----------------
 4 files changed, 31 insertions(+), 36 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4a9729257023..b873673740e2 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -318,9 +318,11 @@ void rose_destroy_socket(struct sock *);
 /*
  *	Handler for deferred kills.
  */
-static void rose_destroy_timer(unsigned long data)
+static void rose_destroy_timer(struct timer_list *t)
 {
-	rose_destroy_socket((struct sock *)data);
+	struct sock *sk = from_timer(sk, t, sk_timer);
+
+	rose_destroy_socket(sk);
 }
 
 /*
@@ -353,8 +355,7 @@ void rose_destroy_socket(struct sock *sk)
 
 	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
-		setup_timer(&sk->sk_timer, rose_destroy_timer,
-				(unsigned long)sk);
+		timer_setup(&sk->sk_timer, rose_destroy_timer, 0);
 		sk->sk_timer.expires  = jiffies + 10 * HZ;
 		add_timer(&sk->sk_timer);
 	} else
@@ -538,8 +539,8 @@ static int rose_create(struct net *net, struct socket *sock, int protocol,
 	sock->ops    = &rose_proto_ops;
 	sk->sk_protocol = protocol;
 
-	init_timer(&rose->timer);
-	init_timer(&rose->idletimer);
+	timer_setup(&rose->timer, NULL, 0);
+	timer_setup(&rose->idletimer, NULL, 0);
 
 	rose->t1   = msecs_to_jiffies(sysctl_rose_call_request_timeout);
 	rose->t2   = msecs_to_jiffies(sysctl_rose_reset_request_timeout);
diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index c76638cc2cd5..cda4c6678ef1 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -27,8 +27,8 @@
 #include <linux/interrupt.h>
 #include <net/rose.h>
 
-static void rose_ftimer_expiry(unsigned long);
-static void rose_t0timer_expiry(unsigned long);
+static void rose_ftimer_expiry(struct timer_list *);
+static void rose_t0timer_expiry(struct timer_list *);
 
 static void rose_transmit_restart_confirmation(struct rose_neigh *neigh);
 static void rose_transmit_restart_request(struct rose_neigh *neigh);
@@ -37,8 +37,7 @@ void rose_start_ftimer(struct rose_neigh *neigh)
 {
 	del_timer(&neigh->ftimer);
 
-	neigh->ftimer.data     = (unsigned long)neigh;
-	neigh->ftimer.function = &rose_ftimer_expiry;
+	neigh->ftimer.function = (TIMER_FUNC_TYPE)rose_ftimer_expiry;
 	neigh->ftimer.expires  =
 		jiffies + msecs_to_jiffies(sysctl_rose_link_fail_timeout);
 
@@ -49,8 +48,7 @@ static void rose_start_t0timer(struct rose_neigh *neigh)
 {
 	del_timer(&neigh->t0timer);
 
-	neigh->t0timer.data     = (unsigned long)neigh;
-	neigh->t0timer.function = &rose_t0timer_expiry;
+	neigh->t0timer.function = (TIMER_FUNC_TYPE)rose_t0timer_expiry;
 	neigh->t0timer.expires  =
 		jiffies + msecs_to_jiffies(sysctl_rose_restart_request_timeout);
 
@@ -77,13 +75,13 @@ static int rose_t0timer_running(struct rose_neigh *neigh)
 	return timer_pending(&neigh->t0timer);
 }
 
-static void rose_ftimer_expiry(unsigned long param)
+static void rose_ftimer_expiry(struct timer_list *t)
 {
 }
 
-static void rose_t0timer_expiry(unsigned long param)
+static void rose_t0timer_expiry(struct timer_list *t)
 {
-	struct rose_neigh *neigh = (struct rose_neigh *)param;
+	struct rose_neigh *neigh = from_timer(neigh, t, t0timer);
 
 	rose_transmit_restart_request(neigh);
 
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 452bbb38d943..65921cd10323 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -104,8 +104,8 @@ static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 
 		skb_queue_head_init(&rose_neigh->queue);
 
-		init_timer(&rose_neigh->ftimer);
-		init_timer(&rose_neigh->t0timer);
+		timer_setup(&rose_neigh->ftimer, NULL, 0);
+		timer_setup(&rose_neigh->t0timer, NULL, 0);
 
 		if (rose_route->ndigis != 0) {
 			rose_neigh->digipeat =
@@ -390,8 +390,8 @@ void rose_add_loopback_neigh(void)
 
 	skb_queue_head_init(&sn->queue);
 
-	init_timer(&sn->ftimer);
-	init_timer(&sn->t0timer);
+	timer_setup(&sn->ftimer, NULL, 0);
+	timer_setup(&sn->t0timer, NULL, 0);
 
 	spin_lock_bh(&rose_neigh_list_lock);
 	sn->next = rose_neigh_list;
diff --git a/net/rose/rose_timer.c b/net/rose/rose_timer.c
index bc5469d6d9cb..3b89d66f15bb 100644
--- a/net/rose/rose_timer.c
+++ b/net/rose/rose_timer.c
@@ -29,8 +29,8 @@
 #include <net/rose.h>
 
 static void rose_heartbeat_expiry(unsigned long);
-static void rose_timer_expiry(unsigned long);
-static void rose_idletimer_expiry(unsigned long);
+static void rose_timer_expiry(struct timer_list *);
+static void rose_idletimer_expiry(struct timer_list *);
 
 void rose_start_heartbeat(struct sock *sk)
 {
@@ -49,8 +49,7 @@ void rose_start_t1timer(struct sock *sk)
 
 	del_timer(&rose->timer);
 
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
+	rose->timer.function = (TIMER_FUNC_TYPE)rose_timer_expiry;
 	rose->timer.expires  = jiffies + rose->t1;
 
 	add_timer(&rose->timer);
@@ -62,8 +61,7 @@ void rose_start_t2timer(struct sock *sk)
 
 	del_timer(&rose->timer);
 
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
+	rose->timer.function = (TIMER_FUNC_TYPE)rose_timer_expiry;
 	rose->timer.expires  = jiffies + rose->t2;
 
 	add_timer(&rose->timer);
@@ -75,8 +73,7 @@ void rose_start_t3timer(struct sock *sk)
 
 	del_timer(&rose->timer);
 
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
+	rose->timer.function = (TIMER_FUNC_TYPE)rose_timer_expiry;
 	rose->timer.expires  = jiffies + rose->t3;
 
 	add_timer(&rose->timer);
@@ -88,8 +85,7 @@ void rose_start_hbtimer(struct sock *sk)
 
 	del_timer(&rose->timer);
 
-	rose->timer.data     = (unsigned long)sk;
-	rose->timer.function = &rose_timer_expiry;
+	rose->timer.function = (TIMER_FUNC_TYPE)rose_timer_expiry;
 	rose->timer.expires  = jiffies + rose->hb;
 
 	add_timer(&rose->timer);
@@ -102,8 +98,7 @@ void rose_start_idletimer(struct sock *sk)
 	del_timer(&rose->idletimer);
 
 	if (rose->idle > 0) {
-		rose->idletimer.data     = (unsigned long)sk;
-		rose->idletimer.function = &rose_idletimer_expiry;
+		rose->idletimer.function = (TIMER_FUNC_TYPE)rose_idletimer_expiry;
 		rose->idletimer.expires  = jiffies + rose->idle;
 
 		add_timer(&rose->idletimer);
@@ -163,10 +158,10 @@ static void rose_heartbeat_expiry(unsigned long param)
 	bh_unlock_sock(sk);
 }
 
-static void rose_timer_expiry(unsigned long param)
+static void rose_timer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
-	struct rose_sock *rose = rose_sk(sk);
+	struct rose_sock *rose = from_timer(rose, t, timer);
+	struct sock *sk = &rose->sock;
 
 	bh_lock_sock(sk);
 	switch (rose->state) {
@@ -192,9 +187,10 @@ static void rose_timer_expiry(unsigned long param)
 	bh_unlock_sock(sk);
 }
 
-static void rose_idletimer_expiry(unsigned long param)
+static void rose_idletimer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct rose_sock *rose = from_timer(rose, t, idletimer);
+	struct sock *sk = &rose->sock;
 
 	bh_lock_sock(sk);
 	rose_clear_queues(sk);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
