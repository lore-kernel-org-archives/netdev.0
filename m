From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 1/3] sysctl: refactor integer handling proc code
Date: Wed, 5 May 2010 06:26:45 -0400
Message-ID: <20100505103044.5600.14955.sendpatchset@localhost.localdomain>
References: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, ebiederm@xmission.com,
	xiaosuo@gmail.com, David Miller <davem@davemloft.net>,
	adobriyan@gmail.com, Amerigo Wang <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Based on Octavian's work, and I modified a lot.)

As we are about to add another integer handling proc function a little
bit of cleanup is in order: add a few helper functions to improve code
readability and decrease code duplication.

In the process a bug is also fixed: if the user specifies a number
with more then 20 digits it will be interpreted as two integers
(e.g. 10000...13 will be interpreted as 100.... and 13).

Behavior for EFAULT handling was changed as well. Previous to this
patch, when an EFAULT error occurred in the middle of a write
operation, although some of the elements were set, that was not
acknowledged to the user (by shorting the write and returning the
number of bytes accepted). EFAULT is now treated just like any other
errors by acknowledging the amount of bytes accepted.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---

Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -2040,8 +2040,122 @@ int proc_dostring(struct ctl_table *tabl
 			       buffer, lenp, ppos);
 }
 
+static size_t proc_skip_spaces(char **buf)
+{
+	size_t ret;
+	char *tmp = skip_spaces(*buf);
+	ret = tmp - *buf;
+	*buf = tmp;
+	return ret;
+}
+
+#define TMPBUFLEN 22
+/**
+ * proc_get_long - reads an ASCII formated integer from a user buffer
+ *
+ * @buf - a kernel buffer
+ * @size - size of the kernel buffer
+ * @val - this is where the number will be stored
+ * @neg - set to %TRUE if number is negative
+ * @perm_tr - a vector which contains the allowed trailers
+ * @perm_tr_len - size of the perm_tr vector
+ * @tr - pointer to store the trailer character
+ *
+ * In case of success 0 is returned and buf and size are updated with
+ * the amount of bytes read. If tr is non NULL and a trailing
+ * character exist (size is non zero after returning from this
+ * function) tr is updated with the trailing character.
+ */
+static int proc_get_long(char **buf, size_t *size,
+			  unsigned long *val, bool *neg,
+			  const char *perm_tr, unsigned perm_tr_len, char *tr)
+{
+	int len;
+	char *p, tmp[TMPBUFLEN];
+
+	if (!*size)
+		return -EINVAL;
+
+	len = *size;
+	if (len > TMPBUFLEN - 1)
+		len = TMPBUFLEN - 1;
+
+	memcpy(tmp, *buf, len);
+
+	tmp[len] = 0;
+	p = tmp;
+	if (*p == '-' && *size > 1) {
+		*neg = true;
+		p++;
+	} else
+		*neg = false;
+	if (!isdigit(*p))
+		return -EINVAL;
+
+	*val = simple_strtoul(p, &p, 0);
 
-static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
+	len = p - tmp;
+
+	/* We don't know if the next char is whitespace thus we may accept
+	 * invalid integers (e.g. 1234...a) or two integers instead of one
+	 * (e.g. 123...1). So lets not allow such large numbers. */
+	if (len == TMPBUFLEN - 1)
+		return -EINVAL;
+
+	if (len < *size && perm_tr_len && !memchr(perm_tr, *p, perm_tr_len))
+		return -EINVAL;
+
+	if (tr && (len < *size))
+		*tr = *p;
+
+	*buf += len;
+	*size -= len;
+
+	return 0;
+}
+
+/**
+ * proc_put_long - coverts an integer to a decimal ASCII formated string
+ *
+ * @buf - the user buffer
+ * @size - the size of the user buffer
+ * @val - the integer to be converted
+ * @neg - sign of the number, %TRUE for negative
+ *
+ * In case of success 0 is returned and buf and size are updated with
+ * the amount of bytes read.
+ */
+static int proc_put_long(void __user **buf, size_t *size, unsigned long val,
+			  bool neg)
+{
+	int len;
+	char tmp[TMPBUFLEN], *p = tmp;
+
+	sprintf(p, "%s%lu", neg ? "-" : "", val);
+	len = strlen(tmp);
+	if (len > *size)
+		len = *size;
+	if (copy_to_user(*buf, tmp, len))
+		return -EFAULT;
+	*size -= len;
+	*buf += len;
+	return 0;
+}
+#undef TMPBUFLEN
+
+static int proc_put_char(void __user **buf, size_t *size, char c)
+{
+	if (*size) {
+		char __user **buffer = (char __user **)buf;
+		if (put_user(c, *buffer))
+			return -EFAULT;
+		(*size)--, (*buffer)++;
+		*buf = *buffer;
+	}
+	return 0;
+}
+
+static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
 				 int *valp,
 				 int write, void *data)
 {
@@ -2050,33 +2164,31 @@ static int do_proc_dointvec_conv(int *ne
 	} else {
 		int val = *valp;
 		if (val < 0) {
-			*negp = -1;
+			*negp = true;
 			*lvalp = (unsigned long)-val;
 		} else {
-			*negp = 0;
+			*negp = false;
 			*lvalp = (unsigned long)val;
 		}
 	}
 	return 0;
 }
 
