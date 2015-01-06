From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 5 Jan 2015 21:25:28 -0800
Message-ID: <CAE4R7bBeCbq1yiRHQaQSX4JwKMWxn2hMoOptyOZe3Ak=9WzrVw@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194544.31070.30335.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:47306 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbAFFZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 00:25:30 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so10922054wgg.40
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 21:25:28 -0800 (PST)
In-Reply-To: <20141231194544.31070.30335.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice work John.  Some nits inline...

On Wed, Dec 31, 2014 at 11:45 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
> new file mode 100644
> index 0000000..1b6c1ea
> --- /dev/null
> +++ b/include/linux/if_flow.h
> @@ -0,0 +1,93 @@
> +/*
> + * include/linux/net/if_flow.h - Flow table interface for Switch devices
> + * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
> + *
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Author: John Fastabend <john.r.fastabend@intel.com>
> + */
> +
> +#ifndef _IF_FLOW_H
> +#define _IF_FLOW_H
> +
> +#include <uapi/linux/if_flow.h>
> +
> +/**
> + * @struct net_flow_header
> + * @brief defines a match (header/field) an endpoint can use
> + *
> + * @uid unique identifier for header
> + * @field_sz number of fields are in the set
> + * @fields the set of fields in the net_flow_header
> + */
> +struct net_flow_header {
> +       char name[NET_FLOW_NAMSIZ];
> +       int uid;
> +       int field_sz;
> +       struct net_flow_field *fields;
> +};
> +
> +/**
> + * @struct net_flow_action
> + * @brief a description of a endpoint defined action
> + *
> + * @name printable name
> + * @uid unique action identifier
> + * @types NET_FLOW_ACTION_TYPE_NULL terminated list of action types

s/types/args?

> + */
> +struct net_flow_action {
> +       char name[NET_FLOW_NAMSIZ];
> +       int uid;
> +       struct net_flow_action_arg *args;
> +};
> +
> +/**
> + * @struct net_flow_table
> + * @brief define flow table with supported match/actions
> + *
> + * @uid unique identifier for table
> + * @source uid of parent table

Is parent table the table previous in the pipeline?  If so, what if
you can get to table from N different parent tables, what goes in
source?

> + * @size max number of entries for table or -1 for unbounded
> + * @matches null terminated set of supported match types given by match uid
> + * @actions null terminated set of supported action types given by action uid
> + * @flows set of flows
> + */
> +struct net_flow_table {
> +       char name[NET_FLOW_NAMSIZ];
> +       int uid;
> +       int source;
> +       int size;
> +       struct net_flow_field_ref *matches;
> +       int *actions;
> +};
> +
> +/* net_flow_hdr_node: node in a header graph of header fields.
> + *
> + * @uid : unique id of the graph node
> + * @flwo_header_ref : identify the hdrs that can handled by this node

s/flwo_header_ref/hdrs?

> + * @net_flow_jump_table : give a case jump statement

s/net_flow_jump_table/jump

> + */
> +struct net_flow_hdr_node {
> +       char name[NET_FLOW_NAMSIZ];
> +       int uid;
> +       int *hdrs;
> +       struct net_flow_jump_table *jump;
> +};
> +
> +struct net_flow_tbl_node {
> +       int uid;
> +       __u32 flags;
> +       struct net_flow_jump_table *jump;
> +};
> +#endif
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 29c92ee..3c3c856 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -52,6 +52,11 @@
>  #include <linux/neighbour.h>
>  #include <uapi/linux/netdevice.h>
>
> +#ifdef CONFIG_NET_FLOW_TABLES
> +#include <linux/if_flow.h>
> +#include <uapi/linux/if_flow.h>

linux/if_flow.h already included uapi file

> +#endif
> +
>  struct netpoll_info;
>  struct device;
>  struct phy_device;
> @@ -1186,6 +1191,13 @@ struct net_device_ops {
>         int                     (*ndo_switch_port_stp_update)(struct net_device *dev,
>                                                               u8 state);
>  #endif
> +#ifdef CONFIG_NET_FLOW_TABLES
> +       struct net_flow_action  **(*ndo_flow_get_actions)(struct net_device *dev);
> +       struct net_flow_table   **(*ndo_flow_get_tables)(struct net_device *dev);
> +       struct net_flow_header  **(*ndo_flow_get_headers)(struct net_device *dev);
> +       struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct net_device *dev);

hdr or header?  pick one, probably hdr.

> +       struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct net_device *dev);

move this up next to get_tables

