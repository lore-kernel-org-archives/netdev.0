From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 11/58] net/hamradio/6pack: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:55 -0700
Message-ID: <1508200182-104605-12-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Andreas Koensgen <ajk@comnets.uni-bremen.de>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Andreas Koensgen <ajk@comnets.uni-bremen.de>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/hamradio/6pack.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 97fe8dfb602d..bbc7b7808a31 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -136,9 +136,9 @@ static int encode_sixpack(unsigned char *, unsigned char *, int, unsigned char);
  * Note that in case of DAMA operation, the data is not sent here.
  */
 
-static void sp_xmit_on_air(unsigned long channel)
+static void sp_xmit_on_air(struct timer_list *t)
 {
-	struct sixpack *sp = (struct sixpack *) channel;
+	struct sixpack *sp = from_timer(sp, t, tx_t);
 	int actual, when = sp->slottime;
 	static unsigned char random;
 
@@ -229,7 +229,7 @@ static void sp_encaps(struct sixpack *sp, unsigned char *icp, int len)
 		sp->xleft = count;
 		sp->xhead = sp->xbuff;
 		sp->status2 = count;
-		sp_xmit_on_air((unsigned long)sp);
+		sp_xmit_on_air(&sp->tx_t);
 	}
 
 	return;
@@ -500,9 +500,9 @@ static inline void tnc_set_sync_state(struct sixpack *sp, int new_tnc_state)
 		__tnc_set_sync_state(sp, new_tnc_state);
 }
 
-static void resync_tnc(unsigned long channel)
+static void resync_tnc(struct timer_list *t)
 {
-	struct sixpack *sp = (struct sixpack *) channel;
+	struct sixpack *sp = from_timer(sp, t, resync_t);
 	static char resync_cmd = 0xe8;
 
 	/* clear any data that might have been received */
@@ -526,8 +526,6 @@ static void resync_tnc(unsigned long channel)
 	/* Start resync timer again -- the TNC might be still absent */
 
 	del_timer(&sp->resync_t);
-	sp->resync_t.data	= (unsigned long) sp;
-	sp->resync_t.function	= resync_tnc;
 	sp->resync_t.expires	= jiffies + SIXP_RESYNC_TIMEOUT;
 	add_timer(&sp->resync_t);
 }
@@ -541,8 +539,6 @@ static inline int tnc_init(struct sixpack *sp)
 	sp->tty->ops->write(sp->tty, &inbyte, 1);
 
 	del_timer(&sp->resync_t);
-	sp->resync_t.data = (unsigned long) sp;
-	sp->resync_t.function = resync_tnc;
 	sp->resync_t.expires = jiffies + SIXP_RESYNC_TIMEOUT;
 	add_timer(&sp->resync_t);
 
@@ -623,9 +619,9 @@ static int sixpack_open(struct tty_struct *tty)
 
 	netif_start_queue(dev);
 
-	setup_timer(&sp->tx_t, sp_xmit_on_air, (unsigned long)sp);
+	timer_setup(&sp->tx_t, sp_xmit_on_air, 0);
 
-	init_timer(&sp->resync_t);
+	timer_setup(&sp->resync_t, resync_tnc, 0);
 
 	spin_unlock_bh(&sp->lock);
 
@@ -926,8 +922,6 @@ static void decode_prio_command(struct sixpack *sp, unsigned char cmd)
 
 	if (sp->tnc_state == TNC_IN_SYNC) {
 		del_timer(&sp->resync_t);
-		sp->resync_t.data	= (unsigned long) sp;
-		sp->resync_t.function	= resync_tnc;
 		sp->resync_t.expires	= jiffies + SIXP_INIT_RESYNC_TIMEOUT;
 		add_timer(&sp->resync_t);
 	}
-- 
2.7.4
