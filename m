From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFT] covert br2684 to seq_file
Date: Thu, 04 Sep 2003 12:36:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309041636.h84GaoSa017129@ginger.cmf.nrl.navy.mil>
References: <shemminger@osdl.org>
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: Message from Stephen Hemminger <shemminger@osdl.org>
   of "Tue, 02 Sep 2003 10:43:08 PDT." <20030902104308.08ce3fa4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave, please apply to 2.6 -- thanks

[i made a few minor changes, like alignment and missing #ifdef
for remove_proc_entry during __exit]

In message <20030902104308.08ce3fa4.shemminger@osdl.org>,Stephen Hemminger writ
es:
>Convert the /proc/net/atm/br2684 to seq_file interface.
>It builds and runs, but without any real atm hardware the table
>is empty...


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1418  -> 1.1419 
#	    net/atm/br2684.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1419
# convert the /proc/net/atm/br2684 to seq_file interface (from shemminger@osdl.org)
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Thu Sep  4 12:32:14 2003
+++ b/net/atm/br2684.c	Thu Sep  4 12:32:14 2003
@@ -18,6 +18,7 @@
 #include <net/arp.h>
 #include <linux/atm.h>
 #include <linux/atmdev.h>
+#include <linux/seq_file.h>
 
 #include <linux/atmbr2684.h>
 
@@ -666,31 +667,57 @@
 	return -ENOIOCTLCMD;
 }
 
-/* Never put more than 256 bytes in at once */
-static int br2684_proc_engine(loff_t pos, char *buf)
+#ifdef CONFIG_PROC_FS
+static void *br2684_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct list_head *lhd, *lhc;
-	struct net_device *net_dev;
-	struct br2684_dev *brdev;
-	struct br2684_vcc *brvcc;
-	list_for_each(lhd, &br2684_devs) {
-		net_dev = list_entry_brdev(lhd);
-		brdev = BRPRIV(net_dev);
-		if (pos-- == 0)
-			return sprintf(buf, "dev %.16s: num=%d, mac=%02X:%02X:"
-			    "%02X:%02X:%02X:%02X (%s)\n", net_dev->name,
-			    brdev->number,
-			    net_dev->dev_addr[0],
-			    net_dev->dev_addr[1],
-			    net_dev->dev_addr[2],
-			    net_dev->dev_addr[3],
-			    net_dev->dev_addr[4],
-			    net_dev->dev_addr[5],
-			    brdev->mac_was_set ? "set" : "auto");
-		list_for_each(lhc, &brdev->brvccs) {
-			brvcc = list_entry_brvcc(lhc);
-			if (pos-- == 0)
-				return sprintf(buf, "  vcc %d.%d.%d: encaps=%s"
+	loff_t offs = 0;
+	struct br2684_dev *brd;
+
+	read_lock(&devs_lock);
+
+	list_for_each_entry(brd, &br2684_devs, br2684_devs) {
+		if (offs == *pos)
+			return brd;
+		++offs;
+	}
+	return NULL;
+}
+
+static void *br2684_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct br2684_dev *brd = v;
+
+	++*pos;
+
+	brd = list_entry(brd->br2684_devs.next, 
+			 struct br2684_dev, br2684_devs);
+	return (&brd->br2684_devs != &br2684_devs) ? brd : NULL;
+}
+
+static void br2684_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&devs_lock);
+}
+
+static int br2684_seq_show(struct seq_file *seq, void *v)
+{
+	const struct br2684_dev *brdev = v;
+	const struct net_device *net_dev = brdev->net_dev;
+	const struct br2684_vcc *brvcc;
+
+	seq_printf(seq, "dev %.16s: num=%d, mac=%02X:%02X:"
+		       "%02X:%02X:%02X:%02X (%s)\n", net_dev->name,
+		       brdev->number,
+		       net_dev->dev_addr[0],
+		       net_dev->dev_addr[1],
+		       net_dev->dev_addr[2],
+		       net_dev->dev_addr[3],
+		       net_dev->dev_addr[4],
+		       net_dev->dev_addr[5],
+		       brdev->mac_was_set ? "set" : "auto");
+
+	list_for_each_entry(brvcc, &brdev->brvccs, brvccs) {
+		seq_printf(seq, "  vcc %d.%d.%d: encaps=%s"
 #ifndef FASTER_VERSION
 				    ", failed copies %u/%u"
 #endif /* FASTER_VERSION */
@@ -711,63 +738,41 @@
 #undef bs
 #undef b1
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
-		}
 	}
 	return 0;
 }
 
-static ssize_t br2684_proc_read(struct file *file, char *buf, size_t count,
-	loff_t *pos)
+static struct seq_operations br2684_seq_ops = {
+	.start = br2684_seq_start,
+	.next  = br2684_seq_next,
+	.stop  = br2684_seq_stop,
+	.show  = br2684_seq_show,
+};
+
+static int br2684_proc_open(struct inode *inode, struct file *file)
 {
-	unsigned long page;
-	int len = 0, x, left;
-	page = get_zeroed_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-	left = PAGE_SIZE - 256;
-	if (count < left)
-		left = count;
-	read_lock(&devs_lock);
-	for (;;) {
-		x = br2684_proc_engine(*pos, &((char *) page)[len]);
-		if (x == 0)
-			break;
-		if (x > left)
-			/*
-			 * This should only happen if the user passed in
-			 * a "count" too small for even one line
-			 */
-			x = -EINVAL;
-		if (x < 0) {
-			len = x;
-			break;
-		}
-		len += x;
-		left -= x;
-		(*pos)++;
-		if (left < 256)
-			break;
-	}
-	read_unlock(&devs_lock);
-	if (len > 0 && copy_to_user(buf, (char *) page, len))
-		len = -EFAULT;
-	free_page(page);
-	return len;
+	return seq_open(file, &br2684_seq_ops);
 }
 
-static struct file_operations br2684_proc_operations = {
-	.owner = THIS_MODULE,
-	.read =  br2684_proc_read,
+static struct file_operations br2684_proc_ops = {
+	.owner   = THIS_MODULE,
+	.open    = br2684_proc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
 };
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
+#endif
 
 static int __init br2684_init(void)
 {
+#ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
 	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
 		return -ENOMEM;
-	p->proc_fops = &br2684_proc_operations;
+	p->proc_fops = &br2684_proc_ops;
+#endif
 	br2684_ioctl_set(br2684_ioctl);
 	return 0;
 }
@@ -779,7 +784,9 @@
 	struct br2684_vcc *brvcc;
 	br2684_ioctl_set(NULL);
 
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("br2684", atm_proc_root);
+#endif
 
 	while (!list_empty(&br2684_devs)) {
 		net_dev = list_entry_brdev(br2684_devs.next);
