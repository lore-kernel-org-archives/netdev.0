From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/11] pps/ptp: Allow PHC devices to adjust PPS
 events for known delay
Date: Wed, 19 Sep 2012 20:13:44 +0100
Message-ID: <1348082024.2636.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Andrew Jackson <ajackson@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58366 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754843Ab2ISTNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:13:48 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial version by Stuart Hodgson <smhodgson@solarflare.com>

Some PHC device drivers may deliver PPS events with a significant
and variable delay, but still be able to measure precisely what
that delay is.

Add a pps_sub_ts() function for subtracting a delay from the
timestamp(s) in a PPS event, and a PTP event type (PTP_CLOCK_PPSUSR)
for which the caller provides a complete PPS event.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/ptp/ptp_clock.c          |    5 +++++
 include/linux/pps_kernel.h       |    9 +++++++++
 include/linux/ptp_clock_kernel.h |   10 ++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 1e528b5..966875d 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -300,6 +300,11 @@ void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
 		pps_get_ts(&evt);
 		pps_event(ptp->pps_source, &evt, PTP_PPS_EVENT, NULL);
 		break;
+
+	case PTP_CLOCK_PPSUSR:
+		pps_event(ptp->pps_source, &event->pps_times,
+			  PTP_PPS_EVENT, NULL);
+		break;
 	}
 }
 EXPORT_SYMBOL(ptp_clock_event);
diff --git a/include/linux/pps_kernel.h b/include/linux/pps_kernel.h
index 9404854..0cc45ae 100644
--- a/include/linux/pps_kernel.h
+++ b/include/linux/pps_kernel.h
@@ -116,5 +116,14 @@ static inline void pps_get_ts(struct pps_event_time *ts)
 
 #endif /* CONFIG_NTP_PPS */
 
+/* Subtract known time delay from PPS event time(s) */
+static inline void pps_sub_ts(struct pps_event_time *ts, struct timespec delta)
+{
+	ts->ts_real = timespec_sub(ts->ts_real, delta);
+#ifdef CONFIG_NTP_PPS
+	ts->ts_raw = timespec_sub(ts->ts_raw, delta);
+#endif
+}
+
 #endif /* LINUX_PPS_KERNEL_H */
 
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 945704c..a644b29 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -21,6 +21,7 @@
 #ifndef _PTP_CLOCK_KERNEL_H_
 #define _PTP_CLOCK_KERNEL_H_
 
+#include <linux/pps_kernel.h>
 #include <linux/ptp_clock.h>
 

@@ -110,6 +111,7 @@ enum ptp_clock_events {
 	PTP_CLOCK_ALARM,
 	PTP_CLOCK_EXTTS,
 	PTP_CLOCK_PPS,
+	PTP_CLOCK_PPSUSR,
 };
 
 /**
@@ -117,13 +119,17 @@ enum ptp_clock_events {
  *
  * @type:  One of the ptp_clock_events enumeration values.
  * @index: Identifies the source of the event.
- * @timestamp: When the event occured.
+ * @timestamp: When the event occurred (%PTP_CLOCK_EXTTS only).
+ * @pps_times: When the event occurred (%PTP_CLOCK_PPSUSR only).
  */
 
 struct ptp_clock_event {
 	int type;
 	int index;
-	u64 timestamp;
+	union {
+		u64 timestamp;
+		struct pps_event_time pps_times;
+	};
 };
 
 /**
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
