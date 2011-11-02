From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Wed, 02 Nov 2011 21:30:59 +0100
Message-ID: <4EB1A883.2040605@hartkopp.net>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET .INT> <20111102080438.GA324@e-circ.dyndns.org> <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA803@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
To: Reuben Dowle <Reuben.Dowle@navico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:56588 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab1KBUbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 16:31:20 -0400
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA803@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2011 20:46, Reuben Dowle wrote:

>>>  	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
>>>
>>> -	kfree_skb(skb);
>>> +	can_put_echo_skb(skb, dev, 0);
>>>
>>>  	/* tx_packets is incremented in flexcan_irq */
>>>  	stats->tx_bytes += cf->can_dlc;
>> Why not move the statistics to the place where the echo_skb is popped?
>> When no frame gets out (due to whatever reason), the statistics may
>> have
>> incremented.
>>
>> Or maybe this needs a seperate patch?
>>
>> The rest looks good.
>>
>> Kurt
> 
> I think you are right - incrementing the tx_bytes at this point does not seem right. It makes most sense to increment the bytes and packets at the same time when tx is confirmed by the interrupt. Looking through the various can drivers, there seems to be 2 approaches to this: at91, slcan and flexcan are incrementing tx_bytes when tx is started, and tx_packets in complete irq, whereas vcan, mcp251x, pch, hecc, softing, sja1000, c_can do it in tx complete irq.
> 
> So I think this is a slightly different issue to the one I was patching, which affects a couple of drivers. The majority of drivers seem to be doing it the way you suggest, but I am not familiar enough with the linux can layer to say one way or the other. I think if it is done how flexcan is doing it, then you would get tx_bytes always gets incremented, even when the tx is dropped due to bus off.
> 
> If we change the behaviour of flexcan, I think at91 and slcan should be changed too, because this should be handled consistently across all drivers I would think.


At least the slcan driver does not support the correct echo of CAN frames on
driver level at all. The slcan driver adapts CAN frames to a serial line CAN
adapter where the feedback of successful transmission is not
guaranteed/checked within the serial data stream. Therefore the interface flag
IFF_ECHO is not set in the slcan driver and the local echo is performed in
af_can.c (as a workaround).

Regards,
Oliver
