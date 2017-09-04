From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable NSH
        support
Date: Mon, 4 Sep 2017 09:38:41 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4CB0@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
        <87inh56q8u.fsf@stressinduktion.org>
        <4B1BB321037C0849AAE171801564DFA6888FB254@IRSMSX107.ger.corp.intel.com>
 <87d17boqb1.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "jbenc@redhat.com" <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Mooney, Sean K" <sean.k.mooney@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:46711 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753364AbdIDJjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 05:39:00 -0400
In-Reply-To: <87d17boqb1.fsf@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> >> Does it makes sense to keep the context headers as part of the flow?
> >> >> What is the reasoning behind it? With mdtype 2 headers this might
> >> >> either not work very well or will increase sw_flow_key size causing
> >> >> slowdowns for all protocols.
> >> > [Mooney, Sean K]
> >> > Having the nsh context headers in the flow is quite useful It would
> >> > allow loadblancing on values stored in the context headers Or other
> >> > use. I belive odl previously used context header 4 to store a Flow id
> >> > so this could potentialy be used with the multipath action to have
> >> ovs
> >> > Choose between several possible next hops in the chain.
> >>
> >> In OVS, masks are a list(!) for matching. How can this work for
> >> different paths that might require different masks? If they can't be
> >> unified you even get exact matches. Thus, for OVS the context should
> >> not be part of the flow.
> 
> > [Mooney, Sean K] I'm not sure what you mean about a list as I never
> > made reference to one.  md type 1 context headers are 4 mandatory 32
> > bit field.
> 
> The semantic of the context fields depend on the path id. Every path can
> have their own interpretation of context fields.
> 
> Thus the paths will cetainly have their own masks. I hope I understood
> this part of the standard correctly.
> 
> dp only supports installing (approximated) disjoint megaflows and this
> affects performance a lot. Every new mask that gets added to the dp will
> be installed into a list which will be walked sequentially for
> packets. This will kill performance.
> 
> I assume that user space slows down, too, depending on the algorithm
> they use generate megaflows.

The primary use case for OVS in SFC/NSH is SFF. In almost all SFF use 
cases OVS will not need to match on context headers. The ability of OVS
to match on context headers should not in general slow down the datapath.

When SFC controllers match on parts of the context headers (e.g. in the 
final SFF or for load-balancing purposes), we will get additional megaflow 
masks. This is a fact of life in OVS and nothing new in NSH. I don't think
this should prevent us from supporting valid use cases in OVS.

The slow-down of the megaflow lookup in the datapath with the number 
of masks has been addressed in the user-space datapath with sorting the
mask lists according to hit frequency and maintaining one sorted lists per 
ingress port. There is further work in progress to improve on this with a
cuckoo hash to pick the most likely mask first.
It should be possible to apply similar optimization schemes also in the
Kernel datapath.

> > form an ovs context they should be treated the same as the 32 bit register fields.
> > We do not need to necessarily support those in md type 2 as all metadata is optional.

Support for matching on or updating MD2 TLV context headers is FFS in a
future OVS release. We do not foresee to add MD2 TLVs explicitly to the 
flow struct.

> > You can also see that context header 1 and 2 are still used in the newer odl netvirt sfc classifier implementation
> > https://github.com/opendaylight/netvirt/blob/ba22f7cf19d8a827d77a3391a7f654344ade43d8/docs/specs/new-sfc-
> classifier.rst#pipeline-changes
> > so for odl existing nsh support to work with md type one we must have the ability to set the nsh context headers
> > and should have the ability to match on them also for load lancing between service function in service function group.
> 
> As I said, a separate action sounds much more useful.

I don't think it is a good approach in OVS to introduce custom actions for NSH, e.g. for load sharing based on context header data. The primary tool for load sharing in OpenFlow is the Select Group. OVS already support an extension to the OF 1.5 Group Mod message to specify which fields to hash on. This can be used to hash on the relevant NSH context headers.

BR, Jan
