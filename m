From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 05/13] net: ethernet: ti: cpts: fix registration order
Date: Tue, 6 Dec 2016 18:00:37 -0600
Message-ID: <20161207000045.28333-6-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207000045.28333-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ptp clock registered before spinlock, which is protecting it, and
before timecounter and cyclecounter initialization in cpts_register().

So, ensure that ptp clock is registered the last, after everything
else is done.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 61198f1..3dda6d5 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -356,15 +356,8 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 		  u32 mult, u32 shift)
 {
 	int err, i;
-	unsigned long flags;
 
 	cpts->info = cpts_info;
-	cpts->clock = ptp_clock_register(&cpts->info, dev);
-	if (IS_ERR(cpts->clock)) {
-		err = PTR_ERR(cpts->clock);
-		cpts->clock = NULL;
-		return err;
-	}
 	spin_lock_init(&cpts->lock);
 
 	cpts->cc.read = cpts_systim_read;
@@ -382,15 +375,26 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 	cpts_write32(cpts, CPTS_EN, control);
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 
-	spin_lock_irqsave(&cpts->lock, flags);
 	timecounter_init(&cpts->tc, &cpts->cc, ktime_to_ns(ktime_get_real()));
-	spin_unlock_irqrestore(&cpts->lock, flags);
 
 	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
-	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 
+	cpts->clock = ptp_clock_register(&cpts->info, dev);
+	if (IS_ERR(cpts->clock)) {
+		err = PTR_ERR(cpts->clock);
+		cpts->clock = NULL;
+		goto err_ptp;
+	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
+
+	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
+
 	return 0;
+
+err_ptp:
+	if (cpts->refclk)
+		cpts_clk_release(cpts);
+	return err;
 }
 EXPORT_SYMBOL_GPL(cpts_register);
 
-- 
2.10.1
