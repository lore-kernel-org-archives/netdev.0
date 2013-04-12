From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 14:05:41 -0700
Message-ID: <51687725.5060008@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>     <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>     <1365773328.4459.19.camel@edumazet-glaptop>    <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com>   <1365785511.4459.46.camel@edumazet-glaptop> <516850E4.8020504@intel.com>  <1365792277.4459.67.camel@edumazet-glaptop> <51686AAF.4090105@intel.com> <1365798584.4459.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34514 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757140Ab3DLVFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 17:05:43 -0400
In-Reply-To: <1365798584.4459.70.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 01:29 PM, Eric Dumazet wrote:
> On Fri, 2013-04-12 at 13:12 -0700, Alexander Duyck wrote:
>
>> I think part of the trouble is we are debating reworking the wrong
>> function.  We would probably be better off if we could come up with a
>> generic way to handle the ixgbe_pull_tail function.  I think the only
>> complaint I would have in using the __skb_get_poff in there is the fact
>> that it would be copying the header in multiple chunks.  If it worked
>> more like GRO where it just used an offset in the first frag instead of
>> having to copy the headers separately to read them then I would be 100%
>> on board.
> __skb_get_poff() does no copy at all if you provide a linear 'skb'
>
> Its really fast, I am really sorry you have wrong idea of what is going
> on.
>
> static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
>                                        int len, void *buffer)
> {
>         int hlen = skb_headlen(skb);
>
>         if (hlen - offset >= len)
>                 return skb->data + offset;
>
>
> On the other hand GRO engine is way more expensive, now you mention it, we might
> use the flow dissector to speed it.

I am sure it is fast with a linear skb.  I understand what is going on
in that function, and perhaps my original complaint was not clear.  The
issue I had before is the fact that we were using a big uninitialized
blob that was the fake skb, and I really didn't want to deal with the
potential of somebody expecting something there was that possibly
uninitialized.  Instead I would prefer to deal with what we have,
instead of possibly introducing new issues by using uninitialized memory.

The problem is I have a non-linear skb, with nothing in the skb->data
region.  All my code does now is parse frag 0 to get the size of the
head, and then memcpy that out to skb->data and then update lengths and
offsets.  The problem right now is if I call __skb_get_poff it will go
through the portion of that path you didn't call out that does
skb_copy_bits.

What I would need in order to give up my current solution is a function
that I can pass a fully formed non-linear skb to that will efficiently
parse the header out of frag 0 and place it in skb->data.  What I do not
want to do is hand a partially initialized skb off to some kernel
function and hope that it doesn't do anything I didn't account for.

Perhaps it is just best for me to wait and see what you do with GRO
since it has many of the same requirements that I essentially do.

Thanks,

Alex
