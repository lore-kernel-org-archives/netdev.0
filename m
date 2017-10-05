From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/core: Collapse redundant sk_timer callback data
Date: Wed, 4 Oct 2017 17:52:38 -0700
Message-ID: <20171005005238.GA23626@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        Andrew Hendry <andrew.hendry@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Colin Ian King <colin.king@canonical.com>,
        Ingo Molnar <mingo@kernel.org>,
        linzhang <xiaolou4617@gmail.com>, netdev@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-x25@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The core sk_timer initializer can provide the common .data assignment
instead of it being set separately in users.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Colin Ian King <colin.king@canonical.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linzhang <xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: linux-x25@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/core/sock.c       | 2 +-
 net/netrom/nr_timer.c | 1 -
 net/rose/rose_timer.c | 1 -
 net/x25/af_x25.c      | 1 -
 net/x25/x25_timer.c   | 1 -
 5 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..3a0233106f62 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2678,7 +2678,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk_init_common(sk);
 	sk->sk_send_head	=	NULL;
 
-	init_timer(&sk->sk_timer);
+	setup_timer(&sk->sk_timer, NULL, (unsigned long)sk);
 
 	sk->sk_allocation	=	GFP_KERNEL;
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
diff --git a/net/netrom/nr_timer.c b/net/netrom/nr_timer.c
index 94d05806a9a2..f84ce71f1f5f 100644
--- a/net/netrom/nr_timer.c
+++ b/net/netrom/nr_timer.c
@@ -45,7 +45,6 @@ void nr_init_timers(struct sock *sk)
 	setup_timer(&nr->idletimer, nr_idletimer_expiry, (unsigned long)sk);
 
 	/* initialized by sock_init_data */
-	sk->sk_timer.data     = (unsigned long)sk;
 	sk->sk_timer.function = &nr_heartbeat_expiry;
 }
 
diff --git a/net/rose/rose_timer.c b/net/rose/rose_timer.c
index 3b89d66f15bb..e08201185214 100644
--- a/net/rose/rose_timer.c
+++ b/net/rose/rose_timer.c
@@ -36,7 +36,6 @@ void rose_start_heartbeat(struct sock *sk)
 {
 	del_timer(&sk->sk_timer);
 
-	sk->sk_timer.data     = (unsigned long)sk;
 	sk->sk_timer.function = &rose_heartbeat_expiry;
 	sk->sk_timer.expires  = jiffies + 5 * HZ;
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index ac095936552d..c590c0bd1393 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -414,7 +414,6 @@ static void __x25_destroy_socket(struct sock *sk)
 		/* Defer: outstanding buffers */
 		sk->sk_timer.expires  = jiffies + 10 * HZ;
 		sk->sk_timer.function = x25_destroy_timer;
-		sk->sk_timer.data = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
 	} else {
 		/* drop last reference so sock_put will free */
diff --git a/net/x25/x25_timer.c b/net/x25/x25_timer.c
index 5c5db1a36399..de5cec41d100 100644
--- a/net/x25/x25_timer.c
+++ b/net/x25/x25_timer.c
@@ -36,7 +36,6 @@ void x25_init_timers(struct sock *sk)
 	setup_timer(&x25->timer, x25_timer_expiry, (unsigned long)sk);
 
 	/* initialized by sock_init_data */
-	sk->sk_timer.data     = (unsigned long)sk;
 	sk->sk_timer.function = &x25_heartbeat_expiry;
 }
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
