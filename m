From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Mon, 6 Mar 2006 11:36:32 -0800
Message-ID: <41b516cb0603061136r4569d393i4e7ec5b7f66da669@mail.gmail.com>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	 <20060303214236.11908.98881.stgit@gitlost.site>
	 <20060305004534.1d94b3cf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750819AbWCFTge@vger.kernel.org>
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060305004534.1d94b3cf.akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/5/06, Andrew Morton <akpm@osdl.org> wrote:
> Chris Leech <christopher.leech@intel.com> wrote:
> >
> > +#ifdef CONFIG_NET_DMA
> >  +    tp->ucopy.dma_chan = NULL;
> >  +    if ((len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) && !sysctl_tcp_low_latency && __get_cpu_var(softnet_data.net_dma))
> >  +            dma_lock_iovec_pages(msg->msg_iov, len, &tp->ucopy.locked_list);
> >  +#endif
>
> The __get_cpu_var() here will run smp_processor_id() from preemptible
> context.  You'll get a big warning if the correct debug options are set.
>
> The reason for this is that preemption could cause this code to hop between
> CPUs.

I've been playing with different models of where to select which DMA
channel to use in order to reduce cache thrash and lock contention in
the driver.  It's not a clean per-cpu issue because per I/O there are
potentially operations happening in both the process syscall and the
netrx softirq context.

Right now the code delays selection of a DMA channel until the first
offload copy is ready to go, so the __get_cpu_var() you point out is
just checking to see if any hardware exists for I/OAT at this point
before doing the page pinning.  Before anything is done with the
channel the per-cpu pointer is re-read safely with preemption disabled
and a reference count is incremented.

 - Chris
