From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Tue, 28 Sep 2010 13:42:57 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009281310060.12306@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <20100923.213823.137834706.davem@davemloft.net> <OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com> <20100927.105444.214208865.davem@davemloft.net>
 <OFC4EC0538.26831D99-ON882577AB.006B8055-882577AB.006D75FF@us.ibm.com> <alpine.DEB.2.00.1009271503420.14117@router.home> <OF4DDFA464.A933254C-ON882577AB.00754000-882577AB.00778C77@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
To: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OF4DDFA464.A933254C-ON882577AB.00754000-882577AB.00778C77-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2010, David Stevens wrote:

> > The second patch sets the intervals to X .. X + Rand (interval) and not
> to
> > a table of fixed intervals as you state here. I have pointed this out
> > before.
>
>         Sorry if I've misunderstood something you're proposing, but what
> you describe above would be certainly technically incorrect. There are
> really no circumstances for sending a report greater than <Interval>
> that is protocol-compliant. You can enforce a minimum greater than 0,
> which is a departure from both RFCs, though IGMPv2 uses wishy-washy
> language. The intent for both was to explicitly allow 0, IMO.

There is no igmp interval set by any igmp query yet so this is your usual
unresponsive crappy response to something else that we are not talking
about.

I thought you were talking about the "fixed intervals" that you saw in the
patch. These initial intervals are for unsolicited igmp reports (do I need
to add that statement to every sentence in a thread where we *only*
discuss unsolicited igmp issues?) and those "intervals" are randomized
and not fixed.

> > > as in the original patch. For v2, X=1 or 2 sec and Interval=10
> > > might work well, but for v3, the entire interval is 1 sec and I
> > > think I saw that the set-up time for the fabric may be on the
> > > order of 1 sec.
> >
> > Again there is no knowledge about V2 or V3 without a query and this is
> > during the period when no querier is known yet. You stated elsewhere
> that
> > I can assume V3 by default? So 1 sec?
>
>         Yes, without a querier or the tunable to force it to IGMPv2,
> the default is IGMPv3. It appears there is a bug where IGMPv3 is also
> using a 10sec interval (haven't verified that), but a 1 sec interval

You do not have the linux source code tree available?

from net/ipv4/igmp.c:

#define IGMP_Unsolicited_Report_Interval        (10*HZ)

> as required makes your situation worse, not better. It makes it even
> more likely that all the initial reports will occur before your set-up
> is done.

Right. So can you please give me an approach that considers all these
issues and does not invent problem that do not exist, stays within the
subject discussed and follows the RFCs?

  > > There can be any number of reasons that a short outage could prevent the
> > packets from going through. A buffer overrun (that you mentioned
> > elsewhere) usually causes lots of packets to be lost. Buffer overrun
> > scenarios usually mean that all igmp queries are lost.
>
>         You're arguing against protocol compliance. I didn't define
> the protocol, I only implemented it. And your view is through the
> IB lens, but I don't believe this is an actual problem in any way
> for typical networks. If you wrote a standards-track RFC that modifies
> IGMP for NBMA networks that require a delay or different parameters
> there, I'd have no objection to implementing that. Unilaterally
> changing linux's behavior on all network types without cause for
> departing from RFC on the most common types is another matter.

The RFCs state that the igmp queries have to be repeated at least 3
times. The first patch ensures that a mininum time passes between two igmp
reports (to avoid them getting lost in one go). The second patch doubles
the number of igmp reports and increases the intervals so that we still
have a chance to process the join before the next igmp query is send by
the router (which can be minuates away).

It fixes buggy havior that we see because multicast joins take very long
or fail outright.

 > > There is no solution on the IB layer since there is no notification when
> > the fabric reconfiguration necessary for an multicast group is complete.
>
>         Certainly that's not true; without notification, you can queue for
> first use of a new hardware multicast address and send the queue after an
> appropriate delay (1 sec? If that covers your set-up time). If you had
> positive acknowledgement from the IB network, you'd know exactly when to
> do it, but there's no need to change anything for non-IB networks here.

So you want an arbitrary delay for all new multicast traffic to be
created? I'd rather have a series of staggered attempts so that we can
avoid this setup time.

Also the setup time varies greatly depending on the complexity of the
fabric changes. It can be extremely fast if the multicast group is already
in use by others in the fabric. Adding a delay penalizes everyone
unnecessarily.

Also much of these seems to be contigent on IGMPv3. We are using igmpv2.

> > The querier is of not use since (for the gazillionth of times) this is
> an
> > unsolicited IGMP report. If there is a querier then the unsolicited igmp
> > reports would not be used but the timeout indicated by the querier would
> > be used.
>
>         A querier affects unsolicited reports because it sets both the
> query interval and the robustness value. If you want to send 10 reports,
> you can cause that by having a querier that sets it to that many. The
> initial join would then send 10 reports and the query interval can also
> be as low as you like.

The Linux IGMP subsystem does not support either of those at this point.
When the multicast group is created it has no notion of query intervals
until the first igmp query is received. That is the period of interest
that we are discussing!

>         But the linux code is not just for your particular problem or
> particular configuration. You can solve your problem by adding a querier,
> but I know you're trying to do it without. The mail I was responding to
> referred also to the case of a querier present, which is actually the
> "normal" case for using full IGMP is. I'm saying that for the non-querier
> case, making those per-interface configurable is reasonable because
> they *are* querier-changeable, but you can also use a querier to change
> it _for_the_unsolicited_reports_, as well as making the querier interval
> small enough that you don't have to care at all whether any or all of
> the unsolicited reports are lost.

The network of course has a querier that sents igmp requests in intervals
that could span minutes. We are talking about the period of time after a
join when a multicast group has been created but we have not reached the
time when the router sends an igmp query and where the various bits of
information about the igmp handling can be determined for the multicast
group.

I am not sure that you comprehend the basics of IGMP processing in the
kernel. I see knowledge about IGMP in general but you have a difficult
time to relate that to what the Linux kernel actually does.

Would you please have a look at the source code?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
