From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/7] net, compat_ioctl: handle socket ioctl abuses in tty drivers
Date: Fri,  6 Nov 2009 19:09:05 +0100
Message-ID: <1257530949-9695-4-git-send-email-arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50925 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376AbZKFSJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 13:09:14 -0500
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Slip and a few other drivers use the same ioctl numbers on
tty devices that are normally meant for sockets. This causes
problems with our compat_ioctl handling that tries to convert
the data structures in a different format.

Fortunately, these five drivers all use 32 bit compatible
data structures in the ioctl numbers, so we can just add
a trivial compat_ioctl conversion function to each of them.

SIOCSIFENCAP and SIOCGIFENCAP do not need to live in
fs/compat_ioctl.c after this any more, and they are not
used on any sockets.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/hamradio/6pack.c |   16 ++++++++++++++++
 drivers/net/hamradio/mkiss.c |   16 ++++++++++++++++
 drivers/net/slip.c           |   21 +++++++++++++++++++++
 drivers/net/wan/x25_asy.c    |   15 +++++++++++++++
 drivers/net/wireless/strip.c |   12 ++++++++++++
 fs/compat_ioctl.c            |    2 --
 6 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index fb58830..d75a551 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -777,6 +777,21 @@ static int sixpack_ioctl(struct tty_struct *tty, struct file *file,
 	return err;
 }
 
+static long sixpack_compat_ioctl(struct tty_struct * tty, struct file * file,
+				unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCGIFNAME:
+	case SIOCGIFENCAP:
+	case SIOCSIFENCAP:
+	case SIOCSIFHWADDR:
+		return sixpack_ioctl(tty, file, cmd,
+				(unsigned long)compat_ptr(arg));
+	}
+
+	return -ENOIOCTLCMD;
+}
+
 static struct tty_ldisc_ops sp_ldisc = {
 	.owner		= THIS_MODULE,
 	.magic		= TTY_LDISC_MAGIC,
@@ -784,6 +799,7 @@ static struct tty_ldisc_ops sp_ldisc = {
 	.open		= sixpack_open,
 	.close		= sixpack_close,
 	.ioctl		= sixpack_ioctl,
+	.compat_ioctl	= sixpack_compat_ioctl,
 	.receive_buf	= sixpack_receive_buf,
 	.write_wakeup	= sixpack_write_wakeup,
 };
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index db4b7f1..15020ec 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -898,6 +898,21 @@ static int mkiss_ioctl(struct tty_struct *tty, struct file *file,
 	return err;
 }
 
+static long mkiss_compat_ioctl(struct tty_struct *tty, struct file *file,
+	unsigned int cmd, unsigned long arg)
+{
+	switch (arg) {
+	case SIOCGIFNAME:
+	case SIOCGIFENCAP:
+	case SIOCSIFENCAP:
+	case SIOCSIFHWADDR:
+		return mkiss_ioctl(tty, file, cmd,
+			(unsigned long)compat_ptr(arg));
+	}
+
+	return -ENOIOCTLCMD;
+}
+
 /*
  * Handle the 'receiver data ready' interrupt.
  * This function is called by the 'tty_io' module in the kernel when
@@ -972,6 +987,7 @@ static struct tty_ldisc_ops ax_ldisc = {
 	.open		= mkiss_open,
 	.close		= mkiss_close,
 	.ioctl		= mkiss_ioctl,
+	.compat_ioctl	= mkiss_compat_ioctl,
 	.receive_buf	= mkiss_receive_buf,
 	.write_wakeup	= mkiss_write_wakeup
 };
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index fe3cebb..d9c87e6 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -1169,6 +1169,26 @@ static int slip_ioctl(struct tty_struct *tty, struct file *file,
 	}
 }
 
+static long slip_compat_ioctl(struct tty_struct *tty, struct file *file,
+					unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCGIFNAME:
+	case SIOCGIFENCAP:
+	case SIOCSIFENCAP:
+	case SIOCSIFHWADDR:
+	case SIOCSKEEPALIVE:
+	case SIOCGKEEPALIVE:
+	case SIOCSOUTFILL:
+	case SIOCGOUTFILL:
+		return slip_ioctl(tty, file, cmd,
+			(unsigned long)compat_ptr(arg));
+	}
+
+	return -ENOIOCTLCMD;
+}
+
+
 /* VSV changes start here */
 #ifdef CONFIG_SLIP_SMART
 /* function do_ioctl called from net/core/dev.c
@@ -1261,6 +1281,7 @@ static struct tty_ldisc_ops sl_ldisc = {
 	.close	 	= slip_close,
 	.hangup	 	= slip_hangup,
 	.ioctl		= slip_ioctl,
+	.compat_ioctl	= slip_compat_ioctl,
 	.receive_buf	= slip_receive_buf,
 	.write_wakeup	= slip_write_wakeup,
 };
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 2794504..266e984 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -705,6 +705,20 @@ static int x25_asy_ioctl(struct tty_struct *tty, struct file *file,
 	}
 }
 
+static long x25_asy_compat_ioctl(struct tty_struct *tty, struct file *file,
+			 unsigned int cmd,  unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCGIFNAME:
+	case SIOCSIFHWADDR:
+		return x25_asy_ioctl(tty, file, cmd,
+			(unsigned long)compat_ptr(arg);
+	}
+
+	return -ENOIOCTLCMD;
+}
+
+
 static int x25_asy_open_dev(struct net_device *dev)
 {
 	struct x25_asy *sl = netdev_priv(dev);
@@ -754,6 +768,7 @@ static struct tty_ldisc_ops x25_ldisc = {
 	.open		= x25_asy_open_tty,
 	.close		= x25_asy_close_tty,
 	.ioctl		= x25_asy_ioctl,
+	.compat_ioctl	= x25_asy_compat_ioctl,
 	.receive_buf	= x25_asy_receive_buf,
 	.write_wakeup	= x25_asy_write_wakeup,
 };
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index ea6a87c..6673ce9 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -2725,6 +2725,18 @@ static int strip_ioctl(struct tty_struct *tty, struct file *file,
 	return 0;
 }
 
+static long strip_compat_ioctl(struct tty_struct *tty, struct file *file,
+		       unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCGIFNAME:
+	case SIOCSIFHWADDR:
+		return strip_ioctl(tty, file, cmd,
+			(unsigned long)compat_ptr(arg));
+	}
+	return -ENOIOCTLCMD;
+}
+
 
 /************************************************************************/
 /* Initialization							*/
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index c562e9a..f4a5a01 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2020,8 +2020,6 @@ COMPATIBLE_IOCTL(FIOGETOWN)
 COMPATIBLE_IOCTL(SIOCGPGRP)
 COMPATIBLE_IOCTL(SIOCATMARK)
 COMPATIBLE_IOCTL(SIOCSIFLINK)
-COMPATIBLE_IOCTL(SIOCSIFENCAP)
-COMPATIBLE_IOCTL(SIOCGIFENCAP)
 COMPATIBLE_IOCTL(SIOCSIFNAME)
 COMPATIBLE_IOCTL(SIOCSARP)
 COMPATIBLE_IOCTL(SIOCGARP)
-- 
1.6.3.3

