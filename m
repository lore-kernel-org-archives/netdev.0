From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible regression in HTB
Date: Tue, 07 Oct 2008 14:48:18 +0200
Message-ID: <48EB5A92.6010704@trash.net>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007122052.GA4328@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44687 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYJGMs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:48:27 -0400
In-Reply-To: <20081007122052.GA4328@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>>> Prior to this patch the result looks like this:
>>>
>>> 10194: 545134589bits/s 545Mbits/s
>>> 10197: 205358520bits/s 205Mbits/s
>>> 10196: 205311416bits/s 205Mbits/s
>>> -----------------------------------
>>> total: 955804525bits/s 955Mbits/s
>>>
>>> And after the patch the result looks like this:
>>> 10194: 384248522bits/s 384Mbits/s
>>> 10197: 284706778bits/s 284Mbits/s
>>> 10196: 288119464bits/s 288Mbits/s
>>> -----------------------------------
>>> total: 957074765bits/s 957Mbits/s

I've misinterpreted the numbers, please disregard my previous mail.

I'm wondering though, even before this patch, the sharing doesn't
seem to be proportional to the allocated rates. Assuming the upper
limit is somewhere around 950mbit, we have 250 mbit for sharing
above the allocated rates, so it should be:

500mbit class: 500mbit + 250mbit/7*5 == 678.57mbit
100mbit class: 100mbit + 250mbit/1*5 == 150mbit
100mbit class: 100mbit + 250mbit/1*5 == 150mbit

But maybe my understanding of how excess bandwidth is distributed
with HTB is wrong.

> So, in short, the results with requeuing off show the first class
> doesn't get its rate while the others can borrow.
> 
> My first (maybe wrong) idea is that requeuing could be used here for
> something it wasn't probably meant to. The scenario could be like this:
> the first (and most privileged) class is sending until the card limit,
> and when the xmit is stopped and requeuing on, it slows the others
> (while it has to wait anyway) with requeuing procedures plus gets
> "additional" packet in its queue.
> 
> In the "requeuing off" case there should be a bit more time for others
> and each packet seen only once.
> 
> Since it looks like HTB was lending unused rate, it had to try the first
> class first, so if it didn't use this, probably there were not enough
> packets in its queue, and as mentioned above, requeuing code could help
> to get them, and so to prevent lending to others, when there is not
> enough enqueuing in the meantime.
> 
> So, maybe my diagnose is totally wrong, but there are the questions:
> 
> 1) Is HTB or other similar scheduling code expected to limit correctly
>    while we substantially overlimit (since requeuing should be used so
>    much)?
> 2) Should requeuing be considered as such important factor of
>    controlling the rates?
> 
> I've some doubts it should work like this.

I still can't really make anything of this bug, but the only two
visible differences to HTB resulting from requeing on an upper level
should be that

1) it doesn't reactivate classes that went passive by the last dequeue
2) the time checkpoint from the last dequeue event is different

I guess its in fact the second thing, if a lower priority packet
is requeued and dequeued again, HTB doesn't notice and might allow
the class to send earlier again than it would have previously.

Simon, if you set the ceiling to something around the real limit
you're able to reach (maybe try 940mbit), do the proportions change
significantly?
