From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next] ipv6: Implement optimized IPv6 masked address
 comparison for ARM64
Date: Fri, 17 Mar 2017 15:20:06 -0600
Message-ID: <a149df606bf5d9240b9e9eb2f6f6eace@codeaurora.org>
References: <1489725772-7571-1-git-send-email-subashab@codeaurora.org>
 <bfa8020c-bd12-8de1-5be5-a3408c293600@arm.com>
 <20170317122252.GA32449@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        luke.starrett@broadcom.com, catalin.marinas@arm.com, nd@arm.com,
        netdev-owner@vger.kernel.org
To: James Greenhalgh <james.greenhalgh@arm.com>,
        Robin Murphy <robin.murphy@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47454 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdCQVUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 17:20:25 -0400
In-Reply-To: <20170317122252.GA32449@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
>> That's clearly not right - I'm not sure quite what undefined behaviour
>> assumption convinces GCC to optimise the whole thing away>
> 
> While the pointer casting is a bit ghastly, I don't actually think that
> GCC is taking advantage of undefined behaviour here, rather it looks 
> like
> you have a simple typo on line 3:
> 
>> 	const __uint128_t *ul1 = (const __uint128_t *)a1;
>> 	const __uint128_t *ulm = (const __uint128_t *)m;
>> 	const __uint128_t *ul2 = (const __uint128_t *)a1;
> 
> ul2 = a2, surely?
> 
> As it is (stripping casts) you have a1 ^ a1, which will get you to 0
> pretty quickly. Fixing that up for you;
> 
>   bool
>   ipv6_masked_addr_cmp_new(const struct in6_addr *a1, const struct
>   in6_addr *m,
>   		     const struct in6_addr *a2)
>   {
>   	const __uint128_t *ul1 = (const __uint128_t *)a1;
>   	const __uint128_t *ulm = (const __uint128_t *)m;
>   	const __uint128_t *ul2 = (const __uint128_t *)a2;
> 
>   	return !!((*ul1 ^ *ul2) & *ulm);
>   }
> 
> $ gcc -O2
> 
>   ipv6_masked_addr_cmp_new:
> 	ldp	x4, x3, [x0]
> 	ldp	x5, x2, [x2]
> 	ldp	x0, x1, [x1]
> 	eor	x4, x4, x5
> 	eor	x2, x3, x2
> 	and	x0, x0, x4
> 	and	x1, x1, x2
> 	orr	x0, x0, x1
> 	cmp	x0, 0
> 	cset	w0, ne
> 	ret
> 
> Which at least looks like it might calculate something useful :-)
> 
Hi Robin / James

Thanks for checking and sorry for the confusion. I'll retest this.
