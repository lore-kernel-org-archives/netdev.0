From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Tue, 31 Aug 2010 01:15:33 +0100
Message-ID: <1283213733.7653.180.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59440 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab0HaAPk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 20:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vortex_ioctl() was grabbing vortex_private::lock around its call to
generic_mii_ioctl().  This is no longer necessary since there are more
specific locks which the mdio_{read,write}() functions will obtain.
Worse, those functions do not save and restore IRQ flags when locking
the MII state, so interrupts will be enabled when generic_mii_ioctl()
returns.

Since there is currently no need for any function to call
mdio_{read,write}() while holding another spinlock, do not change them
to save and restore IRQ flags but remove the specification of ordering
between vortex_private::lock and vortex_private::mii_lock.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I've now borrowed a card to test 3c59x on.  I've seen another regression
reported <http://bugs.debian.org/586967> after my locking changes, which
I can't reproduce.

Ben.

 drivers/net/3c59x.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c685a55..a045559 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -647,7 +647,7 @@ struct vortex_private {
 	u16 io_size;						/* Size of PCI region (for release_region) */
 
 	/* Serialises access to hardware other than MII and variables below.
-	 * The lock hierarchy is rtnl_lock > lock > mii_lock > window_lock. */
+	 * The lock hierarchy is rtnl_lock > {lock, mii_lock} > window_lock. */
 	spinlock_t lock;
 
 	spinlock_t mii_lock;		/* Serialises access to MII */
@@ -2984,7 +2984,6 @@ static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	int err;
 	struct vortex_private *vp = netdev_priv(dev);
-	unsigned long flags;
 	pci_power_t state = 0;
 
 	if(VORTEX_PCI(vp))
@@ -2994,9 +2993,7 @@ static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	if(state != 0)
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);
-	spin_lock_irqsave(&vp->lock, flags);
 	err = generic_mii_ioctl(&vp->mii, if_mii(rq), cmd, NULL);
-	spin_unlock_irqrestore(&vp->lock, flags);
 	if(state != 0)
 		pci_set_power_state(VORTEX_PCI(vp), state);
 
-- 
1.7.1


