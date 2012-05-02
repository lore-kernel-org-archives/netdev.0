From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] net: take care of cloned skbs in tcp_try_coalesce()
Date: Wed, 02 May 2012 09:27:22 -0700
Message-ID: <4FA1606A.6040607@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>  <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>  <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>  <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>  <1335946384.22133.119.camel@edumazet-glaptop>  <4FA15830.6080600@intel.com> <1335975168.22133.578.camel@edumazet-glaptop>
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
Received: from mga01.intel.com ([192.55.52.88]:56892 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288Ab2EBQ1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 12:27:47 -0400
In-Reply-To: <1335975168.22133.578.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 09:12 AM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 08:52 -0700, Alexander Duyck wrote:
>> On 05/02/2012 01:13 AM, Eric Dumazet wrote:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> Before stealing fragments or skb head, we must make sure skb is not
>>> cloned.
>>>
>>> If skb is cloned, we must take references on pages instead.
>>>
>>> Bug happened using tcpdump (if not using mmap())
>>>
>>> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>> ---
>>>  net/ipv4/tcp_input.c |   17 ++++++++++++++---
>>>  1 file changed, 14 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>> index 96a631d..7686d7f 100644
>>> --- a/net/ipv4/tcp_input.c
>>> +++ b/net/ipv4/tcp_input.c
>>> @@ -4467,7 +4467,7 @@ static bool tcp_try_coalesce(struct sock *sk,
>>>  			     struct sk_buff *from,
>>>  			     bool *fragstolen)
>>>  {
>>> -	int delta, len = from->len;
>>> +	int i, delta, len = from->len;
>>>  
>>>  	*fragstolen = false;
>>>  	if (tcp_hdr(from)->fin)
>>> @@ -4497,7 +4497,13 @@ copyfrags:
>>>  		       skb_shinfo(from)->frags,
>>>  		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
>>>  		skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
>>> -		skb_shinfo(from)->nr_frags = 0;
>>> +
>>> +		if (skb_cloned(from))
>>> +			for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
>>> +				skb_frag_ref(from, i);
>>> +		else
>>> +			skb_shinfo(from)->nr_frags = 0;
>>> +
>>>  		to->truesize += delta;
>>>  		atomic_add(delta, &sk->sk_rmem_alloc);
>>>  		sk_mem_charge(sk, delta);
>> I am fairly certain the bug I saw is only masked over by this change. 
>> The underlying problem is that we shouldn't be messing with nr_frags on
>> the from or the to if either one is clone.  You now have a check in
>> place for the from, but what about the to?  This function should
>> probably be calling a pskb_expand_head on the to skb in order to
>> guarantee that the skb->head isn't shared.  Otherwise this is going to
>> cause other issues for any functions that are sharing these skbs that
>> just walk through frags without checking skb->len or skb->data_len first. 
> Its safe to increase to->len and increase nr_frags in this context,
> because we hold a reference to dataref : It cannot disappear under us.
>
> clones will still have their skb->len at skb_clone() time and wont care
> we expanded the frags.
Are you sure about that?  I think this may blow up if a bridge is
brought into play.  In that case you will have clones that will be going
through the xmit path of network drivers and I know in the case of the
older e1000 driver it didn't stop to look at the length but would
instead just go through and start mapping all frags to the device.  I am
fairly certain you are risking a data corruption any time you modify
nr_frags and dataref is != 1.

I really think what we should be doing is either not merge period, or we
have to go through slow paths if either the to or the from is cloned.

>>> @@ -4515,7 +4521,12 @@ copyfrags:
>>>  		offset = from->data - (unsigned char *)page_address(page);
>>>  		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
>>>  				   page, offset, skb_headlen(from));
>>> -		*fragstolen = true;
>>> +
>>> +		if (skb_cloned(from))
>>> +			get_page(page);
>>> +		else
>>> +			*fragstolen = true;
>>> +
>>>  		delta = len; /* we dont know real truesize... */
>>>  		goto copyfrags;
>>>  	}
>>>
>>>
>> I don't see where we are now addressing the put_page call to release the
>> page afterwards.  By calling get_page you are incrementing the page
>> count by one, but where are you decrementing dataref in the shared
>> info?  Without that we are looking at a memory leak because __kfree_skb
>> will decrement the dataref but it will never reach 0 so it will never
>> call put_page on the head frag.
> really the dataref was already incremented at skb_clone() time
>
> It will be properly decremented since we call __kfree_skb()
>
> Only the last decrement will perform the put_page()
>
> Think about splice() is doing, its the same get_page() game.
I think you are missing the point.  So skb_clone will bump the dataref
to 2, calling get_page will bump the page count to 2.  After this
function you don't call __kfree_skb(skb) instead you call
kmem_cache_free(skbuff_head_cache, skb).  This will free the sk_buff,
but not decrement dataref leaving it at 2.  Eventually the raw socket
will call kfree_skb(skb) on the clone dropping the dataref to 1 and you
will call put_page dropping the page count to 1, but I don't see where
the last __kfree_skb call will come from that will drop dataref and the
page count to 0.

Thanks,

Alex
