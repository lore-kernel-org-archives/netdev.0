From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Sat, 26 Jul 2014 11:54:57 +0200
Message-ID: <1406368497.12728.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
	 <20140725111448.53df867a@haswell.linuxnetplumber.net>
	 <20140726085924.GF6810@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Doug Leith <doug.leith@nuim.ie>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:40448 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaGZJzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 05:55:11 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so5177064wes.22
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 02:55:09 -0700 (PDT)
In-Reply-To: <20140726085924.GF6810@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-07-26 at 10:59 +0200, Christoph Paasch wrote:

> do you mean, using "do_div"?
> 
> David suggested to avoid using do_div in tcp_vegas.

My understanding is the following :

On 64bit arches, used on most servers that really care of TCP
performance these days, do_div() is the fastest thing : No extra
conditional.

# define do_div(n,base) ({                                      \
        uint32_t __base = (base);                               \
        uint32_t __rem;                                         \
        __rem = ((uint64_t)(n)) % __base;                       \
        (n) = ((uint64_t)(n)) / __base;                         \
        __rem;                                                  \
 })


Then on 32bit, do_div(target_cwnd, Y) will perform a single divide
if target_cwnd is < 2^32, which is very likely the case :


# define do_div(n,base) ({                              \
        uint32_t __base = (base);                       \
        uint32_t __rem;                                 \
        (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
        if (likely(((n) >> 32) == 0)) {                 \
                __rem = (uint32_t)(n) % __base;         \
                (n) = (uint32_t)(n) / __base;           \
        } else                                          \
                __rem = __div64_32(&(n), __base);       \
        __rem;                                          \
 })



(In both cases, compiler will remove the modulo operation, as we do not use it)
