From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.51 1/5] ofp-actions: Allow Consistency checking of
 OF1.3+ VLAN actions after mpls_push
Date: Wed, 4 Dec 2013 16:44:17 -0800
Message-ID: <20131205004417.GD11354@nicira.com>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
 <1385005606-30130-2-git-send-email-horms@verge.net.au>
 <20131204212429.GA11354@nicira.com>
 <20131204235849.GB21448@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>, Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:45205 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756000Ab3LEAo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 19:44:27 -0500
Received: by mail-qc0-f175.google.com with SMTP id e9so4162873qcy.6
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 16:44:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131204235849.GB21448@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 08:58:49AM +0900, Simon Horman wrote:
> On Wed, Dec 04, 2013 at 01:24:29PM -0800, Ben Pfaff wrote:
> > On Thu, Nov 21, 2013 at 12:46:42PM +0900, Simon Horman wrote:
> > > The aim of this patch is to support provide infrastructure for verification
> > > of VLAN actions after an mpls_push action for OpenFlow1.3. This supplements
> > > existing support for verifying these actions for pre-OpenFlow1.3.
> > > 
> > > In OpenFlow1.1 and 1.2 MPLS tags are pushed after any VLAN tags that
> > > immediately follow the ethernet header. This is pre-OpenFlow1.3 tag
> > > ordering. Open vSwitch also uses this ordering when supporting MPLS
> > > actions via Nicira extensions to OpenFlow1.0.
> > > 
> > > When using pre-OpenFlow1.3 tag ordering an MPLS push action does not
> > > affect the VLANs of a packet. If VLAN tags are present immediately after
> > > the ethernet header then they remain present there.
> > > 
> > > In of OpenFlow1.3+ MPLS LSEs are pushed before any VLAN tags that
> > > immediately follow the ethernet header. This is OpenFlow1.3+ tag
> > > ordering.
> > > 
> > > When using OpenFlow1.3+ tag ordering an MPLS push action affects the
> > > VLANs of a packet as any VLAN tags previously present after the ethernet
> > > header are moved to be immediately after the newly pushed MPLS LSE. Thus
> > > for the purpose of action consistency checking a packet may be changed
> > > from a VLAN packet to a non-VLAN packet.
> > > 
> > > In this way the effective value of the VLAN TCI of a packet may differ
> > > after an MPLS push depending on the OpenFlow version in use.
> > > 
> > > This patch does not enable the logic described above.
> > > Rather it is disabled in ofpacts_check__(). It should
> > > be enabled when support for OpenFlow1.3+ tag order is added
> > > and enabled.
> > > 
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > As far as I can tell this doesn't make sense, because where the MPLS
> > tag goes is a property of the action that we know at the time we parse
> > the push_mpls action.  So why isn't this patch just the following?
> > 
> > diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
> > index a02f842..f444374 100644
> > --- a/lib/ofp-actions.c
> > +++ b/lib/ofp-actions.c
> > @@ -2071,6 +2071,9 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
> >           * Thus nothing can be assumed about the network protocol.
> >           * Temporarily mark that we have no nw_proto. */
> >          flow->nw_proto = 0;
> > +        if (ofpact_get_PUSH_MPLS(a)->position == OFPACT_MPLS_BEFORE_VLAN) {
> > +            flow->vlan_tci = 0;
> > +        }
> >          return 0;
> 
> That was more or less what I originally tried.  However I believe that it
> doesn't work because ofpact_get_PUSH_MPLS(a)->position may not have been
> set at the time that ofpact_check__ is called.  In particular this occurs
> when it is called indirectly from parse_ofp_str__.
> 
> Moreover, when ofpact_check__ is called indirectly from parse_ofp_str__ it
> is used to check actions when a one of number of protocols may be used,
> that is multiple bits of *usable_protocols.  If we could rely on
> ofpact_get_PUSH_MPLS(a)->position then I believe that implies that if it is
> set to OFPACT_MPLS_BEFORE_VLAN all pre-OpenFlow1.3 bits of
> *usable_protocols need to be cleared.  Otherwise all OpenFlow1.3+ bits
> would need to be cleared.

I think this might be a mistake in how we define the syntax that
parse_ofp_str__() parses.  If I write "actions=push_mpls" on an
ovs-ofctl command line, then I want that to have some specific
meaning.  I don't want it to mean "do one thing if you happen to
negotiate OpenFlow 1.2 or some other thing if you happen to negotiate
OpenFlow 1.3", because that's totally unusable and broken from a user
perspective.  So if that the issue then I think we should change the
syntax.  One way would be to have "push_mpls" default to the 1.3
behavior (which seems generally saner) and allow the user to specify
an option to get the 1.2 behavior.
