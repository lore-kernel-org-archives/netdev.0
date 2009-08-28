From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] can: switch to seq_file
Date: Fri, 28 Aug 2009 23:57:21 +0400
Message-ID: <20090828195721.GD15123@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:43094 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbZH1T5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:57:22 -0400
Received: by ewy2 with SMTP id 2so2437040ewy.17
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 12:57:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

create_proc_read_entry() is going to be removed soon.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/can/bcm.c  |   85 +++++++----------
 net/can/proc.c |  281 ++++++++++++++++++++++++++-------------------------------
 2 files changed, 167 insertions(+), 199 deletions(-)

--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -46,6 +46,7 @@
 #include <linux/hrtimer.h>
 #include <linux/list.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/uio.h>
 #include <linux/net.h>
 #include <linux/netdevice.h>
@@ -146,23 +147,18 @@ static char *bcm_proc_getifname(int ifindex)
 	return "???";
 }
 
-static int bcm_read_proc(char *page, char **start, off_t off,
-			 int count, int *eof, void *data)
+static int bcm_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
-	struct sock *sk = (struct sock *)data;
+	struct sock *sk = (struct sock *)m->private;
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
 
-	len += snprintf(page + len, PAGE_SIZE - len, ">>> socket %p",
-			sk->sk_socket);
-	len += snprintf(page + len, PAGE_SIZE - len, " / sk %p", sk);
-	len += snprintf(page + len, PAGE_SIZE - len, " / bo %p", bo);
-	len += snprintf(page + len, PAGE_SIZE - len, " / dropped %lu",
-			bo->dropped_usr_msgs);
-	len += snprintf(page + len, PAGE_SIZE - len, " / bound %s",
-			bcm_proc_getifname(bo->ifindex));
-	len += snprintf(page + len, PAGE_SIZE - len, " <<<\n");
+	seq_printf(m, ">>> socket %p", sk->sk_socket);
+	seq_printf(m, " / sk %p", sk);
+	seq_printf(m, " / bo %p", bo);
+	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
+	seq_printf(m, " / bound %s", bcm_proc_getifname(bo->ifindex));
+	seq_printf(m, " <<<\n");
 
 	list_for_each_entry(op, &bo->rx_ops, list) {
 
@@ -172,71 +168,62 @@ static int bcm_read_proc(char *page, char **start, off_t off,
 		if (!op->frames_abs)
 			continue;
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"rx_op: %03X %-5s ",
+		seq_printf(m, "rx_op: %03X %-5s ",
 				op->can_id, bcm_proc_getifname(op->ifindex));
-		len += snprintf(page + len, PAGE_SIZE - len, "[%d]%c ",
-				op->nframes,
+		seq_printf(m, "[%d]%c ", op->nframes,
 				(op->flags & RX_CHECK_DLC)?'d':' ');
 		if (op->kt_ival1.tv64)
-			len += snprintf(page + len, PAGE_SIZE - len,
-					"timeo=%lld ",
+			seq_printf(m, "timeo=%lld ",
 					(long long)
 					ktime_to_us(op->kt_ival1));
 
 		if (op->kt_ival2.tv64)
-			len += snprintf(page + len, PAGE_SIZE - len,
-					"thr=%lld ",
+			seq_printf(m, "thr=%lld ",
 					(long long)
 					ktime_to_us(op->kt_ival2));
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"# recv %ld (%ld) => reduction: ",
+		seq_printf(m, "# recv %ld (%ld) => reduction: ",
 				op->frames_filtered, op->frames_abs);
 
 		reduction = 100 - (op->frames_filtered * 100) / op->frames_abs;
 
-		len += snprintf(page + len, PAGE_SIZE - len, "%s%ld%%\n",
+		seq_printf(m, "%s%ld%%\n",
 				(reduction == 100)?"near ":"", reduction);
-
-		if (len > PAGE_SIZE - 200) {
-			/* mark output cut off */
-			len += snprintf(page + len, PAGE_SIZE - len, "(..)\n");
-			break;
-		}
 	}
 
 	list_for_each_entry(op, &bo->tx_ops, list) {
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"tx_op: %03X %s [%d] ",
+		seq_printf(m, "tx_op: %03X %s [%d] ",
 				op->can_id, bcm_proc_getifname(op->ifindex),
 				op->nframes);
 
 		if (op->kt_ival1.tv64)
-			len += snprintf(page + len, PAGE_SIZE - len, "t1=%lld ",
+			seq_printf(m, "t1=%lld ",
 					(long long) ktime_to_us(op->kt_ival1));
 
 		if (op->kt_ival2.tv64)
-			len += snprintf(page + len, PAGE_SIZE - len, "t2=%lld ",
+			seq_printf(m, "t2=%lld ",
 					(long long) ktime_to_us(op->kt_ival2));
 
-		len += snprintf(page + len, PAGE_SIZE - len, "# sent %ld\n",
-				op->frames_abs);
-
-		if (len > PAGE_SIZE - 100) {
-			/* mark output cut off */
-			len += snprintf(page + len, PAGE_SIZE - len, "(..)\n");
-			break;
-		}
+		seq_printf(m, "# sent %ld\n", op->frames_abs);
 	}
+	seq_putc(m, '\n');
+	return 0;
+}
 
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
-
-	*eof = 1;
-	return len;
+static int bcm_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bcm_proc_show, PDE(inode)->data);
 }
 
+static const struct file_operations bcm_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= bcm_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /*
  * bcm_can_tx - send the (next) CAN frame to the appropriate CAN interface
  *              of the given bcm tx op
@@ -1515,9 +1502,9 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	if (proc_dir) {
 		/* unique socket address as filename */
 		sprintf(bo->procname, "%p", sock);
-		bo->bcm_proc_read = create_proc_read_entry(bo->procname, 0644,
-							   proc_dir,
-							   bcm_read_proc, sk);
+		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
+						     proc_dir,
+						     &bcm_proc_fops, sk);
 	}
 
 	return 0;
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -196,8 +196,8 @@ void can_stat_update(unsigned long data)
  *
  */
 
-static int can_print_rcvlist(char *page, int len, struct hlist_head *rx_list,
-			     struct net_device *dev)
+static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
+			      struct net_device *dev)
 {
 	struct receiver *r;
 	struct hlist_node *n;
@@ -208,199 +208,188 @@ static int can_print_rcvlist(char *page, int len, struct hlist_head *rx_list,
 			"   %-5s  %08X  %08x  %08x  %08x  %8ld  %s\n" :
 			"   %-5s     %03X    %08x  %08lx  %08lx  %8ld  %s\n";
 
-		len += snprintf(page + len, PAGE_SIZE - len, fmt,
-				DNAME(dev), r->can_id, r->mask,
+		seq_printf(m, fmt, DNAME(dev), r->can_id, r->mask,
 				(unsigned long)r->func, (unsigned long)r->data,
 				r->matches, r->ident);
-
-		/* does a typical line fit into the current buffer? */
-
-		/* 100 Bytes before end of buffer */
-		if (len > PAGE_SIZE - 100) {
-			/* mark output cut off */
-			len += snprintf(page + len, PAGE_SIZE - len,
-					"   (..)\n");
-			break;
-		}
 	}
 	rcu_read_unlock();
-
-	return len;
 }
 
-static int can_print_recv_banner(char *page, int len)
+static void can_print_recv_banner(struct seq_file *m)
 {
 	/*
 	 *                  can1.  00000000  00000000  00000000
 	 *                 .......          0  tp20
 	 */
-	len += snprintf(page + len, PAGE_SIZE - len,
-			"  device   can_id   can_mask  function"
+	seq_puts(m, "  device   can_id   can_mask  function"
 			"  userdata   matches  ident\n");
-
-	return len;
 }
 
-static int can_proc_read_stats(char *page, char **start, off_t off,
-			       int count, int *eof, void *data)
+static int can_stats_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
+	seq_putc(m, '\n');
+	seq_printf(m, " %8ld transmitted frames (TXF)\n", can_stats.tx_frames);
+	seq_printf(m, " %8ld received frames (RXF)\n", can_stats.rx_frames);
+	seq_printf(m, " %8ld matched frames (RXMF)\n", can_stats.matches);
 
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
-	len += snprintf(page + len, PAGE_SIZE - len,
-			" %8ld transmitted frames (TXF)\n",
-			can_stats.tx_frames);
-	len += snprintf(page + len, PAGE_SIZE - len,
-			" %8ld received frames (RXF)\n", can_stats.rx_frames);
-	len += snprintf(page + len, PAGE_SIZE - len,
-			" %8ld matched frames (RXMF)\n", can_stats.matches);
-
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
+	seq_putc(m, '\n');
 
 	if (can_stattimer.function == can_stat_update) {
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld %% total match ratio (RXMR)\n",
+		seq_printf(m, " %8ld %% total match ratio (RXMR)\n",
 				can_stats.total_rx_match_ratio);
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s total tx rate (TXR)\n",
+		seq_printf(m, " %8ld frames/s total tx rate (TXR)\n",
 				can_stats.total_tx_rate);
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s total rx rate (RXR)\n",
+		seq_printf(m, " %8ld frames/s total rx rate (RXR)\n",
 				can_stats.total_rx_rate);
 
-		len += snprintf(page + len, PAGE_SIZE - len, "\n");
+		seq_putc(m, '\n');
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld %% current match ratio (CRXMR)\n",
+		seq_printf(m, " %8ld %% current match ratio (CRXMR)\n",
 				can_stats.current_rx_match_ratio);
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s current tx rate (CTXR)\n",
+		seq_printf(m, " %8ld frames/s current tx rate (CTXR)\n",
 				can_stats.current_tx_rate);
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s current rx rate (CRXR)\n",
+		seq_printf(m, " %8ld frames/s current rx rate (CRXR)\n",
 				can_stats.current_rx_rate);
 
-		len += snprintf(page + len, PAGE_SIZE - len, "\n");
+		seq_putc(m, '\n');
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld %% max match ratio (MRXMR)\n",
+		seq_printf(m, " %8ld %% max match ratio (MRXMR)\n",
 				can_stats.max_rx_match_ratio);
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s max tx rate (MTXR)\n",
+		seq_printf(m, " %8ld frames/s max tx rate (MTXR)\n",
 				can_stats.max_tx_rate);
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld frames/s max rx rate (MRXR)\n",
+		seq_printf(m, " %8ld frames/s max rx rate (MRXR)\n",
 				can_stats.max_rx_rate);
 
-		len += snprintf(page + len, PAGE_SIZE - len, "\n");
+		seq_putc(m, '\n');
 	}
 
-	len += snprintf(page + len, PAGE_SIZE - len,
-			" %8ld current receive list entries (CRCV)\n",
+	seq_printf(m, " %8ld current receive list entries (CRCV)\n",
 			can_pstats.rcv_entries);
-	len += snprintf(page + len, PAGE_SIZE - len,
-			" %8ld maximum receive list entries (MRCV)\n",
+	seq_printf(m, " %8ld maximum receive list entries (MRCV)\n",
 			can_pstats.rcv_entries_max);
 
 	if (can_pstats.stats_reset)
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"\n %8ld statistic resets (STR)\n",
+		seq_printf(m, "\n %8ld statistic resets (STR)\n",
 				can_pstats.stats_reset);
 
 	if (can_pstats.user_reset)
-		len += snprintf(page + len, PAGE_SIZE - len,
-				" %8ld user statistic resets (USTR)\n",
+		seq_printf(m, " %8ld user statistic resets (USTR)\n",
 				can_pstats.user_reset);
 
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
-
-	*eof = 1;
-	return len;
+	seq_putc(m, '\n');
+	return 0;
 }
 
-static int can_proc_read_reset_stats(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
+static int can_stats_proc_open(struct inode *inode, struct file *file)
 {
-	int len = 0;
+	return single_open(file, can_stats_proc_show, NULL);
+}
+
+static const struct file_operations can_stats_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= can_stats_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 
+static int can_reset_stats_proc_show(struct seq_file *m, void *v)
+{
 	user_reset = 1;
 
 	if (can_stattimer.function == can_stat_update) {
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"Scheduled statistic reset #%ld.\n",
+		seq_printf(m, "Scheduled statistic reset #%ld.\n",
 				can_pstats.stats_reset + 1);
 
 	} else {
 		if (can_stats.jiffies_init != jiffies)
 			can_init_stats();
 
-		len += snprintf(page + len, PAGE_SIZE - len,
-				"Performed statistic reset #%ld.\n",
+		seq_printf(m, "Performed statistic reset #%ld.\n",
 				can_pstats.stats_reset);
 	}
+	return 0;
+}
 
-	*eof = 1;
-	return len;
+static int can_reset_stats_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, can_reset_stats_proc_show, NULL);
 }
 
-static int can_proc_read_version(char *page, char **start, off_t off,
-				 int count, int *eof, void *data)
+static const struct file_operations can_reset_stats_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= can_reset_stats_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int can_version_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
+	seq_printf(m, "%s\n", CAN_VERSION_STRING);
+	return 0;
+}
 
-	len += snprintf(page + len, PAGE_SIZE - len, "%s\n",
-			CAN_VERSION_STRING);
-	*eof = 1;
-	return len;
+static int can_version_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, can_version_proc_show, NULL);
 }
 
-static int can_proc_read_rcvlist(char *page, char **start, off_t off,
-				 int count, int *eof, void *data)
+static const struct file_operations can_version_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= can_version_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int can_rcvlist_proc_show(struct seq_file *m, void *v)
 {
 	/* double cast to prevent GCC warning */
-	int idx = (int)(long)data;
-	int len = 0;
+	int idx = (int)(long)m->private;
 	struct dev_rcv_lists *d;
 	struct hlist_node *n;
 
-	len += snprintf(page + len, PAGE_SIZE - len,
-			"\nreceive list '%s':\n", rx_list_name[idx]);
+	seq_printf(m, "\nreceive list '%s':\n", rx_list_name[idx]);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(d, n, &can_rx_dev_list, list) {
 
 		if (!hlist_empty(&d->rx[idx])) {
-			len = can_print_recv_banner(page, len);
-			len = can_print_rcvlist(page, len, &d->rx[idx], d->dev);
+			can_print_recv_banner(m);
+			can_print_rcvlist(m, &d->rx[idx], d->dev);
 		} else
-			len += snprintf(page + len, PAGE_SIZE - len,
-					"  (%s: no entry)\n", DNAME(d->dev));
-
-		/* exit on end of buffer? */
-		if (len > PAGE_SIZE - 100)
-			break;
+			seq_printf(m, "  (%s: no entry)\n", DNAME(d->dev));
 	}
 	rcu_read_unlock();
 
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
+	seq_putc(m, '\n');
+	return 0;
+}
 
-	*eof = 1;
-	return len;
+static int can_rcvlist_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, can_rcvlist_proc_show, PDE(inode)->data);
 }
 
