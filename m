From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 42/58] isdnloop: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:26 -0700
Message-ID: <1508200182-104605-43-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Added missing initialization for
rb_timer.

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/isdnloop/isdnloop.c | 33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index e97232646ba1..a4597e96c916 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -90,9 +90,9 @@ isdnloop_bchan_send(isdnloop_card *card, int ch)
  *   data = pointer to card struct, set by kernel timer.data
  */
 static void
-isdnloop_pollbchan(unsigned long data)
+isdnloop_pollbchan(struct timer_list *t)
 {
-	isdnloop_card *card = (isdnloop_card *) data;
+	isdnloop_card *card = from_timer(card, t, rb_timer);
 	unsigned long flags;
 
 	if (card->flags & ISDNLOOP_FLAGS_B1ACTIVE)
@@ -305,9 +305,9 @@ isdnloop_putmsg(isdnloop_card *card, unsigned char c)
  *   data = pointer to card struct
  */
 static void
-isdnloop_polldchan(unsigned long data)
+isdnloop_polldchan(struct timer_list *t)
 {
-	isdnloop_card *card = (isdnloop_card *) data;
+	isdnloop_card *card = from_timer(card, t, st_timer);
 	struct sk_buff *skb;
 	int avail;
 	int left;
@@ -373,8 +373,6 @@ isdnloop_polldchan(unsigned long data)
 			card->flags |= ISDNLOOP_FLAGS_RBTIMER;
 			spin_lock_irqsave(&card->isdnloop_lock, flags);
 			del_timer(&card->rb_timer);
-			card->rb_timer.function = isdnloop_pollbchan;
-			card->rb_timer.data = (unsigned long) card;
 			card->rb_timer.expires = jiffies + ISDNLOOP_TIMER_BCREAD;
 			add_timer(&card->rb_timer);
 			spin_unlock_irqrestore(&card->isdnloop_lock, flags);
@@ -588,9 +586,10 @@ isdnloop_atimeout(isdnloop_card *card, int ch)
  * Wrapper for isdnloop_atimeout().
  */
 static void
-isdnloop_atimeout0(unsigned long data)
+isdnloop_atimeout0(struct timer_list *t)
 {
-	isdnloop_card *card = (isdnloop_card *) data;
+	isdnloop_card *card = from_timer(card, t, c_timer[0]);
+
 	isdnloop_atimeout(card, 0);
 }
 
@@ -598,9 +597,10 @@ isdnloop_atimeout0(unsigned long data)
  * Wrapper for isdnloop_atimeout().
  */
 static void
-isdnloop_atimeout1(unsigned long data)
+isdnloop_atimeout1(struct timer_list *t)
 {
-	isdnloop_card *card = (isdnloop_card *) data;
+	isdnloop_card *card = from_timer(card, t, c_timer[1]);
+
 	isdnloop_atimeout(card, 1);
 }
 
@@ -617,13 +617,9 @@ isdnloop_start_ctimer(isdnloop_card *card, int ch)
 	unsigned long flags;
 
 	spin_lock_irqsave(&card->isdnloop_lock, flags);
-	init_timer(&card->c_timer[ch]);
+	timer_setup(&card->c_timer[ch], ch ? isdnloop_atimeout1
+					   : isdnloop_atimeout0, 0);
 	card->c_timer[ch].expires = jiffies + ISDNLOOP_TIMER_ALERTWAIT;
-	if (ch)
-		card->c_timer[ch].function = isdnloop_atimeout1;
-	else
-		card->c_timer[ch].function = isdnloop_atimeout0;
-	card->c_timer[ch].data = (unsigned long) card;
 	add_timer(&card->c_timer[ch]);
 	spin_unlock_irqrestore(&card->isdnloop_lock, flags);
 }
@@ -1113,10 +1109,9 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
 		       sdef.ptype);
 		return -EINVAL;
 	}
-	init_timer(&card->st_timer);
+	timer_setup(&card->rb_timer, isdnloop_pollbchan, 0);
+	timer_setup(&card->st_timer, isdnloop_polldchan, 0);
 	card->st_timer.expires = jiffies + ISDNLOOP_TIMER_DCREAD;
-	card->st_timer.function = isdnloop_polldchan;
-	card->st_timer.data = (unsigned long) card;
 	add_timer(&card->st_timer);
 	card->flags |= ISDNLOOP_FLAGS_RUNNING;
 	spin_unlock_irqrestore(&card->isdnloop_lock, flags);
-- 
2.7.4
