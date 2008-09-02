From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 3/4] drivers/net/atl1e/: don't take the mdio_lock in atl1e_probe
Date: Tue, 02 Sep 2008 14:48:19 -0700
Message-ID: <200809022148.m82LmJs9014381@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, matthew@wil.cx,
	jie.yang@atheros.com, willy@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40499 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753089AbYIBVzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 17:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Wilcox <matthew@wil.cx>

Lockdep warns about the mdio_lock taken with interrupts enabled then later
taken from interrupt context.  Initially, I considered changing these to
spin_lock_irq/spin_unlock_irq, but then I looked at atl1e_phy_init() and
saw that it calls msleep().  Sleeping while holding a spinlock is not
allowed either.

In the probe path, we haven't registered the interrupt handler, so it
can't poke at this card yet.  It's before we call register_netdev(), so I
don't think any other threads can reach this card either.  If I'm right,
we don't need a spinlock at all.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Acked-by: Jie Yang <jie.yang@atheros.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atl1e/atl1e_main.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/atl1e/atl1e_main.c~drivers-net-atl1e-dont-take-the-mdio_lock-in-atl1e_probe drivers/net/atl1e/atl1e_main.c
--- a/drivers/net/atl1e/atl1e_main.c~drivers-net-atl1e-dont-take-the-mdio_lock-in-atl1e_probe
+++ a/drivers/net/atl1e/atl1e_main.c
@@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct 
 	}
 
 	/* Init GPHY as early as possible due to power saving issue  */
-	spin_lock(&adapter->mdio_lock);
 	atl1e_phy_init(&adapter->hw);
-	spin_unlock(&adapter->mdio_lock);
 	/* reset the controller to
 	 * put the device in a known good starting state */
 	err = atl1e_reset_hw(&adapter->hw);
_
