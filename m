From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 18:51:11 -0500
Message-ID: <4B4FADEF.6020408@majjas.com>
References: <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com>
 <4B4CC29E.4020703@majjas.com> <4B4CDC28.2050508@majjas.com>
 <20100112201012.21894fd3@nehalam> <4B4DEEF9.7020806@majjas.com>
 <20100113194148.139091a3@nehalam> <20100114101445.GA7210@ff.dom.local>
 <20100114095254.5cf7faa0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:33261 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab0ANXvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 18:51:43 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta1.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW900MH8GY6UWA0@mta1.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Thu, 14 Jan 2010 18:51:42 -0500 (EST)
In-reply-to: <20100114095254.5cf7faa0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2010 12:52 PM, Stephen Hemminger wrote:
> On Thu, 14 Jan 2010 10:14:45 +0000
> Jarek Poplawski<jarkao2@gmail.com>  wrote:
>
>    
>> This makes it safe, but it still resembles the "short term fix"
>> according do David's opinion.
>>
>> This change seems to affect dev->stats too. Since they are not
>> updated in sky2_tx_clean(). Btw, I hope "&" is some optimization
>> because it's less readable than "&&".
>>      
> Stats don't matter for packets flushed during device reset.
>
> The&  is because in the most common case device is up,
> and we don't want the additional conditional branch.
>    
I've been looking at what might explain the dhcp stuff - as well as the 
dropped packets only when there's an extra hop. I came across one path 
that seems suspect - although I'm really not familiar with the network 
stack code... that said, I'm wondering about neigh_compat_output (and 
eth_rebuild_header and arp_find). If I'm following things correctly (or 
perhaps mostly correctly), the only time anything goes this route (pun 
intentional) is when the packet was routed to this box. I'm guessing 
that bridging makes this more likely. So my dhcp stuff would all be 
going through here, as would the smb stuff that seemed flaky. The race 
I'm seeing (maybe) is that when the arp table is being rebuilt, there's 
a possibility that arp_find frees the skb. There's some other locking 
and stuff going on that seems maybe races with sky2.c in places on both 
the rx and tx path. I *think* it's right from looking at it, but test 
results suggest otherwise. Aside from the potential race, I think 
there's also a corner case where neigh_compat_output can return either 
with or without freeing the skb depending on the return from 
dev_hard_header... this may also be part of the race.

Maybe I've missed something... but as far as I can see, this is just 
about the only difference in code path taken between stuff that is 
working and stuff that is occasionally not.
