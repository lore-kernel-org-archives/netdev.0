From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: Re: [PATCH] 2.6.3 pcnet32.c fix link reporting for non-mii devices
Date: Sat, 21 Feb 2004 22:57:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4037D42C.4030909@tmus.dk>
References: <200402202232.i1KMWqD07369@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030004050402030806020001"
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>, netdev@oss.sgi.com
In-Reply-To: <200402202232.i1KMWqD07369@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030004050402030806020001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Don Fry wrote:
> Thomas,
> 
> Thanks for the input.  I am the unofficial maintainer, sort of.  I don't
> have a card without an mii, so I can't test some of the changes.  Do
> you know of a way to determine the link state so I can correctly return
> the state?
> 
> By the way, are you running 2.4 or 2.6?
> 

Hi again!

Decided to do some research and get this thing implemented right!
I've created a new patch against the 2.6.3-bk3 version of pcnet32.c

What this patch does is that in the event that mii is not supported, 
link status is read directly from device's lnktst bcr register.

Works without any problem with the virtual nic under vmware. So if all 
the other non-mii pcnet32 devices have the link status register in the 
same place, things should be just fine!

Could you please test this and let me know what you think?

Best regards

Thomas


--------------030004050402030806020001
Content-Type: text/plain;
 name="pcnet32_real_link_detect_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcnet32_real_link_detect_fix.patch"

--- drivers/net/pcnet32.c.tmus	2004-02-19 15:24:31.238513096 +0100
+++ drivers/net/pcnet32.c	2004-02-19 15:27:28.265600888 +0100
@@ -1644,7 +1644,9 @@
 	case ETHTOOL_GLINK: {
 		struct ethtool_value edata = {ETHTOOL_GLINK};
 		spin_lock_irq(&lp->lock);
-		edata.data = mii_link_ok(&lp->mii_if);
+		if(lp->mii) edata.data = mii_link_ok(&lp->mii_if);
+                /* read the LNKTST BCR register for link status on non-mii capable devices */
+                else edata.data = (lp->a.read_bcr(ioaddr,4) != 0xc0);
 		spin_unlock_irq(&lp->lock);
 		if (copy_to_user(useraddr, &edata, sizeof(edata)))
 			return -EFAULT;

--------------030004050402030806020001--
