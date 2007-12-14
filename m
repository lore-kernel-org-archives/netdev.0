From: akpm@linux-foundation.org
Subject: [patch 4/4] PPP synchronous tty: convert dead_sem to completion
Date: Thu, 13 Dec 2007 16:02:37 -0800
Message-ID: <200712140002.lBE02cF7025497@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias.kaehlcke@gmail.com, paulus@samba.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42186 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762736AbXLNACm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:02:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>

PPP synchronous tty channel driver: convert the semaphore dead_sem to a
completion

Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ppp_synctty.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/net/ppp_synctty.c~ppp-synchronous-tty-convert-dead_sem-to-completion drivers/net/ppp_synctty.c
--- a/drivers/net/ppp_synctty.c~ppp-synchronous-tty-convert-dead_sem-to-completion
+++ a/drivers/net/ppp_synctty.c
@@ -42,9 +42,9 @@
 #include <linux/if_ppp.h>
 #include <linux/ppp_channel.h>
 #include <linux/spinlock.h>
+#include <linux/completion.h>
 #include <linux/init.h>
 #include <asm/uaccess.h>
-#include <asm/semaphore.h>
 
 #define PPP_VERSION	"2.4.2"
 
@@ -70,7 +70,7 @@ struct syncppp {
 	struct tasklet_struct tsk;
 
 	atomic_t	refcnt;
-	struct semaphore dead_sem;
+	struct completion dead_cmp;
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 };
 
@@ -195,7 +195,7 @@ static struct syncppp *sp_get(struct tty
 static void sp_put(struct syncppp *ap)
 {
 	if (atomic_dec_and_test(&ap->refcnt))
-		up(&ap->dead_sem);
+		complete(&ap->dead_cmp);
 }
 
 /*
@@ -225,7 +225,7 @@ ppp_sync_open(struct tty_struct *tty)
 	tasklet_init(&ap->tsk, ppp_sync_process, (unsigned long) ap);
 
 	atomic_set(&ap->refcnt, 1);
-	init_MUTEX_LOCKED(&ap->dead_sem);
+	init_completion(&ap->dead_cmp);
 
 	ap->chan.private = ap;
 	ap->chan.ops = &sync_ops;
@@ -273,7 +273,7 @@ ppp_sync_close(struct tty_struct *tty)
 	 * by the time it returns.
 	 */
 	if (!atomic_dec_and_test(&ap->refcnt))
-		down(&ap->dead_sem);
+		wait_for_completion(&ap->dead_cmp);
 	tasklet_kill(&ap->tsk);
 
 	ppp_unregister_channel(&ap->chan);
_
