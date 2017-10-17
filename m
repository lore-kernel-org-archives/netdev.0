From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 20/58] atm: idt77252: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:04 -0700
Message-ID: <1508200182-104605-21-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. This required adding a pointer back
to vc_map, and adjusting the locking around removal a bit.

Cc: Chas Williams <3chas3@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/atm/idt77252.c | 21 ++++++++++++---------
 drivers/atm/idt77252.h |  3 +++
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 47f3c4ae0594..0e3b9c44c808 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -2073,21 +2073,19 @@ idt77252_rate_logindex(struct idt77252_dev *card, int pcr)
 }
 
 static void
-idt77252_est_timer(unsigned long data)
+idt77252_est_timer(struct timer_list *t)
 {
-	struct vc_map *vc = (struct vc_map *)data;
+	struct rate_estimator *est = from_timer(est, t, timer);
+	struct vc_map *vc = est->vc;
 	struct idt77252_dev *card = vc->card;
-	struct rate_estimator *est;
 	unsigned long flags;
 	u32 rate, cps;
 	u64 ncells;
 	u8 lacr;
 
 	spin_lock_irqsave(&vc->lock, flags);
-	est = vc->estimator;
-	if (!est)
+	if (!vc->estimator)
 		goto out;
-
 	ncells = est->cells;
 
 	rate = ((u32)(ncells - est->last_cells)) << (7 - est->interval);
@@ -2126,10 +2124,11 @@ idt77252_init_est(struct vc_map *vc, int pcr)
 	est->maxcps = pcr < 0 ? -pcr : pcr;
 	est->cps = est->maxcps;
 	est->avcps = est->cps << 5;
+	est->vc = vc;
 
 	est->interval = 2;		/* XXX: make this configurable */
 	est->ewma_log = 2;		/* XXX: make this configurable */
-	setup_timer(&est->timer, idt77252_est_timer, (unsigned long)vc);
+	timer_setup(&est->timer, idt77252_est_timer, 0);
 	mod_timer(&est->timer, jiffies + ((HZ / 4) << est->interval));
 
 	return est;
@@ -2209,16 +2208,20 @@ static int
 idt77252_init_ubr(struct idt77252_dev *card, struct vc_map *vc,
 		  struct atm_vcc *vcc, struct atm_qos *qos)
 {
+	struct rate_estimator *est = NULL;
 	unsigned long flags;
 	int tcr;
 
 	spin_lock_irqsave(&vc->lock, flags);
 	if (vc->estimator) {
-		del_timer(&vc->estimator->timer);
-		kfree(vc->estimator);
+		est = vc->estimator;
 		vc->estimator = NULL;
 	}
 	spin_unlock_irqrestore(&vc->lock, flags);
+	if (est) {
+		del_timer_sync(&est->timer);
+		kfree(est);
+	}
 
 	tcr = atm_pcr_goal(&qos->txtp);
 	if (tcr == 0)
diff --git a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
index 3a82cc23a053..9339197d701c 100644
--- a/drivers/atm/idt77252.h
+++ b/drivers/atm/idt77252.h
@@ -184,6 +184,8 @@ struct aal1 {
 	unsigned char		sequence;
 };
 
+struct vc_map;
+
 struct rate_estimator {
 	struct timer_list	timer;
 	unsigned int		interval;
@@ -193,6 +195,7 @@ struct rate_estimator {
 	long			avcps;
 	u32			cps;
 	u32			maxcps;
+	struct vc_map		*vc;
 };
 
 struct vc_map {
-- 
2.7.4
