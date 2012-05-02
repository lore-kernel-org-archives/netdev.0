From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] net: take care of cloned skbs in tcp_try_coalesce()
Date: Wed, 02 May 2012 11:05:53 -0700
Message-ID: <4FA17781.6080306@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>  <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>  <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>  <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>  <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>  <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com> <1335977179.22133.599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
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
Received: from mga11.intel.com ([192.55.52.93]:1209 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755380Ab2EBSFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 14:05:54 -0400
In-Reply-To: <1335977179.22133.599.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 09:46 AM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 09:27 -0700, Alexander Duyck wrote:
[...]
>>>>> @@ -4515,7 +4521,12 @@ copyfrags:
>>>>>  		offset = from->data - (unsigned char *)page_address(page);
>>>>>  		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
>>>>>  				   page, offset, skb_headlen(from));
>>>>> -		*fragstolen = true;
>>>>> +
>>>>> +		if (skb_cloned(from))
>>>>> +			get_page(page);
>>>>> +		else
>>>>> +			*fragstolen = true;
>>>>> +
>>>>>  		delta = len; /* we dont know real truesize... */
>>>>>  		goto copyfrags;
>>>>>  	}
>>>>>
>>>>>
>>>> I don't see where we are now addressing the put_page call to release the
>>>> page afterwards.  By calling get_page you are incrementing the page
>>>> count by one, but where are you decrementing dataref in the shared
>>>> info?  Without that we are looking at a memory leak because __kfree_skb
>>>> will decrement the dataref but it will never reach 0 so it will never
>>>> call put_page on the head frag.
>>> really the dataref was already incremented at skb_clone() time
>>>
>>> It will be properly decremented since we call __kfree_skb()
>>>
>>> Only the last decrement will perform the put_page()
>>>
>>> Think about splice() is doing, its the same get_page() game.
>> I think you are missing the point.  So skb_clone will bump the dataref
>> to 2, calling get_page will bump the page count to 2.  After this
>> function you don't call __kfree_skb(skb) instead you call
>> kmem_cache_free(skbuff_head_cache, skb).  This will free the sk_buff,
>> but not decrement dataref leaving it at 2.  Eventually the raw socket
>> will call kfree_skb(skb) on the clone dropping the dataref to 1 and you
>> will call put_page dropping the page count to 1, but I don't see where
>> the last __kfree_skb call will come from that will drop dataref and the
>> page count to 0.
> No, you miss that _if_ we added one to page count, then we wont call
> kmem_cache_free(skbuff_head_cache, skb) but call __kfree_skb(skb)
> instead because fragstolen will be false.
>
> if (fragstolen)
> 	kmem_cache_free(...)
> else
> 	__kfree_skb(...)
>
> In future patch (addressing tcp coalescing in tcp_queue_rcv() as well),
> I'll add a helper to make this more clear.
You're correct about the fragstolen case, I actually was thinking of the
first patch you sent, not this second one.

However we still have a problem.  What we end up with now is a case of
sharing in which the clone skb no longer knows that it is sharing the
head with another skb.  The dataref will drop to 1 when we call
__kfree_skb.  This means that any other function out there that tries to
see if the skb is shared would return false.  This could lead to issues
if there is anything out there that manipulates the data in head based
on the false assumption that it is not cloned.  What we would probably
need to do in this case is tweak the logic for skb_cloned.  If you are
using a head_frag you should probably add a check that returns true if
cloned is true and page_count is greater than 1.  We should be safe in
the case of skb_header_cloned since we already dropped are dataref when
we stole the page and freed the skb.

Thanks,

Alex
