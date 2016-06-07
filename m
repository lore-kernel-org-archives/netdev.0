From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 3/5] openvswitch: add support to push and
 pop mpls for layer3 packets
Date: Tue, 7 Jun 2016 11:51:33 +0900
Message-ID: <20160607025130.GD31696@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-4-git-send-email-simon.horman@netronome.com>
 <CAOrHB_D0XoGUjSXztNMdektGgTMPxeVfbNF0WcTZuTbR4VYz5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36453 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcFGCvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 22:51:42 -0400
Received: by mail-pf0-f170.google.com with SMTP id z187so18808762pfz.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 19:51:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_D0XoGUjSXztNMdektGgTMPxeVfbNF0WcTZuTbR4VYz5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2016 at 03:02:00PM -0700, pravin shelar wrote:
> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Allow push and pop mpls actions to act on layer 3 packets by teaching
> > them not to access non-existent L2 headers of such packets.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > v10
> > * Limit scope of hdr in {push,pop}_mpls()
> >
> > v9
> > * New Patch
> > ---
> >  net/openvswitch/actions.c | 19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> >
> > diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> > index 9a3eb7a0ebf4..15f130e4c22b 100644
> > --- a/net/openvswitch/actions.c
> > +++ b/net/openvswitch/actions.c
> > @@ -172,7 +172,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >
> >         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
> >
> > -       update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
> > +       if (skb->mac_len)
> > +               update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
> We can move all ethernet related code in this if block. for example memmove().

My assumption is that the memmove() does nothing if skb->mac_len is zero
and from my point of view it seems clean to leave it where it is unless
the code around it also moves.

Is there other code you think could/should be moved into the
if (skb->mac_len) block?

> 
> >         if (!skb->inner_protocol)
> >                 skb_set_inner_protocol(skb, skb->protocol);
> >         skb->protocol = mpls->mpls_ethertype;
> > @@ -184,7 +185,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >  static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >                     const __be16 ethertype)
> >  {
> > -       struct ethhdr *hdr;
> >         int err;
> >
> >         err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
> > @@ -199,11 +199,16 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >         __skb_pull(skb, MPLS_HLEN);
> >         skb_reset_mac_header(skb);
> >
> > -       /* skb_mpls_header() is used to locate the ethertype
> > -        * field correctly in the presence of VLAN tags.
> > -        */
> > -       hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
> > -       update_ethertype(skb, hdr, ethertype);
> > +       if (skb->mac_len) {
> > +               struct ethhdr *hdr;
> > +
> > +               /* skb_mpls_header() is used to locate the ethertype
> > +                * field correctly in the presence of VLAN tags.
> > +                */
> > +               hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
> > +               update_ethertype(skb, hdr, ethertype);
> > +       }
> same here.
