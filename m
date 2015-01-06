From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 05 Jan 2015 22:04:03 -0800
Message-ID: <54AB7AD3.7050704@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <CAE4R7bBeCbq1yiRHQaQSX4JwKMWxn2hMoOptyOZe3Ak=9WzrVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34524 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbbAFGET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 01:04:19 -0500
Received: by mail-ob0-f182.google.com with SMTP id wo20so64218897obc.13
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 22:04:18 -0800 (PST)
In-Reply-To: <CAE4R7bBeCbq1yiRHQaQSX4JwKMWxn2hMoOptyOZe3Ak=9WzrVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> +/**
>> + * @struct net_flow_action
>> + * @brief a description of a endpoint defined action
>> + *
>> + * @name printable name
>> + * @uid unique action identifier
>> + * @types NET_FLOW_ACTION_TYPE_NULL terminated list of action types
>
> s/types/args?
>

yep typo fixed in upcoming v2.

>> + */
>> +struct net_flow_action {
>> +       char name[NET_FLOW_NAMSIZ];
>> +       int uid;
>> +       struct net_flow_action_arg *args;
>> +};
>> +
>> +/**
>> + * @struct net_flow_table
>> + * @brief define flow table with supported match/actions
>> + *
>> + * @uid unique identifier for table
>> + * @source uid of parent table
>
> Is parent table the table previous in the pipeline?  If so, what if
> you can get to table from N different parent tables, what goes in
> source?

No, you can get the layout of tables from the table graph ops.

Source is used when a single tcam or other implementation mechanism
is sliced into a set of tables. The current rocker world doesn't use
this very much at the moment because its static and I just assumed
every table came out of the same virtual hardware namespace.

A simple example world would be to come up with a set of large virtual
TCAMs. Any given TCAM maybe sliced into a set of tables. Users may
organize these either via some out of band configuration at init or
power on time. In the rocker case we could specify this when we load
qemu. For now it is just informational. But if we start allowing users
to create delete tables at runtime it is important to "know" where the
slices are being allocated/free'd from. The source gives you this
information.

The hardware devices I'm working on have multiple sources we can
allocate/free tables from. The source values would provide a way to
track down which tables are in which hardware namespaces.

Hope that helps?

>
>> + * @size max number of entries for table or -1 for unbounded
>> + * @matches null terminated set of supported match types given by match uid
>> + * @actions null terminated set of supported action types given by action uid
>> + * @flows set of flows
>> + */
>> +struct net_flow_table {
>> +       char name[NET_FLOW_NAMSIZ];
>> +       int uid;
>> +       int source;
>> +       int size;
>> +       struct net_flow_field_ref *matches;
>> +       int *actions;
>> +};
>> +
>> +/* net_flow_hdr_node: node in a header graph of header fields.
>> + *
>> + * @uid : unique id of the graph node
>> + * @flwo_header_ref : identify the hdrs that can handled by this node
>
> s/flwo_header_ref/hdrs?
>
>> + * @net_flow_jump_table : give a case jump statement
>
> s/net_flow_jump_table/jump

yep thanks.

>
>> + */
>> +struct net_flow_hdr_node {
>> +       char name[NET_FLOW_NAMSIZ];
>> +       int uid;
>> +       int *hdrs;
>> +       struct net_flow_jump_table *jump;
>> +};
>> +
>> +struct net_flow_tbl_node {
>> +       int uid;
>> +       __u32 flags;
>> +       struct net_flow_jump_table *jump;
>> +};
>> +#endif
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 29c92ee..3c3c856 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -52,6 +52,11 @@
>>   #include <linux/neighbour.h>
>>   #include <uapi/linux/netdevice.h>
>>
>> +#ifdef CONFIG_NET_FLOW_TABLES
>> +#include <linux/if_flow.h>
>> +#include <uapi/linux/if_flow.h>
>
> linux/if_flow.h already included uapi file
>

fixed.

>> +#endif
>> +
>>   struct netpoll_info;
>>   struct device;
>>   struct phy_device;
>> @@ -1186,6 +1191,13 @@ struct net_device_ops {
>>          int                     (*ndo_switch_port_stp_update)(struct net_device *dev,
>>                                                                u8 state);
>>   #endif
>> +#ifdef CONFIG_NET_FLOW_TABLES
>> +       struct net_flow_action  **(*ndo_flow_get_actions)(struct net_device *dev);
>> +       struct net_flow_table   **(*ndo_flow_get_tables)(struct net_device *dev);
>> +       struct net_flow_header  **(*ndo_flow_get_headers)(struct net_device *dev);
>> +       struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct net_device *dev);
>
> hdr or header?  pick one, probably hdr.