-static int can_proc_read_rcvlist_sff(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
+static const struct file_operations can_rcvlist_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= can_rcvlist_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int can_rcvlist_sff_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
 	struct dev_rcv_lists *d;
 	struct hlist_node *n;
 
 	/* RX_SFF */
-	len += snprintf(page + len, PAGE_SIZE - len,
-			"\nreceive list 'rx_sff':\n");
+	seq_puts(m, "\nreceive list 'rx_sff':\n");
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(d, n, &can_rx_dev_list, list) {
@@ -413,46 +402,38 @@ static int can_proc_read_rcvlist_sff(char *page, char **start, off_t off,
 			}
 
 		if (!all_empty) {
-			len = can_print_recv_banner(page, len);
+			can_print_recv_banner(m);
 			for (i = 0; i < 0x800; i++) {
-				if (!hlist_empty(&d->rx_sff[i]) &&
-				    len < PAGE_SIZE - 100)
-					len = can_print_rcvlist(page, len,
-								&d->rx_sff[i],
-								d->dev);
+				if (!hlist_empty(&d->rx_sff[i]))
+					can_print_rcvlist(m, &d->rx_sff[i],
+							  d->dev);
 			}
 		} else
-			len += snprintf(page + len, PAGE_SIZE - len,
-					"  (%s: no entry)\n", DNAME(d->dev));
-
-		/* exit on end of buffer? */
-		if (len > PAGE_SIZE - 100)
-			break;
+			seq_printf(m, "  (%s: no entry)\n", DNAME(d->dev));
 	}
 	rcu_read_unlock();
 
-	len += snprintf(page + len, PAGE_SIZE - len, "\n");
+	seq_putc(m, '\n');
+	return 0;
+}
 
