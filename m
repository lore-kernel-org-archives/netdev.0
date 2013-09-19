From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Thu, 19 Sep 2013 10:57:35 -0500
Message-ID: <20130919155732.GC24919@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Pfaff <blp@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58386 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab3ISP6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 11:58:24 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 6741d81..2335014 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > +/* Push MPLS after the ethernet header. */
> > +static int push_mpls(struct sk_buff *skb,
> > +                    const struct ovs_action_push_mpls *mpls)
> [...]
> > +       /* update mac_len for subsequent pop_mpls actions. */
> > +       skb->mac_len += VLAN_HLEN;
> 
> Is this supposed to be part of put_vlan()?

Thanks, this does seem bogus.

I will remove it as mac_len is already incremented in put_vlan().

> 
> [...]
> 
> > +       if (skb->ip_summed == CHECKSUM_COMPLETE)
> > +               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> > +                                                            MPLS_HLEN, 0));
> > +
> > +       hdr = (struct ethhdr *)(skb_mac_header(skb));
> 
> I think you could simplify this by using eth_hdr().

Thanks, I have updated the code as follows:

	hdr = eth_hdr(skb);

> > @@ -616,6 +736,13 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
> >                 goto out_loop;
> >         }
> >
> > +       /* Needed to initialise inner protocol on kernels older
> > +        * than v3.11 where skb->inner_protocol is not present
> > +        * and compatibility code uses the OVS_CB(skb) to store
> > +        * the inner protocol.
> > +        */
> > +       ovs_skb_set_inner_protocol(skb, skb->protocol);
> 
> The comment makes it sound like this code should just be deleted when
> upstreaming. However, I believe that we still need to initialize this
> field, right? Is this the best place do it or should it be conditional
> on adding a first MPLS header? (i.e. what happens if inner_protocol is
> already set and the packet simply passes through OVS?)

I believe there are several problems here.

The first one, which my comment was written around is that I think that if
inner_protocol is a field of struct sk_buff then we can rely on it already
being initialised.  However, if we are using compatibility code, where
inner_protcol is called in the callback field of struct sk_buff then I
think that OVS needs to initialise it.

Perhaps a good solution to that problem is to add
an ovs_skb_reset_inner_protocol() call which sets
the inner_protocol unconditionally if it is not a field of struct sk_buff.

I believe this could be called from ovs_execute_actions().


A second problem is one that you raise which I had not considered
which is how to handle things if inner_protocol is already set.

I believe this should only occur in the case where inner_protocol
is a field of struct sk_buff and I think it would be most convenient
to set it conditionally in ovs_skb_reset_inner_protocol().
I think that if it is not set it should be zero but it should be
safe to check for values less than ETH_P_802_3_MIN.

In short, I am thinking of something like this:

#ifdef HAVE_INNER_PROTOCOL
static inline void ovs_skb_reset_inner_protocol(struct sk_buff *skb)
{
	OVS_CB(skb)->inner_protocol = skb->protocol;
}
#else
static inline void ovs_skb_reset_inner_protocol(struct sk_buff *skb)
{
	if (skb->inner_protocol < ETH_P_802_3_MIN)
		skb->inner_protocol = skb->protocol;
}
#endif



Pravin has also raised a separate discussion on wheather
OVS_GSO_CB should be used in place of OVS_CB. I would like
to continue that discussion in the sub-thread where is started.
Though obviously the outcome of that discussion may affect the
exact implementation of a solution to the problem discussed above.

> > diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
> > index 215a47e..69f24d1 100644
> > --- a/datapath/vport-netdev.c
> > +++ b/datapath/vport-netdev.c
> > @@ -287,8 +291,17 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> > +       inner_protocol = ovs_skb_get_inner_protocol(skb);
> > +       if (eth_p_mpls(skb->protocol) && !eth_p_mpls(inner_protocol))
> > +               mpls = true;
> > +
> > +       if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
> > +               vlan = true;
> 
> A couple of thoughts on this:
>  - I'm not sure that the check on inner_protocol is right since I
> don't think it will be set to an MPLS EtherType in any real situation.
> I think you can just drop it.

Sure, that sounds reasonable.

>  - Can we simplify the loop by just inserting the vlan tag (if
> necessary), calling skb_gso_segment(), and sending the packet? I think
> it should be possible now that our skb_gso_segment() backport is more
> robust and it would make things easier to read.

Pravin also raised that idea and yes I think it should be possible.
I have posted a prototype in the sub-thread where Pravin reviewed the code
(as I read that first).

>  - Can we have some kind of version check for MPLS, similar to what we
> do for VLAN, so that we don't call into this on kernels >= 3.11?

Sure, I'll see about making that so.

> These are all pretty targeted comments though, as was the one in the
> previous kernel patch so I am basically happy with this overall.
> 
> To move forward with this:
>  - Pravin, would you mind double checking the GSO compat code?
>  - Ben, do you want to take over for the userspace portions of the
> series on the assumption that the above comments can be fixed fairly
> easily?
> 
