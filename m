From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.35 6/6] datapath: Add basic MPLS support to kernel
Date: Fri, 9 Aug 2013 17:17:20 +0900
Message-ID: <20130809081720.GA25800@verge.net.au>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
 <1374289623-17056-7-git-send-email-horms@verge.net.au>
 <CAEP_g=-4gvJEbQ68=gBUpa-j2Kz_DX_zkV4KKvtewa=rbsSZiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34370 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967682Ab3HIIRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:17:24 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-4gvJEbQ68=gBUpa-j2Kz_DX_zkV4KKvtewa=rbsSZiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 05:39:55PM -0700, Jesse Gross wrote:
> On Fri, Jul 19, 2013 at 8:07 PM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 0a2def6..99e02cf 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > +/* The end of the mac header.
> > + *
> > + * For non-MPLS skbs this will correspond to the network header.
> > + * For MPLS skbs it will be berfore the network_header as the MPLS
> > + * label stack lies between the end of the mac header and the network
> > + * header. That is, for MPLS skbs the end of the mac header
> > + * is the top of the MPLS label stack.
> > + */
> > +static unsigned char *mac_header_end(const struct sk_buff *skb)
> > +{
> > +       return skb_mac_header(skb) + skb->mac_len;
> > +}
> > +
> > +static void set_ethertype(struct sk_buff *skb, __be16 ethertype, bool inner)
> > +{
> > +       struct ethhdr *hdr;
> > +       if (inner)
> > +               /* mac_header_end() is used to locate the ethertype
> > +                * field correctly in the presence of VLAN tags. */
> > +               hdr = (struct ethhdr *)(mac_header_end(skb) - ETH_HLEN);
> > +       else
> > +               hdr = (struct ethhdr *)(skb_mac_header(skb));
> > +       hdr->h_proto = ethertype;
> > +}
> > +
> > +/* Push MPLS after the ethernet header. We blindly ignore any other tags,
> > + * assuming that actions are ordered correctly. */
> > +static int push_mpls(struct sk_buff *skb,
> > +                    const struct ovs_action_push_mpls *mpls)
> > +{
> > +       __be32 *new_mpls_lse;
> > +       int err;
> > +
> > +       if (skb_cow_head(skb, MPLS_HLEN) < 0)
> > +               return -ENOMEM;
> > +
> > +       err = make_writable(skb, skb->mac_len);
> > +       if (unlikely(err))
> > +               return err;
> > +
> > +       skb_push(skb, MPLS_HLEN);
> > +       memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
> > +               ETH_HLEN);
> > +       skb_reset_mac_header(skb);
> > +
> > +       new_mpls_lse = (__be32 *)(skb_mac_header(skb) + ETH_HLEN);
> > +       *new_mpls_lse = mpls->mpls_lse;
> > +
> > +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> > +                                                            MPLS_HLEN, 0));
> > +
> > +       set_ethertype(skb, mpls->mpls_ethertype, false);
> > +       if (skb->protocol != htons(ETH_P_8021Q))
> > +               skb->protocol = mpls->mpls_ethertype;

Hi Jesse,

> It seems to me that there is a fair amount of stuff left over from
> before the tag ordering conversion. For example, shouldn't we set the
> EtherType unconditionally now if we are pushing tags onto the front?

Yes, I think so.

> Do we still need to dig into the packet to find the last EtherType if
> we are now working on the outer tag?

I believe that the code is a little confusing.
Joe has refactored it to make it more obvious what is going on
and in particular that the last ether type is needed for MPLS pop
but not push.

> How does this interact with vlan
> offloading, etc.?

Not well. I think the solution is to deaccelearate VLANs before
pushing MPLS.

Joe and I have prepared a revised version of the patch which I believe
addresses all the issues that you raise. I will post it shortly.
