From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 02/10] timecompare: generic infrastructure to map between two time bases
Date: Thu, 12 Feb 2009 16:03:35 +0100
Message-ID: <1234451023-6505-2-git-send-email-patrick.ohly@intel.com>
References: <1234450981.5914.11.camel@ecld0pohly>
 <1234451023-6505-1-git-send-email-patrick.ohly@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	John Ronciak <john.ronciak@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15848 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760715AbZBLPDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:03:50 -0500
In-Reply-To: <1234451023-6505-1-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mapping from a struct timecounter to a time returned by functions like
ktime_get_real() is implemented. This is sufficient to use this code
in a network device driver which wants to support hardware time
stamping and transformation of hardware time stamps to system time.

The interface could have been made more versatile by not depending on
a time counter, but this wasn't done to avoid writing glue code
elsewhere.

The method implemented here is the one used and analyzed under the name
"assisted PTP" in the LCI PTP paper:
http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Ohly_92221.pdf

Acked-by: John Stultz <johnstul@us.ibm.com>
Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 include/linux/timecompare.h |  125 ++++++++++++++++++++++++++++
 kernel/time/Makefile        |    2 +-
 kernel/time/timecompare.c   |  191 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 317 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/timecompare.h
 create mode 100644 kernel/time/timecompare.c

diff --git a/include/linux/timecompare.h b/include/linux/timecompare.h
new file mode 100644
index 0000000..546e223
--- /dev/null
+++ b/include/linux/timecompare.h
@@ -0,0 +1,125 @@
+/*
+ * Utility code which helps transforming between two different time
+ * bases, called "source" and "target" time in this code.
+ *
+ * Source time has to be provided via the timecounter API while target
+ * time is accessed via a function callback whose prototype
+ * intentionally matches ktime_get() and ktime_get_real(). These
+ * interfaces where chosen like this so that the code serves its
+ * initial purpose without additional glue code.
+ *
+ * This purpose is synchronizing a hardware clock in a NIC with system
+ * time, in order to implement the Precision Time Protocol (PTP,
+ * IEEE1588) with more accurate hardware assisted time stamping.  In
+ * that context only synchronization against system time (=
+ * ktime_get_real()) is currently needed. But this utility code might
+ * become useful in other situations, which is why it was written as
+ * general purpose utility code.
+ *
+ * The source timecounter is assumed to return monotonically
+ * increasing time (but this code does its best to compensate if that
+ * is not the case) whereas target time may jump.
+ *
+ * The target time corresponding to a source time is determined by
+ * reading target time, reading source time, reading target time
+ * again, then assuming that average target time corresponds to source
+ * time. In other words, the assumption is that reading the source
+ * time is slow and involves equal time for sending the request and
+ * receiving the reply, whereas reading target time is assumed to be
+ * fast.
+ *
+ * Copyright (C) 2009 Intel Corporation.
+ * Author: Patrick Ohly <patrick.ohly@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+#ifndef _LINUX_TIMECOMPARE_H
+#define _LINUX_TIMECOMPARE_H
+
+#include <linux/clocksource.h>
+#include <linux/ktime.h>
+
+/**
+ * struct timecompare - stores state and configuration for the two clocks
+ *
+ * Initialize to zero, then set source/target/num_samples.
+ *
+ * Transformation between source time and target time is done with:
+ * target_time = source_time + offset +
+ *               (source_time - last_update) * skew /
+ *               TIMECOMPARE_SKEW_RESOLUTION
+ *
+ * @source:          used to get source time stamps via timecounter_read()
+ * @target:          function returning target time (for example, ktime_get
+ *                   for monotonic time, or ktime_get_real for wall clock)
+ * @num_samples:     number of times that source time and target time are to
+ *                   be compared when determining their offset
+ * @offset:          (target time - source time) at the time of the last update
+ * @skew:            average (target time - source time) / delta source time *
+ *                   TIMECOMPARE_SKEW_RESOLUTION
+ * @last_update:     last source time stamp when time offset was measured
+ */
+struct timecompare {
+	struct timecounter *source;
+	ktime_t (*target)(void);
+	int num_samples;
+
+	s64 offset;
+	s64 skew;
+	u64 last_update;
+};
+
+/**
+ * timecompare_transform - transform source time stamp into target time base
+ * @sync:            context for time sync
+ * @source_tstamp:   the result of timecounter_read() or
+ *                   timecounter_cyc2time()
+ */
+extern ktime_t timecompare_transform(struct timecompare *sync,
+				     u64 source_tstamp);
+
+/**
+ * timecompare_offset - measure current (target time - source time) offset
+ * @sync:            context for time sync
+ * @offset:          average offset during sample period returned here
+ * @source_tstamp:   average source time during sample period returned here
+ *
+ * Returns number of samples used. Might be zero (= no result) in the
+ * unlikely case that target time was monotonically decreasing for all
+ * samples (= broken).
+ */
+extern int timecompare_offset(struct timecompare *sync,
+			      s64 *offset,
+			      u64 *source_tstamp);
+
+extern void __timecompare_update(struct timecompare *sync,
+				 u64 source_tstamp);
+
+/**
+ * timecompare_update - update offset and skew by measuring current offset
+ * @sync:            context for time sync
+ * @source_tstamp:   the result of timecounter_read() or
+ *                   timecounter_cyc2time(), pass zero to force update
+ *
+ * Updates are only done at most once per second.
+ */
+static inline void timecompare_update(struct timecompare *sync,
+				      u64 source_tstamp)
+{
+	if (!source_tstamp ||
+	    (s64)(source_tstamp - sync->last_update) >= NSEC_PER_SEC)
+		__timecompare_update(sync, source_tstamp);
+}
+
+#endif /* _LINUX_TIMECOMPARE_H */
diff --git a/kernel/time/Makefile b/kernel/time/Makefile
index 905b0b5..0b0a636 100644
--- a/kernel/time/Makefile
+++ b/kernel/time/Makefile
@@ -1,4 +1,4 @@
-obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o
+obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timecompare.o
 
 obj-$(CONFIG_GENERIC_CLOCKEVENTS_BUILD)		+= clockevents.o
 obj-$(CONFIG_GENERIC_CLOCKEVENTS)		+= tick-common.o
