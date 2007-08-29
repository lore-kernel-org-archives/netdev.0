From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 08/12] ktime_sub_ns: analog of ktime_add_ns
Date: Wed, 29 Aug 2007 12:58:17 -0700
Message-ID: <20070829195843.076226125@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57850 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932084AbXH2UCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:02:20 -0400
Content-Disposition: inline; filename=ktime_sub_ns.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add macro/function to subtract constant nanoseconds.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/ktime.h	2007-08-29 11:31:59.000000000 -0700
+++ b/include/linux/ktime.h	2007-08-29 11:41:19.000000000 -0700
@@ -102,6 +102,13 @@ static inline ktime_t ktime_set(const lo
 #define ktime_add_ns(kt, nsval) \
 		({ (ktime_t){ .tv64 = (kt).tv64 + (nsval) }; })
 
+/*
+ * Subtract a ktime_t variable and a scalar nanosecond value.
+ * res = kt - nsval:
+ */
+#define ktime_sub_ns(kt, nsval) \
+		({ (ktime_t){ .tv64 = (kt).tv64 - (nsval) }; })
+
 /* convert a timespec to ktime_t format: */
 static inline ktime_t timespec_to_ktime(struct timespec ts)
 {
@@ -200,6 +207,15 @@ static inline ktime_t ktime_add(const kt
 extern ktime_t ktime_add_ns(const ktime_t kt, u64 nsec);
 
 /**
+ * ktime_sub_ns - Subtract a scalar nanoseconds value to a ktime_t variable
+ * @kt:	        minuend
+ * @nsec:	subtrahend in nanoseconds
+ *
+ * Returns the difference of @kt and @nsec in ktime_t format
+ */
+extern ktime_t ktime_sub_ns(const ktime_t kt, u64 nsec);
+
+/**
  * timespec_to_ktime - convert a timespec to ktime_t format
  * @ts:		the timespec variable to convert
  *
--- a/kernel/hrtimer.c	2007-08-29 11:31:59.000000000 -0700
+++ b/kernel/hrtimer.c	2007-08-29 11:41:19.000000000 -0700
@@ -277,6 +277,30 @@ ktime_t ktime_add_ns(const ktime_t kt, u
 }
 
 EXPORT_SYMBOL_GPL(ktime_add_ns);
+
+/**
+ * ktime_sub_ns - Subract a scalar nanoseconds value to a ktime_t variable
+ * @kt:		minuend
+ * @nsec:	subtrahend in nanoseconds
+ *
+ * Returns the difference of kt and nsec in ktime_t format
+ */
+ktime_t ktime_sub_ns(const ktime_t kt, u64 nsec)
+{
+	ktime_t tmp;
+
+	if (likely(nsec < NSEC_PER_SEC)) {
+		tmp.tv64 = nsec;
+	} else {
+		unsigned long rem = do_div(nsec, NSEC_PER_SEC);
+
+		tmp = ktime_set((long)nsec, rem);
+	}
+
+	return ktime_sub(kt, tmp);
+}
+
+EXPORT_SYMBOL_GPL(ktime_add_ns);
 # endif /* !CONFIG_KTIME_SCALAR */
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

