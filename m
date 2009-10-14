From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH] cosa: Kill off the use of the old ioctl path
Date: Wed, 14 Oct 2009 16:22:24 +0100
Message-ID: <20091014152224.30363.72926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50948 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758493AbZJOPJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 11:09:52 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by bob.linux.org.uk (8.14.3/8.14.3) with ESMTP id n9EFMOmD030391
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 16:25:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/wan/cosa.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)


diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index e2c33c0..d888390 100644
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
@@ -309,7 +309,7 @@ static const struct file_operations cosa_fops = {
 	.read		= cosa_read,
 	.write		= cosa_write,
 	.poll		= cosa_poll,
-	.ioctl		= cosa_chardev_ioctl,
+	.unlocked_ioctl	= cosa_chardev_ioctl,
 	.open		= cosa_open,
 	.release	= cosa_release,
 #ifdef COSA_FASYNC_WORKING
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
 
 

