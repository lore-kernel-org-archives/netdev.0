From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Tue, 06 Jan 2015 21:37:58 -0800
Message-ID: <54ACC636.30704@gmail.com>
References: <CAADnVQJ6MWVCPsBX6oZpQq=D=4iO7zE5rV8N1Vw5WHxDFGZ7xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:49834 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbAGFiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 00:38:16 -0500
Received: by mail-oi0-f43.google.com with SMTP id i138so1553223oig.2
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 21:38:15 -0800 (PST)
In-Reply-To: <CAADnVQJ6MWVCPsBX6oZpQq=D=4iO7zE5rV8N1Vw5WHxDFGZ7xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2015 05:14 PM, Alexei Starovoitov wrote:
> On Wed, Dec 31, 2014 at 11:45 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> + * [NET_FLOW_TABLE_IDENTIFIER_TYPE]
>> + * [NET_FLOW_TABLE_IDENTIFIER]
>> + * [NET_FLOW_TABLE_TABLES]
>> + *     [NET_FLOW_TABLE]
>> + *       [NET_FLOW_TABLE_ATTR_NAME]
>> + *       [NET_FLOW_TABLE_ATTR_UID]
>> + *       [NET_FLOW_TABLE_ATTR_SOURCE]
>> + *       [NET_FLOW_TABLE_ATTR_SIZE]
> ...
>> + * Header definitions used to define headers with user friendly
>> + * names.
>> + *
>> + * [NET_FLOW_TABLE_HEADERS]
>> + *   [NET_FLOW_HEADER]
>> + *     [NET_FLOW_HEADER_ATTR_NAME]
>> + *     [NET_FLOW_HEADER_ATTR_UID]
>> + *     [NET_FLOW_HEADER_ATTR_FIELDS]
>> + *       [NET_FLOW_HEADER_ATTR_FIELD]
>> + *         [NET_FLOW_FIELD_ATTR_NAME]
>> + *         [NET_FLOW_FIELD_ATTR_UID]
>> + *         [NET_FLOW_FIELD_ATTR_BITWIDTH]
>> + *       [NET_FLOW_HEADER_ATTR_FIELD]
>> + *         [...]
>> + *       [...]
>> + * Action definitions supported by tables
>> + *
>> + * [NET_FLOW_TABLE_ACTIONS]
>> + *   [NET_FLOW_TABLE_ATTR_ACTIONS]
>> + *     [NET_FLOW_ACTION]
>> + *       [NET_FLOW_ACTION_ATTR_NAME]
>> + *       [NET_FLOW_ACTION_ATTR_UID]
>> + *       [NET_FLOW_ACTION_ATTR_SIGNATURE]
>> + *              [NET_FLOW_ACTION_ARG]
> ..
>> + * Get Table Graph <Reply> description
>> + *
>> + * [NET_FLOW_TABLE_TABLE_GRAPH]
>> + *   [TABLE_GRAPH_NODE]
>> + *     [TABLE_GRAPH_NODE_UID]
>> + *     [TABLE_GRAPH_NODE_JUMP]
>
> I think NET_FLOW prefix everywhere is too verbose.
> Especially since you've missed it in the above 3.
> and in patch 2 it is:
> NET_FLOW_FLOW
> which is kinda awkward.
> Can you abbreviate it to NFL_ or something else ?

hmm I'm open for a better name, NFL_ might work but seems
a bit cryptic to me. Maybe it is better than NET_FLOW.
Anyone other suggestions?

>
> I couldn't find get_headers() and get_header_graph()
> implementation on rocker side ?

It is in patch

[net-next PATCH v1 04/11] rocker: add pipeline model for rocker switch

+#ifdef CONFIG_NET_FLOW_TABLES
+	.ndo_flow_get_tables		= rocker_get_tables,
+	.ndo_flow_get_headers		= rocker_get_headers,
+	.ndo_flow_get_actions		= rocker_get_actions,
+	.ndo_flow_get_tbl_graph		= rocker_get_tgraph,
+	.ndo_flow_get_hdr_graph		= rocker_get_hgraph,
+#endif

