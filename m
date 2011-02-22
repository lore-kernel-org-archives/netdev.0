From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Tue, 22 Feb 2011 11:17:41 +0100
Message-ID: <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>
To: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stuart Menefy <stuart.menefy@st.com>

Many devices targeted at the embedded market provide a number of
generic timers which are capable of generating interrupts at a
requested rate. These can then be used in the implementation of drivers
for other peripherals which require a timer interrupt, without having
to provide an additional timer as part of that peripheral.

A code provides a simple abstraction layer which allows a timer to be
registered, and for a driver to request a timer.

Currently this doesn't provide any of the additional information, such
as precision or position in clock framework which might be required
for a fully featured driver.

Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/clocksource/Makefile       |    1 +
 drivers/clocksource/generictimer.c |   60 ++++++++++++++++++++++++++++++++++++
 include/linux/generictimer.h       |   41 ++++++++++++++++++++++++
 3 files changed, 102 insertions(+), 0 deletions(-)
 create mode 100644 drivers/clocksource/generictimer.c
 create mode 100644 include/linux/generictimer.h

diff --git a/drivers/clocksource/Makefile b/drivers/clocksource/Makefile
index be61ece..b0be293 100644
--- a/drivers/clocksource/Makefile
+++ b/drivers/clocksource/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_CS5535_CLOCK_EVENT_SRC)	+= cs5535-clockevt.o
 obj-$(CONFIG_SH_TIMER_CMT)	+= sh_cmt.o
 obj-$(CONFIG_SH_TIMER_MTU2)	+= sh_mtu2.o
 obj-$(CONFIG_SH_TIMER_TMU)	+= sh_tmu.o
+obj-y				+= generictimer.o
diff --git a/drivers/clocksource/generictimer.c b/drivers/clocksource/generictimer.c
new file mode 100644
index 0000000..a74a87a
--- /dev/null
+++ b/drivers/clocksource/generictimer.c
@@ -0,0 +1,60 @@
+/*
+ * Simple generic hardware timer interface
+ *
+ * Copyright (C) 2010 STMicroelectronics Limited
+ * Authors: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+ *          Stuart Menefy <stuart.menefy@st.com>
+ *
+ * May be copied or modified under the terms of the GNU General Public
+ * License. See linux/COPYING for more information.
+ */
+
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/generictimer.h>
+
+static DEFINE_MUTEX(gt_mutex);
+static LIST_HEAD(gt_list);
+
+void generic_timer_register_device(struct generic_timer *gt)
+{
+	mutex_lock(&gt_mutex);
+	list_add(&gt->list, &gt_list);
+	mutex_unlock(&gt_mutex);
+}
+
+struct generic_timer *generic_timer_claim(void (*handler) (void *), void *data)
+{
+	struct generic_timer *gt = NULL;
+
+	if (!handler) {
+		pr_err("%s: invalid handler\n", __func__);
+		return NULL;
+	}
+
+	mutex_lock(&gt_mutex);
+	if (!list_empty(&gt_list)) {
+		struct list_head *list = gt_list.next;
+		list_del(list);
+		gt = container_of(list, struct generic_timer, list);
+	}
+	mutex_unlock(&gt_mutex);
+
+	if (!gt)
+		return NULL;
+
+	/* Prepare the new handler */
+	gt->priv_handler = handler;
+	gt->data = data;
+
+	return gt;
+}
+
+void generic_timer_release(struct generic_timer *gt)
+{
+	/* Just in case... */
+	generic_timer_stop(gt);
+
+	generic_timer_register_device(gt);
+}
diff --git a/include/linux/generictimer.h b/include/linux/generictimer.h
new file mode 100644
index 0000000..87fb656
--- /dev/null
+++ b/include/linux/generictimer.h
@@ -0,0 +1,41 @@
+#ifndef __STM_GENERIC_TIMER_H
+#define __STM_GENERIC_TIMER_H
+
+#include <linux/list.h>
+
+/* Generic timer device intrface */
+
+struct generic_timer {
+	char *name;
+	struct list_head list;
+	void (*priv_handler)(void *data);
+	void *data;
+	void (*timer_start)(struct generic_timer *gt);
+	void (*timer_stop)(struct generic_timer *gt);
+	void (*set_rate)(struct generic_timer *gt, unsigned long rate);
+};
+
+void generic_timer_register_device(struct generic_timer *gt);
+
+/* Driver interface */
+
+struct generic_timer *generic_timer_claim(void (*handler)(void *), void *data);
+void generic_timer_release(struct generic_timer *gt);
+
+static inline void generic_timer_start(struct generic_timer *gt)
+{
+	gt->timer_start(gt);
+}
+
+static inline void generic_timer_stop(struct generic_timer *gt)
+{
+	gt->timer_stop(gt);
+}
+
+static inline void generic_timer_set_rate(struct generic_timer *gt,
+		unsigned long rate)
+{
+	gt->set_rate(gt, rate);
+}
+
+#endif /* __STM_GENERIC_TIMER_H */
-- 
1.7.4
