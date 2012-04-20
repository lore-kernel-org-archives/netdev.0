From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with
 flush_work()
Date: Fri, 20 Apr 2012 10:35:29 -0700
Message-ID: <20120420173529.GD32324@google.com>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
 <20120419152841.GA10553@google.com>
 <4F905521.9020901@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42230 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab2DTRfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 13:35:34 -0400
Content-Disposition: inline
In-Reply-To: <4F905521.9020901@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Apr 19, 2012 at 11:10:41AM -0700, Stephen Boyd wrote:
> On 04/19/12 08:28, Tejun Heo wrote:
> > On Wed, Apr 18, 2012 at 08:25:57PM -0700, Stephen Boyd wrote:
> >> @@ -2513,8 +2513,11 @@ bool flush_work(struct work_struct *work)
> >>  		wait_for_completion(&barr.done);
> >>  		destroy_work_on_stack(&barr.work);
> >>  		return true;
> >> -	} else
> >> +	} else {
> >> +		lock_map_acquire(&work->lockdep_map);
> >> +		lock_map_release(&work->lockdep_map);
> >>  		return false;
> > We don't have this annotation when start_flush_work() succeeds either,
> > right?  IOW, would lockdep trigger when an actual deadlock happens?
> 
> I believe it does although I haven't tested it.

How does it do that?  While wq->lockdep_map would be able to detect
some of the chaining, the read acquire paths probably would miss some
other.  In general, wq->lockdep_map is used to express dependencies
regarding workqueue flushing (and the self flushing) and it would
probably be better to express work item dependencies explicitly using
work->lockdep_map even if it becomes redundant through wq->lockdep_map
sometimes.

> > If not, why not add the acquire/release() before flush_work() does
> > anything?
> 
> I was worried about causing false positive lockdep warnings in the case
> that start_flush_work() succeeds and returns true. In that case, lockdep
> is told about the cwq lockdep map:
> 
> static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
>                              bool wait_executing)
> {
> 
>         .....
> 
>         if (cwq->wq->saved_max_active == 1 || cwq->wq->flags & WQ_RESCUER)
>                 lock_map_acquire(&cwq->wq->lockdep_map);
>         else
>                 lock_map_acquire_read(&cwq->wq->lockdep_map);
> 
> 
> and so if we acquired the work->lockdep_map before the
> cwq->wq->lockdep_map we would get a warning about ABBA between these two
> lockdep maps. At least that is what I'm lead to believe when I look at
> what process_one_work() is doing. Please correct me if I'm wrong.

All that's necessary is acquiring and releasing work->lockdep_map.
There's no need to nest start_flush_work() inside it.  Without
nesting, there's nothing to worry about ABBA lockdeps.

Thanks.

-- 
tejun
