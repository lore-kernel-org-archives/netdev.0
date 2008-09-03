From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 08:07:33 +0300
Message-ID: <48BE1B95.8000508@iki.fi>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:61605 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYICFH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:07:29 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1324427eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 22:07:28 -0700 (PDT)
In-Reply-To: <E1KakUR-0001xp-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
>> This is what added the xfrm_state_lock grabbing in __xfrm_state_destroy().
> 
> This is simply bogus.  We should remove the entry from the list
> when the state is deleted, not when it's destroyed.  That is, we
> should be deleting x->all in places like __xfrm_state_delete instead
> of __xfrm_state_destroy.
>
> The fact that we're adding x->all in __xfrm_state_insert means
> that we should be deleting it from its counter-part, which is
> __xfrm_state_delete.
> 
> The same thing applies to the policies of course.  Once a policy
> or state is deleted there is no reason why it should show up in a
> walk just because some dst is holding onto it.

But then caller of xfrm_state_walk() can be still holding a
reference to the entry and dumping of the whole chain fails,
because the entry is no longer part of the chain when dumping
continues later.

The walking coding skips entries which are dead so the
entry is only kept temporarily to make a full traversal of
the list.

>> ipsec: Fix deadlock in xfrm_state management.
>>
>> Ever since commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3
>> ("[XFRM]: Speed up xfrm_policy and xfrm_state walking") it is
>> illegal to call __xfrm_state_destroy (and thus xfrm_state_put())
>> with xfrm_state_lock held.  If we do, we'll deadlock since we
>> have the lock already and __xfrm_state_destroy() tries to take
>> it again.
>>
>> Fix this by pushing the xfrm_state_put() calls after the lock
>> is dropped.
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> However, moving things out of critical sections is always a good
> idea.  So I think your patch is an improvement regardless of why
> it came about :)

Right. Also alternatively the xfrm_state_all could be protected
by a different lock than xfrm_state_lock.

- Timo
