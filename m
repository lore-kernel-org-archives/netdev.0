From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 1/4] kernel: time: Add current_nw_timestamp() for network timestamps
Date: Wed, 24 Feb 2016 23:07:08 -0800
Message-ID: <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34642 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759284AbcBYHI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 02:08:56 -0500
Received: by mail-pf0-f193.google.com with SMTP id 71so2350753pfv.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 23:08:55 -0800 (PST)
In-Reply-To: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP timestamp messages and IP source route options require
timestamps to be in milliseconds modulo 24 hours from
midnight UTC format.

Add a time function to support this. The function returns the
required timestamp in network byte order.

The function also uses y2038 safe time functions and data
structures.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 include/linux/ip.h     |  2 ++
 include/linux/time64.h |  3 +++
 kernel/time/time.c     | 26 ++++++++++++++++++++++++++
 3 files changed, 31 insertions(+)

diff --git a/include/linux/ip.h b/include/linux/ip.h
index 492bc65..edf923e 100644
--- a/include/linux/ip.h
+++ b/include/linux/ip.h
@@ -34,4 +34,6 @@ static inline struct iphdr *ipip_hdr(const struct sk_buff *skb)
 {
 	return (struct iphdr *)skb_transport_header(skb);
 }
+
+extern __be32 current_nw_timestamp(void);
 #endif	/* _LINUX_IP_H */
diff --git a/include/linux/time64.h b/include/linux/time64.h
index 367d5af..5b5db3b 100644
--- a/include/linux/time64.h
+++ b/include/linux/time64.h
@@ -35,6 +35,9 @@ struct itimerspec64 {
 #define NSEC_PER_SEC	1000000000L
 #define FSEC_PER_SEC	1000000000000000LL
 
+#define SECONDS_PER_DAY	86400
+#define MSEC_PER_DAY	(SECONDS_PER_DAY * MSEC_PER_SEC)
+
 /* Located here for timespec[64]_valid_strict */
 #define TIME64_MAX			((s64)~((u64)1 << 63))
 #define KTIME_MAX			((s64)~((u64)1 << 63))
diff --git a/kernel/time/time.c b/kernel/time/time.c
index 86751c6..6df15df 100644
--- a/kernel/time/time.c
+++ b/kernel/time/time.c
@@ -245,6 +245,32 @@ struct timespec current_fs_time(struct super_block *sb)
 EXPORT_SYMBOL(current_fs_time);
 
 /*
+ * current_nw_timestamp - Return network time
+ *
+ * Return milliseconds since midnight in network byte order.
+ */
+__be32 current_nw_timestamp(void)
+{
+	u64 now;
+	u32 secs;
+	u32 msecs;
+	struct timespec64 ts;
+
+	ktime_get_ts64(&ts);
+
+	/* Get secs since midnight. */
+	now = div_u64_rem(ts.tv_sec, SECONDS_PER_DAY, &secs);
+	/* Convert to msecs. */
+	msecs = secs * MSEC_PER_SEC;
+	/* Convert nsec to msec. */
+	msecs += (u32)ts.tv_nsec/NSEC_PER_MSEC;
+
+	/* Convert to network byte order. */
+	return htons(msecs);
+}
+EXPORT_SYMBOL(current_nw_timestamp);
+
+/*
  * Convert jiffies to milliseconds and back.
  *
  * Avoid unnecessary multiplications/divisions in the
-- 
1.9.1
