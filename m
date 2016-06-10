From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [RFC] Handle error writing UINT_MAX to u32 fields
Date: Thu,  9 Jun 2016 20:40:52 -0600
Message-ID: <1465526452-30567-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: xypron.glpk@gmx.de, eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58273 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcFJCnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 22:43:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have scripts which write to certain fields on 3.18 kernels but
this seems to be failing on 4.4 kernels.
An entry which we write to here is xfrm_aevent_rseqth which is u32.

echo 4294967295  > /proc/sys/net/core/xfrm_aevent_rseqth

Commit 230633d109e35b0a24277498e773edeb79b4a331 ("kernel/sysctl.c:
detect overflows when converting to int") prevented writing to
sysctl entries when integer overflow occurs.
However, this does not apply to unsigned integers.

u32 should be able to hold 4294967295 here, however it fails due
to this check.

static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
...
			if (*lvalp > (unsigned long) INT_MAX)
				return -EINVAL;

I would like to know if introducing a new handler proc_douintvec
would work here. Sample output and implementation below. This can be
cleaned up and added for other u32 fields in kernel.

dev0# cat /proc/sys/net/core/xfrm_aevent_rseqth
2
dev0# echo 4294967295  > /proc/sys/net/core/xfrm_aevent_rseqth
dev0# cat /proc/sys/net/core/xfrm_aevent_rseqth
4294967295
dev0#
dev0# echo -1  > /proc/sys/net/core/xfrm_aevent_rseqth
bash: echo: write error: Invalid argument

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/linux/sysctl.h |  2 ++
 kernel/sysctl.c        | 32 ++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_sysctl.c |  2 +-
 3 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index fa7bc29..ef17db6c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -41,6 +41,8 @@ extern int proc_dostring(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
+extern int proc_douintvec(struct ctl_table *, int,
+			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec_minmax(struct ctl_table *, int,
 				void __user *, size_t *, loff_t *);
 extern int proc_dointvec_jiffies(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 725587f..6362859 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2094,6 +2094,21 @@ static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
 	return 0;
 }
 
+static int do_proc_douintvec_conv(bool *negp, unsigned long *lvalp,
+				 int *valp,
+				 int write, void *data)
+{
+	if (write) {
+		if (*negp)
+			return -EINVAL;
+		*valp = *lvalp;
+	} else {
+		unsigned int val = *valp;
+		*lvalp = (unsigned long)val;
+	}
+	return 0;
+}
+
 static const char proc_wspace_sep[] = { ' ', '\t', '\n' };
 
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
@@ -2217,6 +2232,16 @@ int proc_dointvec(struct ctl_table *table, int write,
 		    	    NULL,NULL);
 }
 
+/**
+ * proc_douintvec - read a vector of unsigned integers
+ */
+int proc_douintvec(struct ctl_table *table, int write,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+    return do_proc_dointvec(table,write,buffer,lenp,ppos,
+			    do_proc_douintvec_conv, NULL);
+}
+
 /*
  * Taint values can only be increased
  * This means we can safely use a temporary.
@@ -2812,6 +2837,12 @@ int proc_dointvec(struct ctl_table *table, int write,
 	return -ENOSYS;
 }
 
+int proc_douintvec(struct ctl_table *table, int write,
+		  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
 int proc_dointvec_minmax(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2857,6 +2888,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
  * exception granted :-)
  */
 EXPORT_SYMBOL(proc_dointvec);
+EXPORT_SYMBOL(proc_douintvec);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
 EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05a6e3d..1fa3b1a 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -23,7 +23,7 @@ static struct ctl_table xfrm_table[] = {
 		.procname	= "xfrm_aevent_rseqth",
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_douintvec
 	},
 	{
 		.procname	= "xfrm_larval_drop",
-- 
1.9.1
