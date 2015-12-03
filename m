From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rhashtable: ENOMEM errors when hit with a flood of insertions
Date: Thu, 03 Dec 2015 08:08:39 -0800
Message-ID: <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
	 <20151130093755.GA8159@gondor.apana.org.au>
	 <20151130101401.GA17712@orbit.nwl.cc>
	 <20151130101859.GA8378@gondor.apana.org.au>
	 <20151203125117.GB5505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32971 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbbLCQIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:08:42 -0500
In-Reply-To: <20151203125117.GB5505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 20:51 +0800, Herbert Xu wrote:
> On Mon, Nov 30, 2015 at 06:18:59PM +0800, Herbert Xu wrote:
> > 
> > OK that's better.  I think I see the problem.  The test in
> > rhashtable_insert_rehash is racy and if two threads both try
> > to grow the table one of them may be tricked into doing a rehash
> > instead.
> > 
> > I'm working on a fix.
> 
> While the EBUSY errors are gone for me, I can still see plenty
> of ENOMEM errors.  In fact it turns out that the reason is quite
> understandable.  When you pound the rhashtable hard so that it
> doesn't actually get a chance to grow the table in process context,
> then the table will only grow with GFP_ATOMIC allocations.
> 
> For me this starts failing regularly at around 2^19 entries, which
> requires about 1024 contiguous pages if I'm not mistaken.

Well, it will fail before this point if memory is fragmented.

Anyway, __vmalloc() can be used with GFP_ATOMIC, have you tried this ?

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a54ff8949f91..9ef5d74963b2 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -120,8 +120,9 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
 	    gfp != GFP_KERNEL)
 		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
-	if (tbl == NULL && gfp == GFP_KERNEL)
-		tbl = vzalloc(size);
+	if (tbl == NULL)
+		tbl = __vmalloc(size, gfp | __GFP_HIGHMEM | __GFP_ZERO,
+				PAGE_KERNEL);
 	if (tbl == NULL)
 		return NULL;
 
