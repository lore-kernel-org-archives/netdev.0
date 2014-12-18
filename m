From: Nils Holland <nholland@tisys.org>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Thu, 18 Dec 2014 21:26:38 +0100
Message-ID: <20141218202637.GA2930@teela.fritz.box>
References: <20141213210251.GA12812@teela.fritz.box>
 <548EF90A.5070607@gmail.com>
 <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
 <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
 <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <54907300.9050902@gmail.com>
 <1418759684.4248.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAErSpo7sqZS+-4LHo3wbo-pa73mcP_3d0Z37U0tfnASaxp-D_g@mail.gmail.com>
 <1418930889.3433.8.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Rajat Jain <rajatxjain@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418930889.3433.8.camel@prashant>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 18, 2014 at 11:28:09AM -0800, Prashant Sreedharan wrote:
> On Thu, 2014-12-18 at 12:15 -0700, Bjorn Helgaas wrote:
> > 
> > Any updates from the hardware team?
> > 
> > This is a pretty serious regression, but as far as I can tell, it is
> > not a PCI bug.  The device should respond to a config read of vendor
> > ID.  If the driver does something that make the read return CRS
> > status, I think the driver is responsible for doing whatever delay or
> > other fixup is required.
> > 
> > I'm inclined to reassign this bug to the tg3 driver unless you think
> > the PCI core is doing something wrong here.
> > 
> > Bjorn
> 
> We were not able to reproduce this issue, could you please check what is
> the value of reg 0x70, before the pci_device_is_present call is made ?
> if bit 15 is set config access will be retried.
> 
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -9025,6 +9025,7 @@ static int tg3_chip_reset(struct tg3 *tp)
>         void (*write_op)(struct tg3 *, u32, u32);
>         int i, err;
>  
> +       printk(KERN_ERR "config state: %x\n", tr32(TG3PCI_PCISTATE));
>         if (!pci_device_is_present(tp->pdev))
>                 return -ENODEV;

No problem, I gave this a try and here is what I get:

[    2.185190] libphy: tg3 mdio bus: probed
[    2.229357] tsc: Refined TSC clocksource calibration: 2399.999 MHz
[    2.244993] config state: 1292
[    2.247136] tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM57780) rev 57780001]
        (PCI Express) MAC address 00:19:99:ce:13:a6
[    2.249279] tg3 0000:02:00.0 eth0: attached PHY driver [Broadcom BCM57780]
        (mii_bus:phy_addr=200:01)
[    2.251460] tg3 0000:02:00.0 eth0: RXcsums[1] LinkChgREG[0]
        MIirq[0] ASF[0] TSOcap[1]
[    2.253672] tg3 0000:02:00.0 eth0: dma_rwctrl[76180000] dma_mask[64-bit]
[...]
[   12.204692] tg3 0000:02:00.0
        enp2s0: No firmware running
[   12.206653] config state: 1292
[   12.208655] config state: 1292

That's all of the three times the new debugging line gets hit when I
boot my system using the supplied diagnostic patch.

Hope that helps - of course, I'd gladly test any further
(diagnostic) patches if required! Also, if I can provide any
additional information that might be of value, just ask:-)

Greetings,
Nils
