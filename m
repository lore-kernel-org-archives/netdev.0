From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 2 Jun 2008 20:03:30 +0100
Message-ID: <20080602190329.GC6192@solarflare.com>
References: <20080602155415.GA6192@solarflare.com> <OF3A2B75A8.48ADA40F-ON8025745C.00633ABA-8025745C.0065B74E@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>, catalin.marinas@arm.com,
	Dustin Mcintire <dustin@sensoria.com>, Enrik.Berkhan@ge.com,
	hennerich@blackfin.uclinux.org, ian.saturley@smsc.com,
	Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:41618 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751707AbYFBTEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 15:04:12 -0400
Content-Disposition: inline
In-Reply-To: <OF3A2B75A8.48ADA40F-ON8025745C.00633ABA-8025745C.0065B74E@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve.Glendinning@smsc.com wrote:
> Hi Ben,
> 
> Thanks for the feedback.  I've implemented most of your suggestions, but 
> have a few questions:
> 
> > [...]
> > > +/* Set a mac register, phy_lock must be acquired before calling */
> > > +static void smsc911x_mac_write(struct smsc911x_data *pdata,
> > > +                unsigned int offset, u32 val)
> > > +{
> > > +   unsigned int temp;
> > > +
> > > +#ifdef CONFIG_DEBUG_SPINLOCK
> > > +   if (!spin_is_locked(&pdata->phy_lock))
> > > +      SMSC_WARNING("phy_lock not held");
> > > +#endif            /* CONFIG_DEBUG_SPINLOCK */
> > > +
> > > +   temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
> > > +   if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
> > > +      SMSC_WARNING("smsc911x_mac_write failed, MAC busy at entry");
> > > +      return;
> > > +   }
> > 
> > Shouldn't this return an error code?
> > 
> > [...]
> > > +/* Sets a phy register, phy_lock must be acquired before calling */
> > > +static void smsc911x_phy_write(struct smsc911x_data *pdata,
> > > +                unsigned int index, u16 val)
> > > +{
> > > +   unsigned int addr;
> > > +   int i;
> > > +
> > > +#ifdef CONFIG_DEBUG_SPINLOCK
> > > +   if (!spin_is_locked(&pdata->phy_lock))
> > > +      SMSC_WARNING("phy_lock not held");
> > > +#endif            /* CONFIG_DEBUG_SPINLOCK */
> > > +
> > > +   /* Confirm MII not busy */
> > > +   if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & 
> MII_ACC_MII_BUSY_)) {
> > > +      SMSC_WARNING("MII is busy in smsc911x_write_phy???");
> > > +      return;
> > > +   }
> > 
> > Similarly for this function.
> 
> I could return an error code from these write functions, but the 
> equivalent read functions currently return their register value.  Would 
> you change the read functions to take a result pointer?

If you can't reserve some range of values for errors (e.g. 32-bit reads
which may yield any 32-bit value) then I suppose so.  For 16-bit reads you
can return an int with negative values reserved for errors.

> I should mention this "MAC busy at entry" check is an assert to catch 
> driver locking problems during development (as is the spinlock check 
> above).  If the driver is "correct" it should only be seen in the case of 
> hardware failure.

Hardware failure does happen though, and once you've detected it it seems
like a bad idea to hide it.

> > [...]
> > > +static int smsc911x_soft_reset(struct smsc911x_data *pdata)
> > > +{
> > > +   unsigned int timeout;
> > > +   unsigned int temp;
> > > +
> > > +   /* Reset the LAN911x */
> > > +   smsc911x_reg_write(HW_CFG_SRST_, pdata, HW_CFG);
> > > +   timeout = 10;
> > > +   do {
> > > +      udelay(10);
> > > +      temp = smsc911x_reg_read(pdata, HW_CFG);
> > > +   } while ((--timeout) && (temp & HW_CFG_SRST_));
> > > +
> > > +   if (unlikely(temp & HW_CFG_SRST_)) {
> > > +      SMSC_WARNING("Failed to complete reset");
> > > +      return -ENODEV;
> > 
> > I think this should be -EIO unless this is only called during probe.
> 
> This reset function is called from both probe and open, although its 
> return code is only checked for nonzero by both.  Should probe return 
> -ENODEV, and open return -EIO if this device reset fails?

Personally I think -EIO is a perfectly reasonable error code for I/O
errors after the device has been positively identified, even during
probe.  You could have the probe function squash other errors into
-ENODEV if you want.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
