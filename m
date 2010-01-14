From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH] proc_fops: convert drivers/isdn/ to seq_file
Date: Thu, 14 Jan 2010 11:27:45 +0100
Message-ID: <1263467281.28429@pingi>
Cc: tilman@imap.cc, adobriyan@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112.x-mailer.de ([212.162.56.210]:46376 "EHLO d112.x-mailer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755467Ab0ANLIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 06:08:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Alexey Dobriyan <adobriyan@gmail.com>

Convert code away from ->read_proc/->write_proc interfaces.  Switch to
proc_create()/proc_create_data() which make addition of proc entries
reliable wrt NULL ->proc_fops, NULL ->data and so on.

Problem with ->read_proc et al is described here commit
786d7e1612f0b0adb6046f19b906609e4fe8b1ba "Fix rmmod/read/write races in
/proc entries"

[akpm@linux-foundation.org: CONFIG_PROC_FS=n build fix]
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 Documentation/isdn/INTERFACE.CAPI       |    9 +-
 drivers/isdn/capi/capi.c                |   99 ++++++----------
 drivers/isdn/capi/capidrv.c             |   55 +++------
 drivers/isdn/capi/kcapi.c               |    8 +-
 drivers/isdn/gigaset/capi.c             |   75 ++++++------
 drivers/isdn/hardware/avm/avmcard.h     |    6 +-
 drivers/isdn/hardware/avm/b1.c          |   54 +++++----
 drivers/isdn/hardware/avm/b1dma.c       |   71 ++++++------
 drivers/isdn/hardware/avm/b1isa.c       |    2 +-
 drivers/isdn/hardware/avm/b1pci.c       |    4 +-
 drivers/isdn/hardware/avm/b1pcmcia.c    |    2 +-
 drivers/isdn/hardware/avm/c4.c          |   53 +++++----
 drivers/isdn/hardware/avm/t1isa.c       |    2 +-
 drivers/isdn/hardware/avm/t1pci.c       |    2 +-
 drivers/isdn/hardware/eicon/capimain.c  |   40 ++++---
 drivers/isdn/hardware/eicon/diva_didd.c |   45 ++++----
 drivers/isdn/hardware/eicon/divasi.c    |   48 ++++----
 drivers/isdn/hardware/eicon/divasproc.c |  198 ++++++++++++++-----------------
 drivers/isdn/hysdn/hycapi.c             |   56 +++++-----
 include/linux/isdn/capilli.h            |    3 +-
 net/bluetooth/cmtp/capi.c               |   37 ++++---
 21 files changed, 411 insertions(+), 458 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index 5fe8de5..f172091 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -149,10 +149,11 @@ char *(*procinfo)(struct capi_ctr *ctrlr)
 	pointer to a callback function returning the entry for the device in
 	the CAPI controller info table, /proc/capi/controller
 
-read_proc_t *ctr_read_proc
-	pointer to the read_proc callback function for the device's proc file
-	system entry, /proc/capi/controllers/<n>; will be called with a
-	pointer to the device's capi_ctr structure as the last (data) argument
+const struct file_operations *proc_fops
+	pointers to callback functions for the device's proc file
+	system entry, /proc/capi/controllers/<n>; pointer to the device's
+	capi_ctr structure is available from struct proc_dir_entry::data
+	which is available from struct inode.
 
 Note: Callback functions except send_message() are never called in interrupt
 context.
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 65bf91e..79f9364 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -33,6 +33,7 @@
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/poll.h>
 #include <linux/capi.h>
 #include <linux/kernelcapi.h>
@@ -1407,114 +1408,84 @@ static void capinc_tty_exit(void)
  * /proc/capi/capi20:
  *  minor applid nrecvctlpkt nrecvdatapkt nsendctlpkt nsenddatapkt
  */
-static int proc_capidev_read_proc(char *page, char **start, off_t off,
-                                       int count, int *eof, void *data)
+static int capi20_proc_show(struct seq_file *m, void *v)
 {
         struct capidev *cdev;
 	struct list_head *l;
-	int len = 0;
 
 	read_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
-		len += sprintf(page+len, "0 %d %lu %lu %lu %lu\n",
+		seq_printf(m, "0 %d %lu %lu %lu %lu\n",
 			cdev->ap.applid,
 			cdev->ap.nrecvctlpkt,
 			cdev->ap.nrecvdatapkt,
 			cdev->ap.nsentctlpkt,
 			cdev->ap.nsentdatapkt);
-		if (len <= off) {
-			off -= len;
-			len = 0;
-		} else {
-			if (len-off > count)
-				goto endloop;
-		}
 	}
-
-endloop:
 	read_unlock(&capidev_list_lock);
-	if (len < count)
-		*eof = 1;
-	if (len > count) len = count;
-	if (len < 0) len = 0;
-	return len;
+	return 0;
 }
 
+static int capi20_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, capi20_proc_show, NULL);
+}
+
+static const struct file_operations capi20_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= capi20_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /*
  * /proc/capi/capi20ncci:
  *  applid ncci
  */
-static int proc_capincci_read_proc(char *page, char **start, off_t off,
-                                       int count, int *eof, void *data)
+static int capi20ncci_proc_show(struct seq_file *m, void *v)
 {
         struct capidev *cdev;
         struct capincci *np;
 	struct list_head *l;
-	int len = 0;
 
 	read_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
 		for (np=cdev->nccis; np; np = np->next) {
-			len += sprintf(page+len, "%d 0x%x\n",
+			seq_printf(m, "%d 0x%x\n",
 				       cdev->ap.applid,
 				       np->ncci);
-			if (len <= off) {
-				off -= len;
-				len = 0;
-			} else {
-				if (len-off > count)
-					goto endloop;
-			}
 		}
 	}
-endloop:
 	read_unlock(&capidev_list_lock);
-	*start = page+off;
-	if (len < count)
-		*eof = 1;
-	if (len>count) len = count;
-	if (len<0) len = 0;
-	return len;
+	return 0;
 }
 
-static struct procfsentries {
-  char *name;
-  mode_t mode;
-  int (*read_proc)(char *page, char **start, off_t off,
-                                       int count, int *eof, void *data);
-  struct proc_dir_entry *procent;
-} procfsentries[] = {
-   /* { "capi",		  S_IFDIR, 0 }, */
-   { "capi/capi20", 	  0	 , proc_capidev_read_proc },
-   { "capi/capi20ncci",   0	 , proc_capincci_read_proc },
+static int capi20ncci_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, capi20ncci_proc_show, NULL);
+}
+
+static const struct file_operations capi20ncci_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= capi20ncci_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
 };
 
 static void __init proc_init(void)
 {
-    int nelem = ARRAY_SIZE(procfsentries);
-    int i;
-
-    for (i=0; i < nelem; i++) {
-        struct procfsentries *p = procfsentries + i;
-	p->procent = create_proc_entry(p->name, p->mode, NULL);
-	if (p->procent) p->procent->read_proc = p->read_proc;
-    }
+	proc_create("capi/capi20", 0, NULL, &capi20_proc_fops);
+	proc_create("capi/capi20ncci", 0, NULL, &capi20ncci_proc_fops);
 }
 
 static void __exit proc_exit(void)
 {
-    int nelem = ARRAY_SIZE(procfsentries);
-    int i;
-
-    for (i=nelem-1; i >= 0; i--) {
-        struct procfsentries *p = procfsentries + i;
-	if (p->procent) {
-	   remove_proc_entry(p->name, NULL);
-	   p->procent = NULL;
-	}
-    }
+	remove_proc_entry("capi/capi20", NULL);
+	remove_proc_entry("capi/capi20ncci", NULL);
 }
 
 /* -------- init function and module interface ---------------------- */
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 66b7d7a..bb45015 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -24,6 +24,7 @@
 #include <linux/isdn.h>
 #include <linux/isdnif.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/capi.h>
 #include <linux/kernelcapi.h>
 #include <linux/ctype.h>
