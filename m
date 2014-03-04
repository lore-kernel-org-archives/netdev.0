From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Tue, 4 Mar 2014 14:53:58 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1403041439230.7122@intel.com>
References: <1393536377-32243-1-git-send-email-hkchu@google.com> <CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com> <CAPshTCgLo8ycMTtoa+D14+7pPxJaiC-jUzyR3PJcrMKFw9V0zA@mail.gmail.com> <20140228.165614.1112789771887381245.davem@davemloft.net>
 <5315FBAA.3030809@mellanox.com> <CAPshTCgT4sYp7KtPazrJNMBvK0HcSWeDT_EdvSdjv4C0qrueqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18844 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757240AbaCDWeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 17:34:23 -0500
In-Reply-To: <CAPshTCgT4sYp7KtPazrJNMBvK0HcSWeDT_EdvSdjv4C0qrueqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 4 Mar 2014, Jerry Chu wrote:

> Hi Or,
> 
> Thanks for writing this up.
> 
> On Tue, Mar 4, 2014 at 8:13 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> > On 28/02/2014 23:56, David Miller wrote:
> >>
> >> The topic of the skb->encapsulation semantics has come up several times in
> >> the past few weeks. We cannot move forward on any changes in this area until
> >> the semantics are well defined, and documented. Can someone work on a patch
> >> which documents skb->encapsulation properly, and then we can come back to
> >> fixing this bug? Thanks.
> >
> >
> > Lets try... the skb->encapsulation flag was introduced and used in 3.8 by
> > the
> > sequence of these three commits
> >
> > 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
> > d6727fe vxlan: capture inner headers during encapsulation
> > 6a674e9 net: Add support for hardware-offloaded encapsulation
> >
> > When discussed earlier on the list in the context of the skb->ip_summed
> > field,
> > Tom Herbert came with the following interpretation for the semantics which
> > Joseph confirmed
> >
> > "when skb->encapsulation is set the ip_summed is valid for both the inner
> > and outer header
> > (e.g. CHECKSUM_COMPLETE is always assumed okay for both layers). If
> > skb->encapsulation is not set then ip_summed is only valid for outer header"
> 
> For GRE encapped pkts is the following interpretation correct?
> 
> 1) ip_summed == CHECKSUM_COMPLETE
>     => csum covers IP payload csum of the outer IP datagram
> 
> 2) ip_summed == CHECKSUM_UNNECESSARY
> 2.1. skb->encapsulation is on => both GRE csum (if one is present) and TCP/UDP
> csum have been validated (assuming inner is a TCP or UDP pkt)

i40e also supports SCTP csumming for the inner packet, too.

> 
> 2.2. skb->encapsulation is off => only GRE csum (if one is present) is
> validated.
> 

Apart for the SCTP request for inclusion, it looks reasonable to me.

> >
> > As for the TX side of things, the change-log of commit 6a674e9 states
> >
> > "For Tx encapsulation offload, the driver will need to set the right bits in
> > netdev->hw_enc_features. The protocol driver will have to set the
> > skb->encapsulation bit and populate the inner headers, so the NIC driver
> > will use those inner headers to calculate the csum in hardware."
> 
> So we only support/care about csum offload for the inner pkts, which
> makes sense.

Well, we care about outer too. It is just that the inner headers are for 
the inner csum, the outer headers are for the outer csum. The outer 
headers will be always there anyway, so the patch introduced the inner 
ones. But I guess this is what you meant, right?

> 
> >
> > So in higher level, it seems that the role of the skb->encapsulation field
> > is to mark the skb to carry encapsulated packet for the code path between
> > the time the packet is encapsulated by the protocol driver (e.g vxlan/ipip)
> > to the time driver xmit is called. Or from the time driver rx code runs till
> > the the time the packet is decapsulated.
> >
> > Further, my personal interpretation was that on the rx path, skb should
> > carry the encapsulation flag **only** if the HW was able to offload the
> > inner checksum.
> 
> SGTM.
> 
> Jerry
> 
> >
> > Joseph, what's your thinking here?
> >
> > Or.
> >
> >
> 
