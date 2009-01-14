From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH 1/2] Add SMC_MEM_RESERVED for OMAP platform.
Date: Wed, 14 Jan 2009 13:20:01 +0800
Message-ID: <1231910401.6847.24.camel@localhost>
References: <OF0160BDDA.D8B59B44-ON8025753D.0059A9A7-8025753D.0059ADBB@smsc.com>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ian.Saturley@smsc.com, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47163 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbZANFLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 00:11:23 -0500
In-Reply-To: <OF0160BDDA.D8B59B44-ON8025753D.0059A9A7-8025753D.0059ADBB@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Steve,

I found the reason why it failed. the omap_ldp need to pass
IRQF_TRIGGER_LOW to request_irq.

So I add a irq_flags in smsc911x_platform_config. you can also pass
SHARED_IRQ flag via it.

I will send the smsc911 patch later. For the omap_ldp platform patch, I
will send it to linux-omap mail list when they update to 2.6.29.

Stanley.

On Tue, 2009-01-13 at 16:18 +0000, Steve.Glendinning@smsc.com wrote:
> Hi Stanley,
> 
> Apologies, on closer examination your platform doesn't request a shared 
> irq.   You can ignore the first patch in the set I sent you, and the 
> second is *extremely* similar to yours.
> 
> Sorry about my confusion, out of 3 arm platforms I converted only omap 
> DOESN'T request a shared irq!
> 
> Regards,
> --
> Steve Glendinning
> SMSC GmbH
> m: +44 777 933 9124
> e: steve.glendinning@smsc.com
> 
> 
> 
> __________________
> 
> Hi Stanley,
> 
> I've just forwarded you two patches.  They're my version of your platform 
> support patch, from a queue of patches I am preparing to send to the arm 
> and sh lists.
> 
> The first patch adds support for registering shared interrupts to the 
> smsc911x driver, as this is something you were doing with smc911x.  Out of 
> interest, what else is the interrupt line shared with?
> 
> Regards,
> --
> Steve Glendinning
> SMSC GmbH
> m: +44 777 933 9124
> e: steve.glendinning@smsc.com
> 
> 
> 
> 
> 
> "stanley.miao" <stanley.miao@windriver.com> 
> 13/01/2009 12:59
> Please respond to
> stanley.miao@windriver.com
> 
> 
> To
> Steve Glendinning/SMSC@SMSC
> cc
> 
> Subject
> Re: [PATCH 1/2] Add SMC_MEM_RESERVED for OMAP platform.
> 
> 
> 
> 
> 
> 
> Hi,Steve,
> 
> I saw your patches has been integrated into mainline kernel, so I begin
> to support omap_ldp based on your patches. It uses SMSC LAN9211.
> 
> The attached file is omap_ldp platform patch. It does't work. the
> following message is the boot log.
> -------------------------------------------------------
> smsc911x: Driver version 2008-10-21.
> eth%d: smsc911x_init: Driver Parameters:
> eth%d: smsc911x_init: LAN base: 0xC8808000
> eth%d: smsc911x_init: IRQ: 312
> eth%d: smsc911x_init: PHY will be autodetected.
> eth%d: smsc911x_init: BYTE_TEST: 0x87654321
> eth%d: smsc911x_init: LAN911x identified, idrev: 0x92110000, generation:
> 4
> eth0: smsc911x_drv_probe: Network interface: "eth0"
> eth0: smsc911x_mii_init: External PHY is not supported, using internal
> PHY
> phy_device_create(): bus_name=<NULL>, addr=508099, phy_id=0xc78f1800.
> smsc911x-mdio: probed
> eth0: smsc911x_mii_probe: PHY 1: addr 1, phy_id 0x0007C0C3
> eth0: attached PHY driver [SMSC LAN8700/LAN9211]
> (mii_bus:phy_addr=ffffffff:01, irq=-1)
> eth0: smsc911x_phy_check_loopbackpkt: Successfully verified loopback
> packet
> eth0: smsc911x_mii_probe: Passed Loop Back Test
> eth0: smsc911x_mii_probe: phy initialised succesfully
> eth0: smsc911x_drv_probe: Mac Address is read from LAN911x EEPROM
> net eth0: MAC Address: 00:08:ee:02:53:0e
> <snip>
> eth0: smsc911x_open: irq polarity: active low
> eth0: smsc911x_open: irq type: open drain
> eth0: smsc911x_open: Testing irq handler using IRQ 312
> smsc911x_open(): temp=0x80000000.
> net eth0: ISR failed signaling test (IRQ 312)
> IP-Config: Failed to open eth0
> IP-Config: Device `eth0' not found.
> --------------------------------------------------------------
> 
> Testing irq handler failed. The register INT_EN was written correctly,
> but the interrupt didn't occur.
> 
> Do you have any suggestion on this problem ?
> 
> Thanks.
> 
> Stanley.
> 
> 
> 
> On Mon, 2008-11-17 at 10:31 +0000, Steve.Glendinning@smsc.com wrote:
> > Hi Stanley,
> > 
> > Jeff has merged the smsc911x driver into -next, this is intended to 
> > replace smc911x moving forward.  I'll forward the patchset to you 
> > off-list, it includes platform_data support for several platforms so 
> > adding support for omap should be simple.
> > 
> > > diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
> > > index cc7d85b..d1b3b9b 100644
> > > --- a/drivers/net/smc911x.h
> > > +++ b/drivers/net/smc911x.h
> > > @@ -42,6 +42,16 @@
> > >    #define SMC_USE_16BIT      0
> > >    #define SMC_USE_32BIT      1
> > >    #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > > +#elif defined(CONFIG_ARCH_OMAP34XX)
> > > +  #define SMC_USE_16BIT      0
> > > +  #define SMC_USE_32BIT      1
> > > +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > > +  #define SMC_MEM_RESERVED   1
> > > +#elif defined(CONFIG_ARCH_OMAP24XX)
> > > +  #define SMC_USE_16BIT      0
> > > +  #define SMC_USE_32BIT      1
> > > +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > > +  #define SMC_MEM_RESERVED   1
> > >  #else
> > >  /*
> > >   * Default configuration
> > 
> > nack - this platform-specific configuration shouldn't be in the driver, 
> > SMC_DYNAMIC_BUS_CONFIG was added so this can be specified in 
> > platform_data.
> > 
> > Regards,
> > --
> > Steve Glendinning
> > SMSC GmbH
> > m: +44 777 933 9124
> > e: steve.glendinning@smsc.com
> > 
> [attachment "ldp.patch" deleted by Steve Glendinning/SMSC] 
> 