@@ -2229,59 +2230,37 @@ static void lower_callback(unsigned int cmd, u32 contr, void *data)
  * /proc/capi/capidrv:
  * nrecvctlpkt nrecvdatapkt nsendctlpkt nsenddatapkt
  */
-static int proc_capidrv_read_proc(char *page, char **start, off_t off,
-                                       int count, int *eof, void *data)
+static int capidrv_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
-
-	len += sprintf(page+len, "%lu %lu %lu %lu\n",
+	seq_printf(m, "%lu %lu %lu %lu\n",
 			global.ap.nrecvctlpkt,
 			global.ap.nrecvdatapkt,
 			global.ap.nsentctlpkt,
 			global.ap.nsentdatapkt);
-	if (off+count >= len)
-	   *eof = 1;
-	if (len < off)
-           return 0;
-	*start = page + off;
-	return ((count < len-off) ? count : len-off);
+	return 0;
+}
+
+static int capidrv_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, capidrv_proc_show, NULL);
 }
 
-static struct procfsentries {
-  char *name;
-  mode_t mode;
-  int (*read_proc)(char *page, char **start, off_t off,
-                                       int count, int *eof, void *data);
-  struct proc_dir_entry *procent;
-} procfsentries[] = {
-   /* { "capi",		  S_IFDIR, 0 }, */
-   { "capi/capidrv", 	  0	 , proc_capidrv_read_proc },
+static const struct file_operations capidrv_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= capidrv_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
 };
 
 static void __init proc_init(void)
 {
-    int nelem = ARRAY_SIZE(procfsentries);
-    int i;
-
-    for (i=0; i < nelem; i++) {
-        struct procfsentries *p = procfsentries + i;
-	p->procent = create_proc_entry(p->name, p->mode, NULL);
-	if (p->procent) p->procent->read_proc = p->read_proc;
-    }
+	proc_create("capi/capidrv", 0, NULL, &capidrv_proc_fops);
 }
 
 static void __exit proc_exit(void)
 {
-    int nelem = ARRAY_SIZE(procfsentries);
-    int i;
-
-    for (i=nelem-1; i >= 0; i--) {
-        struct procfsentries *p = procfsentries + i;
-	if (p->procent) {
-	   remove_proc_entry(p->name, NULL);
-	   p->procent = NULL;
-	}
-    }
+	remove_proc_entry("capi/capidrv", NULL);
 }
 
 static int __init capidrv_init(void)
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index dc506ab..b0bacf3 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -490,13 +490,7 @@ attach_capi_ctr(struct capi_ctr *card)
 	card->traceflag = showcapimsgs;
 
 	sprintf(card->procfn, "capi/controllers/%d", card->cnr);
-	card->procent = create_proc_entry(card->procfn, 0, NULL);
-	if (card->procent) {
-	   card->procent->read_proc = 
-		(int (*)(char *,char **,off_t,int,int *,void *))
-			card->ctr_read_proc;
-	   card->procent->data = card;
-	}
+	card->procent = proc_create_data(card->procfn, 0, NULL, card->proc_fops, card);
 
 	ncards++;
 	printk(KERN_NOTICE "kcapi: Controller [%03d]: %s attached\n",
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 3f5cd06..6f0ae32 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -13,6 +13,8 @@
 
 #include "gigaset.h"
 #include <linux/ctype.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/isdn/capilli.h>
 #include <linux/isdn/capicmd.h>
 #include <linux/isdn/capiutil.h>
@@ -2106,35 +2108,22 @@ static char *gigaset_procinfo(struct capi_ctr *ctr)
 	return ctr->name;	/* ToDo: more? */
 }
 
-/**
- * gigaset_ctr_read_proc() - build controller proc file entry
- * @page:	buffer of PAGE_SIZE bytes for receiving the entry.
- * @start:	unused.
- * @off:	unused.
- * @count:	unused.
- * @eof:	unused.
- * @ctr:	controller descriptor structure.
- *
- * Return value: length of generated entry
- */
-static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
-			  int count, int *eof, struct capi_ctr *ctr)
+static int gigaset_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctr = m->private;
 	struct cardstate *cs = ctr->driverdata;
 	char *s;
 	int i;
