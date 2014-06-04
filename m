From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.58] datapath: Add basic MPLS support to kernel
Date: Wed, 4 Jun 2014 10:01:18 +0900
Message-ID: <20140604010115.GC22191@verge.net.au>
References: <1401063743-30997-1-git-send-email-horms@verge.net.au>
 <CAEP_g=8Ub64M29TQx82KrFMLcdsAPfKmC8w92d-Ofr9cVhNKFQ@mail.gmail.com>
 <20140603040406.GA22191@verge.net.au>
 <CAEP_g=9mMSwReBQjrm835dSCvLJQW2rgaLUts02YC+7uidTHkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49081 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaFDBBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 21:01:22 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9mMSwReBQjrm835dSCvLJQW2rgaLUts02YC+7uidTHkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2014 at 03:40:27PM -0700, Jesse Gross wrote:
> On Mon, Jun 2, 2014 at 9:04 PM, Simon Horman <horms@verge.net.au> wrote:
> > Hi Jesse,
> >
> > thanks for your feedback.
> >
> > On Mon, Jun 02, 2014 at 05:58:10PM -0700, Jesse Gross wrote:
> >> On Sun, May 25, 2014 at 5:22 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
> >> > index 803a94c..8ce596c 100644
> >> > --- a/datapath/flow_netlink.c
> >> > +++ b/datapath/flow_netlink.c
> >> > +               case OVS_ACTION_ATTR_POP_MPLS:
> >> > +                       if (!eth_p_mpls(eth_type))
> >> > +                               return -EINVAL;
> >>
> >> Should this also take into account the VLAN tag? It's really part of
> >> the EtherType although it has been stripped out here. Actually, maybe
> >> it's better to not track the vlan_tci separately at all during
> >> validation but just fold it into the EtherType.
> >>
> >> The practical implication of this is that you wouldn't be able to pop
> >> out from underneath a VLAN. This may be a good thing if we are trying
> >> to avoid tag order issues - after all, you can't push underneath a
> >> VLAN either. I'm not sure what effects this has on the need to track
> >> mac_len, if any.
> >
> > My thinking is that the ordering problem only surfaces in relation
> > to push MPLS actions where should it go in relation to VLAN tags.
> > For pop actions it seems to me that the outermost tag should be removed
> > regardless of its position in relation to other tags.
> >
> > So I think that the code above is safe. Though now you mention
> > it I do notice that it only allows pop MPLS if there is at most
> > one VLAN tag present.
> >
> > That said, I would not mind particularly disabling pop MPLS in the
> > presence of VLAN tags. At the very least it is related to the
> > painful issue of tag ordering.
> 
> I agree that it is safe but my thought was the it avoids a number of
> potential corner cases such as:
>  * Difference between push and pop underneath vlan tags.
>  * Pop with multiple vlan tags
>  * Differences with varying EtherTypes used for vlans
> 
> > I explored your idea of tracking only eth_type rather than both
> > it and vlan_tci. I did this by adding the following logic to
> > ovs_nla_copy_actions().
> >
> >         if (key->eth.tci & htons(VLAN_TAG_PRESENT))
> >                 eth_type = htons(ETH_P_8021Q);
> >         else
> >                 eth_type = key->eth.type;
> >
> > I then updated the usage of eth_type in ovs_nla_copy_actions__() accordingly.
> > One problem that I have run into is what to do about pop VLAN.
> >
> > I don't believe its possible to know what the new eth type is.
> > This makes subsequent checks of the eth type for validate_set()
> > a little awkward. And seems to indicate that an extra parameter would
> > be needed.
> >
> > For this reason I am inclined to leave the eth_type and vlan_tci
> > parameters in place. In this case there is no problem with pop VLAN
> > as the ether type inside the VLAN tag should be the value of eth_type.
> 
> Can't we populate eth_type with the EtherType from the flow key in
> pop_vlan? This doesn't provide us with the ability to look arbitrarily
> deep into the packet but it should at least retain the functionality
> that we have today.

I think that things are still a bit tricky for at least two reasons.

1. Tracking eth_type if there are more push VLAN actions than pop VLAN actions

   e.g.: A packet with no VLAN tags with the following
         actions applied: push VLAN, push VLAN, pop VLAN

   I believe that with the change your propose eth_type would end up being
   that of the original packet than of the packet with one VLAN tag removed
   after two are added.

   I think would allow a push MPLS action but it should be rejected.

   I think this could be resolved by setting eth_type to a bogus value
   (e.g. 0) but that would may cause subsequent calls to validate_set()
   to fail when they should pass.

2. The use of eth_type in validate_set().

   Suppose we have an IPv6 packet with one VLAN.

   validate_set() allows an IPv6 set operation if the eth_type is IPv6.
   Which would be true if the eth_type is that of the inner rather
   than the outer packet. However, I believe with the scheme
   you are proposing this becomes a bit tricky as the eth_type will
   be that of the outer packet.

   I suppose this particular problem could be resolved using something like
   this in validate_set():

	if (eth_type == htons(ETH_P_8021Q))
		eth_type = flow_key.eth_type;

   But that may get a bit tricky. For example suppose there is
   an IPv6 packet with no VLAN tags and the following actions are applied.

   push MPLS, push VLAN, set IPv6

   validate_set() would be passed:
   eth_type: htons(ETH_P_8021Q)
   flow_key.eth_type: htons(ETH_P_IPV6)

   But validate_set should be checking against an MPLS ethtype.

   I think this particular problem could be resolved with a new
   restriction, prohibiting push VLAN in the presence of MPLS.

My general feeling is that tracking both eth_type and vlan_tci gives
us a richer set of information to work with for various cases the
code handles.

I would like to propose leaving the eth_type and vlan_tci scheme in place
and using something like the following (untested) to address your concern
about pop MPLS.

diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index 8ce596c..bcd05b3 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1571,7 +1571,8 @@ static int ovs_nla_copy_actions__(const struct nlattr *attr,
 		}
 
 		case OVS_ACTION_ATTR_POP_MPLS:
-			if (!eth_p_mpls(eth_type))
+			if (vlan_tci & htons(VLAN_TAG_PRESENT) ||
+			    !eth_p_mpls(eth_type))
 				return -EINVAL;
 
 			/* Disallow subsequent L2.5+ set and mpls_pop actions

> >> Otherwise, I'm happy with this. I think that we need to conclude the
> >> discussion on the other patch and update this appropriately first.
> >
> > Yes, lets get that sorted out.
> >
> > Assuming the other patch is accepted do you want me to increase the
> > coverage of the compatibility code (in this patch) up to whichever version
> > of the kernel the other patch is included in? It seems logical to me but I
> > do not have strong feelings about it.
> 
> Yes, I think that probably makes sense.

Thanks, I'll work on sorting out the other patch and then
update the compatibility code accordingly.
