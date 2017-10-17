From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 52/58] net/core: Convert sk_timer users to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:36 -0700
Message-ID: <1508200182-104605-53-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Ralf Baechle <ralf@linux-mips.org>,
        Andrew Hendry <andrew.hendry@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        linzhang <xiaolou4617@gmail.com>, Ingo Molnar <mingo@kernel.org>,
        netdev@vger.kernel.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly for all users of sk_timer.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>
Cc: linzhang <xiaolou4617@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: netdev@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: linux-x25@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/core/sock.c        |  2 +-
 net/netrom/af_netrom.c |  6 +++---
 net/netrom/nr_timer.c  | 47 ++++++++++++++++++++++++-----------------------
 net/rose/rose_timer.c  |  8 ++++----
 net/x25/af_x25.c       |  8 +++++---
 net/x25/x25_timer.c    | 17 +++++++++--------
 6 files changed, 46 insertions(+), 42 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 57113b42b2c8..34b3ac2de44a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2685,7 +2685,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk_init_common(sk);
 	sk->sk_send_head	=	NULL;
 
-	setup_timer(&sk->sk_timer, NULL, (unsigned long)sk);
+	timer_setup(&sk->sk_timer, NULL, 0);
 
 	sk->sk_allocation	=	GFP_KERNEL;
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ebf16f7f9089..2dec3583c97d 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -241,9 +241,9 @@ void nr_destroy_socket(struct sock *);
 /*
  *	Handler for deferred kills.
  */
-static void nr_destroy_timer(unsigned long data)
+static void nr_destroy_timer(struct timer_list *t)
 {
-	struct sock *sk=(struct sock *)data;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 	bh_lock_sock(sk);
 	sock_hold(sk);
 	nr_destroy_socket(sk);
@@ -284,7 +284,7 @@ void nr_destroy_socket(struct sock *sk)
 
 	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
-		sk->sk_timer.function = nr_destroy_timer;
+		sk->sk_timer.function = (TIMER_FUNC_TYPE)nr_destroy_timer;
 		sk->sk_timer.expires  = jiffies + 2 * HZ;
 		add_timer(&sk->sk_timer);
 	} else
diff --git a/net/netrom/nr_timer.c b/net/netrom/nr_timer.c
index f84ce71f1f5f..43569aea0f5e 100644
--- a/net/netrom/nr_timer.c
+++ b/net/netrom/nr_timer.c
@@ -29,23 +29,23 @@
 #include <linux/interrupt.h>
 #include <net/netrom.h>
 
-static void nr_heartbeat_expiry(unsigned long);
-static void nr_t1timer_expiry(unsigned long);
-static void nr_t2timer_expiry(unsigned long);
-static void nr_t4timer_expiry(unsigned long);
-static void nr_idletimer_expiry(unsigned long);
+static void nr_heartbeat_expiry(struct timer_list *);
+static void nr_t1timer_expiry(struct timer_list *);
+static void nr_t2timer_expiry(struct timer_list *);
+static void nr_t4timer_expiry(struct timer_list *);
+static void nr_idletimer_expiry(struct timer_list *);
 
 void nr_init_timers(struct sock *sk)
 {
 	struct nr_sock *nr = nr_sk(sk);
 
-	setup_timer(&nr->t1timer, nr_t1timer_expiry, (unsigned long)sk);
-	setup_timer(&nr->t2timer, nr_t2timer_expiry, (unsigned long)sk);
-	setup_timer(&nr->t4timer, nr_t4timer_expiry, (unsigned long)sk);
-	setup_timer(&nr->idletimer, nr_idletimer_expiry, (unsigned long)sk);
+	timer_setup(&nr->t1timer, nr_t1timer_expiry, 0);
+	timer_setup(&nr->t2timer, nr_t2timer_expiry, 0);
+	timer_setup(&nr->t4timer, nr_t4timer_expiry, 0);
+	timer_setup(&nr->idletimer, nr_idletimer_expiry, 0);
 
 	/* initialized by sock_init_data */
-	sk->sk_timer.function = &nr_heartbeat_expiry;
+	sk->sk_timer.function = (TIMER_FUNC_TYPE)nr_heartbeat_expiry;
 }
 
 void nr_start_t1timer(struct sock *sk)
@@ -112,9 +112,9 @@ int nr_t1timer_running(struct sock *sk)
 	return timer_pending(&nr_sk(sk)->t1timer);
 }
 
-static void nr_heartbeat_expiry(unsigned long param)
+static void nr_heartbeat_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 	struct nr_sock *nr = nr_sk(sk);
 
 	bh_lock_sock(sk);
@@ -151,10 +151,10 @@ static void nr_heartbeat_expiry(unsigned long param)
 	bh_unlock_sock(sk);
 }
 
-static void nr_t2timer_expiry(unsigned long param)
+static void nr_t2timer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
-	struct nr_sock *nr = nr_sk(sk);
+	struct nr_sock *nr = from_timer(nr, t, t2timer);
+	struct sock *sk = &nr->sock;
 
 	bh_lock_sock(sk);
 	if (nr->condition & NR_COND_ACK_PENDING) {
@@ -164,19 +164,20 @@ static void nr_t2timer_expiry(unsigned long param)
 	bh_unlock_sock(sk);
 }
 