> +#endif
>  };
>
>  /**
> diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
> new file mode 100644
> index 0000000..2acdb38
> --- /dev/null
> +++ b/include/uapi/linux/if_flow.h
> @@ -0,0 +1,363 @@
> +/*
> + * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
> + * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
> + *
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Author: John Fastabend <john.r.fastabend@intel.com>
> + */
> +
> +/* Netlink description:
> + *
> + * Table definition used to describe running tables. The following
> + * describes the netlink message returned from a flow API messages.

message?


> +
> +enum {
> +       NET_FLOW_MASK_TYPE_UNSPEC,
> +       NET_FLOW_MASK_TYPE_EXACT,
> +       NET_FLOW_MASK_TYPE_LPM,

As discussed in another thread, need third mask type that's not LPM;
e.g. 0b0101.


> +#define NET_FLOW_TABLE_GRAPH_NODE_MAX (__NET_FLOW_TABLE_GRAPH_NODE_MAX - 1)
> +
> +enum {
> +       NET_FLOW_TABLE_GRAPH_UNSPEC,
> +       NET_FLOW_TABLE_GRAPH_NODE,
> +       __NET_FLOW_TABLE_GRAPH_MAX,
> +};
> +#define NET_FLOW_TABLE_GRAPH_MAX (__NET_FLOW_TABLE_GRAPH_MAX - 1)
> +
> +enum {
> +       NET_FLOW_IDENTIFIER_IFINDEX, /* net_device ifindex */

Maybe add an NET_FLOW_IDENTIFIER_UNSPEC so NET_FLOW_IDENTIFIER_IFINDEX
isn't zero.

