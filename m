From: Chris Redpath <Chris.Redpath@arm.com>
Subject: Re: [RFC 7/7] net: don't check for active hrtimer after adding it
Date: Wed, 09 Jul 2014 11:32:54 +0100
Message-ID: <53BD1A56.7000902@arm.com>
References: <cover.1404888801.git.viresh.kumar@linaro.org> <a8994b5dda7599c0d8ce9f66aef40b8587acf691.1404888801.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	"fweisbec@gmail.com" <fweisbec@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"preeti@linux.vnet.ibm.com" <preeti@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arvind Chauhan <Arvind.Chauhan@arm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Viresh Kumar <viresh.kumar@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a8994b5dda7599c0d8ce9f66aef40b8587acf691.1404888801.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Viresh,

On 09/07/14 07:55, Viresh Kumar wrote:
> hrtimer_start*() family never fails to enqueue a hrtimer to a clock-base. The
> only special case is when the hrtimer was in past. If it is getting enqueued to
> local CPUs's clock-base, we raise a softirq and exit, else we handle that on
> next interrupt on remote CPU.
>
> At several places in the kernel, we try to make sure if hrtimer was added
> properly or not by calling hrtimer_active(), like:
>
> 	hrtimer_start(timer, expires, mode);
> 	if (hrtimer_active(timer)) {
> 		/* Added successfully */
> 	} else {
> 		/* Was added in the past */
> 	}
>
> As hrtimer_start*() never fails, hrtimer_active() is guaranteed to return '1'.
> So, there is no point calling hrtimer_active().
>
> This patch updates net core to get this fixed.
>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> ---
>   net/core/pktgen.c | 2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index fc17a9d..f911acd 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2186,8 +2186,6 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
>   		do {
>   			set_current_state(TASK_INTERRUPTIBLE);
>   			hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);
> -			if (!hrtimer_active(&t.timer))
> -				t.task = NULL;
>
>   			if (likely(t.task))
>   				schedule();

I think this if condition can also be removed. hrtimer_init_sleeper 
copies the supplied task_struct * to the timer, which in this case is 
'current'. The check is likely to be there in case of !active case you 
removed.

>

--Chris
