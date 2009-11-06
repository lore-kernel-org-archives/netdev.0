From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/7] net/tun: handle compat_ioctl directly
Date: Fri,  6 Nov 2009 19:09:04 +0100
Message-ID: <1257530949-9695-3-git-send-email-arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:54669 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376AbZKFSJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 13:09:11 -0500
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun driver is the only code in the kernel that operates
on a character device with struct ifreq. Change the driver
to handle the conversion itself so we can contain the
remaining ifreq handling in the socket layer.

This also fixes a bug in the handling of invalid ioctl
numbers on an unbound tun device. The driver treats this
as a TUNSETIFF in native mode, but there is no way for
the generic compat_ioctl() function to emulate this
behaviour. Possibly the driver was only doing this
accidentally anyway, but if any code relies on this
misfeature, it now also works in compat mode.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/tun.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++------
 fs/compat_ioctl.c |   20 -------------------
 2 files changed, 48 insertions(+), 27 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4fdfa2a..c132c8e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -54,6 +54,7 @@
 #include <linux/miscdevice.h>
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
+#include <linux/compat.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
@@ -1110,8 +1111,8 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 	return 0;
 }
 
-static long tun_chr_ioctl(struct file *file, unsigned int cmd,
-			  unsigned long arg)
+static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
+			    unsigned long arg, int ifreq_len)
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
@@ -1121,7 +1122,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 	int ret;
 
 	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
-		if (copy_from_user(&ifr, argp, sizeof ifr))
+		if (copy_from_user(&ifr, argp, ifreq_len))
 			return -EFAULT;
 
 	if (cmd == TUNGETFEATURES) {
@@ -1144,7 +1145,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 		if (ret)
 			goto unlock;
 
-		if (copy_to_user(argp, &ifr, sizeof(ifr)))
+		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
 		goto unlock;
 	}
@@ -1162,7 +1163,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 		if (ret)
 			break;
 
-		if (copy_to_user(argp, &ifr, sizeof(ifr)))
+		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
 		break;
 
@@ -1236,7 +1237,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 		/* Get hw addres */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev->dev_addr, ETH_ALEN);
 		ifr.ifr_hwaddr.sa_family = tun->dev->type;
-		if (copy_to_user(argp, &ifr, sizeof ifr))
+		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
 		break;
 
@@ -1275,6 +1276,43 @@ unlock:
 	return ret;
 }
 
+static long tun_chr_ioctl(struct file *file,
+			  unsigned int cmd, unsigned long arg)
+{
+	return __tun_chr_ioctl(file, cmd, arg, sizeof (struct ifreq));
+}
+
+#ifdef CONFIG_COMPAT
+static long tun_chr_compat_ioctl(struct file *file,
+			 unsigned int cmd, unsigned long arg)
+{
+	int ret;
+
+	switch (cmd) {
+	case TUNSETIFF:
+	case TUNGETIFF:
+	case TUNSETTXFILTER:
+	case TUNGETSNDBUF:
+	case TUNSETSNDBUF:
+	case SIOCGIFHWADDR:
+	case SIOCSIFHWADDR:
+		arg = (unsigned long)compat_ptr(arg);
+		break;
+	default:
+		arg = (compat_ulong_t)arg;
+		break;
+	}
+
+	/*
+	 * compat_ifreq is shorter than ifreq, so we must not access beyond
+	 * the end of that structure. All fields that are used in this
+	 * driver are compatible though, we don't need to convert the
+	 * contents.
+	 */
+	return __tun_chr_ioctl(file, cmd, arg, sizeof(struct compat_ifreq));
+}
+#endif /* CONFIG_COMPAT */
+
 static int tun_chr_fasync(int fd, struct file *file, int on)
 {
 	struct tun_struct *tun = tun_get(file);
@@ -1359,7 +1397,10 @@ static const struct file_operations tun_fops = {
 	.write = do_sync_write,
 	.aio_write = tun_chr_aio_write,
 	.poll	= tun_chr_poll,
-	.unlocked_ioctl = tun_chr_ioctl,
+	.unlocked_ioctl	= tun_chr_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl = tun_chr_compat_ioctl,
+#endif
 	.open	= tun_chr_open,
 	.release = tun_chr_close,
 	.fasync = tun_chr_fasync
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index f91fd51..c562e9a 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -539,12 +539,6 @@ static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 	set_fs (old_fs);
 	if (!err) {
 		switch (cmd) {
-		/* TUNSETIFF is defined as _IOW, it should be _IORW
-		 * as the data is copied back to user space, but that
-		 * cannot be fixed without breaking all existing apps.
-		 */
-		case TUNSETIFF:
-		case TUNGETIFF:
 		case SIOCGIFFLAGS:
 		case SIOCGIFMETRIC:
 		case SIOCGIFMTU:
@@ -1979,18 +1973,6 @@ COMPATIBLE_IOCTL(SCSI_IOCTL_SEND_COMMAND)
 COMPATIBLE_IOCTL(SCSI_IOCTL_PROBE_HOST)
 COMPATIBLE_IOCTL(SCSI_IOCTL_GET_PCI)
 #endif
-/* Big T */
-COMPATIBLE_IOCTL(TUNSETNOCSUM)
-COMPATIBLE_IOCTL(TUNSETDEBUG)
-COMPATIBLE_IOCTL(TUNSETPERSIST)
-COMPATIBLE_IOCTL(TUNSETOWNER)
-COMPATIBLE_IOCTL(TUNSETLINK)
-COMPATIBLE_IOCTL(TUNSETGROUP)
-COMPATIBLE_IOCTL(TUNGETFEATURES)
-COMPATIBLE_IOCTL(TUNSETOFFLOAD)
-COMPATIBLE_IOCTL(TUNSETTXFILTER)
-COMPATIBLE_IOCTL(TUNGETSNDBUF)
-COMPATIBLE_IOCTL(TUNSETSNDBUF)
 /* Big V */
 COMPATIBLE_IOCTL(VT_SETMODE)
 COMPATIBLE_IOCTL(VT_GETMODE)
@@ -2571,8 +2553,6 @@ HANDLE_IOCTL(SIOCSIFPFLAGS, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFPFLAGS, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFTXQLEN, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFTXQLEN, dev_ifsioc)
-HANDLE_IOCTL(TUNSETIFF, dev_ifsioc)
-HANDLE_IOCTL(TUNGETIFF, dev_ifsioc)
 HANDLE_IOCTL(SIOCETHTOOL, ethtool_ioctl)
 HANDLE_IOCTL(SIOCBONDENSLAVE, bond_ioctl)
 HANDLE_IOCTL(SIOCBONDRELEASE, bond_ioctl)
-- 
1.6.3.3

