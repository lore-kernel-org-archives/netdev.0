From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Wed, 13 Apr 2016 15:28:03 +0200
Message-ID: <20160413132803.GN2906@worktop>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140822073653.GA7372@gmail.com>
 <20160411182111-mutt-send-email-mst@redhat.com>
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
In-Reply-To: <20160411182111-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 07:31:57PM +0300, Michael S. Tsirkin wrote:
> +static bool expected_to_run_fair(struct cfs_rq *cfs_rq, s64 t)
> +{
> +       struct sched_entity *left;
> +       struct sched_entity *curr = cfs_rq->curr;
> +
> +       if (!curr || !curr->on_rq)
> +               return false;
> +
> +       left = __pick_first_entity(cfs_rq);
> +       if (!left)
> +               return true;
> +
> +       return (s64)(curr->vruntime + calc_delta_fair(t, curr) -
> +                    left->vruntime) < 0;
> +}
> 
> The reason it seems easier is because that way we can reuse
> calc_delta_fair and don't have to do the reverse translation
> from vruntime to nsec.
> 
> And I guess if we do this with interrupts disabled, and only poke
> at the current CPU's rq, we know first entity
> won't go away so we don't need locks? 

Nope, not true. Current isn't actually in the tree, and any other task
is subject to being moved at any time.

Even if current was in the tree, there is no guarantee it is
->rb_leftmost; imagine a task being migrated in that has a smaller
vruntime.

So this really cannot work without locks :/

I've not thought about the actual problem you're trying to solve; but I
figured I'd let you know this before you continue down this path.
