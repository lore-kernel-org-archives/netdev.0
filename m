From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 26/58] bna: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:10 -0700
Message-ID: <1508200182-104605-27-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Rasesh Mody <rasesh.mody@cavium.com>,
        Sudarsana Kalluru <sudarsana.kalluru@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
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

Cc: Rasesh Mody <rasesh.mody@cavium.com>
Cc: Sudarsana Kalluru <sudarsana.kalluru@cavium.com>
Cc: Dept-GELinuxNICDev@cavium.com
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 43 +++++++++++++++------------------
 1 file changed, 19 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 6e13c937d715..a843076597ec 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1693,9 +1693,9 @@ bnad_rx_res_alloc(struct bnad *bnad, struct bna_res_info *res_info,
 /* Timer callbacks */
 /* a) IOC timer */
 static void
-bnad_ioc_timeout(unsigned long data)
+bnad_ioc_timeout(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, bna.ioceth.ioc.ioc_timer);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -1704,9 +1704,9 @@ bnad_ioc_timeout(unsigned long data)
 }
 
 static void
-bnad_ioc_hb_check(unsigned long data)
+bnad_ioc_hb_check(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, bna.ioceth.ioc.hb_timer);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -1715,9 +1715,9 @@ bnad_ioc_hb_check(unsigned long data)
 }
 
 static void
-bnad_iocpf_timeout(unsigned long data)
+bnad_iocpf_timeout(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, bna.ioceth.ioc.iocpf_timer);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -1726,9 +1726,9 @@ bnad_iocpf_timeout(unsigned long data)
 }
 
 static void
-bnad_iocpf_sem_timeout(unsigned long data)
+bnad_iocpf_sem_timeout(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, bna.ioceth.ioc.sem_timer);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -1748,9 +1748,9 @@ bnad_iocpf_sem_timeout(unsigned long data)
 
 /* b) Dynamic Interrupt Moderation Timer */
 static void
-bnad_dim_timeout(unsigned long data)
+bnad_dim_timeout(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, dim_timer);
 	struct bnad_rx_info *rx_info;
 	struct bnad_rx_ctrl *rx_ctrl;
 	int i, j;
@@ -1781,9 +1781,9 @@ bnad_dim_timeout(unsigned long data)
 
 /* c)  Statistics Timer */
 static void
-bnad_stats_timeout(unsigned long data)
+bnad_stats_timeout(struct timer_list *t)
 {
-	struct bnad *bnad = (struct bnad *)data;
+	struct bnad *bnad = from_timer(bnad, t, stats_timer);
 	unsigned long flags;
 
 	if (!netif_running(bnad->netdev) ||
@@ -1804,8 +1804,7 @@ bnad_dim_timer_start(struct bnad *bnad)
 {
 	if (bnad->cfg_flags & BNAD_CF_DIM_ENABLED &&
 	    !test_bit(BNAD_RF_DIM_TIMER_RUNNING, &bnad->run_flags)) {
-		setup_timer(&bnad->dim_timer, bnad_dim_timeout,
-			    (unsigned long)bnad);
+		timer_setup(&bnad->dim_timer, bnad_dim_timeout, 0);
 		set_bit(BNAD_RF_DIM_TIMER_RUNNING, &bnad->run_flags);
 		mod_timer(&bnad->dim_timer,
 			  jiffies + msecs_to_jiffies(BNAD_DIM_TIMER_FREQ));
@@ -1823,8 +1822,7 @@ bnad_stats_timer_start(struct bnad *bnad)
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (!test_and_set_bit(BNAD_RF_STATS_TIMER_RUNNING, &bnad->run_flags)) {
-		setup_timer(&bnad->stats_timer, bnad_stats_timeout,
-			    (unsigned long)bnad);
+		timer_setup(&bnad->stats_timer, bnad_stats_timeout, 0);
 		mod_timer(&bnad->stats_timer,
 			  jiffies + msecs_to_jiffies(BNAD_STATS_TIMER_FREQ));
 	}
@@ -3692,14 +3690,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 		goto res_free;
 
 	/* Set up timers */
-	setup_timer(&bnad->bna.ioceth.ioc.ioc_timer, bnad_ioc_timeout,
-		    (unsigned long)bnad);
-	setup_timer(&bnad->bna.ioceth.ioc.hb_timer, bnad_ioc_hb_check,
-		    (unsigned long)bnad);
-	setup_timer(&bnad->bna.ioceth.ioc.iocpf_timer, bnad_iocpf_timeout,
-		    (unsigned long)bnad);
-	setup_timer(&bnad->bna.ioceth.ioc.sem_timer, bnad_iocpf_sem_timeout,
-		    (unsigned long)bnad);
+	timer_setup(&bnad->bna.ioceth.ioc.ioc_timer, bnad_ioc_timeout, 0);
+	timer_setup(&bnad->bna.ioceth.ioc.hb_timer, bnad_ioc_hb_check, 0);
+	timer_setup(&bnad->bna.ioceth.ioc.iocpf_timer, bnad_iocpf_timeout, 0);
+	timer_setup(&bnad->bna.ioceth.ioc.sem_timer, bnad_iocpf_sem_timeout,
+		    0);
 
 	/*
 	 * Start the chip
-- 
2.7.4
