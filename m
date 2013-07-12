From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.34] datapath: Add basic MPLS support to kernel
Date: Fri, 12 Jul 2013 10:55:38 +0900
Message-ID: <20130712015538.GA30897@verge.net.au>
References: <1372234717-8735-1-git-send-email-horms@verge.net.au>
 <CAEP_g=-uMQuwK7=35XG8xrToFDoe8HS8yBK51tSWOipS0FdYtA@mail.gmail.com>
 <20130702041628.GD14567@verge.net.au>
 <CAEP_g=-_Dh=9U8rVrd9XvWdT-MZoKFfY3=i0_h9EWOzPo4u20w@mail.gmail.com>
 <20130703013102.GA21323@verge.net.au>
 <CAEP_g=9bM8-cAC93OOdLVk-ExitCRHP-EjRkO4+Bqzs-Bip00A@mail.gmail.com>
 <20130711001655.GA22153@verge.net.au>
 <CAEP_g=-oDR4h0G-uNum3-Yx7nfwRGedkNOc-AC8tJEH+hqKeDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46134 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932385Ab3GLBzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 21:55:41 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-oDR4h0G-uNum3-Yx7nfwRGedkNOc-AC8tJEH+hqKeDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 06:26:32PM -0700, Jesse Gross wrote:
> On Wed, Jul 10, 2013 at 5:16 PM, Simon Horman <horms@verge.net.au> wr=
ote:
> > On Mon, Jul 08, 2013 at 11:51:18PM -0700, Jesse Gross wrote:
> >> On Tue, Jul 2, 2013 at 6:31 PM, Simon Horman <horms@verge.net.au> =
wrote:
> >> > On Tue, Jul 02, 2013 at 02:59:51PM -0700, Jesse Gross wrote:
> >> >> On Mon, Jul 1, 2013 at 9:16 PM, Simon Horman <horms@verge.net.a=
u> wrote:
> >> >> > On Mon, Jul 01, 2013 at 04:42:46PM -0700, Jesse Gross wrote:
> >> >> >> On Wed, Jun 26, 2013 at 1:18 AM, Simon Horman <horms@verge.n=
et.au> wrote:
> >> >> >> > Allow datapath to recognize and extract MPLS labels into f=
low keys
> >> >> >> > and execute actions which push, pop, and set labels on pac=
kets.
> >> >> >> >
> >> >> >> > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamah=
ata and Joe Stringer.
> >> >> >> >
> >> >> >> > Cc: Ravi K <rkerur@gmail.com>
> >> >> >> > Cc: Leo Alterman <lalterman@nicira.com>
> >> >> >> > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> >> >> >> > Cc: Joe Stringer <joe@wand.net.nz>
> >> >> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >> >> >>
> >> >> >> Simon, have you thought any more about the header ordering i=
ssues? I
> >> >> >> don't think we've reached a conclusion at this point.
> >> >> >
> >> >> > I believe that you then raised the issue of QinQ, which someh=
ow
> >> >> > I failed to respond to, I apologise for that.
> >> >> >
> >> >> > In particular, my understanding is that you are concerned the=
 code will
