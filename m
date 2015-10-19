From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Mon, 19 Oct 2015 09:27:20 +0200
Message-ID: <56249B58.6090100@denx.de>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, anton.a.glukhov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56249491.4020009@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

Am 19.10.2015 um 08:58 schrieb Marc Kleine-Budde:
> On 10/19/2015 08:39 AM, Heiko Schocher wrote:
>> add DT support for the ti hecc controller, used on
>> am3517 SoCs.
>
> A similar patch was posted a few days ago, see
> http://comments.gmane.org/gmane.linux.can/8616 and my comments.

Uh, sorry! Seems I missed them ...

> Please coordinate with Anton Glukhov (Cc'ed) and/or pick up his patches
> as they are in better shape.

Yes, I try the patchset from Anton ... thanks for pointing to them.

@Anton: Do you have a newer version, which contains the comments
         from Marc?

bye,
Heiko
>
> Marc
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> ---
>>
>>   .../devicetree/bindings/net/can/ti_hecc-can.txt    | 20 ++++++++++
>>   arch/arm/boot/dts/am3517.dtsi                      | 13 +++++++
>>   drivers/net/can/ti_hecc.c                          | 45 +++++++++++++++++++++-
>>   3 files changed, 76 insertions(+), 2 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>> new file mode 100644
>> index 0000000..09fab59
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>> @@ -0,0 +1,20 @@
>> +* TI HECC CAN *
>> +
>> +Required properties:
>> +  - compatible: Should be "ti,hecc"
>
> We usually put the name of the first SoC this IP core appears in to the
> compatible.

Ok, so "ti,am335xx-hecc" would be OK?
@Anton: you used "am35x" ... it should be "am35xx"

>> +  - reg: Should contain CAN controller registers location and length
>> +  - interrupts: Should contain IRQ line for the CAN controller
>
> I'm missing the description of the ti,* properties. I think they are
> required, too. Although the code doesn't enforce it.

Ok.

>> +
>> +Example:
>> +
>> +	can0: hecc@5c050000 {
>> +		compatible = "ti,hecc";
>> +		reg = <0x5c050000 0x4000>;
>> +		interrupts = <24>;
>> +		ti,hecc_scc_offset = <0>;
>> +		ti,hecc_scc_ram_offset = <0x3000>;
>> +		ti,hecc_ram_offset = <0x3000>;
>> +		ti,hecc_mbx_offset = <0x2000>;
>> +		ti,hecc_int_line = <0>;
>> +		ti,hecc_version = <1>;
>
> Versioning in the OF world is done via the compatible. Are the offsets a
> per SoC parameter? I'm not sure if it's better to put
> the offsets into the driver.

I am unsure here too..

>> +	};
>> diff --git a/arch/arm/boot/dts/am3517.dtsi b/arch/arm/boot/dts/am3517.dtsi
>> index 5e3f5e8..47bc429 100644
>> --- a/arch/arm/boot/dts/am3517.dtsi
>> +++ b/arch/arm/boot/dts/am3517.dtsi
>> @@ -25,6 +25,19 @@
>>   			interrupt-names = "mc";
>>   		};
>>
>> +		can0: hecc@5c050000 {
>> +			compatible = "ti,hecc";
>> +			reg = <0x5c050000 0x4000>;
>> +			interrupts = <24>;
>> +			ti,hecc_scc_offset = <0>;
>> +			ti,hecc_scc_ram_offset = <0x3000>;
>> +			ti,hecc_ram_offset = <0x3000>;
>> +			ti,hecc_mbx_offset = <0x2000>;
>> +			ti,hecc_int_line = <0>;
>> +			ti,hecc_version = <1>;
>> +			status = "disabled";
>> +		};
>> +
>>   		davinci_emac: ethernet@0x5c000000 {
>>   			compatible = "ti,am3517-emac";
>>   			ti,hwmods = "davinci_emac";
>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>> index c08e8ea..f1705d5 100644
>> --- a/drivers/net/can/ti_hecc.c
>> +++ b/drivers/net/can/ti_hecc.c
>> @@ -875,16 +875,56 @@ static const struct net_device_ops ti_hecc_netdev_ops = {
>>   	.ndo_change_mtu		= can_change_mtu,
>>   };
>>
>> +#if defined(CONFIG_OF)
>> +static const struct of_device_id ti_hecc_can_dt_ids[] = {
>> +	{
>> +		.compatible = "ti,hecc",
>> +	}, {
>> +		/* sentinel */
>> +	}
>> +};
>> +MODULE_DEVICE_TABLE(of, ti_hecc_can_dt_ids);
>> +#endif
>
> Please remove the ifdef, use __maybe_unused instead.
>
>> +
>> +static const struct ti_hecc_platform_data
>> +*ti_hecc_can_get_driver_data(struct platform_device *pdev)
>> +{
>> +	if (pdev->dev.of_node) {
>> +		struct ti_hecc_platform_data *data;
>> +		struct device_node *np = pdev->dev.of_node;
>> +
>> +		data = devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
>> +		if (!data)
>> +			return NULL;
>> +
>> +		of_property_read_u32(np, "ti,hecc_scc_offset",
>> +				     &data->scc_hecc_offset);
>> +		of_property_read_u32(np, "ti,hecc_scc_ram_offset",
>> +				     &data->scc_ram_offset);
>> +		of_property_read_u32(np, "ti,hecc_ram_offset",
>> +				     &data->hecc_ram_offset);
>> +		of_property_read_u32(np, "ti,hecc_mbx_offset",
>> +				     &data->mbx_offset);
>> +		of_property_read_u32(np, "ti,hecc_int_line",
>> +				     &data->int_line);
>> +		of_property_read_u32(np, "ti,hecc_version",
>> +				     &data->version);
>
> I'm missing error handling here.
>
>> +		return data;
>> +	}
>> +	return (const struct ti_hecc_platform_data *)
>> +		dev_get_platdata(&pdev->dev);
>
> Is this cast needed?
>
>> +}
>> +
>>   static int ti_hecc_probe(struct platform_device *pdev)
>>   {
>>   	struct net_device *ndev = (struct net_device *)0;
>>   	struct ti_hecc_priv *priv;
>> -	struct ti_hecc_platform_data *pdata;
>> +	const struct ti_hecc_platform_data *pdata;
>>   	struct resource *mem, *irq;
>>   	void __iomem *addr;
>>   	int err = -ENODEV;
>>
>> -	pdata = dev_get_platdata(&pdev->dev);
>> +	pdata = ti_hecc_can_get_driver_data(pdev);
>>   	if (!pdata) {
>>   		dev_err(&pdev->dev, "No platform data\n");
>>   		goto probe_exit;
>> @@ -1040,6 +1080,7 @@ static int ti_hecc_resume(struct platform_device *pdev)
>>   static struct platform_driver ti_hecc_driver = {
>>   	.driver = {
>>   		.name    = DRV_NAME,
>> +		.of_match_table = of_match_ptr(ti_hecc_can_dt_ids),
>>   	},
>>   	.probe = ti_hecc_probe,
>>   	.remove = ti_hecc_remove,
>>
>
> Marc
>

-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
