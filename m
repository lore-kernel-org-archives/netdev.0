From: Greg Alexander <grefgs@galexander.org>
Subject: BMC Tigon 3 (tg3) problem with powering down PHY (tentative PATCH)
Date: Tue, 9 Feb 2010 13:08:07 -0500
Message-ID: <20100209180807.GG23446@goonies.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shed.goonies.be ([64.62.190.177]:34711 "EHLO shed.goonies.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288Ab0BISQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 13:16:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all -

My new Lenovo U150 has a BMC57780 in it. It uses mdio with phylib to
access the PHY.  I am using x86-64 SMP kernel 2.6.32.7.

The device initializes successfully the first time but after ifconfig
down, it will not not re-initialize.  It looks like the phy layer is
attempting to autonegotiate while MII_BMCR is BMCR_PDOWN.

drivers/net/tg3.c:tg3_set_power_state() calls tg3_power_down_phy() which
sets BMCR_PDOWN directly.  But I could not find anything which is
responsible for powering it back up.  tg3_mdio_init() has a comment
indicating that it uses tg3_bmcr_reset() to turn the phy on.  So I
basically cut and pasted that code into tg3_set_power_state(),
conditional on using phylib (because I'm ignorant about other cases).

And that fixed my problem.  Hack-patch below. I'm ignorant as all get out
about this, so hopefully someone else can take this the rest of the way?

Red herrings: genphy_suspend()/genphy_resume() never get called,
(genphy_resume() does not work in this context even if called). Also, the
PHY_RESUMING state is never processed because the tg3.c code calls into
phy_start_aneg() setting it directly to PHY_AN...which also seems to be a
non-issue but maybe it matters to someone in some cases?

Anyways, thanks!  This chip is pretty new but it is already 99% supported
in Linux!  My hat's off to all of you!

- Greg

------------------patch--------------------------
--- tg3.c	2010/02/08 22:08:52
+++ tg3.c	2010/02/09 17:36:05
@@ -2432,6 +2432,12 @@
 		/* Switch out of Vaux if it is a NIC */
 		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
 			tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl, 100);
+		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+			u32 reg;
+			if (tg3_readphy(tp, MII_BMCR, &reg) || (reg & BMCR_PDOWN)) {
+				tg3_bmcr_reset(tp);
+			}
+		}
 
 		return 0;
 
