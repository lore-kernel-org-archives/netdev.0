From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Fri, 15 Jul 2016 09:47:46 -0700
Message-ID: <20160715164744.GA3693@ast-mbp.thefacebook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36840 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbcGOQrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 12:47:52 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so2969937pab.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 09:47:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 09:18:13AM -0700, Tom Herbert wrote:
> > attaching program to all rings at once is a fundamental part for correct
> > operation. As was pointed out in the past the bpf_prog pointer
> > in the ring design loses atomicity of the update. While the new program is
> > being attached the old program is still running on other rings.
> > That is not something user space can compensate for.
> > So for current 'one prog for all rings' we cannot do what you're suggesting,
> > yet it doesn't mean we won't do prog per ring tomorrow. To do that the other
> > aspects need to be agreed upon before we jump into implementation:
> > - what is the way for the program to know which ring it's running on?
> >   if there is no such way, then attaching the same prog to multiple
> >   ring is meaningless.
> 
> Why would it need to know? If the user can say run this program on
> this ring that should be sufficient.

and the program would have to be recompiled with #define for every ring?
Ouch. We have to do on the fly recompilation for tracing because kernel
data structures are different between different kernels, but for
networking that will be unnecessary headache.

> >   we can easily extend 'struct xdp_md' in the future if we decide
> >   that it's worth doing.
> > - should we allow different programs to attach to different rings?
> >   we certainly can, but at this point there are only two XDP programs
> >   ILA router and L4 load balancer. Both require single program on all rings.
> >   Before we add new feature, we need to have real use case for it.
> > - if program knows the rx ring, should it be able to specify tx ring?
> >   It's doable, but it requires locking and performs will tank.
> >
> >> I'm starting to see more and more code assuming that a single global
> >> XDP program owns the NIC.  This will be harder and harder to cleanup.
> >
> 
> I agree with Jesper on this. If we mandate that all rings must run the
> same program enforces the notion that all rings must be equivalent,
> but that is not a requirement with the stack and doesn't leverage
> features like ntuple filter that are good to purposely steer traffic
> to rings having different. Just one program across all rings would be
> very limiting.
> 
> > Two xdp programs in the world today want to see all rings at once.
> 
> That is only under the initial design. For instance, one thing we
> could do for the ILA router is to split SIR prefixed traffic between
> different rings using an ntuple filter. That way we only need to run
> the ILA router on rings where we need to do translation, other traffic
> would not need to go through that XDP program.

now we talking :)
such use case would indeed be great to have, but we need to
spray sir prefixed traffic to all rx rings.
99% job of ila router is doing the routing, so we need all cpus
to participate, if we can reserve a ring to send non-sir-prefixed
traffic there, then it would be good. Can ntuple do that?
So it finally it goes back to what I was proposing all along.
1. we need to attach a program to all rings
2. we need to be able to exclude few rings from it for control
plane traffic.
we can preserve atomicity of attach with extra boolean flag per ring
that costs nothing in fast path, since the cost of 'if' is
one per napi invocation.

> > We don't need extra comlexity of figuring out number of rings and
> > struggling with lack of atomicity.
> 
> We already have this problem with other per ring configuration.

not really. without atomicity of the program change, the user space
daemon that controls it will struggle to adjust. Consider the case
where we're pushing new update for loadbalancer. In such case we
want to reuse the established bpf map, since we cannot atomically
move it from old to new, but we want to swap the program that uses
in one go, otherwise two different programs will be accessing
the same map. Technically it's valid, but difference in the programs
may cause issues. Lack of atomicity is not intractable problem,
it just makes user space quite a bit more complex for no reason.
