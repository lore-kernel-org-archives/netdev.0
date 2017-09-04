From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 11:57:37 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E2C@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <20170904023831.GA68062@cran64.bj.intel.com>
 <87mv6abte5.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>, "e@erig.me" <e@erig.me>,
        "blp@ovn.org" <blp@ovn.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:44028 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753455AbdIDL5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 07:57:40 -0400
In-Reply-To: <87mv6abte5.fsf@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Does it makes sense to keep the context headers as part of the flow?
> >> What is the reasoning behind it? With mdtype 2 headers this might either
> >> not work very well or will increase sw_flow_key size causing slowdowns
> >> for all protocols.
> >
> > For userspace, miniflow can handle such issue, but kernel data path
> > didn't provide such mechanism, so I don't think we can think of a better
> > way to fix this.
> 
> I do think that both, kernel and dpdk dp, are fine if you don't match on
> context fields, which I think is the common case.

Agree

> As soon as a few paths start to match on contexts at different offsets I
> am not sure if miniflow will actually help. I don't know enough about
> that. Set cover is a NP hard problem, so constructing plain simple flows
> will be an approximation somewhere anyway at some point.
> 
> If the context values are in some way discrete it might make sense, but
> for load balancing purposes your ingress router might fill out one
> context field with a flow hash of the inner flow to allow ECMP or
> loadbalancing. You might want to treat that separately. Otherwise the
> different paths might always need to context[3] & 0x3 (bits as number of
> possible next hops) and put that into the flow state. Because every hop
> and every path might have different numbers of nexthops etc., I don't
> think this is easy unifiable anymore.

Yes, that would become a scaling challenge for the datapaths and also for 
schemes to off-load that datapath to HW. I believe it requires discipline
on the controller side to not let the number of needed masks explode for
OVS.

> > I believe every newly-added key will result in similiar issue you
> > concern, maybe it will be better to introduce miniflow in kernel data
> > path, but it isn't in scope of this patch series.
> 
> You will see the same problem with offloading flows e.g. to network
> cards very soon. Flow explosion here will cause your 100Gbit/s NIC
> suddenly to go to software slow path.
> 
> > It will be great if you can have a better proposal to fix your concern.
> 
> I do think that something alike miniflow might make sense, but I don't
> know enough about miniflow.

Struct miniflow in the netdev datapath is merely a compact representation
of struct flow. struct flow is partitioned in to 64-bit "stripes" and struct
miniflow only stores those 64-bit bit stripes that have a non-zero mask stripe.
It reduces the memory footprint for storing packet flow and megaflow entries
but does not provide any megaflow lookup performance as such.

> New ACTIONS, that are not only bound to NSH, seem appealing to me at the
> moment. E.g. have a subtable match in the kernel dp or allowing for some
> OXM % modulo -> select action or neighbor alike thing would probably
> cover a lot of cases in the beginning. The submatch would probably very
> much reassemble the miniflow in dpdk dp.

I would like to discuss your ideas to optimize scalable load-sharing in OVS.
But I think we should do that in a separate mail thread to let the immediate
NSH kernel datapath work proceed. 

Can you  provide some more details of what you suggest? Perhaps take that 
on the ovs-dev mailing list.

BR, Jan