hdr is shorter and doesn't lose any clarity IMO I'll use net_flow_hdr
and net_flow_hdr_node

>
>> +       struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct net_device *dev);
>
> move this up next to get_tables

sure also what do you think tbl instead of table.

>
>> +#endif
>>   };
>>
>>   /**
>> diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
>> new file mode 100644
>> index 0000000..2acdb38
>> --- /dev/null
>> +++ b/include/uapi/linux/if_flow.h
>> @@ -0,0 +1,363 @@
>> +/*
>> + * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
>> + * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
>> + *
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms and conditions of the GNU General Public License,
>> + * version 2, as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope it will be useful, but WITHOUT
>> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>> + * more details.
>> + *
>> + * The full GNU General Public License is included in this distribution in
>> + * the file called "COPYING".
>> + *
>> + * Author: John Fastabend <john.r.fastabend@intel.com>
>> + */
>> +
>> +/* Netlink description:
>> + *
>> + * Table definition used to describe running tables. The following
>> + * describes the netlink message returned from a flow API messages.
>
> message?
>

That sentence is a bit awkward all around. Changed it to

"The following describes the netlink format used by the flow API."

maybe that is better.

>
>> +
>> +enum {
>> +       NET_FLOW_MASK_TYPE_UNSPEC,
>> +       NET_FLOW_MASK_TYPE_EXACT,
>> +       NET_FLOW_MASK_TYPE_LPM,
>
> As discussed in another thread, need third mask type that's not LPM;
> e.g. 0b0101.
>

yep.

>
>> +#define NET_FLOW_TABLE_GRAPH_NODE_MAX (__NET_FLOW_TABLE_GRAPH_NODE_MAX - 1)
>> +
>> +enum {
>> +       NET_FLOW_TABLE_GRAPH_UNSPEC,
>> +       NET_FLOW_TABLE_GRAPH_NODE,
>> +       __NET_FLOW_TABLE_GRAPH_MAX,
>> +};
>> +#define NET_FLOW_TABLE_GRAPH_MAX (__NET_FLOW_TABLE_GRAPH_MAX - 1)
>> +
>> +enum {
>> +       NET_FLOW_IDENTIFIER_IFINDEX, /* net_device ifindex */
>
> Maybe add an NET_FLOW_IDENTIFIER_UNSPEC so NET_FLOW_IDENTIFIER_IFINDEX
> isn't zero.
>

agreed I tend to like being able to test things with if (foo) { ... }

[...]

