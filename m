From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: Normalize jiffies reported to userspace, in neighbor
 management code
Date: Mon, 10 Nov 2003 10:45:36 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110.104536.79654717.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

more jiffies normalizations reported to userspace, in core/neighbour.c.

===== include/linux/sysctl.h 1.53 vs edited =====
--- 1.53/include/linux/sysctl.h	Thu Oct 30 05:19:30 2003
+++ edited/include/linux/sysctl.h	Tue Nov 11 01:12:31 2003
@@ -726,6 +726,8 @@
 				void __user *, size_t *);
 extern int proc_dointvec_jiffies(ctl_table *, int, struct file *,
 				 void __user *, size_t *);
+extern int proc_dointvec_userhz_jiffies(ctl_table *, int, struct file *,
+					void __user *, size_t *);
 extern int proc_doulongvec_minmax(ctl_table *, int, struct file *,
 				  void __user *, size_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(ctl_table *table, int,
===== kernel/sysctl.c 1.55 vs edited =====
--- 1.55/kernel/sysctl.c	Thu Oct  2 16:12:07 2003
+++ edited/kernel/sysctl.c	Tue Nov 11 01:12:32 2003
@@ -37,6 +37,7 @@
 #include <linux/hugetlb.h>
 #include <linux/security.h>
 #include <linux/initrd.h>
+#include <linux/times.h>
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_ROOT_NFS
@@ -1750,6 +1751,114 @@
     return do_proc_dointvec(table,write,filp,buffer,lenp,HZ,OP_SET);
 }
 
+/**
+ * proc_dointvec_userhz_jiffies - read a vector of integers as 1/USER_HZ seconds
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @filp: the file structure
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ *
+ * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
+ * values from/to the user buffer, treated as an ASCII string. 
+ * The values read are assumed to be in 1/USER_HZ seconds, and 
+ * are converted into jiffies.
+ *
+ * Returns 0 on success.
+ */
+int proc_dointvec_userhz_jiffies(ctl_table *table, int write, struct file *filp,
+				 void __user *buffer, size_t *lenp)
+{
+	int *i, vleft, first=1, neg, val;
+	size_t left, len;
+	
+	#define TMPBUFLEN 20
+	char buf[TMPBUFLEN], *p;
+	
+	if (!table->data || !table->maxlen || !*lenp ||
+	    (filp->f_pos && !write)) {
+		*lenp = 0;
+		return 0;
+	}
+	
+	i = (int *) table->data;
+	vleft = table->maxlen / sizeof(int);
+	left = *lenp;
+	
+	for (; left && vleft--; i++, first=0) {
+		if (write) {
+			while (left) {
+				char c;
+				if (get_user(c,(char __user *) buffer))
+					return -EFAULT;
+				if (!isspace(c))
+					break;
+				left--;
+				buffer++;
+			}
+			if (!left)
+				break;
+			neg = 0;
+			len = left;
+			if (len > TMPBUFLEN-1)
+				len = TMPBUFLEN-1;
+			if(copy_from_user(buf, buffer, len))
+				return -EFAULT;
+			buf[len] = 0;
+			p = buf;
+			if (*p == '-' && left > 1) {
+				neg = 1;
+				left--, p++;
+			}
+			if (*p < '0' || *p > '9')
+				break;
+			val = clock_t_to_jiffies(simple_strtoul(p, &p, 0));
+			len = p-buf;
+			if ((len < left) && *p && !isspace(*p))
+				break;
+			if (neg)
+				val = -val;
+			buffer += len;
+			left -= len;
+			*i = val;
+		} else {
+			p = buf;
+			if (!first)
+				*p++ = '\t';
+			sprintf(p, "%d", jiffies_to_clock_t(*i));
+			len = strlen(buf);
+			if (len > left)
+				len = left;
+			if(copy_to_user(buffer, buf, len))
+				return -EFAULT;
+			left -= len;
+			buffer += len;
+		}
+	}
+
+	if (!write && !first && left) {
+		if(put_user('\n', (char *) buffer))
+			return -EFAULT;
+		left--, buffer++;
+	}
+	if (write) {
+		p = (char *) buffer;
+		while (left) {
+			char c;
+			if(get_user(c, p++))
+				return -EFAULT;
+			if (!isspace(c))
+				break;
+			left--;
+		}
+	}
+	if (write && first)
+		return -EINVAL;
+	*lenp -= left;
+	filp->f_pos += *lenp;
+	return 0;
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(ctl_table *table, int write, struct file *filp,
@@ -1788,6 +1897,12 @@
 	return -ENOSYS;
 }
 
+int proc_dointvec_userhz_jiffies(ctl_table *table, int write, struct file *filp,
+		    void *buffer, size_t *lenp)
+{
+	return -ENOSYS;
+}
+
 int proc_doulongvec_minmax(ctl_table *table, int write, struct file *filp,
 		    void *buffer, size_t *lenp)
 {
@@ -1975,6 +2090,12 @@
 	return -ENOSYS;
 }
 
+int proc_dointvec_userhz_jiffies(ctl_table *table, int write, struct file *filp,
+			  void *buffer, size_t *lenp)
+{
+	return -ENOSYS;
+}
+
 int proc_doulongvec_minmax(ctl_table *table, int write, struct file *filp,
 		    void __user *buffer, size_t *lenp)
 {
@@ -2007,6 +2128,7 @@
 EXPORT_SYMBOL(proc_dointvec);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
+EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
 EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
===== net/core/neighbour.c 1.20 vs edited =====
--- 1.20/net/core/neighbour.c	Tue Oct 21 14:59:11 2003
+++ edited/net/core/neighbour.c	Tue Nov 11 01:12:34 2003
@@ -24,6 +24,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <linux/times.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/sock.h>
@@ -1510,7 +1511,7 @@
 			.procname	= "retrans_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= &proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_REACHABLE_TIME,
@@ -1552,21 +1553,21 @@
 			.procname	= "anycast_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= &proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_PROXY_DELAY,
 			.procname	= "proxy_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= &proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_LOCKTIME,
 			.procname	= "locktime",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= &proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_INTERVAL,

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
