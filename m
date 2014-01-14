From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] stmmac: Fix kernel crashes for jumbo frames
Date: Tue, 14 Jan 2014 14:44:35 -0600
Message-ID: <CAOwfj2Ne1oRU1z6BaH4g2_EJJFtJOWbgs2oMzSq5nNpz9G6LsA@mail.gmail.com>
References: <1389719859-29071-1-git-send-email-vbridgers2013@gmail.com>
	<1389719859-29071-3-git-send-email-vbridgers2013@gmail.com>
	<1389729216.2025.197.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, Kumar Gala <galak@codeaurora.org>,
	Dinh Nguyen <dinguyen@altera.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:53670 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaANUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 15:44:37 -0500
In-Reply-To: <1389729216.2025.197.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 1:53 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2014-01-14 at 11:17 -0600, Vince Bridgers wrote:
>> These changes correct the following issues with jumbo frames on the
>> stmmac driver:
>>
>> 1) The Synopsys EMAC can be configured to support different FIFO
>> sizes at core configuration time. There's no way to query the
>> controller and know the FIFO size, so the driver needs to get this
>> information from the device tree in order to know how to correctly
>> handle MTU changes and setting up dma buffers. The default
>> max-frame-size is as currently used, which is the size of a jumbo
>> frame.
>>
>> 2) The driver was enabling Jumbo frames by default, but was not allocating
>> dma buffers of sufficient size to handle the maximum possible packet
>> size that could be received. This led to memory corruption since DMAs were
>> occurring beyond the extent of the allocated receive buffers for certain types
>> of network traffic.
> [...]
>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>> @@ -293,6 +293,8 @@ struct dma_features {
>>  #define STMMAC_CHAIN_MODE    0x1
>>  #define STMMAC_RING_MODE     0x2
>>
>> +#define JUMBO_LEN            9000
>> +
>>  struct stmmac_desc_ops {
>>       /* DMA RX descriptor ring initialization */
>>       void (*init_rx_desc) (struct dma_desc *p, int disable_rx_ic, int mode,
> [...]
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> @@ -51,6 +51,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>>       plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
>>                                          sizeof(struct stmmac_mdio_bus_data),
>>                                          GFP_KERNEL);
>> +     /* Set the maxmtu to a default of 1500 in case the
>> +      * parameter is not present in the device tree
>> +      */
>> +     plat->maxmtu = JUMBO_LEN;
>
> The comment disagrees with the definition of JUMBO_LEN.

ok, I'll address the comment inconsistency. The goal is to maintain
current driver behavior, and add the capability to clip the maximum
MTU supported by the device based on the configuration option selected
when the device was created. Some devices support a maxmtu less than
JUMBO_LEN, but the original driver as upstreamed supported JUMBO_LEN
sized packets.

>
>>
>>       /*
>>        * Currently only the properties needed on SPEAr600
>> @@ -60,6 +64,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>>       if (of_device_is_compatible(np, "st,spear600-gmac") ||
>>               of_device_is_compatible(np, "snps,dwmac-3.70a") ||
>>               of_device_is_compatible(np, "snps,dwmac")) {
>> +             of_property_read_u32(np, "max-frame-size", &plat->maxmtu);
> [...]
>
> Is it the maximum frame size, including Ethernet header?  (And then, is
> the CRC or any VLAN header included in the frame size?)
> Or is it the MTU, excluding all of those?
> You really need to be very clear about what this number represents.

max-frame-size as read from the device tree is defined in the ePAPR
v1.1 specification. I originally used a name of "max-mtu", but was
asked to change that since this attribute was already defined in the
ePAPR v1.1 specification.

I'm using the standard definition of Ethernet MTU, which is the
maximum size of the MAC Client data sans the CRC, DA, SA, and
EtherType fields (IEEE 802.3 2008, Section 3.2.7 - "MAC Client Data
Field"). This matches the regular usage of this attribute by the
device trees in the kernel tree at arch/powerpc/boot/dts. There I see
entries for 1500, 0x5dc, and 9000 for different devices supporting
different MTUs. So in that context, "max-frame-size" is the same as
MTU.

I agree the use of "max-frame-size" in this context and usage is
confusing. I'll clarify in code comments and resubmit if you agree
that's acceptable.

Cheers,

Vince

>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
