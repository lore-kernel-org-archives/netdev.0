From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 02/11] net: flow_table: add flow, delete flow
Date: Mon, 5 Jan 2015 22:19:57 -0800
Message-ID: <CAE4R7bBbnU5SyeEaZoeaziX9nhXxK55eHcsN8vT0h_HZ-n_=cg@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194615.31070.18038.stgit@nitbit.x32>
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
Received: from mail-wg0-f41.google.com ([74.125.82.41]:54302 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbAFGT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 01:19:59 -0500
Received: by mail-wg0-f41.google.com with SMTP id l18so3456848wgh.14
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 22:19:57 -0800 (PST)
In-Reply-To: <20141231194615.31070.18038.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:46 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> Now that the device capabilities are exposed we can add support to
> add and delete flows from the tables.
>
> The two operations are
>
> table_set_flows :
>
>   The set flow operations is used to program a set of flows into a
>   hardware device table. The message is consumed via netlink encoded
>   message which is then decoded into a null terminated  array of
>   flow entry structures. A flow entry structure is defined as
>
>      struct net_flow_flow {
>                           int table_id;
>                           int uid;
>                           int priority;
>                           struct net_flow_field_ref *matches;
>                           struct net_flow_action *actions;
>      }
>
>   The table id is the _uid_ returned from 'get_tables' operatoins.
>   Matches is a set of match criteria for packets with a logical AND
>   operation done on the set so packets match the entire criteria.
>   Actions provide a set of actions to perform when the flow rule is
>   hit. Both matches and actions are null terminated arrays.
>
>   The flows are configured in hardware using an ndo op. We do not
>   provide a commit operation at the moment and expect hardware
>   commits the flows one at a time. Future work may require a commit
>   operation to tell the hardware we are done loading flow rules. On
>   some hardware this will help bulk updates.
>
>   Its possible for hardware to return an error from a flow set
>   operation. This can occur for many reasons both transient and
>   resource constraints. We have different error handling strategies
>   built in and listed here,
>
>     *_ERROR_ABORT      abort on first error with errmsg
>
>     *_ERROR_CONTINUE   continue programming flows no errmsg
>
>     *_ERROR_ABORT_LOG  abort on first error and return flow that
>                        failed to user space in reply msg
>
>     *_ERROR_CONT_LOG   continue programming flows and return a list
>                        of flows that failed to user space in a reply
>                        msg.
>
>   notably missing is a rollback error strategy. I don't have a
>   use for this in software yet but the strategy can be added with
>   *_ERROR_ROLLBACK for example.
>
> table_del_flows
>
>   The delete flow operation uses the same structures and error
>   handling strategies as the table_set_flows operations. Although on
>   delete messges ommit the matches/actions arrays because they are
>   not needed to lookup the flow.
>
> Also thanks to Simon Horman for fixes and other help.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/if_flow.h      |   21 ++
>  include/linux/netdevice.h    |    8 +
>  include/uapi/linux/if_flow.h |   49 ++++
>  net/core/flow_table.c        |  501 ++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 579 insertions(+)
>
> diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
> index 1b6c1ea..20fa752 100644
> --- a/include/linux/if_flow.h
> +++ b/include/linux/if_flow.h
> @@ -90,4 +90,25 @@ struct net_flow_tbl_node {
>         __u32 flags;
>         struct net_flow_jump_table *jump;
>  };
> +
> +/**
> + * @struct net_flow_flow
> + * @brief describes the match/action entry
> + *
> + * @uid unique identifier for flow
> + * @priority priority to execute flow match/action in table

What is the convention on priority?  0 is lowest priority or highest?

> + * @match null terminated set of match uids match criteria
> + * @actoin null terminated set of action uids to apply to match
> + *
> + * Flows must match all entries in match set.
> + */
> +struct net_flow_flow {
> +       int table_id;
> +       int uid;
> +       int priority;
> +       struct net_flow_field_ref *matches;
> +       struct net_flow_action *actions;
> +};
> +
> +int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow);
>  #endif
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3c3c856..be8d4e4 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1197,6 +1197,14 @@ struct net_device_ops {
>         struct net_flow_header  **(*ndo_flow_get_headers)(struct net_device *dev);
>         struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct net_device *dev);
>         struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct net_device *dev);
> +       int                     (*ndo_flow_get_flows)(struct sk_buff *skb,
> +                                                     struct net_device *dev,
> +                                                     int table,
> +                                                     int min, int max);
> +       int                     (*ndo_flow_set_flows)(struct net_device *dev,
> +                                                     struct net_flow_flow *f);
> +       int                     (*ndo_flow_del_flows)(struct net_device *dev,
> +                                                     struct net_flow_flow *f);

