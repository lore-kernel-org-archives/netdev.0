From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Thu, 14 Apr 2016 02:58:35 +0200
Message-ID: <20160414005835.GB2975@worktop.cust.blueprintrf.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140822073653.GA7372@gmail.com>
 <20160411182111-mutt-send-email-mst@redhat.com>
 <20160413132803.GN2906@worktop>
 <20160413163940-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160413163940-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2016 at 04:51:36PM +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 13, 2016 at 03:28:03PM +0200, Peter Zijlstra wrote:

> > Nope, not true. Current isn't actually in the tree, and any other task
> > is subject to being moved at any time.
> > Even if current was in the tree, there is no guarantee it is
> > ->rb_leftmost; imagine a task being migrated in that has a smaller
> > vruntime.
> > 
> > So this really cannot work without locks :/
> > 
> > I've not thought about the actual problem you're trying to solve; but I
> > figured I'd let you know this before you continue down this path.

> static bool expected_to_run_fair(struct cfs_rq *cfs_rq, struct task_struct *task, s64 t)
> {
>        struct sched_entity *left;
>        struct sched_entity *curr = &task->se;
>        if (!curr || !curr->on_rq)
>               return false;
> 
>        left = __pick_first_entity(cfs_rq);
>        if (!left)
>                return true;
> 
>        return (s64)(curr->vruntime + calc_delta_fair(t, curr) -
>                     left->vruntime) < 0;
> }
> 
> Left here is on tree so it's not going away, right?

No, left is the leftmost entry on the tree, it can go away at any time.
You cannot touch the tree without locks.

Someone can come an migrate the task to another CPU, start executing it
and it can die between you finding the left pointer and dereferencing
it.
