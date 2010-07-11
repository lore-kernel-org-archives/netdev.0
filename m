From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 02/12] isdn: autoconvert trivial BKL users to private mutex
Date: Sun, 11 Jul 2010 23:18:53 +0200
Message-ID: <1278883143-29035-3-git-send-email-arnd@arndb.de>
References: <1278883143-29035-1-git-send-email-arnd@arndb.de>
Cc: John Kacur <jkacur@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278883143-29035-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All these files use the big kernel lock in a trivial
way to serialize their private file operations,
typically resulting from an earlier semi-automatic
pushdown from VFS.

None of these drivers appears to want to lock against
other code, and they all use the BKL as the top-level
lock in their file operations, meaning that there
is no lock-order inversion problem.

Consequently, we can remove the BKL completely,
replacing it with a per-file mutex in every case.
Using a scripted approach means we can avoid
typos.

file=$1
name=$2
if grep -q lock_kernel ${file} ; then
    if grep -q 'include.*linux.mutex.h' ${file} ; then
            sed -i '/include.*<linux\/smp_lock.h>/d' ${file}
    else
            sed -i 's/include.*<linux\/smp_lock.h>.*$/include <linux\/mutex.h>/g' ${file}
    fi
    sed -i ${file} \
        -e "/^#include.*linux.mutex.h/,$ {
                1,/^\(static\|int\|long\)/ {
                     /^\(static\|int\|long\)/istatic DEFINE_MUTEX(${name}_mutex);

} }"  \
    -e "s/\(un\)*lock_kernel\>[ ]*()/mutex_\1lock(\&${name}_mutex)/g" \
    -e '/[      ]*cycle_kernel_lock();/d'
else
    sed -i -e '/include.*\<smp_lock.h\>/d' ${file}  \
                -e '/cycle_kernel_lock()/d'
fi

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/capi/capi.c                |    6 +++---
 drivers/isdn/divert/divert_procfs.c     |    7 ++++---
 drivers/isdn/hardware/eicon/divamnt.c   |    7 ++++---
 drivers/isdn/hardware/eicon/divasi.c    |    2 --
 drivers/isdn/hardware/eicon/divasmain.c |    2 --
 drivers/isdn/hysdn/hysdn_procconf.c     |   21 +++++++++++----------
 drivers/isdn/hysdn/hysdn_proclog.c      |   15 ++++++++-------
 drivers/isdn/i4l/isdn_common.c          |   27 ++++++++++++++-------------
 drivers/isdn/mISDN/timerdev.c           |    7 ++++---
 9 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 0cabe31..b0a4a69 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -20,7 +20,6 @@
 #include <linux/signal.h>
 #include <linux/mutex.h>
 #include <linux/mm.h>
-#include <linux/smp_lock.h>
 #include <linux/timer.h>
 #include <linux/wait.h>
 #include <linux/tty.h>
@@ -50,6 +49,7 @@ MODULE_LICENSE("GPL");
 
 /* -------- driver information -------------------------------------- */
 
+static DEFINE_MUTEX(capi_mutex);
 static struct class *capi_class;
 static int capi_major = 68;		/* allocated */
 
@@ -985,9 +985,9 @@ capi_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	int ret;
 
-	lock_kernel();
+	mutex_lock(&capi_mutex);
 	ret = capi_ioctl(file, cmd, arg);
-	unlock_kernel();
+	mutex_unlock(&capi_mutex);
 
 	return ret;
 }
diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
index c53e241..33ec9e4 100644
--- a/drivers/isdn/divert/divert_procfs.c
+++ b/drivers/isdn/divert/divert_procfs.c
@@ -20,7 +20,7 @@
 #include <linux/sched.h>
 #include <linux/isdnif.h>
 #include <net/net_namespace.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include "isdn_divert.h"
 
 
@@ -28,6 +28,7 @@
 /* Variables for interface queue */
 /*********************************/
 ulong if_used = 0;		/* number of interface users */
+static DEFINE_MUTEX(isdn_divert_mutex);
 static struct divert_info *divert_info_head = NULL;	/* head of queue */
 static struct divert_info *divert_info_tail = NULL;	/* pointer to last entry */
 static DEFINE_SPINLOCK(divert_info_lock);/* lock for queue */
@@ -261,9 +262,9 @@ static long isdn_divert_ioctl(struct file *file, uint cmd, ulong arg)
 {
 	long ret;
 
-	lock_kernel();
+	mutex_lock(&isdn_divert_mutex);
 	ret = isdn_divert_ioctl_unlocked(file, cmd, arg);
-	unlock_kernel();
+	mutex_unlock(&isdn_divert_mutex);
 
 	return ret;
 }
