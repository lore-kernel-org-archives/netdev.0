From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 4/6] perf, bpf: add perf events core support
 for BPF_PROG_TYPE_PERF_EVENT programs
Date: Thu, 1 Sep 2016 10:12:51 +0200
Message-ID: <20160901081251.GL10153@twins.programming.kicks-ass.net>
References: <1472680243-1326608-1-git-send-email-ast@fb.com>
 <1472680243-1326608-5-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472680243-1326608-5-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2016 at 02:50:41PM -0700, Alexei Starovoitov wrote:
> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
> index 97bfe62f30d7..dcaaaf3ec8e6 100644
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -679,6 +679,8 @@ struct perf_event {
>  	u64				(*clock)(void);
>  	perf_overflow_handler_t		overflow_handler;
>  	void				*overflow_handler_context;

> +	perf_overflow_handler_t		orig_overflow_handler;
> +	struct bpf_prog			*prog;

Should we put that under CONFIG_BPF_SYSCALL too?

> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 3cfabdf7b942..305433ab2447 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c

> @@ -7637,11 +7637,75 @@ static void perf_event_free_filter(struct perf_event *event)
>  	ftrace_profile_free_filter(event);
>  }
>  
> +static void bpf_overflow_handler(struct perf_event *event,
> +				 struct perf_sample_data *data,
> +				 struct pt_regs *regs)
> +{
> +	struct bpf_perf_event_data_kern ctx = {
> +		.data = data,
> +		.regs = regs,
> +	};
> +	int ret = 0;
> +
> +#ifdef CONFIG_BPF_SYSCALL
> +	preempt_disable();
> +	if (unlikely(__this_cpu_inc_return(bpf_prog_active) != 1))
> +		goto out;
> +	rcu_read_lock();
> +	ret = BPF_PROG_RUN(event->prog, (void *)&ctx);
> +	rcu_read_unlock();
> + out:

Please, no leading space before labels. Use something like:

[diff "default"]
        xfuncname = "^[[:alpha:]$_].*[^:]$"

In your .gitconfig if you want to keep diff output 'sane'.

> +	__this_cpu_dec(bpf_prog_active);
> +	preempt_enable();
> +#endif
> +	if (!ret)
> +		return;
> +
> +	event->orig_overflow_handler(event, data, regs);
> +}

Other than that, ACK.
