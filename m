From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: take care of cloned skbs in tcp_try_coalesce()
Date: Wed, 02 May 2012 20:28:06 -0700
Message-ID: <4FA1FB46.6020609@gmail.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>	 <1335835677.11396.5.camel@edumazet-glaptop>	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>	 <1335977179.22133.599.camel@edumazet-glaptop> <4FA17781.6080306@intel.com>	 <1335982515.22133.610.camel@edumazet-glaptop> <4FA19F5B.7040407@intel.com>	 <1336009974.22133.706.c
 amel@edumazet-glaptop>  <4FA1F4C3.8000804@gmail.com> <1336014869.22133.821.camel@edumazet-glaptop>
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
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40291 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab2ECD2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 23:28:20 -0400
Received: by pbbrp8 with SMTP id rp8so1898927pbb.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 20:28:20 -0700 (PDT)
In-Reply-To: <1336014869.22133.821.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 8:14 PM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 20:00 -0700, Alexander Duyck wrote:
>> This is exactly my point.  The way your current code works the check in
>> pskb_expand_head will not detect the header is cloned.
>>
>> So for example lets say you have one of your skbs that goes through and
>> is merged.
>>
>> 1.  You start with a cloned skb.  dataref = 2, head_frag page count = 1;
>> 2.  You go through tcp_try_coalesce.  dataref = 2, head_frag page count = 2;

4592         if (from->head_frag) {
4593                 struct page *page;
4594                 unsigned int offset;
4595
4596                 if (skb_shinfo(to)->nr_frags + skb_shinfo(from)->nr_frags>= MAX_SKB_FRAGS)
4597                         return false;
4598                 page = virt_to_head_page(from->head);
4599                 offset = from->data - (unsigned char *)page_address(page);
4600                 skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
4601                                    page, offset, skb_headlen(from));
4602
4603                 if (skb_cloned(from))
4604                         get_page(page);
4605                 else
4606                         *fragstolen = true;
4607
4608                 delta = len; /* we dont know real truesize... */
4609                 goto copyfrags;
4610         }


>> 3.  You call __kfree_skb on the skb.  dataref = 1, head_frag page count = 2;
4614 static void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
4615 {
4616         if (head_stolen)
4617                 kmem_cache_free(skbuff_head_cache, skb);
4618         else
4619                 __kfree_skb(skb);
4620 }
4621

>
> If page count was incremented in 2., this is because we stole the head.
>
> But we could not stole the head since dataref = 2
I don't see how that is the case.  It looks pretty clear to me that if 
dataref ==2, as represented by skb_cloned(from) being true above, we are 
calling get_page which will bump the page count and we are still 
stealing the head and then calling __kfree_skb which will decrement dataref.
> So try to find a real example, based on current state, not on the first
> patch I sent, since we made progress since this time.
>
> Thanks

I included a couple of grabs from blobs on git.kernel.org for Dave's 
current tree.  I should have patches out in about 10 minutes and then we 
can discuss those.

Thanks,

Alex
