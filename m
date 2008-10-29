From: akpm@linux-foundation.org
Subject: [patch 1/7] forcedeth: power down phy when interface is down
Date: Wed, 29 Oct 2008 14:22:10 -0700
Message-ID: <200810292122.m9TLMAsp020135@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	eswierk@arastra.com, aabdulla@nvidia.com, ajones@riverbed.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48215 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754163AbYJ2VWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:22:52 -0400
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

Arthur Jones said:

  I just ran across this patch.  Tested on a Marvell 88E1121R (GigE PHY)
  and works great.  This is a very important feature for me.

Signed-off-by: Ed Swierk <eswierk@arastra.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Tested-by: Arthur Jones <ajones@riverbed.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-down drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-down
+++ a/drivers/net/forcedeth.c
@@ -1446,9 +1446,9 @@ static int phy_init(struct net_device *d
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
@@ -5210,6 +5210,10 @@ static int nv_open(struct net_device *de
 
 	dprintk(KERN_DEBUG "nv_open: begin\n");
 
+	/* power up phy */
+	mii_rw(dev, np->phyaddr, MII_BMCR,
+	       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) & ~BMCR_PDOWN);
+
 	/* erase previous misconfiguration */
 	if (np->driver_data & DEV_HAS_POWER_CNTRL)
 		nv_mac_reset(dev);
@@ -5403,6 +5407,10 @@ static int nv_close(struct net_device *d
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