>> +
>> +static int net_flow_put_action(struct sk_buff *skb, struct net_flow_action *a)
>> +{
>> +       struct net_flow_action_arg *this;
>> +       struct nlattr *nest;
>> +       int err, args = 0;
>> +
>> +       if (a->name && nla_put_string(skb, NET_FLOW_ACTION_ATTR_NAME, a->name))
>> +               return -EMSGSIZE;
>> +
>> +       if (nla_put_u32(skb, NET_FLOW_ACTION_ATTR_UID, a->uid))
>> +               return -EMSGSIZE;
>> +
>> +       if (!a->args)
>> +               return 0;
>> +
>> +       for (this = &a->args[0]; strlen(this->name) > 0; this++)
>> +               args++;
>> +
>
> Since you only need to know that there are > 0 args, but don't need
> the actual count, can you simplify test with something like:
>

good catch, this is a hold over from some code I rewrote I'll clean
this up like,


  static int net_flow_put_action(struct sk_buff *skb, struct 
net_flow_action *a)
  {
          struct net_flow_action_arg *this;
          struct nlattr *nest;
          int err;

          if (a->name && nla_put_string(skb, NET_FLOW_ACTION_ATTR_NAME, 
a->name))
                  return -EMSGSIZE;

          if (nla_put_u32(skb, NET_FLOW_ACTION_ATTR_UID, a->uid))
                  return -EMSGSIZE;

          if (a->args && a->args[0].type) {
                  nest = nla_nest_start(skb, 
NET_FLOW_ACTION_ATTR_SIGNATURE);
                  if (!nest)
                          return -EMSGSIZE;

                  err = net_flow_put_act_types(skb, a->args);
                  if (err) {
                          nla_nest_cancel(skb, nest);
                          return err;
                  }
                  nla_nest_end(skb, nest);
        }

         return 0;
  }

I think that should probably work. Of course I'll compile it and test
it.


>     bool has_args = strlen(a->args->name) > 0;
>
> or
>
>    bool has_args = !!a->args->type;
>
>> +       if (args) {
>> +               nest = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
>> +               if (!nest)
>> +                       goto nest_put_failure;
>
> Maybe just return -EMSGSIZE here and skip goto.
>
>> +
>> +               err = net_flow_put_act_types(skb, a->args);
>> +               if (err) {
>> +                       nla_nest_cancel(skb, nest);
>> +                       return err;
>> +               }
>> +               nla_nest_end(skb, nest);
>> +       }
>> +
>> +       return 0;
>> +nest_put_failure:
>> +       return -EMSGSIZE;
>> +}
>> +
>> +static int net_flow_put_actions(struct sk_buff *skb,
>> +                               struct net_flow_action **acts)
>> +{
>> +       struct nlattr *actions;
>> +       int err, i;
>> +
>> +       actions = nla_nest_start(skb, NET_FLOW_ACTIONS);
>> +       if (!actions)
>> +               return -EMSGSIZE;
>> +
>> +       for (i = 0; acts[i]->uid; i++) {
>
> Using for(act = acts; act->udi; act++) will make code a little nicer.
>

not entirely convinced its any nicer that way but sure I'll convert it.

[...]

>> +static int net_flow_cmd_get_actions(struct sk_buff *skb,
>> +                                   struct genl_info *info)
>> +{
>> +       struct net_flow_action **a;
>> +       struct net_device *dev;
>> +       struct sk_buff *msg;
>> +
>> +       dev = net_flow_get_dev(info);
>> +       if (!dev)
>> +               return -EINVAL;
>> +
>> +       if (!dev->netdev_ops->ndo_flow_get_actions) {
>> +               dev_put(dev);
>> +               return -EOPNOTSUPP;
>> +       }
>> +
>> +       a = dev->netdev_ops->ndo_flow_get_actions(dev);
>> +       if (!a)
>> +               return -EBUSY;
>
> Is it assumed ndo_flow_get_actions() returns a pointer to a static
> list of actions?  What if the device wants to give up a dynamic list
> of actions?  I'm trying to understand the lifetime of pointer 'a'.
> What would cause -EBUSY condition?
>

Ah this is a good point. At the moment if a driver dynamically changes
a structure then its going to break because there is no locking
involved. I think the best way to do this is to use RCU here. We can
return rcu dereferenced pointers and then drivers will need to wait a
grace period before free'ing the old pointer. To simplify drivers we
can do this from helper calls and document the semantics.

Currently rocker is static so we don't have any issues. If no one minds
I would like to do this in a follow up series.

>> +
>> +       msg = net_flow_build_actions_msg(a, dev,
>> +                                        info->snd_portid,
>> +                                        info->snd_seq,
>> +                                        NET_FLOW_TABLE_CMD_GET_ACTIONS);
>> +       dev_put(dev);
>> +
>> +       if (IS_ERR(msg))
>> +               return PTR_ERR(msg);
>> +
>> +       return genlmsg_reply(msg, info);
>> +}
>> +
>> +static int net_flow_put_table(struct net_device *dev,
>> +                             struct sk_buff *skb,
>> +                             struct net_flow_table *t)
>> +{
>> +       struct nlattr *matches, *actions;
>> +       int i;
>> +
>> +       if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
>> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
>> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
>> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
>> +               return -EMSGSIZE;
>> +
>> +       matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
>> +       if (!matches)
>> +               return -EMSGSIZE;
>> +
>> +       for (i = 0; t->matches[i].instance; i++)
>
> pointer-based loop better than i-based?  my personal preference, i guess.

hmm I guess I tended to write these with indices. I might leave them
for now but can change them if the consensus is pointer loops are easier
to read.

>
>> +               nla_put(skb, NET_FLOW_FIELD_REF,
>> +                       sizeof(struct net_flow_field_ref),
>> +                       &t->matches[i]);
>> +       nla_nest_end(skb, matches);
>> +


-- 
John Fastabend         Intel Corporation
