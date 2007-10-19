From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 9189] New: Oops in kernel 2.6.21-rc4 through 2.6.23, page allocation failure
Date: Sat, 20 Oct 2007 00:00:15 +0800
Message-ID: <E1IiuGl-000482-00@gondolin.me.apana.org.au>
References: <4718C651.5040804@psc.edu>
Cc: shemminger@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: jheffner@psc.edu (John Heffner)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1449 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752598AbXJSQAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 12:00:30 -0400
In-Reply-To: <4718C651.5040804@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> wrote:
>
>> 
>> Backtrace #1:
>> page allocation failure. order:1, mode:0x20
>>  [<c0131581>] __alloc_pages+0x2e1/0x300   
>>  [<c0144bee>] cache_alloc_refill+0x29e/0x4b0
>>  [<c0144e6e>] __kmalloc+0x6e/0x80
>>  [<c0227103>] __alloc_skb+0x53/0x110
>>  [<c024de5c>] tcp_collapse+0x1ac/0x370
>>  [<c024e11d>] tcp_prune_queue+0xfd/0x2c0
>>  [<c024eaad>] tcp_data_queue+0x7cd/0xbb0
>>  [<c0225c2d>] skb_checksum+0x4d/0x2a0
>>  [<c02504ee>] tcp_rcv_established+0x36e/0x6a0
>>  [<c02561e4>] tcp_v4_do_rcv+0xb4/0x2a0
>>  [<c0131379>] __alloc_pages+0xd9/0x300
>>  [<c0258269>] tcp_v4_rcv+0x6a9/0x6c0
>>  [<c023ddb1>] ip_local_deliver+0x91/0x110
>>  [<c023e130>] ip_rcv+0x230/0x3c0
>>  [<c0227103>] __alloc_skb+0x53/0x110
>>  [<c022b742>] netif_receive_skb+0x152/0x1e0
>>  [<c022ce6f>] process_backlog+0x6f/0xe0
>>  [<c022cf3c>] net_rx_action+0x5c/0xf0
>>  [<c0115af2>] __do_softirq+0x42/0x90
>>  [<c0115b67>] do_softirq+0x27/0x30
>>  [<c01044fd>] do_IRQ+0x3d/0x70
>>  [<c0115818>] sys_gettimeofday+0x28/0x80
>>  [<c0102967>] common_interrupt+0x23/0x28
>>  =======================
> 
> I'm not surprised that this commit would make a difference in this 
> situation, since it does change the fraction of memory TCP is allowed to 
> use.  (If it really is too much in this situation, we should tweak the 
> function.)  However, I don't think this is the root cause.  Why does it 
> oops here when the allocation fails?

I don't think your change is the problem either.

It's pretty clear that the bug here is that tcp_collapse tries
to allocate a linear skb that's bigger than a page.  It should
instead use page frags to store the data.

However, the fact that we're calling tcp_collapse at all might
be related to your commit though since it means that we're hitting
the TCP memory threshold.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
