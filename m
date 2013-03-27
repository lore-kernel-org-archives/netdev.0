From: Florian Fainelli <florian@openwrt.org>
Subject: Re: pch_gbe: Expanding PHY and Board support (MinnowBoard)
Date: Wed, 27 Mar 2013 11:53:51 +0100
Message-ID: <5152CFBF.9050407@openwrt.org>
References: <51522E7C.4040204@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@google.com>,
	Tomoya <tomoya-linux@dsn.okisemi.com>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Takahiro Shimizu <tshimizu818@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:46382 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab3C0KyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 06:54:03 -0400
Received: by mail-wg0-f53.google.com with SMTP id c11so347464wgh.20
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 03:54:02 -0700 (PDT)
In-Reply-To: <51522E7C.4040204@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Le 03/27/13 00:25, Darren Hart a =C3=A9crit :
> I'm working on adding support for the MinnowBoard (minnowboard.org) a=
s
> we're working through the last of the hardware changes. There are a f=
ew
> things about the pch_gbe driver that I'm having to update to support
> this board. I'd appreciate your thoughts on how to best go about the
> specializations.
>
> 1) It uses an Atheros AR8031 PHY instead of the more typical Realtek
>     a) This PHY hibernates after 10s of no cable and can prevent
> successful PHY
>        init during PCI probe of the device. This can be addressed by
> disabling
>        hibernation in firmware and enabling later in the Kernel or by
> adding support
>        for the HW Reset of this PHY with the GPIO line tied to it on =
this
> board.
>     b) The board doesn't have a long trace to add the 2ns delay to TX
> clock like
>        other boards using this platform. This can be addressed by
> instructing the
>        PHY to introduce the delay.
>
> 2) Like another board which led to the following commit, this board d=
oes not
>     have an EEPROM for the Ethernet address (MAC).
>
>      commit 2b53d07891630dead46d65c8f896955fd3ae0302
>      Author: Darren Hart <dvhart@linux.intel.com>
>      Date:   Mon Jan 16 09:50:19 2012 +0000
>
>          pch_gbe: Do not abort probe on bad MAC
>
>     On this board, we plan to have the MAC provided by the firmware
> (NVRAM, EFI
>     VAR, something along those lines).
>
> Looking at the driver and our options, using a PCI subsystem
> vendor/device IDs
> to identify the board seems like the best way to go. I have a start a=
t
> this but
> would appreciate your thoughts on the following:
>
> 1) Is the PCI subsystem vendor/device IDs the right approach, e.g. in
> probe():
>
> 	adapter =3D netdev_priv(netdev);
>
> 	/* Identify PCI subsystem ID tweaks */
> 	adapter->hw.mac_in_nvram =3D NULL
> 	adapter->hw.phy.hw_rst_gpio =3D -1;
> 	adapter->hw.phy.tx_clk_delay =3D false;
> 	switch (pdev->subsystem_vendor) {
> 	case PCI_VENDOR_ID_INTEL:
> 		switch (pdev->subsystem_device) {
> 		case PCI_SUBDEVICE_ID_MINNOWBOARD:
> 			pr_debug("MinnowBoard detected\n");
> 			adapter->hw.mac_in_nvram =3D MINNOW_NVRAM_MAC_ADDR;
> 			adapter->hw.phy.hw_reset_gpio =3D MINNOW_PHY_RST_GPIO;
> 			adapter->hw.phy.tx_clk_delay =3D true;
> 	}
>
>     The mac_in_nvram, hw_rst_gpio, and tx_clk_delay vars were added t=
o the
>     existing structures in support of this.

Each PCI device entry in your PCI ID table can be tight to a driver_dat=
a=20
cookie holding device specific information like the one you mention=20
above, this should eliminate the need for the switch/case here. The=20
8250_pci.c driver extensively makes use of this for instance.

>
> 2) The physical reset of the PHY is extremely board and PHY specifc a=
s it
>     requires knowledge of the GPIO line used and the specifics of the
> reset and
>     clock timings on the particular PHY. I believe I can avoid this b=
y just
>     disabling hibernation in firmware and enabling after the driver i=
s
> up. There
>     are scenarios where this could fail though, such as loading the m=
odule,
>     unloading the module, removing the cable, waiting 10+ seconds, an=
d
> trying to
>     load the driver again. It should however load successfully after =
a
> cable was
>     reinserted.

If this board can be uniquely identified using a PCI vendor/device id,=20
then you should be good with this, otherwise, you may need to find for=20
alternate solutions, like checking for a specific DMI string, or=20
whatever the firmware/BIOS can provide to you to uniquely identify this=
=20
board, and thus deduce the GPIO line.

>
> 3) It appears as though the pch_gbe was written with a very specific =
PHY in
>     mind. I've switched on phy.id where needed:
>
> 	switch (hw->phy.id) {
> 	case PHY_AR803X_ID:
> 		pr_info("AR803x PHY: configuring tx clock delay.\n");
> 		...
>
>     But I wonder if converting pch_gbe over to the PHY Abstraction La=
yer and
>     fleshing out the two known PHYs for this platform would be "the r=
ight"
>     approach. Sounds like a lot more work...

I would recommend you switch over to PHYLIB which nicely abstracts all=20
PHY specific details for you, provided that you write a corresponding=20
PHY driver if needed. Looking at the existing pch_gbe driver, it should=
=20
not be too much of work since it seems to already have everything in=20
place, just not tight together. Specifically, here are roughly the step=
s=20
needed:

- pch_gbe_phy.c should be turned into a proper PHY driver (looks like=20
this file supports some kind of internal PHY?
- most of the code in pch_gbe_main.c, especially pch_gbe_init_phy()=20
should be removed or moved to the corresponding PHY driver
- you should register and implement a mdio bus driver for the pch_gbe=20
adapter
--
=46lorian
