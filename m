From: Bernhard Kaindl <bernhard.kaindl@gmx.net>
Subject: [PATCH] e100: fix 10sec DHCP delay (regression for 82559ER)
Date: Wed, 21 Oct 2009 22:29:09 +0200
Message-ID: <4ADF6F15.5040301@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:40602 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbZJUU3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 16:29:09 -0400
Received: by fxm18 with SMTP id 18so8216281fxm.37
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 13:29:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Kaindl <bernhard.kaindl@gmx.net>

With 2.6.30, we noticed a regression on our Intel 82559ER-equipped
boards regarding the PHY initialization. The Intel 82559ER uses an
internal PHY bus, so our PHY environment should be not be very special.

The symptom which we observed on these boards was that the boot-time
DHCP negotiation was stalled for ~5secs and went very slowly until
it was finally completed after ~10secs after initial interface start.

I reported our finding along with a proposal for a fix to netdev and
Bruce Allan@Intel, whose patch to support the new Intel 82552 adapter
included a workaround for the 82552 with this side effect for our env.

Bruce worked on a way to have both environments working and tested
it on as many 10/100 parts he could get his hands on and started
a process which allows for more testing and patch submission from

So pending this process which allows for more testing at Intel, I am
submitting our common patch. For PHYs other than the 82552, it resembles
mostly how 2.6.23-2.6.29 have been selecting and isolating the PHYs.

This patch applies to 2.6.30.9, 2.6.31.4 and 2.6.32-rc5-git1 and is
essentially what Bruce has been testing:

Signed-off-by: Bernhard Kaindl <bernhard.kaindl@gmx.net>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

  drivers/net/e100.c |   10 +++++++---
  1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 5d2f48f..aed18a4 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1427,13 +1427,17 @@ static int e100_phy_init(struct nic *nic)
  	} else
  		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);

-	/* Isolate all the PHY ids */
-	for (addr = 0; addr < 32; addr++)
-		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
  	/* Select the discovered PHY */
  	bmcr &= ~BMCR_ISOLATE;
  	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);

+	if (nic->phy != phy_82552_v) {
+		/* Isolate the unused PHY ids */
+		for (addr = 0; addr < 32; addr++)
+			if (addr != nic->mii.phy_id)
+				mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
+	}
+
  	/* Get phy ID */
  	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
  	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
