From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: Add a test to see if a skb is freeable in irq
 context
Date: Tue, 01 Apr 2014 12:15:53 -0400 (EDT)
Message-ID: <20140401.121553.1464672258686459428.davem@davemloft.net>
References: <87eh1nktrw.fsf_-_@x220.int.ebiederm.org>
	<20140329.180945.1823589321953879448.davem@davemloft.net>
	<87a9c5jx1y.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, eric.dumazet@gmail.com, ben@decadent.org.uk,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	David.Laight@ACULAB.COM
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbaDAQP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:15:58 -0400
In-Reply-To: <87a9c5jx1y.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 01 Apr 2014 01:03:53 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Thu, 27 Mar 2014 18:15:47 -0700
>>
>>> Currently netpoll and skb_release_head_state assume that a skb is
>>> freeable in hard irq context except when skb->destructor is set.
>>> 
>>> The reality is far from this.  So add a function skb_irq_freeable to
>>> compute the full test and in the process be the living documentation of
>>> what the requirements are of actually freeing a skb in hard irq context.
>>> 
>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>  ...
>>> +	return !skb->destructor &&
>>> +#if IS_ENABLED(CONFIG_XFRM)
>>> +		!skb->sp &&
>>> +#endif
>>> +#if IS_ENABLED(CONFIG_NF_CONNTRACK)
>>> +		!skb->nfct &&
>>> +#endif
>>> +		!skb->_skb_refdst &&
>>> +		!skb_has_frag_list(skb);
>>
>> I think you need to add "!skb->nf_bridge &&" to this test.
> 
> Given that the definition of nf_bridge_put is just:
> 
> static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
> {
> 	if (nf_bridge && atomic_dec_and_test(&nf_bridge->use))
> 		kfree(nf_bridge);
> }
> 
> I don't see why.
> 
> atomic_dec_and_test and kfree are hard irq safe.
> 
> I can see the code evolving in a way where it wouldn't be safe to put a
> nf_bridge from hard irq context but the code as it is today is trivially
> safe.

Fair enough.
