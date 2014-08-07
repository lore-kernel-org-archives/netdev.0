From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [setsockopt] WARNING: CPU: 0 PID: 1444 at
 kernel/sched/core.c:7088 __might_sleep+0x51/0x16f()
Date: Thu, 7 Aug 2014 12:59:48 -0400
Message-ID: <20140807125948.2b7f1472@thirdoffive.cmf.nrl.navy.mil>
References: <20140805214624.GA9973@localhost>
	<20140807151741.GP19379@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	linux-atm-general@lists.sourceforge.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807151741.GP19379@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2014 17:17:41 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Subject: atm: Fix blocking in wait loop
> 
> One should not call blocking primitives inside a wait loop, since both
> require task_struct::state to sleep, so the inner will destroy the outer
> state.
> 
> In this instance sigd_enq() will possible sleep for alloc_skb(), now if
> I understand the code right, we do not actually need to call sigd_enq()
> after the initial prepare_to_wait(), because we test the termination
> condition before schedule() anyhow.
> 
> So we can simply move it up a bit and avoid the entire confusion.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> ---
>  net/atm/svc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/atm/svc.c b/net/atm/svc.c
> index d8e5d0c2ebbc..445ac238b69b 100644
> --- a/net/atm/svc.c
> +++ b/net/atm/svc.c
> @@ -297,8 +297,8 @@ static int svc_listen(struct socket *sock, int backlog)
>  		goto out;
>  	}
>  	set_bit(ATM_VF_WAITING, &vcc->flags);
> -	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
>  	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
> +	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
>  	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
>  		schedule();
>  		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);


This isn't the only place that we queue a message for the signalling
daemon after a prepare_to_wait() uninterruptibly so this patch would
be incomplete as is.

What bothers me is the TASK_UNINTERRUPTIBLE -- I don't have a good
reason why any of these should be sleeping uninterruptibly.
