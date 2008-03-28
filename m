From: akpm@linux-foundation.org
Subject: [patch 09/21] forcedeth: power down phy when interface is down
Date: Fri, 28 Mar 2008 14:41:20 -0700
Message-ID: <200803282141.m2SLfKth011825@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	eswierk@arastra.com, aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40292 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756574AbYC1Vl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ed Swierk" <eswierk@arastra.com>

Bring the physical link down when the interface is down by placing the PHY
in power-down state, unless WOL is enabled.  This mirrors the behavior of
other drivers including e1000 and tg3.

Without the patch, ifconfig down leaves the physical link up, which confuses
datacenter users who expect the link lights both on the NIC and the switch to
go out when they bring an interface down.

Furthermore, even though the phy is powered on, autonegotiation stops working,
so a normally gigabit link might suddenly become 100 Mbit half-duplex when the
interface goes down, and become gigabit when it comes up again.

Ayaz said:

  I would not include this patch until further testing is performed.  NVIDIA
  MCP chips use 3rd party PHY vendors.  By powering down the phy, it could
  have adverse affects on certain phys.

Signed-off-by: Ed Swierk <eswierk@arastra.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-down drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-down
+++ a/drivers/net/forcedeth.c
@@ -1344,9 +1344,9 @@ static int phy_init(struct net_device *d
 	/* some phys clear out pause advertisment on reset, set it back */
 	mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);
 
-	/* restart auto negotiation */
+	/* restart auto negotiation, power down phy */
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
-	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
+	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE | BMCR_PDOWN);
 	if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
 		return PHY_ERROR;
 	}
@@ -4930,6 +4930,10 @@ static int nv_open(struct net_device *de
 
 	dprintk(KERN_DEBUG "nv_open: begin\n");
 
+	/* power up phy */
+	mii_rw(dev, np->phyaddr, MII_BMCR,
+	       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) & ~BMCR_PDOWN);
+
 	/* erase previous misconfiguration */
 	if (np->driver_data & DEV_HAS_POWER_CNTRL)
 		nv_mac_reset(dev);
@@ -5113,6 +5117,10 @@ static int nv_close(struct net_device *d
 	if (np->wolenabled) {
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
+	} else {
+		/* power down phy */
+		mii_rw(dev, np->phyaddr, MII_BMCR,
+		       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ)|BMCR_PDOWN);
 	}
 
 	/* FIXME: power down nic */
_
