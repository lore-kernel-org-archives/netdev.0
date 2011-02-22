From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (sh-2.6) 2/4] sh_timer: add the support to use the generic
 timer
Date: Tue, 22 Feb 2011 11:17:42 +0100
Message-ID: <1298369864-24429-3-git-send-email-peppe.cavallaro@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the support to register and use a TMU channel as
generic timer. For example the stmmac network device
driver, on STM platforms, uses the TMU channel 2 for
mitigating the number of interrupts.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
---
 drivers/clocksource/sh_tmu.c |   72 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/drivers/clocksource/sh_tmu.c b/drivers/clocksource/sh_tmu.c
index 36aba99..8199556 100644
--- a/drivers/clocksource/sh_tmu.c
+++ b/drivers/clocksource/sh_tmu.c
@@ -29,6 +29,7 @@
 #include <linux/err.h>
 #include <linux/clocksource.h>
 #include <linux/clockchips.h>
+#include <linux/generictimer.h>
 #include <linux/sh_timer.h>
 #include <linux/slab.h>
 
@@ -41,6 +42,7 @@ struct sh_tmu_priv {
 	unsigned long periodic;
 	struct clock_event_device ced;
 	struct clocksource cs;
+	struct generic_timer gt;
 };
 
 static DEFINE_SPINLOCK(sh_tmu_lock);
@@ -184,6 +186,74 @@ static irqreturn_t sh_tmu_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static struct sh_tmu_priv *gt_to_sh_tmu(struct generic_timer *gt)
+{
+	return container_of(gt, struct sh_tmu_priv, gt);
+}
+
+static void sh_tmu_generic_timer_start(struct generic_timer *gt)
+{
+	struct sh_tmu_priv *p = gt_to_sh_tmu(gt);
+
+	sh_tmu_write(p, TCR, 0x0020);
+	sh_tmu_start_stop_ch(p, 1);
+}
+
+static void sh_tmu_generic_timer_stop(struct generic_timer *gt)
+{
+	struct sh_tmu_priv *p = gt_to_sh_tmu(gt);
+
+	sh_tmu_start_stop_ch(p, 0);
+	sh_tmu_write(p, TCR, 0x0000);
+}
+
+static void sh_tmu_generic_timer_set_rate(struct generic_timer *gt,
+					  unsigned long rate)
+{
+	struct sh_tmu_priv *p = gt_to_sh_tmu(gt);
+
+	sh_tmu_enable(p);
+	p->periodic = p->rate / rate;
+	sh_tmu_set_next(p, p->periodic, 1);
+}
+
+static irqreturn_t sh_tmu_generic_timer_interrupt(int irq, void *dev_id)
+{
+	struct sh_tmu_priv *p = dev_id;
+
+	sh_tmu_write(p, TCR, 0x0020);
+
+	p->gt.priv_handler(p->gt.data);
+	return IRQ_HANDLED;
+}
+
+static void sh_tmu_register_generic_timer(struct sh_tmu_priv *p, char *name)
+{
+	struct generic_timer *gt = &p->gt;
+	int ret;
+
+	gt->name = name;
+	gt->timer_start = sh_tmu_generic_timer_start;
+	gt->timer_stop = sh_tmu_generic_timer_stop;
+	gt->set_rate = sh_tmu_generic_timer_set_rate;
+
+	p->irqaction.handler = sh_tmu_generic_timer_interrupt;
+
+	ret = setup_irq(p->irqaction.irq, &p->irqaction);
+	if (unlikely(ret)) {
+		dev_err(&p->pdev->dev, "failed to request irq %d\n",
+			p->irqaction.irq);
+		return;
+	}
+
+	sh_tmu_generic_timer_stop(gt);
+	sh_tmu_write(p, TCOR, 0xffffffff);
+	sh_tmu_write(p, TCNT, 0xffffffff);
+
+	dev_info(&p->pdev->dev, "used for generic timer\n");
+	generic_timer_register_device(gt);
+}
+
 static struct sh_tmu_priv *cs_to_sh_tmu(struct clocksource *cs)
 {
 	return container_of(cs, struct sh_tmu_priv, cs);
@@ -342,6 +412,8 @@ static int sh_tmu_register(struct sh_tmu_priv *p, char *name,
 		sh_tmu_register_clockevent(p, name, clockevent_rating);
 	else if (clocksource_rating)
 		sh_tmu_register_clocksource(p, name, clocksource_rating);
+	else
+		sh_tmu_register_generic_timer(p, name);
 
 	return 0;
 }
-- 
1.7.4
