From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Wed, 05 Dec 2007 23:28:34 -0500
Message-ID: <47577A72.10205@redhat.com>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au> <47515CCF.3030009@cosmosbay.com> <47549BE2.9080605@redhat.com> <20071204002644.GA28982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbXLFEaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 23:30:55 -0500
In-Reply-To: <20071204002644.GA28982@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Dec 03, 2007 at 07:14:26PM -0500, Hideo AOKI wrote:
>> Let me try to use sk_forward_alloc at first, while percpu storage
>> is an interesting idea.
> 
> Actually I don't think sk_forward_alloc would work for UDP because
> it runs lockless (unlike TCP which is run under a the socket lock).
> 
> So it's either going to be the atomic op or per-cpu counters.  For
> me the atomic op isn't the issue, it's the SMP cache-line bouncing
> that's more important so having something that did atomic ops on a
> socket counter which then feeds into the global counter would solve
> my concerns.
> 
> But let's wait and see what Dave has to say about this too.

Hello,

I suppose that he also wants to have per-socket accounting to avoid
global counter access.

To achieve this, I think I have three ideas at present. I'd
appreciate if you let me know acceptable idea or any suggestions.

1. Using sk_forward_alloc and adding socket lock

   UDP already uses a socket lock to send message. However, it doesn't
   use the lock to receive message. I wonder if we can also use the
   lock when sk_forward_alloc is updated in receive processing.
   I understand performance issue might occur, but ...


2. Adding new atomic_t variable for memory accounting

   Datagram protocols will use the variable for per-socket memory
   accounting. Stream protocols continue to use sk_forward_alloc.


3. Replacing current sk_forward_alloc with union type

   Stream protocols use the union as int, and datagram protocols use
   it as atomic_t.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
