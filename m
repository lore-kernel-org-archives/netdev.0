From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH  v2 05/13] net: ethernet: ti: cpts: fix registration order
Date: Mon, 28 Nov 2016 17:03:29 -0600
Message-ID: <20161128230337.6731-6-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ptp clock registered before spinlock, which is protecting it, and
before timecounter and cyclecounter initialization in cpts_register().

So, ensure that ptp clock is registered the last, after everything
else is done.

Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/cpts.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 101e17b..cb851a7 100644
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
