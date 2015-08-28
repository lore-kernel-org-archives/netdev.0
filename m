From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Fri, 28 Aug 2015 15:34:37 +0200
Message-ID: <20150828133437.GM20760@orbit.nwl.cc>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
 <1440757685-14241-2-git-send-email-phil@nwl.cc>
 <20150828110929.GI32206@pox.localdomain>
 <20150828111320.GL20760@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150828111320.GL20760@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2015 at 01:13:20PM +0200, Phil Sutter wrote:
> On Fri, Aug 28, 2015 at 01:09:29PM +0200, Thomas Graf wrote:
> > On 08/28/15 at 12:28pm, Phil Sutter wrote:
> > > After adding cond_resched() calls to threadfunc(), a surprisingly high
> > > rate of insert failures occurred probably due to table resizes getting a
> > > better chance to run in background. To not soften up the remaining
> > > tests, retry inserts until they either succeed or fail permanently.
> > > 
> > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > ---
> > >  lib/test_rhashtable.c | 13 +++++++------
> > >  1 file changed, 7 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
> > > index 63654e3..093cf84 100644
> > > --- a/lib/test_rhashtable.c
> > > +++ b/lib/test_rhashtable.c
> > > @@ -244,7 +244,7 @@ static int thread_lookup_test(struct thread_data *tdata)
> > >  
> > >  static int threadfunc(void *data)
> > >  {
> > > -	int i, step, err = 0, insert_fails = 0;
> > > +	int i, step, err = 0, retries = 0;
> > >  	struct thread_data *tdata = data;
> > >  
> > >  	up(&prestart_sem);
> > > @@ -253,21 +253,22 @@ static int threadfunc(void *data)
> > >  
> > >  	for (i = 0; i < entries; i++) {
> > >  		tdata->objs[i].value = (tdata->id << 16) | i;
> > > +insert_retry:
> > >  		cond_resched();
> > >  		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
> > >  		                             test_rht_params);
> > >  		if (err == -ENOMEM || err == -EBUSY) {
> > > -			tdata->objs[i].value = TEST_INSERT_FAIL;
> > > -			insert_fails++;
> > > +			retries++;
> > > +			goto insert_retry;
> > 
> > Is it safe to retry indefinitely on ENOMEM? Retrying on EBUSY is
> > definitely an improvement and we should do the same in the non
> > threaded test as well.
> 
> Oh yes, that is definitely a bug. I will respin and add the same for the
> normal test, too.

Quite ugly, IMHO: rhashtable_insert_fast() may return -ENOMEM as
non-permanent error, if allocation in GFP_ATOMIC failed. In this case,
allocation in GFP_KERNEL is retried by rht_deferred_worker(). Sadly,
there is no way to determine if that has already been tried and failed.

The thread test triggers GFP_ATOMIC allocation failure quite easily, so
I can't really just ignore this issue. :)

Cheers, Phil