> diff --git a/net/Kconfig b/net/Kconfig
> index ff9ffc1..8380bfe 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -293,6 +293,13 @@ config NET_FLOW_LIMIT
>           with many clients some protection against DoS by a single (spoofed)
>           flow that greatly exceeds average workload.
>
> +config NET_FLOW_TABLES
> +       boolean "Support network flow tables"
> +       ---help---
> +       This feature provides an interface for device drivers to report
> +       flow tables and supported matches and actions. If you do not
> +       want to support hardware offloads for flow tables, say N here.
> +
>  menu "Network testing"
>
>  config NET_PKTGEN
> diff --git a/net/core/Makefile b/net/core/Makefile
> index 235e6c5..1eea785 100644
> --- a/net/core/Makefile
> +++ b/net/core/Makefile
> @@ -23,3 +23,4 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
>  obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
>  obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
>  obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
> +obj-$(CONFIG_NET_FLOW_TABLES) += flow_table.o
> diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> new file mode 100644
> index 0000000..ec3f06d
> --- /dev/null
> +++ b/net/core/flow_table.c
> @@ -0,0 +1,837 @@
> +/*
> + * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
> + * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
> + *
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Author: John Fastabend <john.r.fastabend@intel.com>
> + */
> +
> +#include <uapi/linux/if_flow.h>
> +#include <linux/if_flow.h>
> +#include <linux/if_bridge.h>
> +#include <linux/types.h>
> +#include <net/netlink.h>
> +#include <net/genetlink.h>
> +#include <net/rtnetlink.h>
> +#include <linux/module.h>
> +
> +static struct genl_family net_flow_nl_family = {
> +       .id             = GENL_ID_GENERATE,
> +       .name           = NET_FLOW_GENL_NAME,
> +       .version        = NET_FLOW_GENL_VERSION,
> +       .maxattr        = NET_FLOW_MAX,
> +       .netnsok        = true,
> +};
> +
> +static struct net_device *net_flow_get_dev(struct genl_info *info)
> +{
> +       struct net *net = genl_info_net(info);
> +       int type, ifindex;
> +
> +       if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
> +           !info->attrs[NET_FLOW_IDENTIFIER])
> +               return NULL;
> +
> +       type = nla_get_u32(info->attrs[NET_FLOW_IDENTIFIER_TYPE]);
> +       switch (type) {
> +       case NET_FLOW_IDENTIFIER_IFINDEX:
> +               ifindex = nla_get_u32(info->attrs[NET_FLOW_IDENTIFIER]);
> +               break;
> +       default:
> +               return NULL;
> +       }
> +
> +       return dev_get_by_index(net, ifindex);
> +}
> +
> +static int net_flow_put_act_types(struct sk_buff *skb,
> +                                 struct net_flow_action_arg *args)
> +{
> +       int i, err;
> +
> +       for (i = 0; args[i].type; i++) {
> +               err = nla_put(skb, NET_FLOW_ACTION_ARG,
> +                             sizeof(struct net_flow_action_arg), &args[i]);
> +               if (err)
> +                       return -EMSGSIZE;
> +       }
> +       return 0;
> +}
> +
> +static const
> +struct nla_policy net_flow_action_policy[NET_FLOW_ACTION_ATTR_MAX + 1] = {
> +       [NET_FLOW_ACTION_ATTR_NAME]      = {.type = NLA_STRING,
> +                                           .len = NET_FLOW_NAMSIZ-1 },
> +       [NET_FLOW_ACTION_ATTR_UID]       = {.type = NLA_U32 },
> +       [NET_FLOW_ACTION_ATTR_SIGNATURE] = {.type = NLA_NESTED },
> +};
> +
> +static int net_flow_put_action(struct sk_buff *skb, struct net_flow_action *a)
> +{
> +       struct net_flow_action_arg *this;
> +       struct nlattr *nest;
> +       int err, args = 0;
> +
> +       if (a->name && nla_put_string(skb, NET_FLOW_ACTION_ATTR_NAME, a->name))
> +               return -EMSGSIZE;
> +
> +       if (nla_put_u32(skb, NET_FLOW_ACTION_ATTR_UID, a->uid))
> +               return -EMSGSIZE;
> +
> +       if (!a->args)
> +               return 0;
> +
> +       for (this = &a->args[0]; strlen(this->name) > 0; this++)
> +               args++;
> +

Since you only need to know that there are > 0 args, but don't need
the actual count, can you simplify test with something like:

   bool has_args = strlen(a->args->name) > 0;

or

  bool has_args = !!a->args->type;

> +       if (args) {
> +               nest = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
> +               if (!nest)
> +                       goto nest_put_failure;

Maybe just return -EMSGSIZE here and skip goto.

> +
> +               err = net_flow_put_act_types(skb, a->args);
> +               if (err) {
> +                       nla_nest_cancel(skb, nest);
> +                       return err;
> +               }
> +               nla_nest_end(skb, nest);
> +       }
> +
> +       return 0;
> +nest_put_failure:
> +       return -EMSGSIZE;
> +}
> +
> +static int net_flow_put_actions(struct sk_buff *skb,
> +                               struct net_flow_action **acts)
> +{
> +       struct nlattr *actions;
> +       int err, i;
> +
> +       actions = nla_nest_start(skb, NET_FLOW_ACTIONS);
> +       if (!actions)
> +               return -EMSGSIZE;
> +
> +       for (i = 0; acts[i]->uid; i++) {

Using for(act = acts; act->udi; act++) will make code a little nicer.

> +               struct nlattr *action = nla_nest_start(skb, NET_FLOW_ACTION);
> +
> +               if (!action)
> +                       goto action_put_failure;
> +
> +               err = net_flow_put_action(skb, acts[i]);
> +               if (err)
> +                       goto action_put_failure;
> +               nla_nest_end(skb, action);
> +       }
> +       nla_nest_end(skb, actions);
> +
> +       return 0;
> +action_put_failure:
> +       nla_nest_cancel(skb, actions);
> +       return -EMSGSIZE;
> +}
> +
> +struct sk_buff *net_flow_build_actions_msg(struct net_flow_action **a,
> +                                          struct net_device *dev,
> +                                          u32 portid, int seq, u8 cmd)
> +{
> +       struct genlmsghdr *hdr;
> +       struct sk_buff *skb;
> +       int err = -ENOBUFS;
> +
> +       skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +       if (!skb)
> +               return ERR_PTR(-ENOBUFS);
> +
> +       hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
> +       if (!hdr)
> +               goto out;
> +
> +       if (nla_put_u32(skb,
> +                       NET_FLOW_IDENTIFIER_TYPE,
> +                       NET_FLOW_IDENTIFIER_IFINDEX) ||
> +           nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
> +               err = -ENOBUFS;
> +               goto out;
> +       }
> +
> +       err = net_flow_put_actions(skb, a);
> +       if (err < 0)
> +               goto out;
> +
> +       err = genlmsg_end(skb, hdr);
> +       if (err < 0)
> +               goto out;
> +
> +       return skb;
> +out:
> +       nlmsg_free(skb);
> +       return ERR_PTR(err);
> +}
> +
> +static int net_flow_cmd_get_actions(struct sk_buff *skb,
> +                                   struct genl_info *info)
> +{
> +       struct net_flow_action **a;
> +       struct net_device *dev;
> +       struct sk_buff *msg;
> +
> +       dev = net_flow_get_dev(info);
> +       if (!dev)
> +               return -EINVAL;
> +
> +       if (!dev->netdev_ops->ndo_flow_get_actions) {
> +               dev_put(dev);
> +               return -EOPNOTSUPP;
> +       }
> +
> +       a = dev->netdev_ops->ndo_flow_get_actions(dev);
> +       if (!a)
> +               return -EBUSY;

Is it assumed ndo_flow_get_actions() returns a pointer to a static
list of actions?  What if the device wants to give up a dynamic list
of actions?  I'm trying to understand the lifetime of pointer 'a'.
What would cause -EBUSY condition?

> +
> +       msg = net_flow_build_actions_msg(a, dev,
> +                                        info->snd_portid,
> +                                        info->snd_seq,
> +                                        NET_FLOW_TABLE_CMD_GET_ACTIONS);
> +       dev_put(dev);
> +
> +       if (IS_ERR(msg))
> +               return PTR_ERR(msg);
> +
> +       return genlmsg_reply(msg, info);
> +}
> +
> +static int net_flow_put_table(struct net_device *dev,
> +                             struct sk_buff *skb,
> +                             struct net_flow_table *t)
> +{
> +       struct nlattr *matches, *actions;
> +       int i;
> +
> +       if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
> +           nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
> +               return -EMSGSIZE;
> +
> +       matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
> +       if (!matches)
> +               return -EMSGSIZE;
> +
> +       for (i = 0; t->matches[i].instance; i++)

pointer-based loop better than i-based?  my personal preference, i guess.

> +               nla_put(skb, NET_FLOW_FIELD_REF,
> +                       sizeof(struct net_flow_field_ref),
> +                       &t->matches[i]);
> +       nla_nest_end(skb, matches);
> +
