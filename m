From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Fri, 19 Dec 2014 10:09:58 -0700
Message-ID: <CAErSpo4UdxwL=wA8cBJ7_DAdTb2xNeg6600qB0=Jdxv80aVmcg@mail.gmail.com>
References: <20141213210251.GA12812@teela.fritz.box> <548EF90A.5070607@gmail.com>
 <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
 <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
 <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <54907300.9050902@gmail.com> <1418759684.4248.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAErSpo7sqZS+-4LHo3wbo-pa73mcP_3d0Z37U0tfnASaxp-D_g@mail.gmail.com>
 <1418930889.3433.8.camel@prashant> <20141218202637.GA2930@teela.fritz.box> <1418955047.3433.27.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nils Holland <nholland@tisys.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Rajat Jain <rajatxjain@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1418955047.3433.27.camel@prashant>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 18, 2014 at 7:10 PM, Prashant Sreedharan
<prashant@broadcom.com> wrote:
> On Thu, 2014-12-18 at 21:26 +0100, Nils Holland wrote:
>> On Thu, Dec 18, 2014 at 11:28:09AM -0800, Prashant Sreedharan wrote:
>> > On Thu, 2014-12-18 at 12:15 -0700, Bjorn Helgaas wrote:
>> > >
>> > > Any updates from the hardware team?
>> > >
>> > > This is a pretty serious regression, but as far as I can tell, it is
>> > > not a PCI bug.  The device should respond to a config read of vendor
>> > > ID.  If the driver does something that make the read return CRS
>> > > status, I think the driver is responsible for doing whatever delay or
>> > > other fixup is required.
>> > >
>> > > I'm inclined to reassign this bug to the tg3 driver unless you think
>> > > the PCI core is doing something wrong here.
>> > >
>> > > Bjorn
>> >
>> > We were not able to reproduce this issue, could you please check what is
>> > the value of reg 0x70, before the pci_device_is_present call is made ?
>> > if bit 15 is set config access will be retried.
>> >
>> > --- a/drivers/net/ethernet/broadcom/tg3.c
>> > +++ b/drivers/net/ethernet/broadcom/tg3.c
>> > @@ -9025,6 +9025,7 @@ static int tg3_chip_reset(struct tg3 *tp)
>> >         void (*write_op)(struct tg3 *, u32, u32);
>> >         int i, err;
>> >
>> > +       printk(KERN_ERR "config state: %x\n", tr32(TG3PCI_PCISTATE));
>> >         if (!pci_device_is_present(tp->pdev))
>> >                 return -ENODEV;
>>
>> No problem, I gave this a try and here is what I get:
>>
>> [    2.185190] libphy: tg3 mdio bus: probed
>> [    2.229357] tsc: Refined TSC clocksource calibration: 2399.999 MHz
>> [    2.244993] config state: 1292
>> [    2.247136] tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM57780) rev 57780001]
>>         (PCI Express) MAC address 00:19:99:ce:13:a6
>> [    2.249279] tg3 0000:02:00.0 eth0: attached PHY driver [Broadcom BCM57780]
>>         (mii_bus:phy_addr=200:01)
>> [    2.251460] tg3 0000:02:00.0 eth0: RXcsums[1] LinkChgREG[0]
>>         MIirq[0] ASF[0] TSOcap[1]
>> [    2.253672] tg3 0000:02:00.0 eth0: dma_rwctrl[76180000] dma_mask[64-bit]
>> [...]
>> [   12.204692] tg3 0000:02:00.0
>>         enp2s0: No firmware running
>> [   12.206653] config state: 1292
>> [   12.208655] config state: 1292
>>
>> That's all of the three times the new debugging line gets hit when I
>> boot my system using the supplied diagnostic patch.
>>
>> Hope that helps - of course, I'd gladly test any further
>> (diagnostic) patches if required! Also, if I can provide any
>> additional information that might be of value, just ask:-)
>>
> Nils/Marcelo thanks for inputs, since reg 0x70 bit 15 is clear it
> indicates the chip is not setting the config retry bit. We were hoping
> this bit is causing the config access to return CRS but looks like it is
> not.
>
> Btw after forcing the error path (tg3_init_one -> tg3_halt) in the
> driver now we are able to reproduce the problem on 5722 in house. We are
> working with the HW team to narrow this down.
>
> Also it is not clear to me how reverting commit cfa6a7877b17a667 fixes
> the problem.

The full commit is 89665a6a71408796565bfd29cfa6a7877b17a667, and git
works with any unique *prefix* of that.  The current convention is to
use the first 12 characters (I have "[core] abbrev = 12" in my
.git/config).  Unfortunately, suffixes don't work at all.

Anyway, here's why I think 89665a6a7140 makes a difference.  We're in this path:

  pci_device_is_present
    pci_bus_read_dev_vendor_id(..., crs_timeout = 0)
      pci_bus_read_config_dword(bus, devfn, PCI_VENDOR_ID, l)

and for some reason the chip returns 0x00010001 for that 32-bit read.
Before 89665a6a7140, we compared all 32 bits with "*l == 0xffff0001".
This is false, so pci_bus_read_dev_vendor_id() returns true, which
means pci_device_is_present() is also true.

After 89665a6a7140, we compare only the low 16 bits with ((*l &
0xffff) == 0x0001), which is true, so pci_bus_read_dev_vendor_id()
returns false, and pci_device_is_present() is false.

Bjorn
