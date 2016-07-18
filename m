From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/1] tracing, bpf: Implement function bpf_probe_write
Date: Sun, 17 Jul 2016 21:11:07 -0700
Message-ID: <20160718041105.GA36253@ast-mbp.thefacebook.com>
References: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com>
 <20160713170849.GA76615@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607131230210.19550@ircssh.c.rugged-nimbus-611.internal>
 <20160715054025.GA99435@ast-mbp>
 <alpine.DEB.2.02.1607151552400.24930@ircssh.c.rugged-nimbus-611.internal>
 <20160716023035.GA19373@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607161729010.12799@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35443 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbcGRELM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 00:11:12 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1607161729010.12799@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 17, 2016 at 03:19:13AM -0700, Sargun Dhillon wrote:
> 
> +static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	void *to = (void *) (long) r1;
> +	void *from = (void *) (long) r2;
> +	int  size = (int) r3;
> +
> +	/* check if we're in a user context */
> +	if (unlikely(in_interrupt()))
> +		return -EINVAL;
> +	if (unlikely(!current->pid))
> +		return -EINVAL;
> +
> +	return copy_to_user(to, from, size);
> +}

thanks for the patch, unfortunately it's not that straightforward.
copy_to_user might fault. Try enabling CONFIG_DEBUG_ATOMIC_SLEEP and
you'll see the splat since bpf programs are protected by rcu.
Also 'current' can be null and I'm not sure what current->pid does.
So the writing to user memory either has to be verified to avoid
sleeping and faults or we need to use something like task_work_add
mechanism. Ideas are certainly welcome.