diff --git a/kernel/time/timecompare.c b/kernel/time/timecompare.c
new file mode 100644
index 0000000..71e7f1a
--- /dev/null
+++ b/kernel/time/timecompare.c
@@ -0,0 +1,191 @@
+/*
+ * Copyright (C) 2009 Intel Corporation.
+ * Author: Patrick Ohly <patrick.ohly@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/timecompare.h>
+#include <linux/module.h>
+#include <linux/math64.h>
+
+/*
+ * fixed point arithmetic scale factor for skew
+ *
+ * Usually one would measure skew in ppb (parts per billion, 1e9), but
+ * using a factor of 2 simplifies the math.
+ */
+#define TIMECOMPARE_SKEW_RESOLUTION (((s64)1)<<30)
+
+ktime_t timecompare_transform(struct timecompare *sync,
+			      u64 source_tstamp)
+{
+	u64 nsec;
+
+	nsec = source_tstamp + sync->offset;
+	nsec += (s64)(source_tstamp - sync->last_update) * sync->skew /
+		TIMECOMPARE_SKEW_RESOLUTION;
+
+	return ns_to_ktime(nsec);
+}
+EXPORT_SYMBOL(timecompare_transform);
+
+int timecompare_offset(struct timecompare *sync,
+		       s64 *offset,
+		       u64 *source_tstamp)
+{
+	u64 start_source = 0, end_source = 0;
+	struct {
+		s64 offset;
+		s64 duration_target;
+	} buffer[10], sample, *samples;
+	int counter = 0, i;
+	int used;
+	int index;
+	int num_samples = sync->num_samples;
+
+	if (num_samples > sizeof(buffer)/sizeof(buffer[0])) {
+		samples = kmalloc(sizeof(*samples) * num_samples, GFP_ATOMIC);
+		if (!samples) {
+			samples = buffer;
+			num_samples = sizeof(buffer)/sizeof(buffer[0]);
+		}
+	} else {
+		samples = buffer;
+	}
+
+	/* run until we have enough valid samples, but do not try forever */
+	i = 0;
+	counter = 0;
+	while (1) {
+		u64 ts;
+		ktime_t start, end;
+
+		start = sync->target();
+		ts = timecounter_read(sync->source);
+		end = sync->target();
+
+		if (!i)
+			start_source = ts;
+
+		/* ignore negative durations */
+		sample.duration_target = ktime_to_ns(ktime_sub(end, start));
+		if (sample.duration_target >= 0) {
+			/*
+			 * assume symetric delay to and from source:
+			 * average target time corresponds to measured
+			 * source time
+			 */
+			sample.offset =
+				ktime_to_ns(ktime_add(end, start)) / 2 -
+				ts;
+
+			/* simple insertion sort based on duration */
+			index = counter - 1;
+			while (index >= 0) {
+				if (samples[index].duration_target <
+				    sample.duration_target)
+					break;
+				samples[index + 1] = samples[index];
+				index--;
+			}
+			samples[index + 1] = sample;
+			counter++;
+		}
+
+		i++;
+		if (counter >= num_samples || i >= 100000) {
+			end_source = ts;
+			break;
+		}
+	}
+
+	*source_tstamp = (end_source + start_source) / 2;
+
+	/* remove outliers by only using 75% of the samples */
+	used = counter * 3 / 4;
+	if (!used)
+		used = counter;
+	if (used) {
+		/* calculate average */
+		s64 off = 0;
+		for (index = 0; index < used; index++)
+			off += samples[index].offset;
+		*offset = div_s64(off, used);
+	}
+
+	if (samples && samples != buffer)
+		kfree(samples);
+
+	return used;
+}
+EXPORT_SYMBOL(timecompare_offset);
+
+void __timecompare_update(struct timecompare *sync,
+			  u64 source_tstamp)
+{
+	s64 offset;
+	u64 average_time;
+
+	if (!timecompare_offset(sync, &offset, &average_time))
+		return;
+
+	if (!sync->last_update) {
+		sync->last_update = average_time;
+		sync->offset = offset;
+		sync->skew = 0;
+	} else {
+		s64 delta_nsec = average_time - sync->last_update;
+
+		/* avoid division by negative or small deltas */
+		if (delta_nsec >= 10000) {
+			s64 delta_offset_nsec = offset - sync->offset;
+			s64 skew; /* delta_offset_nsec *
+				     TIMECOMPARE_SKEW_RESOLUTION /
+				     delta_nsec */
+			u64 divisor;
+
+			/* div_s64() is limited to 32 bit divisor */
+			skew = delta_offset_nsec * TIMECOMPARE_SKEW_RESOLUTION;
+			divisor = delta_nsec;
+			while (unlikely(divisor >= ((s64)1) << 32)) {
+				/* divide both by 2; beware, right shift
+				   of negative value has undefined
+				   behavior and can only be used for
+				   the positive divisor */
+				skew = div_s64(skew, 2);
+				divisor >>= 1;
+			}
+			skew = div_s64(skew, divisor);
+
+			/*
+			 * Calculate new overall skew as 4/16 the
+			 * old value and 12/16 the new one. This is
+			 * a rather arbitrary tradeoff between
+			 * only using the latest measurement (0/16 and
+			 * 16/16) and even more weight on past measurements.
+			 */
+#define TIMECOMPARE_NEW_SKEW_PER_16 12
+			sync->skew =
+				div_s64((16 - TIMECOMPARE_NEW_SKEW_PER_16) *
+					sync->skew +
+					TIMECOMPARE_NEW_SKEW_PER_16 * skew,
+					16);
+			sync->last_update = average_time;
+			sync->offset = offset;
+		}
+	}
+}
+EXPORT_SYMBOL(__timecompare_update);
-- 
1.6.1.2

