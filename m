From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 13/18] i4l: kill big kernel lock
Date: Tue, 14 Sep 2010 21:35:04 +0200
Message-ID: <1284492909-7147-14-git-send-email-arnd@arndb.de>
References: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56107 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab0INTfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 15:35:37 -0400
In-Reply-To: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The isdn4linux driver uses the big kernel lock only
to serialize access to a few fields in its own
modem_info structure.

The easiest replacement is a driver-wide mutex.
More fine-grained locking would be more appropriate
here, but likely harder to implement.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/i4l/isdn_tty.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 51dc60d..981f7ab 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -14,7 +14,7 @@
 #include <linux/isdn.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
-#include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include "isdn_common.h"
 #include "isdn_tty.h"
 #ifdef CONFIG_ISDN_AUDIO
@@ -28,6 +28,7 @@
 
 /* Prototypes */
 
+static DEFINE_MUTEX(modem_info_mutex);
 static int isdn_tty_edit_at(const char *, int, modem_info *);
 static void isdn_tty_check_esc(const u_char *, u_char, int, int *, u_long *);
 static void isdn_tty_modem_reset_regs(modem_info *, int);
@@ -1354,14 +1355,14 @@ isdn_tty_tiocmget(struct tty_struct *tty, struct file *file)
 	if (tty->flags & (1 << TTY_IO_ERROR))
 		return -EIO;
 
-	lock_kernel();
+	mutex_lock(&modem_info_mutex);
 #ifdef ISDN_DEBUG_MODEM_IOCTL
 	printk(KERN_DEBUG "ttyI%d ioctl TIOCMGET\n", info->line);
 #endif
 
 	control = info->mcr;
 	status = info->msr;
-	unlock_kernel();
+	mutex_unlock(&modem_info_mutex);
 	return ((control & UART_MCR_RTS) ? TIOCM_RTS : 0)
 	    | ((control & UART_MCR_DTR) ? TIOCM_DTR : 0)
 	    | ((status & UART_MSR_DCD) ? TIOCM_CAR : 0)
@@ -1385,7 +1386,7 @@ isdn_tty_tiocmset(struct tty_struct *tty, struct file *file,
 	printk(KERN_DEBUG "ttyI%d ioctl TIOCMxxx: %x %x\n", info->line, set, clear);
 #endif
 
-	lock_kernel();
+	mutex_lock(&modem_info_mutex);
 	if (set & TIOCM_RTS)
 		info->mcr |= UART_MCR_RTS;
 	if (set & TIOCM_DTR) {
@@ -1407,7 +1408,7 @@ isdn_tty_tiocmset(struct tty_struct *tty, struct file *file,
 			isdn_tty_modem_hup(info, 1);
 		}
 	}
-	unlock_kernel();
+	mutex_unlock(&modem_info_mutex);
 	return 0;
 }
 
-- 
1.7.1

