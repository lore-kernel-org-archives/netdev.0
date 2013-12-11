From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Wed, 11 Dec 2013 20:17:41 +0800
Message-ID: <CAGb2v64qQvqJSicA6MTAxeh1sGjWY=Pk=vDq=9J3pTQW+wkXrA@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org> <52A5A52C.50605@st.com>
 <CAGb2v67WiCaMpJEzA_X6o7uOu6i3w3FCEz7=N5HY0amQb01SZA@mail.gmail.com> <52A72C6D.60100@st.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: srinivas kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBB6VPUGKQKGQE5NN564Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <52A72C6D.60100-qxv4g6HH51o@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Dec 10, 2013 at 10:59 PM, srinivas kandagatla
<srinivas.kandagatla-qxv4g6HH51o@public.gmane.org> wrote:
>
> On 09/12/13 17:34, Chen-Yu Tsai wrote:
>> Hi,
>>
>> On Mon, Dec 9, 2013 at 7:10 PM, srinivas kandagatla
>> <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org> wrote:
>>> Hi Chen,
>>> Good to know that Allwinner uses gmac.
>>
>> To my knowledge, Allwinner has never confirmed this.
>>
>>> On ST SoC, we have very similar requirements, before we merge any of
>>> these changes I think we need to come up with common way to solve both
>>> Allwinner and ST SOCs use cases.
>>>
>>> I have already posted few patches on to net-dev
>>> http://lkml.org/lkml/2013/11/12/243 to add Glue driver on top of stmmac
>>> driver.
>>>
>>>
>>> There are few reasons for the way I have done it.
>>>
>>> 1> I did not want to modify gmac driver in any sense to when a new SOC
>>> support is added.
>>
>> My approach would add one line (compatible strings) each time.
>
> This would be a best case, But in reality the defination of the
> configuration register can change per each soc, so the data associated
> with it will also change and hence you will have to change more than
> then just compatible strings.

This could also be delegated to .data with an extra data structure.
See drivers/i2c/busses/i2c-mv64xxx.c for an example, which was done
by Maxime.

>>> 2> As the SOC specific glue logic sits on top of standard GMAC IP, it
>>> makes sense to represent it proper harware hierarchy.
>>
>> My feeling is that the SoC specifics are not a glue layer around dwmac,
>> rather an interconnected extension. Arguably I do not have the whole
>> picture. Allwinner has refused to provide us with any specifics beyond
>> the SoC manual and drivers. As such I can only make educated guesses on
>> how the dwmac core interacts with the other modules.
>
> I would be good to get actual picture of this hw setup, On ST the
> additional glue logic which sits on top of the GMAC is to resposible for
> selecting the correct retime clock.

I would have liked to look at the internal design, how the dwmac core
is connected to the clock control, but that is out of the question.
Still, based on the documents, I think our clock controller is partially
intertwined with the GMAC. It takes GMAC's internally generated clock
as one of several inputs, then sends it back to the GMAC to time tx data.

Judging by the register definitions listed in the A20 manual,
the SoC glue layer clocks is something like this:

                               _________________________
  MII TX clock from PHY >-----|___________    _________|----> to GMAC core
  GMAC Int. RGMII TX clk >----|___________\__/__gate---|----> to PHY
  Ext. 125MHz RGMII TX clk >--|__divider__/            |
                              |________________________|


For MII mode, the glue layer should select the TX clock from the PHY.
The gate to the PHY should be disabled.

For RGMII mode, either the internal clock generated by the GMAC core,
or the external 125MHz reference generated by the PHY can be selected.
And the clock gate to the PHY should be enabled.
If the 125MHz reference is used, the glue layer should select the proper
divider (/1, /5, /50) based on the link speed.

For GMII mode, under 10/100 speeds, the operation matches MII mode.
For gigabit speeds, should use a 125MHz clock (internal or external)
and enable the output gate.

The glue layer may indeed sit on top or around the GMAC core.
Nevertheless, its operational state does depend on the GMAC.
The current callbacks present in the stmmac driver are a good model
for this.

>>> 3> Did not want to change any generic gmac bindings for SOC specific
>>> stuff as requirements if SOC glue would be very different in each case.
>>
>> We could try to define a standard set of clocks and reset controllers.
>> The dwmac does not have much additional tunables in the driver.
>> Anything else should be SoC specific, put in an extension, and
>> documented as such.
>
> I think it will be impossible to standardize SOC specifics as this
> glue/logic keeps changing across SOCs/Vendors.

