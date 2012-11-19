From: Rui Xiang <leo.ruixiang@gmail.com>
Subject: [PATCH RFC 4/5] printk: add ns_printk for specific syslog_ns
Date: Mon, 19 Nov 2012 16:17:34 +0800
Message-ID: <50A9EB1E.2010000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: serge.hallyn@canonical.com, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60741 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab2KSIRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:17:46 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so280060pad.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 00:17:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <clbchenlibo.chen@huawei.com>

In some context such as iptable, we can not get correct syslog_ns by
current_syslog_ns, because we get init_syslog_ns instead of syslog_ns
belonged to container.

We add a new interface ns_printk,and give it an parameter syslog_ns.

Signed-off-by: Libo Chen <clbchenlibo.chen@huawei.com>
Signed-off-by: Xiang Rui <rui.xiang@huawei.com>
---
 include/linux/printk.h |    1 +
 kernel/printk.c        |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index e0c60d9..444d229 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -119,6 +119,7 @@ asmlinkage int printk_emit(int facility, int level,

 asmlinkage __printf(1, 2) __cold
 int printk(const char *fmt, ...);
+int ns_printk(struct syslog_namespace *syslog_ns, const char *fmt, ...);

 /*
  * Special printk facility for scheduler use only, _DO_NOT_USE_ !
diff --git a/kernel/printk.c b/kernel/printk.c
index 2ef9c46..85a9965 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -1681,6 +1681,43 @@ asmlinkage int printk(const char *fmt, ...)
 }
 EXPORT_SYMBOL(printk);

+/**
+ * ns_printk - print a kernel message in syslog_ns
+ * @syslog_ns: syslog namespace
+ * @fmt: format string
+ *
+ * This is ns_printk().
+ * It can be called from container context. We add a param
+ * syslog_ns to record current syslog namespace,because
+ * we can't get the correct syslog_ns from current_syslog_ns
+ * in some context,e.g. iptable.
+ *
+ * See the vsnprintf() documentation for format string extensions over C99.
+ **/
+asmlinkage int ns_printk(struct syslog_namespace *syslog_ns,
+					const char *fmt, ...)
+{
+	va_list args;
+	int r;
+
+	if (!syslog_ns)
+		syslog_ns = current_syslog_ns();
+
+#ifdef CONFIG_KGDB_KDB
+	if (unlikely(kdb_trap_printk)) {
+		va_start(args, fmt);
+		r = vkdb_printf(fmt, args);
+		va_end(args);
+		return r;
+	}
+#endif
+	va_start(args, fmt);
+	r = vprintk_emit(0, -1, NULL, 0, fmt, args, syslog_ns);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(ns_printk);
 #else /* CONFIG_PRINTK */

 #define LOG_LINE_MAX		0
-- 
1.7.1
