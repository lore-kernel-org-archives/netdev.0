From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 2 Jun 2008 19:30:59 +0100
Message-ID: <OF3A2B75A8.48ADA40F-ON8025745C.00633ABA-8025745C.0065B74E@smsc.com>
References: <20080602155415.GA6192@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>, catalin.marinas@arm.com,
	Dustin Mcintire <dustin@sensoria.com>, Enrik.Berkhan@ge.com,
	hennerich@blackfin.uclinux.org, ian.saturley@smsc.com,
	Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1736 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752084AbYFBSbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 14:31:18 -0400
In-Reply-To: <20080602155415.GA6192@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thanks for the feedback.  I've implemented most of your suggestions, but 
have a few questions:

> [...]
> > +/* Set a mac register, phy_lock must be acquired before calling */
> > +static void smsc911x_mac_write(struct smsc911x_data *pdata,
> > +                unsigned int offset, u32 val)
> > +{
> > +   unsigned int temp;
> > +
> > +#ifdef CONFIG_DEBUG_SPINLOCK
> > +   if (!spin_is_locked(&pdata->phy_lock))
> > +      SMSC_WARNING("phy_lock not held");
> > +#endif            /* CONFIG_DEBUG_SPINLOCK */
> > +
> > +   temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
> > +   if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
> > +      SMSC_WARNING("smsc911x_mac_write failed, MAC busy at entry");
> > +      return;
> > +   }
> 
> Shouldn't this return an error code?
> 
> [...]
> > +/* Sets a phy register, phy_lock must be acquired before calling */
> > +static void smsc911x_phy_write(struct smsc911x_data *pdata,
> > +                unsigned int index, u16 val)
> > +{
> > +   unsigned int addr;
> > +   int i;
> > +
> > +#ifdef CONFIG_DEBUG_SPINLOCK
> > +   if (!spin_is_locked(&pdata->phy_lock))
> > +      SMSC_WARNING("phy_lock not held");
> > +#endif            /* CONFIG_DEBUG_SPINLOCK */
> > +
> > +   /* Confirm MII not busy */
> > +   if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & 
MII_ACC_MII_BUSY_)) {
> > +      SMSC_WARNING("MII is busy in smsc911x_write_phy???");
> > +      return;
> > +   }
> 
> Similarly for this function.

I could return an error code from these write functions, but the 
equivalent read functions currently return their register value.  Would 
you change the read functions to take a result pointer?

I should mention this "MAC busy at entry" check is an assert to catch 
driver locking problems during development (as is the spinlock check 
above).  If the driver is "correct" it should only be seen in the case of 
hardware failure.

> [...]
> > +static int smsc911x_soft_reset(struct smsc911x_data *pdata)
> > +{
> > +   unsigned int timeout;
> > +   unsigned int temp;
> > +
> > +   /* Reset the LAN911x */
> > +   smsc911x_reg_write(HW_CFG_SRST_, pdata, HW_CFG);
> > +   timeout = 10;
> > +   do {
> > +      udelay(10);
> > +      temp = smsc911x_reg_read(pdata, HW_CFG);
> > +   } while ((--timeout) && (temp & HW_CFG_SRST_));
> > +
> > +   if (unlikely(temp & HW_CFG_SRST_)) {
> > +      SMSC_WARNING("Failed to complete reset");
> > +      return -ENODEV;
> 
> I think this should be -EIO unless this is only called during probe.

This reset function is called from both probe and open, although its 
return code is only checked for nonzero by both.  Should probe return 
-ENODEV, and open return -EIO if this device reset fails?

> [...]
> > +/* SMSC911x registers and bitfields */
> > +#define RX_DATA_FIFO         0x00
> > +
> > +#define TX_DATA_FIFO         0x20
> > +#define TX_CMD_A_ON_COMP_      0x80000000
> 
> Why do these flag/mask names have trailing underscores?

"It was like that when i got here" :-)  The register offsets don't, but 
the bitmasks do.  Should I remove them?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

