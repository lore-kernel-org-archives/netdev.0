From: Nathaniel Case <ncase@xes-inc.com>
Subject: [PATCH 0/2] PHYLIB: Fix forcing mode reduction
Date: Mon, 05 Jun 2006 18:45:58 -0500
Message-ID: <1149551159.10700.46.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:1199 "EHLO xes-mad.com")
	by vger.kernel.org with ESMTP id S1750833AbWFEXqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:46:01 -0400
To: Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-05 at 17:08 -0500, Andy Fleming wrote:
> Looks good.  Feel free to send these patches to  
> netdev@vger.kernel.org (you may need to subscribe), and copy Jeff  
> Garzik <jeff@garzik.org>.

This fixes a problem seen when a port without a cable connected would
repeatedly print out "Trying 1000/HALF".  While in the PHY_FORCING
state, the call to phy_read_status() was resetting the value of
phydev->speed and phydev->duplex, preventing it from incrementally
trying the speed/duplex variations.

Since we really just want the link status updated for the PHY_FORCING
state, calling genphy_update_link() instead of phy_read_status() fixes
this issue.

Patch tested on a MPC8540 platform with a BCM5421 PHY.

Signed-off-by: Nate Case <ncase@xes-inc.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>

---

--- a/drivers/net/phy/phy.c	2006-06-04 16:01:59.000000000 -0500
+++ b/drivers/net/phy/phy.c	2006-06-05 10:55:31.000000000 -0500
@@ -767,7 +783,7 @@
 			}
 			break;
 		case PHY_FORCING:
-			err = phy_read_status(phydev);
+			err = genphy_update_link(phydev);
 
 			if (err)
 				break;
--- a/drivers/net/phy/phy_device.c	2006-06-04 16:02:08.000000000 -0500
+++ b/drivers/net/phy/phy_device.c	2006-06-04 19:12:26.000000000 -0500
@@ -417,6 +417,7 @@
 
 	return 0;
 }
+EXPORT_SYMBOL(genphy_update_link);
 
 /* genphy_read_status
  *


