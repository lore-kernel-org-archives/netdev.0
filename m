From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 06 Oct 2011 16:33:24 +0200
Message-ID: <4E8DBC34.80607@hartkopp.net>
References: <4E8C78E8.3010605@hartkopp.net> <20111005155127.GB13794@pengutronix.de> <4E8C8175.2040202@hartkopp.net> <4E8D528D.8020607@hartkopp.net> <4E8D7065.8040905@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfram Sang <w.sang@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:16569 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755835Ab1JFOd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 10:33:29 -0400
In-Reply-To: <4E8D7065.8040905@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/11 11:09, Wolfgang Grandegger wrote:

> On 10/06/2011 09:02 AM, Oliver Hartkopp wrote:
>>
>> I think if one would like to rework the 16bit register access (which is used
>> in the rx path /and/ in the tx path also) this should go via net-next after
>> some discussion and testing.
> 
> Why do you want to change 16-bit accesses in general? They are faster
> than two 8 bit accesses. 
> 
>> IMHO this fix is small and clear and especially not risky. I wonder if
>> reworking the 16 bit register access is worth the effort?
> 
> I would prefer:
> 
>  	if (!(frame->can_id & CAN_RTR_FLAG)) {
>  		void __iomem *data = &regs->rx.dsr1_0;
>  		u16 *payload = (u16 *)frame->data;
>  
>  		for (i = 0; i < frame->can_dlc / 2; i++) {
>  			*payload++ = in_be16(data);
>  			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
>  		}
> 		/* copy remaining byte */
> 		if (frame->can_dlc & 1)
> 			frame->data[frame->can_dlc - 1] = in_8(data);
>  	}


Besides the fact that Andre is going to test this idea from Wolfgang now, are
you really sure that it must be

	in_8(data)

and not

	in_8(data+1)

???

And that data definitely points to the right place?

I would prefer to be really cautious with these big endian 16 bit registers!

Therefore my fix with

+		/* zero accidentally copied register content at odd DLCs */
+		if (frame->can_dlc & 1)
+			frame->data[frame->can_dlc] = 0;

only repairing the result looks much more defensive to me.

Regards,
Oliver
