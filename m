From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Wed, 28 Dec 2011 12:28:39 +0000
Message-ID: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
Cc: netdev@vger.kernel.org, Roger Luethi <rl@hellgate.ch>,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44784 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab1L1MbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 07:31:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Working around problem causing high CPU load and hanging system when
there is alot of network trafic.

It is kind of an ugly way to work around it, but it allows the Soekris
net5501 to have trafic between two of it's NICs without hanging so much
that the watchdog kicks in and does a hard reboot of the system.

There is more info on the problem here:
http://http://lists.soekris.com/pipermail/soekris-tech/2010-October/016889.html

Tested with positive results on two Soekris net5501-70 boxes.

Signed-off-by: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
---
 drivers/net/ethernet/via/via-rhine.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index f34dd99..8c77dcd 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1567,6 +1567,9 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 	int boguscnt = max_interrupt_work;
 	int handled = 0;
 
+	if (!spin_trylock(&rp->lock))
+		return IRQ_RETVAL(handled);
+
 	while ((intr_status = get_intr_status(dev))) {
 		handled = 1;
 
@@ -1616,6 +1619,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 		}
 	}
 
+	spin_unlock(&rp->lock);
+
 	if (debug > 3)
 		netdev_dbg(dev, "exiting interrupt, status=%08x\n",
 			   ioread16(ioaddr + IntrStatus));
-- 
1.7.8
