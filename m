From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [IPV4] Fix ip_rt_gc_min_interval_ms procfs/sysctl
Date: Fri, 18 Feb 2005 19:24:30 +0900 (JST)
Message-ID: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: torvalds@osdl.org, akpm@osdl.org, davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, Linus, Andrew and David;

Recently, we added gc_min_interval_ms procfs/sysctl.

Because type of ip_rt_gc_min_interval is int, 
use of ulong helpers is inappropriate and unsafe.
I believe it breaks some archs that the size of unsigned long
is not equal to one of int.

So, let's add new sysctl helpers and use them instead.
This also fixes inconsistency between procfs and sysctl.

Please pull following changesets available at
        <bk://bk.skbuff.net:20611/linux-2.6-sysctl/>
into 2.6.11 tree.

Thanks.

P.S. I will send several changesets to add other users 
(neighbour and ipv6 routing) after 2.6.12 opens.

HEADLINES
---------
ChangeSet@1.2063, 2005-02-18 18:23:43+09:00, yoshfuji@linux-ipv6.org
 add sysctl helper functions to provide milliseconds-based interfaces.
ChangeSet@1.2064, 2005-02-18 18:54:30+09:00, yoshfuji@linux-ipv6.org
 [IPV4] Use appropriate sysctl helpers for gc_min_interval_ms.


DIFFSTATS
---------
 include/linux/sysctl.h |    3 +
 kernel/sysctl.c        |   91 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/route.c       |    6 +--
 3 files changed, 97 insertions(+), 3 deletions(-)


CHANGESETS
----------
ChangeSet@1.2063, 2005-02-18 18:23:43+09:00, yoshfuji@linux-ipv6.org
 add sysctl helper functions to provide milliseconds-based interfaces.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-02-18 18:55:25 +09:00
+++ b/include/linux/sysctl.h	2005-02-18 18:55:25 +09:00
@@ -796,6 +796,8 @@
 				 void __user *, size_t *, loff_t *);
 extern int proc_dointvec_userhz_jiffies(ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
+extern int proc_dointvec_ms_jiffies(ctl_table *, int, struct file *,
+				    void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_minmax(ctl_table *, int, struct file *,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(ctl_table *table, int,
@@ -813,6 +815,7 @@
 extern ctl_handler sysctl_string;
 extern ctl_handler sysctl_intvec;
 extern ctl_handler sysctl_jiffies;
+extern ctl_handler sysctl_ms_jiffies;
 
 
 /*
diff -Nru a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c	2005-02-18 18:55:25 +09:00
+++ b/kernel/sysctl.c	2005-02-18 18:55:25 +09:00
@@ -1902,6 +1902,27 @@
 	return 0;
 }
 
+static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
+					    int *valp,
+					    int write, void *data)
+{
+	if (write) {
+		*valp = msecs_to_jiffies(*negp ? -*lvalp : *lvalp);
+	} else {
+		int val = *valp;
+		unsigned long lval;
+		if (val < 0) {
+			*negp = -1;
+			lval = (unsigned long)-val;
+		} else {
+			*negp = 0;
+			lval = (unsigned long)val;
+		}
+		*lvalp = jiffies_to_msecs(lval);
+	}
+	return 0;
+}
+
 /**
  * proc_dointvec_jiffies - read a vector of integers as seconds
  * @table: the sysctl table
@@ -1946,6 +1967,28 @@
 		    	    do_proc_dointvec_userhz_jiffies_conv,NULL);
 }
 
+/**
+ * proc_dointvec_ms_jiffies - read a vector of integers as 1 milliseconds
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @filp: the file structure
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ *
+ * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
+ * values from/to the user buffer, treated as an ASCII string. 
+ * The values read are assumed to be in 1/1000 seconds, and 
+ * are converted into jiffies.
+ *
+ * Returns 0 on success.
+ */
+int proc_dointvec_ms_jiffies(ctl_table *table, int write, struct file *filp,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+				do_proc_dointvec_ms_jiffies_conv, NULL);
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(ctl_table *table, int write, struct file *filp,
@@ -1990,6 +2033,12 @@
 	return -ENOSYS;
 }
 
+int proc_dointvec_ms_jiffies(ctl_table *table, int write, struct file *filp,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
 int proc_doulongvec_minmax(ctl_table *table, int write, struct file *filp,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2119,6 +2168,33 @@
 	return 1;
 }
 
+/* Strategy function to convert jiffies to seconds */ 
+int sysctl_ms_jiffies(ctl_table *table, int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen, void **context)
+{
+	if (oldval) {
+		size_t olen;
+		if (oldlenp) { 
+			if (get_user(olen, oldlenp))
+				return -EFAULT;
+			if (olen!=sizeof(int))
+				return -EINVAL; 
+		}
+		if (put_user(jiffies_to_msecs(*(int *)(table->data)), (int __user *)oldval) ||
+		    (oldlenp && put_user(sizeof(int),oldlenp)))
+			return -EFAULT;
+	}
+	if (newval && newlen) { 
+		int new;
+		if (newlen != sizeof(int))
+			return -EINVAL; 
+		if (get_user(new, (int __user *)newval))
+			return -EFAULT;
+		*(int *)(table->data) = msecs_to_jiffies(new);
+	}
+	return 1;
+}
 
 #else /* CONFIG_SYSCTL */
 
@@ -2149,6 +2225,13 @@
 	return -ENOSYS;
 }
 
+int sysctl_ms_jiffies(ctl_table *table, int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen, void **context)
+{
+	return -ENOSYS;
+}
+
 int proc_dostring(ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2185,6 +2268,12 @@
 	return -ENOSYS;
 }
 
+int proc_dointvec_ms_jiffies(ctl_table *table, int write, struct file *filp,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
 int proc_doulongvec_minmax(ctl_table *table, int write, struct file *filp,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2219,11 +2308,13 @@
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
 EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
+EXPORT_SYMBOL(proc_dointvec_ms_jiffies);
 EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
 EXPORT_SYMBOL(register_sysctl_table);
 EXPORT_SYMBOL(sysctl_intvec);
 EXPORT_SYMBOL(sysctl_jiffies);
+EXPORT_SYMBOL(sysctl_ms_jiffies);
 EXPORT_SYMBOL(sysctl_string);
 EXPORT_SYMBOL(unregister_sysctl_table);

ChangeSet@1.2064, 2005-02-18 18:54:30+09:00, yoshfuji@linux-ipv6.org
 [IPV4] Use appropriate sysctl helpers for gc_min_interval_ms.
 
 Because its type is int, inappropriate to use ulong helpers.
 This also fixes inconsistency between sysctl and procfs.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2005-02-18 18:55:29 +09:00
+++ b/net/ipv4/route.c	2005-02-18 18:55:29 +09:00
@@ -2545,10 +2545,10 @@
 		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS,
 		.procname	= "gc_min_interval_ms",
 		.data		= &ip_rt_gc_min_interval,
-		.maxlen		= sizeof(unsigned long),
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= &proc_dointvec_ms_jiffies,
+		.strategy	= &sysctl_ms_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_TIMEOUT,

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