-static void nr_t4timer_expiry(unsigned long param)
+static void nr_t4timer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct nr_sock *nr = from_timer(nr, t, t4timer);
+	struct sock *sk = &nr->sock;
 
 	bh_lock_sock(sk);
 	nr_sk(sk)->condition &= ~NR_COND_PEER_RX_BUSY;
 	bh_unlock_sock(sk);
 }
 
-static void nr_idletimer_expiry(unsigned long param)
+static void nr_idletimer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
-	struct nr_sock *nr = nr_sk(sk);
+	struct nr_sock *nr = from_timer(nr, t, idletimer);
+	struct sock *sk = &nr->sock;
 
 	bh_lock_sock(sk);
 
@@ -201,10 +202,10 @@ static void nr_idletimer_expiry(unsigned long param)
 	bh_unlock_sock(sk);
 }
 
-static void nr_t1timer_expiry(unsigned long param)
+static void nr_t1timer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
-	struct nr_sock *nr = nr_sk(sk);
+	struct nr_sock *nr = from_timer(nr, t, t1timer);
+	struct sock *sk = &nr->sock;
 
 	bh_lock_sock(sk);
 	switch (nr->state) {
diff --git a/net/rose/rose_timer.c b/net/rose/rose_timer.c
index e08201185214..ea613b2a9735 100644
--- a/net/rose/rose_timer.c
+++ b/net/rose/rose_timer.c
@@ -28,7 +28,7 @@
 #include <linux/interrupt.h>
 #include <net/rose.h>
 
-static void rose_heartbeat_expiry(unsigned long);
+static void rose_heartbeat_expiry(struct timer_list *t);
 static void rose_timer_expiry(struct timer_list *);
 static void rose_idletimer_expiry(struct timer_list *);
 
@@ -36,7 +36,7 @@ void rose_start_heartbeat(struct sock *sk)
 {
 	del_timer(&sk->sk_timer);
 
-	sk->sk_timer.function = &rose_heartbeat_expiry;
+	sk->sk_timer.function = (TIMER_FUNC_TYPE)rose_heartbeat_expiry;
 	sk->sk_timer.expires  = jiffies + 5 * HZ;
 
 	add_timer(&sk->sk_timer);
@@ -119,9 +119,9 @@ void rose_stop_idletimer(struct sock *sk)
 	del_timer(&rose_sk(sk)->idletimer);
 }
 
-static void rose_heartbeat_expiry(unsigned long param)
+static void rose_heartbeat_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 	struct rose_sock *rose = rose_sk(sk);
 
 	bh_lock_sock(sk);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c590c0bd1393..ea87143314f3 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -374,9 +374,11 @@ static void __x25_destroy_socket(struct sock *);
 /*
  *	handler for deferred kills.
  */
-static void x25_destroy_timer(unsigned long data)
+static void x25_destroy_timer(struct timer_list *t)
 {
-	x25_destroy_socket_from_timer((struct sock *)data);
+	struct sock *sk = from_timer(sk, t, sk_timer);
+
+	x25_destroy_socket_from_timer(sk);
 }
 
 /*
@@ -413,7 +415,7 @@ static void __x25_destroy_socket(struct sock *sk)
 	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
 		sk->sk_timer.expires  = jiffies + 10 * HZ;
-		sk->sk_timer.function = x25_destroy_timer;
+		sk->sk_timer.function = (TIMER_FUNC_TYPE)x25_destroy_timer;
 		add_timer(&sk->sk_timer);
 	} else {
 		/* drop last reference so sock_put will free */
diff --git a/net/x25/x25_timer.c b/net/x25/x25_timer.c
index de5cec41d100..1dfba3c23459 100644
--- a/net/x25/x25_timer.c
+++ b/net/x25/x25_timer.c
@@ -26,17 +26,17 @@
 #include <net/tcp_states.h>
 #include <net/x25.h>
 
-static void x25_heartbeat_expiry(unsigned long);
-static void x25_timer_expiry(unsigned long);
+static void x25_heartbeat_expiry(struct timer_list *t);
+static void x25_timer_expiry(struct timer_list *t);
 
 void x25_init_timers(struct sock *sk)
 {
 	struct x25_sock *x25 = x25_sk(sk);
 
-	setup_timer(&x25->timer, x25_timer_expiry, (unsigned long)sk);
+	timer_setup(&x25->timer, x25_timer_expiry, 0);
 
 	/* initialized by sock_init_data */
-	sk->sk_timer.function = &x25_heartbeat_expiry;
+	sk->sk_timer.function = (TIMER_FUNC_TYPE)x25_heartbeat_expiry;
 }
 
 void x25_start_heartbeat(struct sock *sk)
@@ -92,9 +92,9 @@ unsigned long x25_display_timer(struct sock *sk)
 	return x25->timer.expires - jiffies;
 }
 
-static void x25_heartbeat_expiry(unsigned long param)
+static void x25_heartbeat_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) /* can currently only occur in state 3 */
@@ -159,9 +159,10 @@ static inline void x25_do_timer_expiry(struct sock * sk)
 	}
 }
 
-static void x25_timer_expiry(unsigned long param)
+static void x25_timer_expiry(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)param;
+	struct x25_sock *x25 = from_timer(x25, t, timer);
+	struct sock *sk = &x25->sk;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) { /* can currently only occur in state 3 */
-- 
2.7.4
