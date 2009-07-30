From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Thu, 30 Jul 2009 14:38:59 +0200
Message-ID: <4A719463.2060201@grandegger.com>
References: <20090729082010.GZ2714@pengutronix.de>	<4A7011BA.7040906@grandegger.com>	<20090730083729.GC2714@pengutronix.de>	<4A715F0E.2070605@grandegger.com> <20090730092730.GD2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:52616 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbZG3MjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 08:39:05 -0400
In-Reply-To: <20090730092730.GD2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Thu, Jul 30, 2009 at 10:51:26AM +0200, Wolfgang Grandegger wrote:
>> Sascha Hauer wrote:
>>> On Wed, Jul 29, 2009 at 11:09:14AM +0200, Wolfgang Grandegger wrote:
>>>> Sascha Hauer wrote:
>>>>> And another go...
>>>>>
>>>>> Sascha
>>>>>
>>>>>
>>>>> >From 9f6f6fb67d57d082e056dec8121f1423c1b4fa0b Mon Sep 17 00:00:00 2001
>>>>> From: Sascha Hauer <s.hauer@pengutronix.de>
>>>>> Date: Tue, 21 Jul 2009 10:47:19 +0200
>>>>> Subject: [PATCH] CAN: Add Flexcan CAN driver
>>>>>
>>>>> This core is found on some Freescale SoCs and also some Coldfire
>>>>> SoCs. Support for Coldfire is missing though at the moment as
>>>>> they have an older revision of the core which does not have RX FIFO
>>>>> support.
>>>>>
>>>>> V3: integrated comments from Oliver Hartkopp
>>>>> V2: integrated comments from Wolfgang Grandegger
>>>>>
>>>>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>>>>> ---
>>>>>  drivers/net/can/Kconfig   |    6 +
>>>>>  drivers/net/can/Makefile  |    1 +
>>>>>  drivers/net/can/flexcan.c |  719 +++++++++++++++++++++++++++++++++++++++++++++
>>>>>  3 files changed, 726 insertions(+), 0 deletions(-)
>>>>>  create mode 100644 drivers/net/can/flexcan.c
>>>>>
>>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>>>> index 33821a8..99c6da4 100644
>>>>> --- a/drivers/net/can/Kconfig
>>>>> +++ b/drivers/net/can/Kconfig
>>>>> @@ -74,6 +74,12 @@ config CAN_KVASER_PCI
>>>>>  	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>>>>>  	  4 channel) from Kvaser (http://www.kvaser.com).
>>>>>  
>>>>> +config CAN_FLEXCAN
>>>>> +	tristate "Support for Freescale FLEXCAN based chips"
>>>>> +	depends on CAN_DEV
>>>>> +	---help---
>>>>> +	  Say Y here if you want to support for Freescale FlexCAN.
>>>>> +
>>>>>  config CAN_DEBUG_DEVICES
>>>>>  	bool "CAN devices debugging messages"
>>>>>  	depends on CAN
>>>>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
>>>>> index 523a941..25f2032 100644
>>>>> --- a/drivers/net/can/Makefile
>>>>> +++ b/drivers/net/can/Makefile
>>>>> @@ -8,5 +8,6 @@ obj-$(CONFIG_CAN_DEV)		+= can-dev.o
>>>>>  can-dev-y			:= dev.o
>>>>>  
>>>>>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>>>>> +obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
>>>>>  
>>>>>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
>>>>> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
>>>>> new file mode 100644
>>>>> index 0000000..77661b3
>>>>> --- /dev/null
>>>>> +++ b/drivers/net/can/flexcan.c
>>>> [...]
>>>>> +static void flexcan_error(struct net_device *ndev, u32 stat)
>>>>> +{
>>>>> +	struct can_frame *cf;
>>>>> +	struct sk_buff *skb;
>>>>> +	struct flexcan_priv *priv = netdev_priv(ndev);
>>>>> +	struct net_device_stats *stats = &ndev->stats;
>>>>> +	enum can_state state = priv->can.state;
>>>>> +	int error_warning = 0, rx_errors = 0, tx_errors = 0;
>>>>> +
>>>>> +	skb = dev_alloc_skb(sizeof(struct can_frame));
>>>>> +	if (!skb)
>>>>> +		return;
>>>>> +
>>>>> +	skb->dev = ndev;
>>>>> +	skb->protocol = __constant_htons(ETH_P_CAN);
>>>>> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
>>>>> +
>>>>> +	cf = (struct can_frame *)skb_put(skb, sizeof(*cf));
>>>>> +	memset(cf, 0, sizeof(*cf));
>>>>> +
>>>>> +	cf->can_id = CAN_ERR_FLAG;
>>>>> +	cf->can_dlc = CAN_ERR_DLC;
>>>>> +
>>>>> +	if (stat & ERRSTAT_RWRNINT) {
>>>>> +		error_warning = 1;
>>>>> +		cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>>>>> +	}
>>>>> +
>>>>> +	if (stat & ERRSTAT_TWRNINT) {
>>>>> +		error_warning = 1;
>>>>> +		cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
>>>>> +	}
>>>> What is the meaning of this error warning interrupt? It does *not*
>>>> change the state.
>>> This TWRNINT means that the Tx error counter has transitioned from < 96
>>> to >= 96 (analog the RWRNINT for the Rx error counter). Unfortunately
>>> the state bits handled below do not reflect this error warning state.
>>>
>>> So this interrupt signals us that we have been in error warning state
>>> once but we have no possibility to detect if we are still in error
>>> warning state. I don't know how to handle this correctly. I could
>>> disable this interrupt and ignore it completely.
>>>
>>>>> +	switch ((stat >> 4) & 0x3) {
>>>>> +	case 0:
>>>>> +		state = CAN_STATE_ERROR_ACTIVE;
>>>>> +		break;
>>>>> +	case 1:
>>>>> +		state = CAN_STATE_ERROR_PASSIVE;
>>>>> +		break;
>>>>> +	default:
>>>>> +		state = CAN_STATE_BUS_OFF;
>>>>> +		break;
>>>>> +	}
>>>> I'm still not happy with the error message generation. If a state change
>>>> to error passive happens, it should be signaled to the user. Here my ideas:
>>>>
>>>> 	if (state != priv->can.state) {
>>>> 		if (state == CAN_STATE_ERROR_WARNING) {
>>>> 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>>>> 			priv->can.can_stats.error_warning++;
>>>> 		} else if (state == CAN_STATE_ERROR_PASSIVE) {
>>>> 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
>>>> 			priv->can.can_stats.error_passive++;
>>>> 		}
>>>>
>>>> It might have missed something, though.
>>> Sorry, I missed that from your previous mail. As we can't properly
>>> detect ERROR_WARNING state this would reduce to:
>>>
>>> 	if (state != priv->can.state && state == CAN_STATE_ERROR_WARNING) {
>>> 		cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>>> 		priv->can.can_stats.error_warning++;
>>> 	}
>> Why you can't detect error warning? When the [RT]WRNINT comes, the error
>> waning state has entered. By looking to the manual, the state changes to
>> error warning and bus-off are directly signaled via interrupt. A change
>> to error passive might be visible when bus error ints occurs. You could
>> add some dev_dbg's to the "if (stat & ERRSTAT_[RT]WRNINT)" and "switch"
>> blocks above and check with sending a message with no cable connected.
> 
> Read what I've written above. We get an interrupt on entering
> error warning, but the bits reflecting the actual state only give error
> active, error passive or bus off, but *not* error warning.

You could check the error counters.to verify the real state.

> We could read the error counter and do something like
> 
> 	switch ((stat >> 4) & 0x3) {
> 	case 0:
> 		state = CAN_STATE_ERROR_ACTIVE;
> 		break;
> 	case 1:
> 		state = CAN_STATE_ERROR_PASSIVE;
> 		break;
> 	default:
> 		state = CAN_STATE_BUS_OFF;
> 		break;
> 	}
> 
> 	errcnt = readl(&regs->errcnt);
> 	rxerr = (errcnt >> 8) & 0xff;
> 	txerr = errcnt & 0xff;
> 	if ((rxerr >= 96 || txerr >= 96) && state == CAN_STATE_ERROR_ACTIVE)
> 		state = CAN_STATE_ERROR_WARNING;

Yes, or do not handle the state in the "case 0" above appropriately. The
CAN spec only specifies the bus error states error active, error passive
and bus off. The warning is somehow optional but available on most CAN
controllers. Nevertheless, we should create a message if the ISR
realizes a state changes.

Wolfgang.
