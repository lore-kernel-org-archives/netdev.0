From: Steve.Glendinning@smsc.com
Subject: Re: SMSC LAN911x and LAN921x vendor driver
Date: Mon, 31 Jul 2006 21:20:30 +0100
Message-ID: <OFD3BF6580.D8A1BF50-ON802571BC.006F9002-802571BC.006FBC29@smsc.com>
References: <20060728213841.GA14235@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:32012 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S932490AbWGaUUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 16:20:52 -0400
In-Reply-To: <20060728213841.GA14235@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

Thanks for your feedback, I have a few questions.

> > +            return serviced;
> > +}
> > +
> > +/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 
flavors.
> > + * If something goes wrong, returns -ENODEV to revert back to 
internal phy. */
> > +static int smsc911x_phy_initialise_external(struct smsc911x_data 
*pdata)
> > +{
> > +            unsigned int address;
> > +            unsigned int hwcfg;
> > +            unsigned int phyid1;
> > +            unsigned int phyid2;
> > +
> > +            hwcfg = smsc911x_reg_read(pdata, HW_CFG);
> > +
> > +            /* External phy is requested, supported, and detected */
> > +            if (hwcfg & HW_CFG_EXT_PHY_DET_) {
> > +
> > +                            /* Attempt to switch to external phy for 
auto-detecting
> > +                             * its address. Assuming tx and rx are 
stopped because
> > +                             * smsc911x_phy_initialise is called 
before
> > +                             * smsc911x_rx_initialise and 
tx_initialise.
> > +                             */
> > +
> > +                            /* Disable phy clocks to the MAC */
> > +                            hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> > +                            hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
> > +                            smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> > +                            udelay(10);             /* Enough time 
for clocks to stop */
> 
> I assume that writes are never posted, right ?
> 

I don't understand the question, what do you mean?


> > +static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata)
> > +{
> > +            unsigned long flags;
> > +            unsigned int timeout;
> > +            unsigned int mac_cr;
> > +
> > +            /* This function is only called for older LAN911x devices 

> > +             * (revA or revB), where MAC_CR, HASHH and HASHL should 
not
> > +             * be modified during Rx - newer devices immediately 
update the
> > +             * registers */
> > +
> > +            local_irq_save(flags);
> > +
> > +            /* Stop Rx */
> > +            mac_cr = smsc911x_mac_read(pdata, MAC_CR);
> > +            mac_cr &= ~(MAC_CR_RXEN_);
> > +            smsc911x_mac_write(pdata, MAC_CR, mac_cr);
> > +
> > +            /* Poll until Rx has stopped.  If a frame is being 
recieved, this will
> > +             * block until the end of this frame.  (this may take a 
long time at
> > +             * 10Mbps) */
> > +            timeout = 2000;
> > +            while ((timeout--)
> > +                   && (!(smsc911x_reg_read(pdata, INT_STS) & 
INT_STS_RXSTOP_INT_))) {
> > +                            udelay(1);
> 
> 
> In a completely ideal world the driver would probably race outside of an
> irq disabled section until it grabs the napi poll handler, thus 
preserving
> the nice low latency property of the kernel.
> 
> Nevermind :o}

Agreed, I would like to find a nicer way to do this.  It's a nasty 
workaround to a nasty hardware issue :o}

There are two problems.  First, on older hardware revisions the multicast 
hash filters (as well as the promisc flag) cannot be modified while rx is 
active (bad things might happen).  There is an interrupt which can be used 
to indicate RX has stopped, but on early hardware this is not 100% 
reliable.

The current solution is the simplest option, and works.  A better way 
could be to use the RX_STOP interrupt, but also schedule a task to run 
later "just in case"?

Best Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

