From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2: hw checksum failures
Date: Tue, 05 Sep 2006 08:00:12 -0700
Message-ID: <44FD90FC.4090409@osdl.org>
References: <1157416603.22705.62.camel@localhost.localdomain>	 <20060904203442.1c9ed2eb@localhost.localdomain>	 <1157427758.22705.65.camel@localhost.localdomain>	 <20060904205645.6c80f30c@localhost.localdomain> <1157431548.22705.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15827 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965073AbWIEPA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 11:00:29 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157431548.22705.78.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> On Mon, 2006-09-04 at 20:56 -0700, Stephen Hemminger wrote:
>   
>> On Tue, 05 Sep 2006 13:42:38 +1000
>> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>>
>>     
>>> On Mon, 2006-09-04 at 20:34 -0700, Stephen Hemminger wrote:
>>>       
>>>> Unneeded byte swap was occurring.
>>>>
>>>> --- linux-2.6.orig/drivers/net/sky2.c
>>>> +++ linux-2.6/drivers/net/sky2.c
>>>> @@ -2001,7 +2001,7 @@ static int sky2_status_intr(struct sky2_
>>>>  		case OP_RXCHKS:
>>>>  			skb = sky2->rx_ring[sky2->rx_next].skb;
>>>>  			skb->ip_summed = CHECKSUM_HW;
>>>> -			skb->csum = le16_to_cpu(status);
>>>> +			skb->csum = status;
>>>>  			break;
>>>>  
>>>>  		case OP_TXINDEXLE:
>>>>         
>>> I've removed it in my paches (have you seen the other patches I sent for
>>> this driver ?), though I'm pre-swapping status and lenght now before the
>>> switch/case so there might still be an issue there. I'll have a look.
>>>       
>> The other tack would be to leave the "reverse in hw" flag on and take out all the existing
>> swap calls but then you have to add an ifdef to re-order all the structures for tx_le, rx_le, status_le.
>> That is what the vendor (GPL) version of sk98lin does.
>>     
>
> I prefer keeping the HW swap out of the way for now... that way, I know
> the card will react exactly like in an x86, and I avoid those ugly
> ifdef's. At least on powerpc, there is no cost in doing swap in software
> (well, pretty much no cost).
>
> Which means that if it worked on x86 with le16_to_cpu, it should work on
> powerpc... The main difference here however is that you called
> le16_to_cpu (which is basically a nop) on a 32 bits field, while I
> called le32_to_cpu() on it. But both should lead to the same ... (x86
> will do a swapped 16 bits load of the 2 first bytes, while ppc will do a
> load of 4 bytes and swap that, thus ending up with the first 2 bytes
> swapped in the low order of the result). I'll dump the values and have a
> look to be sure. Another possibility would be a problem with the bits
> telling the chip where to calculate the checksum.
>   
Hardware only computes 16 bit checksum.
