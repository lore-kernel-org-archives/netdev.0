From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH] cosa: Kill off the use of the old ioctl path
Date: Tue, 13 Oct 2009 16:30:46 +0100
Message-ID: <20091013153045.20012.76202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:55256 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759977AbZJMPms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 11:42:48 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by bob.linux.org.uk (8.14.3/8.14.3) with ESMTP id n9DFUk7s020040
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 16:30:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/message/i2o/i2o_config.c |    5 ++---
 drivers/net/wan/cosa.c           |   18 ++++++++++++------
 2 files changed, 14 insertions(+), 9 deletions(-)


diff --git a/drivers/message/i2o/i2o_config.c b/drivers/message/i2o/i2o_config.c
index 4e8722b..3d5f40c 100644
--- a/drivers/message/i2o/i2o_config.c
+++ b/drivers/message/i2o/i2o_config.c
@@ -40,8 +40,7 @@
 
 #define SG_TABLESIZE		30
 
-static int i2o_cfg_ioctl(struct inode *, struct file *, unsigned int,
-			 unsigned long);
+static long i2o_cfg_ioctl(struct file *, unsigned int, unsigned long);
 
 static spinlock_t i2o_config_lock;
 
@@ -1118,7 +1117,7 @@ static int cfg_release(struct inode *inode, struct file *file)
 static const struct file_operations config_fops = {
 	.owner = THIS_MODULE,
 	.llseek = no_llseek,
-	.ioctl = i2o_cfg_ioctl,
+	.unlocked_ioctl = i2o_cfg_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = i2o_cfg_compat_ioctl,
 #endif
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index e2c33c0..a15f017 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -297,8 +297,8 @@ static ssize_t cosa_write(struct file *file,
 static unsigned int cosa_poll(struct file *file, poll_table *poll);
 static int cosa_open(struct inode *inode, struct file *file);
 static int cosa_release(struct inode *inode, struct file *file);
-static int cosa_chardev_ioctl(struct inode *inode, struct file *file,
-	unsigned int cmd, unsigned long arg);
+static long cosa_chardev_ioctl(struct file *file, unsigned int cmd,
+				unsigned long arg);
 #ifdef COSA_FASYNC_WORKING
 static int cosa_fasync(struct inode *inode, struct file *file, int on);
 #endif
@@ -1204,12 +1204,18 @@ static int cosa_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return hdlc_ioctl(dev, ifr, cmd);
 }
 
-static int cosa_chardev_ioctl(struct inode *inode, struct file *file,
-	unsigned int cmd, unsigned long arg)
+static long cosa_chardev_ioctl(struct file *file, unsigned int cmd,
+							unsigned long arg)
 {
 	struct channel_data *channel = file->private_data;
-	struct cosa_data *cosa = channel->cosa;
-	return cosa_ioctl_common(cosa, channel, cmd, arg);
+	struct cosa_data *cosa;
+	long ret;
+	
+	lock_kernel();
+	cosa = channel->cosa;
+	ret = cosa_ioctl_common(cosa, channel, cmd, arg);
+	unlock_kernel();
+	return ret;
 }
 
 

