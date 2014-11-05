From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net
	onarndale platform
Date: Wed, 5 Nov 2014 15:02:58 +0000
Message-ID: <20141105150258.GR23178@opensource.wolfsonmicro.com>
References: <20141104072236.GA559@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local> <20141104094336.GA3145@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local> <20141104200914.GN23178@opensource.wolfsonmicro.com> <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Riku Voipio <riku.voipio@iki.fi>, davem@davemloft.net,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org
To: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:39920 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755245AbaKEPDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 10:03:02 -0500
Content-Disposition: inline
In-Reply-To: <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 01:04:37PM +0100, Stam, Michel [FINT] wrote:
> Hello Charles,
> 
> After looking around I found the reset value for the 8772 chip, which
> seems to be 0x1E1 (ANAR register).
> 
> This equates to (according to include/uapi/linux/mii.h)
> ADVERTISE_ALL | ADVERTISE_CSMA.
> 
> The register only seems to become 0 if the software reset fails.

Odd it definitely reads back as zero on Arndale. I am guessing
that the root of the problem here is that for some reason Arndale
POR of the ethernet is pants and it needs a full software reset
before it will work and the patch removes the full reset
callback.

> 
> Unfortunately, this is exactly what I get when the patch is applied;
> asix 1-2:1.0 eth1: Failed to send software reset: ffffffb5
> asix 1-2:1.0 eth1: link reset failed (-75) usbnet usb-0000:00:1d.0-2, 
> ASIX AX88772 USB 2.0 Ethernet
> asix 1-2:1.0 eth1: Failed to send software reset: ffffffb5
> asix 1-2:1.0 eth1: link reset failed (-75) usbnet usb-0000:00:1d.0-2, 
> ASIX AX88772 USB 2.0 Ethernet

Ok so I am guessing you have a value in the register which is
neither the reset value or 0 and this causing problems later in
the reset/on the next reset. I do find the naming confusing in
the error message there as it says link reset failed but the
link_reset callback can't fail in the driver and I modified the
reset callback. But I guess that is just oddities of the network
stack I am not familiar with.

The other thing that feels odd is (and again apologies as I know
next to nothing about the networking stack) how come it is
unexpected that the reset callback destroys the state of the
device. Naively I would have expected that a reset callback would
reset the device back to its default state. Here we seem to be
trying to avoid that happening.

> 
> A little while after this its 'Failed to enable software MII access'.
> The ethernet device fails to see any link or accept any ethtool -s
> command.
> 
> My device has vid:devid 0b95:772a (ASIX Elec. Corp.).
> 
> Can you tell me what device is on the Andale platform, Charles? Same
> vendor/device id?

Yeah mine also idVendor=0b95, idProduct=772a

Thanks,
Charles

