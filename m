From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Fri, 20 Feb 2015 21:02:26 +0100
Message-ID: <20150220200226.GD23367@worktop.ger.corp.intel.com>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
 <1424455977-21903-6-git-send-email-fabf@skynet.be>
 <54E77E34.6050909@cogentembedded.com>
 <20150220185800.GR2896@worktop.programming.kicks-ass.net>
 <1424460713.5565.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424460713.5565.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 20, 2015 at 11:31:53AM -0800, Eric Dumazet wrote:
> On Fri, 2015-02-20 at 19:58 +0100, Peter Zijlstra wrote:

> Maybe this might be self documented in set_current_state(),
> as we have about 120 calls to __set_current_state(TASK_RUNNING)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 41c60e5302d7..26133da6445e 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -275,7 +275,11 @@ extern char ___assert_task_state[1 - 2*!!(
>  #define set_current_state(state_value)				\
>  	do {							\
>  		current->task_state_change = _THIS_IP_;		\
> -		set_mb(current->state, (state_value));		\
> +		if (__builtin_constant_p(state_value) &&	\
> +		    (state_value) == TASK_RUNNING)		\
> +			current->state = (state_value);		\
> +		else						\
> +			set_mb(current->state, (state_value));	\
>  	} while (0)

lkml.kernel.org/r/20150206163947.GR21418@twins.programming.kicks-ass.net

The problem is that there _might_ be someone relying on that barrier.

Its (very) unlikely, but you don't want to risk subtle borkage just
because. And I'm too lazy to go audit all of them :/