-	int len = 0;
-	len += sprintf(page+len, "%-16s %s\n", "name", ctr->name);
-	len += sprintf(page+len, "%-16s %s %s\n", "dev",
+
+	seq_printf(m, "%-16s %s\n", "name", ctr->name);
+	seq_printf(m, "%-16s %s %s\n", "dev",
 			dev_driver_string(cs->dev), dev_name(cs->dev));
-	len += sprintf(page+len, "%-16s %d\n", "id", cs->myid);
+	seq_printf(m, "%-16s %d\n", "id", cs->myid);
 	if (cs->gotfwver)
-		len += sprintf(page+len, "%-16s %d.%d.%d.%d\n", "firmware",
+		seq_printf(m, "%-16s %d.%d.%d.%d\n", "firmware",
 			cs->fwver[0], cs->fwver[1], cs->fwver[2], cs->fwver[3]);
-	len += sprintf(page+len, "%-16s %d\n", "channels",
-			cs->channels);
-	len += sprintf(page+len, "%-16s %s\n", "onechannel",
-			cs->onechannel ? "yes" : "no");
+	seq_printf(m, "%-16s %d\n", "channels", cs->channels);
+	seq_printf(m, "%-16s %s\n", "onechannel", cs->onechannel ? "yes" : "no");
 
 	switch (cs->mode) {
 	case M_UNKNOWN:
@@ -2152,7 +2141,7 @@ static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
 	default:
 		s = "??";
 	}
-	len += sprintf(page+len, "%-16s %s\n", "mode", s);
+	seq_printf(m, "%-16s %s\n", "mode", s);
 
 	switch (cs->mstate) {
 	case MS_UNINITIALIZED:
@@ -2176,25 +2165,21 @@ static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
 	default:
 		s = "??";
 	}
-	len += sprintf(page+len, "%-16s %s\n", "mstate", s);
+	seq_printf(m, "%-16s %s\n", "mstate", s);
 
-	len += sprintf(page+len, "%-16s %s\n", "running",
-			cs->running ? "yes" : "no");
-	len += sprintf(page+len, "%-16s %s\n", "connected",
-			cs->connected ? "yes" : "no");
-	len += sprintf(page+len, "%-16s %s\n", "isdn_up",
-			cs->isdn_up ? "yes" : "no");
-	len += sprintf(page+len, "%-16s %s\n", "cidmode",
-			cs->cidmode ? "yes" : "no");
+	seq_printf(m, "%-16s %s\n", "running", cs->running ? "yes" : "no");
+	seq_printf(m, "%-16s %s\n", "connected", cs->connected ? "yes" : "no");
+	seq_printf(m, "%-16s %s\n", "isdn_up", cs->isdn_up ? "yes" : "no");
+	seq_printf(m, "%-16s %s\n", "cidmode", cs->cidmode ? "yes" : "no");
 
 	for (i = 0; i < cs->channels; i++) {
-		len += sprintf(page+len, "[%d]%-13s %d\n", i, "corrupted",
+		seq_printf(m, "[%d]%-13s %d\n", i, "corrupted",
 				cs->bcs[i].corrupted);
-		len += sprintf(page+len, "[%d]%-13s %d\n", i, "trans_down",
+		seq_printf(m, "[%d]%-13s %d\n", i, "trans_down",
 				cs->bcs[i].trans_down);
-		len += sprintf(page+len, "[%d]%-13s %d\n", i, "trans_up",
+		seq_printf(m, "[%d]%-13s %d\n", i, "trans_up",
 				cs->bcs[i].trans_up);
-		len += sprintf(page+len, "[%d]%-13s %d\n", i, "chstate",
+		seq_printf(m, "[%d]%-13s %d\n", i, "chstate",
 				cs->bcs[i].chstate);
 		switch (cs->bcs[i].proto2) {
 		case L2_BITSYNC:
@@ -2209,11 +2194,23 @@ static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
 		default:
 			s = "??";
 		}
-		len += sprintf(page+len, "[%d]%-13s %s\n", i, "proto2", s);
+		seq_printf(m, "[%d]%-13s %s\n", i, "proto2", s);
 	}
-	return len;
+	return 0;
 }
 
+static int gigaset_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, gigaset_proc_show, PDE(inode)->data);
+}
+
+static const struct file_operations gigaset_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= gigaset_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 
 static struct capi_driver capi_driver_gigaset = {
 	.name		= "gigaset",
@@ -2256,7 +2253,7 @@ int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
 	iif->ctr.release_appl  = gigaset_release_appl;
 	iif->ctr.send_message  = gigaset_send_message;
 	iif->ctr.procinfo      = gigaset_procinfo;
-	iif->ctr.ctr_read_proc = gigaset_ctr_read_proc;
+	iif->ctr.proc_fops = &gigaset_proc_fops;
 	INIT_LIST_HEAD(&iif->appls);
 	skb_queue_head_init(&iif->sendqueue);
 	atomic_set(&iif->sendqlen, 0);
diff --git a/drivers/isdn/hardware/avm/avmcard.h b/drivers/isdn/hardware/avm/avmcard.h
index d964f07..a70e885 100644
--- a/drivers/isdn/hardware/avm/avmcard.h
+++ b/drivers/isdn/hardware/avm/avmcard.h
@@ -556,8 +556,7 @@ u16  b1_send_message(struct capi_ctr *ctrl, struct sk_buff *skb);
 void b1_parse_version(avmctrl_info *card);
 irqreturn_t b1_interrupt(int interrupt, void *devptr);
 
-int b1ctl_read_proc(char *page, char **start, off_t off,
-        		int count, int *eof, struct capi_ctr *ctrl);
+extern const struct file_operations b1ctl_proc_fops;
 
 avmcard_dmainfo *avmcard_dma_alloc(char *name, struct pci_dev *,
 				   long rsize, long ssize);
@@ -577,7 +576,6 @@ void b1dma_register_appl(struct capi_ctr *ctrl,
 				capi_register_params *rp);
 void b1dma_release_appl(struct capi_ctr *ctrl, u16 appl);
 u16  b1dma_send_message(struct capi_ctr *ctrl, struct sk_buff *skb);
-int b1dmactl_read_proc(char *page, char **start, off_t off,
-        		int count, int *eof, struct capi_ctr *ctrl);
+extern const struct file_operations b1dmactl_proc_fops;
 
 #endif /* _AVMCARD_H_ */
diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
index a7c0083..c38fa0f 100644
--- a/drivers/isdn/hardware/avm/b1.c
+++ b/drivers/isdn/hardware/avm/b1.c
@@ -12,6 +12,8 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
@@ -634,18 +636,17 @@ irqreturn_t b1_interrupt(int interrupt, void *devptr)
 }
 
 /* ------------------------------------------------------------- */
-int b1ctl_read_proc(char *page, char **start, off_t off,
-        		int count, int *eof, struct capi_ctr *ctrl)
+static int b1ctl_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	avmctrl_info *cinfo = (avmctrl_info *)(ctrl->driverdata);
 	avmcard *card = cinfo->card;
 	u8 flag;
-	int len = 0;
 	char *s;
 
-	len += sprintf(page+len, "%-16s %s\n", "name", card->name);
-	len += sprintf(page+len, "%-16s 0x%x\n", "io", card->port);
-	len += sprintf(page+len, "%-16s %d\n", "irq", card->irq);
+	seq_printf(m, "%-16s %s\n", "name", card->name);
+	seq_printf(m, "%-16s 0x%x\n", "io", card->port);
+	seq_printf(m, "%-16s %d\n", "irq", card->irq);
 	switch (card->cardtype) {
 	case avm_b1isa: s = "B1 ISA"; break;
 	case avm_b1pci: s = "B1 PCI"; break;
@@ -658,20 +659,20 @@ int b1ctl_read_proc(char *page, char **start, off_t off,
 	case avm_c2: s = "C2"; break;
 	default: s = "???"; break;
 	}
-	len += sprintf(page+len, "%-16s %s\n", "type", s);
+	seq_printf(m, "%-16s %s\n", "type", s);
 	if (card->cardtype == avm_t1isa)
-	   len += sprintf(page+len, "%-16s %d\n", "cardnr", card->cardnr);
+		seq_printf(m, "%-16s %d\n", "cardnr", card->cardnr);
 	if ((s = cinfo->version[VER_DRIVER]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_driver", s);
+		seq_printf(m, "%-16s %s\n", "ver_driver", s);
 	if ((s = cinfo->version[VER_CARDTYPE]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_cardtype", s);
+		seq_printf(m, "%-16s %s\n", "ver_cardtype", s);
 	if ((s = cinfo->version[VER_SERIAL]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_serial", s);
+		seq_printf(m, "%-16s %s\n", "ver_serial", s);
 
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[3];
         	if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s%s%s%s\n",
 			"protocol",
 			(flag & 0x01) ? " DSS1" : "",
 			(flag & 0x02) ? " CT1" : "",
@@ -685,7 +686,7 @@ int b1ctl_read_proc(char *page, char **start, off_t off,
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[5];
 		if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s\n",
 			"linetype",
 			(flag & 0x01) ? " point to point" : "",
 			(flag & 0x02) ? " point to multipoint" : "",
@@ -693,16 +694,25 @@ int b1ctl_read_proc(char *page, char **start, off_t off,
 			(flag & 0x04) ? " leased line with D-channel" : ""
 			);
 	}
-	len += sprintf(page+len, "%-16s %s\n", "cardname", cinfo->cardname);
-
-	if (off+count >= len)
-	   *eof = 1;
-	if (len < off)
-           return 0;
-	*start = page + off;
-	return ((count < len-off) ? count : len-off);
+	seq_printf(m, "%-16s %s\n", "cardname", cinfo->cardname);
+
+	return 0;
+}
+
+static int b1ctl_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, b1ctl_proc_show, PDE(inode)->data);
 }
 
+const struct file_operations b1ctl_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= b1ctl_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+EXPORT_SYMBOL(b1ctl_proc_fops);
+
 /* ------------------------------------------------------------- */
 
 #ifdef CONFIG_PCI
@@ -781,8 +791,6 @@ EXPORT_SYMBOL(b1_send_message);
 EXPORT_SYMBOL(b1_parse_version);
 EXPORT_SYMBOL(b1_interrupt);
 
-EXPORT_SYMBOL(b1ctl_read_proc);
-
 static int __init b1_init(void)
 {
 	char *p;
diff --git a/drivers/isdn/hardware/avm/b1dma.c b/drivers/isdn/hardware/avm/b1dma.c
index 0e84aaa..124550d 100644
--- a/drivers/isdn/hardware/avm/b1dma.c
+++ b/drivers/isdn/hardware/avm/b1dma.c
@@ -11,6 +11,8 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
@@ -855,21 +857,20 @@ u16 b1dma_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 
 /* ------------------------------------------------------------- */
 
-int b1dmactl_read_proc(char *page, char **start, off_t off,
-        		int count, int *eof, struct capi_ctr *ctrl)
+static int b1dmactl_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	avmctrl_info *cinfo = (avmctrl_info *)(ctrl->driverdata);
 	avmcard *card = cinfo->card;
 	u8 flag;
-	int len = 0;
 	char *s;
 	u32 txoff, txlen, rxoff, rxlen, csr;
 	unsigned long flags;
 
-	len += sprintf(page+len, "%-16s %s\n", "name", card->name);
-	len += sprintf(page+len, "%-16s 0x%x\n", "io", card->port);
-	len += sprintf(page+len, "%-16s %d\n", "irq", card->irq);
-	len += sprintf(page+len, "%-16s 0x%lx\n", "membase", card->membase);
+	seq_printf(m, "%-16s %s\n", "name", card->name);
+	seq_printf(m, "%-16s 0x%x\n", "io", card->port);
+	seq_printf(m, "%-16s %d\n", "irq", card->irq);
+	seq_printf(m, "%-16s 0x%lx\n", "membase", card->membase);
 	switch (card->cardtype) {
 	case avm_b1isa: s = "B1 ISA"; break;
 	case avm_b1pci: s = "B1 PCI"; break;
@@ -882,18 +883,18 @@ int b1dmactl_read_proc(char *page, char **start, off_t off,
 	case avm_c2: s = "C2"; break;
 	default: s = "???"; break;
 	}
-	len += sprintf(page+len, "%-16s %s\n", "type", s);
+	seq_printf(m, "%-16s %s\n", "type", s);
 	if ((s = cinfo->version[VER_DRIVER]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_driver", s);
+		seq_printf(m, "%-16s %s\n", "ver_driver", s);
 	if ((s = cinfo->version[VER_CARDTYPE]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_cardtype", s);
+		seq_printf(m, "%-16s %s\n", "ver_cardtype", s);
 	if ((s = cinfo->version[VER_SERIAL]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_serial", s);
+		seq_printf(m, "%-16s %s\n", "ver_serial", s);
 
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[3];
         	if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s%s%s%s\n",
 			"protocol",
 			(flag & 0x01) ? " DSS1" : "",
 			(flag & 0x02) ? " CT1" : "",
@@ -907,7 +908,7 @@ int b1dmactl_read_proc(char *page, char **start, off_t off,
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[5];
 		if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s\n",
 			"linetype",
 			(flag & 0x01) ? " point to point" : "",
 			(flag & 0x02) ? " point to multipoint" : "",
@@ -915,7 +916,7 @@ int b1dmactl_read_proc(char *page, char **start, off_t off,
 			(flag & 0x04) ? " leased line with D-channel" : ""
 			);
 	}
-	len += sprintf(page+len, "%-16s %s\n", "cardname", cinfo->cardname);
+	seq_printf(m, "%-16s %s\n", "cardname", cinfo->cardname);
 
 
 	spin_lock_irqsave(&card->lock, flags);
@@ -930,27 +931,30 @@ int b1dmactl_read_proc(char *page, char **start, off_t off,
 
 	spin_unlock_irqrestore(&card->lock, flags);
 
-        len += sprintf(page+len, "%-16s 0x%lx\n",
-				"csr (cached)", (unsigned long)card->csr);
-        len += sprintf(page+len, "%-16s 0x%lx\n",
-				"csr", (unsigned long)csr);
-        len += sprintf(page+len, "%-16s %lu\n",
-				"txoff", (unsigned long)txoff);
-        len += sprintf(page+len, "%-16s %lu\n",
-				"txlen", (unsigned long)txlen);
-        len += sprintf(page+len, "%-16s %lu\n",
-				"rxoff", (unsigned long)rxoff);
-        len += sprintf(page+len, "%-16s %lu\n",
-				"rxlen", (unsigned long)rxlen);
-
-	if (off+count >= len)
-	   *eof = 1;
-	if (len < off)
-           return 0;
-	*start = page + off;
-	return ((count < len-off) ? count : len-off);
+	seq_printf(m, "%-16s 0x%lx\n", "csr (cached)", (unsigned long)card->csr);
+	seq_printf(m, "%-16s 0x%lx\n", "csr", (unsigned long)csr);
+	seq_printf(m, "%-16s %lu\n", "txoff", (unsigned long)txoff);
+	seq_printf(m, "%-16s %lu\n", "txlen", (unsigned long)txlen);
+	seq_printf(m, "%-16s %lu\n", "rxoff", (unsigned long)rxoff);
+	seq_printf(m, "%-16s %lu\n", "rxlen", (unsigned long)rxlen);
+
+	return 0;
+}
+
+static int b1dmactl_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, b1dmactl_proc_show, PDE(inode)->data);
 }
 
+const struct file_operations b1dmactl_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= b1dmactl_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+EXPORT_SYMBOL(b1dmactl_proc_fops);
+
 /* ------------------------------------------------------------- */
 
 EXPORT_SYMBOL(b1dma_reset);
@@ -963,7 +967,6 @@ EXPORT_SYMBOL(b1dma_reset_ctr);
 EXPORT_SYMBOL(b1dma_register_appl);
 EXPORT_SYMBOL(b1dma_release_appl);
 EXPORT_SYMBOL(b1dma_send_message);
-EXPORT_SYMBOL(b1dmactl_read_proc);
 
 static int __init b1dma_init(void)
 {
diff --git a/drivers/isdn/hardware/avm/b1isa.c b/drivers/isdn/hardware/avm/b1isa.c
index 6461a32..ff53905 100644
--- a/drivers/isdn/hardware/avm/b1isa.c
+++ b/drivers/isdn/hardware/avm/b1isa.c
@@ -121,7 +121,7 @@ static int b1isa_probe(struct pci_dev *pdev)
 	cinfo->capi_ctrl.load_firmware = b1_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = b1_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = b1isa_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1ctl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1ctl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 
 	retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/avm/b1pci.c b/drivers/isdn/hardware/avm/b1pci.c
index 5b314a2..c97e431 100644
--- a/drivers/isdn/hardware/avm/b1pci.c
+++ b/drivers/isdn/hardware/avm/b1pci.c
@@ -112,7 +112,7 @@ static int b1pci_probe(struct capicardparams *p, struct pci_dev *pdev)
 	cinfo->capi_ctrl.load_firmware = b1_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = b1_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = b1pci_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1ctl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1ctl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 	cinfo->capi_ctrl.owner         = THIS_MODULE;
 
@@ -251,7 +251,7 @@ static int b1pciv4_probe(struct capicardparams *p, struct pci_dev *pdev)
 	cinfo->capi_ctrl.load_firmware = b1dma_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = b1dma_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = b1pciv4_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1dmactl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1dmactl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 
 	retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/avm/b1pcmcia.c b/drivers/isdn/hardware/avm/b1pcmcia.c
index 7740403..d6391e0 100644
--- a/drivers/isdn/hardware/avm/b1pcmcia.c
+++ b/drivers/isdn/hardware/avm/b1pcmcia.c
@@ -108,7 +108,7 @@ static int b1pcmcia_add_card(unsigned int port, unsigned irq,
 	cinfo->capi_ctrl.load_firmware = b1_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = b1_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = b1pcmcia_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1ctl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1ctl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 
 	retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 6833301..de6e6b3 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -11,6 +11,8 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
@@ -1062,19 +1064,18 @@ static char *c4_procinfo(struct capi_ctr *ctrl)
 	return cinfo->infobuf;
 }
 
-static int c4_read_proc(char *page, char **start, off_t off,
-        		int count, int *eof, struct capi_ctr *ctrl)
+static int c4_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	avmctrl_info *cinfo = (avmctrl_info *)(ctrl->driverdata);
 	avmcard *card = cinfo->card;
 	u8 flag;
-	int len = 0;
 	char *s;
 
-	len += sprintf(page+len, "%-16s %s\n", "name", card->name);
-	len += sprintf(page+len, "%-16s 0x%x\n", "io", card->port);
-	len += sprintf(page+len, "%-16s %d\n", "irq", card->irq);
-	len += sprintf(page+len, "%-16s 0x%lx\n", "membase", card->membase);
+	seq_printf(m, "%-16s %s\n", "name", card->name);
+	seq_printf(m, "%-16s 0x%x\n", "io", card->port);
+	seq_printf(m, "%-16s %d\n", "irq", card->irq);
+	seq_printf(m, "%-16s 0x%lx\n", "membase", card->membase);
 	switch (card->cardtype) {
 	case avm_b1isa: s = "B1 ISA"; break;
 	case avm_b1pci: s = "B1 PCI"; break;
@@ -1087,18 +1088,18 @@ static int c4_read_proc(char *page, char **start, off_t off,
 	case avm_c2: s = "C2"; break;
 	default: s = "???"; break;
 	}
-	len += sprintf(page+len, "%-16s %s\n", "type", s);
+	seq_printf(m, "%-16s %s\n", "type", s);
 	if ((s = cinfo->version[VER_DRIVER]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_driver", s);
+		seq_printf(m, "%-16s %s\n", "ver_driver", s);
 	if ((s = cinfo->version[VER_CARDTYPE]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_cardtype", s);
+		seq_printf(m, "%-16s %s\n", "ver_cardtype", s);
 	if ((s = cinfo->version[VER_SERIAL]) != NULL)
-	   len += sprintf(page+len, "%-16s %s\n", "ver_serial", s);
+		seq_printf(m, "%-16s %s\n", "ver_serial", s);
 
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[3];
         	if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s%s%s%s\n",
 			"protocol",
 			(flag & 0x01) ? " DSS1" : "",
 			(flag & 0x02) ? " CT1" : "",
@@ -1112,7 +1113,7 @@ static int c4_read_proc(char *page, char **start, off_t off,
 	if (card->cardtype != avm_m1) {
         	flag = ((u8 *)(ctrl->profile.manu))[5];
 		if (flag)
-			len += sprintf(page+len, "%-16s%s%s%s%s\n",
+			seq_printf(m, "%-16s%s%s%s%s\n",
 			"linetype",
 			(flag & 0x01) ? " point to point" : "",
 			(flag & 0x02) ? " point to multipoint" : "",
@@ -1120,16 +1121,24 @@ static int c4_read_proc(char *page, char **start, off_t off,
 			(flag & 0x04) ? " leased line with D-channel" : ""
 			);
 	}
-	len += sprintf(page+len, "%-16s %s\n", "cardname", cinfo->cardname);
-
-	if (off+count >= len)
-	   *eof = 1;
-	if (len < off)
-           return 0;
-	*start = page + off;
-	return ((count < len-off) ? count : len-off);
+	seq_printf(m, "%-16s %s\n", "cardname", cinfo->cardname);
+
+	return 0;
 }
 
+static int c4_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, c4_proc_show, PDE(inode)->data);
+}
+
+static const struct file_operations c4_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= c4_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /* ------------------------------------------------------------- */
 
 static int c4_add_card(struct capicardparams *p, struct pci_dev *dev,
@@ -1201,7 +1210,7 @@ static int c4_add_card(struct capicardparams *p, struct pci_dev *dev,
 		cinfo->capi_ctrl.load_firmware = c4_load_firmware;
 		cinfo->capi_ctrl.reset_ctr     = c4_reset_ctr;
 		cinfo->capi_ctrl.procinfo      = c4_procinfo;
-		cinfo->capi_ctrl.ctr_read_proc = c4_read_proc;
+		cinfo->capi_ctrl.proc_fops = &c4_proc_fops;
 		strcpy(cinfo->capi_ctrl.name, card->name);
 
 		retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/avm/t1isa.c b/drivers/isdn/hardware/avm/t1isa.c
index 1c53fd4..baeeb3c 100644
--- a/drivers/isdn/hardware/avm/t1isa.c
+++ b/drivers/isdn/hardware/avm/t1isa.c
@@ -429,7 +429,7 @@ static int t1isa_probe(struct pci_dev *pdev, int cardnr)
 	cinfo->capi_ctrl.load_firmware = t1isa_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = t1isa_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = t1isa_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1ctl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1ctl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 
 	retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/avm/t1pci.c b/drivers/isdn/hardware/avm/t1pci.c
index e6d298d..5a3f830 100644
--- a/drivers/isdn/hardware/avm/t1pci.c
+++ b/drivers/isdn/hardware/avm/t1pci.c
@@ -119,7 +119,7 @@ static int t1pci_add_card(struct capicardparams *p, struct pci_dev *pdev)
 	cinfo->capi_ctrl.load_firmware = b1dma_load_firmware;
 	cinfo->capi_ctrl.reset_ctr     = b1dma_reset_ctr;
 	cinfo->capi_ctrl.procinfo      = t1pci_procinfo;
-	cinfo->capi_ctrl.ctr_read_proc = b1dmactl_read_proc;
+	cinfo->capi_ctrl.proc_fops = &b1dmactl_proc_fops;
 	strcpy(cinfo->capi_ctrl.name, card->name);
 
 	retval = attach_capi_ctr(&cinfo->capi_ctrl);
diff --git a/drivers/isdn/hardware/eicon/capimain.c b/drivers/isdn/hardware/eicon/capimain.c
index 98fcdfc..0f073cd 100644
--- a/drivers/isdn/hardware/eicon/capimain.c
+++ b/drivers/isdn/hardware/eicon/capimain.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <asm/uaccess.h>
+#include <linux/seq_file.h>
 #include <linux/skbuff.h>
 
 #include "os_capi.h"
@@ -75,25 +76,32 @@ void diva_os_free_message_buffer(diva_os_message_buffer_s * dmb)
 /*
  * proc function for controller info
  */
-static int diva_ctl_read_proc(char *page, char **start, off_t off,
-			      int count, int *eof, struct capi_ctr *ctrl)
+static int diva_ctl_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	diva_card *card = (diva_card *) ctrl->driverdata;
-	int len = 0;
-
-	len += sprintf(page + len, "%s\n", ctrl->name);
-	len += sprintf(page + len, "Serial No. : %s\n", ctrl->serial);
-	len += sprintf(page + len, "Id         : %d\n", card->Id);
-	len += sprintf(page + len, "Channels   : %d\n", card->d.channels);
-
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+
+	seq_printf(m, "%s\n", ctrl->name);
+	seq_printf(m, "Serial No. : %s\n", ctrl->serial);
+	seq_printf(m, "Id         : %d\n", card->Id);
+	seq_printf(m, "Channels   : %d\n", card->d.channels);
+
+	return 0;
+}
+
+static int diva_ctl_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, diva_ctl_proc_show, NULL);
 }
 
+static const struct file_operations diva_ctl_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= diva_ctl_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /*
  * set additional os settings in capi_ctr struct
  */
@@ -102,7 +110,7 @@ void diva_os_set_controller_struct(struct capi_ctr *ctrl)
 	ctrl->driver_name = DRIVERLNAME;
 	ctrl->load_firmware = NULL;
 	ctrl->reset_ctr = NULL;
-	ctrl->ctr_read_proc = diva_ctl_read_proc;
+	ctrl->proc_fops = &diva_ctl_proc_fops;
 	ctrl->owner = THIS_MODULE;
 }
 
diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
index 993b14c..5d06a74 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <net/net_namespace.h>
 
 #include "platform.h"
@@ -62,39 +63,41 @@ static char *getrev(const char *revision)
 	return rev;
 }
 
-static int
-proc_read(char *page, char **start, off_t off, int count, int *eof,
-	  void *data)
+static int divadidd_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
 	char tmprev[32];
 
 	strcpy(tmprev, main_revision);
-	len += sprintf(page + len, "%s\n", DRIVERNAME);
-	len += sprintf(page + len, "name     : %s\n", DRIVERLNAME);
-	len += sprintf(page + len, "release  : %s\n", DRIVERRELEASE_DIDD);
-	len += sprintf(page + len, "build    : %s(%s)\n",
+	seq_printf(m, "%s\n", DRIVERNAME);
+	seq_printf(m, "name     : %s\n", DRIVERLNAME);
+	seq_printf(m, "release  : %s\n", DRIVERRELEASE_DIDD);
+	seq_printf(m, "build    : %s(%s)\n",
 		       diva_didd_common_code_build, DIVA_BUILD);
-	len += sprintf(page + len, "revision : %s\n", getrev(tmprev));
-
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+	seq_printf(m, "revision : %s\n", getrev(tmprev));
+
+	return 0;
 }
 
+static int divadidd_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, divadidd_proc_show, NULL);
+}
+
+static const struct file_operations divadidd_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= divadidd_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int DIVA_INIT_FUNCTION create_proc(void)
 {
 	proc_net_eicon = proc_mkdir("eicon", init_net.proc_net);
 
 	if (proc_net_eicon) {
-		if ((proc_didd =
-		     create_proc_entry(DRIVERLNAME, S_IFREG | S_IRUGO,
-				       proc_net_eicon))) {
-			proc_didd->read_proc = proc_read;
-		}
+		proc_didd = proc_create(DRIVERLNAME, S_IRUGO, proc_net_eicon,
+					&divadidd_proc_fops);
 		return (1);
 	}
 	return (0);
diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardware/eicon/divasi.c
index 69e71eb..f577719 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -17,6 +17,7 @@
 #include <linux/poll.h>
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
+#include <linux/seq_file.h>
 #include <linux/smp_lock.h>
 #include <asm/uaccess.h>
 
@@ -86,39 +87,40 @@ static void diva_um_timer_function(unsigned long data);
 extern struct proc_dir_entry *proc_net_eicon;
 static struct proc_dir_entry *um_idi_proc_entry = NULL;
 
-static int
-um_idi_proc_read(char *page, char **start, off_t off, int count, int *eof,
-		 void *data)
+static int um_idi_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
 	char tmprev[32];
 
-	len += sprintf(page + len, "%s\n", DRIVERNAME);
-	len += sprintf(page + len, "name     : %s\n", DRIVERLNAME);
-	len += sprintf(page + len, "release  : %s\n", DRIVERRELEASE_IDI);
+	seq_printf(m, "%s\n", DRIVERNAME);
+	seq_printf(m, "name     : %s\n", DRIVERLNAME);
+	seq_printf(m, "release  : %s\n", DRIVERRELEASE_IDI);
 	strcpy(tmprev, main_revision);
-	len += sprintf(page + len, "revision : %s\n", getrev(tmprev));
-	len += sprintf(page + len, "build    : %s\n", DIVA_BUILD);
-	len += sprintf(page + len, "major    : %d\n", major);
-
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+	seq_printf(m, "revision : %s\n", getrev(tmprev));
+	seq_printf(m, "build    : %s\n", DIVA_BUILD);
+	seq_printf(m, "major    : %d\n", major);
+
+	return 0;
+}
+
+static int um_idi_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, um_idi_proc_show, NULL);
 }
 
+static const struct file_operations um_idi_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= um_idi_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int DIVA_INIT_FUNCTION create_um_idi_proc(void)
 {
-	um_idi_proc_entry = create_proc_entry(DRIVERLNAME,
-					      S_IFREG | S_IRUGO | S_IWUSR,
-					      proc_net_eicon);
+	um_idi_proc_entry = proc_create(DRIVERLNAME, S_IRUGO, proc_net_eicon,
+					&um_idi_proc_fops);
 	if (!um_idi_proc_entry)
 		return (0);
-
-	um_idi_proc_entry->read_proc = um_idi_proc_read;
-
 	return (1);
 }
 
diff --git a/drivers/isdn/hardware/eicon/divasproc.c b/drivers/isdn/hardware/eicon/divasproc.c
index 0408272..46d44a9 100644
--- a/drivers/isdn/hardware/eicon/divasproc.c
+++ b/drivers/isdn/hardware/eicon/divasproc.c
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/poll.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/list.h>
 #include <asm/uaccess.h>
 
@@ -141,14 +142,10 @@ void remove_divas_proc(void)
 	}
 }
 
-/*
-** write group_optimization 
-*/
-static int
-write_grp_opt(struct file *file, const char __user *buffer, unsigned long count,
-	      void *data)
+static ssize_t grp_opt_proc_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
 {
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = PDE(file->f_path.dentry->d_inode)->data;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 
 	if ((count == 1) || (count == 2)) {
@@ -172,14 +169,10 @@ write_grp_opt(struct file *file, const char __user *buffer, unsigned long count,
 	return (-EINVAL);
 }
 
-/*
-** write dynamic_l1_down
-*/
-static int
-write_d_l1_down(struct file *file, const char __user *buffer, unsigned long count,
-		void *data)
+static ssize_t d_l1_down_proc_write(struct file *file, const char __user *buffer,
+				    size_t count, loff_t *pos)
 {
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = PDE(file->f_path.dentry->d_inode)->data;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 
 	if ((count == 1) || (count == 2)) {
@@ -203,63 +196,62 @@ write_d_l1_down(struct file *file, const char __user *buffer, unsigned long coun
 	return (-EINVAL);
 }
 
-
-/*
-** read dynamic_l1_down 
-*/
-static int
-read_d_l1_down(char *page, char **start, off_t off, int count, int *eof,
-	       void *data)
+static int d_l1_down_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = m->private;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 
-	len += sprintf(page + len, "%s\n",
+	seq_printf(m, "%s\n",
 		       (IoAdapter->capi_cfg.
 			cfg_1 & DIVA_XDI_CAPI_CFG_1_DYNAMIC_L1_ON) ? "1" :
 		       "0");
+	return 0;
+}
 
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+static int d_l1_down_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, d_l1_down_proc_show, PDE(inode)->data);
 }
 
-/*
-** read group_optimization
-*/
-static int
-read_grp_opt(char *page, char **start, off_t off, int count, int *eof,
-	     void *data)
+static const struct file_operations d_l1_down_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= d_l1_down_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+	.write		= d_l1_down_proc_write,
+};
+
+static int grp_opt_proc_show(struct seq_file *m, void *v)
 {
-	int len = 0;
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = m->private;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 
-	len += sprintf(page + len, "%s\n",
+	seq_printf(m, "%s\n",
 		       (IoAdapter->capi_cfg.
 			cfg_1 & DIVA_XDI_CAPI_CFG_1_GROUP_POPTIMIZATION_ON)
 		       ? "1" : "0");
+	return 0;
+}
 
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+static int grp_opt_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, grp_opt_proc_show, PDE(inode)->data);
 }
 
-/*
-** info write
-*/
-static int
-info_write(struct file *file, const char __user *buffer, unsigned long count,
-	   void *data)
+static const struct file_operations grp_opt_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= grp_opt_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+	.write		= grp_opt_proc_write,
+};
+
+static ssize_t info_proc_write(struct file *file, const char __user *buffer,
+			       size_t count, loff_t *pos)
 {
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = PDE(file->f_path.dentry->d_inode)->data;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 	char c[4];
 
@@ -277,63 +269,46 @@ info_write(struct file *file, const char __user *buffer, unsigned long count,
 	return (-EINVAL);
 }
 
-/*
-** info read
-*/
-static int
-info_read(char *page, char **start, off_t off, int count, int *eof,
-	  void *data)
+static int info_proc_show(struct seq_file *m, void *v)
 {
 	int i = 0;
-	int len = 0;
 	char *p;
 	char tmpser[16];
-	diva_os_xdi_adapter_t *a = (diva_os_xdi_adapter_t *) data;
+	diva_os_xdi_adapter_t *a = m->private;
 	PISDN_ADAPTER IoAdapter = IoAdapters[a->controller - 1];
 
-	len +=
-	    sprintf(page + len, "Name        : %s\n",
-		    IoAdapter->Properties.Name);
-	len += sprintf(page + len, "DSP state   : %08x\n", a->dsp_mask);
-	len += sprintf(page + len, "Channels    : %02d\n",
-		       IoAdapter->Properties.Channels);
-	len += sprintf(page + len, "E. max/used : %03d/%03d\n",
+	seq_printf(m, "Name        : %s\n", IoAdapter->Properties.Name);
+	seq_printf(m, "DSP state   : %08x\n", a->dsp_mask);
+	seq_printf(m, "Channels    : %02d\n", IoAdapter->Properties.Channels);
+	seq_printf(m, "E. max/used : %03d/%03d\n",
 		       IoAdapter->e_max, IoAdapter->e_count);
 	diva_get_vserial_number(IoAdapter, tmpser);
-	len += sprintf(page + len, "Serial      : %s\n", tmpser);
-	len +=
-	    sprintf(page + len, "IRQ         : %d\n",
-		    IoAdapter->irq_info.irq_nr);
-	len += sprintf(page + len, "CardIndex   : %d\n", a->CardIndex);
-	len += sprintf(page + len, "CardOrdinal : %d\n", a->CardOrdinal);
-	len += sprintf(page + len, "Controller  : %d\n", a->controller);
-	len += sprintf(page + len, "Bus-Type    : %s\n",
+	seq_printf(m, "Serial      : %s\n", tmpser);
+	seq_printf(m, "IRQ         : %d\n", IoAdapter->irq_info.irq_nr);
+	seq_printf(m, "CardIndex   : %d\n", a->CardIndex);
+	seq_printf(m, "CardOrdinal : %d\n", a->CardOrdinal);
+	seq_printf(m, "Controller  : %d\n", a->controller);
+	seq_printf(m, "Bus-Type    : %s\n",
 		       (a->Bus ==
 			DIVAS_XDI_ADAPTER_BUS_ISA) ? "ISA" : "PCI");
-	len += sprintf(page + len, "Port-Name   : %s\n", a->port_name);
+	seq_printf(m, "Port-Name   : %s\n", a->port_name);
 	if (a->Bus == DIVAS_XDI_ADAPTER_BUS_PCI) {
-		len +=
-		    sprintf(page + len, "PCI-bus     : %d\n",
-			    a->resources.pci.bus);
-		len +=
-		    sprintf(page + len, "PCI-func    : %d\n",
-			    a->resources.pci.func);
+		seq_printf(m, "PCI-bus     : %d\n", a->resources.pci.bus);
+		seq_printf(m, "PCI-func    : %d\n", a->resources.pci.func);
 		for (i = 0; i < 8; i++) {
 			if (a->resources.pci.bar[i]) {
-				len +=
-				    sprintf(page + len,
+				seq_printf(m,
 					    "Mem / I/O %d : 0x%x / mapped : 0x%lx",
 					    i, a->resources.pci.bar[i],
 					    (unsigned long) a->resources.
 					    pci.addr[i]);
 				if (a->resources.pci.length[i]) {
-					len +=
-					    sprintf(page + len,
+					seq_printf(m,
 						    " / length : %d",
 						    a->resources.pci.
 						    length[i]);
 				}
-				len += sprintf(page + len, "\n");
+				seq_putc(m, '\n');
 			}
 		}
 	}
@@ -353,16 +328,25 @@ info_read(char *page, char **start, off_t off, int count, int *eof,
 	} else {
 		p = "ready";
 	}
-	len += sprintf(page + len, "State       : %s\n", p);
+	seq_printf(m, "State       : %s\n", p);
 
-	if (off + count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len - off) ? count : len - off);
+	return 0;
+}
+
+static int info_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, info_proc_show, PDE(inode)->data);
 }
 
+static const struct file_operations info_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= info_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+	.write		= info_proc_write,
+};
+
 /*
 ** adapter proc init/de-init
 */
@@ -380,28 +364,20 @@ int create_adapter_proc(diva_os_xdi_adapter_t * a)
 		return (0);
 	a->proc_adapter_dir = (void *) de;
 
-	if (!(pe =
-	     create_proc_entry(info_proc_name, S_IFREG | S_IRUGO | S_IWUSR, de)))
+	pe = proc_create_data(info_proc_name, S_IRUGO | S_IWUSR, de,
+			      &info_proc_fops, a);
+	if (!pe)
 		return (0);
 	a->proc_info = (void *) pe;
-	pe->write_proc = info_write;
-	pe->read_proc = info_read;
-	pe->data = a;
 
-	if ((pe = create_proc_entry(grp_opt_proc_name,
-			       S_IFREG | S_IRUGO | S_IWUSR, de))) {
+	pe = proc_create_data(grp_opt_proc_name, S_IRUGO | S_IWUSR, de,
+			      &grp_opt_proc_fops, a);
+	if (pe)
 		a->proc_grp_opt = (void *) pe;
-		pe->write_proc = write_grp_opt;
-		pe->read_proc = read_grp_opt;
-		pe->data = a;
-	}
-	if ((pe = create_proc_entry(d_l1_down_proc_name,
-			       S_IFREG | S_IRUGO | S_IWUSR, de))) {
+	pe = proc_create_data(d_l1_down_proc_name, S_IRUGO | S_IWUSR, de,
+			      &d_l1_down_proc_fops, a);
+	if (pe)
 		a->proc_d_l1_down = (void *) pe;
-		pe->write_proc = write_d_l1_down;
-		pe->read_proc = read_d_l1_down;
-		pe->data = a;
-	}
 
 	DBG_TRC(("proc entry %s created", tmp));
 
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 4ffaa14..fe874af 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -11,6 +11,8 @@
  */
 
 #include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/signal.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
@@ -432,26 +434,16 @@ static u16 hycapi_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 	return retval;
 }
 
-/*********************************************************************
-hycapi_read_proc
-
-Informations provided in the /proc/capi-entries.
-
-*********************************************************************/
-
-static int hycapi_read_proc(char *page, char **start, off_t off,
-			    int count, int *eof, struct capi_ctr *ctrl)
+static int hycapi_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	hycapictrl_info *cinfo = (hycapictrl_info *)(ctrl->driverdata);
 	hysdn_card *card = cinfo->card;
-	int len = 0;
 	char *s;
-#ifdef HYCAPI_PRINTFNAMES
-	printk(KERN_NOTICE "hycapi_read_proc\n");    
-#endif
-	len += sprintf(page+len, "%-16s %s\n", "name", cinfo->cardname);
-	len += sprintf(page+len, "%-16s 0x%x\n", "io", card->iobase);
-	len += sprintf(page+len, "%-16s %d\n", "irq", card->irq);
+
+	seq_printf(m, "%-16s %s\n", "name", cinfo->cardname);
+	seq_printf(m, "%-16s 0x%x\n", "io", card->iobase);
+	seq_printf(m, "%-16s %d\n", "irq", card->irq);
     
 	switch (card->brdtype) {
 		case BD_PCCARD:  s = "HYSDN Hycard"; break;
@@ -461,24 +453,32 @@ static int hycapi_read_proc(char *page, char **start, off_t off,
 		case BD_PLEXUS: s = "HYSDN Plexus30"; break;
 		default: s = "???"; break;
 	}
-	len += sprintf(page+len, "%-16s %s\n", "type", s);
+	seq_printf(m, "%-16s %s\n", "type", s);
 	if ((s = cinfo->version[VER_DRIVER]) != NULL)
-		len += sprintf(page+len, "%-16s %s\n", "ver_driver", s);
+		seq_printf(m, "%-16s %s\n", "ver_driver", s);
 	if ((s = cinfo->version[VER_CARDTYPE]) != NULL)
-		len += sprintf(page+len, "%-16s %s\n", "ver_cardtype", s);
+		seq_printf(m, "%-16s %s\n", "ver_cardtype", s);
 	if ((s = cinfo->version[VER_SERIAL]) != NULL)
-		len += sprintf(page+len, "%-16s %s\n", "ver_serial", s);
+		seq_printf(m, "%-16s %s\n", "ver_serial", s);
     
-	len += sprintf(page+len, "%-16s %s\n", "cardname", cinfo->cardname);
+	seq_printf(m, "%-16s %s\n", "cardname", cinfo->cardname);
     
-	if (off+count >= len)
-		*eof = 1;
-	if (len < off)
-		return 0;
-	*start = page + off;
-	return ((count < len-off) ? count : len-off);
+	return 0;
+}
+
+static int hycapi_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, hycapi_proc_show, PDE(inode)->data);
 }
 
+static const struct file_operations hycapi_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= hycapi_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /**************************************************************
 hycapi_load_firmware
 
@@ -774,7 +774,7 @@ hycapi_capi_create(hysdn_card *card)
 		ctrl->load_firmware = hycapi_load_firmware;
 		ctrl->reset_ctr     = hycapi_reset_ctr;
 		ctrl->procinfo      = hycapi_procinfo;
-		ctrl->ctr_read_proc = hycapi_read_proc;
+		ctrl->proc_fops = &hycapi_proc_fops;
 		strcpy(ctrl->name, cinfo->cardname);
 		ctrl->owner = THIS_MODULE;
 
diff --git a/include/linux/isdn/capilli.h b/include/linux/isdn/capilli.h
index 7acb87a..d3e5e9d 100644
--- a/include/linux/isdn/capilli.h
+++ b/include/linux/isdn/capilli.h
@@ -50,8 +50,7 @@ struct capi_ctr {
 	u16  (*send_message)(struct capi_ctr *, struct sk_buff *skb);
 	
 	char *(*procinfo)(struct capi_ctr *);
-	int (*ctr_read_proc)(char *page, char **start, off_t off,
-			     int count, int *eof, struct capi_ctr *card);
+	const struct file_operations *proc_fops;
 
 	/* filled in before calling ready callback */
 	u8 manu[CAPI_MANUFACTURER_LEN];		/* CAPI_GET_MANUFACTURER */
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 97f8d68..3487cfe 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -21,7 +21,8 @@
 */
 
 #include <linux/module.h>
-
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -516,33 +517,37 @@ static char *cmtp_procinfo(struct capi_ctr *ctrl)
 	return "CAPI Message Transport Protocol";
 }
 
-static int cmtp_ctr_read_proc(char *page, char **start, off_t off, int count, int *eof, struct capi_ctr *ctrl)
+static int cmtp_proc_show(struct seq_file *m, void *v)
 {
+	struct capi_ctr *ctrl = m->private;
 	struct cmtp_session *session = ctrl->driverdata;
 	struct cmtp_application *app;
 	struct list_head *p, *n;
-	int len = 0;
 
-	len += sprintf(page + len, "%s\n\n", cmtp_procinfo(ctrl));
-	len += sprintf(page + len, "addr %s\n", session->name);
-	len += sprintf(page + len, "ctrl %d\n", session->num);
+	seq_printf(m, "%s\n\n", cmtp_procinfo(ctrl));
+	seq_printf(m, "addr %s\n", session->name);
+	seq_printf(m, "ctrl %d\n", session->num);
 
 	list_for_each_safe(p, n, &session->applications) {
 		app = list_entry(p, struct cmtp_application, list);
-		len += sprintf(page + len, "appl %d -> %d\n", app->appl, app->mapping);
+		seq_printf(m, "appl %d -> %d\n", app->appl, app->mapping);
 	}
 
-	if (off + count >= len)
-		*eof = 1;
-
-	if (len < off)
-		return 0;
-
-	*start = page + off;
+	return 0;
+}
 
-	return ((count < len - off) ? count : len - off);
+static int cmtp_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, cmtp_proc_show, PDE(inode)->data);
 }
 
+static const struct file_operations cmtp_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= cmtp_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 
 int cmtp_attach_device(struct cmtp_session *session)
 {
@@ -582,7 +587,7 @@ int cmtp_attach_device(struct cmtp_session *session)
 	session->ctrl.send_message  = cmtp_send_message;
 
 	session->ctrl.procinfo      = cmtp_procinfo;
-	session->ctrl.ctr_read_proc = cmtp_ctr_read_proc;
+	session->ctrl.proc_fops = &cmtp_proc_fops;
 
 	if (attach_capi_ctr(&session->ctrl) < 0) {
 		BT_ERR("Can't attach new controller");
-- 
1.6.0.2

