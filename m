From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Mon, 04 Sep 2017 13:22:26 +0200
Message-ID: <87mv6abte5.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <20170904023831.GA68062@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev\@openvswitch.org" <dev@openvswitch.org>,
        "jbenc\@redhat.com" <jbenc@redhat.com>, "e\@erig.me" <e@erig.me>,
        "blp\@ovn.org" <blp@ovn.org>,
        "jan.scheurich\@ericsson.com" <jan.scheurich@ericsson.com>
To: "Yang\, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42893 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753410AbdIDLWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 07:22:30 -0400
In-Reply-To: <20170904023831.GA68062@cran64.bj.intel.com> (Yi Yang's message
        of "Mon, 4 Sep 2017 10:38:32 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

"Yang, Yi" <yi.y.yang@intel.com> writes:

> On Wed, Aug 30, 2017 at 05:53:27PM +0800, Hannes Frederic Sowa wrote:
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
>> > +	__be32 context[NSH_MD1_CONTEXT_SIZE];
>> > +};
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
>> What is the reasoning behind it? With mdtype 2 headers this might either
>> not work very well or will increase sw_flow_key size causing slowdowns
>> for all protocols.
>
> For userspace, miniflow can handle such issue, but kernel data path
> didn't provide such mechanism, so I don't think we can think of a better
> way to fix this.

I do think that both, kernel and dpdk dp, are fine if you don't match on
context fields, which I think is the common case.

As soon as a few paths start to match on contexts at different offsets I
am not sure if miniflow will actually help. I don't know enough about
that. Set cover is a NP hard problem, so constructing plain simple flows
will be an approximation somewhere anyway at some point.

If the context values are in some way discrete it might make sense, but
for load balancing purposes your ingress router might fill out one
context field with a flow hash of the inner flow to allow ECMP or
loadbalancing. You might want to treat that separately. Otherwise the
different paths might always need to context[3] & 0x3 (bits as number of
possible next hops) and put that into the flow state. Because every hop
and every path might have different numbers of nexthops etc., I don't
think this is easy unifiable anymore.

> We have to have context headers in flow for match and set, every hop in
> service function chaining can put its metedata into context headers on
> demand, MD type 2 is much more complicated than you can imagine, it is
> impossible to use an uniform way to handle MD type 1 and MD type 2, our
> way is to keep MD type 1 keys in struct ovs_key_nsh and to reuse struct
> flow_tnl for MD type 2 metadata, in case of MD type 2, we can set
> context headers to 0 in struct ovs_key_nsh.

Understood and agreed.

> I beleive every newly-added key will result in similiar issue you
> concern, maybe it will be better to introduce miniflow in kernel data
> path, but it isn't in scope of this patch series.

You will see the same problem with offloading flows e.g. to network
cards very soon. Flow explosion here will cause your 100Gbit/s NIC
suddenly to go to software slow path.

> It will be great if you can have a better proposal to fix your concern.

I do think that something alike miniflow might make sense, but I don't
know enough about miniflow.

New ACTIONS, that are not only bound to NSH, seem appealing to me at the
moment. E.g. have a subtable match in the kernel dp or allowing for some
OXM % modulo -> select action or neighbor alike thing would probably
cover a lot of cases in the beginning. The submatch would probably very
much reassemble the miniflow in dpdk dp.

Thanks,
Hannes
