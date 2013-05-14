From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 14 May 2013 11:16:10 +0200
Message-ID: <519200DA.8060102@atmel.com>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <hein_tibosch@yahoo.es>,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	<michal.simek@xilinx.com>, <s.trumtrar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/05/2013 18:05, Jean-Christophe PLAGNIOL-VILLARD :
>
> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>
>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>> introduces clear-on-write on ISR register. This behavior is not always
>> implemented when using Cadence MACB/GEM and is breaking other platforms.
>> We are using a new Device Tree compatibility string and a capability
>> property to actually activate this clear-on-write behavior on ISR.
>>
>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>
> can we detect it via the IP?

As said by Hein, we cannot use the IP revision number. *But* we may have 
the opportunity to read this integration configuration in the Design 
Configuration Register 1 (DCFG1 already used for determining data bus 
width).

So, Michal or Steffen, can you please tell me the value of:
-> bit 23 at register address 0x280: mine is "1" which should mean "IRQ 
read clear", yours should be "0".

Hein, in case of use of the MACB, we do not have this register included, 
so I will avoid to run the test when using MACB (we already have this 
information).

If it works, I plan to rewrite the patch but taking this information 
instead of the device tree compatibility string.

Best regards,

>> ---
>> Documentation/devicetree/bindings/net/macb.txt |  2 ++
>> drivers/net/ethernet/cadence/macb.c            | 15 +++++++++++++--
>> drivers/net/ethernet/cadence/macb.h            |  5 +++++
>> 3 files changed, 20 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
>> index 44afa0e..13ec4f6 100644
>> --- a/Documentation/devicetree/bindings/net/macb.txt
>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> @@ -6,6 +6,8 @@ Required properties:
>>    Use "cdns,at32ap7000-macb" for other 10/100 usage or use the generic form: "cdns,macb".
>>    Use "cnds,pc302-gem" for Picochip picoXcell pc302 and later devices based on
>>    the Cadence GEM, or the generic form: "cdns,gem".
>> +  Use "cdns,zynq-7000-gem" for devices based on Cadence GEM with alternative
>> +  options enabled (ISR clear on write).
>> - reg: Address and length of the register set for the device
>> - interrupts: Should contain macb interrupt
>> - phy-mode: String, operation mode of the PHY interface.
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
>> index 6be513d..628f2b0 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -485,7 +485,8 @@ static void macb_tx_interrupt(struct macb *bp)
>> 	status = macb_readl(bp, TSR);
>> 	macb_writel(bp, TSR, status);
>>
>> -	macb_writel(bp, ISR, MACB_BIT(TCOMP));
>> +	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
>> +		macb_writel(bp, ISR, MACB_BIT(TCOMP));
>>
>> 	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
>> 		(unsigned long)status);
>> @@ -738,7 +739,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
>> 			 * now.
>> 			 */
>> 			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
>> -			macb_writel(bp, ISR, MACB_BIT(RCOMP));
>> +			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
>> +				macb_writel(bp, ISR, MACB_BIT(RCOMP));
>>
>> 			if (napi_schedule_prep(&bp->napi)) {
>> 				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
>> @@ -1474,6 +1476,10 @@ static const struct of_device_id macb_dt_ids[] = {
>> 	{ .compatible = "cdns,macb" },
>> 	{ .compatible = "cdns,pc302-gem" },
>> 	{ .compatible = "cdns,gem" },
>> +	{
>> +		.compatible = "cdns,zynq-7000-gem",
>> +		.data = (void *)MACB_CAPS_ISR_CLEAR_ON_WRITE,
>> +	},
>> 	{ /* sentinel */ }
>> };
>> MODULE_DEVICE_TABLE(of, macb_dt_ids);
>> @@ -1484,6 +1490,7 @@ static int __init macb_probe(struct platform_device *pdev)
>> 	struct macb_platform_data *pdata;
>> 	struct resource *regs;
>> 	struct net_device *dev;
>> +	const struct of_device_id *dev_id;
>> 	struct macb *bp;
>> 	struct phy_device *phydev;
>> 	u32 config;
>> @@ -1558,6 +1565,10 @@ static int __init macb_probe(struct platform_device *pdev)
>>
>> 	dev->base_addr = regs->start;
>>
>> +	dev_id = of_match_device(macb_dt_ids, &pdev->dev);
>> +	if (dev_id)
>> +		bp->caps = (u32)dev_id->data;
>> +
>> 	/* Set MII management clock divider */
>> 	config = macb_mdc_clk_div(bp);
>> 	config |= macb_dbw(bp);
>> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
>> index 993d703..5d622fe 100644
>> --- a/drivers/net/ethernet/cadence/macb.h
>> +++ b/drivers/net/ethernet/cadence/macb.h
>> @@ -323,6 +323,9 @@
>> #define MACB_MAN_READ				2
>> #define MACB_MAN_CODE				2
>>
>> +/* Capability mask bits */
>> +#define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x1
>> +
>> /* Bit manipulation macros */
>> #define MACB_BIT(name)					\
>> 	(1 << MACB_##name##_OFFSET)
>> @@ -574,6 +577,8 @@ struct macb {
>> 	unsigned int 		speed;
>> 	unsigned int 		duplex;
>>
>> +	u32			caps;
>> +
>> 	phy_interface_t		phy_interface;
>>
>> 	/* AT91RM9200 transmit */
>> --
>> 1.8.0
>>
>
>


-- 
Nicolas Ferre
