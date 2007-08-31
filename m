From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Fri, 31 Aug 2007 21:33:02 +0400
Message-ID: <20070831173301.GA3886@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708281408.06618.phillips@phunq.net> <20070829085331.GA16607@2ka.mipt.ru> <200708301620.37965.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708301620.37965.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel.

On Thu, Aug 30, 2007 at 04:20:35PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Wednesday 29 August 2007 01:53, Evgeniy Polyakov wrote:
> > Then, if of course you will want, which I doubt, you can reread
> > previous mails and find that it was pointed to that race and
> > possibilities to solve it way too long ago.
> 
> What still bothers me about your response is that, while you know the 
> race exists and do not disagree with my example, you don't seem to see 
> that that race can eventually lock up the block device by repeatedly 
> losing throttle counts which are never recovered.  What prevents that?

I posted a trivial hack with pointed possible errors and a question
about should it be further extended (and race fixed by any of the
possible methods and so on) or new one should be developed (like in your
approach when only high level device is charged), instead I got replies
that it contains bugs, whcih will stop system and kill gene pool of the
mankind. I know how it works and where problems are. And if we are going
with this approach I will fix pointed issues.

> > > --- 2.6.22.clean/block/ll_rw_blk.c	2007-07-08 16:32:17.000000000
> > > -0700 +++ 2.6.22/block/ll_rw_blk.c	2007-08-24 12:07:16.000000000
> > > -0700 @@ -3237,6 +3237,15 @@ end_io:
> > >   */
> > >  void generic_make_request(struct bio *bio)
> > >  {
> > > +	struct request_queue *q = bdev_get_queue(bio->bi_bdev);
> > > +
> > > +	if (q && q->metric) {
> > > +		int need = bio->bi_reserved = q->metric(bio);
> > > +		bio->queue = q;
> >
> > In case you have stacked device, this entry will be rewritten and you
> > will lost all your account data.
> 
> It is a weakness all right.  Well,
> 
> -	if (q && q->metric) {
> +	if (q && q->metric && !bio->queue) {
> 
> which fixes that problem.  Maybe there is a better fix possible.  Thanks 
> for the catch!

Yes, it should.

> The original conception was that this block throttling would apply only 
> to the highest level submission of the bio, the one that crosses the 
> boundary between filesystem (or direct block device application) and 
> block layer.  Resubmitting a bio or submitting a dependent bio from 
> inside a block driver does not need to be throttled because all 
> resources required to guarantee completion must have been obtained 
> _before_ the bio was allowed to proceed into the block layer.

We still did not come to the conclusion, but I do not want to start a
flamewar, you believe that throttling must be done on the top level
device, so you need to extend bio and convince others that idea worth
it.

> The other principle we are trying to satisfy is that the throttling 
> should not be released until bio->endio, which I am not completely sure 
> about with the patch as modified above.  Your earlier idea of having 
> the throttle protection only cover the actual bio submission is 
> interesting and may be effective in some cases, in fact it may cover 
> the specific case of ddsnap.  But we don't have to look any further 
> than ddraid (distributed raid) to find a case it doesn't cover - the 
> additional memory allocated to hold parity data has to be reserved 
> until parity data is deallocated, long after the submission completes.
> So while you manage to avoid some logistical difficulties, it also looks 
> like you didn't solve the general problem.

Block layer does not know and should not be bothered with underlying
device nature - if you think that in endio callback limit should not be
rechardged, then provide your own layer on top of bio and thus call
endio callback only when you think it is ready to be completed.

> Hopefully I will be able to report on whether my patch actually works 
> soon, when I get back from vacation.  The mechanism in ddsnap this is 
> supposed to replace is effective, it is just ugly and tricky to verify.
> 
> Regards,
> 
> Daniel

-- 
	Evgeniy Polyakov