+static const char proc_wspace_sep[] = { ' ', '\t', '\n' };
+
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 		  int write, void __user *buffer,
 		  size_t *lenp, loff_t *ppos,
-		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
+		  int (*conv)(bool *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
 		  void *data)
 {
-#define TMPBUFLEN 21
-	int *i, vleft, first = 1, neg;
-	unsigned long lval;
-	size_t left, len;
+	int *i, vleft, first = 1, err = 0;
+	unsigned long page = 0;
+	size_t left;
+	char *kbuf;
 	
-	char buf[TMPBUFLEN], *p;
-	char __user *s = buffer;
-	
-	if (!tbl_data || !table->maxlen || !*lenp ||
-	    (*ppos && !write)) {
+	if (!tbl_data || !table->maxlen || !*lenp || (*ppos && !write)) {
 		*lenp = 0;
 		return 0;
 	}
@@ -2088,89 +2200,69 @@ static int __do_proc_dointvec(void *tbl_
 	if (!conv)
 		conv = do_proc_dointvec_conv;
 
+	if (write) {
+		if (left > PAGE_SIZE - 1)
+			left = PAGE_SIZE - 1;
+		page = __get_free_page(GFP_TEMPORARY);
+		kbuf = (char *) page;
+		if (!kbuf)
+			return -ENOMEM;
+		if (copy_from_user(kbuf, buffer, left)) {
+			err = -EFAULT;
+			goto free;
+		}
+		kbuf[left] = 0;
+	}
+
 	for (; left && vleft--; i++, first=0) {
-		if (write) {
-			while (left) {
-				char c;
-				if (get_user(c, s))
-					return -EFAULT;
-				if (!isspace(c))
-					break;
-				left--;
-				s++;
-			}
-			if (!left)
-				break;
-			neg = 0;
-			len = left;
-			if (len > sizeof(buf) - 1)
-				len = sizeof(buf) - 1;
-			if (copy_from_user(buf, s, len))
-				return -EFAULT;
-			buf[len] = 0;
-			p = buf;
-			if (*p == '-' && left > 1) {
-				neg = 1;
-				p++;
-			}
-			if (*p < '0' || *p > '9')
-				break;
+		unsigned long lval;
+		bool neg;
 
-			lval = simple_strtoul(p, &p, 0);
+		if (write) {
+			left -= proc_skip_spaces(&kbuf);
 
-			len = p-buf;
-			if ((len < left) && *p && !isspace(*p))
+			err = proc_get_long(&kbuf, &left, &lval, &neg,
+					     proc_wspace_sep,
+					     sizeof(proc_wspace_sep), NULL);
+			if (err)
 				break;
-			s += len;
-			left -= len;
-
-			if (conv(&neg, &lval, i, 1, data))
+			if (conv(&neg, &lval, i, 1, data)) {
+				err = -EINVAL;
 				break;
+			}
 		} else {
-			p = buf;
+			if (conv(&neg, &lval, i, 0, data)) {
+				err = -EINVAL;
+				break;
+			}
 			if (!first)
-				*p++ = '\t';
-	
-			if (conv(&neg, &lval, i, 0, data))
+				err = proc_put_char(&buffer, &left, '\t');
+			if (err)
+				break;
+			err = proc_put_long(&buffer, &left, lval, neg);
+			if (err)
 				break;
-
-			sprintf(p, "%s%lu", neg ? "-" : "", lval);
-			len = strlen(buf);
-			if (len > left)
-				len = left;
-			if(copy_to_user(s, buf, len))
-				return -EFAULT;
-			left -= len;
-			s += len;
 		}
 	}
 
-	if (!write && !first && left) {
-		if(put_user('\n', s))
-			return -EFAULT;
-		left--, s++;
-	}
+	if (!write && !first && left && !err)
+		err = proc_put_char(&buffer, &left, '\n');
+	if (write && !err)
+		left -= proc_skip_spaces(&kbuf);
+free:
 	if (write) {
-		while (left) {
-			char c;
-			if (get_user(c, s++))
-				return -EFAULT;
-			if (!isspace(c))
-				break;
-			left--;
-		}
+		free_page(page);
+		if (first)
+			return err ? : -EINVAL;
 	}
-	if (write && first)
-		return -EINVAL;
 	*lenp -= left;
 	*ppos += *lenp;
-	return 0;
-#undef TMPBUFLEN
+	return err;
 }
 
 static int do_proc_dointvec(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos,
-		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
+		  int (*conv)(bool *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
 		  void *data)
 {
@@ -2238,8 +2330,8 @@ struct do_proc_dointvec_minmax_conv_para
 	int *max;
 };
 
-static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp, 
-					int *valp, 
+static int do_proc_dointvec_minmax_conv(bool *negp, unsigned long *lvalp,
+					int *valp,
 					int write, void *data)
 {
 	struct do_proc_dointvec_minmax_conv_param *param = data;
@@ -2252,10 +2344,10 @@ static int do_proc_dointvec_minmax_conv(
 	} else {
 		int val = *valp;
 		if (val < 0) {
-			*negp = -1;
+			*negp = true;
 			*lvalp = (unsigned long)-val;
 		} else {
-			*negp = 0;
+			*negp = false;
 			*lvalp = (unsigned long)val;
 		}
 	}
@@ -2295,102 +2387,78 @@ static int __do_proc_doulongvec_minmax(v
 				     unsigned long convmul,
 				     unsigned long convdiv)
 {
-#define TMPBUFLEN 21
-	unsigned long *i, *min, *max, val;
-	int vleft, first=1, neg;
-	size_t len, left;
-	char buf[TMPBUFLEN], *p;
-	char __user *s = buffer;
-	
-	if (!data || !table->maxlen || !*lenp ||
-	    (*ppos && !write)) {
+	unsigned long *i, *min, *max;
+	int vleft, first = 1, err = 0;
+	unsigned long page = 0;
+	size_t left;
+	char *kbuf;
+
+	if (!data || !table->maxlen || !*lenp || (*ppos && !write)) {
 		*lenp = 0;
 		return 0;
 	}
-	
+
 	i = (unsigned long *) data;
 	min = (unsigned long *) table->extra1;
 	max = (unsigned long *) table->extra2;
 	vleft = table->maxlen / sizeof(unsigned long);
 	left = *lenp;
-	
+
+	if (write) {
+		if (left > PAGE_SIZE - 1)
+			left = PAGE_SIZE - 1;
+		page = __get_free_page(GFP_TEMPORARY);
+		kbuf = (char *) page;
+		if (!kbuf)
+			return -ENOMEM;
+		if (copy_from_user(kbuf, buffer, left)) {
+			err = -EFAULT;
+			goto free;
+		}
+		kbuf[left] = 0;
+	}
+
 	for (; left && vleft--; i++, min++, max++, first=0) {
+		unsigned long val;
+
 		if (write) {
-			while (left) {
-				char c;
-				if (get_user(c, s))
-					return -EFAULT;
-				if (!isspace(c))
-					break;
-				left--;
-				s++;
-			}
-			if (!left)
-				break;
-			neg = 0;
-			len = left;
-			if (len > TMPBUFLEN-1)
-				len = TMPBUFLEN-1;
-			if (copy_from_user(buf, s, len))
-				return -EFAULT;
-			buf[len] = 0;
-			p = buf;
-			if (*p == '-' && left > 1) {
-				neg = 1;
-				p++;
-			}
-			if (*p < '0' || *p > '9')
-				break;
-			val = simple_strtoul(p, &p, 0) * convmul / convdiv ;
-			len = p-buf;
-			if ((len < left) && *p && !isspace(*p))
+			bool neg;
+
+			left -= proc_skip_spaces(&kbuf);
+
+			err = proc_get_long(&kbuf, &left, &val, &neg,
+					     proc_wspace_sep,
+					     sizeof(proc_wspace_sep), NULL);
+			if (err)
 				break;
 			if (neg)
-				val = -val;
-			s += len;
-			left -= len;
-
-			if(neg)
 				continue;
 			if ((min && val < *min) || (max && val > *max))
 				continue;
 			*i = val;
 		} else {
-			p = buf;
+			val = convdiv * (*i) / convmul;
 			if (!first)
-				*p++ = '\t';
-			sprintf(p, "%lu", convdiv * (*i) / convmul);
-			len = strlen(buf);
-			if (len > left)
-				len = left;
-			if(copy_to_user(s, buf, len))
-				return -EFAULT;
-			left -= len;
-			s += len;
+				err = proc_put_char(&buffer, &left, '\t');
+			err = proc_put_long(&buffer, &left, val, false);
+			if (err)
+				break;
 		}
 	}
 
-	if (!write && !first && left) {
-		if(put_user('\n', s))
-			return -EFAULT;
-		left--, s++;
-	}
+	if (!write && !first && left && !err)
+		err = proc_put_char(&buffer, &left, '\n');
+	if (write && !err)
+		left -= proc_skip_spaces(&kbuf);
+free:
 	if (write) {
-		while (left) {
-			char c;
-			if (get_user(c, s++))
-				return -EFAULT;
-			if (!isspace(c))
-				break;
-			left--;
-		}
+		free_page(page);
+		if (first)
+			return err ? : -EINVAL;
 	}
-	if (write && first)
-		return -EINVAL;
 	*lenp -= left;
 	*ppos += *lenp;
-	return 0;
-#undef TMPBUFLEN
+	return err;
 }
 
 static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
@@ -2451,7 +2519,7 @@ int proc_doulongvec_ms_jiffies_minmax(st
 }
 
 
-static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_jiffies_conv(bool *negp, unsigned long *lvalp,
 					 int *valp,
 					 int write, void *data)
 {
@@ -2463,10 +2531,10 @@ static int do_proc_dointvec_jiffies_conv
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = true;
 			lval = (unsigned long)-val;
 		} else {
-			*negp = 0;
+			*negp = false;
 			lval = (unsigned long)val;
 		}
 		*lvalp = lval / HZ;
@@ -2474,7 +2542,7 @@ static int do_proc_dointvec_jiffies_conv
 	return 0;
 }
 
-static int do_proc_dointvec_userhz_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_userhz_jiffies_conv(bool *negp, unsigned long *lvalp,
 						int *valp,
 						int write, void *data)
 {
@@ -2486,10 +2554,10 @@ static int do_proc_dointvec_userhz_jiffi
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = true;
 			lval = (unsigned long)-val;
 		} else {
-			*negp = 0;
+			*negp = false;
 			lval = (unsigned long)val;
 		}
 		*lvalp = jiffies_to_clock_t(lval);
@@ -2497,7 +2565,7 @@ static int do_proc_dointvec_userhz_jiffi
 	return 0;
 }
 
-static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
 					    int *valp,
 					    int write, void *data)
 {
@@ -2507,10 +2575,10 @@ static int do_proc_dointvec_ms_jiffies_c
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = true;
 			lval = (unsigned long)-val;
 		} else {
-			*negp = 0;
+			*negp = false;
 			lval = (unsigned long)val;
 		}
 		*lvalp = jiffies_to_msecs(lval);
