From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Sun, 27 Jul 2014 11:48:49 +0200
Message-ID: <20140727094849.GC5965@cpaasch-mac>
References: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
 <20140725111448.53df867a@haswell.linuxnetplumber.net>
 <20140726085924.GF6810@cpaasch-mac>
 <1406368497.12728.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Doug Leith <doug.leith@nuim.ie>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50416 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbaG0Jsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 05:48:55 -0400
Content-Disposition: inline
In-Reply-To: <1406368497.12728.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/07/14 - 11:54:57, Eric Dumazet wrote:
> On Sat, 2014-07-26 at 10:59 +0200, Christoph Paasch wrote:
> 
> > do you mean, using "do_div"?
> > 
> > David suggested to avoid using do_div in tcp_vegas.
> 
> My understanding is the following :
> 
> On 64bit arches, used on most servers that really care of TCP
> performance these days, do_div() is the fastest thing : No extra
> conditional.
> 
> # define do_div(n,base) ({                                      \
>         uint32_t __base = (base);                               \
>         uint32_t __rem;                                         \
>         __rem = ((uint64_t)(n)) % __base;                       \
>         (n) = ((uint64_t)(n)) / __base;                         \
>         __rem;                                                  \
>  })
> 
> 
> Then on 32bit, do_div(target_cwnd, Y) will perform a single divide
> if target_cwnd is < 2^32, which is very likely the case :
> 
> 
> # define do_div(n,base) ({                              \
>         uint32_t __base = (base);                       \
>         uint32_t __rem;                                 \
>         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
>         if (likely(((n) >> 32) == 0)) {                 \
>                 __rem = (uint32_t)(n) % __base;         \
>                 (n) = (uint32_t)(n) / __base;           \
>         } else                                          \
>                 __rem = __div64_32(&(n), __base);       \
>         __rem;                                          \
>  })
> 
> 
> 
> (In both cases, compiler will remove the modulo operation, as we do not use it)

I am very fine with using do_div. Indeed, cwnd and rtt must be quite high to
fall into the case of 64-bit divides.

I will wait a bit for other feedback and then send a new version with do_div.


Thanks,
Christoph