although v2 will address some good feedback and clean it up a bit.


> Could you describe how put_header_graph() will look like?

The signature for get_hdrs and get_hdrs_graph in my latest deck
(I'll push shortly still need to sort out the caching for
get_flows) look like this,

   struct net_flow_hdr **(*ndo_flow_get_hdrs)(struct net_device *dev);
   struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct 
net_device *dev)

I could then use the following signatures for put hdrs,

   int (*ndo_flow_put_hdrs)(struct net_device *dev, struct net_flow_hdr 
**hdrs);
   int (*ndo_flow_put_hdrs_graph(struct net_device *dev, struct 
net_flow_hdr_graph **graph);

If the user supplies a new set of hdrs via put_hdrs it would
invalidate the hdrs graph though so we could either smash those two
operations into one or require both to occur when the device is down but
not allow it to come up without a graph operation. Currently my
preference is to smash the above two ops to this,

>   int (*ndo_flow_put_hdrs)(struct net_device *dev, struct net_flow_hdr **hdrs, struct net_flow_hdr_graph **graph);

I've gone back and forth on this, doing updates to the hdrs/graph
while the device is online doesn't seem practical. I don't have access
to any devices that would support this. If your device is a software
one though (futuristic eBPF-OVS) it may make some sense.

> When it comes to parsing I'm assuming that hw will fall
> into N categories:
> - that has get_headers() and get_header_graph() only
>    which would mean fixed parser

right this is rocker and what the initial series is trying to
address.

> - above plus put_header_graph() which will allow to
>    rearrange some fixed sized headers ?

OK but I'm not sure where/if these devices exist. Maybe your
thinking of a software dataplane case? Would get_headers return
some headers/fields but not include them in the graph and then
expect the user to build a graph with them if the user needs
them. Are there restrictions on how the graph can be built
out? I guess I'm working with the assumption that the device
returns a complete parse graph for all combinations it supports.
Are there really devices that could only support certain combinations
and then if you shuffled the headers graph around support others?
I'm just not aware of any device.

> - above plus put_header() ?
>    I'm having a hard time envisioning how that would
>    look like.

This case makes more sense to me. The user supplies the definition
of the headers and the graph showing how they are related and the
driver can program the parser to work correctly. This implies a
flexible parser but I think some devices could support this. You
would need some attributes to define depth of the parser and such
restrictions if the device has restrictions on the parsers that
can be supported.

Maybe one concrete example would be to introduce a header tag that
was previously unknown to the device. You could define it using
the header/fields (bit/length/offset) notation and then give the
graph to let the parser "know" where to expect it. Finally this
could be passed to the driver and the parser could be generated.

To be honest though I would really be happy getting the 1st option
working.

> - ... ?
>
> also can we change a name from add_flow
> to add_entry or add_rule ?
> I think 'rule' fits better, since rule = field_ref+action
> and one real TCP flow may need multiple rules
> inserted into table, right?
> The whole thing can still be called 'flow API'...

add_rule/del_rule fine by me.

>
> will there be a put_table_graph() ?
> probably not, right? since as soon as HW supports
> 'goto' aciton, the meaning of table_graph is lost and
> it's actually just a set of disconnected tables and the
> way to jump from one into another is through 'goto'.

hmm I have support in another tree for create/destroy table. This
allows users to create tables and destroy them. .

I think the table_graph is still relevant its just the graph
is completely connected. I'm not sure you will really see hardware
like this anytime soon though :) or maybe I just mean I haven't
seen any.

>
> I think OVS guys are quiet, since they're skeptical
> that headers+header_graph approach can work?
> Would be great if they can share the experience...
>

hmm maybe but I could define all the headers OVS supports using
this. And then define a linear array of tables. It might be an
interesting exercise to build this on top of rocker.

-- 
John Fastabend         Intel Corporation
