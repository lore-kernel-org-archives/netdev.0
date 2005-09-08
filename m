From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Fri, 09 Sep 2005 00:39:18 +0200
Message-ID: <4320BD96.3060307@tpack.net>
References: <200509080125.j881PcL9015847@hera.kernel.org>  <431F9899.4060602@pobox.com>  <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>  <1126184700.4805.32.camel@tsc-6.cph.tpack.net>  <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de> <1126190554.4805.68.camel@tsc-6.cph.tpack.net> <Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090202050309010401090008"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965055AbVIHWg7@vger.kernel.org>
To: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090202050309010401090008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Bogdan Costescu wrote:
> I now understood what the problem was, so I'll put it in words for 
> posterity: the Link Status bit of the MII Status register needs to be 
> read twice to first clear the error state (link bit=0) after which the 
> bit reports the actual value of the link. From the manual:

Yes, this is exactly the point.

> But I still don't agree with your solution: you are reading the Status 
> register twice in all cases, which is wrong. What you want is to read it 
> a second time only after the link was marked as down: a simple check if 
> bit 2 of the Status register is 0, in which case you issue the second 
> read. This still means that there will be 2 reads if the link remains 
> down, but at least there is only 1 read for the case where the link is 
> up and remains up.

I don't think this makes much of a difference in the big picture, but
you're certainly right: let's not waste more cycles than we have to.

Can we agree on the patch below?


-Tommy

--------------090202050309010401090008
Content-Type: text/plain;
 name="3c59x-carrier.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c59x-carrier.patch"

[3c59x] Avoid blindly reading link status twice

In order to spare some I/O operations, be more intelligent about
when to read from the PHY.

Pointed out by Bogdan Costescu.

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--- linux-2.6.13-git8/drivers/net/3c59x.c-orig	Fri Sep  9 00:05:49 2005
+++ linux-2.6.13-git8/drivers/net/3c59x.c	Fri Sep  9 00:13:55 2005
@@ -1889,7 +1889,9 @@ vortex_timer(unsigned long data)
 		{
 			spin_lock_bh(&vp->lock);
 			mii_status = mdio_read(dev, vp->phys[0], 1);
-			mii_status = mdio_read(dev, vp->phys[0], 1);
+			if (!(mii_status & BMSR_LSTATUS))
+				/* Re-read to get actual link status */
+				mii_status = mdio_read(dev, vp->phys[0], 1);
 			ok = 1;
 			if (vortex_debug > 2)
 				printk(KERN_DEBUG "%s: MII transceiver has status %4.4x.\n",

--------------090202050309010401090008--
