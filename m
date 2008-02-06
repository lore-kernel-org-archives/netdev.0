From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][AX25] Fwd: SMP with AX.25
Date: Wed, 6 Feb 2008 08:15:09 +0000
Message-ID: <20080206081509.GD4496@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Jann Traschewski <jann@gmx.de>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:19385 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbYBFIIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 03:08:04 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1879691rvb.1
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2008 00:08:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:45:29AM +0000, Jarek Poplawski wrote:
...
> From: Jann Traschewski <jann@gmx.de>
> Subject: SMP with AX.25


[AX25] ax25_timer: use mod_timer instead of add_timer

According to one of Jann's OOPS reports it looks like
BUG_ON(timer_pending(timer)) triggers during add_timer()
in ax25_start_t1timer(). This patch changes current use
of: init_timer(), add_timer() and del_timer() to
setup_timer() with mod_timer(), which should be safer
anyway.


Reported-by: Jann Traschewski <jann@gmx.de>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/ax25.h    |    1 +
 net/ax25/af_ax25.c    |    6 +----
 net/ax25/ax25_timer.c |   60 +++++++++++++++++-------------------------------
 3 files changed, 23 insertions(+), 44 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 32a57e1..3f0236f 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -416,6 +416,7 @@ extern void ax25_calculate_rtt(ax25_cb *);
 extern void ax25_disconnect(ax25_cb *, int);
 
 /* ax25_timer.c */
+extern void ax25_setup_timers(ax25_cb *);
 extern void ax25_start_heartbeat(ax25_cb *);
 extern void ax25_start_t1timer(ax25_cb *);
 extern void ax25_start_t2timer(ax25_cb *);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 8fc64e3..94b2b1b 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -510,11 +510,7 @@ ax25_cb *ax25_create_cb(void)
 	skb_queue_head_init(&ax25->ack_queue);
 	skb_queue_head_init(&ax25->reseq_queue);
 
-	init_timer(&ax25->timer);
-	init_timer(&ax25->t1timer);
-	init_timer(&ax25->t2timer);
-	init_timer(&ax25->t3timer);
-	init_timer(&ax25->idletimer);
+	ax25_setup_timers(ax25);
 
 	ax25_fillin_cb(ax25, NULL);
 
diff --git a/net/ax25/ax25_timer.c b/net/ax25/ax25_timer.c
index 7259486..db29ea7 100644
--- a/net/ax25/ax25_timer.c
+++ b/net/ax25/ax25_timer.c
@@ -40,63 +40,45 @@ static void ax25_t2timer_expiry(unsigned long);
 static void ax25_t3timer_expiry(unsigned long);
 static void ax25_idletimer_expiry(unsigned long);
 
-void ax25_start_heartbeat(ax25_cb *ax25)
+void ax25_setup_timers(ax25_cb *ax25)
 {
-	del_timer(&ax25->timer);
-
-	ax25->timer.data     = (unsigned long)ax25;
-	ax25->timer.function = &ax25_heartbeat_expiry;
-	ax25->timer.expires  = jiffies + 5 * HZ;
+	setup_timer(&ax25->timer, ax25_heartbeat_expiry, (unsigned long)ax25);
+	setup_timer(&ax25->t1timer, ax25_t1timer_expiry, (unsigned long)ax25);
+	setup_timer(&ax25->t2timer, ax25_t2timer_expiry, (unsigned long)ax25);
+	setup_timer(&ax25->t3timer, ax25_t3timer_expiry, (unsigned long)ax25);
+	setup_timer(&ax25->idletimer, ax25_idletimer_expiry,
+		    (unsigned long)ax25);
+}
 
-	add_timer(&ax25->timer);
+void ax25_start_heartbeat(ax25_cb *ax25)
+{
+	mod_timer(&ax25->timer, jiffies + 5 * HZ);
 }
 
 void ax25_start_t1timer(ax25_cb *ax25)
 {
-	del_timer(&ax25->t1timer);
-
-	ax25->t1timer.data     = (unsigned long)ax25;
-	ax25->t1timer.function = &ax25_t1timer_expiry;
-	ax25->t1timer.expires  = jiffies + ax25->t1;
-
-	add_timer(&ax25->t1timer);
+	mod_timer(&ax25->t1timer, jiffies + ax25->t1);
 }
 
 void ax25_start_t2timer(ax25_cb *ax25)
 {
-	del_timer(&ax25->t2timer);
-
-	ax25->t2timer.data     = (unsigned long)ax25;
-	ax25->t2timer.function = &ax25_t2timer_expiry;
-	ax25->t2timer.expires  = jiffies + ax25->t2;
-
-	add_timer(&ax25->t2timer);
+	mod_timer(&ax25->t2timer, jiffies + ax25->t2);
 }
 
 void ax25_start_t3timer(ax25_cb *ax25)
 {
-	del_timer(&ax25->t3timer);
-
-	if (ax25->t3 > 0) {
-		ax25->t3timer.data     = (unsigned long)ax25;
-		ax25->t3timer.function = &ax25_t3timer_expiry;
-		ax25->t3timer.expires  = jiffies + ax25->t3;
-
-		add_timer(&ax25->t3timer);
-	}
+	if (ax25->t3 > 0)
+		mod_timer(&ax25->t3timer, jiffies + ax25->t3);
+	else
+		del_timer(&ax25->t3timer);
 }
 
 void ax25_start_idletimer(ax25_cb *ax25)
 {
-	del_timer(&ax25->idletimer);
-
-	if (ax25->idle > 0) {
-		ax25->idletimer.data     = (unsigned long)ax25;
-		ax25->idletimer.function = &ax25_idletimer_expiry;
-		ax25->idletimer.expires  = jiffies + ax25->idle;
-
-		add_timer(&ax25->idletimer);
-	}
+	if (ax25->idle > 0)
+		mod_timer(&ax25->idletimer, jiffies + ax25->idle);
+	else
+		del_timer(&ax25->idletimer);
 }
 
 void ax25_stop_heartbeat(ax25_cb *ax25)
