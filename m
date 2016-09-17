From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net-next 02/16] lib/win_minmax: windowed min or max estimator
Date: Sat, 17 Sep 2016 13:35:35 -0400
Message-ID: <1474133749-12895-3-git-send-email-ncardwell@google.com>
References: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35001 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753781AbcIQRgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 13:36:09 -0400
Received: by mail-qk0-f172.google.com with SMTP id t7so115300908qkh.2
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 10:36:08 -0700 (PDT)
In-Reply-To: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces a generic library to estimate either the min or
max value of a time-varying variable over a recent time window. This
is code originally from Kathleen Nichols. The current form of the code
is from Van Jacobson.

A single struct minmax_sample will track the estimated windowed-max
value of the series if you call minmax_running_max() or the estimated
windowed-min value of the series if you call minmax_running_min().

Nearly equivalent code is already in place for minimum RTT estimation
in the TCP stack. This commit extracts that code and generalizes it to
handle both min and max. Moving the code here reduces the footprint
and complexity of the TCP code base and makes the filter generally
available for other parts of the codebase, including an upcoming TCP
congestion control module.

This library works well for time series where the measurements are
smoothly increasing or decreasing.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/linux/win_minmax.h | 37 +++++++++++++++++
 lib/Makefile               |  2 +-
 lib/win_minmax.c           | 98 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 136 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/win_minmax.h
 create mode 100644 lib/win_minmax.c

diff --git a/include/linux/win_minmax.h b/include/linux/win_minmax.h
new file mode 100644
index 0000000..5656960
--- /dev/null
+++ b/include/linux/win_minmax.h
@@ -0,0 +1,37 @@
+/**
+ * lib/minmax.c: windowed min/max tracker by Kathleen Nichols.
+ *
+ */
+#ifndef MINMAX_H
+#define MINMAX_H
+
+#include <linux/types.h>
+
+/* A single data point for our parameterized min-max tracker */
+struct minmax_sample {
+	u32	t;	/* time measurement was taken */
+	u32	v;	/* value measured */
+};
+
+/* State for the parameterized min-max tracker */
+struct minmax {
+	struct minmax_sample s[3];
+};
+
+static inline u32 minmax_get(const struct minmax *m)
+{
+	return m->s[0].v;
+}
+
+static inline u32 minmax_reset(struct minmax *m, u32 t, u32 meas)
+{
+	struct minmax_sample val = { .t = t, .v = meas };
+
+	m->s[2] = m->s[1] = m->s[0] = val;
+	return m->s[0].v;
+}
+
+u32 minmax_running_max(struct minmax *m, u32 win, u32 t, u32 meas);
+u32 minmax_running_min(struct minmax *m, u32 win, u32 t, u32 meas);
+
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 5dc77a8..df747e5 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -22,7 +22,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 sha1.o chacha20.o md5.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
-	 earlycpio.o seq_buf.o nmi_backtrace.o nodemask.o
+	 earlycpio.o seq_buf.o nmi_backtrace.o nodemask.o win_minmax.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
diff --git a/lib/win_minmax.c b/lib/win_minmax.c
new file mode 100644
index 0000000..c8420d4
--- /dev/null
+++ b/lib/win_minmax.c
@@ -0,0 +1,98 @@
+/**
+ * lib/minmax.c: windowed min/max tracker
+ *
+ * Kathleen Nichols' algorithm for tracking the minimum (or maximum)
+ * value of a data stream over some fixed time interval.  (E.g.,
+ * the minimum RTT over the past five minutes.) It uses constant
+ * space and constant time per update yet almost always delivers
+ * the same minimum as an implementation that has to keep all the
+ * data in the window.
+ *
+ * The algorithm keeps track of the best, 2nd best & 3rd best min
+ * values, maintaining an invariant that the measurement time of
+ * the n'th best >= n-1'th best. It also makes sure that the three
+ * values are widely separated in the time window since that bounds
+ * the worse case error when that data is monotonically increasing
+ * over the window.
+ *
+ * Upon getting a new min, we can forget everything earlier because
+ * it has no value - the new min is <= everything else in the window
+ * by definition and it's the most recent. So we restart fresh on
+ * every new min and overwrites 2nd & 3rd choices. The same property
+ * holds for 2nd & 3rd best.
+ */
+#include <linux/module.h>
+#include <linux/win_minmax.h>
+
+/* As time advances, update the 1st, 2nd, and 3rd choices. */
+static u32 minmax_subwin_update(struct minmax *m, u32 win,
+				const struct minmax_sample *val)
+{
+	u32 dt = val->t - m->s[0].t;
+
+	if (unlikely(dt > win)) {
+		/*
+		 * Passed entire window without a new val so make 2nd
+		 * choice the new val & 3rd choice the new 2nd choice.
+		 * we may have to iterate this since our 2nd choice
+		 * may also be outside the window (we checked on entry
+		 * that the third choice was in the window).
+		 */
+		m->s[0] = m->s[1];
+		m->s[1] = m->s[2];
+		m->s[2] = *val;
+		if (unlikely(val->t - m->s[0].t > win)) {
+			m->s[0] = m->s[1];
+			m->s[1] = m->s[2];
+			m->s[2] = *val;
+		}
+	} else if (unlikely(m->s[1].t == m->s[0].t) && dt > win/4) {
+		/*
+		 * We've passed a quarter of the window without a new val
+		 * so take a 2nd choice from the 2nd quarter of the window.
+		 */
+		m->s[2] = m->s[1] = *val;
+	} else if (unlikely(m->s[2].t == m->s[1].t) && dt > win/2) {
+		/*
+		 * We've passed half the window without finding a new val
+		 * so take a 3rd choice from the last half of the window
+		 */
+		m->s[2] = *val;
+	}
+	return m->s[0].v;
+}
+
+/* Check if new measurement updates the 1st, 2nd or 3rd choice max. */
+u32 minmax_running_max(struct minmax *m, u32 win, u32 t, u32 meas)
+{
+	struct minmax_sample val = { .t = t, .v = meas };
+
+	if (unlikely(val.v >= m->s[0].v) ||	  /* found new max? */
+	    unlikely(val.t - m->s[2].t > win))	  /* nothing left in window? */
+		return minmax_reset(m, t, meas);  /* forget earlier samples */
+
+	if (unlikely(val.v >= m->s[1].v))
+		m->s[2] = m->s[1] = val;
+	else if (unlikely(val.v >= m->s[2].v))
+		m->s[2] = val;
+
+	return minmax_subwin_update(m, win, &val);
+}
+EXPORT_SYMBOL(minmax_running_max);
+
+/* Check if new measurement updates the 1st, 2nd or 3rd choice min. */
+u32 minmax_running_min(struct minmax *m, u32 win, u32 t, u32 meas)
+{
+	struct minmax_sample val = { .t = t, .v = meas };
+
+	if (unlikely(val.v <= m->s[0].v) ||	  /* found new min? */
+	    unlikely(val.t - m->s[2].t > win))	  /* nothing left in window? */
+		return minmax_reset(m, t, meas);  /* forget earlier samples */
+
+	if (unlikely(val.v <= m->s[1].v))
+		m->s[2] = m->s[1] = val;
+	else if (unlikely(val.v <= m->s[2].v))
+		m->s[2] = val;
+
+	return minmax_subwin_update(m, win, &val);
+}
-- 
2.8.0.rc3.226.g39d4020
