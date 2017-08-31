From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Thu, 31 Aug 2017 14:49:22 +0200
Message-ID: <87d17boqb1.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
        <87inh56q8u.fsf@stressinduktion.org>
        <4B1BB321037C0849AAE171801564DFA6888FB254@IRSMSX107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Yang\, Yi Y" <yi.y.yang@intel.com>,
        "dev\@openvswitch.org" <dev@openvswitch.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "jbenc\@redhat.com" <jbenc@redhat.com>, "e\@erig.me" <e@erig.me>
To: "Mooney\, Sean K" <sean.k.mooney@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52813 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751001AbdHaMtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 08:49:25 -0400
In-Reply-To: <4B1BB321037C0849AAE171801564DFA6888FB254@IRSMSX107.ger.corp.intel.com>
        (Sean K. Mooney's message of "Wed, 30 Aug 2017 19:00:44 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

"Mooney, Sean K" <sean.k.mooney@intel.com> writes:


[...]

>> >> > +struct ovs_key_nsh {
>> >> > +	u8 flags;
>> >> > +	u8 ttl;
>> >> > +	u8 mdtype;
>> >> > +	u8 np;
>> >> > +	__be32 path_hdr;
>> >> > +	__be32 context[NSH_MD1_CONTEXT_SIZE]; };
>> >> > +
>> >> >  struct sw_flow_key {
>> >> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
>> >> >  	u8 tun_opts_len;
>> >> > @@ -144,6 +154,7 @@ struct sw_flow_key {
>> >> >  			};
>> >> >  		} ipv6;
>> >> >  	};
>> >> > +	struct ovs_key_nsh nsh;         /* network service header */
>> >> >  	struct {
>> >> >  		/* Connection tracking fields not packed above. */
>> >> >  		struct {
>> >>
>> >> Does it makes sense to keep the context headers as part of the flow?
>> >> What is the reasoning behind it? With mdtype 2 headers this might
>> >> either not work very well or will increase sw_flow_key size causing
>> >> slowdowns for all protocols.
>> > [Mooney, Sean K]
>> > Having the nsh context headers in the flow is quite useful It would
>> > allow loadblancing on values stored in the context headers Or other
>> > use. I belive odl previously used context header 4 to store a Flow id
>> > so this could potentialy be used with the multipath action to have
>> ovs
>> > Choose between several possible next hops in the chain.
>> 
>> In OVS, masks are a list(!) for matching. How can this work for
>> different paths that might require different masks? If they can't be
>> unified you even get exact matches. Thus, for OVS the context should
>> not be part of the flow.

> [Mooney, Sean K] I'm not sure what you mean about a list as I never
> made reference to one.  md type 1 context headers are 4 mandatory 32
> bit field.

The semantic of the context fields depend on the path id. Every path can
have their own interpretation of context fields.

Thus the paths will cetainly have their own masks. I hope I understood
this part of the standard correctly.

dp only supports installing (approximated) disjoint megaflows and this
affects performance a lot. Every new mask that gets added to the dp will
be installed into a list which will be walked sequentially for
packets. This will kill performance.

I assume that user space slows down, too, depending on the algorithm
they use generate megaflows.

All in all, this stuff sounds extremely fragile to me. E.g. imagine you
configure a new match on your context and suddenly you start to generate
exact match flows, they can't be offloaded anymore at more than 10Gbp/s,
I don't think the network survives this event at all.

> form an ovs context they should be treated the same as the 32 bit register fields.
> We do not need to necessarily support those in md type 2 as all metadata is optional.
>> 
>> > Another example of where this is usefull is branching chains.  if I
>> > assume that both the classifier and Service function forwarder are
>> > collocated in ovs on the host, and is send A packet to a firewall
>> > service function which tags the packet as suspicious Via setting a
>> > context header metadata field to 1, I as the sdn controller can
>> > Install a high priority rule that will reclassify the packet as part
>> > of as separate Service function chain the will prefer dpi on the
>> > packet before returning it to The original chain if demand not a
>> > threat.
>> 
>> You can do that with different path id's, too?
> [Mooney, Sean K] a service function is not allowed to alter the spi.
> Only a classifier can do that. You are correct that a different spi is required for the branch
> To the dpi sf but packets that are not droped can rejoin the original spi.
> Packet are not require you to enter a service chain at the first hop.
>
> service function chain are explicitly not A list. They are a directed graph composed
> of service function instance or service function groups that generally 
> are reducible to a directed acrylic graph and in the simple case to a simple list. 
> branching an recovering chains are expected, as is loadblancing between 
> service function instances in the same service function group which share the same spi. 
> The spi filed in the nsh heard is intended to transport the logical service plane path id
> not the rendered service path id.

Use an explicit action with a parameter to multiplex on a context
header, no problem with that.

>> 
>> > So while a sff dose not in general have to be able to match on the
>> > context header If I assume I want to use ovs to implenet a classifier
>> > or service function(e.g. loadblancer) The its desirable to be able to
>> > both match on the context headers in md type1 and also be able To set
>> > them(this is something classifies and service fuction are allowed to
>> > do).
>> 
>> I don't think it is practical at all?
> [Mooney, Sean K] To day in OpenStack we co-locate the clarifier at every
> Ovs instance and use mpls as a standing for nsh doing proxing at every hop before sending
> To an sf. Flow based load balancing is not only practical but has been demonstrated to work with odl gbp classifier
> and sfc application controlling a patched ovs with nsh support in 2015. 

Define an action to do so.

> If you look at slide 36 of http://events.linuxfoundation.org/sites/events/files/slides/odl%20summit%20sfc%20v5.pdf
> you will see that prior to the berilium release of odl context header 1 and 2 are used to allow multi-tenancy
> and overlapping ips. For the loadblancing implentaiton I belived they also used context header 4 to store a flow id.
> This require odl to generate openflow rules to set the context headers
> as part of classification.

Okay.

> You can also see that context header 1 and 2 are still used in the newer odl netvirt sfc classifier implementation
> https://github.com/opendaylight/netvirt/blob/ba22f7cf19d8a827d77a3391a7f654344ade43d8/docs/specs/new-sfc-classifier.rst#pipeline-changes
> so for odl existing nsh support to work with md type one we must have the ability to set the nsh context headers
> and should have the ability to match on them also for load lancing between service function in service function group.

As I said, a separate action sounds much more useful.

Bye,
Hannes