Need doc for these in BIG comment block above this struct.  Same for
ndo_flow_xxx added in previous patch.

>  #endif
>  };
>
> diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
> index 2acdb38..125cdc6 100644
> --- a/include/uapi/linux/if_flow.h
> +++ b/include/uapi/linux/if_flow.h
> @@ -329,6 +329,48 @@ enum {
>  #define NET_FLOW_TABLE_GRAPH_MAX (__NET_FLOW_TABLE_GRAPH_MAX - 1)
>
>  enum {
> +       NET_FLOW_NET_FLOW_UNSPEC,
> +       NET_FLOW_FLOW,
> +       __NET_FLOW_NET_FLOW_MAX,
> +};
> +#define NET_FLOW_NET_FLOW_MAX (__NET_FLOW_NET_FLOW_MAX - 1)
> +
> +enum {
> +       NET_FLOW_TABLE_FLOWS_UNSPEC,
> +       NET_FLOW_TABLE_FLOWS_TABLE,
> +       NET_FLOW_TABLE_FLOWS_MINPRIO,
> +       NET_FLOW_TABLE_FLOWS_MAXPRIO,
> +       NET_FLOW_TABLE_FLOWS_FLOWS,
> +       __NET_FLOW_TABLE_FLOWS_MAX,
> +};
> +#define NET_FLOW_TABLE_FLOWS_MAX (__NET_FLOW_TABLE_FLOWS_MAX - 1)
> +
> +enum {

NET_FLOW_FLOWS_ERROR_UNSPEC?

> +       /* Abort with normal errmsg */
> +       NET_FLOW_FLOWS_ERROR_ABORT,
> +       /* Ignore errors and continue without logging */
> +       NET_FLOW_FLOWS_ERROR_CONTINUE,
> +       /* Abort and reply with invalid flow fields */
> +       NET_FLOW_FLOWS_ERROR_ABORT_LOG,
> +       /* Continue and reply with list of invalid flows */
> +       NET_FLOW_FLOWS_ERROR_CONT_LOG,
> +       __NET_FLOWS_FLOWS_ERROR_MAX,
> +};
> +#define NET_FLOWS_FLOWS_ERROR_MAX (__NET_FLOWS_FLOWS_ERROR_MAX - 1)
> +
> +enum {
> +       NET_FLOW_ATTR_UNSPEC,
> +       NET_FLOW_ATTR_ERROR,
> +       NET_FLOW_ATTR_TABLE,
> +       NET_FLOW_ATTR_UID,
> +       NET_FLOW_ATTR_PRIORITY,
> +       NET_FLOW_ATTR_MATCHES,
> +       NET_FLOW_ATTR_ACTIONS,
> +       __NET_FLOW_ATTR_MAX,
> +};
> +#define NET_FLOW_ATTR_MAX (__NET_FLOW_ATTR_MAX - 1)
> +
> +enum {
>         NET_FLOW_IDENTIFIER_IFINDEX, /* net_device ifindex */
>  };
>
> @@ -343,6 +385,9 @@ enum {
>         NET_FLOW_HEADER_GRAPH,
>         NET_FLOW_TABLE_GRAPH,
>
> +       NET_FLOW_FLOWS,
> +       NET_FLOW_FLOWS_ERROR,
> +
>         __NET_FLOW_MAX,
>         NET_FLOW_MAX = (__NET_FLOW_MAX - 1),
>  };
> @@ -354,6 +399,10 @@ enum {
>         NET_FLOW_TABLE_CMD_GET_HDR_GRAPH,
>         NET_FLOW_TABLE_CMD_GET_TABLE_GRAPH,
>
> +       NET_FLOW_TABLE_CMD_GET_FLOWS,
> +       NET_FLOW_TABLE_CMD_SET_FLOWS,
> +       NET_FLOW_TABLE_CMD_DEL_FLOWS,
> +
>         __NET_FLOW_CMD_MAX,
>         NET_FLOW_CMD_MAX = (__NET_FLOW_CMD_MAX - 1),
>  };
> diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> index ec3f06d..f4cf293 100644
> --- a/net/core/flow_table.c
> +++ b/net/core/flow_table.c
> @@ -774,6 +774,489 @@ static int net_flow_cmd_get_table_graph(struct sk_buff *skb,
>         return genlmsg_reply(msg, info);
>  }
>
> +static struct sk_buff *net_flow_build_flows_msg(struct net_device *dev,
> +                                               u32 portid, int seq, u8 cmd,
> +                                               int min, int max, int table)
> +{
> +       struct genlmsghdr *hdr;
> +       struct nlattr *flows;
> +       struct sk_buff *skb;
> +       int err = -ENOBUFS;
> +
> +       skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);

Does netlink msg size limit the number of flows we can return?  If I
have 10K unique prefix routes, resulting in 10K flows in my L3 table,
all at same priority, can it be dumped?

I'm wondering (out loud) if get_flows is something that should be
supported at the driver level, or should it be managed above the
driver.  In other words, whoever calls set_flows and del_flows knows
what's what and could return get_flows rather than calling down to
driver/device to get_flows.  Unless driver/device could create flows
independent of set_flows and del_flows.

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
> +       flows = nla_nest_start(skb, NET_FLOW_FLOWS);
> +       if (!flows) {
> +               err = -EMSGSIZE;
> +               goto out;
> +       }
> +
> +       err = dev->netdev_ops->ndo_flow_get_flows(skb, dev, table, min, max);
> +       if (err < 0)
> +               goto out_cancel;
> +
> +       nla_nest_end(skb, flows);
> +
> +       err = genlmsg_end(skb, hdr);
> +       if (err < 0)
> +               goto out;
> +
> +       return skb;
> +out_cancel:
> +       nla_nest_cancel(skb, flows);
> +out:
> +       nlmsg_free(skb);
> +       return ERR_PTR(err);
> +}
> +
> +static const
> +struct nla_policy net_flow_table_flows_policy[NET_FLOW_TABLE_FLOWS_MAX + 1] = {
> +       [NET_FLOW_TABLE_FLOWS_TABLE]   = { .type = NLA_U32,},
> +       [NET_FLOW_TABLE_FLOWS_MINPRIO] = { .type = NLA_U32,},
> +       [NET_FLOW_TABLE_FLOWS_MAXPRIO] = { .type = NLA_U32,},
> +       [NET_FLOW_TABLE_FLOWS_FLOWS]   = { .type = NLA_NESTED,},
> +};
> +
> +static int net_flow_table_cmd_get_flows(struct sk_buff *skb,
> +                                       struct genl_info *info)
> +{
> +       struct nlattr *tb[NET_FLOW_TABLE_FLOWS_MAX+1];
> +       int table, min = -1, max = -1;
> +       struct net_device *dev;
> +       struct sk_buff *msg;
> +       int err = -EINVAL;
> +
> +       dev = net_flow_get_dev(info);
> +       if (!dev)
> +               return -EINVAL;
> +
> +       if (!dev->netdev_ops->ndo_flow_get_flows) {
> +               dev_put(dev);
> +               return -EOPNOTSUPP;
> +       }
> +
> +       if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
> +           !info->attrs[NET_FLOW_IDENTIFIER] ||
> +           !info->attrs[NET_FLOW_FLOWS])
> +               goto out;
> +
> +       err = nla_parse_nested(tb, NET_FLOW_TABLE_FLOWS_MAX,
> +                              info->attrs[NET_FLOW_FLOWS],
> +                              net_flow_table_flows_policy);
> +       if (err)
> +               goto out;
> +
> +       if (!tb[NET_FLOW_TABLE_FLOWS_TABLE])
> +               goto out;
> +
> +       table = nla_get_u32(tb[NET_FLOW_TABLE_FLOWS_TABLE]);
> +
> +       if (tb[NET_FLOW_TABLE_FLOWS_MINPRIO])
> +               min = nla_get_u32(tb[NET_FLOW_TABLE_FLOWS_MINPRIO]);
> +       if (tb[NET_FLOW_TABLE_FLOWS_MAXPRIO])
> +               max = nla_get_u32(tb[NET_FLOW_TABLE_FLOWS_MAXPRIO]);

