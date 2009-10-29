From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 21:57:38 -0700 (PDT)
Message-ID: <20091028.215738.66603083.davem@davemloft.net>
References: <1256683583.3153.389.camel@linux-1lbu>
	<4AE81A70.5060307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schen@mvista.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbZJ2E5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 00:57:15 -0400
In-Reply-To: <4AE81A70.5060307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 11:18:24 +0100

> Check line 219 of net/ipv4/inet_fragment.c
> 
> #ifdef CONFIG_SMP
>         /* With SMP race we have to recheck hash table, because
>          * such entry could be created on other cpu, while we
>          * promoted read lock to write lock.
>          */
>         hlist_for_each_entry(qp, n, &f->hash[hash], list) {
>                 if (qp->net == nf && f->match(qp, arg)) {
>                         atomic_inc(&qp->refcnt);
>                         write_unlock(&f->lock);
>                         qp_in->last_in |= INET_FRAG_COMPLETE;   <<< HERE >>>
>                         inet_frag_put(qp_in, f);
>                         return qp;
>                 }
>         }
> #endif
> 
> I really wonder why we set INET_FRAG_COMPLETE here

What has happened here is that another cpu created an identical
frag entry before we took the write lock.

So we're letting that other cpu's entry stand, and will release
our local one and not use it at all.

Setting INET_FRAG_COMPLETE does two things:

1) It makes sure input frag processing skips this entry if such
   code paths happen to see it for some reason.

2) INET_FRAG_COMPLETE must be set when inet_frag_destroy() gets
   called by inet_frag_put() when it drops the refcount to zero.
   There is an assertion on INET_FRAG_COMPLETE in inet_frag_destroy.

Hope that clears things up.
