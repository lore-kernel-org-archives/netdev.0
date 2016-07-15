From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Fri, 15 Jul 2016 10:21:23 +0200
Message-ID: <20160715102123.28efb815@redhat.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
	<20160714092543.776f8d8c@redhat.com>
	<20160715033057.GA98180@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbcGOIVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 04:21:31 -0400
In-Reply-To: <20160715033057.GA98180@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2016 20:30:59 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Thu, Jul 14, 2016 at 09:25:43AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > I would really really like to see the XDP program associated with the
> > RX ring queues, instead of a single XDP program covering the entire NIC.
> > (Just move the bpf_prog pointer to struct mlx4_en_rx_ring)
> > 
> > So, why is this so important? It is a fundamental architectural choice.
> > 
> > With a single XDP program per NIC, then we are not better than DPDK,
> > where a single application monopolize the entire NIC.  Recently netmap
> > added support for running on a single specific queue[1].  This is the
> > number one argument our customers give, for not wanting to run DPDK,
> > because they need to dedicate an entire NIC per high speed application.
> > 
> > As John Fastabend says, his NICs have thousands of queues, and he want
> > to bind applications to the queues.  This idea of binding queues to
> > applications, goes all the way back to Van Jacobson's 2006
> > netchannels[2].  Where creating an application channel allow for lock
> > free single producer single consumer (SPSC) queue directly into the
> > application.  A XDP program "locked" to a single RX queue can make
> > these optimizations, a global XDP programm cannot.
> > 
> > 
> > Why this change now, why can't this wait?
> > 
> > I'm starting to see more and more code assuming that a single global
> > XDP program owns the NIC.  This will be harder and harder to cleanup.
> > I'm fine with the first patch iteration only supports setting the XDP
> > program on all RX queue (e.g. returns ENOSUPPORT on specific
> > queues). Only requesting that this is moved to struct mlx4_en_rx_ring,
> > and appropriate refcnt handling is done.  
> 
> attaching program to all rings at once is a fundamental part for correct
> operation. As was pointed out in the past the bpf_prog pointer
> in the ring design loses atomicity of the update. While the new program is
> being attached the old program is still running on other rings.
> That is not something user space can compensate for.

I don't see a problem with this.  This is how iptables have been
working for years.  The iptables ruleset exchange is atomic, but only
atomic per CPU.  It's been working fine for iptables.

> So for current 'one prog for all rings' we cannot do what you're suggesting,
> yet it doesn't mean we won't do prog per ring tomorrow. To do that the other
> aspects need to be agreed upon before we jump into implementation:
> - what is the way for the program to know which ring it's running on?
>   if there is no such way, then attaching the same prog to multiple
>   ring is meaningless.
>   we can easily extend 'struct xdp_md' in the future if we decide
>   that it's worth doing.

Not sure we need to extend 'struct xdp_md' with a ring number. If we
allow assigning the program to a specific queue (if not we might need to).

The setup sequence would be:
1. userspace setup ntuple filter into a queue number
2. userspace register XDP program on this queue number
3. kernel XDP program queue packets into SPSC queue (like netmap)
   (no locking, single RX queue, single producer)
4. userspace reads packets from SPSC queue (like netmap)

For step 2, the XDP program should return some identifier for the SPSC
queue.  And step 3, is of cause a new XDP feature.


> - should we allow different programs to attach to different rings?

Yes, that is one of my main points.  You assume that a single program
own the entire NIC.  John's proposal was that he can create 1000's of
queues, and wanted to bind this to (e.g. 1000) different applications.


>   we certainly can, but at this point there are only two XDP programs
>   ILA router and L4 load balancer. Both require single program on all rings.
>   Before we add new feature, we need to have real use case for it.
> - if program knows the rx ring, should it be able to specify tx ring?
>   It's doable, but it requires locking and performs will tank.

No, the selection of the TX ring number is something internally.  For
forwarding inside the kernel (_not_ above SPSC), I imagine the XDP
selection of the TX "port" will be using some port-table abstraction.
Like the mSwitch article:
 "mSwitch: a highly-scalable, modular software switch"
 http://info.iet.unipi.it/~luigi/20150617-mswitch-paper.pdf


> > I'm starting to see more and more code assuming that a single global
> > XDP program owns the NIC.  This will be harder and harder to
> > cleanup.  
> 
> Two xdp programs in the world today want to see all rings at once.
> We don't need extra comlexity of figuring out number of rings and
> struggling with lack of atomicity.
> There is nothing to 'cleanup' at this point.
> 
> The reason netmap/dpdk want to run on a given hw ring come from
> the problem that they cannot share the nic with stack.
> XDP is different. It natively integrates with the stack.
> XDP_PASS is a programmable way to indicate that the packet is a
> control plane packet and should be passed into the stack and further
> into applications. netmap/dpdk don't have such ability, so they have
> to resort to bifurcated driver model.

Netmap have this capability already:
 https://blog.cloudflare.com/partial-kernel-bypass-merged-netmap/

> At this point I don't see a _real_ use case where we want to see
> different bpf programs running on different rings, but as soon as
> it comes we can certainly add support for it.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
