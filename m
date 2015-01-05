From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 05 Jan 2015 10:59:11 -0800
Message-ID: <54AADEFF.3090306@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <20150104111238.GD15305@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33684 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbbAES70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 13:59:26 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so62393687obc.6
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 10:59:25 -0800 (PST)
In-Reply-To: <20150104111238.GD15305@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2015 03:12 AM, Thomas Graf wrote:
> On 12/31/14 at 11:45am, John Fastabend wrote:
>
> Impressive work John, some minor nits below. In general this looks
> great. How large could tables grow? Any risk one of the nested
> attribtues could exceed 16K in size because of a very large parse
> graph? Not a problem if we account for it and allow for jumbo
> attributes.
>

hmm it sounds large to me but maybe if you have an NPU that is trying
to parse into application data it could happen.

What does it take to allow for jumbo attributes?

>> +
>> +/**
>> + * @struct net_flow_header
>> + * @brief defines a match (header/field) an endpoint can use
>> + *
>> + * @uid unique identifier for header
>> + * @field_sz number of fields are in the set
>> + * @fields the set of fields in the net_flow_header
>
> FWIW, name is not documented.

thanks fixed up documentation and spacing for v2.

[...]

>> +#ifndef _UAPI_LINUX_IF_FLOW
>> +#define _UAPI_LINUX_IF_FLOW
>> +
>> +#include <linux/types.h>
>> +#include <linux/netlink.h>
>> +#include <linux/if.h>
>> +
>> +#define NET_FLOW_NAMSIZ 80
>
> Did you consider allocating the memory for names? I don't have a grasp
> for the typical number of net_flow_* instances in memory yet.
>

<100k in the devices I have. Maybe Simon can pitch in what is typical
on the NPUs I'm not sure about them.

Rocker tables can grow as large as needed at the moment.

Allocating the memory may help I'll go ahead and give it a try.

>> +/**
>> + * @struct net_flow_field_ref
>> + * @brief uniquely identify field as header:field tuple
>> + */
>> +struct net_flow_field_ref {
>> +	int instance;
>> +	int header;
>> +	int field;
>> +	int mask_type;
>> +	int type;
>> +	union {	/* Are these all the required data types */
>> +		__u8 value_u8;
>> +		__u16 value_u16;
>> +		__u32 value_u32;
>> +		__u64 value_u64;
>> +	};
>> +	union {	/* Are these all the required data types */
>> +		__u8 mask_u8;
>> +		__u16 mask_u16;
>> +		__u32 mask_u32;
>> +		__u64 mask_u64;
>> +	};
>> +};
>
> Does it make sense to write this as follows?

Yes. I'll make this update it helps make it clear value/mask pairs are
needed.

>
> union {
>          struct {
>                  __u8 value_u8;
>                  __u8 mask_u8;
>          };
>          struct {
>                  __u16 value_u16;
>                  __u16 mask_u16;
>          };
>          ...
> };
>
>> +#define NET_FLOW_TABLE_EGRESS_ROOT 1
>> +#define	NET_FLOW_TABLE_INGRESS_ROOT 2
>
> Tab/space mix.
>

yep fixed.

>> +struct sk_buff *net_flow_build_actions_msg(struct net_flow_action **a,
>> +					   struct net_device *dev,
>> +					   u32 portid, int seq, u8 cmd)
>> +{
>> +	struct genlmsghdr *hdr;
>> +	struct sk_buff *skb;
>> +	int err = -ENOBUFS;
>> +
>> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>
> genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);

fixed along with the other cases.

>
>> +static int net_flow_put_table(struct net_device *dev,
>> +			      struct sk_buff *skb,
>> +			      struct net_flow_table *t)
>> +{
>> +	struct nlattr *matches, *actions;
>> +	int i;
>> +
>> +	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
>> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
>> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
>> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
>> +		return -EMSGSIZE;
>> +
>> +	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
>> +	if (!matches)
>> +		return -EMSGSIZE;
>> +
>> +	for (i = 0; t->matches[i].instance; i++)
>> +		nla_put(skb, NET_FLOW_FIELD_REF,
>> +			sizeof(struct net_flow_field_ref),
>> +			&t->matches[i]);
>
> Unhandled nla_put() error
>

thanks.

[...]

>> +static int net_flow_put_headers(struct sk_buff *skb,
>> +				struct net_flow_header **headers)
>> +{
>> +	struct nlattr *nest, *hdr, *fields;
>> +	struct net_flow_header *h;
>> +	int i, err;
>> +
>> +	nest = nla_nest_start(skb, NET_FLOW_HEADERS);
>> +	if (!nest)
>> +		return -EMSGSIZE;
>> +
>> +	for (i = 0; headers[i]->uid; i++) {
>> +		err = -EMSGSIZE;
>> +		h = headers[i];
>> +
>> +		hdr = nla_nest_start(skb, NET_FLOW_HEADER);
>> +		if (!hdr)
>> +			goto hdr_put_failure;
>> +
>> +		if (nla_put_string(skb, NET_FLOW_HEADER_ATTR_NAME, h->name) ||
>> +		    nla_put_u32(skb, NET_FLOW_HEADER_ATTR_UID, h->uid))
>> +			goto attr_put_failure;
>> +
>> +		fields = nla_nest_start(skb, NET_FLOW_HEADER_ATTR_FIELDS);
>> +		if (!fields)
>> +			goto attr_put_failure;
>
> You can jump to hdr_put_failure right away and get rid of the
> attr_put_failure target as you cancel that nest anyway. You can apply
> this comment to several other places as well if you want.
>

OK so to simplify the error paths we only need to cancel the outer most
nested attribute. I'll do this transformation.

.John


-- 
John Fastabend         Intel Corporation