Just curious, what is the intended use of min/max prio?  Was it to
reduce number of flows returned in one get_flows call?


> +       msg = net_flow_build_flows_msg(dev,
> +                                      info->snd_portid,
> +                                      info->snd_seq,
> +                                      NET_FLOW_TABLE_CMD_GET_FLOWS,
> +                                      min, max, table);
> +       dev_put(dev);
> +
> +       if (IS_ERR(msg))
> +               return PTR_ERR(msg);
> +
> +       return genlmsg_reply(msg, info);
> +out:
> +       dev_put(dev);
> +       return err;
> +}
> +
> +static struct sk_buff *net_flow_start_errmsg(struct net_device *dev,
> +                                            struct genlmsghdr **hdr,
> +                                            u32 portid, int seq, u8 cmd)
> +{
> +       struct genlmsghdr *h;
> +       struct sk_buff *skb;
> +
> +       skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +       if (!skb)
> +               return ERR_PTR(-EMSGSIZE);
> +
> +       h = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
> +       if (!h)
> +               return ERR_PTR(-EMSGSIZE);
> +
> +       if (nla_put_u32(skb,
> +                       NET_FLOW_IDENTIFIER_TYPE,
> +                       NET_FLOW_IDENTIFIER_IFINDEX) ||
> +           nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex))
> +               return ERR_PTR(-EMSGSIZE);
> +
> +       *hdr = h;
> +       return skb;
> +}
> +
> +static struct sk_buff *net_flow_end_flow_errmsg(struct sk_buff *skb,
> +                                               struct genlmsghdr *hdr)
> +{
> +       int err;
> +
> +       err = genlmsg_end(skb, hdr);
> +       if (err < 0) {
> +               nlmsg_free(skb);
> +               return ERR_PTR(err);
> +       }
> +
> +       return skb;
> +}
> +
> +static int net_flow_put_flow_action(struct sk_buff *skb,
> +                                   struct net_flow_action *a)
> +{
> +       struct nlattr *action, *sigs;
> +       int i, err = 0;
> +
> +       action = nla_nest_start(skb, NET_FLOW_ACTION);
> +       if (!action)
> +               return -EMSGSIZE;
> +
> +       if (nla_put_u32(skb, NET_FLOW_ACTION_ATTR_UID, a->uid))
> +               return -EMSGSIZE;
> +
> +       if (!a->args)
> +               goto done;
> +
> +       for (i = 0; a->args[i].type; i++) {
> +               sigs = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
> +               if (!sigs) {
> +                       nla_nest_cancel(skb, action);
> +                       return -EMSGSIZE;
> +               }
> +
> +               err = net_flow_put_act_types(skb, a[i].args);
> +               if (err) {
> +                       nla_nest_cancel(skb, action);
> +                       nla_nest_cancel(skb, sigs);

order seems backwards.  i think you can just cancel outer.

> +                       return err;
> +               }
> +               nla_nest_end(skb, sigs);
> +       }
> +
> +done:
> +       nla_nest_end(skb, action);
> +       return 0;
> +}
> +
> +int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
> +{
> +       struct nlattr *flows, *matches;
> +       struct nlattr *actions = NULL; /* must be null to unwind */
> +       int err, j, i = 0;
> +
> +       flows = nla_nest_start(skb, NET_FLOW_FLOW);
> +       if (!flows)
> +               goto put_failure;
> +
> +       if (nla_put_u32(skb, NET_FLOW_ATTR_TABLE, flow->table_id) ||
> +           nla_put_u32(skb, NET_FLOW_ATTR_UID, flow->uid) ||
> +           nla_put_u32(skb, NET_FLOW_ATTR_PRIORITY, flow->priority))
> +               goto flows_put_failure;
> +
> +       if (flow->matches) {
> +               matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
> +               if (!matches)
> +                       goto flows_put_failure;
> +
> +               for (j = 0; flow->matches && flow->matches[j].header; j++) {

for(match = flow->matches; match->header; match++)

> +                       struct net_flow_field_ref *f = &flow->matches[j];
> +
> +                       if (!f->header)
> +                               continue;

Already checked in for loop?

> +
> +                       nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);

no err check

> +               }
> +               nla_nest_end(skb, matches);
> +       }
> +
> +       if (flow->actions) {
> +               actions = nla_nest_start(skb, NET_FLOW_ATTR_ACTIONS);
> +               if (!actions)
> +                       goto flows_put_failure;
> +
> +               for (i = 0; flow->actions && flow->actions[i].uid; i++) {
> +                       err = net_flow_put_flow_action(skb, &flow->actions[i]);
> +                       if (err) {
> +                               nla_nest_cancel(skb, actions);

just cancel outer (I think)

> +                               goto flows_put_failure;
> +                       }
> +               }
> +               nla_nest_end(skb, actions);
> +       }
> +
> +       nla_nest_end(skb, flows);
> +       return 0;
> +
> +flows_put_failure:
> +       nla_nest_cancel(skb, flows);
> +put_failure:
> +       return -EMSGSIZE;
> +}
> +EXPORT_SYMBOL(net_flow_put_flow);
> +
> +static int net_flow_get_field(struct net_flow_field_ref *field,
> +                             struct nlattr *nla)
> +{
> +       if (nla_type(nla) != NET_FLOW_FIELD_REF)
> +               return -EINVAL;
> +
> +       if (nla_len(nla) < sizeof(*field))
> +               return -EINVAL;
> +
> +       *field = *(struct net_flow_field_ref *)nla_data(nla);
> +       return 0;
> +}