If the GMAC core accepts external inputs for reset and tx clock,
they should be part of the generic driver core.

I think that is what the ST platform needs as well. Is it possible
to model the ST platform tx clock selection as a clock?

>>> I see issues with this approach, which are addressed in my patches.
>>>
>>> Please have a look at the http://lkml.org/lkml/2013/11/12/462 patch on
>>> STi SOC glue, which does implement a very similar glue driver.
>>>
>>> Do you see any issues not to do that way?
>>
>> The glue layer driver would not have access to any of dwmac driver's
>> internals, nor could it respond to any state changes.
>
> Should it have access to this in the first place?
> Should SOC Glue driver actually change the internal data structures of
> the stmmac? I guess No.
>
> I think all you need is to know the interface type which can be derived
> from a child node as I did in my glue driver.

The interface type is not enough. In GMII mode, you would have to change
the tx clock parent to match the link speed, as I mentioned in a previous
section.

>>
>> For example, .fix_mac_speed is called whenever auto-negotiation happens,
>> or when the link goes down or up. Maybe some future SoC would need this.#
> Makes sense..
>
> Yes, On ST we need this too, but max-speed would limit the device
> capability. But I think its more complicated than just setting up
> divider, most of the configuration depends on board hw setup.
>
> Ex: TX clk can come from external clk or phyclk or txclk itself...
>
> So the call I have taken here is to support only speeds based on the
> max-speed property.

So you would be supporting 10/100 for MII, and 10/100/1000 or 10/100
for RGMII, depending on the available clock input.
What about GMII?

Doesn't this seem a bit self-limiting? You have a gigabit capable
MAC and PHY, but you are not using it to its full potential.

>> The Allwinner A20 has the option to use the external 125MHz clock
>> provided by the PHY for the tx clock under RGMII mode, with multiple
>> dividers yielding 125, 25, or 2.5 MHz. It seems this would require
>
> Why should not the this be represented in a proper clock( "phyclk" )
> which can be setup and driven the mac driver it self.

This I am working on. Here is what I propose:

stmmac takes a second optional clock, named "tx_clk".
The clock provider should:

  1. put the glue layer into MII mode when the clock is disabled
  2. put the glue layer into RGMII mode when the clock is enabled
  3. support clk_set_rate at 125, 25, or 2.5 MHz for RGMII link
     speed changes. This could be a no-op for the internal clock.

While we're at it, we can also make stmmac take an optional reset handler.

I think this solves both our problems, while being both generic and
part of the gmac core hardware.

The rest of my requirements for Allwinner A20/A31 gmac can be solved
with proper PHY node support, which I will implement, and
"snps,force_sf_dma_mode" and "snps,tx-coe" properties.

