From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 08:58:07 -0800
Message-ID: <54C12C1F.706@gmail.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:37911 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbAVQ6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:58:25 -0500
Received: by mail-oi0-f41.google.com with SMTP id z81so2315828oif.0
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:58:24 -0800 (PST)
In-Reply-To: <20150122151316.GB25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 07:13 AM, Thomas Graf wrote:
> On 01/22/15 at 10:00am, Jamal Hadi Salim wrote:
>> On 01/22/15 09:00, Pablo Neira Ayuso wrote:
>>
>>>

I'll try to unify the threads here

>>> +/* rocker specific action definitions */
>>> +struct net_flow_action_arg rocker_set_group_id_args[] = {
>>> +       {
>>> +               .name = "group_id",
>>> +               .type = NFL_ACTION_ARG_TYPE_U32,
>>> +               .value_u32 = 0,
>>> +       },
>>>

In response to Pablo's observation,

Correct this is fully exposed to user space, but it is also self
contained inside the API meaning I can learn when to use it and what it
does by looking at the other operations tables the table graph and
supported headers. The assumption I am making that is not in the API
explicitly yet. Is that actions named "set_field_name" perform the
set operation on that field. We can and plan to extend the API to make
this assumption explicit in the API.

In this case I can "learn" that I can match on group_id in some tables
and then use the above action to set the group_id in others.

>>> that is retrieved via ndo_flow_get_actions and fully exposed to
>>> userspace.
>>>
>>
>> My main concern is along similar lines (I did express it earlier and
>> I think Jiri chimed in as well).
>> The API exposes direct access to hardware. I am sure this was a result
>> of trying to replace the ethtool interface (which was primitive).
>> By providing vendors direct access to the hardware - they do not need
>> to use any traditional Linux tooling/APIs.
>
> I don't follow this. John's proposal allows to decide on a case by
> case basis what we want to export. Just like with ethtool or
> RTNETLINK. There is no direct access to hardware. A user can only
> configure what is being exposed by the kernel.
>
> Pablo raises an interesting point though. How do we handle unique
> features like Rocker groups.
>
> Maybe Jiri and Scott can chime in and describe if we can map this to
> something more generic and avoid exporting anything Rocker specific.
>

Even though its a detail of the rocker world its easy enough for a
program on top of the API to learn how it works.

So in the rocker switch case if I want to rewrite an eth_dst adress I
have a  couple choices. I can set the group_id in one of the tables
that support setting the group_id and then do the rewrite in one of the
tables that supports matching on group_id and setting the eth_dst mac.
The "choice" I make is a policy IMO and I don't want to hard code logic
in the kernel that picks tables and decides things like what should I
do if table x is full but table y could also be used should I overflow
into table y? Or  is table y reserved for some other network function?
etc.

There are some actions and metadata though that _need_ to be
standardized. These are the metadata that is used outside the API. For
example ingress_port is metadata that is set outside the tables.
Similarly set_egress_port and set_egress_queue provide the forwarding
and queueing fields. No matter how hard you look at the model from the
API you can not learn how these are used.

> What would a rocker group map to in the tc world?

In the 'tc' world I would guess the easiest thing to do is simply bind
a 'tc' qdisc to the ACL table. It seems a good first approximation of
how to make this work. But the rocker world doesn't yet have any QOS so
it makes it difficult to "offload" anything but the fifo qdiscs.

>
>> I see this as a gaping hole
>> for vendor SDKs with their own definitions of their own hardware that
>> doesnt work with anyone else. i.e it seems to standardize proprietary
>> interfaces. Maybe thats what Pablo is alluding to.
>
> I will be the first to root for rejection if such patches appear.
>

Is it problematic if users define some unique header here and then
provide actions to set/pop/push/get operations on it?

For me this seems perfectly reasonable. We can pull it out of hardware
or a database in libvirt perhaps then feed it back into Linux nft,
ebpf, tc u32_filter, to create a unified view. I think ebpf, nft, and
u32 have been all about supporting vendor specific protocols?

I must be missing the point about proprietary interfaces. The FLOW API
would be the interface and if we create interesting tools/systems around
it and integration with other Linux sub-systems by choosing to use a
proprietary SDK you lose the goodness.

.John

-- 
John Fastabend         Intel Corporation
