From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 06/12] net: autoconvert trivial BKL users to private mutex
Date: Sun, 11 Jul 2010 23:18:57 +0200
Message-ID: <1278883143-29035-7-git-send-email-arnd@arndb.de>
References: <1278883143-29035-1-git-send-email-arnd@arndb.de>
Cc: John Kacur <jkacur@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
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
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ppp_generic.c |   19 +++++++++----------
 drivers/net/wan/cosa.c    |   10 +++++-----
 net/wanrouter/wanmain.c   |    7 ++++---
 net/wanrouter/wanproc.c   |    7 ++++---
 4 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 1b2c291..a72a335 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -40,7 +40,6 @@
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
-#include <linux/smp_lock.h>
 #include <linux/spinlock.h>
 #include <linux/rwsem.h>
 #include <linux/stddef.h>
@@ -181,6 +180,7 @@ struct channel {
  * channel.downl.
  */
 
+static DEFINE_MUTEX(ppp_mutex);
 static atomic_t ppp_unit_count = ATOMIC_INIT(0);
 static atomic_t channel_count = ATOMIC_INIT(0);
 
@@ -363,7 +363,6 @@ static const int npindex_to_ethertype[NUM_NP] = {
  */
 static int ppp_open(struct inode *inode, struct file *file)
 {
-	cycle_kernel_lock();
 	/*
 	 * This could (should?) be enforced by the permissions on /dev/ppp.
 	 */
@@ -588,7 +587,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		 * this fd and reopening /dev/ppp.
 		 */
 		err = -EINVAL;
-		lock_kernel();
+		mutex_lock(&ppp_mutex);
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
 			if (file == ppp->owner)
@@ -600,7 +599,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		} else
 			printk(KERN_DEBUG "PPPIOCDETACH file->f_count=%ld\n",
 			       atomic_long_read(&file->f_count));
-		unlock_kernel();
+		mutex_unlock(&ppp_mutex);
 		return err;
 	}
 
@@ -608,7 +607,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct channel *pch;
 		struct ppp_channel *chan;
 
-		lock_kernel();
+		mutex_lock(&ppp_mutex);
 		pch = PF_TO_CHANNEL(pf);
 
 		switch (cmd) {
@@ -630,7 +629,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				err = chan->ops->ioctl(chan, cmd, arg);
 			up_read(&pch->chan_sem);
 		}
-		unlock_kernel();
+		mutex_unlock(&ppp_mutex);
 		return err;
 	}
 
@@ -640,7 +639,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return -EINVAL;
 	}
 
-	lock_kernel();
+	mutex_lock(&ppp_mutex);
 	ppp = PF_TO_PPP(pf);
 	switch (cmd) {
 	case PPPIOCSMRU:
@@ -788,7 +787,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	default:
 		err = -ENOTTY;
 	}
-	unlock_kernel();
+	mutex_unlock(&ppp_mutex);
 	return err;
 }
 
@@ -801,7 +800,7 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 	struct ppp_net *pn;
 	int __user *p = (int __user *)arg;
 
-	lock_kernel();
+	mutex_lock(&ppp_mutex);
 	switch (cmd) {
 	case PPPIOCNEWUNIT:
 		/* Create a new ppp unit */
@@ -852,7 +851,7 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 	default:
 		err = -ENOTTY;
 	}
-	unlock_kernel();
+	mutex_unlock(&ppp_mutex);
 	return err;
 }
 
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index f0bd70f..04c6cd4 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -89,7 +89,6 @@
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/device.h>
-#include <linux/smp_lock.h>
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
@@ -174,6 +173,7 @@ struct cosa_data {
  * Character device major number. 117 was allocated for us.
  * The value of 0 means to allocate a first free one.
  */
+static DEFINE_MUTEX(cosa_chardev_mutex);
 static int cosa_major = 117;
 
 /*
@@ -944,7 +944,7 @@ static int cosa_open(struct inode *inode, struct file *file)
 	int n;
 	int ret = 0;
 
-	lock_kernel();
+	mutex_lock(&cosa_chardev_mutex);
 	if ((n=iminor(file->f_path.dentry->d_inode)>>CARD_MINOR_BITS)
 		>= nr_cards) {
 		ret = -ENODEV;
@@ -976,7 +976,7 @@ static int cosa_open(struct inode *inode, struct file *file)
 	chan->rx_done = chrdev_rx_done;
 	spin_unlock_irqrestore(&cosa->lock, flags);
 out:
-	unlock_kernel();
+	mutex_unlock(&cosa_chardev_mutex);
 	return ret;
 }
 
@@ -1212,10 +1212,10 @@ static long cosa_chardev_ioctl(struct file *file, unsigned int cmd,
 	struct cosa_data *cosa;
 	long ret;
 
-	lock_kernel();
+	mutex_lock(&cosa_chardev_mutex);
 	cosa = channel->cosa;
 	ret = cosa_ioctl_common(cosa, channel, cmd, arg);
-	unlock_kernel();
+	mutex_unlock(&cosa_chardev_mutex);
 	return ret;
 }
 
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 258daa8..2bf2340 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -48,7 +48,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>	/* support for loadable modules */
 #include <linux/slab.h>		/* kmalloc(), kfree() */
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include <linux/mm.h>
 #include <linux/string.h>	/* inline mem*, str* functions */
 
@@ -71,6 +71,7 @@
  *	WAN device IOCTL handlers
  */
 
+static DEFINE_MUTEX(wanrouter_mutex);
 static int wanrouter_device_setup(struct wan_device *wandev,
 				  wandev_conf_t __user *u_conf);
 static int wanrouter_device_stat(struct wan_device *wandev,
@@ -376,7 +377,7 @@ long wanrouter_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	if (wandev->magic != ROUTER_MAGIC)
 		return -EINVAL;
 
-	lock_kernel();
+	mutex_lock(&wanrouter_mutex);
 	switch (cmd) {
 	case ROUTER_SETUP:
 		err = wanrouter_device_setup(wandev, data);
@@ -408,7 +409,7 @@ long wanrouter_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			err = wandev->ioctl(wandev, cmd, arg);
 		else err = -EINVAL;
 	}
-	unlock_kernel();
+	mutex_unlock(&wanrouter_mutex);
 	return err;
 }
 
diff --git a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
index c44d96b..11f25c7 100644
--- a/net/wanrouter/wanproc.c
+++ b/net/wanrouter/wanproc.c
@@ -27,7 +27,7 @@
 #include <linux/module.h>
 #include <linux/wanrouter.h>	/* WAN router API definitions */
 #include <linux/seq_file.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 
 #include <net/net_namespace.h>
 #include <asm/io.h>
@@ -66,6 +66,7 @@
  *	/proc/net/router
  */
 
+static DEFINE_MUTEX(config_mutex);
 static struct proc_dir_entry *proc_router;
 
 /* Strings */
@@ -85,7 +86,7 @@ static void *r_start(struct seq_file *m, loff_t *pos)
 	struct wan_device *wandev;
 	loff_t l = *pos;
 
-	lock_kernel();
+	mutex_lock(&config_mutex);
 	if (!l--)
 		return SEQ_START_TOKEN;
 	for (wandev = wanrouter_router_devlist; l-- && wandev;
@@ -104,7 +105,7 @@ static void *r_next(struct seq_file *m, void *v, loff_t *pos)
 static void r_stop(struct seq_file *m, void *v)
 	__releases(kernel_lock)
 {
-	unlock_kernel();
+	mutex_unlock(&config_mutex);
 }
 
 static int config_show(struct seq_file *m, void *v)
-- 
1.7.1
