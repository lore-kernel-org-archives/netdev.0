From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Wed, 2 Nov 2016 11:48:12 +0100
Message-ID: <7ac775f4-4638-3bd0-f6f8-e54c7d26e8d8@stressinduktion.org>
References: <cover.1477959702.git.tgraf@suug.ch>
 <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
 <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org>
 <CALx6S37s-pTxgqje9+FgmuvVgSZONGURAmJOemL6pOc6_Oepew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44662 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752535AbcKBKsQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 06:48:16 -0400
In-Reply-To: <CALx6S37s-pTxgqje9+FgmuvVgSZONGURAmJOemL6pOc6_Oepew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, Nov 2, 2016, at 00:07, Tom Herbert wrote:
> On Tue, Nov 1, 2016 at 3:12 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On 01.11.2016 21:59, Thomas Graf wrote:
> >> On 1 November 2016 at 13:08, Hannes Frederic Sowa
> >> <hannes@stressinduktion.org> wrote:
> >>> On Tue, Nov 1, 2016, at 19:51, Thomas Graf wrote:
> >>>> If I understand you correctly then a single BPF program would be
> >>>> loaded which then applies to all dst_output() calls? This has a huge
> >>>> drawback, instead of multiple small BPF programs which do exactly what
> >>>> is required per dst, a large BPF program is needed which matches on
> >>>> metadata. That's way slower and renders one of the biggest advantages
> >>>> of BPF invalid, the ability to generate a a small program tailored to
> >>>> a particular use. See Cilium.
> >>>
> >>> I thought more of hooks in the actual output/input functions specific to
> >>> the protocol type (unfortunately again) protected by jump labels? Those
> >>> hook get part of the dst_entry mapped so they can act on them.
> >>
> >> This has no advantage over installing a BPF program at tc egress and
> >> enabling to store/access metadata per dst. The whole point is to
> >> execute bpf for a specific route.
> >
> > The advantage I saw here was that in your proposal the tc egress path
> > would have to be chosen by a route. Otherwise I would already have
> > proposed it. :)
> >
> >>> Another idea would be to put the eBPF hooks into the fib rules
> >>> infrastructure. But I fear this wouldn't get you the hooks you were
> >>> looking for? There they would only end up in the runtime path if
> >>> actually activated.
> >>
> >> Use of fib rules kills performance so it's not an option. I'm not even
> >> sure that would be any simpler.
> >
> > It very much depends on the number of rules installed. If there are just
> > several very few rules, it shouldn't hurt performance that much (but
> > haven't verified).
> >
> Hannes,
> 
> I can say that the primary value we get out of using ILA+LWT is that
> we can essentially cache a policy decision in connected sockets. That
> is we are able to create a host route for each destination (thousands
> of them) that describes how to do the translation for each one. There
> is no route lookup per packet, and actually no extra lookup otherwise.

Exactly, that is why I do like LWT and the dst_entry socket caching
shows its benefits here. Also the dst_entries communicate enough vital
information up the stack so that allocation of sk_buffs is done
accordingly to the headers that might need to be inserted later on.

(On the other hand, the looked up BPF program can also be cached. This
becomes more difficult if we can't share the socket structs between
namespaces though.)

> The translation code doesn't do much at all, basically just copies in
> new destination to the packet. We need a route lookup for the
> rewritten destination, but that is easily cached in the LWT structure.
> The net result is that the transmit path for ILA is _really_ fast. I'm
> not sure how we can match this same performance tc egress, it seems
> like we would want to cache the matching rules in the socket to avoid
> rule lookups.

In case of namespaces, do you allocate the host routes in the parent or
child (net-)namespaces? Or don't we talk about namespaces right now at all?

Why do we want to do the packet manipulation in tc egress and not using
LWT + interfaces? The dst_entries should be able to express all possible
allocation strategies etc. so that we don't need to shift/reallocate
packets around when inserting an additional header. We can't express
those semantics with tc egress.

> On the other hand, I'm not really sure how to implement for this level
> of performance this in LWT+BPF either. It seems like one way to do
> that would be to create a program each destination and set it each
> host. As you point out would create a million different programs which
> doesn't seem manageable. I don't think the BPF map works either since
> that implies we need a lookup (?). It seems like what we need is one
> program but allow it to be parameterized with per destination
> information saved in the route (LWT structure).

Yes, that is my proposal. Just using the dst entry as meta-data (which
can actually also be an ID for the network namespace the packet is
coming from).

My concern with using BPF is that the rest of the kernel doesn't really
see the semantics and can't optimize or cache at specific points,
because the kernel cannot introspect what the BPF program does (for
metadata manipulation, one can e.g. specifiy that the program is "pure",
and always provides the same output for some specified given input, thus
things can be cached and memorized, but that framework seems very hard
to build).

That's why I am in favor of splitting this patchset down and allow the
policies that should be expressed by BPF programs being applied to the
specific subsystems (I am not totally against a generic BPF hook in
input or output of the protocol engines). E.g. can we deal with static
rewriting of L2 addresses in the neighbor cache? We already provide a
fast header cache for L2 data which might be used here?

I also fear this becomes a kernel by-pass:

It might be very hard e.g. to apply NFT/netfilter to such packets, if
e.g. a redirect happens suddenly and packet flow is diverted from the
one the user sees currently based on the interfaces and routing tables.

Those are just some thoughts so far, I still have to think more about
this. Thanks for the discussion, it is very interesting.

Bye,
Hannes
