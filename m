From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Wed, 30 Aug 2017 17:15:45 +0200
Message-ID: <87inh56q8u.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Yang\, Yi Y" <yi.y.yang@intel.com>,
        "dev\@openvswitch.org" <dev@openvswitch.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "jbenc\@redhat.com" <jbenc@redhat.com>, "e\@erig.me" <e@erig.me>
To: "Mooney\, Sean K" <sean.k.mooney@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33757 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751317AbdH3PPv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 11:15:51 -0400
In-Reply-To: <4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
        (Sean K. Mooney's message of "Wed, 30 Aug 2017 11:36:17 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Mooney, Sean K" <sean.k.mooney@intel.com> writes:

>> -----Original Message-----
>> From: ovs-dev-bounces@openvswitch.org [mailto:ovs-dev-
>> bounces@openvswitch.org] On Behalf Of Hannes Frederic Sowa
>> Sent: Wednesday, August 30, 2017 10:53 AM
>> To: Yang, Yi Y <yi.y.yang@intel.com>
>> Cc: dev@openvswitch.org; netdev@vger.kernel.org; jbenc@redhat.com;
>> e@erig.me
>> Subject: Re: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable NSH
>> support
>> 
>> Hello,
>> 
>> Yi Yang <yi.y.yang@intel.com> writes:
>> 
>> [...]
>> 
>> > +struct ovs_key_nsh {
>> > +	u8 flags;
>> > +	u8 ttl;
>> > +	u8 mdtype;
>> > +	u8 np;
>> > +	__be32 path_hdr;
>> > +	__be32 context[NSH_MD1_CONTEXT_SIZE]; };
>> > +
>> >  struct sw_flow_key {
>> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
>> >  	u8 tun_opts_len;
>> > @@ -144,6 +154,7 @@ struct sw_flow_key {
>> >  			};
>> >  		} ipv6;
>> >  	};
>> > +	struct ovs_key_nsh nsh;         /* network service header */
>> >  	struct {
>> >  		/* Connection tracking fields not packed above. */
>> >  		struct {
>> 
>> Does it makes sense to keep the context headers as part of the flow?
>> What is the reasoning behind it? With mdtype 2 headers this might
>> either not work very well or will increase sw_flow_key size causing
>> slowdowns for all protocols.
> [Mooney, Sean K]
> Having the nsh context headers in the flow is quite useful It would
> allow loadblancing on values stored in the context headers Or other
> use. I belive odl previously used context header 4 to store a Flow id
> so this could potentialy be used with the multipath action to have ovs
> Choose between several possible next hops in the chain.

In OVS, masks are a list(!) for matching. How can this work for
different paths that might require different masks? If they can't be
unified you even get exact matches. Thus, for OVS the context should not
be part of the flow.

> Another example of where this is usefull is branching chains.  if I
> assume that both the classifier and Service function forwarder are
> collocated in ovs on the host, and is send A packet to a firewall
> service function which tags the packet as suspicious Via setting a
> context header metadata field to 1, I as the sdn controller can
> Install a high priority rule that will reclassify the packet as part
> of as separate Service function chain the will prefer dpi on the
> packet before returning it to The original chain if demand not a
> threat.

You can do that with different path id's, too?

> So while a sff dose not in general have to be able to match on the
> context header If I assume I want to use ovs to implenet a classifier
> or service function(e.g. loadblancer) The its desirable to be able to
> both match on the context headers in md type1 and also be able To set
> them(this is something classifies and service fuction are allowed to
> do).

I don't think it is practical at all?
