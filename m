From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: LLC: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:45:48 -0700
Message-ID: <20171024084548.GA23776@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:43473 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751848AbdJXIpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:45:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id s75so13969311pgs.0
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:45:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Hans Liljestrand <ishkamiel@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/llc_c_ac.h |  8 ++++----
 net/llc/llc_c_ac.c     | 27 +++++++++++++++++----------
 net/llc/llc_conn.c     | 12 ++++--------
 3 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/include/net/llc_c_ac.h b/include/net/llc_c_ac.h
index f3be818e73c1..e766300b3e99 100644
--- a/include/net/llc_c_ac.h
+++ b/include/net/llc_c_ac.h
@@ -171,10 +171,10 @@ int llc_conn_ac_rst_sendack_flag(struct sock *sk, struct sk_buff *skb);
 int llc_conn_ac_send_i_rsp_as_ack(struct sock *sk, struct sk_buff *skb);
 int llc_conn_ac_send_i_as_ack(struct sock *sk, struct sk_buff *skb);
 
-void llc_conn_busy_tmr_cb(unsigned long timeout_data);
-void llc_conn_pf_cycle_tmr_cb(unsigned long timeout_data);
-void llc_conn_ack_tmr_cb(unsigned long timeout_data);
-void llc_conn_rej_tmr_cb(unsigned long timeout_data);
+void llc_conn_busy_tmr_cb(struct timer_list *t);
+void llc_conn_pf_cycle_tmr_cb(struct timer_list *t);
+void llc_conn_ack_tmr_cb(struct timer_list *t);
+void llc_conn_rej_tmr_cb(struct timer_list *t);
 
 void llc_conn_set_p_flag(struct sock *sk, u8 value);
 #endif /* LLC_C_AC_H */
diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index ea225bd2672c..f59648018060 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1318,9 +1318,8 @@ static int llc_conn_ac_inc_vs_by_1(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static void llc_conn_tmr_common_cb(unsigned long timeout_data, u8 type)
+static void llc_conn_tmr_common_cb(struct sock *sk, u8 type)
 {
-	struct sock *sk = (struct sock *)timeout_data;
 	struct sk_buff *skb = alloc_skb(0, GFP_ATOMIC);
 
 	bh_lock_sock(sk);
@@ -1334,24 +1333,32 @@ static void llc_conn_tmr_common_cb(unsigned long timeout_data, u8 type)
 	bh_unlock_sock(sk);
 }
 
-void llc_conn_pf_cycle_tmr_cb(unsigned long timeout_data)
+void llc_conn_pf_cycle_tmr_cb(struct timer_list *t)
 {
-	llc_conn_tmr_common_cb(timeout_data, LLC_CONN_EV_TYPE_P_TMR);
+	struct llc_sock *llc = from_timer(llc, t, pf_cycle_timer.timer);
+
+	llc_conn_tmr_common_cb(&llc->sk, LLC_CONN_EV_TYPE_P_TMR);
 }
 
-void llc_conn_busy_tmr_cb(unsigned long timeout_data)
+void llc_conn_busy_tmr_cb(struct timer_list *t)
 {
-	llc_conn_tmr_common_cb(timeout_data, LLC_CONN_EV_TYPE_BUSY_TMR);
+	struct llc_sock *llc = from_timer(llc, t, busy_state_timer.timer);
+
+	llc_conn_tmr_common_cb(&llc->sk, LLC_CONN_EV_TYPE_BUSY_TMR);
 }
 
-void llc_conn_ack_tmr_cb(unsigned long timeout_data)
+void llc_conn_ack_tmr_cb(struct timer_list *t)
 {
-	llc_conn_tmr_common_cb(timeout_data, LLC_CONN_EV_TYPE_ACK_TMR);
+	struct llc_sock *llc = from_timer(llc, t, ack_timer.timer);
+
+	llc_conn_tmr_common_cb(&llc->sk, LLC_CONN_EV_TYPE_ACK_TMR);
 }
 
-void llc_conn_rej_tmr_cb(unsigned long timeout_data)
+void llc_conn_rej_tmr_cb(struct timer_list *t)
 {
-	llc_conn_tmr_common_cb(timeout_data, LLC_CONN_EV_TYPE_REJ_TMR);
+	struct llc_sock *llc = from_timer(llc, t, rej_sent_timer.timer);
+
+	llc_conn_tmr_common_cb(&llc->sk, LLC_CONN_EV_TYPE_REJ_TMR);
 }
 
 int llc_conn_ac_rst_vs(struct sock *sk, struct sk_buff *skb)
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 5e91b47f0d2a..9177dbb16dce 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -902,20 +902,16 @@ static void llc_sk_init(struct sock *sk)
 	llc->inc_cntr = llc->dec_cntr = 2;
 	llc->dec_step = llc->connect_step = 1;
 
-	setup_timer(&llc->ack_timer.timer, llc_conn_ack_tmr_cb,
-			(unsigned long)sk);
+	timer_setup(&llc->ack_timer.timer, llc_conn_ack_tmr_cb, 0);
 	llc->ack_timer.expire	      = sysctl_llc2_ack_timeout;
 
-	setup_timer(&llc->pf_cycle_timer.timer, llc_conn_pf_cycle_tmr_cb,
-			(unsigned long)sk);
+	timer_setup(&llc->pf_cycle_timer.timer, llc_conn_pf_cycle_tmr_cb, 0);
 	llc->pf_cycle_timer.expire	   = sysctl_llc2_p_timeout;
 
-	setup_timer(&llc->rej_sent_timer.timer, llc_conn_rej_tmr_cb,
-			(unsigned long)sk);
+	timer_setup(&llc->rej_sent_timer.timer, llc_conn_rej_tmr_cb, 0);
 	llc->rej_sent_timer.expire	   = sysctl_llc2_rej_timeout;
 
-	setup_timer(&llc->busy_state_timer.timer, llc_conn_busy_tmr_cb,
-			(unsigned long)sk);
+	timer_setup(&llc->busy_state_timer.timer, llc_conn_busy_tmr_cb, 0);
 	llc->busy_state_timer.expire	     = sysctl_llc2_busy_timeout;
 
 	llc->n2 = 2;   /* max retransmit */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
