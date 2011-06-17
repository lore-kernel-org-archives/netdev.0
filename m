From: Pavel Shved <shved@ispras.ru>
Subject: [PATCH] gigaset: call module_put before restart of if_open()
Date: Fri, 17 Jun 2011 20:25:11 +0400
Message-ID: <1308327913-23220-2-git-send-email-shved@ispras.ru>
References: <1308327913-23220-1-git-send-email-shved@ispras.ru>
Cc: Pavel Shved <shved@ispras.ru>,
	Tilman Schmidt <tilman@imap.cc> (maintainer:GIGASET ISDN DRIVERS),
	Karsten Keil <isdn@linux-pingi.de> (maintainer:ISDN SUBSYSTEM),
	gigaset307x-common@lists.sourceforge.net (open list:GIGASET ISDN
	DRIVERS), netdev@vger.kernel.org (open list:ISDN SUBSYSTEM),
	linux-kernel@vger.kernel.org (open list), ldv-project@ispras.ru
To: Hansjoerg Lipp <hjlipp@web.de> (maintainer:GIGASET ISDN DRIVERS)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ispras.ru ([83.149.198.202]:56032 "EHLO smtp.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756090Ab1FQQ47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 12:56:59 -0400
In-Reply-To: <1308327913-23220-1-git-send-email-shved@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if_open() calls try_module_get(), and after an attempt to lock a mutex
the if_open() function may return -ERESTARTSYS without
putting the module.  Then, when if_open() is executed again,
try_module_get() is called making the reference counter of THIS_MODULE
greater than one at successful exit from if_open().  The if_close()
function puts the module only once, and as a result it can't be
unloaded.

This patch adds module_put call before the return from if_open().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Pavel Shved <shved@ispras.ru>
---
 drivers/isdn/gigaset/interface.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 59de638..e35058b 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -156,8 +156,10 @@ static int if_open(struct tty_struct *tty, struct file *filp)
 	if (!cs || !try_module_get(cs->driver->owner))
 		return -ENODEV;
 
-	if (mutex_lock_interruptible(&cs->mutex))
+	if (mutex_lock_interruptible(&cs->mutex)) {
+		module_put(cs->driver->owner);
 		return -ERESTARTSYS;
+	}
 	tty->driver_data = cs;
 
 	++cs->open_count;
-- 
1.7.0.2

