From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Wed, 13 Apr 2016 16:51:36 +0300
Message-ID: <20160413163940-mutt-send-email-mst@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140822073653.GA7372@gmail.com>
 <20160411182111-mutt-send-email-mst@redhat.com>
 <20160413132803.GN2906@worktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758271AbcDMNvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 09:51:42 -0400
Content-Disposition: inline
In-Reply-To: <20160413132803.GN2906@worktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 03:28:03PM +0200, Peter Zijlstra wrote:
> On Mon, Apr 11, 2016 at 07:31:57PM +0300, Michael S. Tsirkin wrote:
> > +static bool expected_to_run_fair(struct cfs_rq *cfs_rq, s64 t)
> > +{
> > +       struct sched_entity *left;
> > +       struct sched_entity *curr = cfs_rq->curr;
> > +
> > +       if (!curr || !curr->on_rq)
> > +               return false;
> > +
> > +       left = __pick_first_entity(cfs_rq);
> > +       if (!left)
> > +               return true;
> > +
> > +       return (s64)(curr->vruntime + calc_delta_fair(t, curr) -
> > +                    left->vruntime) < 0;
> > +}
> > 
> > The reason it seems easier is because that way we can reuse
> > calc_delta_fair and don't have to do the reverse translation
> > from vruntime to nsec.
> > 
> > And I guess if we do this with interrupts disabled, and only poke
> > at the current CPU's rq, we know first entity
> > won't go away so we don't need locks? 
> 
> Nope, not true. Current isn't actually in the tree, and any other task
> is subject to being moved at any time.
> Even if current was in the tree, there is no guarantee it is
> ->rb_leftmost; imagine a task being migrated in that has a smaller
> vruntime.
> 
> So this really cannot work without locks :/
> 
> I've not thought about the actual problem you're trying to solve; but I
> figured I'd let you know this before you continue down this path.

Hmm. This is in fact called in the context of a given task,
so maybe I should just change the API and use
	&task->se
instead of 
	cfs_rq->current

:

static bool expected_to_run_fair(struct cfs_rq *cfs_rq, struct task_struct *task, s64 t)
{
       struct sched_entity *left;
       struct sched_entity *curr = &task->se;
       if (!curr || !curr->on_rq)
              return false;

       left = __pick_first_entity(cfs_rq);
       if (!left)
               return true;

       return (s64)(curr->vruntime + calc_delta_fair(t, curr) -
                    left->vruntime) < 0;
}

This way it is caller's respinsibility to make sure task
is not going away.
Left here is on tree so it's not going away, right?

-- 
MST
