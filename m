From: Patrick McHardy <kaber@trash.net>
Subject: [RFC TIME 01/03]: Add jiffies_to_nsecs/nsecs_to_jiffies
Date: Sun,  4 Mar 2007 20:05:31 +0100 (MET)
Message-ID: <20070304190440.21142.496.sendpatchset@localhost.localdomain>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61546 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbXCDTFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:05:32 -0500
In-Reply-To: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TIME]: Add jiffies_to_nsecs/nsecs_to_jiffies

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 861b3967e1bb01335e544220df779f91b20a27e7
tree cd877a5091f461008ec708b801a2fa04d3c26004
parent 2ff7354fe888f46f6629b57e463b0a1eb956c02b
author Patrick McHardy <kaber@trash.net> Fri, 02 Mar 2007 02:49:43 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 04 Mar 2007 19:31:38 +0100

 include/linux/jiffies.h |    2 ++
 kernel/time.c           |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index c080f61..e01f8f2 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -263,8 +263,10 @@ #endif
  */
 extern unsigned int jiffies_to_msecs(const unsigned long j);
 extern unsigned int jiffies_to_usecs(const unsigned long j);
+extern unsigned int jiffies_to_nsecs(const unsigned long j);
 extern unsigned long msecs_to_jiffies(const unsigned int m);
 extern unsigned long usecs_to_jiffies(const unsigned int u);
+extern unsigned long nsecs_to_jiffies(const unsigned int n);
 extern unsigned long timespec_to_jiffies(const struct timespec *value);
 extern void jiffies_to_timespec(const unsigned long jiffies,
 				struct timespec *value);
diff --git a/kernel/time.c b/kernel/time.c
index c6c80ea..736f5e1 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -500,6 +500,18 @@ #endif
 }
 EXPORT_SYMBOL(jiffies_to_usecs);
 
+unsigned int jiffies_to_nsecs(const unsigned long j)
+{
+#if HZ <= NSEC_PER_SEC && !(NSEC_PER_SEC % HZ)
+	return (NSEC_PER_SEC / HZ) * j;
+#elif HZ > NSEC_PER_SEC && !(HZ % NSEC_PER_SEC)
+	return (j + (HZ / NSEC_PER_SEC) - 1)/(HZ / NSEC_PER_SEC);
+#else
+	return (j * NSEC_PER_SEC) / HZ;
+#endif
+}
+EXPORT_SYMBOL(jiffies_to_nsecs);
+
 /*
  * When we convert to jiffies then we interpret incoming values
  * the following way:
@@ -569,6 +581,20 @@ #endif
 }
 EXPORT_SYMBOL(usecs_to_jiffies);
 
+unsigned long nsecs_to_jiffies(const unsigned int n)
+{
+	if (n > jiffies_to_nsecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+#if HZ <= NSEC_PER_SEC && (!NSEC_PER_SEC % HZ)
+	return (n + (NSEC_PER_SEC / HZ) - 1) / (NSEC_PER_SEC / HZ);
+#elif HZ > NSEC_PER_SEC && !(HZ % NSEC_PER_SEC)
+	return n * (HZ / NSEC_PER_SEC);
+#else
+	return (n * HZ + NSEC_PER_SEC - 1) / NSEC_PER_SEC;
+#endif
+}
+EXPORT_SYMBOL(nsecs_to_jiffies);
+
 /*
  * The TICK_NSEC - 1 rounds up the value to the next resolution.  Note
  * that a remainder subtract here would not do the right thing as the
