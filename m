From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] [CORE]: datagram: mem_scheudle functions
Date: Sun, 16 Dec 2007 16:20:02 -0500
Message-ID: <47659682.4030204@redhat.com>
References: <47636120.4050701@redhat.com> <476362D8.4070807@redhat.com> <20071215153210.GA29415@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbXLPVXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 16:23:11 -0500
In-Reply-To: <20071215153210.GA29415@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Thank you for your quick comments.

Herbert Xu wrote:
>> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);
> 
> Please use bh_lock_sock since this must never be used from an
> IRQ handler.

I'll try to re-implement this locking mechanism as David suggested.

>> +static inline void sk_mem_reclaim(struct sock *sk)
>> +{
>> +	if (sk->sk_type == SOCK_DGRAM)
>> +		sk_datagram_mem_reclaim(sk);
>> +}
> 
> Please get rid of these wrappers since we should only get here
> for datagram protocols.

In my understanding, TCP also uses ip_append_data() and
ip_ufo_append_data() via ip_send_reply(). Then I thought TCP could
reach datagram memory accounting functions, and I used the wrappers
since I didn't want to change TCP's sk_alloc_forward and
memory_allocated.

I'll try to remove these wrappers in next patch set. But I'd
appreciate it if you let me know whether we can keep the wrappers
in case TCP memory accounting doesn't work well due to accounting
in IP layer.

>> +static inline int sk_account_wmem_charge(struct sock *sk, int size)
>> +{
>> +	unsigned long flags;
>> +
>> +	/* account if protocol supports memory accounting. */
>> +	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
>> +		return 1;
>> +
>> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);
>> +	if (sk_datagram_wmem_schedule(sk, size)) {
>> +		sk->sk_forward_alloc -= size;
>> +		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
>> +		return 1;
>> +	}
>> +	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
>> +	return 0;
>> +}
> 
> This is probably too big to inline.
> 
>> +static inline int sk_account_rmem_charge(struct sock *sk, int size)
>> +{
>> +	unsigned long flags;
>> +
>> +	/* account if protocol supports memory accounting. */
>> +	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
>> +		return 1;
>> +
>> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);
>> +	if (sk_datagram_rmem_schedule(sk, size)) {
>> +		sk->sk_forward_alloc -= size;
>> +		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
>> +		return 1;
>> +	}
>> +	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
>> +	return 0;
>> +}
> 
> Why are we duplicating the rmem/wmem versions when they're identical?

Good catch. I'll merge the body of these functions into one function.
Furthermore, I'll stop using inline if the code is large.

>> -int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>> +int sock_queue_rcv_skb_with_owner(struct sock *sk, struct sk_buff *skb,
>> +				  void set_owner_r(struct sk_buff *nskb,
>> +						   struct sock* nsk))
> 
> Just make a new function for this rather than playing with function
> pointers.

I understood. I'll fix it.

Again, many thanks for the review.

Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.

