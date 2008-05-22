From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] cosa: Push the BKL down into the COSA driver
Date: Thu, 22 May 2008 21:58:30 +0100
Message-ID: <20080522215830.0bed60db@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:58187 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757942AbYEVVLB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 17:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@redhat.com>

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 45ddfc9..35cff1a 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -305,8 +305,8 @@ static ssize_t cosa_write(struct file *file,
 static unsigned int cosa_poll(struct file *file, poll_table *poll);
 static int cosa_open(struct inode *inode, struct file *file);
 static int cosa_release(struct inode *inode, struct file *file);
-static int cosa_chardev_ioctl(struct inode *inode, struct file *file,
-	unsigned int cmd, unsigned long arg);
+static long cosa_chardev_ioctl(struct file *file, unsigned int cmd,
+							unsigned long arg);
 #ifdef COSA_FASYNC_WORKING
 static int cosa_fasync(struct inode *inode, struct file *file, int on);
 #endif
@@ -317,7 +317,7 @@ static const struct file_operations cosa_fops = {
 	.read		= cosa_read,
 	.write		= cosa_write,
 	.poll		= cosa_poll,
-	.ioctl		= cosa_chardev_ioctl,
+	.unlocked_ioctl	= cosa_chardev_ioctl,
 	.open		= cosa_open,
 	.release	= cosa_release,
 #ifdef COSA_FASYNC_WORKING
@@ -1225,12 +1225,18 @@ static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr,
 	return rv;
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
 
 
