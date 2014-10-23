From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 19:22:29 -0700
Message-ID: <CAMEtUuxo7TT+9S1KSHxyTKR+pD6HWJKaTOO=A_VGsZVji3YU2w@mail.gmail.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	<1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:35124 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206AbaJWCWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 22:22:30 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so103085wgh.10
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 19:22:29 -0700 (PDT)
In-Reply-To: <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 6:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
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
>
> Well, your driver is probably a NAPI one, so you need to
> mask irqs, or to remove all non NAPI drivers from linux.

yeah, the 10G+ nics I care about are all napi :)

> __netdev_alloc_frag() (__netdev_alloc_skb()) is used by all.
>
> Problem is __netdev_alloc_frag() is generally deep inside caller
> chain, so using a private pool might have quite an overhead.

yes. I was thinking, since dev is already passed
into __netdev_alloc_skb(), we can check whether
dev registered with napi via dev->napi_list and if so,
tell inner __netdev_alloc_frag() to skip irq disabling...

don't know about skb_queue_head() and friends.
I'm only looking at pure rx now. One challenge at a time.
