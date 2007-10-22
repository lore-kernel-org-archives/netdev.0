From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC][PATCH 1/3][XFRM]: Define packet processing statistics.
Date: Mon, 22 Oct 2007 15:11:16 +0900
Message-ID: <11930334761787-git-send-email-nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:47272 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbXJVGcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:32:18 -0400
In-Reply-To: <20071017.213523.58458049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This statistics is shown as /proc/net/xfrm_stat about transformation
error (or almost error) factor at packet processing for developer.
It is not a SNMP/MIB specification but a counter designed from
current transformation source code.

- Inbound errors
XfrmInError               - all errors which is not matched others
XfrmInBufferError         - no buffer is left
XfrmInHdrError            - header error
XfrmInNoStates            - no state is found
XfrmInStateProtoError     - error at transformation protocol
XfrmInStateModeError      - error at transformation mode
XfrmInSeqOutOfWindow      - sequence out of window
XfrmInStateExpired        - state is expired
XfrmInStateMismatch       - state has mismatch option
XfrmInStateInvalid        - state is invalid
XfrmInTmplMismatch        - no matching template for states
XfrmInNoPols              - no policy is found for states
XfrmInPolBlock            - policy discards
XfrmInPolError            - policy error

- Outbound errors
XfrmOutError              - all errors which is not matched others
XfrmOutLengthError        - length error
XfrmOutBundleError        - error at bundle
XfrmOutNoStates           - no state is found
XfrmOutStateProtoError    - error at transformation protocol
XfrmOutStateModeError     - error at transformation mode
XfrmOutStateExpired       - state expired
XfrmOutPolBlock           - policy discards
XfrmOutPolError           - policy error

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/linux/snmp.h   |   30 +++++++++++++++
 include/net/snmp.h     |    5 ++
 include/net/xfrm.h     |   17 ++++++++
 net/xfrm/Makefile      |    1 +
 net/xfrm/xfrm_policy.c |   35 +++++++++++++++++
 net/xfrm/xfrm_proc.c   |   96 ++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 184 insertions(+), 0 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 89f0c2b..3fc89f4 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -217,4 +217,34 @@ enum
 	__LINUX_MIB_MAX
 };
 
+/* xfrm mib definitions */
+enum
+{
+	XFRM_MIB_NUM = 0,
+	XFRM_MIB_INERROR,		/* XfrmInError */
+	XFRM_MIB_INBUFFERERROR,		/* XfrmInBufferError */
+	XFRM_MIB_INHDRERROR,		/* XfrmInHdrError */
+	XFRM_MIB_INNOSTATES,		/* XfrmInNoStates */
+	XFRM_MIB_INSTATEPROTOERROR,	/* XfrmInStateProtoError */
+	XFRM_MIB_INSTATEMODEERROR,	/* XfrmInStateModeError */
+	XFRM_MIB_INSEQOUTOFWINDOW,	/* XfrmInSeqOutOfWindow */
+	XFRM_MIB_INSTATEEXPIRED,	/* XfrmInStateExpired */
+	XFRM_MIB_INSTATEMISMATCH,	/* XfrmInStateMismatch */
+	XFRM_MIB_INSTATEINVALID,	/* XfrmInStateInvalid */
+	XFRM_MIB_INTMPLMISMATCH,	/* XfrmInTmplMismatch */
+	XFRM_MIB_INNOPOLS,		/* XfrmInNoPols */
+	XFRM_MIB_INPOLBLOCK,		/* XfrmInPolBlock */
+	XFRM_MIB_INPOLERROR,		/* XfrmInPolError */
+	XFRM_MIB_OUTERROR,		/* XfrmOutError */
+	XFRM_MIB_OUTLENGTHERROR,	/* XfrmOutLengthError */
+	XFRM_MIB_OUTBUNDLEERROR,	/* XfrmOutBundleError */
+	XFRM_MIB_OUTNOSTATES,		/* XfrmOutNoStates */
+	XFRM_MIB_OUTSTATEPROTOERROR,	/* XfrmOutStateProtoError */
+	XFRM_MIB_OUTSTATEMODEERROR,	/* XfrmOutStateModeError */
+	XFRM_MIB_OUTSTATEEXPIRED,	/* XfrmOutStateExpired */
+	XFRM_MIB_OUTPOLBLOCK,		/* XfrmOutPolBlock */
+	XFRM_MIB_OUTPOLERROR,		/* XfrmOutPolError */
+	__XFRM_MIB_MAX
+};
+
 #endif	/* _LINUX_SNMP_H */