maybe return struct net_flow_field_ref * to simplify return logic.

> +
> +static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
> +{
> +       struct nlattr *act[NET_FLOW_ACTION_ATTR_MAX+1];
> +       struct nlattr *args;
> +       int rem;
> +       int err, count = 0;
> +
> +       if (nla_type(attr) != NET_FLOW_ACTION) {
> +               pr_warn("%s: expected NET_FLOW_ACTION\n", __func__);
> +               return 0;
> +       }
> +
> +       err = nla_parse_nested(act, NET_FLOW_ACTION_ATTR_MAX,
> +                              attr, net_flow_action_policy);
> +       if (err < 0)
> +               return err;
> +
> +       if (!act[NET_FLOW_ACTION_ATTR_UID] ||
> +           !act[NET_FLOW_ACTION_ATTR_SIGNATURE])
> +               return -EINVAL;
> +
> +       a->uid = nla_get_u32(act[NET_FLOW_ACTION_ATTR_UID]);
> +
> +       nla_for_each_nested(args, act[NET_FLOW_ACTION_ATTR_SIGNATURE], rem)
> +               count++; /* unoptimized max possible */
> +
> +       a->args = kcalloc(count + 1,
> +                         sizeof(struct net_flow_action_arg),
> +                         GFP_KERNEL);

kcalloc failure?

> +       count = 0;
> +
> +       nla_for_each_nested(args, act[NET_FLOW_ACTION_ATTR_SIGNATURE], rem) {
> +               if (nla_type(args) != NET_FLOW_ACTION_ARG)
> +                       continue;
> +
> +               if (nla_len(args) < sizeof(struct net_flow_action_arg)) {
> +                       kfree(a->args);
> +                       return -EINVAL;
> +               }
> +
> +               a->args[count] = *(struct net_flow_action_arg *)nla_data(args);

count++?
