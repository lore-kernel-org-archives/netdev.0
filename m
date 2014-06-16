From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH tty-next 15/22] isdn: tty: Use private flag for ASYNC_CLOSING
Date: Mon, 16 Jun 2014 09:17:12 -0400
Message-ID: <1402924639-5164-16-git-send-email-peter@hurleysoftware.com>
References: <1402924639-5164-1-git-send-email-peter@hurleysoftware.com>
Cc: linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Peter Hurley <peter@hurleysoftware.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402924639-5164-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ASYNC_CLOSING is no longer used in the tty core; use private flag
info->closing as substitute.

CC: Karsten Keil <isdn@linux-pingi.de>
CC: netdev@vger.kernel.org
Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/isdn/i4l/isdn_tty.c | 14 +++++++-------
 include/linux/isdn.h        |  1 +
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 732f68a..5310932 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1577,8 +1577,7 @@ isdn_tty_close(struct tty_struct *tty, struct file *filp)
 #endif
 		return;
 	}
-	port->flags |= ASYNC_CLOSING;
-
+	info->closing = 1;
 	tty->closing = 1;
 	/*
 	 * At this point we stop accepting input.  To do this, we
@@ -1606,6 +1605,7 @@ isdn_tty_close(struct tty_struct *tty, struct file *filp)
 	tty_ldisc_flush(tty);
 	port->tty = NULL;
 	info->ncarrier = 0;
+	info->closing = 0;
 
 	tty_port_close_end(port, tty);
 #ifdef ISDN_DEBUG_MODEM_OPEN
@@ -1806,6 +1806,7 @@ isdn_tty_modem_init(void)
 		spin_lock_init(&info->readlock);
 		sprintf(info->last_cause, "0000");
 		sprintf(info->last_num, "none");
+		info->closing = 0;
 		info->last_dir = 0;
 		info->last_lhup = 1;
 		info->last_l2 = -1;
@@ -2241,7 +2242,7 @@ isdn_tty_at_cout(char *msg, modem_info *info)
 	l = strlen(msg);
 
 	spin_lock_irqsave(&info->readlock, flags);
-	if (port->flags & ASYNC_CLOSING) {
+	if (info->closing) {
 		spin_unlock_irqrestore(&info->readlock, flags);
 		return;
 	}
@@ -2391,13 +2392,12 @@ isdn_tty_modem_result(int code, modem_info *info)
 	case RESULT_NO_CARRIER:
 #ifdef ISDN_DEBUG_MODEM_HUP
 		printk(KERN_DEBUG "modem_result: NO CARRIER %d %d\n",
-		       (info->port.flags & ASYNC_CLOSING),
-		       (!info->port.tty));
+		       info->closing, (!info->port.tty));
 #endif
 		m->mdmreg[REG_RINGCNT] = 0;
 		del_timer(&info->nc_timer);
 		info->ncarrier = 0;
-		if ((info->port.flags & ASYNC_CLOSING) || (!info->port.tty))
+		if (info->closing || (!info->port.tty))
 			return;
 
 #ifdef CONFIG_ISDN_AUDIO
@@ -2530,7 +2530,7 @@ isdn_tty_modem_result(int code, modem_info *info)
 		}
 	}
 	if (code == RESULT_NO_CARRIER) {
-		if ((info->port.flags & ASYNC_CLOSING) || (!info->port.tty))
+		if (info->closing || (!info->port.tty))
 			return;
 
 		if (info->port.flags & ASYNC_CHECK_CD)
diff --git a/include/linux/isdn.h b/include/linux/isdn.h
index 1e9a0f2..fe80475 100644
--- a/include/linux/isdn.h
+++ b/include/linux/isdn.h
@@ -311,6 +311,7 @@ typedef struct atemu {
 typedef struct modem_info {
   int			magic;
   struct tty_port	port;
+  int			closing:1;	 /* port count has dropped to 0    */
   int			x_char;		 /* xon/xoff character             */
   int			mcr;		 /* Modem control register         */
   int                   msr;             /* Modem status register          */
-- 
2.0.0
