From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Tue, 01 May 2012 09:17:35 -0700
Message-ID: <4FA00C9F.8080409@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com> <1335854378.11396.26.camel@edumazet-glaptop>
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
Received: from mga14.intel.com ([143.182.124.37]:6884 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214Ab2EAQRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 12:17:37 -0400
In-Reply-To: <1335854378.11396.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2012 11:39 PM, Eric Dumazet wrote:
> On Mon, 2012-04-30 at 22:33 -0700, Alexander Duyck wrote:
>
>> The question I had was more specific to GRO.  As long as we have
>> skb->users == 1 and the skb isn't cloned we should be fine.   It just
>> hadn't occurred to me before that napi_gro_receive had the extra
>> requirement that the skb couldn't be cloned.
>>
> OK
>
> By the way, even if skb was cloned, we would be allowed to steal
> skb->head.
>
> When we clone an oskb we :
>
> 1) allocate a struct nskb sk_buff (or use the shadow in case of TCP)
> 2) increment dataref
The problem I have is with this piece right here.  So you increment
dataref.  Now you have an skb that is still pointing to the shared info
on this page and dataref is 2.  What about the side that is stealing the
head?  Is it going to be tracking the dataref as well and decrementing
it before put_page or does it just assume that dataref is 1 and call
put_page directly?  I am guessing the latter since I didn't see anything
that allowed for tracking the dataref of stolen heads.

> 3) link skb->head
>
> After cloning()  nskb->users == 1, and oskb->users is unchanged
>
> I believe you are referring to skb_get(oskb), that ones increment
> oskb->users and skb_shared(oskb) then returns true.
skb_clone and skb_get are two completely separate things.  My concern
with the skb_get portion is if skb->users is greater than 1 we should
not be freeing the skbuff back to the head cache.  This was addressed
with the fact that GRO is requiring that skb->users be 1 before it is
handed the skb, although I didn't look too closely at the other patches
that are also stealing skb->head.  My concern with skb_clone, as I
mentioned above, is that I am not sure how the dataref tracking will
still work.

It looks like Dave applied the patches last night so I will pull the
latest net-next and do some poking around.  It is possible I am just
being dense and not getting this, but I just feel like there is
something that got missed or overlooked.

Thanks,

Alex
