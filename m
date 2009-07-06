From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: scheduling while atomic
Date: Mon, 6 Jul 2009 16:31:19 +0800
Message-ID: <20090706083119.GA17782@gondor.apana.org.au>
References: <23AED400-6DA5-462F-94F0-BEE34AC08A7A@it-loops.com> <20090627140643.7140f6a9@lxorguk.ukuu.org.uk> <33C7D336-F062-47B3-9033-D3DC465F793C@it-loops.com> <20090706074333.GA17276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Guntsche <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36504 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752721AbZGFIb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 04:31:26 -0400
Content-Disposition: inline
In-Reply-To: <20090706074333.GA17276@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 03:43:33PM +0800, Herbert Xu wrote:
> 
> I think the first backtrace is bogus, this is where the real
> problem is.  So what see here is that on xmit from the network,
> PPP will call pty_write from BH context which eventually leads
> to tty_throttle and the sleep.

Here's the stupidest possible fix for this, changing the mutex
to a spin lock.  We should also revert the other commit that
tried to fix this, a6540f731d506d9e82444cf0020e716613d4c46c as
those unthrottles are really needed (the pty driver is always
in the throttled state, so that's why there are no explicit calls
to throttle).

tty: Use spin lock instead of mutex for throttling

Commit 38db89799bdf11625a831c5af33938dcb11908b6 (tty: throttling
race fix) added a mutex to the throttle/unthrottle paths.  This
broke PPP because the PPP ldisc calls both throttle and unthrottle
from softirq contexts.

Since any tty device that's been used together with PPP has clearly
coped with throttling and unthrottling in softirq contexts, we can
turn the mutex into a spin lock.

The added protection of termios consistency does not appear to be
needed as it stands.  When it is needed, we'll have to redo the
locking, or change the throttle/unthrottle implementation that
needs it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index a3afa0c..3ee1968 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2727,6 +2727,7 @@ void initialize_tty_struct(struct tty_struct *tty,
 	mutex_init(&tty->echo_lock);
 	spin_lock_init(&tty->read_lock);
 	spin_lock_init(&tty->ctrl_lock);
+	spin_lock_init(&tty->throttle_lock);
 	INIT_LIST_HEAD(&tty->tty_files);
 	INIT_WORK(&tty->SAK_work, do_SAK_work);
 
diff --git a/drivers/char/tty_ioctl.c b/drivers/char/tty_ioctl.c
index b24f6c6..3b70a4e 100644
--- a/drivers/char/tty_ioctl.c
+++ b/drivers/char/tty_ioctl.c
@@ -22,6 +22,7 @@
 #include <linux/bitops.h>
 #include <linux/mutex.h>
 #include <linux/smp_lock.h>
+#include <linux/spinlock.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -97,19 +98,18 @@ EXPORT_SYMBOL(tty_driver_flush_buffer);
  *	@tty: terminal
  *
  *	Indicate that a tty should stop transmitting data down the stack.
- *	Takes the termios mutex to protect against parallel throttle/unthrottle
- *	and also to ensure the driver can consistently reference its own
- *	termios data at this point when implementing software flow control.
+ *	Takes the throttle lock to protect against parallel throttle and
+ *	unthrottle.
  */
 
 void tty_throttle(struct tty_struct *tty)
 {
-	mutex_lock(&tty->termios_mutex);
+	spin_lock_bh(&tty->throttle_lock);
 	/* check TTY_THROTTLED first so it indicates our state */
 	if (!test_and_set_bit(TTY_THROTTLED, &tty->flags) &&
 	    tty->ops->throttle)
 		tty->ops->throttle(tty);
-	mutex_unlock(&tty->termios_mutex);
+	spin_unlock_bh(&tty->throttle_lock);
 }
 EXPORT_SYMBOL(tty_throttle);
 
@@ -118,9 +118,8 @@ EXPORT_SYMBOL(tty_throttle);
  *	@tty: terminal
  *
  *	Indicate that a tty may continue transmitting data down the stack.
- *	Takes the termios mutex to protect against parallel throttle/unthrottle
- *	and also to ensure the driver can consistently reference its own
- *	termios data at this point when implementing software flow control.
+ *	Takes the throttle lock to protect against parallel throttle and
+ *	unthrottle.
  *
  *	Drivers should however remember that the stack can issue a throttle,
  *	then change flow control method, then unthrottle.
@@ -128,11 +127,11 @@ EXPORT_SYMBOL(tty_throttle);
 
 void tty_unthrottle(struct tty_struct *tty)
 {
-	mutex_lock(&tty->termios_mutex);
+	spin_lock_bh(&tty->throttle_lock);
 	if (test_and_clear_bit(TTY_THROTTLED, &tty->flags) &&
 	    tty->ops->unthrottle)
 		tty->ops->unthrottle(tty);
-	mutex_unlock(&tty->termios_mutex);
+	spin_unlock_bh(&tty->throttle_lock);
 }
 EXPORT_SYMBOL(tty_unthrottle);
 
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 1488d8c..1dc2d6b 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -233,6 +233,7 @@ struct tty_struct {
 
 	struct mutex termios_mutex;
 	spinlock_t ctrl_lock;
+	spinlock_t throttle_lock;
 	/* Termios values are protected by the termios mutex */
 	struct ktermios *termios, *termios_locked;
 	struct termiox *termiox;	/* May be NULL for unsupported */
diff --git a/include/linux/tty_driver.h b/include/linux/tty_driver.h
index 3566129..c068940 100644
--- a/include/linux/tty_driver.h
+++ b/include/linux/tty_driver.h
@@ -128,7 +128,7 @@
  * 	signal that no more characters should be sent to the tty.
  *
  *	Optional: Always invoke via tty_throttle(), called under the
- *	termios lock.
+ *	throttle lock.
  * 
  * void (*unthrottle)(struct tty_struct * tty);
  *
@@ -137,7 +137,7 @@
  * 	overrunning the input buffers of the line disciplines.
  * 
  *	Optional: Always invoke via tty_unthrottle(), called under the
- *	termios lock.
+ *	throttle lock.
  *
  * void (*stop)(struct tty_struct *tty);
  *

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
