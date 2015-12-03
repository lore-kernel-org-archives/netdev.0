From: Phil Sutter <phil@nwl.cc>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Thu, 3 Dec 2015 16:38:05 +0100
Message-ID: <20151203153805.GC17467@orbit.nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203124129.GA5505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151203124129.GA5505@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2015 at 08:41:29PM +0800, Herbert Xu wrote:
> On Mon, Nov 30, 2015 at 06:18:59PM +0800, Herbert Xu wrote:
> > 
> > OK that's better.  I think I see the problem.  The test in
> > rhashtable_insert_rehash is racy and if two threads both try
> > to grow the table one of them may be tricked into doing a rehash
> > instead.
> > 
> > I'm working on a fix.
> 
> OK this patch fixes the EBUSY problem as far as I can tell.  Please
> let me know if you still observe EBUSY with it.  I'll respond to the
> ENOMEM problem in another email.
> 
> ---8<---
> Thomas and Phil observed that under stress rhashtable insertion
> sometimes failed with EBUSY, even though this error should only
> ever been seen when we're under attack and our hash chain length
> has grown to an unacceptable level, even after a rehash.
> 
> It turns out that the logic for detecting whether there is an
> existing rehash is faulty.  In particular, when two threads both
> try to grow the same table at the same time, one of them may see
> the newly grown table and thus erroneously conclude that it had
> been rehashed.  This is what leads to the EBUSY error.
> 
> This patch fixes this by remembering the current last table we
> used during insertion so that rhashtable_insert_rehash can detect
> when another thread has also done a resize/rehash.  When this is
> detected we will give up our resize/rehash and simply retry the
> insertion with the new table.
> 
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Tested-by: Phil Sutter <phil@nwl.cc>
