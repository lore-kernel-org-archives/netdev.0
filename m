From: Dan Langlois <daniel.langlois@siemens.com>
Subject: Re: IGMPMSG_WRONGVIF only happens when true VIF is an OIF of
 correct IIF?
Date: Mon, 21 Feb 2011 17:03:54 +0100
Message-ID: <1298304234.2769.55.camel@thor>
References: <1298044016.2898.12.camel@thor>
	 <20110218171225.GC1739639@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taad0e1a.siemens.dk ([94.101.220.112]:2566 "EHLO
	taad0e1a.siemens.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751783Ab1BUQD6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:03:58 -0500
In-Reply-To: <20110218171225.GC1739639@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-18 at 18:12 +0100, David Lamparter wrote:
> On Fri, Feb 18, 2011 at 04:46:56PM +0100, Dan Langlois wrote:
> > Hi, I have a question about the IGMPMSG_WRONGVIF message.
> > I have MRT_ASSERT enabled but do not receive notifications.
> > However, if I enable MRT_PIM, I do get them.  I'm curious
> > why MRT_ASSERT alone isn't sufficient.
> > 
> > This if-statement appears in ip_mr_forward() in net/ipv4/ipmr.c
> > 
> >        if (true_vifi >= 0 && net->ipv4.mroute_do_assert &&
> >             /* pimsm uses asserts, when switching from RPT to SPT, 
> >                so that we cannot check that packet arrived on an oif. 
> >                It is bad, but otherwise we would need to move pretty
> >                large chunk of pimd to kernel. Ough... --ANK
> >              */      
> >             (net->ipv4.mroute_do_pim ||
> >              cache->mfc_un.res.ttls[true_vifi] < 255) && 
> >             time_after(jiffies,
> >                        cache->mfc_un.res.last_assert +
> > MFC_ASSERT_THRESH)) {
> >                 cache->mfc_un.res.last_assert = jiffies;
> >                 ipmr_cache_report(net, skb, true_vifi,
> > IGMPMSG_WRONGVIF);
> >         }       
> > 
> > 
> > By the time this statement is reached, it is known that the packet
> > did not arrive on the expected incoming interface (IIF) and thus a
> > "WRONGVIF" condition.  This if-statement decides whether a PIM-assert
> > notification needs to be sent to the multicast routing daemon.
> > 
> > The part of this if-statement I'm questioning is:
> >     (net->ipv4.mroute_do_pim ||
> >      cache->mfc_un.res.ttls[true_vifi] < 255) &&
> > 
> > I read this as:
> > "send WRONGVIF if PIM is enabled -OR-
> > the packet arrived on an outgoing interface OIF of the correct IIF"
> > 
> > So this statement is always true when PIM is enabled.
> > However, if only ASSERT is enabled, this statement is only true when
> > a packet is reflected back on an OIF.
> > 
> > Why not always send the assert for any WRONGVIF condition regardless
> > of the interface it came in on?  I mean, isn't that the point of
> > enabling MRT_ASSERT in the first place?  If the assertions weren't
> > wanted, just don't enable that feature, right?
> 
> The point of MRT_ASSERT is to aid in resolving duplication issues where
> you end up with multiple mrouters thinking they're responsible for the
> same subnet. This condition is indicated by more than 1 router on the
> subnet having the subnet as OIF on the (*,G) or (S,G). Therefore, your
> daemon receives the assertion if it is one of the forwarding mrouters,
> which it will only be if it's an OIF.
> 
> If your daemon doesn't have the target subnet listed as oif, the
> assumption is that a different mrouter has been elected to forward
> packets for this G/S,G to this subnet. The kernel knows that your daemon
> decided to not forward things to this subnet, so you are not involved in
> duplicates, so you don't get an assert.


Hmmm, well thanks for the explanation.  At least that explains why the
notification only applies to OIFs.  I suppose it would actually be wrong
to generate an ASSERT under any other condition?  


> The "PIM or" is a kludge to make PIM work, as indicated by the comment
> above the if. I'd have to refreshen my PIM knowledge to fully understand
> it or explain it ;)
> 
> > In our system, multicast streams may get rerouted through a different
> > VIF than what was first installed in the MFC cache.  I would very much
> > like to get these WRONGVIF assertions in this case, which is NOT the
> > case that a packet is seen on an OIF.
> > 
> > Of course I can simply enable MRT_PIM to get the messages, but in that
> > case I don't understand the reason for having two separate toggles
> > (MRT_ASSERT versus MRT_PIM).
> 
> I don't really understand you use case -- is this a case of another
> router showing up on the subnet and directing traffic to it? If so, why
> wasn't the first router directing traffic to it? Do you have a primary
> multicast forwarder election system in place?
> 

It is a bit of an odd setup:  We have multicast traffic aboard various
vehicles and we need to tunnel that back to a central server, to then be
forwarded on its various backend interfaces.  There is also traffic
coming in from those interfaces which needs to be directed back out to
one or more of these vehicles, depending on group membership.  We use
IGMP-based multicast forwarding daemons on the vehicles and on the
server (something like igmpproxyd, but bidirectional) and IP-IP tunnels
between the server and each vehicle.

These vehicles can be coupled together.  When this happens, we designate
one of the coupled vehicles as "master" and all traffic is sent through
the master tunnel, rather than each of the individual tunnels.  The
vehicles can of course be decoupled again, such that the multicast
streams need to be separated to individual tunnels again.  

Since the onboard equipment maintains its IP address despite coupling,
the (S,G) pairing remains the same, but now it is being forwarded
through the "master" rather than its own IP-IP tunnel.  This corresponds
to a different VIF on the server.  So this (de)coupling activity is why
traffic can shift between VIFs.  I noticed the "Wrong" statistic
incrementing, but didn't get an ASSERT.  Once I started digging I found
this if-statement and decided to ask about it.

Now I'm not too sure how to proceed.  In our system, the IIF for a (S,G)
can change due to these couplings.  Receiving the IGMPMSG_WRONGVIF
notification seems to be the most ideal fix, but maybe it isn't.  Can
you suggest something else?  Is it "dangerous" to enable PIM in an
IGMP-based multicast forwarding daemon? (e.g. a daemon that doesn't
implement PIM-SM or -DM, but is still protocol independent)  Perhaps
enabling MRT_PIM is actually the right solution?  Advice appreciated. 

cheers,
Dan

