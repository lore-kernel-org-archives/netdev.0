From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH v2.50 1/6] ofp-actions: Consider L4 actions
 after mpls_push as inconsistent
Date: Fri, 15 Nov 2013 09:45:30 -0800
Message-ID: <20131115174530.GE18635@nicira.com>
References: <1384506623-18503-1-git-send-email-horms@verge.net.au>
 <1384506623-18503-2-git-send-email-horms@verge.net.au>
 <6A09EE11-CDFA-4E49-AB7F-34746ED4765D@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>, Ravi K <rkerur@gmail.com>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:50755 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751192Ab3KORpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 12:45:36 -0500
Received: by mail-pd0-f172.google.com with SMTP id q10so3761855pdj.3
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 09:45:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6A09EE11-CDFA-4E49-AB7F-34746ED4765D@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Simon, thanks Jarno, applied.

On Fri, Nov 15, 2013 at 08:55:42AM -0800, Jarno Rajahalme wrote:
> Looks good to me,
> 
> Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
> 
> > On Nov 15, 2013, at 1:10 AM, Simon Horman <horms@verge.net.au> wrote:
> > 
> > After an mpls_push action the resulting packet is MPLS and
> > the MPLS payload is opaque. Thus nothing can be assumed
> > about the packets network protocol and it is inconsistent
> > to apply L4 actions.
> > 
> > With regards to actions that affect the packet at other layers
> > of the protocol stack:
> > 
> > * L3: The consistency of L3 actions should already be handled correctly
> >  by virtue of the dl_type of the flow being temporarily altered
> >  during consistency checking by both push_mpls and pop_mpls actions.
> > 
> > * MPLS: The consistency checking of MPLS actions appear to already be
> >  handled correctly.
> > 
> > * VLAN: At this time Open vSwitch on mpls_push an MPLS LSE is always
> >  added after any VLAN tags that follow the ethernet header.
> >  That is the tag ordering defined prior to OpenFlow1.3. As such
> >  VLAN actions should sill be equally valid before and after mpls_push
> >  and mpls_pop actions.
> > 
> > * L2 actions are equally valid before and after mpls_push and mpls_pop actions.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > ---
> > v2.50
> > * Correct typo in comment. nw_protocol -> nw_proto
> > 
> > v2.49
> > * First post
> > ---
> > lib/ofp-actions.c    |  9 ++++++++-
> > tests/ofp-actions.at | 12 ++++++++++++
> > 2 files changed, 20 insertions(+), 1 deletion(-)
> > 
> > diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
> > index abc9505..03ad1a4 100644
> > --- a/lib/ofp-actions.c
> > +++ b/lib/ofp-actions.c
> > @@ -1869,7 +1869,8 @@ ofpact_check_output_port(ofp_port_t port, ofp_port_t max_ports)
> >     }
> > }
> > 
> > -/* May modify flow->dl_type and flow->vlan_tci, caller must restore them.
> > +/* May modify flow->dl_type, flow->nw_proto and flow->vlan_tci,
> > + * caller must restore them.
> >  *
> >  * Modifies some actions, filling in fields that could not be properly set
> >  * without context. */
> > @@ -2056,6 +2057,10 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
> > 
> >     case OFPACT_PUSH_MPLS:
> >         flow->dl_type = ofpact_get_PUSH_MPLS(a)->ethertype;
> > +        /* The packet is now MPLS and the MPLS payload is opaque.
> > +         * Thus nothing can be assumed about the network protocol.
> > +         * Temporarily mark that we have no nw_proto. */
> > +        flow->nw_proto = 0;
> >         return 0;
> > 
> >     case OFPACT_POP_MPLS:
> > @@ -2127,6 +2132,7 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
> >     struct ofpact *a;
> >     ovs_be16 dl_type = flow->dl_type;
> >     ovs_be16 vlan_tci = flow->vlan_tci;
> > +    uint8_t nw_proto = flow->nw_proto;
> >     enum ofperr error = 0;
> > 
> >     OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
> > @@ -2139,6 +2145,7 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
> >     /* Restore fields that may have been modified. */
> >     flow->dl_type = dl_type;
> >     flow->vlan_tci = vlan_tci;
> > +    flow->nw_proto = nw_proto;
> >     return error;
> > }
> > 
> > diff --git a/tests/ofp-actions.at b/tests/ofp-actions.at
> > index cdca8ca..08ebccf 100644
> > --- a/tests/ofp-actions.at
> > +++ b/tests/ofp-actions.at
> > @@ -477,3 +477,15 @@ AT_CHECK(
> >   [ovs-ofctl '-vPATTERN:console:%c|%p|%m' parse-ofp11-instructions < input.txt],
> >   [0], [expout], [experr])
> > AT_CLEANUP
> > +
> > +AT_SETUP([ofp-actions - inconsistent MPLS actions])
> > +OVS_VSWITCHD_START
> > +dnl OK: Use fin_timeout action on TCP flow
> > +AT_CHECK([ovs-ofctl -O OpenFlow11 -vwarn add-flow br0 'tcp actions=fin_timeout(idle_timeout=1)'])
> > +dnl Bad: Use fin_timeout action on TCP flow that has been converted to MPLS
> > +AT_CHECK([ovs-ofctl -O OpenFlow11 -vwarn add-flow br0 'tcp actions=push_mpls:0x8847,fin_timeout(idle_timeout=1)'],
> > +         [1], [], [dnl
> > +ovs-ofctl: actions are invalid with specified match (OFPBAC_MATCH_INCONSISTENT)
> > +])
> > +OVS_VSWITCHD_STOP
> > +AT_CLEANUP
> > -- 
> > 1.8.4
> > 
> > _______________________________________________
> > dev mailing list
> > dev@openvswitch.org
> > http://openvswitch.org/mailman/listinfo/dev
