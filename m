From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/4] Move execute_set_action to lib/odp-util.c
Date: Tue, 9 Apr 2013 12:11:19 +0900
Message-ID: <20130409031119.GF11444@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
 <1365403431-18102-3-git-send-email-horms@verge.net.au>
 <CAEP_g=_JYu0m4G01osWCaMhu6ESdiryMQYvikfpuNNYj6dNn_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38106 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934544Ab3DIDLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 23:11:22 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_JYu0m4G01osWCaMhu6ESdiryMQYvikfpuNNYj6dNn_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 01:29:52PM -0700, Jesse Gross wrote:
> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
> > Move execute_set_action from lib/dpif-netedev.c to lib/odp-util.c
> >
> > This is in preparation for using execute_set_action()
> > in lib/odp-util.c to handle recirculation/
> >
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> >
> > packet.c might be a better place for execute_set_action()
> > but I'm unsure if accessing struct ovs_key_ethernet would
> > lead to a layering violation.
> 
> I'd be tempted to just put this in it's own file.  As you say, it
> doesn't really fit in either of the two existing ones.

perhaps execute-action.c ?

> 
> > diff --git a/lib/odp-util.c b/lib/odp-util.c
> > index e18e109..ad5873c 100644
> > --- a/lib/odp-util.c
> > +++ b/lib/odp-util.c
> > @@ -2420,3 +2420,79 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
> >      commit_set_priority_action(flow, base, odp_actions);
> >      commit_set_skb_mark_action(flow, base, odp_actions);
> >  }
> > +
> > +static void
> > +dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)
> 
> I think this function should be given a more generic name and possibly
> moved to packet.c.

Sure, how about eth_set_src_and_dst()

> > +void
> > +execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
> > +                   uint32_t *skb_mark)
> > +{
> > +    enum ovs_key_attr type = nl_attr_type(a);
> > +    const struct ovs_key_ipv4 *ipv4_key;
> > +    const struct ovs_key_ipv6 *ipv6_key;
> > +    const struct ovs_key_tcp *tcp_key;
> > +    const struct ovs_key_udp *udp_key;
> > +
> > +    switch (type) {
> > +    case OVS_KEY_ATTR_PRIORITY:
> > +    case OVS_KEY_ATTR_TUNNEL:
> > +        /* not implemented */
> > +        break;
> 
> Don't we need to carry this information along as well similar to skb->mark?

Most likely, sorry for missing that.

> Also, is there a reason to not have the code for push/pop actions here as well?

Good point.

With that in mind perhaps execute_set_or_mpls_action() would
be a good name for the function?
