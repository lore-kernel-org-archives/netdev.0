From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.34] datapath: Add basic MPLS support to kernel
Date: Thu, 11 Jul 2013 09:16:58 +0900
Message-ID: <20130711001655.GA22153@verge.net.au>
References: <1372234717-8735-1-git-send-email-horms@verge.net.au>
 <CAEP_g=-uMQuwK7=35XG8xrToFDoe8HS8yBK51tSWOipS0FdYtA@mail.gmail.com>
 <20130702041628.GD14567@verge.net.au>
 <CAEP_g=-_Dh=9U8rVrd9XvWdT-MZoKFfY3=i0_h9EWOzPo4u20w@mail.gmail.com>
 <20130703013102.GA21323@verge.net.au>
 <CAEP_g=9bM8-cAC93OOdLVk-ExitCRHP-EjRkO4+Bqzs-Bip00A@mail.gmail.com>
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
Received: from kirsty.vergenet.net ([202.4.237.240]:60346 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab3GKARC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:17:02 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9bM8-cAC93OOdLVk-ExitCRHP-EjRkO4+Bqzs-Bip00A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 08, 2013 at 11:51:18PM -0700, Jesse Gross wrote:
> On Tue, Jul 2, 2013 at 6:31 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Jul 02, 2013 at 02:59:51PM -0700, Jesse Gross wrote:
> >> On Mon, Jul 1, 2013 at 9:16 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > On Mon, Jul 01, 2013 at 04:42:46PM -0700, Jesse Gross wrote:
> >> >> On Wed, Jun 26, 2013 at 1:18 AM, Simon Horman <horms@verge.net.au> wrote:
> >> >> > Allow datapath to recognize and extract MPLS labels into flow keys
> >> >> > and execute actions which push, pop, and set labels on packets.
> >> >> >
> >> >> > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >> >> >
> >> >> > Cc: Ravi K <rkerur@gmail.com>
> >> >> > Cc: Leo Alterman <lalterman@nicira.com>
> >> >> > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> >> >> > Cc: Joe Stringer <joe@wand.net.nz>
> >> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >> >>
> >> >> Simon, have you thought any more about the header ordering issues? I
> >> >> don't think we've reached a conclusion at this point.
> >> >
> >> > I believe that you then raised the issue of QinQ, which somehow
> >> > I failed to respond to, I apologise for that.
> >> >
> >> > In particular, my understanding is that you are concerned the code will
> >> > miss-calculate the end of L2 headers in the presence of multiple VLAN tags.
> >> > Thus resulting in an MPLS push action inserting an MPLS LSE after the first
> >> > rather than the last VLAN tag. And that would likely change if QinQ support
> >> > was added to Open vSwtich.
> >> >
> >> > I wonder if a good way forwards is to enhance the calculation
> >> > of the end of L2 headers (mac_len) and the beginning of L3 headers
> >> > (network_header) in ovs_flow_extract() such that it takes into
> >> > account the presence of more than one VLAN tag.
> >>
> >> The problem is that this requires being able to calculate the length
> >> of all possible headers that we might want to support in the future.
> >> In the case of QinQ, this would mean the various EtherTypes. You could
> >> also imagine other things like MAC-in-MAC that are farther afield from
> >> what we currently support.
> >
> > That is true.
> >
> > I think that the key problem is it that it is hard for us
> > to correctly determine where the end of the L2 header is,
> > or more specifically where the MPLS tag should go, for all cases.
> > Particularly cases which are yet to be defined.
> >
> > Having spoken with Joe about this we see two main options:
> >
> > 1. The status quo as of this patch. Which is that MPLS actions
> >    may be invalid for some cases.
> >
> >    While it should be be possible to solve individual cases,
> >    this doesn't solve the general case.
> >
> > 2. Only allow MPLS actions on ether types where the implementation
> >    is known to work.
> >
> >    This could act as a white list of sorts. It could start with
> >    the obvious candidates: IPv4, IPv6, ARP, 802.1Q,...
> >    And support for more protocols could be added in the future.
> >
> >    This would seem to reflect the somewhat special nature of MPLS.
> 
> I think what is really necessary at the kernel level is some
> flexibility about where to put the newly inserted MPLS header. Then
> you could basically chose either of the two options above or export
> the flexibility through OpenFlow (which by my reading of the spec is
> already supposed to be allowed). Furthermore, you could do different
> things in different situations as OpenFlow evolves, which really has
> to be done at the userspace level since only it has the full set of
> knowledge about the protocol.

I wonder if this can be achieved by adding a list of features to
the MPLS push action, for example as a possibly zero-length array of
integers which encode feature bits.

At the time that MPLS support is added to the datapath we could define that
all the bits are zero and the behaviour of the code at that time is the
expected behaviour.

Suppose that a new feature is added in the future.  I will use the example
of support for 802.1ad (the standardised variant of Q-in-Q).

The logic in the datapath to determine the end of the L2 header and thus
the top of the MPLS LSE stack could be guarded by a new feature bit,
the ad-bit.

If an MPLS push action, supplied by userspace, has the ad-bit set then the
new logic is used and the MPLS LSE is inserted accordingly.
Conversely, if the MPLS push action does not have the bit set then the
old logic is used and the MPLS LSE is inserted as if the datapath
didn't understand 802.1ad.

In this way it would be possible for userspace to select the desired
behaviour. An old user-space would use the old behaviour. A new userspace
may choose the old or the new behaviour.

And it would be possible for the datapath to reject facets with MPLS
push actions with feature bits or combinations of feature bits that
are not supported.
