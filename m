From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next 7/7] openvswitch: Use skb_zerocopy() for upcall
Date: Thu, 5 Dec 2013 21:29:43 +0000
Message-ID: <20131205212943.GA11286@casper.infradead.org>
References: <cover.1385813891.git.tgraf@suug.ch>
 <d840bbc411b72c1fe7c23a6afde6fc1ca20cca98.1385813891.git.tgraf@suug.ch>
 <CAEP_g=8j_JUk9mDc0KLPSCoWuKwssfCrTi3-Vp8jX4iNN-9Sng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59398 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab3LEV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 16:29:46 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8j_JUk9mDc0KLPSCoWuKwssfCrTi3-Vp8jX4iNN-9Sng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/13 at 09:43pm, Jesse Gross wrote:

Thanks for merging a first set of patches

> On Sat, Nov 30, 2013 at 4:21 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> > index 8eaa39a..867edf1 100644
> > --- a/net/openvswitch/datapath.c
> > +++ b/net/openvswitch/datapath.c
> > +static int queue_gso_packets(struct datapath *, struct net *, int dp_ifindex,
> > +                            struct sk_buff *, const struct dp_upcall_info *);
> > +static int queue_userspace_packet(struct datapath *, struct net *,
> > +                                 int dp_ifindex, struct sk_buff *,
> >                                   const struct dp_upcall_info *);
> 
> Should we drop the dp_ifindex arguments from these functions? It
> should be trivially derivable from struct datapath.

Sounds good
> 
> >  static size_t upcall_msg_size(const struct sk_buff *skb,
> > -                             const struct nlattr *userdata)
> > +                             const struct nlattr *userdata,
> > +                             unsigned int hdrlen)
> 
> I think that 'skb' is now unused.

Right

> 
> > @@ -427,7 +429,21 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
> >                 goto out;
> >         }
> >
> > -       len = upcall_msg_size(skb, upcall_info->userdata);
> > +       /* Complete checksum if needed */
> > +       if (skb->ip_summed == CHECKSUM_PARTIAL &&
> > +           (err = skb_checksum_help(skb)))
> > +               goto out;
> 
> I think that we can remove the hardware features argument to
> __skb_gso_segment() in queue_gso_packet(). It was there to take
> advantage of the copy and checksum optimization but that's no longer
> present.

In the case of a mapped skb we could still make use of it as we copy
the packet into the headroom. It would mean integrating the logic
into skb_zerocopy() though so I'd say we stay with what you propose.
It shouldn't be the fast path anyway.

> > @@ -447,13 +463,17 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
> >                           nla_len(upcall_info->userdata),
> >                           nla_data(upcall_info->userdata));
> >
> > -       nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
> > +       /* Only reserve room for attribute header, packet data is added
> > +        * in skb_zerocopy() */
> > +       if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
> > +               goto out;
> 
> Does this initialized 'err' on failure?

Good catch, I'll fix this up as well.
