From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Sun, 4 Jan 2015 11:12:38 +0000
Message-ID: <20150104111238.GD15305@casper.infradead.org>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <20141231194544.31070.30335.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jiri@resnulli.us, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40268 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbADLMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 06:12:42 -0500
Content-Disposition: inline
In-Reply-To: <20141231194544.31070.30335.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/14 at 11:45am, John Fastabend wrote:

Impressive work John, some minor nits below. In general this looks
great. How large could tables grow? Any risk one of the nested
attribtues could exceed 16K in size because of a very large parse
graph? Not a problem if we account for it and allow for jumbo
attributes.

> +
> +/**
> + * @struct net_flow_header
> + * @brief defines a match (header/field) an endpoint can use
> + *
> + * @uid unique identifier for header
> + * @field_sz number of fields are in the set
> + * @fields the set of fields in the net_flow_header

FWIW, name is not documented.

> + */
> +struct net_flow_header {
> +	char name[NET_FLOW_NAMSIZ];
> +	int uid;
> +	int field_sz;
> +	struct net_flow_field *fields;
> +};
> +
> +
> +/**
> + * @struct net_flow_table
> + * @brief define flow table with supported match/actions
> + *
> + * @uid unique identifier for table
> + * @source uid of parent table
> + * @size max number of entries for table or -1 for unbounded
> + * @matches null terminated set of supported match types given by match uid
> + * @actions null terminated set of supported action types given by action uid
> + * @flows set of flows

name not documented, flows seems to be leftover

> + */
> +struct net_flow_table {
> +	char name[NET_FLOW_NAMSIZ];
> +	int uid;
> +	int source;
> +	int size;
> +	struct net_flow_field_ref *matches;
> +	int *actions;
> +};
> +
> +/* net_flow_hdr_node: node in a header graph of header fields.
> + *
> + * @uid : unique id of the graph node
> + * @flwo_header_ref : identify the hdrs that can handled by this node
> + * @net_flow_jump_table : give a case jump statement
> + */

needs more work too ;)

> +struct net_flow_hdr_node {
> +	char name[NET_FLOW_NAMSIZ];
> +	int uid;
> +	int *hdrs;
> +	struct net_flow_jump_table *jump;
> +};
> + */
> +
> +/* Netlink description:
> + *
> + * Table definition used to describe running tables. The following
> + * describes the netlink message returned from a flow API messages.
> + *
> + * Flow table definitions used to define tables.
> + *
> + * [NET_FLOW_TABLE_IDENTIFIER_TYPE]
> + * [NET_FLOW_TABLE_IDENTIFIER]
> + * [NET_FLOW_TABLE_TABLES]
> + *     [NET_FLOW_TABLE]
> + *       [NET_FLOW_TABLE_ATTR_NAME]
> + *       [NET_FLOW_TABLE_ATTR_UID]
> + *       [NET_FLOW_TABLE_ATTR_SOURCE]
> + *       [NET_FLOW_TABLE_ATTR_SIZE]
> + *	 [NET_FLOW_TABLE_ATTR_MATCHES]

The tabs and spaces mix make the indentation wrong in the patch, it
looks correct unquoted though but consistency would make this perfect.

> +#ifndef _UAPI_LINUX_IF_FLOW
> +#define _UAPI_LINUX_IF_FLOW
> +
> +#include <linux/types.h>
> +#include <linux/netlink.h>
> +#include <linux/if.h>
> +
> +#define NET_FLOW_NAMSIZ 80

Did you consider allocating the memory for names? I don't have a grasp
for the typical number of net_flow_* instances in memory yet.

> +/**
> + * @struct net_flow_field_ref
> + * @brief uniquely identify field as header:field tuple
> + */
> +struct net_flow_field_ref {
> +	int instance;
> +	int header;
> +	int field;
> +	int mask_type;
> +	int type;
> +	union {	/* Are these all the required data types */
> +		__u8 value_u8;
> +		__u16 value_u16;
> +		__u32 value_u32;
> +		__u64 value_u64;
> +	};
> +	union {	/* Are these all the required data types */
> +		__u8 mask_u8;
> +		__u16 mask_u16;
> +		__u32 mask_u32;
> +		__u64 mask_u64;
> +	};
> +};

