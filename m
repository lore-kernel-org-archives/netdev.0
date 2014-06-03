From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.58] datapath: Add basic MPLS support to kernel
Date: Tue, 3 Jun 2014 13:04:08 +0900
Message-ID: <20140603040406.GA22191@verge.net.au>
References: <1401063743-30997-1-git-send-email-horms@verge.net.au>
 <CAEP_g=8Ub64M29TQx82KrFMLcdsAPfKmC8w92d-Ofr9cVhNKFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60414 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaFCEEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:04:12 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8Ub64M29TQx82KrFMLcdsAPfKmC8w92d-Ofr9cVhNKFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

thanks for your feedback.

On Mon, Jun 02, 2014 at 05:58:10PM -0700, Jesse Gross wrote:
> On Sun, May 25, 2014 at 5:22 PM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
> > index 803a94c..8ce596c 100644
> > --- a/datapath/flow_netlink.c
> > +++ b/datapath/flow_netlink.c
> > +               case OVS_ACTION_ATTR_POP_MPLS:
> > +                       if (!eth_p_mpls(eth_type))
> > +                               return -EINVAL;
> 
> Should this also take into account the VLAN tag? It's really part of
> the EtherType although it has been stripped out here. Actually, maybe
> it's better to not track the vlan_tci separately at all during
> validation but just fold it into the EtherType.
> 
> The practical implication of this is that you wouldn't be able to pop
> out from underneath a VLAN. This may be a good thing if we are trying
> to avoid tag order issues - after all, you can't push underneath a
> VLAN either. I'm not sure what effects this has on the need to track
> mac_len, if any.

My thinking is that the ordering problem only surfaces in relation
to push MPLS actions where should it go in relation to VLAN tags.
For pop actions it seems to me that the outermost tag should be removed
regardless of its position in relation to other tags.

So I think that the code above is safe. Though now you mention
it I do notice that it only allows pop MPLS if there is at most
one VLAN tag present.

That said, I would not mind particularly disabling pop MPLS in the
presence of VLAN tags. At the very least it is related to the
painful issue of tag ordering.


I explored your idea of tracking only eth_type rather than both
it and vlan_tci. I did this by adding the following logic to
ovs_nla_copy_actions().

	if (key->eth.tci & htons(VLAN_TAG_PRESENT))
		eth_type = htons(ETH_P_8021Q);
	else
		eth_type = key->eth.type;

I then updated the usage of eth_type in ovs_nla_copy_actions__() accordingly.
One problem that I have run into is what to do about pop VLAN.

I don't believe its possible to know what the new eth type is.
This makes subsequent checks of the eth type for validate_set()
a little awkward. And seems to indicate that an extra parameter would
be needed.

For this reason I am inclined to leave the eth_type and vlan_tci
parameters in place. In this case there is no problem with pop VLAN
as the ether type inside the VLAN tag should be the value of eth_type.


> Otherwise, I'm happy with this. I think that we need to conclude the
> discussion on the other patch and update this appropriately first.

Yes, lets get that sorted out.

Assuming the other patch is accepted do you want me to increase the
coverage of the compatibility code (in this patch) up to whichever version
of the kernel the other patch is included in? It seems logical to me but I
do not have strong feelings about it.
