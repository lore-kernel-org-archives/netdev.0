From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e100: fix 10sec DHCP delay (regression for 82559ER)
Date: Fri, 23 Oct 2009 14:45:49 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A903B165929@orsmsx509.amr.corp.intel.com>
References: <4ADF6F15.5040301@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bernhard Kaindl <bernhard.kaindl@gmx.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37843 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbZJWVpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 17:45:46 -0400
In-Reply-To: <4ADF6F15.5040301@gmx.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After further testing, this introduces a problem on 82552 parts where it no longer autonegs to 100Full.  I've created a different patch that reverts my code put in to 2.6.30 which isolates all PHY ids (which causes the problem discovered by Bernhard) yet still works around the problem on 82552.  It is currently queued up for testing here at Intel and will be pushed to netdev in the next few days.

>-----Original Message-----
>From: Bernhard Kaindl [mailto:bernhard.kaindl@gmx.net]
>Sent: Wednesday, October 21, 2009 1:29 PM
>To: David S. Miller
>Cc: Allan, Bruce W; netdev@vger.kernel.org
>Subject: [PATCH] e100: fix 10sec DHCP delay (regression for 82559ER)
>
>From: Bernhard Kaindl <bernhard.kaindl@gmx.net>
>
>With 2.6.30, we noticed a regression on our Intel 82559ER-equipped
>boards regarding the PHY initialization. The Intel 82559ER uses an
>internal PHY bus, so our PHY environment should be not be very special.
>
>The symptom which we observed on these boards was that the boot-time
>DHCP negotiation was stalled for ~5secs and went very slowly until
>it was finally completed after ~10secs after initial interface start.
>
>I reported our finding along with a proposal for a fix to netdev and
>Bruce Allan@Intel, whose patch to support the new Intel 82552 adapter
>included a workaround for the 82552 with this side effect for our env.
>
>Bruce worked on a way to have both environments working and tested
>it on as many 10/100 parts he could get his hands on and started
>a process which allows for more testing and patch submission from
>
>So pending this process which allows for more testing at Intel, I am
>submitting our common patch. For PHYs other than the 82552, it resembles
>mostly how 2.6.23-2.6.29 have been selecting and isolating the PHYs.
>
>This patch applies to 2.6.30.9, 2.6.31.4 and 2.6.32-rc5-git1 and is
>essentially what Bruce has been testing:
>
>Signed-off-by: Bernhard Kaindl <bernhard.kaindl@gmx.net>
>Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>---
>
>  drivers/net/e100.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>index 5d2f48f..aed18a4 100644
>--- a/drivers/net/e100.c
>+++ b/drivers/net/e100.c
>@@ -1427,13 +1427,17 @@ static int e100_phy_init(struct nic *nic)
>  	} else
>  		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
>
>-	/* Isolate all the PHY ids */
>-	for (addr = 0; addr < 32; addr++)
>-		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
>  	/* Select the discovered PHY */
>  	bmcr &= ~BMCR_ISOLATE;
>  	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);
>
>+	if (nic->phy != phy_82552_v) {
>+		/* Isolate the unused PHY ids */
>+		for (addr = 0; addr < 32; addr++)
>+			if (addr != nic->mii.phy_id)
>+				mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
>+	}
>+
>  	/* Get phy ID */
>  	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
>  	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