> 
> Another thing that bothers me is that dev->mii.advertising seems to
> contain the same value, so maybe that can be used instead of a call to
> asix_mdio_read(). Can anyone comment on its purpose? Should it be a
> shadow copy of the real register or something?
> 
> Riku, can you test Charles' patch as well?
> 
> Kind regards,
> 
> Michel Stam
> 
> -----Original Message-----
> From: Charles Keepax [mailto:ckeepax@opensource.wolfsonmicro.com] 
> Sent: Tuesday, November 04, 2014 21:09 PM
> To: Stam, Michel [FINT]
> Cc: Riku Voipio; davem@davemloft.net; linux-usb@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> linux-samsung-soc@vger.kernel.org
> Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net
> onarndale platform
> 
> On Tue, Nov 04, 2014 at 11:23:06AM +0100, Stam, Michel [FINT] wrote:
> > Hello Riku,
> > 
> > >Fixing a bug (ethtool support) must not cause breakage elsewhere (in
> > this case on arndale). This is now a regression of functionality from 
> > 3.17.
> > >
> > >I think it would better to revert the change now and with less hurry
> > introduce a ethtool fix that doesn't break arndale.
> > 
> > I don't fully agree here;
> > I would like to point out that this commit is a revert itself. Fixing 
> > the armdale will then cause breakage in other implementations, such as
> 
> > ours. Blankly reverting breaks other peoples' implementations.
> > 
> > The PHY reset is the thing that breaks ethtool support, so any fix 
> > that appeases all would have to take existing PHY state into account.
> > 
> > I'm not an expert on the ASIX driver, nor the MII, but I think this is
> 
> > the cause;
> > drivers/net/usb/asix_devices.c:
> >    361      asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
> > BMCR_RESET);
> >    362      asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> >    363              ADVERTISE_ALL | ADVERTISE_CSMA);
> >    364      mii_nway_restart(&dev->mii);
> > 
> > I would think that the ADVERTISE_ALL is the cause here, as it will 
> > reset the MII back to default, thus overriding ethtool settings.
> > Would an:
> > Int reg;
> > reg = asix_mdio_read(dev->net,dev->mii.phy_id,MII_ADVERTISE);
> > 
> > prior to the offending lines, and then;
> > 
> >    362      asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> >    363             reg);
> > 
> > solve the problem for you guys?
> 
> If I revert the patch in question and add this in:
> 
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -299,6 +299,7 @@ static int ax88772_reset(struct usbnet *dev)  {
>         struct asix_data *data = (struct asix_data *)&dev->data;
>         int ret, embd_phy;
> +       int reg;
>         u16 rx_ctl;
> 
>         ret = asix_write_gpio(dev,
> @@ -359,8 +360,10 @@ static int ax88772_reset(struct usbnet *dev)
>         msleep(150);
> 
>         asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
> BMCR_RESET);
> -       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> -                       ADVERTISE_ALL | ADVERTISE_CSMA);
> +       reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_ADVERTISE);
> +       if (!reg)
> +               reg = ADVERTISE_ALL | ADVERTISE_CSMA;
> +       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE, reg);
>         mii_nway_restart(&dev->mii);
> 
>         ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
> 
> Then things work on Arndale for me. Does that work for you?
> Whether that is a sensible fix I don't know however.
> 
> > 
> > Mind, maybe the read function should take into account the reset value
> 
> > of the MII, and set it to ADVERTISE_ALL | ADVERTISE_CSMA. I don't have
> 
> > any documention here at the moment.
> 
> Yeah I also have no documentation.
> 
> Thanks,
> Charles
> 
> > 
> > Is anyone able to confirm my suspicions?
> > 
> > Kind regards,
> > 
> > Michel Stam
> > -----Original Message-----
> > From: Riku Voipio [mailto:riku.voipio@iki.fi]
> > Sent: Tuesday, November 04, 2014 10:44 AM
> > To: Stam, Michel [FINT]
> > Cc: Riku Voipio; davem@davemloft.net; linux-usb@vger.kernel.org; 
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> > linux-samsung-soc@vger.kernel.org; ckeepax@opensource.wolfsonmicro.com
> > Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks 
> > net on arndale platform
> > 
> > On Tue, Nov 04, 2014 at 09:19:26AM +0100, Stam, Michel [FINT] wrote:
> > > Interesting, as the commit itself is a revert from a kernel back to
> > > 2.6 somewhere. The problem I had is related to the PHY being reset 
> > > on interface-up, can you confirm that you require this?
> > 
> > I can't confirm what exactly is needed on arndale. I'm neither expert 
> > in USB or ethernet. However, I can confirm that without the PHY reset,
> 
> > networking doesn't work on arndale.
> > 
> > I now see someone else has the same problem, adding Charles to CC.
> > 
> > http://www.spinics.net/lists/linux-usb/msg116656.html
> > 
> > > Reverting this
> > > breaks ethtool support in turn.
> > 
> > Fixing a bug (ethtool support) must not cause breakage elsewhere (in 
> > this case on arndale). This is now a regression of functionality from 
> > 3.17.
> > 
> > I think it would better to revert the change now and with less hurry 
> > introduce a ethtool fix that doesn't break arndale.
> >  
> > > Kind regards,
> > > 
> > > Michel Stam
> > > 
> > > -----Original Message-----
> > > From: Riku Voipio [mailto:riku.voipio@iki.fi]
> > > Sent: Tuesday, November 04, 2014 8:23 AM
> > > To: davem@davemloft.net; Stam, Michel [FINT]
> > > Cc: linux-usb@vger.kernel.org; netdev@vger.kernel.org; 
> > > linux-kernel@vger.kernel.org; linux-samsung-soc@vger.kernel.org
> > > Subject: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net 
> > > on
> > 
> > > arndale platform
> > > 
> > > Hi,
> > > 
> > > With 3.18-rc3, asix on arndale (samsung exynos 5250 based board), 
> > > fails to work. Interface is initialized but network traffic seem not
> 
> > > to pass through. With kernel IP config the result looks like:
> > > 
> > > [    3.323275] usb 3-3.2.4: new high-speed USB device number 4 using
> > > exynos-ehci
> > > [    3.419151] usb 3-3.2.4: New USB device found, idVendor=0b95,
> > > idProduct=772a
> > > [    3.424735] usb 3-3.2.4: New USB device strings: Mfr=1,
> Product=2,
> > > SerialNumber=3
> > > [    3.432196] usb 3-3.2.4: Product: AX88772 
> > > [    3.436279] usb 3-3.2.4: Manufacturer: ASIX Elec. Corp.
> > > [    3.441486] usb 3-3.2.4: SerialNumber: 000001
> > > [    3.447530] asix 3-3.2.4:1.0 (unnamed net_device)
> (uninitialized):
> > > invalid hw address, using random
> > > [    3.764352] asix 3-3.2.4:1.0 eth0: register 'asix' at
> > > usb-12110000.usb-3.2.4, ASIX AX88772 USB 2.0 Ethernet,
> > de:a2:66:bf:ca:4f
> > > [    4.488773] asix 3-3.2.4:1.0 eth0: link down
> > > [    5.690025] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex,
> > lpa
> > > 0xC5E1
> > > [    5.712947] Sending DHCP requests ...... timed out!
> > > [   83.165303] IP-Config: Retrying forever (NFS root)...
> > > [   83.170397] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex,
> > lpa
> > > 0xC5E1
> > > [   83.192944] Sending DHCP requests .....
> > > 
> > > Similar results also with dhclient. Git bisect identified the 
> > > breaking
> > 
> > > commit as:
> > > 
> > > commit 3cc81d85ee01e5a0b7ea2f4190e2ed1165f53c31
> > > Author: Michel Stam <m.stam@fugro.nl>
> > > Date:   Thu Oct 2 10:22:02 2014 +0200
> > > 
> > >     asix: Don't reset PHY on if_up for ASIX 88772
> > > 
> > > Taking 3.18-rc3 and that commit reverted, network works again:
> > > 
> > > [    3.303500] usb 3-3.2.4: new high-speed USB device number 4 using
> > > exynos-ehci
> > > [    3.399375] usb 3-3.2.4: New USB device found, idVendor=0b95,
> > > idProduct=772a
> > > [    3.404963] usb 3-3.2.4: New USB device strings: Mfr=1,
> Product=2,
> > > SerialNumber=3
> > > [    3.412424] usb 3-3.2.4: Product: AX88772 
> > > [    3.416508] usb 3-3.2.4: Manufacturer: ASIX Elec. Corp.
> > > [    3.421715] usb 3-3.2.4: SerialNumber: 000001
> > > [    3.427755] asix 3-3.2.4:1.0 (unnamed net_device)
> (uninitialized):
> > > invalid hw address, using random
> > > [    3.744837] asix 3-3.2.4:1.0 eth0: register 'asix' at
> > > usb-12110000.usb-3.2.4, ASIX AX88772 USB 2.0 Ethernet,
> > 12:59:f1:a8:43:90
> > > [    7.098998] asix 3-3.2.4:1.0 eth0: link up, 100Mbps, full-duplex,
> > lpa
> > > 0xC5E1
> > > [    7.118258] Sending DHCP requests ., OK
> > > [    9.753259] IP-Config: Got DHCP answer from 192.168.1.1, my
> address
> > > is 192.168.1.111
> > > 
> > > There might something wrong on the samsung platform code (I 
> > > understand
> > 
> > > the USB on arndale is "funny"), but this is still an regression from
> 
> > > 3.17.
> > > 
> > > Riku