diff --git a/include/net/snmp.h b/include/net/snmp.h
index ea206bf..37bcf19 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -117,6 +117,11 @@ struct linux_mib {
 	unsigned long	mibs[LINUX_MIB_MAX];
 };
 
+/* Xfrm */
+#define XFRM_MIB_MAX	__XFRM_MIB_MAX
+struct xfrm_mib {
+	unsigned long	mibs[XFRM_MIB_MAX];
+};
 
 /* 
  * FIXME: On x86 and some other CPUs the split into user and softirq parts
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 688f6f5..679d915 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -19,6 +19,9 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+#ifdef CONFIG_XFRM_STATISTICS
+#include <net/snmp.h>
+#endif
 
 #define XFRM_PROTO_ESP		50
 #define XFRM_PROTO_AH		51
@@ -34,6 +37,17 @@
 #define MODULE_ALIAS_XFRM_TYPE(family, proto) \
 	MODULE_ALIAS("xfrm-type-" __stringify(family) "-" __stringify(proto))
 
+#ifdef CONFIG_XFRM_STATISTICS
+DECLARE_SNMP_STAT(struct xfrm_mib, xfrm_statistics);
+#define XFRM_INC_STATS(field)		SNMP_INC_STATS(xfrm_statistics, field)
+#define XFRM_INC_STATS_BH(field)	SNMP_INC_STATS_BH(xfrm_statistics, field)
+#define XFRM_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(xfrm_statistics, field)
+#else
+#define XFRM_INC_STATS(field)
+#define XFRM_INC_STATS_BH(field)
+#define XFRM_INC_STATS_USER(field)
+#endif
+
 extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
@@ -985,6 +999,9 @@ extern void xfrm_state_init(void);
 extern void xfrm4_state_init(void);
 extern void xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
+#ifdef CONFIG_XFRM_STATISTICS
+extern int xfrm_proc_init(void);
+#endif
 
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
 extern struct xfrm_state *xfrm_state_alloc(void);
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 45744a3..332cfb0 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,5 +4,6 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o xfrm_algo.o
+obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b702bd8..e770998 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -25,11 +25,19 @@
 #include <linux/cache.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
+#ifdef CONFIG_XFRM_STATISTICS
+#include <net/snmp.h>
+#endif
 
 #include "xfrm_hash.h"
 
 int sysctl_xfrm_larval_drop __read_mostly;
 
+#ifdef CONFIG_XFRM_STATISTICS
+DEFINE_SNMP_STAT(struct xfrm_mib, xfrm_statistics) __read_mostly;
+EXPORT_SYMBOL(xfrm_statistics);
+#endif
+
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -2078,6 +2086,27 @@ static struct notifier_block xfrm_dev_notifier = {
 	0
 };
 
+#ifdef CONFIG_XFRM_STATISTICS
+static int __init xfrm_statistics_init(void)
+{
+	xfrm_statistics[0] = alloc_percpu(struct xfrm_mib);
+	if (!xfrm_statistics[0])
+		goto err0;
+
+	xfrm_statistics[1] = alloc_percpu(struct xfrm_mib);
+	if (!xfrm_statistics[1])
+		goto err1;
+
+	return 0;
+
+err1:
+	free_percpu(xfrm_statistics[0]);
+	xfrm_statistics[0] = NULL;
+err0:
+	return -ENOMEM;
+}
+#endif
+
 static void __init xfrm_policy_init(void)
 {
 	unsigned int hmask, sz;
@@ -2114,9 +2143,15 @@ static void __init xfrm_policy_init(void)
 
 void __init xfrm_init(void)
 {
+#ifdef CONFIG_XFRM_STATISTICS
+	xfrm_statistics_init();
+#endif
 	xfrm_state_init();
 	xfrm_policy_init();
 	xfrm_input_init();
+#ifdef CONFIG_XFRM_STATISTICS
+	xfrm_proc_init();
+#endif
 }
 
 #ifdef CONFIG_AUDITSYSCALL
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
new file mode 100644
index 0000000..7a44a12
--- /dev/null
+++ b/net/xfrm/xfrm_proc.c
@@ -0,0 +1,96 @@
+/*
+ * xfrm_proc.c
+ *
+ * Copyright (C)2006-2007 USAGI/WIDE Project
+ *
+ * Authors:	Masahide NAKAMURA <nakam@linux-ipv6.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <net/net_namespace.h>
+#include <net/snmp.h>
+#include <net/xfrm.h>
+
+static struct snmp_mib xfrm_mib_list[] = {
+	SNMP_MIB_ITEM("XfrmInError", XFRM_MIB_INERROR),
+	SNMP_MIB_ITEM("XfrmInBufferError", XFRM_MIB_INBUFFERERROR),
+	SNMP_MIB_ITEM("XfrmInHdrError", XFRM_MIB_INHDRERROR),
+	SNMP_MIB_ITEM("XfrmInNoStates", XFRM_MIB_INNOSTATES),
+	SNMP_MIB_ITEM("XfrmInStateProtoError", XFRM_MIB_INSTATEPROTOERROR),
+	SNMP_MIB_ITEM("XfrmInStateModeError", XFRM_MIB_INSTATEMODEERROR),
+	SNMP_MIB_ITEM("XfrmInSeqOutOfWindow", XFRM_MIB_INSEQOUTOFWINDOW),
+	SNMP_MIB_ITEM("XfrmInStateExpired", XFRM_MIB_INSTATEEXPIRED),
+	SNMP_MIB_ITEM("XfrmInStateMismatch", XFRM_MIB_INSTATEMISMATCH),
+	SNMP_MIB_ITEM("XfrmInStateInvalid", XFRM_MIB_INSTATEINVALID),
+	SNMP_MIB_ITEM("XfrmInTmplMismatch", XFRM_MIB_INTMPLMISMATCH),
+	SNMP_MIB_ITEM("XfrmInNoPols", XFRM_MIB_INNOPOLS),
+	SNMP_MIB_ITEM("XfrmInPolBlock", XFRM_MIB_INPOLBLOCK),
+	SNMP_MIB_ITEM("XfrmInPolError", XFRM_MIB_INPOLERROR),
+	SNMP_MIB_ITEM("XfrmOutError", XFRM_MIB_OUTERROR),
+	SNMP_MIB_ITEM("XfrmOutLengthError", XFRM_MIB_OUTLENGTHERROR),
+	SNMP_MIB_ITEM("XfrmOutBundleError", XFRM_MIB_OUTBUNDLEERROR),
+	SNMP_MIB_ITEM("XfrmOutNoStates", XFRM_MIB_OUTNOSTATES),
+	SNMP_MIB_ITEM("XfrmOutStateProtoError", XFRM_MIB_OUTSTATEPROTOERROR),
+	SNMP_MIB_ITEM("XfrmOutStateModeError", XFRM_MIB_OUTSTATEMODEERROR),
+	SNMP_MIB_ITEM("XfrmOutStateExpired", XFRM_MIB_OUTSTATEEXPIRED),
+	SNMP_MIB_ITEM("XfrmOutPolBlock", XFRM_MIB_OUTPOLBLOCK),
+	SNMP_MIB_ITEM("XfrmOutPolError", XFRM_MIB_OUTPOLERROR),
+	SNMP_MIB_SENTINEL
+};
+
+static unsigned long
+fold_field(void *mib[], int offt)
+{
+        unsigned long res = 0;
+        int i;
+
+        for_each_possible_cpu(i) {
+                res += *(((unsigned long *)per_cpu_ptr(mib[0], i)) + offt);
+                res += *(((unsigned long *)per_cpu_ptr(mib[1], i)) + offt);
+        }
+        return res;
+}
+
+static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
+{
+	int i;
+	for (i=0; xfrm_mib_list[i].name; i++)
+		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
+			   fold_field((void **)xfrm_statistics,
+				      xfrm_mib_list[i].entry));
+	return 0;
+}
+
+static int xfrm_statistics_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, xfrm_statistics_seq_show, NULL);
+}
+
+static struct file_operations xfrm_statistics_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = xfrm_statistics_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
+int __init xfrm_proc_init(void)
+{
+	int rc = 0;
+
+	if (!proc_net_fops_create(&init_net, "xfrm_stat", S_IRUGO,
+				  &xfrm_statistics_seq_fops))
+		goto stat_fail;
+
+ out:
+	return rc;
+
+ stat_fail:
+	rc = -ENOMEM;
+	goto out;
+}
-- 
1.4.4.2

