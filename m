From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 20:58:12 +0200
Message-ID: <20110628185811.GA2121496@jupiter.n2.diac24.net>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
 <20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
 <BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
 <20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
 <BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
 <BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
 <20110628150257.GB126252@jupiter.n2.diac24.net>
 <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
 <20110628160018.GC126252@jupiter.n2.diac24.net>
 <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:35987 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760795Ab1F1S6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 14:58:24 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2011 at 07:34:57PM +0100, Nick Carter wrote:
> > Yes, the default is a dumb hub (IMHO correctly so). And a dumb hub will
> > forward 802.1X packets (IMHO also correctly so).
> >
> > Why should we specifically add a knob for EAPOL? Next we're adding one
> > for STP itself, then one for LLDP, then one for Cisco's deprecated
> > crap (CDP, DTP, ...) etc.
> >
> > If you want a dumb hub that drops EAPOL, use ebtables.
> >
> > -David
> >
> >
> If we are not going to have an EAPOL knob, but we are going to act as
> a repeater when STP is off then we still need these diffs to forward
> the PAE group address.
> (In fact we cant just act as a repeater because of the recent ethernet
> bonding regression)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 90e985b..267f581 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -163,7 +163,8 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
>                         goto drop;
> 
>                 /* If STP is turned off, then forward */
> -               if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
> +               if (p->br->stp_enabled == BR_NO_STP &&
> +                       (dest[5] == 0 || skb->protocol == htons(ETH_P_PAE)))
>                         goto forward;
> Nick

That code actually looks quite wrong to me, we should be forwarding all of
the 01:80:C2:00:00:0x groups in non-STP mode, especially :0E and :0D.
(LLDP and GVRP/MVRP)

Pause frames are the one exception that makes the rule, but as the
comment a few lines above states, "Pause frames shouldn't be passed up by
driver anyway".

Btw, what might make sense is a general knob for forwarding those
link-local groups, split off from the STP switch so the STP switch
controls only the :00 (STP) group. That way you can decide separately
whether you want to be LLDP/GVRP/802.1X/... transparent and whether you
want to run STP.
Not sure if it's needed, it can always be done with ebtables...


-David