Does it make sense to write this as follows?

union {
        struct {
                __u8 value_u8;
                __u8 mask_u8;
        };
        struct {
                __u16 value_u16;
                __u16 mask_u16;
        };
        ...
};

> +#define NET_FLOW_TABLE_EGRESS_ROOT 1
> +#define	NET_FLOW_TABLE_INGRESS_ROOT 2

Tab/space mix.

> +struct sk_buff *net_flow_build_actions_msg(struct net_flow_action **a,
> +					   struct net_device *dev,
> +					   u32 portid, int seq, u8 cmd)
> +{
> +	struct genlmsghdr *hdr;
> +	struct sk_buff *skb;
> +	int err = -ENOBUFS;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);

genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);

> +static int net_flow_put_table(struct net_device *dev,
> +			      struct sk_buff *skb,
> +			      struct net_flow_table *t)
> +{
> +	struct nlattr *matches, *actions;
> +	int i;
> +
> +	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
> +	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
> +		return -EMSGSIZE;
> +
> +	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
> +	if (!matches)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; t->matches[i].instance; i++)
> +		nla_put(skb, NET_FLOW_FIELD_REF,
> +			sizeof(struct net_flow_field_ref),
> +			&t->matches[i]);

Unhandled nla_put() error


> +static struct sk_buff *net_flow_build_tables_msg(struct net_flow_table **t,
> +						 struct net_device *dev,
> +						 u32 portid, int seq, u8 cmd)
> +{
> +	struct genlmsghdr *hdr;
> +	struct sk_buff *skb;
> +	int err = -ENOBUFS;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);

genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);

> +static int net_flow_put_headers(struct sk_buff *skb,
> +				struct net_flow_header **headers)
> +{
> +	struct nlattr *nest, *hdr, *fields;
> +	struct net_flow_header *h;
> +	int i, err;
> +
> +	nest = nla_nest_start(skb, NET_FLOW_HEADERS);
> +	if (!nest)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; headers[i]->uid; i++) {
> +		err = -EMSGSIZE;
> +		h = headers[i];
> +
> +		hdr = nla_nest_start(skb, NET_FLOW_HEADER);
> +		if (!hdr)
> +			goto hdr_put_failure;
> +
> +		if (nla_put_string(skb, NET_FLOW_HEADER_ATTR_NAME, h->name) ||
> +		    nla_put_u32(skb, NET_FLOW_HEADER_ATTR_UID, h->uid))
> +			goto attr_put_failure;
> +
> +		fields = nla_nest_start(skb, NET_FLOW_HEADER_ATTR_FIELDS);
> +		if (!fields)
> +			goto attr_put_failure;

You can jump to hdr_put_failure right away and get rid of the
attr_put_failure target as you cancel that nest anyway. You can apply 
this comment to several other places as well if you want.

> +
> +		err = net_flow_put_fields(skb, h);
> +		if (err)
> +			goto fields_put_failure;
> +
> +		nla_nest_end(skb, fields);
> +
> +		nla_nest_end(skb, hdr);
> +	}
> +	nla_nest_end(skb, nest);
> +
> +	return 0;
> +fields_put_failure:
> +	nla_nest_cancel(skb, fields);
> +attr_put_failure:
> +	nla_nest_cancel(skb, hdr);
> +hdr_put_failure:
> +	nla_nest_cancel(skb, nest);
> +	return err;
> +}
> +
> +static struct sk_buff *net_flow_build_headers_msg(struct net_flow_header **h,
> +						  struct net_device *dev,
> +						  u32 portid, int seq, u8 cmd)
> +{
> +	struct genlmsghdr *hdr;
> +	struct sk_buff *skb;
> +	int err = -ENOBUFS;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>
genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);

> +static
> +struct sk_buff *net_flow_build_graph_msg(struct net_flow_tbl_node **g,
> +					 struct net_device *dev,
> +					 u32 portid, int seq, u8 cmd)
> +{
> +	struct genlmsghdr *hdr;
> +	struct sk_buff *skb;
> +	int err = -ENOBUFS;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>
genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
