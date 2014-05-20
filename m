From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to kernel
Date: Tue, 20 May 2014 19:48:17 +0900
Message-ID: <20140520104704.GA2979@verge.net.au>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <CAEP_g=-X=T2hJoXTV5ptZRvf1WPgYa1xusczwSR1bUYAZ5yaqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39085 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaETKsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 06:48:22 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-X=T2hJoXTV5ptZRvf1WPgYa1xusczwSR1bUYAZ5yaqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 06:34:05PM -0700, Jesse Gross wrote:
> I have some miscellaneous comments on things that I noticed, all of
> which are pretty small. I will probably have a few more tomorrow but
> my hope is that we can get this in soon.
> 
> On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 603c7cb..7c3ae0c 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > +static int push_mpls(struct sk_buff *skb,
> > +                    const struct ovs_action_push_mpls *mpls)
> > +{
> > +       __be32 *new_mpls_lse;
> > +       struct ethhdr *hdr;
> > +
> > +       if (skb_cow_head(skb, MPLS_HLEN) < 0) {
> > +               kfree_skb(skb);
> > +               return -ENOMEM;
> > +       }
> 
> I think it would be better to not free the skb on error here - it
> introduces an exception case in the call to push_mpls() that would be
> otherwise handled if we didn't free it.

Thanks, I have fixed it up as you suggest.

> When we set the EtherType at the bottom of the function, I don't think
> that it is correct in the presence of VLAN tags because it will set
> the outer EtherType.

I believe this comes back to the problem we have with tag ordering. A
problem which after the most recent discussion of this topic I planned to
kick into the long grass by only allowing push MPLS actions on packets with
a well defined tag order.

This is the purpose of the white list in ovs_nla_copy_actions__().  It is
supposed to only push MPLS actions for flows with an IPv4, IPv6, ARP, RARP
or MPLS ethtype.  However, I now think that the white list likely does not
work for VLAN packets as their flow's ethtype will be the inner-ethtype
(the one inside the VLAN tag) rather than a VLAN ethtype.

I'm unsure how you would like to handle this but one possibility would be
simply for push_mpls() to return an error if it is called on an skb with a
VLAN tag present or if the ethtype doesn't match a white list. Another is
to set the inner ethtype.

> > +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> > +{
> > +       struct ethhdr *hdr;
> > +       int err;
> > +
> > +       if (unlikely(skb->len < skb->mac_len + MPLS_HLEN))
> > +               return -EINVAL;
> 
> I don't think this check is necessary since we would have rejected
> such packets at flow validation time.

Thanks, I have removed it.

> > +static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
> > +{
> > +       __be32 *stack = (__be32 *)mac_header_end(skb);
> > +       int err;
> > +
> > +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +       if (unlikely(err))
> > +               return err;
> > +
> > +       if (skb->ip_summed == CHECKSUM_COMPLETE) {
> > +               __be32 diff[] = { ~(*stack), *mpls_lse };
> > +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> > +                                         ~skb->csum);
> > +       }
> 
> Is it possible to use csum_replace4() to simplify this?

I'm not sure that it can be due to its use of csum_fold() and csum_unfold().
In particular I notice that inet_proto_csum_replace4() uses code
similar to the above rather than csum_replace4().

> > @@ -701,6 +815,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb, bool recirc)
> >                 goto out_loop;
> >         }
> >
> > +       ovs_skb_init_inner_protocol(skb);
> 
> I think we talked about some time ago but it seems like this will get
> reset by recirculation (although maybe it's unlikely that
> recirculation will get used on output).

Thanks, I think that can be fixed as follows:

	if (!recirc)
		ovs_skb_init_inner_protocol(skb);

> Also, maybe I'm missing something but I don't see where we actually
> set the inner protocol.

Thanks, I noticed that too. I have added the following back into push_mpls(),
just before skb->protocol is updated.

	if (!ovs_skb_get_inner_protocol(skb))
		ovs_skb_set_inner_protocol(skb, skb->protocol);
