From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [RFC/RFT PATCH 1/4] net: ethernet: ti: cpts: use own highpri workqueue
Date: Tue, 13 Jun 2017 18:16:20 -0500
Message-ID: <20170613231623.28353-2-grygorii.strashko@ti.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231623.28353-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There could be significant delay in CPTS work schedule under high system
load and on -RT which could cause CPTS misbehavior due to internal counter
overflow. Usage of own highpri ordered workqueue allows to avoid such kind
of issues and makes it possible to tune priority of CPTS workqueue thread
on -RT.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 11 +++++++++--
 drivers/net/ethernet/ti/cpts.h |  1 +
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 32279d2..f35d950 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -245,7 +245,8 @@ static void cpts_overflow_check(struct work_struct *work)
 
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+	queue_delayed_work(cpts->workwq, &cpts->overflow_work,
+			   cpts->ov_check_period);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -378,7 +379,8 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+	queue_delayed_work(cpts->workwq, &cpts->overflow_work,
+			   cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -477,6 +479,11 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->reg = (struct cpsw_cpts __iomem *)regs;
 	spin_lock_init(&cpts->lock);
 	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
+	cpts->workwq = alloc_ordered_workqueue("cpts_ptp",
+					       WQ_MEM_RECLAIM | WQ_HIGHPRI);
+	if (!cpts->workwq)
+		return ERR_PTR(-ENOMEM);
+
 
 	ret = cpts_of_parse(cpts, node);
 	if (ret)
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index c96eca2..3eae01c 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -125,6 +125,7 @@ struct cpts {
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
+	struct workqueue_struct *workwq;
 };
 
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1
