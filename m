From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/1] tracing, bpf: Implement function bpf_probe_write
Date: Mon, 18 Jul 2016 23:13:54 -0700
Message-ID: <20160719061352.GA55865@ast-mbp.thefacebook.com>
References: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com>
 <20160713170849.GA76615@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607131230210.19550@ircssh.c.rugged-nimbus-611.internal>
 <20160715054025.GA99435@ast-mbp>
 <alpine.DEB.2.02.1607151552400.24930@ircssh.c.rugged-nimbus-611.internal>
 <20160716023035.GA19373@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607161729010.12799@ircssh.c.rugged-nimbus-611.internal>
 <20160718041105.GA36253@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607180330330.5362@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1607180330330.5362@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 03:57:17AM -0700, Sargun Dhillon wrote:
> 
> 
> On Sun, 17 Jul 2016, Alexei Starovoitov wrote:
> 
> >On Sun, Jul 17, 2016 at 03:19:13AM -0700, Sargun Dhillon wrote:
> >>
> >>+static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> >>+{
> >>+	void *to = (void *) (long) r1;
> >>+	void *from = (void *) (long) r2;
> >>+	int  size = (int) r3;
> >>+
> >>+	/* check if we're in a user context */
> >>+	if (unlikely(in_interrupt()))
> >>+		return -EINVAL;
> >>+	if (unlikely(!current->pid))
> >>+		return -EINVAL;
> >>+
> >>+	return copy_to_user(to, from, size);
> >>+}
> >
> >thanks for the patch, unfortunately it's not that straightforward.
> >copy_to_user might fault. Try enabling CONFIG_DEBUG_ATOMIC_SLEEP and
> >you'll see the splat since bpf programs are protected by rcu.
> >Also 'current' can be null and I'm not sure what current->pid does.
> >So the writing to user memory either has to be verified to avoid
> >sleeping and faults or we need to use something like task_work_add
> >mechanism. Ideas are certainly welcome.
> >
> >
> From casual inspection, I can't find where current can be null when
> in_interrupt() is false. Although, we can check before dereferencing it.
> When not in a user context, the pid of the task struct returns 0.
> 
> As far as preventing sleep, would the following alteration do? Or do we
> actually need something more sophisticated?
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index be89c148..45878f3 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -86,14 +86,19 @@ static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64
> r4, u64 r5)
>         void *to = (void *) (long) r1;
>         void *from = (void *) (long) r2;
>         int  size = (int) r3;
> +       struct task_struct *task = current;
> 
>         /* check if we're in a user context */
>         if (unlikely(in_interrupt()))
>                 return -EINVAL;
> -       if (unlikely(!current->pid))
> +       if (unlikely(!task || !task->pid))
>                 return -EINVAL;
> 
> -       return copy_to_user(to, from, size);
> +       /* Is this a user address, or a kernel address? */
> +       if (!access_ok(VERIFY_WRITE, to, size))
> +               return -EINVAL;
> +
> +       return probe_kernel_write(to, from, size);
>  }

I think it can actually work. The only concern is that comment
in access_ok() says that it may sleep whereas I couldn't find
any arch where that would be the case.
Could you please send an official patch with detailed commit log?
