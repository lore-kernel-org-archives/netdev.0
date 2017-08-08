From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC net-next] net: xfrm: support setting an output mark.
Date: Tue, 8 Aug 2017 09:51:43 +0200
Message-ID: <20170808075143.GR2631@secunet.com>
References: <20170807092326.10239-1-lorenzo@google.com>
 <20170807111623.GQ2631@secunet.com>
 <CAKD1Yr2YXYed+vVgcyYo4XLAFXGjwwdSRucOmg+z2PVZD_A06Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        <herbert@gondor.apana.org.au>, Nathan Harold <nharold@google.com>,
        "Jonathan Basseri" <misterikkit@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34550 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750776AbdHHHvp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 03:51:45 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr2YXYed+vVgcyYo4XLAFXGjwwdSRucOmg+z2PVZD_A06Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 07, 2017 at 10:34:37PM +0900, Lorenzo Colitti wrote:
> On Mon, Aug 7, 2017 at 8:16 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > >       XFRMA_OFFLOAD_DEV,      /* struct xfrm_state_offload */
> > > +     XFRMA_OUTPUT_MARK,      /* __u32 */
> > >       __XFRMA_MAX
> >
> > Hm, why don't you use the existing xfrm_mark for this?
> > Having two different marks on one SA seems to be a bit odd.
> 
> I think using a separate mark is conceptually cleaner and much more flexible.
> 
> The existing xfrm_mark is constrained to match the mark of the socket
> that sends the packet (or the unencrypted packet that is transformed).
> Specifically (at least if I'm reading the code correctly),
> xfrm_policy_match requires:
> 
>     (fl->flowi_mark & pol->mark.m) == pol->mark.v
> 
> and xfrm_state_find requires:
> 
>     (mark & x->mark.m) == x->mark.v
> 
> so basically the SA mark is a subset of the bits of the policy mark,
> which is a subset of the bits of sk_mark.
> 
> On systems using mark-based routing (or at least on Android [1]), the
> mark decides how a packet is routed, and in order for things to work
> properly the routing of an IPsec tunnel should depend only on the
> tunnel configuration and not on the mark of any socket or any packet
> that is routed through that tunnel. The mark might select which tunnel
> to go through, and the output mark would decide how the tunnel packets
> are routed.

I thought you can just split the 32 bit mark into two 16 bit marks
by setting an appropriate mask at the xfrm and the routing mark.
But this has the drawback that the socket needs to know how possibly
tunneled packets should be routed.

> 
> A real use case is IWLAN [2], which is used to connect to 3GPP
> networks over wifi. The phone has the same IP addresses on the
> cellular interface and on an IPsec tunnel to a carrier gateway (PDG).
> On Android, a socket connected on the carrier network through a native
> interface such as LTE will have the socket mark that's specific to the
> carrier network. If the device then hands over the carrier connection
> to the IPsec tunnel over wifi, the socket will still have the mark of
> the LTE interface. If we used xfrm_mark, then the tunneled packets
> themselves will be routed on LTE instead of being routed on wifi. That
> obviously defeats the purpose.
> 
> Using XFRM_OUTPUT_MARK makes this much cleaner: the socket can
> continue to be marked with the carrier network's mark, and it's the
> IPsec tunnel itself that is bound to the wifi network using the mark
> in the SA.

So we transform the packet and may 'transform' the mark on the packet
too. This could make sense, but we have to point out the differences
between the xfrm_mark and the output_mark on the SA very explicit.
