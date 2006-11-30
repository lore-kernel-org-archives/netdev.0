From: Mike Galbraith <efault@gmx.de>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:04:25 +0100
Message-ID: <1164866665.5913.33.camel@Homer.simpson.net>
References: <HNEBLGGMEGLPMPPDOPMGCEAKCGAA.wenji@fnal.gov>
	 <HNEBLGGMEGLPMPPDOPMGGEAKCGAA.wenji@fnal.gov>
	 <20061129.165311.45739865.davem@davemloft.net>
	 <20061129170835.72bd40b3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, wenji@fnal.gov,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756050AbWK3GEc@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061129170835.72bd40b3.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-29 at 17:08 -0800, Andrew Morton wrote:
> +		if (p->backlog_flag == 0) {
> +			if (!TASK_INTERACTIVE(p) || expired_starving(rq)) {
> +				enqueue_task(p, rq->expired);
> +				if (p->static_prio < rq->best_expired_prio)
> +					rq->best_expired_prio = p->static_prio;
> +			} else
> +				enqueue_task(p, rq->active);
> +		} else {
> +			if (expired_starving(rq)) {
> +				enqueue_task(p,rq->expired);
> +				if (p->static_prio < rq->best_expired_prio)
> +					rq->best_expired_prio = p->static_prio;
> +			} else {
> +				if (!TASK_INTERACTIVE(p))
> +					p->extrarun_flag = 1;
> +				enqueue_task(p,rq->active);
> +			}
> +		}

(oh my, doing that to the scheduler upsets my tummy, but that aside...)

I don't see how that can really solve anything.  "Interactive" tasks
starting to use cpu heftily can still preempt and keep the special cased
cpu hog off the cpu for ages.  It also only takes one task in the
expired array to trigger the forced array switch with a fully loaded
cpu, and once any task hits the expired array, a stream of wakeups can
prevent the switch from completing for as long as you can keep wakeups
happening.

	-Mike
