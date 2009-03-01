From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Sun, 01 Mar 2009 14:19:11 +0100
Message-ID: <49AA8B4F.8090405@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc> <16084.1235752119@death.nxdomain.ibm.com> <49A84802.7030502@krogh.cc> <30478.1235766943@death.nxdomain.ibm.com> <49AA2973.7040209@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:57706 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbZCANTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 08:19:22 -0500
In-Reply-To: <49AA2973.7040209@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> I appreciate that you spend time on it, but my feeling is that it 
> definately isn't reproducible in all environments (otherwise we would
> probably have seen a large cry by now).
> 
> I'm trying to bisect the "fix" down and hope that'll tell us something 
> more.

Ok, The fixing commit seems to be: cb52deba12f27af90a46d2f8667a64888118a888

Applying it to 2.6.28.7 and 2.6.27.19 makes them both work.

It also explains why my e1000 based bonds didnt break, allthough the 
commitmessage doesnt mention anything about how it should effect 
bonding. Wouldn't it make sense to propose this patch for 2.6.27 and 
2.6.28 stable kernels?


commit cb52deba12f27af90a46d2f8667a64888118a888
Author: Ed Swierk <eswierk@arastra.com>
Date:   Mon Dec 1 12:24:43 2008 +0000

     forcedeth: power down phy when interface is down

     Bring the physical link down when the interface is down by placing 
the PHY
     in power-down state, unless WOL is enabled.  This mirrors the 
behavior of
     other drivers including e1000 and tg3.

     Without the patch, ifconfig down leaves the physical link up, which 
confuses
     datacenter users who expect the link lights both on the NIC and the 
switch to
     go out when they bring an interface down.

     Furthermore, even though the phy is powered on, autonegotiation 
stops working,
     so a normally gigabit link might suddenly become 100 Mbit 
half-duplex when the
     interface goes down, and become gigabit when it comes up again.

     Ayaz said:

       I would not include this patch until further testing is 
performed.  NVIDIA
       MCP chips use 3rd party PHY vendors.  By powering down the phy, 
it could
       have adverse affects on certain phys.

     Arthur Jones said:

       I just ran across this patch.  Tested on a Marvell 88E1121R (GigE 
PHY)
       and works great.  This is a very important feature for me.

     Signed-off-by: Ed Swierk <eswierk@arastra.com>
     Tested-by: Arthur Jones <ajones@riverbed.com>
     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
     Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0d7e575..12384df 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1446,9 +1446,9 @@ static int phy_init(struct net_device *dev)
         /* some phys clear out pause advertisment on reset, set it back */
         mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);

-       /* restart auto negotiation */
+       /* restart auto negotiation, power down phy */
         mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
-       mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
+       mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE | BMCR_PDOWN);
         if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
                 return PHY_ERROR;
         }
@@ -5208,6 +5208,10 @@ static int nv_open(struct net_device *dev)

         dprintk(KERN_DEBUG "nv_open: begin\n");

+       /* power up phy */
+       mii_rw(dev, np->phyaddr, MII_BMCR,
+              mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) & ~BMCR_PDOWN);
+
         /* erase previous misconfiguration */
         if (np->driver_data & DEV_HAS_POWER_CNTRL)
                 nv_mac_reset(dev);
@@ -5401,6 +5405,10 @@ static int nv_close(struct net_device *dev)
         if (np->wolenabled) {
                 writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + 
NvRegPacketFilterFlags);
                 nv_start_rx(dev);
+       } else {
+               /* power down phy */
+               mii_rw(dev, np->phyaddr, MII_BMCR,
+                      mii_rw(dev, np->phyaddr, MII_BMCR, 
MII_READ)|BMCR_PDOWN);
         }

         /* FIXME: power down nic */