>> .fix_mac_speed, though I have not tested it. My goal was to produce
>> a usable driver, rather than test all the possibilities.
>>
>> The other issue is when the glue layer needs to set SoC specific
>> implementation details of the dwmac, when it is not possible to
>> add a generic dwmac compatible. See next section for more on this.
>>
>>> On 06/12/13 17:29, Chen-Yu Tsai wrote:as
>>>> The Allwinner A20 has an ethernet controller that seems to be
>>>> an early version of Synopsys DesignWare MAC 10/100/1000 Universal,
>>>> which is supported by the stmmac driver.
>>>>
>>>> Allwinner's GMAC requires setting additional registers in the SoC's
>>>> clock control unit.
>>>>
>>>> The exact version of the DWMAC IP that Allwinner uses is unknown,
>>>> thus the exact feature set is unknown.
>>>>
>>>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>>>> ---
>>>>  .../bindings/net/allwinner,sun7i-gmac.txt          | 22 +++++++
>>>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 ++++
>>>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 76 ++++++++++++++++++++++
>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +lot
>>>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
>>>>  6 files changed, 117 insertions(+)
>>>> http://lkml.org/lkml/2013/11/12/462
>>>> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
>>>
>>>> --- /dev/null
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
>>>> @@ -0,0 +1,76 @@
>>>> +/**
>>>> + * dwmac-sunxi.c - Allwinner sunxi DWMAC specific glue layer
>>>> + *
>>>> + * Copyright (C) 2013 Chen-Yu Tsai
>>>> + *
>>>> + * Chen-Yu Tsai  <wens-jdAy2FN1RRM@public.gmane.org>
>>>> + *
>>>> + * This program is free software; you can redistribute it and/or modify
>>>> + * it under the terms of the GNU General Public License as published by
>>>> + * the Free Software Foundation; either version 2 of the License, orhttp://lkml.org/lkml/2013/11/12/462
>>>> + * (at your option) any later version.
>>>> + *http://lkml.org/lkml/2013/11/12/462
>>>> + * This program is distributed in the hope that it will be useful,http://lkml.org/lkml/2013/11/12/462
>>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty ofas
>>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>>> + * GNU General Public License for more details.
>>>> + */
>>>> +
>>>> +#include <linux/clk.h>
>>>> +#include <linux/phy.h>
>>>> +#include <linux/stmmac.h>
>>>> +
>>>> +#define GMAC_IF_TYPE_RGMII   0x4
>>>> +
>>>> +#define GMAC_TX_CLK_MASK     0x3
>>>> +#define GMAC_TX_CLK_MII              0x0
>>>> +#define GMAC_TX_CLK_RGMII_INT        0x2
>>>> +
>>>> +static int sun7i_gmac_init(struct platform_device *pdev)
>>>> +{
>>>> +     struct resource *res;
>>>> +     struct device *dev = &pdev->dev;
>>>> +     void __iomem *addr = NULL;
>>>> +     struct plat_stmmacenet_data *plat_dat = NULL;
>>>> +     u32 priv_clk_reg;
>>>> +
>>>> +     plat_dat = dev_get_platdata(&pdev->dev);
>>> This is not valid for DT case.
>>> In DT case stmmac maintains its own instance of platform data.
>>>
>>> Setting platform data dynamically after probe to a device is not the
>>> right way to do.
>>
>> I see. And stmmac's own instance of platform data is associated with the
>> device in stmmac_dvr_probe. To make this work, we would have to move
>> setting dev->priv->plat in front of the .init callback.
>
> No it would not work either, as platform data is stmmac is stored in its
> private data structure.

With these modifications, the .init and .exit callbacks will have access
to stmmac's private data structure, as they are passed dev as the sole
argument.

>>>> +     if (!plat_dat)as
>>>> +             return -EINVAL;
>>>> +
>>>> +     /* Get GMAC clock register in CCU */
>>>> +     res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>>>> +     addr = devm_ioremap_resource(dev, res);
>>>> +     if (IS_ERR(addr))
>>>> +             return PTR_ERR(addr);
>>>> +
>>>> +     priv_clk_reg = readl(addr);
>>>> +
>>>> +     /* Set GMAC interface port mode */
>>>> +     if (plat_dat->interface == PHY_INTERFACE_MODE_RGMII)
>>>> +             priv_clk_reg |= GMAC_IF_TYPE_RGMII;
>>>> +     else
>>>> +             priv_clk_reg &= ~GMAC_IF_TYPE_RGMII;
>>>> +
>>>> +     /* Set GMAC transmit clock source. */
>>>> +     priv_clk_reg &= ~GMAC_TX_CLK_MASK;
>>>> +     if (plat_dat->interface == PHY_INTERFACE_MODE_RGMII
>>>> +                     || plat_dat->interface == PHY_INTERFACE_MODE_GMII)
>>>> +             priv_clk_reg |= GMAC_TX_CLK_RGMII_INT;
>>>> +     else
>>>> +             priv_clk_reg |= GMAC_TX_CLK_MII;
>>>> +
>>>> +     writel(priv_clk_reg, addr);
>>>> +
>>>> +     /* mask out phy addr 0x0 */
>>>> +     plat_dat->mdio_bus_data->phy_mask = 0x1;
>>>> +per
>>>> +     return 0;
>>>> +}
>>>> +
>>> This routine would not scale..
>>>
>>> stmmac can call init function multiple times, so you would be parsing DT
>>> and also remapping the address multiple times.
>>
>> I should save the mapped address, and check if it was mapped before.
>> Or we could split it into .probe and .init, where .probe is call in
>> stmmac_pltfr_probe, and .init is called in stmmac_open.
>>
>>> [---
>>>> +const struct plat_stmmacenet_data sun7i_gmac_data = {
>>>> +     .has_gmac = 1,
>>>> +     .tx_coe = 1,
>>>> +     .init = sun7i_gmac_init,
>>>> +};
>>>> +
>>> ---]
>>>
>>> This looks exactly like a AUXDATA way of doing things.
>>> Again stmmac driver has to make a copy of this so that I would not get a
>>> same copy for multiple instances.
>>
>> In the patch series, stmmac will make a copy.
>> Though that part needs some fixes.
>>
>> On a side note, the impression I got for not using AUXDATA is that it pushes
>> what is supposed to be driver extensions to the SoC/board specific code areas.
>>
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> index f16a9bd..c6e1f93 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> @@ -130,6 +130,9 @@ void stmmac_disable_eee_mode(struct stmmac_priv *priv);
>>>>  bool stmmac_eee_init(struct stmmac_priv *priv);
>>>>
>>>
>>>
>>> [...
>>>>  #ifdef CONFIG_STMMAC_PLATFORM
>>>> +#ifdef CONFIG_DWMAC_SUNXI
>>>> +extern const struct plat_stmmacenet_data sun7i_gmac_data;
>>>> +#endif
>>>>  extern struct platform_driver stmmac_pltfr_driver;
>>>>  static inline int stmmac_register_platform(void)
>>>>  {
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> index df3fd1c..6cf8292 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> @@ -35,6 +35,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
>>>>       { .compatible = "snps,dwmac-3.70a"},
>>>>       { .compatible = "snps,dwmac-3.710"},
>>>>       { .compatible = "snps,dwmac"},
>>>> +#ifdef CONFIG_DWMAC_SUNXI
>>>> +     { .compatible = "allwinner,sun7i-gmac", .data = &sun7i_gmac_data},
>>>> +#endif
>>> ...]
>>>
>>> Personally, I did not want to do this kind of stuff in stmmac, As this
>>> list would keep growing, and this file need to be edited for every new
>>> SOC or every different type of glue logic.
>>>
>>> Please let me know what your opnion on doing Allwinner glue driver in
>>> line with http://lkml.org/lkml/2013/11/12/462
>>
>>
>> I needed to set some fields in the platform data,
>> as was set in the driver provided by Allwinner, and
>> out of our own needs.
>
>>
>> 1. .tx_coe
>>    This is not exported in the DT bindings.
>>    Looking at stmmac code, not setting this seems to disable all
>>    checksum offloading.
>
> Why cant this go via DT as well?

If you and Giuseppe are OK with this, why not?
There are quite a few options not exposed to DT.

Or we could add a compatible like "snps,dwmac-tx-coe" to signal
it can use checksum offloading. I'm not sure which is better.

> I think, this will be overriden by stmmac on MACs > 3.50a.

It will, because of the DMA hardware capabilities register.
But the MAC in A20 is not > 3.50a, hence the need to set it
manually.

>>
>> 2. .force_sf_dma_mode
>>    I have added DT property handling for this.
> Ok,
>>
>> 3. .mdio_bus_data
>>    The PHY mask is something we would like to have at the board level.
>>    The PHY on one of our boards, RTL8211E from Realtek, responds to
>>    commands sent to phy address 0, regardless what it's actual address is.
>
> Sounds correct.as
>
>>    This is documented in RTL8211E's datasheet:
>>
>>       The RTL8211E-VB(VL)/RTL8211EG-VB support PHY addresses from 00001 to
>>       00111. PHY address 0 is a broadcast from the MAC; each PHY device
>>       should respond.
>>
>>    Without the PHY mask, probing the MDIO bus would yield two devices,
>>    when in reality there is only one. This results in some confusion.
> Can you explain the issue in more detail.
>
> Why is it a confusion? PHYs are supposed to respond to address 00000.

If you look under /sys/bus/mdio_bus/devices/, for PHYs supporting
address 00000 as broadcast, you would see 2 devices.
stmmac debug messages will also report 2 devices found.

Also, not all PHY devices respond to address 00000.
The Realtek RTL8201CP PHY on one of our other boards, does not.

I could not find a reference to "supposed to respond to address 00000".
IEEE 802.3 only defines the address space, not intended uses.

> MDIO bus could have multiple PHYS on the bus, it does not matter as long
> as you address them with correct PHYID.

Correct. I assume by PHYID you mean PHY address.
Florian has pointed out that "snps,phy-addr" is !standard, and we
should replace it with standard PHY node support. I can address this
in the patch series.

Thanks,
ChenYu

> Thanks,
> srini
>>
>>    This should definitely be exported as a DT binding.
>>
>> I am also unable to add a generic compatible string for our particular
>> dwmac, because I do not know the exact version of the IP, only that
>> it is earlier than 3.50. No hardware DMA capability flags.
>>
>> Using something like "snps,dwmac-pre-3.50" is IMO worse.
>>
>>>>       { /* sentinel */ }
>>>>  };
>>>>  MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
>>>>
>>>
>>
>> ChenYu
>>
>>
>
