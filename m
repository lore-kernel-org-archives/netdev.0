From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.51 1/5] ofp-actions: Allow Consistency checking of
 OF1.3+ VLAN actions after mpls_push
Date: Fri, 6 Dec 2013 12:29:24 +0900
Message-ID: <20131206032924.GA20522@verge.net.au>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
 <1385005606-30130-2-git-send-email-horms@verge.net.au>
 <20131204212429.GA11354@nicira.com>
 <20131204235849.GB21448@verge.net.au>
 <20131205004417.GD11354@nicira.com>
 <20131205005139.GA21443@verge.net.au>
 <20131205010111.GE11354@nicira.com>
 <20131205022606.GC21443@verge.net.au>
 <20131205175625.GU30313@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>, Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60111 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab3LFD32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 22:29:28 -0500
Content-Disposition: inline
In-Reply-To: <20131205175625.GU30313@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 09:56:25AM -0800, Ben Pfaff wrote:
> On Thu, Dec 05, 2013 at 11:26:06AM +0900, Simon Horman wrote:
> > On Wed, Dec 04, 2013 at 05:01:11PM -0800, Ben Pfaff wrote:
> > > On Thu, Dec 05, 2013 at 09:51:39AM +0900, Simon Horman wrote:
> > > > On Wed, Dec 04, 2013 at 04:44:17PM -0800, Ben Pfaff wrote:
> > > > > On Thu, Dec 05, 2013 at 08:58:49AM +0900, Simon Horman wrote:
> > > > > > On Wed, Dec 04, 2013 at 01:24:29PM -0800, Ben Pfaff wrote:
> > > > > > > On Thu, Nov 21, 2013 at 12:46:42PM +0900, Simon Horman wrote:
> > > > > > > > The aim of this patch is to support provide infrastructure for verification
> > > > > > > > of VLAN actions after an mpls_push action for OpenFlow1.3. This supplements
> > > > > > > > existing support for verifying these actions for pre-OpenFlow1.3.
> > > > > > > > 
> > > > > > > > In OpenFlow1.1 and 1.2 MPLS tags are pushed after any VLAN tags that
> > > > > > > > immediately follow the ethernet header. This is pre-OpenFlow1.3 tag
> > > > > > > > ordering. Open vSwitch also uses this ordering when supporting MPLS
> > > > > > > > actions via Nicira extensions to OpenFlow1.0.
> > > > > > > > 
> > > > > > > > When using pre-OpenFlow1.3 tag ordering an MPLS push action does not
> > > > > > > > affect the VLANs of a packet. If VLAN tags are present immediately after
> > > > > > > > the ethernet header then they remain present there.
> > > > > > > > 
> > > > > > > > In of OpenFlow1.3+ MPLS LSEs are pushed before any VLAN tags that
> > > > > > > > immediately follow the ethernet header. This is OpenFlow1.3+ tag
> > > > > > > > ordering.
> > > > > > > > 
> > > > > > > > When using OpenFlow1.3+ tag ordering an MPLS push action affects the
> > > > > > > > VLANs of a packet as any VLAN tags previously present after the ethernet
> > > > > > > > header are moved to be immediately after the newly pushed MPLS LSE. Thus
> > > > > > > > for the purpose of action consistency checking a packet may be changed
> > > > > > > > from a VLAN packet to a non-VLAN packet.
> > > > > > > > 
> > > > > > > > In this way the effective value of the VLAN TCI of a packet may differ
> > > > > > > > after an MPLS push depending on the OpenFlow version in use.
> > > > > > > > 
> > > > > > > > This patch does not enable the logic described above.
> > > > > > > > Rather it is disabled in ofpacts_check__(). It should
> > > > > > > > be enabled when support for OpenFlow1.3+ tag order is added
> > > > > > > > and enabled.
> > > > > > > > 
> > > > > > > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > > > > > 
> > > > > > > As far as I can tell this doesn't make sense, because where the MPLS
> > > > > > > tag goes is a property of the action that we know at the time we parse
> > > > > > > the push_mpls action.  So why isn't this patch just the following?
> > > > > > > 
> > > > > > > diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
> > > > > > > index a02f842..f444374 100644
> > > > > > > --- a/lib/ofp-actions.c
> > > > > > > +++ b/lib/ofp-actions.c
> > > > > > > @@ -2071,6 +2071,9 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
> > > > > > >           * Thus nothing can be assumed about the network protocol.
> > > > > > >           * Temporarily mark that we have no nw_proto. */
> > > > > > >          flow->nw_proto = 0;
> > > > > > > +        if (ofpact_get_PUSH_MPLS(a)->position == OFPACT_MPLS_BEFORE_VLAN) {
> > > > > > > +            flow->vlan_tci = 0;
> > > > > > > +        }
> > > > > > >          return 0;
> > > > > > 
> > > > > > That was more or less what I originally tried.  However I believe that it
> > > > > > doesn't work because ofpact_get_PUSH_MPLS(a)->position may not have been
> > > > > > set at the time that ofpact_check__ is called.  In particular this occurs
> > > > > > when it is called indirectly from parse_ofp_str__.
> > > > > > 
> > > > > > Moreover, when ofpact_check__ is called indirectly from parse_ofp_str__ it
> > > > > > is used to check actions when a one of number of protocols may be used,
> > > > > > that is multiple bits of *usable_protocols.  If we could rely on
> > > > > > ofpact_get_PUSH_MPLS(a)->position then I believe that implies that if it is
> > > > > > set to OFPACT_MPLS_BEFORE_VLAN all pre-OpenFlow1.3 bits of
> > > > > > *usable_protocols need to be cleared.  Otherwise all OpenFlow1.3+ bits
> > > > > > would need to be cleared.
> > > > > 
> > > > > I think this might be a mistake in how we define the syntax that
> > > > > parse_ofp_str__() parses.  If I write "actions=push_mpls" on an
> > > > > ovs-ofctl command line, then I want that to have some specific
> > > > > meaning.  I don't want it to mean "do one thing if you happen to
> > > > > negotiate OpenFlow 1.2 or some other thing if you happen to negotiate
> > > > > OpenFlow 1.3", because that's totally unusable and broken from a user
> > > > > perspective.
> > > > 
> > > > To clarify, that is exactly what this series was trying to do.
> > > > 
> > > > I think there is some precedence in the handling of actions
> > > > that set_vlans. Some OF versions implicitly push a tag, some don't.
> > > 
> > > Maybe that is worth fixing too.
> > > 
> > > > But I do agree that the behaviour you describe above would
> > > > be very confusing for users.
> > > > 
> > > > > So if that the issue then I think we should change the
> > > > > syntax.  One way would be to have "push_mpls" default to the 1.3
> > > > > behavior (which seems generally saner) and allow the user to specify
> > > > > an option to get the 1.2 behavior.
> > > > 
> > > > Sure, I think I am happy with that idea.
> > > > 
> > > > By an option do you mean a different action name, for example append_mpls,
> > > > or push_mpls_after_vlan?
> > > 
> > > I was thinking of something like a push_mpls version of the
> > > keyword-based fin_timeout syntax.  One option would be eth_type,
> > > defaulting to ETH_TYPE_MPLS.  Another option would be position, with
> > > after_vlan or before_vlan as allowed values, and probably after_vlan
> > > as the default.
> > > 
> > > With this approach, any flow with a push_mpls could be used only with
> > > pre-OF1.3 or OF1.3+, depending on the "position" value.  One wrinkle
> > > that might be nice, if it isn't too nasty to implement, would be to
> > > have a third value "no_vlan" as the default.  With no_vlan, we reject
> > > the flow at check time if a VLAN is present; if no VLAN is present,
> > > then push_mpls has the same behavior regardless of OpenFlow version.
> > 
> > From an ovs-ofctl point of view I think that makes a lot of sense and I
> > think it should be clean enough to implement. My initial reaction is that
> > using a position argument would be good and I don't see any particular
> > problem with a no_vlan option. But I'll give some thought to an eth_type
> > argument.
> 
> push_mpls currently takes a required eth_type argument.  There are only
> two values and my understanding is that 0x8847 is more common, hence my
> suggestion that it be the default.

I'm not sure that we can use the eth_type argument of an mpls_push action
in order to differentiate between pushing the LSE before or after
any VLAN tags that may be present. There are two acceptable values for the
eth_type argument, 0x8847 and 0x8848. But I believe they are both
equally acceptable regardless of where the LSE is to be pushed
in relation to existing VLAN tags.

> > I would like to clarify how you would like push_mpls to work in the case
> > where flows are received from a controller. It seems to me that the
> > behaviour should depend on the OpenFlow version used by the connection with
> > the controller as we can't change the action to accommodate an extra
> > argument. 
> 
> Right, when push_mpls is received over OpenFlow then it always behaves
> as the particular OpenFlow version specifies.

Thanks, this is clear to me.

> > I think this is also easy enough to implement: actually I am pretty
> > sure think the series currently does that and that the difficulty that
> > this patch tried to address is only on the ovs-ofctl side. Regardless,
> > I wanted to check that is the behaviour that you would like.
> 
> I hope I clarified, let me know if it's still unclear.
> 
