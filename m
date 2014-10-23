From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 18:52:40 -0700
Message-ID: <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50966 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaJWBwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:52:41 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so87806pab.40
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:52:41 -0700 (PDT)
In-Reply-To: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2014-10-22 at 17:15 -0700, Alexei Starovoitov wrote:
> Hi Eric,
> 
> in the commit 6f532612cc24 ("net: introduce netdev_alloc_frag()")
> you mentioned that the reason to disable interrupts
> in __netdev_alloc_frag() is:
> "- Must be IRQ safe (non NAPI drivers can use it)"
> 
> Is there a way to do this conditionally?
> 
> Without it I see 10% performance gain for my RX tests
> (from 6.9Mpps to 7.7Mpps) and __netdev_alloc_frag()
> itself goes from 6.6% to 2.1%
> (popf seems to be quite costly)

Well, your driver is probably a NAPI one, so you need to
mask irqs, or to remove all non NAPI drivers from linux.

__netdev_alloc_frag() (__netdev_alloc_skb()) is used by all.

Problem is __netdev_alloc_frag() is generally deep inside caller
chain, so using a private pool might have quite an overhead.

Same could be said for skb_queue_head() /skb_queue_tail() /
sock_queue_rcv_skb() :
Many callers don't need to block irq.
