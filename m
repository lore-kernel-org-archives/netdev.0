From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 57/58] ipv4: timewait: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:41 -0700
Message-ID: <1508200182-104605-58-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/ipv4/inet_timewait_sock.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 5b039159e67a..a4bab81f1462 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -142,9 +142,9 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
 
-static void tw_timer_handler(unsigned long data)
+static void tw_timer_handler(struct timer_list *t)
 {
-	struct inet_timewait_sock *tw = (struct inet_timewait_sock *)data;
+	struct inet_timewait_sock *tw = from_timer(tw, t, tw_timer);
 
 	if (tw->tw_kill)
 		__NET_INC_STATS(twsk_net(tw), LINUX_MIB_TIMEWAITKILLED);
@@ -188,8 +188,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic64_set(&tw->tw_cookie, atomic64_read(&sk->sk_cookie));
 		twsk_net_set(tw, sock_net(sk));
-		setup_pinned_timer(&tw->tw_timer, tw_timer_handler,
-				   (unsigned long)tw);
+		timer_setup(&tw->tw_timer, tw_timer_handler, TIMER_PINNED);
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
 		 * to a non null value before everything is setup for this
-- 
2.7.4
