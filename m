From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [patch 02/10] forcedeth: power down phy when interface is down
Date: Thu, 13 Dec 2007 16:11:55 -0800
Message-ID: <F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com>
References: <200712140002.lBE02qo1025508@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <eswierk@arastra.com>
To: <akpm@linux-foundation.org>, <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:16483 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764167AbXLNANA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:13:00 -0500
In-Reply-To: <200712140002.lBE02qo1025508@imap1.linux-foundation.org>
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would not include this patch until further testing is performed.
NVIDIA MCP chips use 3rd party PHY vendors. By powering down the phy, it
could have adverse affects on certain phys.

Ayaz


-----Original Message-----
From: akpm@linux-foundation.org [mailto:akpm@linux-foundation.org] 
Sent: Thursday, December 13, 2007 4:03 PM
To: jeff@garzik.org
Cc: netdev@vger.kernel.org; akpm@linux-foundation.org;
eswierk@arastra.com; Ayaz Abdulla
Subject: [patch 02/10] forcedeth: power down phy when interface is down


From: "Ed Swierk" <eswierk@arastra.com>

Bring the physical link down when the interface is down by placing the
PHY
in power-down state, unless WOL is enabled.  This mirrors the behavior
of
other drivers including e1000 and tg3.

Signed-off-by: Ed Swierk <eswierk@arastra.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff -puN
drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-down
drivers/net/forcedeth.c
---
a/drivers/net/forcedeth.c~forcedeth-power-down-phy-when-interface-is-dow
n
+++ a/drivers/net/forcedeth.c
@@ -1312,9 +1312,9 @@ static int phy_init(struct net_device *d
 	/* some phys clear out pause advertisment on reset, set it back
*/
 	mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);
 
-	/* restart auto negotiation */
+	/* restart auto negotiation, power down phy */
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
-	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
+	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE | BMCR_PDOWN);
 	if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
 		return PHY_ERROR;
 	}
@@ -4798,6 +4798,10 @@ static int nv_open(struct net_device *de
 
 	dprintk(KERN_DEBUG "nv_open: begin\n");
 
+	/* power up phy */
+	mii_rw(dev, np->phyaddr, MII_BMCR,
+	       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) &
~BMCR_PDOWN);
+
 	/* erase previous misconfiguration */
 	if (np->driver_data & DEV_HAS_POWER_CNTRL)
 		nv_mac_reset(dev);
@@ -4980,6 +4984,10 @@ static int nv_close(struct net_device *d
 	if (np->wolenabled) {
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base +
NvRegPacketFilterFlags);
 		nv_start_rx(dev);
+	} else {
+		/* power down phy */
+		mii_rw(dev, np->phyaddr, MII_BMCR,
+		       mii_rw(dev, np->phyaddr, MII_BMCR,
MII_READ)|BMCR_PDOWN);
 	}
 
 	/* FIXME: power down nic */
_
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