diff --git a/drivers/isdn/hardware/eicon/divamnt.c b/drivers/isdn/hardware/eicon/divamnt.c
index 1e85f74..f1d464f 100644
--- a/drivers/isdn/hardware/eicon/divamnt.c
+++ b/drivers/isdn/hardware/eicon/divamnt.c
@@ -14,7 +14,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/poll.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include <asm/uaccess.h>
 
 #include "platform.h"
@@ -22,6 +22,7 @@
 #include "divasync.h"
 #include "debug_if.h"
 
+static DEFINE_MUTEX(maint_mutex);
 static char *main_revision = "$Revision: 1.32.6.10 $";
 
 static int major;
@@ -130,7 +131,7 @@ static int maint_open(struct inode *ino, struct file *filep)
 {
 	int ret;
 
-	lock_kernel();
+	mutex_lock(&maint_mutex);
 	/* only one open is allowed, so we test
 	   it atomically */
 	if (test_and_set_bit(0, &opened))
@@ -139,7 +140,7 @@ static int maint_open(struct inode *ino, struct file *filep)
 		filep->private_data = NULL;
 		ret = nonseekable_open(ino, filep);
 	}
-	unlock_kernel();
+	mutex_unlock(&maint_mutex);
 	return ret;
 }
 
diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardware/eicon/divasi.c
index f577719..42d3b83 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -18,7 +18,6 @@
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <linux/seq_file.h>
-#include <linux/smp_lock.h>
 #include <asm/uaccess.h>
 
 #include "platform.h"
@@ -402,7 +401,6 @@ static unsigned int um_idi_poll(struct file *file, poll_table * wait)
 
 static int um_idi_open(struct inode *inode, struct file *file)
 {
-	cycle_kernel_lock();
 	return (0);
 }
 
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index fbbcb27..16a874b 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -21,7 +21,6 @@
 #include <linux/list.h>
 #include <linux/poll.h>
 #include <linux/kmod.h>
-#include <linux/smp_lock.h>
 
 #include "platform.h"
 #undef ID_MASK
@@ -581,7 +580,6 @@ xdi_copy_from_user(void *os_handle, void *dst, const void __user *src, int lengt
  */
 static int divas_open(struct inode *inode, struct file *file)
 {
-	cycle_kernel_lock();
 	return (0);
 }
 
diff --git a/drivers/isdn/hysdn/hysdn_procconf.c b/drivers/isdn/hysdn/hysdn_procconf.c
index 8096646..96b3e39 100644
--- a/drivers/isdn/hysdn/hysdn_procconf.c
+++ b/drivers/isdn/hysdn/hysdn_procconf.c
@@ -17,11 +17,12 @@
 #include <linux/proc_fs.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include <net/net_namespace.h>
 
 #include "hysdn_defs.h"
 
+static DEFINE_MUTEX(hysdn_conf_mutex);
 static char *hysdn_procconf_revision = "$Revision: 1.8.6.4 $";
 
 #define INFO_OUT_LEN 80		/* length of info line including lf */
@@ -234,7 +235,7 @@ hysdn_conf_open(struct inode *ino, struct file *filep)
 	char *cp, *tmp;
 
 	/* now search the addressed card */
-	lock_kernel();
+	mutex_lock(&hysdn_conf_mutex);
 	card = card_root;
 	while (card) {
 		pd = card->procconf;
@@ -243,7 +244,7 @@ hysdn_conf_open(struct inode *ino, struct file *filep)
 		card = card->next;	/* search next entry */
 	}
 	if (!card) {
-		unlock_kernel();
+		mutex_unlock(&hysdn_conf_mutex);
 		return (-ENODEV);	/* device is unknown/invalid */
 	}
 	if (card->debug_flags & (LOG_PROC_OPEN | LOG_PROC_ALL))
@@ -255,7 +256,7 @@ hysdn_conf_open(struct inode *ino, struct file *filep)
 		/* write only access -> write boot file or conf line */
 
 		if (!(cnf = kmalloc(sizeof(struct conf_writedata), GFP_KERNEL))) {
-			unlock_kernel();
+			mutex_unlock(&hysdn_conf_mutex);
 			return (-EFAULT);
 		}
 		cnf->card = card;
@@ -267,7 +268,7 @@ hysdn_conf_open(struct inode *ino, struct file *filep)
 		/* read access -> output card info data */
 
 		if (!(tmp = kmalloc(INFO_OUT_LEN * 2 + 2, GFP_KERNEL))) {
-			unlock_kernel();
+			mutex_unlock(&hysdn_conf_mutex);
 			return (-EFAULT);	/* out of memory */
 		}
 		filep->private_data = tmp;	/* start of string */
@@ -301,10 +302,10 @@ hysdn_conf_open(struct inode *ino, struct file *filep)
 		*cp++ = '\n';
 		*cp = 0;	/* end of string */
 	} else {		/* simultaneous read/write access forbidden ! */
-		unlock_kernel();
+		mutex_unlock(&hysdn_conf_mutex);
 		return (-EPERM);	/* no permission this time */
 	}
