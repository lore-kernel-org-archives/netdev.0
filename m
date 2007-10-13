From: Kristian Evensen <kristrev@ifi.uio.no>
Subject: Re: Non-linear SKBs
Date: Sat, 13 Oct 2007 16:53:59 +0200
Message-ID: <4710DC07.5070405@ifi.uio.no>
References: <470EA9AD.4020304@ifi.uio.no>
 <20071011.170024.38701852.davem@davemloft.net>
 <50601.129.240.228.53.1192194927.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: kristrev@student.matnat.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from osl1smout1.broadpark.no ([80.202.4.58]:41787 "EHLO
	osl1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762741AbXJMOtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 10:49:07 -0400
In-reply-to: <50601.129.240.228.53.1192194927.squirrel@webmail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reading through my mail again, I see that I was a bit unclear. What I 
want to achieve is to share a frag between to skbs (where one has no 
earlier referance to it). Sorry.

kristrev@student.matnat.uio.no wrote:
>> If the underlying device can do scatter-gather and checksumming,
>> the TCP code builds outgoing packets by copying user date into
>> full system pages, and then attaching those pages into the SKB.
>> The protocol headers sit under the skb->data linear area, and
>> the user data mostly sits in the user pages under
>> skb_shinfo(skb)->frags[]
>>
>> This increases the density of data packed into the memory allocated
>> compared to using skb->data for it.  It also enormously simplifies
>> the logic necessary to support TSO.
>>     
>
> Thank you very much, I think I am starting to get it now and coming to
> think of it this will make my patch much more elegant. I have spent the
> day reading more code, and am wondering if something along the likes of
> this piece of code will do what I want ("copy" the data from the next skb
> in the retransmission queue into this skb):
>
> //Do preliminary checks to see if the "new" packet will be within mss,
> that this_skb->nr_frags + next_skb->nr_frags < MAX_SKB_FRAGS and so on
>
> int i;
> int this_frags = this_skb->nr_frags;
>
> for(i=0; i<next_skb->nr_frags; i++)
>         //Does the "copy"
>         this_skb->frags[this_frags + i] = next_skb->frags[i];
>
> this_skb->data_len += next_skb->data_len;
> this_skb->truesize += next_skb->data_len;
> this_skb->nr_frags += next_skb->nr_frags;
>
> //Update TSO?
>
> By the way, am I correct in my assumption that one SKB's frags is stored
> linearly in the frags-array? Or have I made a horrible misunderstanding?
> :)
>
> One of the things that I have yet to understand is the frag_list in the
> skb_shared_info-struct. Does this contain all skb's that "use" this frag
> and works as a sort of referance counter (frag won't be removed until the
> variable is NULL and I have to append this_skb to the list), or is it
> something else?
>
> Thanks again for all help.
>
> -Kristian
>
>   

