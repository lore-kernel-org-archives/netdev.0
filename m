From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NET: Normalize jiffies reported to userspace, in
 neighbor management code
Date: Thu, 18 Dec 2003 15:42:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218.154227.50757951.yoshfuji@linux-ipv6.org>
References: <20031110230233.254061da.davem@redhat.com>
	<20031111.163128.48152698.yoshfuji@linux-ipv6.org>
	<20031111160200.72cee93a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031111160200.72cee93a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20031111160200.72cee93a.davem@redhat.com> (at Tue, 11 Nov 2003 16:02:00 -0800), "David S. Miller" <davem@redhat.com> says:

> On Tue, 11 Nov 2003 16:31:28 -0600 (CST)
> YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:
> 
> > In article <20031110230233.254061da.davem@redhat.com> (at Mon, 10 Nov 2003 23:02:33 -0800), "David S. Miller" <davem@redhat.com> says:
> > 
> > > Another idea is to change do_proc_dointvec() to take a conversion function
> > > pointer instead of this "conv" thing.  Maybe even proc_dointvec_minmax()
> > > could be implemented in terms of do_proc_dointvec() with such a scheme.
> > 
> > This is essentially identical to what I thought.
> > Okay, how about this?
> 
> This looks very nice, thank you Yoshfuji.
> 
> I'm asking Linus what we should do here.  It's a big change to
> make to fix this bug, and if he thinks so too we'll just use
> your original patch which is a safer version of the fix for 2.6.0
> purposes.  If that happens, we'll integrate this nicer version
> for 2.6.1 or something like this.

2.6.0 is out finally; it would be the good time for resending the patch.
Thanks you in advance.

===== include/linux/sysctl.h 1.53 vs edited =====
--- 1.53/include/linux/sysctl.h	Thu Oct 30 05:19:30 2003
+++ edited/include/linux/sysctl.h	Thu Dec 18 15:34:54 2003
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
+++ edited/kernel/sysctl.c	Thu Dec 18 15:34:57 2003
@@ -37,6 +37,7 @@
 #include <linux/hugetlb.h>
 #include <linux/security.h>
 #include <linux/initrd.h>
+#include <linux/times.h>
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_ROOT_NFS
@@ -1050,8 +1051,8 @@
  * cover common cases -
  *
  * proc_dostring(), proc_dointvec(), proc_dointvec_jiffies(),
- * proc_dointvec_minmax(), proc_doulongvec_ms_jiffies_minmax(),
- * proc_doulongvec_minmax()
+ * proc_dointvec_userhz_jiffies(), proc_dointvec_minmax(), 
+ * proc_doulongvec_ms_jiffies_minmax(), proc_doulongvec_minmax()
  *
  * It is the handler's job to read the input buffer from user memory
  * and process it. The handler should return 0 on success.
@@ -1322,19 +1323,36 @@
 	return r;
 }
 
