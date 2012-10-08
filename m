From: Dong Aisheng-B29396 <B29396@freescale.com>
Subject: RE: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Mon, 8 Oct 2012 07:59:50 +0000
Message-ID: <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net>
References: <5065A35B.3020702@grandegger.com>
 <20121007030858.GJ20231@S2101-09.ap.freescale.net>
 <50719647.4070404@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <50719647.4070404@grandegger.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

>On 10/07/2012 05:09 AM, Shawn Guo wrote:
>> On Fri, Sep 28, 2012 at 03:17:15PM +0200, Wolfgang Grandegger wrote:
>>> Due to a bug in most Flexcan cores, the bus error interrupt needs to
>>> be enabled. Otherwise we don't get any error warning or passive
>>> interrupts. This is _not_ necessay for the i.MX28 and this patch
>>> disables bus error interrupts if "berr-reporting" is not requested.
>>> This avoids bus error flooding, which might harm, especially on
>>> low-end systems.
>>>
>>> To handle such quirks of the Flexcan cores, a hardware feature flag
>>> has been introduced, also replacing the "hw_ver" variable. So far
>>> nobody could tell what Flexcan core version is available on what
>>> Freescale SOC, apart from the i.MX6Q and P1010, and which bugs or
>>> features are present on the various "hw_rev".
>>>
>>> CC: Hui Wang <jason77.wang@gmail.com>
>>> CC: Shawn Guo <shawn.guo@linaro.org>
>>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>>> ---
>>>
>>> Concerning the bug, I know that the i.MX35 does have it. Maybe other
>>> Flexcan cores than on the i.MX28 does *not* have it either. If you
>>> have a chance, please check on the P1010, i.MX6Q, i.MX51, i.MX53,
>>> etc.
>>
>>>From what I can tell, i.MX35, i.MX51 and i.MX53 use the same version,
>> so they should all have the bug.  And for i.MX6Q, since it uses a
>> newer version even than i.MX28, I would believe it's affected by the bug.
>> But I'm copying Dong who should have better knowledge about this to
>> confirm.
>
>Thank for clarification. I have a i.MX6Q board but without CAN adapter :(,
>unfortunately. Otherwise I would try it out myself.
>
How did you verify this issue?
I just checked our ic guy of flexcan, it seems he also had no sense of this issue.

Below is some version info what I got:
Mx6s use FlexCAN3, with IP version 10.00.12.00
Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
Mx35 use FlexCAN2 (without glitch filter) , with IP version 03.00.00.00
Mx25 use FlexCAN2 (without glitch filter), with IP version 03.00.00.00
I'm not sure if mx6q has such issue.

Regards
Dong Aisheng 

>>>  drivers/net/can/flexcan.c |   29 +++++++++++++++++++----------
>>>  1 files changed, 19 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
>>> index c5f1431..c78ecfc 100644
>>> --- a/drivers/net/can/flexcan.c
>>> +++ b/drivers/net/can/flexcan.c
>>> @@ -144,6 +144,10 @@
>>>
>>>  #define FLEXCAN_MB_CODE_MASK		(0xf0ffffff)
>>>
>>> +/* FLEXCAN hardware feature flags */
>>> +#define FLEXCAN_HAS_V10_FEATURES	BIT(1) /* For core version >= 10
>*/
>>> +#define FLEXCAN_HAS_BROKEN_ERR_STATE	BIT(2) /* Broken error state
>handling */
>>> +
>>>  /* Structure of the message buffer */  struct flexcan_mb {
>>>  	u32 can_ctrl;
>>> @@ -178,7 +182,7 @@ struct flexcan_regs {  };
>>>
>>>  struct flexcan_devtype_data {
>>> -	u32 hw_ver;	/* hardware controller version */
>>> +	u32 features;	/* hardware controller features */
>>>  };
>>>
>>>  struct flexcan_priv {
>>> @@ -197,11 +201,11 @@ struct flexcan_priv {  };
>>>
>>>  static struct flexcan_devtype_data fsl_p1010_devtype_data = {
>>> -	.hw_ver = 3,
>>> +	.features = FLEXCAN_HAS_BROKEN_ERR_STATE,
>>>  };
>>> -
>>> +static struct flexcan_devtype_data fsl_imx28_devtype_data;
>>>  static struct flexcan_devtype_data fsl_imx6q_devtype_data = {
>>> -	.hw_ver = 10,
>>> +	.features = FLEXCAN_HAS_V10_FEATURES |
>>> +FLEXCAN_HAS_BROKEN_ERR_STATE,
>>>  };
>>>
>>>  static const struct can_bittiming_const flexcan_bittiming_const = {
>>> @@ -741,15 +745,19 @@ static int flexcan_chip_start(struct net_device
>*dev)
>>>  	 * enable tx and rx warning interrupt
>>>  	 * enable bus off interrupt
>>>  	 * (== FLEXCAN_CTRL_ERR_STATE)
>>> -	 *
>>> -	 * _note_: we enable the "error interrupt"
>>> -	 * (FLEXCAN_CTRL_ERR_MSK), too. Otherwise we don't get any
>>> -	 * warning or bus passive interrupts.
>>>  	 */
>>>  	reg_ctrl = flexcan_read(&regs->ctrl);
>>>  	reg_ctrl &= ~FLEXCAN_CTRL_TSYN;
>>>  	reg_ctrl |= FLEXCAN_CTRL_BOFF_REC | FLEXCAN_CTRL_LBUF |
>>> -		FLEXCAN_CTRL_ERR_STATE | FLEXCAN_CTRL_ERR_MSK;
>>> +		FLEXCAN_CTRL_ERR_STATE;
>>> +	/*
>>> +	 * enable the "error interrupt" (FLEXCAN_CTRL_ERR_MSK),
>>> +	 * on most Flexcan cores, too. Otherwise we don't get
>>> +	 * any error warning or passive interrupts.
>>> +	 */
>>> +	if (priv->devtype_data->features & FLEXCAN_HAS_BROKEN_ERR_STATE ||
>>> +	    priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
>>> +		reg_ctrl |= FLEXCAN_CTRL_ERR_MSK;
>>>
>>>  	/* save for later use */
>>>  	priv->reg_ctrl_default = reg_ctrl;
>>> @@ -772,7 +780,7 @@ static int flexcan_chip_start(struct net_device
>*dev)
>>>  	flexcan_write(0x0, &regs->rx14mask);
>>>  	flexcan_write(0x0, &regs->rx15mask);
>>>
>>> -	if (priv->devtype_data->hw_ver >= 10)
>>> +	if (priv->devtype_data->features & FLEXCAN_HAS_V10_FEATURES)
>>>  		flexcan_write(0x0, &regs->rxfgmask);
>>>
>>>  	flexcan_transceiver_switch(priv, 1); @@ -954,6 +962,7 @@ static
>>> void __devexit unregister_flexcandev(struct net_device *dev)
>>>
>>>  static const struct of_device_id flexcan_of_match[] = {
>>>  	{ .compatible = "fsl,p1010-flexcan", .data =
>>> &fsl_p1010_devtype_data, },
>>> +	{ .compatible = "fsl,imx28-flexcan", .data =
>>> +&fsl_imx28_devtype_data, },
>>>  	{ .compatible = "fsl,imx6q-flexcan", .data =
>&fsl_imx6q_devtype_data, },
>>>  	{ /* sentinel */ },
>>>  };
>>> --
>>> 1.7.7.6
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-can"
>> in the body of a message to majordomo@vger.kernel.org More majordomo
>> info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>