-	*eof = 1;
-	return len;
+static int can_rcvlist_sff_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, can_rcvlist_sff_proc_show, NULL);
 }
 
+static const struct file_operations can_rcvlist_sff_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= can_rcvlist_sff_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /*
  * proc utility functions
  */
 
-static struct proc_dir_entry *can_create_proc_readentry(const char *name,
-							mode_t mode,
-							read_proc_t *read_proc,
-							void *data)
-{
-	if (can_dir)
-		return create_proc_read_entry(name, mode, can_dir, read_proc,
-					      data);
-	else
-		return NULL;
-}
-
 static void can_remove_proc_readentry(const char *name)
 {
 	if (can_dir)
@@ -474,24 +455,24 @@ void can_init_proc(void)
 	}
 
 	/* own procfs entries from the AF_CAN core */
-	pde_version     = can_create_proc_readentry(CAN_PROC_VERSION, 0644,
-					can_proc_read_version, NULL);
-	pde_stats       = can_create_proc_readentry(CAN_PROC_STATS, 0644,
-					can_proc_read_stats, NULL);
-	pde_reset_stats = can_create_proc_readentry(CAN_PROC_RESET_STATS, 0644,
-					can_proc_read_reset_stats, NULL);
-	pde_rcvlist_err = can_create_proc_readentry(CAN_PROC_RCVLIST_ERR, 0644,
-					can_proc_read_rcvlist, (void *)RX_ERR);
-	pde_rcvlist_all = can_create_proc_readentry(CAN_PROC_RCVLIST_ALL, 0644,
-					can_proc_read_rcvlist, (void *)RX_ALL);
-	pde_rcvlist_fil = can_create_proc_readentry(CAN_PROC_RCVLIST_FIL, 0644,
-					can_proc_read_rcvlist, (void *)RX_FIL);
-	pde_rcvlist_inv = can_create_proc_readentry(CAN_PROC_RCVLIST_INV, 0644,
-					can_proc_read_rcvlist, (void *)RX_INV);
-	pde_rcvlist_eff = can_create_proc_readentry(CAN_PROC_RCVLIST_EFF, 0644,
-					can_proc_read_rcvlist, (void *)RX_EFF);
-	pde_rcvlist_sff = can_create_proc_readentry(CAN_PROC_RCVLIST_SFF, 0644,
-					can_proc_read_rcvlist_sff, NULL);
+	pde_version     = proc_create(CAN_PROC_VERSION, 0644, can_dir,
+				      &can_version_proc_fops);
+	pde_stats       = proc_create(CAN_PROC_STATS, 0644, can_dir,
+				      &can_stats_proc_fops);
+	pde_reset_stats = proc_create(CAN_PROC_RESET_STATS, 0644, can_dir,
+				      &can_reset_stats_proc_fops);
+	pde_rcvlist_err = proc_create_data(CAN_PROC_RCVLIST_ERR, 0644, can_dir,
+					   &can_rcvlist_proc_fops, (void *)RX_ERR);
+	pde_rcvlist_all = proc_create_data(CAN_PROC_RCVLIST_ALL, 0644, can_dir,
+					   &can_rcvlist_proc_fops, (void *)RX_ALL);
+	pde_rcvlist_fil = proc_create_data(CAN_PROC_RCVLIST_FIL, 0644, can_dir,
+					   &can_rcvlist_proc_fops, (void *)RX_FIL);
+	pde_rcvlist_inv = proc_create_data(CAN_PROC_RCVLIST_INV, 0644, can_dir,
+					   &can_rcvlist_proc_fops, (void *)RX_INV);
+	pde_rcvlist_eff = proc_create_data(CAN_PROC_RCVLIST_EFF, 0644, can_dir,
+					   &can_rcvlist_proc_fops, (void *)RX_EFF);
+	pde_rcvlist_sff = proc_create(CAN_PROC_RCVLIST_SFF, 0644, can_dir,
+				      &can_rcvlist_sff_proc_fops);
 }
 
 /*
