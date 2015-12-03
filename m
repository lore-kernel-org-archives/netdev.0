From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: ENOMEM errors when hit with a flood of insertions
Date: Thu, 3 Dec 2015 20:51:17 +0800
Message-ID: <20151203125117.GB5505@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151130101859.GA8378@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 06:18:59PM +0800, Herbert Xu wrote:
> 
> OK that's better.  I think I see the problem.  The test in
> rhashtable_insert_rehash is racy and if two threads both try
> to grow the table one of them may be tricked into doing a rehash
> instead.
> 
> I'm working on a fix.

While the EBUSY errors are gone for me, I can still see plenty
of ENOMEM errors.  In fact it turns out that the reason is quite
understandable.  When you pound the rhashtable hard so that it
doesn't actually get a chance to grow the table in process context,
then the table will only grow with GFP_ATOMIC allocations.

For me this starts failing regularly at around 2^19 entries, which
requires about 1024 contiguous pages if I'm not mistaken.

I've got fairly straightforward solution for this, but it does
mean that we have to add another level of complexity to the
rhashtable implementation.  So before I go there I want to be
absolutely sure that we need it.

I guess the question is do we care about users that pound rhashtable
in this fashion?

My answer would be yes but I'd like to hear your opinions.

My solution is to use a slightly more complex/less efficient hash
table when we fail the allocation in interrupt context.  Instead
of allocating contiguous pages, we'll simply switch to allocating
individual pages and have a master page that points to them.

On a 64-bit platform, each page can accomodate 512 entries.  So
with a two-level deep setup (meaning one extra access for a hash
lookup), this would accomodate 2^18 entries.  Three levels (two
extra lookups) will give us 2^27 entries, which should be enough.

When we do this we should of course schedule an async rehash so
that as soon as we get a chance we can move the entries into a
normal hash table that needs only a single lookup.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