> >> >> > miss-calculate the end of L2 headers in the presence of multi=
ple VLAN tags.
> >> >> > Thus resulting in an MPLS push action inserting an MPLS LSE a=
fter the first
> >> >> > rather than the last VLAN tag. And that would likely change i=
f QinQ support
> >> >> > was added to Open vSwtich.
> >> >> >
> >> >> > I wonder if a good way forwards is to enhance the calculation
> >> >> > of the end of L2 headers (mac_len) and the beginning of L3 he=
aders
> >> >> > (network_header) in ovs_flow_extract() such that it takes int=
o
> >> >> > account the presence of more than one VLAN tag.
> >> >>
> >> >> The problem is that this requires being able to calculate the l=
ength
> >> >> of all possible headers that we might want to support in the fu=
ture.
> >> >> In the case of QinQ, this would mean the various EtherTypes. Yo=
u could
> >> >> also imagine other things like MAC-in-MAC that are farther afie=
ld from
> >> >> what we currently support.
> >> >
> >> > That is true.
> >> >
> >> > I think that the key problem is it that it is hard for us
> >> > to correctly determine where the end of the L2 header is,
> >> > or more specifically where the MPLS tag should go, for all cases=
=2E
> >> > Particularly cases which are yet to be defined.
> >> >
> >> > Having spoken with Joe about this we see two main options:
> >> >
> >> > 1. The status quo as of this patch. Which is that MPLS actions
> >> >    may be invalid for some cases.
> >> >
> >> >    While it should be be possible to solve individual cases,
> >> >    this doesn't solve the general case.
> >> >
> >> > 2. Only allow MPLS actions on ether types where the implementati=
on
> >> >    is known to work.
> >> >
> >> >    This could act as a white list of sorts. It could start with
> >> >    the obvious candidates: IPv4, IPv6, ARP, 802.1Q,...
> >> >    And support for more protocols could be added in the future.
> >> >
> >> >    This would seem to reflect the somewhat special nature of MPL=
S.
> >>
> >> I think what is really necessary at the kernel level is some
> >> flexibility about where to put the newly inserted MPLS header. The=
n
> >> you could basically chose either of the two options above or expor=
t
> >> the flexibility through OpenFlow (which by my reading of the spec =
is
> >> already supposed to be allowed). Furthermore, you could do differe=
nt
> >> things in different situations as OpenFlow evolves, which really h=
as
> >> to be done at the userspace level since only it has the full set o=
f
> >> knowledge about the protocol.
> >
> > I wonder if this can be achieved by adding a list of features to
> > the MPLS push action, for example as a possibly zero-length array o=
f
> > integers which encode feature bits.
> >
> > At the time that MPLS support is added to the datapath we could def=
ine that
> > all the bits are zero and the behaviour of the code at that time is=
 the
> > expected behaviour.
> >
> > Suppose that a new feature is added in the future.  I will use the =
example
> > of support for 802.1ad (the standardised variant of Q-in-Q).
> >
> > The logic in the datapath to determine the end of the L2 header and=
 thus
> > the top of the MPLS LSE stack could be guarded by a new feature bit=
,
> > the ad-bit.
> >
> > If an MPLS push action, supplied by userspace, has the ad-bit set t=
hen the
> > new logic is used and the MPLS LSE is inserted accordingly.
> > Conversely, if the MPLS push action does not have the bit set then =
the
> > old logic is used and the MPLS LSE is inserted as if the datapath
> > didn't understand 802.1ad.
> >
> > In this way it would be possible for userspace to select the desire=
d
> > behaviour. An old user-space would use the old behaviour. A new use=
rspace
> > may choose the old or the new behaviour.
> >
> > And it would be possible for the datapath to reject facets with MPL=
S
> > push actions with feature bits or combinations of feature bits that
> > are not supported.
>=20
> Hmm, I think that this may become fairly complicated over time as you
> have a number of different types.
>=20
> Going back to the OpenFlow spec:
>=20
> "Newly pushed tags should always be inserted as the outermost tag in
> the outermost valid location for
> that tag. When a new VLAN tag is pushed, it should be the outermost
> tag inserted, immediately after
> the Ethernet header and before other tags. Likewise, when a new MPLS
> tag is pushed, it should be the
> outermost tag inserted, immediately after the Ethernet header and
> before other tags.
>=20
> When multiple push actions are added to the action set of the packet,
> they apply to the packet in the
> order de=EF=AC=81ned by the action set rules, =EF=AC=81rst MPLS, then=
 PBB, than VLAN
> (se 5.10). When multiple push
> actions are included in an action list, they apply to the packet in
> the list order (see 5.11)."
>=20
> This seems about as flexible as anything that I can think of at the
> moment and fairly straightforward: basically we wouldn't need to skip
> over vlan tags at the beginning because we would just push tags in
> front of them. If userspace wants them in the opposite order then it
> can pop off the tags and put them back but I suspect that this is
> actually quite uncommon.

Thanks.

I agree that your proposed scheme should cover all the bases.

In the case of OpenFlow 1.2 I think the spec is fairly clear that the M=
PLS
label stack should follow any VLAN tags. So I now plan to add logic to =
pop
off the VLAN tags and put them on, as you suggest above.

> I know you mentioned before that the valid location for the MPLS labe=
l
> is after the vlan tags but there are several ways to use MPLS and I
> think the last line of the first paragraph is fairly clear.

With that in mind I plan to have userspace use the order that you sugge=
st,
just adding the MPLS as the outer-most tag, in the case of OpenFlow 1.3=
=2E
