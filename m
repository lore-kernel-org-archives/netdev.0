From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Wed, 05 Oct 2011 18:10:29 +0200
Message-ID: <4E8C8175.2040202@hartkopp.net>
References: <4E8C78E8.3010605@hartkopp.net> <20111005155127.GB13794@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:30723 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934499Ab1JEQKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 12:10:33 -0400
In-Reply-To: <20111005155127.GB13794@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/11 17:51, Wolfram Sang wrote:

> On Wed, Oct 05, 2011 at 05:34:00PM +0200, Oliver Hartkopp wrote:
>> Due to the 16 bit access to mscan registers there's too much data copied to
>> the zero initialized CAN frame when having an odd number of bytes to copy.
>> This patch clears the data byte read from the invalid register entry.
>>
>> Reported-by: Andre Naujoks <nautsch@gmail.com>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>>
>> ---
>>
>> Hello Wolf[gang|ram],
>>
>> from an error report from Andre Naujoks i tracked down the problem of
>> uninitialized data in (normally) initialized CAN frames to the mscan driver.
>>
>> Regards,
>> Oliver
>>
>>
>> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
>> index 92feac6..1b60fbe 100644
>> --- a/drivers/net/can/mscan/mscan.c
>> +++ b/drivers/net/can/mscan/mscan.c
>> @@ -327,20 +327,23 @@ static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
>>  	frame->can_dlc = get_can_dlc(in_8(&regs->rx.dlr) & 0xf);
>>  
>>  	if (!(frame->can_id & CAN_RTR_FLAG)) {
>>  		void __iomem *data = &regs->rx.dsr1_0;
>>  		u16 *payload = (u16 *)frame->data;
>>  
>>  		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
>>  			*payload++ = in_be16(data);
>>  			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
>>  		}
>> +		/* zero accidentally copied register content at odd DLCs */
>> +		if (frame->can_dlc & 1)
>> +			frame->data[frame->can_dlc] = 0;
>>  	}
>>  
>>  	out_8(&regs->canrflg, MSCAN_RXF);
> 
> Nice catch, but wouldn't it be more elegant to never have an invalid byte
> in the first place?
> 
> if (can_dlc & 1)
> 	*payload = in_be16() & mask;
> 


Hm, then i would rather think about changing the for() statement and to read
byte-by-byte instead of the current in_be16() usage with the 16bit access
drawbacks ...

Regards,
Oliver
