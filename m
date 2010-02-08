From: Octavian Purdila <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Mon, 8 Feb 2010 18:51:19 +0200
Message-ID: <201002081851.19999.opurdila@ixiacom.com>
References: <201002031312.48531.opurdila@ixiacom.com> <201002051405.54029.opurdila@ixiacom.com> <4B6F834E.4010801@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B6F834E.4010801-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 08 February 2010 05:21:50 you wrote:
> Octavian Purdila wrote:
> > On Friday 05 February 2010 06:45:38 you wrote:
> >> Again, using bitmap algorithm is not a problem and it's better, the
> >> problem is sysctl interface, how would you plan to interact with users
> >> via sysctl/proc if you use bitmap to handle this? I would like to hear
> >> more details about this.
> >
> > We could use something like positive values for setting and negative for
> > reset (e.g. 3 would set the port in the bitmap and -3 would reset it).
> 
> Hmm, then how do you output the info of those ports? Arrays of bitmaps?
> 

See the patch bellow (work in progress).

BTW, while working on it I added some helpers, which we can use to rewrite the proc_doint/long stuff. I think it will help with readability and eliminates some code duplication as well. What do you guys think about that?

--- linux_2.6.32/main/src/kernel/sysctl.c
+++ linux_2.6.32/main/src/kernel/sysctl.c
@@ -250,6 +250,11 @@
 static int max_wakeup_granularity_ns = NSEC_PER_SEC;	/* 1 second */
 #endif
 
+static unsigned long test_bitmap[65535/sizeof(long)];
+static int proc_dobitmap(struct ctl_table *table, int write,
+			 void __user *buf, size_t *lenp, loff_t *ppos);
+
+
 static struct ctl_table kern_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -1032,6 +1037,15 @@
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "bitmap_test",
+		.data		= &test_bitmap,
+		.maxlen		= 65535,
+		.mode		= 0644,
+		.proc_handler	= &proc_dobitmap,
+	},
+	
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
@@ -2902,6 +2916,194 @@
 	return 0;
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
+		*size--; *buf++;
+	}
+
+	return 0;
+}
+
+static inline int _proc_get_ulong(char __user **buf, size_t *size, 
+				  unsigned long *val, bool *neg)
+{
+#define TMPBUFLEN 21
+	int len = *size;
+	char *p, tmp[TMPBUFLEN];
+
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
+	}
+	if (*p < '0' || *p > '9')
+		return -EINVAL;
+
+	*val = simple_strtoul(p, &p, 0);
+
+	len = p - tmp;
+	if ((len < *size) && *p && !isspace(*p))
+		return -EINVAL;
+
+	*buf += len; *size -= len;
+
+	return 0;
+#undef TMPBUFLEN
+}
+
+static int proc_get_long(char __user **buf, size_t *size, long *val)
+{
+	int err;
+	bool neg;
+	unsigned long uval;
+
+	err = _proc_get_ulong(buf, size, &uval, &neg);
+	if (err)
+		return err;
+
+	if (neg)
+		*val = -uval;
+	else
+		*val = uval;
+
+	return 0;
+}
+
+static int proc_get_ulong(char __user **buf, size_t *size, unsigned long *val)
+{
+	int err;
+	bool neg;
+
+	err = _proc_get_ulong(buf, size, val, &neg);
+	if (err)
+		return err;
+	if (neg)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int proc_put_ulong(char __user **buf, size_t *size, unsigned long val,
+			  bool first)
+{
+#define TMPBUFLEN 21
+	int len;
+	char tmp[TMPBUFLEN], *p = tmp;
+
+	if (!first)
+		*p++ = '\t';
+	sprintf(p, "%lu", val);
+	len = strlen(tmp);
+	if (len > *size)
+		len = *size;
+	if (copy_to_user(*buf, tmp, len))
+		return -EFAULT;
+	*size -= len;
+	*buf += len;
+	return 0;
+#undef TMPBUFLEN
+}
+
+static int proc_put_newline(char __user **buf, size_t *size)
+{
+	if (*size) {
+		if (put_user('\n', *buf))
+			return -EFAULT;
+		*size--, *buf++;
+	}
+	return 0;
+}
+
+static int proc_dobitmap(struct ctl_table *table, int write,
+			 void __user *buf, size_t *lenp, loff_t *ppos)
+{
+	bool first = 1;
+	unsigned long *bitmap = (unsigned long *) table->data;
+	unsigned long bitmap_len = table->maxlen;
+	int left = *lenp, err = 0;
+	char __user *buffer = (char __user *) buf;
+
+	if (!bitmap_len || !left || (*ppos && !write)) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		while (left) {
+			long val;
+			
+			err = proc_skip_wspace(&buffer, &left);
+			if (err)
+				break;
+			if (!left) {
+				err = -EINVAL;
+				break;
+			}
+			err = proc_get_long(&buffer, &left, &val);
+			if (err)
+				break;
+			if (abs(val) > bitmap_len) {
+				err = -EINVAL;
+				break;
+			}
+
+			if (val < 0)
+				clear_bit(-val, bitmap);
+			else
+				set_bit(val, bitmap);
+
+			first = 0;
+		}
+		if (!err)
+			err = proc_skip_wspace(&buffer, &left);
+	} else {
+		unsigned long bit = 0;
+
+		while (left) {
+			bit = find_next_bit(bitmap, bitmap_len, bit);
+			printk("%s:%d %lu\n", __func__, __LINE__, bit);
+			if (bit >= bitmap_len)
+				break;
+			err = proc_put_ulong(&buffer, &left, bit, first);
+			printk("%s:%d %d\n", __func__, __LINE__, err);
+			if (err)
+				break;
+			first = 0; bit++;
+		}
+		if (!err)
+			err = proc_put_newline(&buffer, &left);
+	}
+
+	if (first) {
+		if (write && !err)
+			err = -EINVAL;
+		if (err)
+			return err;
+	}
+
+	if (err == -EFAULT)
+		return err;
+
+	printk("%s:%d %d %d\n", __func__, __LINE__, *lenp, left);
+	*lenp -= left;
+	*ppos += *lenp;
+	return 0;
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(struct ctl_table *table, int write,
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
