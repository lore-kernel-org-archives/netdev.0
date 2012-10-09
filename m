From: Thomas Petazzoni <thomas.petazzoni@enix.org>
Subject: Using phylib with a MAC-handled interrupt
Date: Tue, 9 Oct 2012 18:17:27 +0200
Message-ID: <20121009181727.1845ab85@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Maen Suleiman <maen@marvell.com>
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.enix.org ([193.19.211.146]:56859 "EHLO smtp.enix.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131Ab2JIQXA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 12:23:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andy,

I am currently working on a network driver for the MAC present in the
latest Marvell ARM SoCs. This MAC is capable of polling the PHY in
hardware, which avoids the need for Linux to poll the PHY regularly.

Therefore, I am currently trying to do an integration of the driver wit=
h
the phylib using the third solution you listed at
http://lists.openwall.net/netdev/2008/06/06/38.

Unfortunately, with the current Linux kernel, the phylib continues to
poll the PHY registers regularly even if phydev->irq is set to
PHY_IGNORE_INTERRUPT. This is due to the fact that the phylib code
override phydev->irq to be PHY_POLL whenever the PHY driver doesn't
support interrupt, which isn't correct. This is fixed by the below
patch.

However, even with the below patch, I cannot implement your solution
three described in http://lists.openwall.net/netdev/2008/06/06/38 :
taking a mutex in an interrupt handler is not possible. Therefore, I
cannot change the phydev->state field from my MAC driver to force the
PHY state machine to re-read the status of the PHY.

I tried to force the execution of the phydev->phy_queue workqueue, but
unfortunately, simply calling schedule_work(&phydev->phy_queue)
from my interrupt handler causes problems:

WARNING: at /home/thomas/projets/linux-2.6/kernel/workqueue.c:1033 __qu=
eue_work+0x1c0/0x1d8()

This is apparently because schedule_work() doesn't like when the
workqueue is already scheduled for execution, but I am not sure how to
properly handle this case.

What I would like to do is from my MAC interrupt handler, tell the
phylib "hey, something has changed, you should re-read the PHY
registers and if needed call my ->adjust_link() callback".

How can I do that with the phylib?

Thanks,

Thomas

=46rom 3eae62a1adb08229ea4d20068ef868b731b020cb Mon Sep 17 00:00:00 200=
1
=46rom: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue, 9 Oct 2012 18:10:21 +0200
Subject: [PATCH] net: phy: fix support of PHY_IGNORE_INTERRUPT

When PHY_IGNORE_INTERRUPT is set as the phydev->irq, then the phylib
shouldn't poll the PHY regularly, but instead let the MAC driver tell
the phylib when to re-read the PHY status. Unfortunately, as soon as
the PHY didn't had PHY_HAS_INTERRUPT set, the phylib was forcing
PHY_POLL as the interrupt.

Also fix two other places that test against PHY_POLL while they should
instead be testing if we have an IRQ or not.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/phy/phy.c        |    4 ++--
 drivers/net/phy/phy_device.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7ca2ff9..a1d265f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -709,7 +709,7 @@ void phy_stop(struct phy_device *phydev)
 	if (PHY_HALTED =3D=3D phydev->state)
 		goto out_unlock;
=20
-	if (phydev->irq !=3D PHY_POLL) {
+	if (phydev->irq > 0) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
=20
@@ -896,7 +896,7 @@ void phy_state_machine(struct work_struct *work)
=20
 			phydev->adjust_link(phydev->attached_dev);
=20
-			if (PHY_POLL !=3D phydev->irq)
+			if (phydev->irq > 0)
 				err =3D phy_config_interrupt(phydev,
 						PHY_INTERRUPT_ENABLED);
 			break;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.=
c
index 8af46e8..110b3a3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1011,7 +1011,7 @@ static int phy_probe(struct device *dev)
 	phydev->drv =3D phydrv;
=20
 	/* Disable the interrupt if the PHY doesn't support it */
-	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
+	if (!(phydrv->flags & PHY_HAS_INTERRUPT) && phydev->irq > 0)
 		phydev->irq =3D PHY_POLL;
=20
 	mutex_lock(&phydev->lock);
--=20
1.7.9.5


--=20
Thomas Petazzoni                http://thomas.enix.org
MapOSMatic                      http://www.maposmatic.org
Logiciels Libres =C3=A0 Toulouse     http://www.toulibre.org
Embedded Linux                  http://www.free-electrons.com
