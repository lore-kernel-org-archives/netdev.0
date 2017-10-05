From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/lapb: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:49:47 -0700
Message-ID: <20171005004947.GA23109@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Hans Liljestrand <ishkamiel@gmail.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: linux-x25@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/lapb/lapb_iface.c |  4 ++--
 net/lapb/lapb_timer.c | 18 ++++++++----------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index e15314e3b464..db6e0afe3a20 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -127,8 +127,8 @@ static struct lapb_cb *lapb_create_cb(void)
 	skb_queue_head_init(&lapb->write_queue);
 	skb_queue_head_init(&lapb->ack_queue);
 
-	init_timer(&lapb->t1timer);
-	init_timer(&lapb->t2timer);
+	timer_setup(&lapb->t1timer, NULL, 0);
+	timer_setup(&lapb->t2timer, NULL, 0);
 
 	lapb->t1      = LAPB_DEFAULT_T1;
 	lapb->t2      = LAPB_DEFAULT_T2;
diff --git a/net/lapb/lapb_timer.c b/net/lapb/lapb_timer.c
index 1a5535bc3b8d..8bb469cb3abe 100644
--- a/net/lapb/lapb_timer.c
+++ b/net/lapb/lapb_timer.c
@@ -35,15 +35,14 @@
 #include <linux/interrupt.h>
 #include <net/lapb.h>
 
-static void lapb_t1timer_expiry(unsigned long);
-static void lapb_t2timer_expiry(unsigned long);
+static void lapb_t1timer_expiry(struct timer_list *);
+static void lapb_t2timer_expiry(struct timer_list *);
 
 void lapb_start_t1timer(struct lapb_cb *lapb)
 {
 	del_timer(&lapb->t1timer);
 
-	lapb->t1timer.data     = (unsigned long)lapb;
-	lapb->t1timer.function = &lapb_t1timer_expiry;
+	lapb->t1timer.function = (TIMER_FUNC_TYPE)lapb_t1timer_expiry;
 	lapb->t1timer.expires  = jiffies + lapb->t1;
 
 	add_timer(&lapb->t1timer);
@@ -53,8 +52,7 @@ void lapb_start_t2timer(struct lapb_cb *lapb)
 {
 	del_timer(&lapb->t2timer);
 
-	lapb->t2timer.data     = (unsigned long)lapb;
-	lapb->t2timer.function = &lapb_t2timer_expiry;
+	lapb->t2timer.function = (TIMER_FUNC_TYPE)lapb_t2timer_expiry;
 	lapb->t2timer.expires  = jiffies + lapb->t2;
 
 	add_timer(&lapb->t2timer);
@@ -75,9 +73,9 @@ int lapb_t1timer_running(struct lapb_cb *lapb)
 	return timer_pending(&lapb->t1timer);
 }
 
-static void lapb_t2timer_expiry(unsigned long param)
+static void lapb_t2timer_expiry(struct timer_list *t)
 {
-	struct lapb_cb *lapb = (struct lapb_cb *)param;
+	struct lapb_cb *lapb = from_timer(lapb, t, t2timer);
 
 	if (lapb->condition & LAPB_ACK_PENDING_CONDITION) {
 		lapb->condition &= ~LAPB_ACK_PENDING_CONDITION;
@@ -85,9 +83,9 @@ static void lapb_t2timer_expiry(unsigned long param)
 	}
 }
 
-static void lapb_t1timer_expiry(unsigned long param)
+static void lapb_t1timer_expiry(struct timer_list *t)
 {
-	struct lapb_cb *lapb = (struct lapb_cb *)param;
+	struct lapb_cb *lapb = from_timer(lapb, t, t1timer);
 
 	switch (lapb->state) {
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
