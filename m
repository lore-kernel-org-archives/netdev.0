From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 0/4] improve fault-tolerance of rhashtable runtime-test
Date: Mon, 30 Nov 2015 18:18:59 +0800
Message-ID: <20151130101859.GA8378@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151130101401.GA17712@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 11:14:01AM +0100, Phil Sutter wrote:
> On Mon, Nov 30, 2015 at 05:37:55PM +0800, Herbert Xu wrote:
> > Phil Sutter <phil@nwl.cc> wrote:
> > > The following series aims to improve lib/test_rhashtable in different
> > > situations:
> > > 
> > > Patch 1 allows the kernel to reschedule so the test does not block too
> > >        long on slow systems.
> > > Patch 2 fixes behaviour under pressure, retrying inserts in non-permanent
> > >        error case (-EBUSY).
> > > Patch 3 auto-adjusts the upper table size limit according to the number
> > >        of threads (in concurrency test). In fact, the current default is
> > >        already too small.
> > > Patch 4 makes it possible to retry inserts even in supposedly permanent
> > >        error case (-ENOMEM) to expose rhashtable's remaining problem of
> > >        -ENOMEM being not as permanent as it is expected to be.
> > 
> > I'm sorry but this patch series is simply bogus.
> 
> The whole series?!

Well at least patch two and four seem clearly wrong because no
rhashtable user should need to retry insertions.

> Did you try with my bogus patch series applied? How many CPUs does your
> test system actually have?
> 
> > So can someone please help me reproduce this? Because just loading
> > test_rhashtable isn't doing it.
> 
> As said, maybe you need to increase the number of spawned threads
> (tcount=50 or so).

OK that's better.  I think I see the problem.  The test in
rhashtable_insert_rehash is racy and if two threads both try
to grow the table one of them may be tricked into doing a rehash
instead.

I'm working on a fix.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
