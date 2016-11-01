From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 01 Nov 2016 21:08:52 +0100
Message-ID: <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
References: <cover.1477959702.git.tgraf@suug.ch>
 <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41460 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932263AbcKAUIy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:08:54 -0400
In-Reply-To: <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016, at 19:51, Thomas Graf wrote:
> On 1 November 2016 at 03:54, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I do fear the complexity and debugability introduced by this patch set
> > quite a bit.
> 
> What is the complexity concern? This is pretty straight forward. I
> agree on debugability. This is being worked on separately as Alexei
> mentioned, to address this for all BPF integrations.

We have a multi-layered policy engine which is actually hard to inspect
from user space already.

We first resolve the rules, with forwards us to the table_id, where we
do the fib lookup, which in the end returns the eBPF program to use.

> > I wonder if architecturally it would be more feasible to add a generic
> > (bfp-)hook into into dst_output(_sk) and allow arbitrary metadata to be
> > added into the dsts.
> >
> > BPF could then be able to access parts of the metadata in the attached
> > metadata dst entries and performing the matching this way?
> 
> If I understand you correctly then a single BPF program would be
> loaded which then applies to all dst_output() calls? This has a huge
> drawback, instead of multiple small BPF programs which do exactly what
> is required per dst, a large BPF program is needed which matches on
> metadata. That's way slower and renders one of the biggest advantages
> of BPF invalid, the ability to generate a a small program tailored to
> a particular use. See Cilium.

I thought more of hooks in the actual output/input functions specific to
the protocol type (unfortunately again) protected by jump labels? Those
hook get part of the dst_entry mapped so they can act on them.

Another idea would be to put the eBPF hooks into the fib rules
infrastructure. But I fear this wouldn't get you the hooks you were
looking for? There they would only end up in the runtime path if
actually activated.

> > The reason why I would prefer an approach like this: irregardless of the
> > routing lookup we would process the skb with bpf or not. This gives a
> > single point to debug, where instead in your approach we first must
> > figure out the corresponding bpf program and then check for it specifically.
> 
> Not sure I see what kind of advantage this actually provides. You can
> dump the routes and see which programs get invoked and which section.

Dumping and verifying which routes get used might actually already be
quite complex on its own. Thus my fear.

> If it's based on metadata then you need to know the program logic and
> associate it with the metadata in the dst. It actually doesn't get
> much easier than to debug one of the samples, they are completely
> static once compiled and it's very simple to verify if they do what
> they are supposed to do.

At the same time you can have lots of those programs and you e.g. would
also need to verify if they are acting on the same data structures or
have the identical code.

It all reminds me a bit on grepping in source code which makes heavy use
of function pointers with very generic and short names.

> If you like the single program approach, feel free to load the same
> program for every dst. Perfectly acceptable but I don't see why we
> should force everybody to use that model.

I am concerned having 100ths of BPF programs, all specialized on a
particular route, to debug. Looking at one code file and its associated
tables seems still easier to me.

E.g. imaging we have input routes and output routes with different BPF
programs. We somehow must make sure all nodes kind of behave accordingly
to "sane" network semantics. If you end up with an input route doing bpf
processing and the according output node, which e.g. might be needed to
reflect ICMP packets, doesn't behave accordingly you at least have two
programs to debug already instead of a switch- or if-condition in one
single code location. I would like to "force" this kind of symmetry to
developers using eBPF, thus I thought meta-data manipulation and
verification inside the kernel would be a better attack at this problem,
no?

Bye,
Hannes