-	unlock_kernel();
+	mutex_unlock(&hysdn_conf_mutex);
 	return nonseekable_open(ino, filep);
 }				/* hysdn_conf_open */
 
@@ -319,7 +320,7 @@ hysdn_conf_close(struct inode *ino, struct file *filep)
 	int retval = 0;
 	struct proc_dir_entry *pd;
 
-	lock_kernel();
+	mutex_lock(&hysdn_conf_mutex);
 	/* search the addressed card */
 	card = card_root;
 	while (card) {
@@ -329,7 +330,7 @@ hysdn_conf_close(struct inode *ino, struct file *filep)
 		card = card->next;	/* search next entry */
 	}
 	if (!card) {
-		unlock_kernel();
+		mutex_unlock(&hysdn_conf_mutex);
 		return (-ENODEV);	/* device is unknown/invalid */
 	}
 	if (card->debug_flags & (LOG_PROC_OPEN | LOG_PROC_ALL))
@@ -352,7 +353,7 @@ hysdn_conf_close(struct inode *ino, struct file *filep)
 
 		kfree(filep->private_data);	/* release memory */
 	}
-	unlock_kernel();
+	mutex_unlock(&hysdn_conf_mutex);
 	return (retval);
 }				/* hysdn_conf_close */
 
diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index e83f6fd..37a9dd3 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -15,13 +15,14 @@
 #include <linux/proc_fs.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 
 #include "hysdn_defs.h"
 
 /* the proc subdir for the interface is defined in the procconf module */
 extern struct proc_dir_entry *hysdn_proc_entry;
 
+static DEFINE_MUTEX(hysdn_log_mutex);
 static void put_log_buffer(hysdn_card * card, char *cp);
 
 /*************************************************/
@@ -251,7 +252,7 @@ hysdn_log_open(struct inode *ino, struct file *filep)
 	struct procdata *pd = NULL;
 	unsigned long flags;
 
-	lock_kernel();
+	mutex_lock(&hysdn_log_mutex);
 	card = card_root;
 	while (card) {
 		pd = card->proclog;
@@ -260,7 +261,7 @@ hysdn_log_open(struct inode *ino, struct file *filep)
 		card = card->next;	/* search next entry */
 	}
 	if (!card) {
-		unlock_kernel();
+		mutex_unlock(&hysdn_log_mutex);
 		return (-ENODEV);	/* device is unknown/invalid */
 	}
 	filep->private_data = card;	/* remember our own card */
@@ -278,10 +279,10 @@ hysdn_log_open(struct inode *ino, struct file *filep)
 			filep->private_data = &pd->log_head;
 		spin_unlock_irqrestore(&card->hysdn_lock, flags);
 	} else {		/* simultaneous read/write access forbidden ! */
-		unlock_kernel();
+		mutex_unlock(&hysdn_log_mutex);
 		return (-EPERM);	/* no permission this time */
 	}
-	unlock_kernel();
+	mutex_unlock(&hysdn_log_mutex);
 	return nonseekable_open(ino, filep);
 }				/* hysdn_log_open */
 
@@ -300,7 +301,7 @@ hysdn_log_close(struct inode *ino, struct file *filep)
 	hysdn_card *card;
 	int retval = 0;
 
-	lock_kernel();
+	mutex_lock(&hysdn_log_mutex);
 	if ((filep->f_mode & (FMODE_READ | FMODE_WRITE)) == FMODE_WRITE) {
 		/* write only access -> write debug level written */
 		retval = 0;	/* success */
@@ -339,7 +340,7 @@ hysdn_log_close(struct inode *ino, struct file *filep)
 					kfree(inf);
 				}
 	}			/* read access */
-	unlock_kernel();
+	mutex_unlock(&hysdn_log_mutex);
 
 	return (retval);
 }				/* hysdn_log_close */
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index a44cdb4..15632bd 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -17,7 +17,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/isdn.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include "isdn_common.h"
 #include "isdn_tty.h"
 #include "isdn_net.h"
