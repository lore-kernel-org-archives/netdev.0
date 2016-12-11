From: Thomas Gleixner <tglx@linutronix.de>
Subject: net/3com/3c515: Fix timer handling, prevent leaks and crashes
Date: Sun, 11 Dec 2016 18:31:22 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1612111826310.18281@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, Matthew Whitehead <tedheadster@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        David Miller <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The timer handling in this driver is broken in several ways:

- corkscrew_open() initializes and arms a timer before requesting the
  device interrupt. If the request fails the timer stays armed.

  A second call to corkscrew_open will unconditionally reinitialize the
  quued timer and arm it again. Also a immediate device removal will leave
  the timer queued because close() is not called (open() failed) and
  therefore nothing issues del_timer().

  The reinitialization corrupts the link chain in the timer wheel hash
  bucket and causes a NULL pointer dereference when the timer wheel tries
  to operate on that hash bucket. Immediate device removal lets the link
  chain poke into freed and possibly reused memory.

  Solution: Arm the timer after the successful irq request.

- corkscrew_close() uses del_timer()

  On close the timer is disarmed with del_timer() which lets the following
  code race against a concurrent timer expiry function.

  Solution: Use del_timer_sync() instead

- corkscrew_close() calls del_timer() unconditionally

  del_timer() is invoked even if the timer was never initialized. This
  works by chance because the struct containing the timer is zeroed at
  allocation time.

  Solution: Move the setup of the timer into corkscrew_setup().

Reported-by: Matthew Whitehead <tedheadster@gmail.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/3com/3c515.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -628,6 +628,8 @@ static int corkscrew_setup(struct net_de
 
 	spin_lock_init(&vp->lock);
 
+	setup_timer(&vp->timer, corkscrew_timer, (unsigned long) dev);
+
 	/* Read the station address from the EEPROM. */
 	EL3WINDOW(0);
 	for (i = 0; i < 0x18; i++) {
@@ -708,6 +710,7 @@ static int corkscrew_open(struct net_dev
 {
 	int ioaddr = dev->base_addr;
 	struct corkscrew_private *vp = netdev_priv(dev);
+	bool armtimer = false;
 	__u32 config;
 	int i;
 
@@ -732,12 +735,7 @@ static int corkscrew_open(struct net_dev
 		if (corkscrew_debug > 1)
 			pr_debug("%s: Initial media type %s.\n",
 			       dev->name, media_tbl[dev->if_port].name);
-
-		init_timer(&vp->timer);
-		vp->timer.expires = jiffies + media_tbl[dev->if_port].wait;
-		vp->timer.data = (unsigned long) dev;
-		vp->timer.function = corkscrew_timer;	/* timer handler */
-		add_timer(&vp->timer);
+		armtimer = true;
 	} else
 		dev->if_port = vp->default_media;
 
@@ -777,6 +775,9 @@ static int corkscrew_open(struct net_dev
 		return -EAGAIN;
 	}
 
+	if (armtimer)
+		mod_timer(&vp->timer, jiffies + media_tbl[dev->if_port].wait);
+
 	if (corkscrew_debug > 1) {
 		EL3WINDOW(4);
 		pr_debug("%s: corkscrew_open() irq %d media status %4.4x.\n",
@@ -1427,7 +1428,7 @@ static int corkscrew_close(struct net_de
 			dev->name, rx_nocopy, rx_copy, queued_packet);
 	}
 
-	del_timer(&vp->timer);
+	del_timer_sync(&vp->timer);
 
 	/* Turn off statistics ASAP.  We update lp->stats below. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
