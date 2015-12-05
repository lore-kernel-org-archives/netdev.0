From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Sat, 5 Dec 2015 15:03:54 +0800
Message-ID: <20151205070354.GA23255@gondor.apana.org.au>
References: <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204143956.GA17471@gondor.apana.org.au>
 <20151204.165334.1119277452308794437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, phil@nwl.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54480 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbLEHEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:04:12 -0500
Content-Disposition: inline
In-Reply-To: <20151204.165334.1119277452308794437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 04:53:34PM -0500, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 4 Dec 2015 22:39:56 +0800
> 
> > When an rhashtable user pounds rhashtable hard with back-to-back
> > insertions we may end up growing the table in GFP_ATOMIC context.
> > Unfortunately when the table reaches a certain size this often
> > fails because we don't have enough physically contiguous pages
> > to hold the new table.
> > 
> > Eric Dumazet suggested (and in fact wrote this patch) using
> > __vmalloc instead which can be used in GFP_ATOMIC context.
> > 
> > Reported-by: Phil Sutter <phil@nwl.cc>
> > Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks Herbert.

Sorry Dave but you'll have to revert this because I've been able
to trigger the following crash with the patch:

Testing concurrent rhashtable access from 50 threads
------------[ cut here ]------------
kernel BUG at ../mm/vmalloc.c:1337!
invalid opcode: 0000 [#1] PREEMPT SMP 

The reason is that because I was testing insertions with BH disabled,
and __vmalloc doesn't like that, even with GFP_ATOMIC.  As we
obviously want to continue to support rhashtable users inserting
entries with BH disabled, we'll have to look for an alternate
solution.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
