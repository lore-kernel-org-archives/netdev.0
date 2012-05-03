From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: take care of cloned skbs in tcp_try_coalesce()
Date: Wed, 02 May 2012 20:00:19 -0700
Message-ID: <4FA1F4C3.8000804@gmail.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>	 <1335835677.11396.5.camel@edumazet-glaptop>	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>	 <1335977179.22133.599.camel@edumazet-glaptop> <4FA17781.6080306@intel.com>	 <1335982515.22133.610.camel@edumazet-glaptop> <4FA19F5B.7040407@intel.com> <1336009974.22133.706.ca
 mel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62989 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab2ECDA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 23:00:27 -0400
Received: by pbbrp8 with SMTP id rp8so1873962pbb.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 20:00:26 -0700 (PDT)
In-Reply-To: <1336009974.22133.706.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 6:52 PM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 13:55 -0700, Alexander Duyck wrote:
>> On 05/02/2012 11:15 AM, Eric Dumazet wrote:
>>> On Wed, 2012-05-02 at 11:05 -0700, Alexander Duyck wrote:
>>>> You're correct about the fragstolen case, I actually was thinking of the
>>>> first patch you sent, not this second one.
>>>>
>>>> However we still have a problem.  What we end up with now is a case of
>>>> sharing in which the clone skb no longer knows that it is sharing the
>>>> head with another skb.  The dataref will drop to 1 when we call
>>>> __kfree_skb.  This means that any other function out there that tries to
>>>> see if the skb is shared would return false.  This could lead to issues
>>>> if there is anything out there that manipulates the data in head based
>>>> on the false assumption that it is not cloned.  What we would probably
>>>> need to do in this case is tweak the logic for skb_cloned.  If you are
>>>> using a head_frag you should probably add a check that returns true if
>>>> cloned is true and page_count is greater than 1.  We should be safe in
>>>> the case of skb_header_cloned since we already dropped are dataref when
>>>> we stole the page and freed the skb.
>>> I really dont understand this concern.
>>>
>>> When skb is cloned, we copy in head_frag __skb_clone()
>>>
>>> So both skbs have the bit set, and dataref = 2.
>>>
>>> first skb is freed, dataref becomes 1 and nothing special  happen
>>>
>>> > From this point, skb->head is not 'shared' anymore (taken your own
>>> words). And we are free to do whatever we want.
>>>
>>> second skb is freed, dataref becomes 0 and we call the right destructor.
>> The problem is that the stack will not be able to detect sharing.  As
>> long as page_count is greater than 2 and skb->cloned is set we should be
>> telling any callers to skb_cloned that the head is cloned.  Otherwise we
>> can run into issues elsewhere with well meaning code checking and not
>> detecting sharing, and then mangling the header.
> page count is irrelevant, since if PAGE_SIZE=65536, you can have 32
> fragments (of 2048 bytes) per page. Still we can call put_page() for
> each individual frag that must be freed.
>
> You forgot to give an example of path that would be failing. Since the
> skb_cloned() check is still valid.
>
> Head is cloned if : skb->cloned is set and dataref value is not 1
>
> (minus the skb_header_release() tweaks done on output path for tcp)
>
> Every time a 'caller' is going to modify/mangle its skb head, it must
> first call pskb_expand_head() (or various helpers around it) to :
>
> - allocate a new skb->head
> - copy old content to new head
> - release a reference on old head dataref
> - if old dataref reaches 0, 'free' old head (might be a kfree() or
> put_page())
This is exactly my point.  The way your current code works the check in 
pskb_expand_head will not detect the header is cloned.

So for example lets say you have one of your skbs that goes through and 
is merged.

1.  You start with a cloned skb.  dataref = 2, head_frag page count = 1;
2.  You go through tcp_try_coalesce.  dataref = 2, head_frag page count = 2;
3.  You call __kfree_skb on the skb.  dataref = 1, head_frag page count = 2;
4   At this point if the holder of the clone decides to modify the skb-> 
head there is nothing to stop it from doing so.

Odds are you would have to have a pretty extreme corner case to really 
see any issues with this since I know most raw sockets won't mangle the 
data portion of the frame.  I just figure we could save ourselves a lot 
of trouble by just not coalescing the head_frag in the case that the skb 
is cloned.

>> Also I am not sure if the big monolithic changes are really the best way
>> to approach this.  It would be nice if we could fix this incrementally
>> instead of trying to do it all at once since there are multiple issues
>> that need to be addressed.
>>
>> I will try to submit a few patches from my end later today.  I still
>> need to look over all of the changes from the past couple of weeks that
>> were based on the assumption that the IP stack completely owned the skb.
> I did my best to provide small changes.
I just meant you didn't need to do things like add the kfree_skb_partial 
helper in the same patch.

> Plus TCP coalescing is done after IP processing.
>
> Owning skb is a vague concept anyway. IP borrows skb but not owns them.
> They already could be cloned skb.
I know it is a vague concept.  However it is one of those concepts where 
if we don't get it right we start to see random panics and call traces 
due to memory corruption.  That is why I prefer to avoid it if at all 
possible.  All I am really asking for is that we don't just use the 
head_frag as a page unless we know it is not cloned.  All those checks 
that just look for skb->head_frag could check for skb->head_frag && 
!skb_cloned(skb) and I would be a much happier person since then I know 
all owners of the clones will be using the same variable for reference 
count tracking.

I'm still working on those patches.  I thought I had sent them earlier 
but it looks like I had an email issue, and since then Dave pulled your 
patches so I am rebasing the patches on the updated tree and should have 
something in the next hour or so.

Thanks,

Alex
