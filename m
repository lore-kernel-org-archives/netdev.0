From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v6] net: sh_eth: Add support of device tree probe
Date: Mon, 15 Apr 2013 00:06:49 +0400
Message-ID: <516B0C59.3050207@cogentembedded.com>
References: <1363675196-8940-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <51486699.6000908@cogentembedded.com> <514AB0CB.2030808@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au, mark.rutland@arm.com,
	grant.likely@secretlab.ca
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:58770 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab3DNUHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 16:07:55 -0400
Received: by mail-lb0-f178.google.com with SMTP id q13so3983836lbi.37
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 13:07:53 -0700 (PDT)
In-Reply-To: <514AB0CB.2030808@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-03-2013 11:03, Nobuhiro Iwamatsu wrote:

    Sorry, I have noticed your reply only last Friday. I probably should do 
something with my mail filters, so that they leave the personal mail in my 
inbox and not toss it to the list folders where I may ignore it...

>>> This adds support of device tree probe for Renesas sh-ether driver.

>>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

>>> V6: - Add renesas,sh-eth-gigabit, renesas,sh-eth-sh4 and
>>> renesas,sh-eth-sh3-sh2 to compatible string.
>>> - Remove sh-eth,register-type. This is supplemented by the
>>> compatible string.
>>> - Use the of_property_read_bool instead of of_find_property.
>>> - Add sanity chheck for of_property_read_u32.
>>> - Update document.
>>> V5: - Rewrite sh_eth_parse_dt().
>>> Remove of_device_is_available() and CONFIG_OF from support OF
>>> checking function and re-add empty sh_eth_parse_dt().
>>> - Add CONFIG_PM to definition of dev_pm_ops.
>>> - Add CONFIG_OF to definition of of_device_id.
>>> V4: - Remove empty sh_eth_parse_dt().
>>> V3: - Remove empty sh_eth_parse_dt().
>>> V3: - Removed sentnece of "needs-init" from document.
>>> V2: - Removed ether_setup().
>>> - Fixed typo from "sh-etn" to "sh-eth".
>>> - Removed "needs-init" and sh-eth,endian from definition of DT.
>>> - Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
>>> in definition of DT.
>>> ---
[...]

>>> @@ -2391,12 +2451,33 @@ static int sh_eth_drv_probe(struct platform_device
>>> *pdev)
>>> goto out_release;
>>> }
>>>
>>> + if (np) {
>>> + pd = sh_eth_parse_dt(&pdev->dev, ndev, np);
>>> + if (pdev->dev.platform_data && pd) {
>>> + struct sh_eth_plat_data *tmp =
>>> + pdev->dev.platform_data;
>>> + pd->set_mdio_gate = tmp->set_mdio_gate;
>>> + pd->needs_init = tmp->needs_init;

>> OK, so we can't fully convert this driver to the device tree due to
>> procedural platform data.

>  > I then would advice just using OF_DEV_AUXDATA() in the platform data

    /sdata/code/.

> instead of trying to convert the driver to device tree.

    Convert the platfrom data, I meant. But I already wrote about that I think.

> Yes, I knew about this.

    But still attempted to document and use the data-only device tree 
properties (which was pointless in the light of procediral platfrom data)?

>>> +
>>> +#ifdef CONFIG_OF
>>> +static const struct of_device_id sh_eth_match[] = {
>>> + { .compatible = "renesas,sh-eth-gigabit", },
>>> + { .compatible = "renesas,sh-eth-sh4", },
>>> + { .compatible = "renesas,sh-eth-sh3-sh2", },

>> Biut this is not really enough: the driver supports much more variations of
>> the SH and ARM SoCs
>> all of which have difference not only in register layout but also in the
>> registers bits or even
>> presence of the whole register blocks. All this IMO should be reflected in
>> the different values
>> of the compatible "property". BTW, it seems another register layout and
>> instance needs to be added
>> for the R-Car SoCs (instead of the current ugly hack).

    I've already added it now, it's in the 'net-next' tree.

> I see.
> Latest source code was defined compatible as renesas,sh-eth-gigabit,
> sh-eth-sh4 and sh-eth-sh3-sh2. I will change ito renesas,<CPU>-sh-eth.

    Yes, this is the step in the right direction. Though I'd drop the '-sh' 
infix -- the driver is usable not only on SH platforms.

> And I think that we should define the sh7757-sh-eth-gitabit and
> sh7757-sh-eth-fast for this. Becauase sh7757 is special device.
> There is a device that supports only devices that support fast
> ether and gigabit ether on single CPU.

    Yes, I saw that.

> Therefore, the compatible property of this device becomes <CPU>-sh-eth
> or <CPU>-sh-eth-<ETHER TYPE>.

> How about this?

    Sounds better. I think however that the conversion of this driver to 
device tree shouldn't be done without getting rid of the current #ifdef mess 
in it (which is still on my agenda). I think that the 'register_type' field 
should move from the platform data to the 'struct sh_eth_cpu_data' in the process.

WBR, Sergei
