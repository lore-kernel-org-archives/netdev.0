From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 20:19:59 -0700
Message-ID: <544873DF.1040403@gmail.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com> <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:61003 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbaJWDT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 23:19:58 -0400
Received: by mail-pd0-f175.google.com with SMTP id y13so214949pdi.34
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 20:19:58 -0700 (PDT)
In-Reply-To: <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 06:52 PM, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 17:15 -0700, Alexei Starovoitov wrote:
>> Hi Eric,
>>
>> in the commit 6f532612cc24 ("net: introduce netdev_alloc_frag()")
>> you mentioned that the reason to disable interrupts
>> in __netdev_alloc_frag() is:
>> "- Must be IRQ safe (non NAPI drivers can use it)"
>>
>> Is there a way to do this conditionally?
>>
>> Without it I see 10% performance gain for my RX tests
>> (from 6.9Mpps to 7.7Mpps) and __netdev_alloc_frag()
>> itself goes from 6.6% to 2.1%
>> (popf seems to be quite costly)
> Well, your driver is probably a NAPI one, so you need to
> mask irqs, or to remove all non NAPI drivers from linux.
>
> __netdev_alloc_frag() (__netdev_alloc_skb()) is used by all.
>
> Problem is __netdev_alloc_frag() is generally deep inside caller
> chain, so using a private pool might have quite an overhead.
>
> Same could be said for skb_queue_head() /skb_queue_tail() /
> sock_queue_rcv_skb() :
> Many callers don't need to block irq.

Couldn't __netdev_alloc_frag() be forked into two functions, one that is
only called from inside the NAPI context and one that is called for all
other contexts?  It would mean having to double the number of pages
being held per CPU, but I would think something like that would be doable.

Thanks,

Alex
