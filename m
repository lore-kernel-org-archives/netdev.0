From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: Re: [PATCH 1/1] net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet
 MAC driver
Date: Mon, 11 Jan 2010 17:21:14 +0100
Message-ID: <4B4B4FFA.8070805@gaisler.com>
References: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>	 <1262965531-4800-2-git-send-email-kristoffer@gaisler.com> <1262991459.17358.63.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail168c2.megamailservers.com ([69.49.111.68]:57229 "EHLO
	mail168c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709Ab0AKQYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 11:24:41 -0500
In-Reply-To: <1262991459.17358.63.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thanks for the feedback.

Ben Hutchings wrote:
> On Fri, 2010-01-08 at 16:45 +0100, Kristoffer Glembo wrote:
> [...]
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index dd9a09c..806c127 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
> 
> This is just about the worst possible way to configure the MAC address.
> You should be getting it from EEPROM/flash or OpenFirmware properties.

Yes sorry for that ugliness. I will change this to OF properties.

> Is this driver really so good that we should configure it twice?
> 

Maybe not :) .. but I wanted it to show up both in 10/100 and
1000 Mbps since it supports two different devices. But I read in
Kconfig now that it then should be only in 10/100. That's fine.


> [...] 
>> diff --git a/drivers/net/greth.c b/drivers/net/greth.c

>> +#define GRETH_REGLOAD(a)	    (__raw_readl(&(a)))
>> +#define GRETH_REGSAVE(a, v)         (__raw_writel(v, &(a)))
>> +#define GRETH_REGORIN(a, v)         (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) | (v))))
>> +#define GRETH_REGANDIN(a, v)        (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) & (v))))
> 
> I think you need an mmiowb() after the __raw_writel().
> Also, are you sure the registers are going to match host byte order?


I'm working on a CPU with strong ordering so I'm not so confident in these matters,
but as I understand it I should in that case not put mmiowb() after each __raw_writel()
but only before unlocks where mmio has been done in the critical section.

I have not put a single explicit memory barrier in the code, I was under the 
impression that each architecture that needs it has it in the __raw_writel. 
I only used the __raw versions since I wanted native byte ordering. I should add
cpu_to_be32 and be32_to_cpu however as you point out. Questions is do I need to add
wmb/mb when I use __raw as well?


 
> Use print_hex_dump().
> 

Ah nice, thanks!


>> +
>> +			pr_debug(" %.2x", *((unsigned char *)
>> +					    (phys_to_virt
>> +					     (skb_shinfo(skb)->frags[i].page) +
>> +					     skb_shinfo(skb)->frags[i].page_offset + j)));
> 
> WTF?  phys_to_virt() does not work on pointers to struct page.

Oops. Some untested code crept in here. Adding page_to_phys.


I will fix the other issues you mentioned and resend the patch.


Best regards,
Kristoffer Glembo