@@ -42,6 +42,7 @@ MODULE_LICENSE("GPL");
 
 isdn_dev *dev;
 
+static DEFINE_MUTEX(isdn_mutex);
 static char *isdn_revision = "$Revision: 1.1.2.3 $";
 
 extern char *isdn_net_revision;
@@ -1070,7 +1071,7 @@ isdn_read(struct file *file, char __user *buf, size_t count, loff_t * off)
 	int retval;
 	char *p;
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	if (minor == ISDN_MINOR_STATUS) {
 		if (!file->private_data) {
 			if (file->f_flags & O_NONBLOCK) {
@@ -1163,7 +1164,7 @@ isdn_read(struct file *file, char __user *buf, size_t count, loff_t * off)
 #endif
 	retval = -ENODEV;
  out:
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 	return retval;
 }
 
@@ -1180,7 +1181,7 @@ isdn_write(struct file *file, const char __user *buf, size_t count, loff_t * off
 	if (!dev->drivers)
 		return -ENODEV;
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	if (minor <= ISDN_MINOR_BMAX) {
 		printk(KERN_WARNING "isdn_write minor %d obsolete!\n", minor);
 		drvidx = isdn_minor2drv(minor);
@@ -1225,7 +1226,7 @@ isdn_write(struct file *file, const char __user *buf, size_t count, loff_t * off
 #endif
 	retval = -ENODEV;
  out:
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 	return retval;
 }
 
@@ -1236,7 +1237,7 @@ isdn_poll(struct file *file, poll_table * wait)
 	unsigned int minor = iminor(file->f_path.dentry->d_inode);
 	int drvidx = isdn_minor2drv(minor - ISDN_MINOR_CTRL);
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	if (minor == ISDN_MINOR_STATUS) {
 		poll_wait(file, &(dev->info_waitq), wait);
 		/* mask = POLLOUT | POLLWRNORM; */
@@ -1266,7 +1267,7 @@ isdn_poll(struct file *file, poll_table * wait)
 #endif
 	mask = POLLERR;
  out:
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 	return mask;
 }
 
@@ -1727,9 +1728,9 @@ isdn_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	int ret;
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	ret = isdn_ioctl(file, cmd, arg);
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 
 	return ret;
 }
@@ -1745,7 +1746,7 @@ isdn_open(struct inode *ino, struct file *filep)
 	int chidx;
 	int retval = -ENODEV;
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	if (minor == ISDN_MINOR_STATUS) {
 		infostruct *p;
 
@@ -1796,7 +1797,7 @@ isdn_open(struct inode *ino, struct file *filep)
 #endif
  out:
 	nonseekable_open(ino, filep);
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 	return retval;
 }
 
@@ -1805,7 +1806,7 @@ isdn_close(struct inode *ino, struct file *filep)
 {
 	uint minor = iminor(ino);
 
-	lock_kernel();
+	mutex_lock(&isdn_mutex);
 	if (minor == ISDN_MINOR_STATUS) {
 		infostruct *p = dev->infochain;
 		infostruct *q = NULL;
@@ -1839,7 +1840,7 @@ isdn_close(struct inode *ino, struct file *filep)
 #endif
 
  out:
-	unlock_kernel();
+	mutex_unlock(&isdn_mutex);
 	return 0;
 }
 
diff --git a/drivers/isdn/mISDN/timerdev.c b/drivers/isdn/mISDN/timerdev.c
index 81048b8..de43c8c 100644
--- a/drivers/isdn/mISDN/timerdev.c
+++ b/drivers/isdn/mISDN/timerdev.c
@@ -24,9 +24,10 @@
 #include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/mISDNif.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include "core.h"
 
+static DEFINE_MUTEX(mISDN_mutex);
 static u_int	*debug;
 
 
@@ -224,7 +225,7 @@ mISDN_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
 	if (*debug & DEBUG_TIMER)
 		printk(KERN_DEBUG "%s(%p, %x, %lx)\n", __func__,
 		    filep, cmd, arg);
-	lock_kernel();
+	mutex_lock(&mISDN_mutex);
 	switch (cmd) {
 	case IMADDTIMER:
 		if (get_user(tout, (int __user *)arg)) {
@@ -256,7 +257,7 @@ mISDN_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
 	default:
 		ret = -EINVAL;
 	}
-	unlock_kernel();
+	mutex_unlock(&mISDN_mutex);
 	return ret;
 }
 
-- 
1.7.1