-#define OP_SET	0
-#define OP_AND	1
-#define OP_OR	2
-#define OP_MAX	3
-#define OP_MIN	4
+static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
+				 int *valp,
+				 int write, void *data)
+{
+	if (write) {
+		*valp = *negp ? -*lvalp : *lvalp;
+	} else {
+		int val = *valp;
+		if (val < 0) {
+			*negp = -1;
+			*lvalp = (unsigned long)-val;
+		} else {
+			*negp = 0;
+			*lvalp = (unsigned long)val;
+		}
+	}
+	return 0;
+}
 
 static int do_proc_dointvec(ctl_table *table, int write, struct file *filp,
-		  void __user *buffer, size_t *lenp, int conv, int op)
+		  void __user *buffer, size_t *lenp, 
+		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
+			      int write, void *data),
+		  void *data)
 {
+#define TMPBUFLEN 20
 	int *i, vleft, first=1, neg, val;
+	unsigned long lval;
 	size_t left, len;
 	
-	#define TMPBUFLEN 20
 	char buf[TMPBUFLEN], *p;
 	
 	if (!table->data || !table->maxlen || !*lenp ||
@@ -1344,9 +1362,12 @@
 	}
 	
 	i = (int *) table->data;
-	vleft = table->maxlen / sizeof(int);
+	vleft = table->maxlen / sizeof(*i);
 	left = *lenp;
-	
+
+	if (!conv)
+		conv = do_proc_dointvec_conv;
+
 	for (; left && vleft--; i++, first=0) {
 		if (write) {
 			while (left) {
@@ -1362,8 +1383,8 @@
 				break;
 			neg = 0;
 			len = left;
-			if (len > TMPBUFLEN-1)
-				len = TMPBUFLEN-1;
+			if (len > sizeof(buf) - 1)
+				len = sizeof(buf) - 1;
 			if(copy_from_user(buf, buffer, len))
 				return -EFAULT;
 			buf[len] = 0;
@@ -1374,7 +1395,9 @@
 			}
 			if (*p < '0' || *p > '9')
 				break;
-			val = simple_strtoul(p, &p, 0) * conv;
+
+			lval = simple_strtoul(p, &p, 0);
+
 			len = p-buf;
 			if ((len < left) && *p && !isspace(*p))
 				break;
@@ -1382,22 +1405,18 @@
 				val = -val;
 			buffer += len;
 			left -= len;
-			switch(op) {
-			case OP_SET:	*i = val; break;
-			case OP_AND:	*i &= val; break;
-			case OP_OR:	*i |= val; break;
-			case OP_MAX:	if(*i < val)
-						*i = val;
-					break;
-			case OP_MIN:	if(*i > val)
-						*i = val;
-					break;
-			}
+
+			if (conv(&neg, &lval, i, 1, data))
+				break;
 		} else {
 			p = buf;
 			if (!first)
 				*p++ = '\t';
-			sprintf(p, "%d", (*i) / conv);
+	
+			if (conv(&neg, &lval, i, 0, data))
+				break;
+
+			sprintf(p, "%s%lu", neg ? "-" : "", lval);
 			len = strlen(buf);
 			if (len > left)
 				len = left;
@@ -1429,6 +1448,7 @@
 	*lenp -= left;
 	filp->f_pos += *lenp;
 	return 0;
+#undef TMPBUFLEN
 }
 
 /**
@@ -1447,7 +1467,45 @@
 int proc_dointvec(ctl_table *table, int write, struct file *filp,
 		     void __user *buffer, size_t *lenp)
 {
-    return do_proc_dointvec(table,write,filp,buffer,lenp,1,OP_SET);
+    return do_proc_dointvec(table,write,filp,buffer,lenp,
+		    	    NULL,NULL);
+}
+
+#define OP_SET	0
+#define OP_AND	1
+#define OP_OR	2
+#define OP_MAX	3
+#define OP_MIN	4
+
+static int do_proc_dointvec_bset_conv(int *negp, unsigned long *lvalp,
+				      int *valp,
+				      int write, void *data)
+{
+	int op = *(int *)data;
+	if (write) {
+		int val = *negp ? -*lvalp : *lvalp;
+		switch(op) {
+		case OP_SET:	*valp = val; break;
+		case OP_AND:	*valp &= val; break;
+		case OP_OR:	*valp |= val; break;
+		case OP_MAX:	if(*valp < val)
+					*valp = val;
+				break;
+		case OP_MIN:	if(*valp > val)
+				*valp = val;
+				break;
+		}
+	} else {
+		int val = *valp;
+		if (val < 0) {
+			*negp = -1;
+			*lvalp = (unsigned long)-val;
+		} else {
+			*negp = 0;
+			*lvalp = (unsigned long)val;
+		}
+	}
+	return 0;
 }
 
 /*
@@ -1457,11 +1515,44 @@
 int proc_dointvec_bset(ctl_table *table, int write, struct file *filp,
 			void __user *buffer, size_t *lenp)
 {
+	int op;
+
 	if (!capable(CAP_SYS_MODULE)) {
 		return -EPERM;
 	}
-	return do_proc_dointvec(table,write,filp,buffer,lenp,1,
-				(current->pid == 1) ? OP_SET : OP_AND);
+
+	op = (current->pid == 1) ? OP_SET : OP_AND;
+	return do_proc_dointvec(table,write,filp,buffer,lenp,
+				do_proc_dointvec_bset_conv,&op);
+}
+
+struct do_proc_dointvec_minmax_conv_param {
+	int *min;
+	int *max;
+};
+
+static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp, 
+					int *valp, 
+					int write, void *data)
+{
+	struct do_proc_dointvec_minmax_conv_param *param = data;
+	if (write) {
+		int val = *negp ? -*lvalp : *lvalp;
+		if ((param->min && *param->min > val) ||
+		    (param->max && *param->max < val))
+			return -EINVAL;
+		*valp = val;
+	} else {
+		int val = *valp;
+		if (val < 0) {
+			*negp = -1;
+			*lvalp = (unsigned long)-val;
+		} else {
+			*negp = 0;
+			*lvalp = (unsigned long)val;
+		}
+	}
+	return 0;
 }
 
 /**
@@ -1483,98 +1574,12 @@
 int proc_dointvec_minmax(ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp)
 {
-	int *i, *min, *max, vleft, first=1, neg, val;
-	size_t len, left;
-	#define TMPBUFLEN 20
-	char buf[TMPBUFLEN], *p;
-	
-	if (!table->data || !table->maxlen || !*lenp ||
-	    (filp->f_pos && !write)) {
-		*lenp = 0;
-		return 0;
-	}
-	
-	i = (int *) table->data;
-	min = (int *) table->extra1;
-	max = (int *) table->extra2;
-	vleft = table->maxlen / sizeof(int);
-	left = *lenp;
-	
-	for (; left && vleft--; i++, min++, max++, first=0) {
-		if (write) {
-			while (left) {
-				char c;
-				if(get_user(c, (char *) buffer))
-					return -EFAULT;
-				if (!isspace(c))
-					break;
-				left--;
-				buffer++;
-			}
-			if (!left)
-				break;
-			neg = 0;
-			len = left;
-			if (len > TMPBUFLEN-1)
-				len = TMPBUFLEN-1;
-			if(copy_from_user(buf, buffer, len))
-				return -EFAULT;
-			buf[len] = 0;
-			p = buf;
-			if (*p == '-' && left > 1) {
-				neg = 1;
-				left--, p++;
-			}
-			if (*p < '0' || *p > '9')
-				break;
-			val = simple_strtoul(p, &p, 0);
-			len = p-buf;
-			if ((len < left) && *p && !isspace(*p))
-				break;
-			if (neg)
-				val = -val;
-			buffer += len;
-			left -= len;
-
-			if ((min && val < *min) || (max && val > *max))
-				continue;
-			*i = val;
-		} else {
-			p = buf;
-			if (!first)
-				*p++ = '\t';
-			sprintf(p, "%d", *i);
-			len = strlen(buf);
-			if (len > left)
-				len = left;
-			if(copy_to_user(buffer, buf, len))
-				return -EFAULT;
-			left -= len;
-			buffer += len;
-		}
-	}
-
-	if (!write && !first && left) {
-		if(put_user('\n', (char *) buffer))
-			return -EFAULT;
-		left--, buffer++;
-	}
-	if (write) {
-		p = (char *) buffer;
-		while (left) {
-			char c;
-			if(get_user(c, p++))
-				return -EFAULT;
-			if (!isspace(c))
-				break;
-			left--;
-		}
-	}
-	if (write && first)
-		return -EINVAL;
-	*lenp -= left;
-	filp->f_pos += *lenp;
-	return 0;
+	struct do_proc_dointvec_minmax_conv_param param = {
+		.min = (int *) table->extra1,
+		.max = (int *) table->extra2,
+	};
+	return do_proc_dointvec(table, write, filp, buffer, lenp,
+				do_proc_dointvec_minmax_conv, &param);
 }
 
 static int do_proc_doulongvec_minmax(ctl_table *table, int write,
@@ -1729,6 +1734,48 @@
 }
 
 
+static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
+					 int *valp,
+					 int write, void *data)
+{
+	if (write) {
+		*valp = *negp ? -(*lvalp*HZ) : (*lvalp*HZ);
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
+		*lvalp = lval / HZ;
+	}
+	return 0;
+}
+
+static int do_proc_dointvec_userhz_jiffies_conv(int *negp, unsigned long *lvalp,
+						int *valp,
+						int write, void *data)
+{
+	if (write) {
+		*valp = clock_t_to_jiffies(*negp ? -*lvalp : *lvalp);
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
+		*lvalp = jiffies_to_clock_t(lval);
+	}
+	return 0;
+}
+
 /**
  * proc_dointvec_jiffies - read a vector of integers as seconds
  * @table: the sysctl table
@@ -1747,7 +1794,30 @@
 int proc_dointvec_jiffies(ctl_table *table, int write, struct file *filp,
 			  void __user *buffer, size_t *lenp)
 {
-    return do_proc_dointvec(table,write,filp,buffer,lenp,HZ,OP_SET);
+    return do_proc_dointvec(table,write,filp,buffer,lenp,
+		    	    do_proc_dointvec_jiffies_conv,NULL);
+}
+
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
+    return do_proc_dointvec(table,write,filp,buffer,lenp,
+		    	    do_proc_dointvec_userhz_jiffies_conv,NULL);
 }
 
 #else /* CONFIG_PROC_FS */
@@ -1788,6 +1858,12 @@
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
@@ -1975,6 +2051,12 @@
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
@@ -2007,6 +2089,7 @@
 EXPORT_SYMBOL(proc_dointvec);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
+EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
 EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
===== net/core/neighbour.c 1.20 vs edited =====
--- 1.20/net/core/neighbour.c	Tue Oct 21 14:59:11 2003
+++ edited/net/core/neighbour.c	Thu Dec 18 15:34:54 2003
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
