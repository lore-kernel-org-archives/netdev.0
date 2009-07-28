From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V2] CAN: Add Flexcan CAN controller driver
Date: Tue, 28 Jul 2009 15:50:48 +0200
Message-ID: <4A6F0238.6050605@hartkopp.net>
References: <20090728120624.GS2714@pengutronix.de> <4A6EFB64.8070804@hartkopp.net> <20090728133719.GU2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:34617 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbZG1Nuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 09:50:50 -0400
In-Reply-To: <20090728133719.GU2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> Hi Oliver,
> 
> On Tue, Jul 28, 2009 at 03:21:40PM +0200, Oliver Hartkopp wrote:
>> Sascha Hauer wrote:
>>> Hi,
>>>
>>> Here is the second version of the flexcan driver.
>> Hi Sascha,
>>
>> some more points i forgot to mention, sorry ...
>>
>>
>>> +/* Structure of the message buffer */
>>> +struct flexcan_mb {
>>> +	u32	can_dlc;
>>> +	u32	can_id;
>>> +	u32	data[2];
>>> +};
>> This looks really hackish and does not reflect the structure of a flexcan
>> message buffer! The data is 'u8' and the name of 'dlc' for the
>> description/flag register is bad.
>>
> 
> see below..

Especially can_dlc, can_id and data[] are known from struct can_frame which
really can confuse here ...

> 
>>> +
>>> +static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>> +{
>>> +	struct can_frame *frame = (struct can_frame *)skb->data;
>>> +	struct flexcan_priv *priv = netdev_priv(dev);
>>> +	struct flexcan_regs __iomem *regs = priv->base;
>>> +	u32 can_id;
>>> +	u32 dlc = MB_CNT_CODE(0xc) | (frame->can_dlc << 16);
>> Naming this variable 'dlc' does not hit the point. See below.
>>
>>> +	u32 *can_data;
>> Really this needs to be fixed up by defining a proper mailbox struct.
>>
>>
>>> +
>>> +	netif_stop_queue(dev);
>>> +
>>> +	if (frame->can_id & CAN_EFF_FLAG) {
>>> +		can_id = frame->can_id & MB_ID_EXT;
>> Please use CAN_EFF_MASK here.
> 
> I used MX_ID_EXT intentionally because it it flexcan specific and just
> happens to be the same as CAN_EFF_MASK. I can change it if you like.

Yes, i've seen that. I would tend to use CAN_EFF_MASK here as you apply it on
frame->can_id.

When you get it from the controller MB_ID_EXT_MASK would be the better one.

> 
>>
>>> +		dlc |= MB_CNT_IDE | MB_CNT_SRR;
>>> +	} else {
>>> +		can_id = (frame->can_id & CAN_SFF_MASK) << 18;
>>> +	}
>> Just nitpicking for Kernel coding style:
>> remove the last '{' and '}' pair.
> 
> No, Documentation/CondingStyle suggests that if one branch needs braces
> the other branch should use them, too.

Sorry. Didn't know that.

> 
>>> +
>>> +	if (frame->can_id & CAN_RTR_FLAG)
>>> +		dlc |= MB_CNT_RTR;
>>> +
>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
>>> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
>>> +
>>> +	can_data = (u32 *)frame->data;
>>> +	writel(cpu_to_be32(*can_data), &regs->cantxfg[TX_BUF_ID].data[0]);
>>> +	writel(cpu_to_be32(*(can_data + 1)), &regs->cantxfg[TX_BUF_ID].data[1]);
>> IMHO it is not really transparent, that this is a correct handling to copy the
>>   can_frame.data[] on all architectures. I bet creating a for-statement
>> regarding the dlc is not slower and makes really clear, what's going on here.
> 
> This is indeed a problem here. The original Coldfire code I used as a
> template used a loop around unsigned char * which did the wrong thing
> for me.

This could be a good starting point for an investigation ;-)

> So yes, this is not generic here, but I have no idea how the
> generic code looks like. As Coldfire is big endian this doesn't seem
> that wrong.

I would try to define a proper flexcan_mb struct like

struct flexcan_mb {
	u8 code;
	u8 ctrl;
	u16 timestamp;
	u32 id;
	u8 data[8];
}

And then see how it looks like ;-)

Regards,
Oliver

