From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 1/3] sysctl: refactor integer handling proc code
Date: Thu, 11 Feb 2010 04:09:18 +0200
Message-ID: <1265854160-11763-2-git-send-email-opurdila@ixiacom.com>
References: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vget.kernel.org,
	linux-kernel@vger.kernel.org, WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we are about to add another integer handling proc function a little
bit of cleanup is in order: add a few helper functions to improve code
readability and decrease code duplication.

In the process a bug is fixed as well: if the user specifies a number
with more then 20 digits it will be interpreted as two integers
(e.g. 10000...13 will be interpreted as 100.... and 13).

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Cc: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 kernel/sysctl.c |  298 +++++++++++++++++++++++++++----------------------------
 1 files changed, 144 insertions(+), 154 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8a68b24..b0f9618 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2039,8 +2039,98 @@ int proc_dostring(struct ctl_table *table, int write,
 			       buffer, lenp, ppos);
 }
 
+static int proc_skip_wspace(char __user **buf, size_t *size)
+{
+	char c;
+
+	while (*size) {
+		if (get_user(c, *buf))
+			return -EFAULT;
+		if (!isspace(c))
+			break;
+		(*size)--; (*buf)++;
+	}
+
+	return 0;
+}
+
+#define TMPBUFLEN 22
+static int proc_get_next_ulong(char __user **buf, size_t *size,
+			       unsigned long *val, bool *neg)
+{
+	int len;
+	char *p, tmp[TMPBUFLEN];
+	int err;
+
+	err = proc_skip_wspace(buf, size);
+	if (err)
+		return err;
+	if (!*size)
+		return -EINVAL;
+
+	len = *size;
+	if (len > TMPBUFLEN-1)
+		len = TMPBUFLEN-1;
+
+	if (copy_from_user(tmp, *buf, len))
+		return -EFAULT;
+
+	tmp[len] = 0;
+	p = tmp;
+	if (*p == '-' && *size > 1) {
+		*neg = 1;
+		p++;
+	} else
+		*neg = 0;
+	if (*p < '0' || *p > '9')
+		return -EINVAL;
+
+	*val = simple_strtoul(p, &p, 0);
+
+	len = p - tmp;
+	if (((len < *size) && *p && !isspace(*p)) ||
+	    /* We don't know if the next char is whitespace thus we may accept
+	     * invalid integers (e.g. 1234...a) or two integers instead of one
+	     * (e.g. 123...1). So lets not allow such large numbers. */
+	    len == TMPBUFLEN - 1)
+		return -EINVAL;
 
-static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
+	*buf += len; *size -= len;
+
+	return 0;
+}
+
+static int proc_put_ulong(char __user **buf, size_t *size, unsigned long val,
+			  bool neg, bool first)
+{
+	int len;
+	char tmp[TMPBUFLEN], *p = tmp;
+
+	if (!first)
+		*p++ = '\t';
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
+static int proc_put_newline(char __user **buf, size_t *size)
+{
+	if (*size) {
+		if (put_user('\n', *buf))
+			return -EFAULT;
+		(*size)--, (*buf)++;
+	}
+	return 0;
+}
+
+static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
 				 int *valp,
 				 int write, void *data)
 {
@@ -2049,7 +2139,7 @@ static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
 	} else {
 		int val = *valp;
 		if (val < 0) {
-			*negp = -1;
+			*negp = 1;
 			*lvalp = (unsigned long)-val;
 		} else {
 			*negp = 0;
@@ -2060,19 +2150,15 @@ static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
 }
 
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
-		  int write, void __user *buffer,
+		  int write, void __user *_buffer,
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
-	
-	char buf[TMPBUFLEN], *p;
-	char __user *s = buffer;
+	int *i, vleft, first = 1, err = 0;
+	size_t left;
+	char __user *buffer = (char __user *) _buffer;
 	
 	if (!tbl_data || !table->maxlen || !*lenp ||
 	    (*ppos && !write)) {
@@ -2088,88 +2174,39 @@ static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 		conv = do_proc_dointvec_conv;
 
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
-
-			lval = simple_strtoul(p, &p, 0);
+		unsigned long lval;
+		bool neg;
 
-			len = p-buf;
-			if ((len < left) && *p && !isspace(*p))
+		if (write) {
+			err = proc_get_next_ulong(&buffer, &left, &lval, &neg);
+			if (err)
 				break;
-			s += len;
-			left -= len;
-
 			if (conv(&neg, &lval, i, 1, data))
 				break;
 		} else {
-			p = buf;
-			if (!first)
-				*p++ = '\t';
-	
 			if (conv(&neg, &lval, i, 0, data))
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
-		}
-	}
-
-	if (!write && !first && left) {
-		if(put_user('\n', s))
-			return -EFAULT;
-		left--, s++;
-	}
-	if (write) {
-		while (left) {
-			char c;
-			if (get_user(c, s++))
-				return -EFAULT;
-			if (!isspace(c))
+			err = proc_put_ulong(&buffer, &left, lval, neg, first);
+			if (err)
 				break;
-			left--;
 		}
 	}
-	if (write && first)
-		return -EINVAL;
+
+	if (!write && !first && left && !err)
+		err = proc_put_newline(&buffer, &left);
+	if (write && !err)
+		err = proc_skip_wspace(&buffer, &left);
+	if (err == -EFAULT /* do we really need to check for -EFAULT? */ ||
+	    (write && first))
+		return err ? : -EINVAL;
 	*lenp -= left;
 	*ppos += *lenp;
 	return 0;
-#undef TMPBUFLEN
 }
 
 static int do_proc_dointvec(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos,
-		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
+		  int (*conv)(bool *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
 		  void *data)
 {
@@ -2237,8 +2274,8 @@ struct do_proc_dointvec_minmax_conv_param {
 	int *max;
 };
 
-static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp, 
-					int *valp, 
+static int do_proc_dointvec_minmax_conv(bool *negp, unsigned long *lvalp,
+					int *valp,
 					int write, void *data)
 {
 	struct do_proc_dointvec_minmax_conv_param *param = data;
@@ -2251,7 +2288,7 @@ static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp,
 	} else {
 		int val = *valp;
 		if (val < 0) {
-			*negp = -1;
+			*negp = 1;
 			*lvalp = (unsigned long)-val;
 		} else {
 			*negp = 0;
@@ -2289,17 +2326,15 @@ int proc_dointvec_minmax(struct ctl_table *table, int write,
 }
 
 static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int write,
-				     void __user *buffer,
+				     void __user *_buffer,
 				     size_t *lenp, loff_t *ppos,
 				     unsigned long convmul,
 				     unsigned long convdiv)
 {
-#define TMPBUFLEN 21
-	unsigned long *i, *min, *max, val;
-	int vleft, first=1, neg;
-	size_t len, left;
-	char buf[TMPBUFLEN], *p;
-	char __user *s = buffer;
+	unsigned long *i, *min, *max;
+	int vleft, first = 1, err = 0;
+	size_t left;
+	char __user *buffer = (char __user *) _buffer;
 	
 	if (!data || !table->maxlen || !*lenp ||
 	    (*ppos && !write)) {
@@ -2314,82 +2349,37 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
 	left = *lenp;
 	
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
+			err = proc_get_next_ulong(&buffer, &left, &val, &neg);
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
-			if (!first)
-				*p++ = '\t';
-			sprintf(p, "%lu", convdiv * (*i) / convmul);
-			len = strlen(buf);
-			if (len > left)
-				len = left;
-			if(copy_to_user(s, buf, len))
-				return -EFAULT;
-			left -= len;
-			s += len;
-		}
-	}
-
-	if (!write && !first && left) {
-		if(put_user('\n', s))
-			return -EFAULT;
-		left--, s++;
-	}
-	if (write) {
-		while (left) {
-			char c;
-			if (get_user(c, s++))
-				return -EFAULT;
-			if (!isspace(c))
+			val = convdiv * (*i) / convmul;
+			err = proc_put_ulong(&buffer, &left, val, 0, first);
+			if (err)
 				break;
-			left--;
 		}
 	}
-	if (write && first)
-		return -EINVAL;
+
+	if (!write && !first && left && !err)
+		err = proc_put_newline(&buffer, &left);
+	if (write && !err)
+		err = proc_skip_wspace(&buffer, &left);
+	if (err == -EFAULT /* do we really need to check for -EFAULT? */ ||
+	    (write && first))
+		return err ? : -EINVAL;
 	*lenp -= left;
 	*ppos += *lenp;
 	return 0;
-#undef TMPBUFLEN
 }
 
 static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
@@ -2450,7 +2440,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
 }
 
 
-static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_jiffies_conv(bool *negp, unsigned long *lvalp,
 					 int *valp,
 					 int write, void *data)
 {
@@ -2462,7 +2452,7 @@ static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = 1;
 			lval = (unsigned long)-val;
 		} else {
 			*negp = 0;
@@ -2473,7 +2463,7 @@ static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
 	return 0;
 }
 
-static int do_proc_dointvec_userhz_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_userhz_jiffies_conv(bool *negp, unsigned long *lvalp,
 						int *valp,
 						int write, void *data)
 {
@@ -2485,7 +2475,7 @@ static int do_proc_dointvec_userhz_jiffies_conv(int *negp, unsigned long *lvalp,
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = 1;
 			lval = (unsigned long)-val;
 		} else {
 			*negp = 0;
@@ -2496,7 +2486,7 @@ static int do_proc_dointvec_userhz_jiffies_conv(int *negp, unsigned long *lvalp,
 	return 0;
 }
 
-static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
+static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
 					    int *valp,
 					    int write, void *data)
 {
@@ -2506,7 +2496,7 @@ static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
 		int val = *valp;
 		unsigned long lval;
 		if (val < 0) {
-			*negp = -1;
+			*negp = 1;
 			lval = (unsigned long)-val;
 		} else {
 			*negp = 0;
-- 
1.5.6.5
