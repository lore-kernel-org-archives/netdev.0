From: Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH v3 09/11] syslog_ns: implement ns_printk_emit for specific syslog_ns
Date: Wed, 7 Aug 2013 15:37:13 +0800
Message-ID: <1375861035-24320-10-git-send-email-rui.xiang@huawei.com>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<serge.hallyn@ubuntu.com>, <ebiederm@xmission.com>,
	<akpm@linux-foundation.org>, <gaofeng@cn.fujitsu.com>,
	<guz.fnst@cn.fujitsu.com>, <libo.chen@huawei.com>,
	Rui Xiang <rui.xiang@huawei.com>
To: <containers@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45039 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab3HGHiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 03:38:11 -0400
In-Reply-To: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prink_emit use init_syslog_ns as a parameter of namespace,
but in some context, it will cause that logs generated
through printk_emit will be exported to host, for instance,
devkmsg_writev.

We add a new interface ns_printk_emit to pass an syslog_ns
parameter, and use it in devkmsg_writev.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 include/linux/printk.h |  6 ++++++
 kernel/printk.c        | 20 +++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index bf83ad9..4c7e2be 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -121,6 +121,12 @@ asmlinkage int printk_emit(int facility, int level,
 			   const char *dict, size_t dictlen,
 			   const char *fmt, ...);
 
+asmlinkage __printf(6, 7) __cold
+asmlinkage int ns_printk_emit(struct syslog_namespace *ns,
+			   int facility, int level,
+			   const char *dict, size_t dictlen,
+			   const char *fmt, ...);
+
 asmlinkage __printf(1, 2) __cold
 int printk(const char *fmt, ...);
 
diff --git a/kernel/printk.c b/kernel/printk.c
index 38e8869..b60c1d4 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -420,6 +420,7 @@ static ssize_t devkmsg_writev(struct kiocb *iocb, const struct iovec *iv,
 	int facility = 1;	/* LOG_USER */
 	size_t len = iov_length(iv, count);
 	ssize_t ret = len;
+	struct namespace *ns = current_user_ns()->syslog_ns;
 
 	if (len > LOG_LINE_MAX)
 		return -EINVAL;
@@ -461,7 +462,7 @@ static ssize_t devkmsg_writev(struct kiocb *iocb, const struct iovec *iv,
 	}
 	line[len] = '\0';
 
-	printk_emit(facility, level, NULL, 0, "%s", line);
+	ns_printk_emit(ns, facility, level, NULL, 0, "%s", line);
 out:
 	kfree(buf);
 	return ret;
@@ -1722,6 +1723,23 @@ asmlinkage int printk_emit(int facility, int level,
 }
 EXPORT_SYMBOL(printk_emit);
 
+asmlinkage int ns_printk_emit(struct syslog_namespace *ns,
+			   int facility, int level,
+			   const char *dict, size_t dictlen,
+			   const char *fmt, ...)
+{
+	va_list args;
+	int r;
+
+	va_start(args, fmt);
+	r = ns_vprintk_emit(ns, facility, level, dict, dictlen, fmt,
+								args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(ns_printk_emit);
+
 /**
  * printk - print a kernel message
  * @fmt: format string
-- 
1.8.2.2
