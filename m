From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf program
Date: Fri, 15 Jul 2016 09:18:13 -0700
Message-ID: <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com> <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33067 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcGOQSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 12:18:14 -0400
Received: by mail-io0-f177.google.com with SMTP id 38so108636810iol.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 09:18:14 -0700 (PDT)
In-Reply-To: <20160715033057.GA98180@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 8:30 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Jul 14, 2016 at 09:25:43AM +0200, Jesper Dangaard Brouer wrote:
>>
>> I would really really like to see the XDP program associated with the
>> RX ring queues, instead of a single XDP program covering the entire NIC.
>> (Just move the bpf_prog pointer to struct mlx4_en_rx_ring)
>>
>> So, why is this so important? It is a fundamental architectural choice.
>>
>> With a single XDP program per NIC, then we are not better than DPDK,
>> where a single application monopolize the entire NIC.  Recently netmap
>> added support for running on a single specific queue[1].  This is the
>> number one argument our customers give, for not wanting to run DPDK,
>> because they need to dedicate an entire NIC per high speed application.
>>
>> As John Fastabend says, his NICs have thousands of queues, and he want
>> to bind applications to the queues.  This idea of binding queues to
>> applications, goes all the way back to Van Jacobson's 2006
>> netchannels[2].  Where creating an application channel allow for lock
>> free single producer single consumer (SPSC) queue directly into the
>> application.  A XDP program "locked" to a single RX queue can make
>> these optimizations, a global XDP programm cannot.
>>
>>
>> Why this change now, why can't this wait?
>>
>> I'm starting to see more and more code assuming that a single global
>> XDP program owns the NIC.  This will be harder and harder to cleanup.
>> I'm fine with the first patch iteration only supports setting the XDP
>> program on all RX queue (e.g. returns ENOSUPPORT on specific
>> queues). Only requesting that this is moved to struct mlx4_en_rx_ring,
>> and appropriate refcnt handling is done.
>
> attaching program to all rings at once is a fundamental part for correct
> operation. As was pointed out in the past the bpf_prog pointer
> in the ring design loses atomicity of the update. While the new program is
> being attached the old program is still running on other rings.
> That is not something user space can compensate for.
> So for current 'one prog for all rings' we cannot do what you're suggesting,
> yet it doesn't mean we won't do prog per ring tomorrow. To do that the other
> aspects need to be agreed upon before we jump into implementation:
> - what is the way for the program to know which ring it's running on?
>   if there is no such way, then attaching the same prog to multiple
>   ring is meaningless.

Why would it need to know? If the user can say run this program on
this ring that should be sufficient.

>   we can easily extend 'struct xdp_md' in the future if we decide
>   that it's worth doing.
> - should we allow different programs to attach to different rings?
>   we certainly can, but at this point there are only two XDP programs
>   ILA router and L4 load balancer. Both require single program on all rings.
>   Before we add new feature, we need to have real use case for it.
> - if program knows the rx ring, should it be able to specify tx ring?
>   It's doable, but it requires locking and performs will tank.
>
>> I'm starting to see more and more code assuming that a single global
>> XDP program owns the NIC.  This will be harder and harder to cleanup.
>

I agree with Jesper on this. If we mandate that all rings must run the
same program enforces the notion that all rings must be equivalent,
but that is not a requirement with the stack and doesn't leverage
features like ntuple filter that are good to purposely steer traffic
to rings having different. Just one program across all rings would be
very limiting.

> Two xdp programs in the world today want to see all rings at once.

That is only under the initial design. For instance, one thing we
could do for the ILA router is to split SIR prefixed traffic between
different rings using an ntuple filter. That way we only need to run
the ILA router on rings where we need to do translation, other traffic
would not need to go through that XDP program.

> We don't need extra comlexity of figuring out number of rings and
> struggling with lack of atomicity.

We already have this problem with other per ring configuration.

> There is nothing to 'cleanup' at this point.
>
> The reason netmap/dpdk want to run on a given hw ring come from
> the problem that they cannot share the nic with stack.
> XDP is different. It natively integrates with the stack.
> XDP_PASS is a programmable way to indicate that the packet is a control
> plane packet and should be passed into the stack and further into applications.
> netmap/dpdk don't have such ability, so they have to resort to
> bifurcated driver model.
> At this point I don't see a _real_ use case where we want to see
> different bpf programs running on different rings, but as soon as
> it comes we can certainly add support for it.
>
See ILA example above :-)

Tom
