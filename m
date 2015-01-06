From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 05/11] net: rocker: add set flow rules
Date: Mon, 5 Jan 2015 23:23:33 -0800
Message-ID: <CAE4R7bDvDOfr00=27xe=PKTGO_f9+SBu4j9x3-D_kCSbW9ND6w@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194735.31070.55480.stgit@nitbit.x32>
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
Received: from mail-wi0-f171.google.com ([209.85.212.171]:53262 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbAFHbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 02:31:01 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so4768800wib.4
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 23:31:00 -0800 (PST)
In-Reply-To: <20141231194735.31070.55480.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:47 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> Implement set flow operations for existing rocker tables.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c          |  517 +++++++++++++++++++++++++
>  drivers/net/ethernet/rocker/rocker_pipeline.h |    3
>  2 files changed, 519 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 4c6787a..c40c58d 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3806,6 +3806,520 @@ static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
>  {
>         return rocker_header_nodes;
>  }
> +
> +static int is_valid_net_flow_action_arg(struct net_flow_action *a, int id)
> +{
> +       struct net_flow_action_arg *args = a->args;
> +       int i;
> +
> +       for (i = 0; args[i].type != NET_FLOW_ACTION_ARG_TYPE_NULL; i++) {
> +               if (a->args[i].type == NET_FLOW_ACTION_ARG_TYPE_NULL ||
> +                   args[i].type != a->args[i].type)
> +                       return -EINVAL;
> +       }
> +
> +       return 0;
> +}
> +
> +static int is_valid_net_flow_action(struct net_flow_action *a, int *actions)
> +{
> +       int i;
> +
> +       for (i = 0; actions[i]; i++) {
> +               if (actions[i] == a->uid)
> +                       return is_valid_net_flow_action_arg(a, a->uid);
> +       }
> +       return -EINVAL;
> +}
> +
> +static int is_valid_net_flow_match(struct net_flow_field_ref *f,
> +                                  struct net_flow_field_ref *fields)
> +{
> +       int i;
> +
> +       for (i = 0; fields[i].header; i++) {
> +               if (f->header == fields[i].header &&
> +                   f->field == fields[i].field)
> +                       return 0;
> +       }
> +
> +       return -EINVAL;
> +}
> +
> +int is_valid_net_flow(struct net_flow_table *table, struct net_flow_flow *flow)
> +{
> +       struct net_flow_field_ref *fields = table->matches;
> +       int *actions = table->actions;
> +       int i, err;
> +
> +       for (i = 0; flow->actions[i].uid; i++) {
> +               err = is_valid_net_flow_action(&flow->actions[i], actions);
> +               if (err)
> +                       return -EINVAL;
> +       }
> +
> +       for (i = 0; flow->matches[i].header; i++) {
> +               err = is_valid_net_flow_match(&flow->matches[i], fields);
> +               if (err)
> +                       return -EINVAL;
> +       }
> +
> +       return 0;
> +}

All the above doesn't look rocker-specific...up-level?

> +
> +static u32 rocker_goto_value(u32 id)
> +{
> +       switch (id) {
> +       case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
> +               return ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
> +       case ROCKER_FLOW_TABLE_ID_VLAN:
> +               return ROCKER_OF_DPA_TABLE_ID_VLAN;
> +       case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
> +               return ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
> +       case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
> +               return ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
> +       case ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING:
> +               return ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
> +       case ROCKER_FLOW_TABLE_ID_BRIDGING:
> +               return ROCKER_OF_DPA_TABLE_ID_BRIDGING;
> +       case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
> +               return ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
> +       default:
> +               return 0;
> +       }
> +}

Could the OF-DPA table IDs be used in the flow table defs?  I think I
remember your answer was no because OF-DPA uses INGRESS_PORT ID == 0,
and 0 is a special value for if_flow tables.  Bummer.

> +
> +static int rocker_flow_set_ig_port(struct net_device *dev,
> +                                  struct net_flow_flow *flow)
> +{
> +       struct rocker_port *rocker_port = netdev_priv(dev);
> +       enum rocker_of_dpa_table_id goto_tbl;
> +       u32 in_lport_mask = 0xffff0000;
> +       u32 in_lport = 0;

why initialize these two?

> +       int err, flags = 0;
> +
> +       err = is_valid_net_flow(&ingress_port_table, flow);
> +       if (err)
> +               return err;
> +
> +       /* ingress port table only supports one field/mask/action this
> +        * simplifies the key construction and we can assume the values
> +        * are the correct types/mask/action by valid check above. The
> +        * user could pass multiple match/actions in a message with the
> +        * same field multiple times currently the valid test does not
> +        * catch this and we just use the first specified.
> +        */
> +       in_lport = flow->matches[0].value_u32;
> +       in_lport_mask = flow->matches[0].mask_u32;
> +       goto_tbl = rocker_goto_value(flow->actions[0].args[0].value_u16);
> +
> +       err = rocker_flow_tbl_ig_port(rocker_port, flags,
> +                                     in_lport, in_lport_mask,
> +                                     goto_tbl);
> +       return err;
> +}
> +
> +static int rocker_flow_set_vlan(struct net_device *dev,
> +                               struct net_flow_flow *flow)
> +{
> +       enum rocker_of_dpa_table_id goto_tbl;
> +       struct rocker_port *rocker_port = netdev_priv(dev);

rocker style thing: put rocker_port decl first (sorry for being so pedantic).

> +       int i, err = 0, flags = 0;
> +       u32 in_lport;
> +       __be16 vlan_id, vlan_id_mask, new_vlan_id;
> +       bool untagged, have_in_lport = false;
> +
> +       err = is_valid_net_flow(&vlan_table, flow);
> +       if (err)
> +               return err;
> +
> +       goto_tbl = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
> +
> +       /* If user does not specify vid match default to any */
> +       vlan_id = 1;

htons()?

Not sure.  Rocker convention is vlan_id is network-order, but some
places you'll see vid and that's host-order.

> +       vlan_id_mask = 0;
> +
> +       for (i = 0; flow->matches && flow->matches[i].instance; i++) {
> +               switch (flow->matches[i].instance) {
> +               case HEADER_INSTANCE_IN_LPORT:
> +                       in_lport = flow->matches[i].value_u32;
> +                       have_in_lport = true;
> +                       break;
> +               case HEADER_INSTANCE_VLAN_OUTER:
> +                       if (flow->matches[i].field != HEADER_VLAN_VID)
> +                               break;
> +
> +                       vlan_id = htons(flow->matches[i].value_u16);
> +                       vlan_id_mask = htons(flow->matches[i].mask_u16);
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       /* If user does not specify a new vlan id use default vlan id */
> +       new_vlan_id = rocker_port_vid_to_vlan(rocker_port, vlan_id, &untagged);
> +
> +       for (i = 0; flow->actions && flow->actions[i].uid; i++) {
> +               struct net_flow_action_arg *arg = &flow->actions[i].args[0];
> +
> +               switch (flow->actions[i].uid) {
> +               case ACTION_SET_GOTO_TABLE:
> +                       goto_tbl = rocker_goto_value(arg->value_u16);
> +                       break;
> +               case ACTION_SET_VLAN_ID:
> +                       new_vlan_id = htons(arg->value_u16);
> +                       if (new_vlan_id)
> +                               untagged = false;
> +                       break;
> +               }
> +       }
> +
> +       if (!have_in_lport)
> +               return -EINVAL;

This can be moved up, before second for loop

> +
> +       err = rocker_flow_tbl_vlan(rocker_port, flags, in_lport,
> +                                  vlan_id, vlan_id_mask, goto_tbl,
> +                                  untagged, new_vlan_id);
> +       return err;
> +}
> +
> +static int rocker_flow_set_term_mac(struct net_device *dev,
> +                                   struct net_flow_flow *flow)
> +{
> +       struct rocker_port *rocker_port = netdev_priv(dev);
> +       __be16 vlan_id, vlan_id_mask, ethtype = 0;
> +       const u8 *eth_dst, *eth_dst_mask;
> +       u32 in_lport, in_lport_mask;
> +       int i, err = 0, flags = 0;
> +       bool copy_to_cpu;
> +
> +       eth_dst = NULL;
> +       eth_dst_mask = NULL;
> +

Needed?

> +       err = is_valid_net_flow(&term_mac_table, flow);
> +       if (err)
> +               return err;
> +
> +       /* If user does not specify vid match default to any */
> +       vlan_id = rocker_port->internal_vlan_id;
> +       vlan_id_mask = 0;
> +
> +       /* If user does not specify in_lport match default to any */
> +       in_lport = rocker_port->lport;
> +       in_lport_mask = 0;
> +
> +       /* If user does not specify a mac address match any */
> +       eth_dst = rocker_port->dev->dev_addr;
> +       eth_dst_mask = zero_mac;
> +
> +       for (i = 0; flow->matches && flow->matches[i].instance; i++) {
> +               switch (flow->matches[i].instance) {
> +               case HEADER_INSTANCE_IN_LPORT:
> +                       in_lport = flow->matches[i].value_u32;
> +                       in_lport_mask = flow->matches[i].mask_u32;
> +                       break;
> +               case HEADER_INSTANCE_VLAN_OUTER:
> +                       if (flow->matches[i].field != HEADER_VLAN_VID)
> +                               break;
> +
> +                       vlan_id = htons(flow->matches[i].value_u16);
> +                       vlan_id_mask = htons(flow->matches[i].mask_u16);
> +                       break;
> +               case HEADER_INSTANCE_ETHERNET:
> +                       switch (flow->matches[i].field) {
> +                       case HEADER_ETHERNET_DST_MAC:
> +                               eth_dst = (u8 *)&flow->matches[i].value_u64;
> +                               eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
> +                               break;
> +                       case HEADER_ETHERNET_ETHERTYPE:
> +                               ethtype = htons(flow->matches[i].value_u16);
> +                               break;
> +                       default:
> +                               return -EINVAL;
> +                       }
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       if (!ethtype)
> +               return -EINVAL;
> +
> +       /* By default do not copy to cpu */
> +       copy_to_cpu = false;
> +
> +       for (i = 0; flow->actions && flow->actions[i].uid; i++) {
> +               switch (flow->actions[i].uid) {
> +               case ACTION_COPY_TO_CPU:
> +                       copy_to_cpu = true;
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       err = rocker_flow_tbl_term_mac(rocker_port, in_lport, in_lport_mask,
> +                                      ethtype, eth_dst, eth_dst_mask,
> +                                      vlan_id, vlan_id_mask,
> +                                      copy_to_cpu, flags);
> +       return err;
> +}
> +
> +static int rocker_flow_set_ucast_routing(struct net_device *dev,
> +                                        struct net_flow_flow *flow)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static int rocker_flow_set_mcast_routing(struct net_device *dev,
> +                                        struct net_flow_flow *flow)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static int rocker_flow_set_bridge(struct net_device *dev,
> +                                 struct net_flow_flow *flow)
> +{
> +       enum rocker_of_dpa_table_id goto_tbl;
> +       struct rocker_port *rocker_port = netdev_priv(dev);
> +       u32 in_lport, in_lport_mask, group_id, tunnel_id;
> +       __be16 vlan_id, vlan_id_mask;
> +       const u8 *eth_dst, *eth_dst_mask;
> +       int i, err = 0, flags = 0;
> +       bool copy_to_cpu;
> +
> +       err = is_valid_net_flow(&bridge_table, flow);
> +       if (err)
> +               return err;
> +
> +       goto_tbl = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
> +
> +       /* If user does not specify vid match default to any */
> +       vlan_id = rocker_port->internal_vlan_id;
> +       vlan_id_mask = 0;
> +
> +       /* If user does not specify in_lport match default to any */
> +       in_lport = rocker_port->lport;
> +       in_lport_mask = 0;
> +
> +       /* If user does not specify a mac address match any */
> +       eth_dst = rocker_port->dev->dev_addr;
> +       eth_dst_mask = NULL;
> +
> +       /* Do not support for tunnel_id yet. */
> +       tunnel_id = 0;
> +
> +       for (i = 0; flow->matches && flow->matches[i].instance; i++) {
> +               switch (flow->matches[i].instance) {
> +               case HEADER_INSTANCE_IN_LPORT:
> +                       in_lport = flow->matches[i].value_u32;
> +                       in_lport_mask = flow->matches[i].mask_u32;
> +                       break;
> +               case HEADER_INSTANCE_VLAN_OUTER:
> +                       if (flow->matches[i].field != HEADER_VLAN_VID)
> +                               break;
> +
> +                       vlan_id = htons(flow->matches[i].value_u16);
> +                       vlan_id_mask = htons(flow->matches[i].mask_u16);
> +                       break;
> +               case HEADER_INSTANCE_ETHERNET:
> +                       switch (flow->matches[i].field) {
> +                       case HEADER_ETHERNET_DST_MAC:
> +                               eth_dst = (u8 *)&flow->matches[i].value_u64;
> +                               eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
> +                               break;
> +                       default:
> +                               return -EINVAL;
> +                       }
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       /* By default do not copy to cpu and skip group assignment */
> +       copy_to_cpu = false;
> +       group_id = ROCKER_GROUP_NONE;
> +
> +       for (i = 0; flow->actions && flow->actions[i].uid; i++) {
> +               struct net_flow_action_arg *arg = &flow->actions[i].args[0];
> +
> +               switch (flow->actions[i].uid) {
> +               case ACTION_SET_GOTO_TABLE:
> +                       goto_tbl = rocker_goto_value(arg->value_u16);
> +                       break;
> +               case ACTION_COPY_TO_CPU:
> +                       copy_to_cpu = true;
> +                       break;
> +               case ACTION_SET_GROUP_ID:
> +                       group_id = arg->value_u32;
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       /* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
> +       err = rocker_flow_tbl_bridge(rocker_port, flags,
> +                                    eth_dst, eth_dst_mask,
> +                                    vlan_id, tunnel_id,
> +                                    goto_tbl, group_id, copy_to_cpu);
> +       return err;
> +}
> +
> +static int rocker_flow_set_acl(struct net_device *dev,
> +                              struct net_flow_flow *flow)
> +{
> +       struct rocker_port *rocker_port = netdev_priv(dev);
> +       u32 in_lport, in_lport_mask, group_id, tunnel_id;
> +       __be16 vlan_id, vlan_id_mask, ethtype = 0;
> +       const u8 *eth_dst, *eth_src, *eth_dst_mask, *eth_src_mask;
> +       u8 protocol, protocol_mask, dscp, dscp_mask;
> +       int i, err = 0, flags = 0;
> +
> +       err = is_valid_net_flow(&bridge_table, flow);
> +       if (err)
> +               return err;
> +
> +       /* If user does not specify vid match default to any */
> +       vlan_id = rocker_port->internal_vlan_id;
> +       vlan_id_mask = 0;
> +
> +       /* If user does not specify in_lport match default to any */
> +       in_lport = rocker_port->lport;
> +       in_lport_mask = 0;
> +
> +       /* If user does not specify a mac address match any */
> +       eth_dst = rocker_port->dev->dev_addr;
> +       eth_src = zero_mac;
> +       eth_dst_mask = NULL;
> +       eth_src_mask = NULL;
> +
> +       /* If user does not set protocol/dscp mask them out */
> +       protocol = 0;
> +       dscp = 0;
> +       protocol_mask = 0;
> +       dscp_mask = 0;
> +
> +       /* Do not support for tunnel_id yet. */
> +       tunnel_id = 0;
> +
> +       for (i = 0; flow->matches && flow->matches[i].instance; i++) {
> +               switch (flow->matches[i].instance) {
> +               case HEADER_INSTANCE_IN_LPORT:
> +                       in_lport = flow->matches[i].value_u32;
> +                       in_lport_mask = flow->matches[i].mask_u32;
> +                       break;
> +               case HEADER_INSTANCE_VLAN_OUTER:
> +                       if (flow->matches[i].field != HEADER_VLAN_VID)
> +                               break;
> +
> +                       vlan_id = htons(flow->matches[i].value_u16);
> +                       vlan_id_mask = htons(flow->matches[i].mask_u16);
> +                       break;
> +               case HEADER_INSTANCE_ETHERNET:
> +                       switch (flow->matches[i].field) {
> +                       case HEADER_ETHERNET_SRC_MAC:
> +                               eth_src = (u8 *)&flow->matches[i].value_u64;
> +                               eth_src_mask = (u8 *)&flow->matches[i].mask_u64;
> +                               break;
> +                       case HEADER_ETHERNET_DST_MAC:
> +                               eth_dst = (u8 *)&flow->matches[i].value_u64;
> +                               eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
> +                               break;
> +                       case HEADER_ETHERNET_ETHERTYPE:
> +                               ethtype = htons(flow->matches[i].value_u16);
> +                               break;
> +                       default:
> +                               return -EINVAL;
> +                       }
> +                       break;
> +               case HEADER_INSTANCE_IPV4:
> +                       switch (flow->matches[i].field) {
> +                       case HEADER_IPV4_PROTOCOL:
> +                               protocol = flow->matches[i].value_u8;
> +                               protocol_mask = flow->matches[i].mask_u8;
> +                               break;
> +                       case HEADER_IPV4_DSCP:
> +                               dscp = flow->matches[i].value_u8;
> +                               dscp_mask = flow->matches[i].mask_u8;
> +                               break;
> +                       default:
> +                               return -EINVAL;
> +                       }
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       /* By default do not copy to cpu and skip group assignment */
> +       group_id = ROCKER_GROUP_NONE;
> +
> +       for (i = 0; flow->actions && flow->actions[i].uid; i++) {
> +               switch (flow->actions[i].uid) {
> +               case ACTION_SET_GROUP_ID:
> +                       group_id = flow->actions[i].args[0].value_u32;
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       err = rocker_flow_tbl_acl(rocker_port, flags,
> +                                 in_lport, in_lport_mask,
> +                                 eth_src, eth_src_mask,
> +                                 eth_dst, eth_dst_mask, ethtype,
> +                                 vlan_id, vlan_id_mask,
> +                                 protocol, protocol_mask,
> +                                 dscp, dscp_mask,
> +                                 group_id);
> +       return err;
> +}
> +
> +static int rocker_set_flows(struct net_device *dev,
> +                           struct net_flow_flow *flow)
> +{
> +       int err = -EINVAL;
> +
> +       if (!flow->matches || !flow->actions)
> +               return -EINVAL;
> +
> +       switch (flow->table_id) {
> +       case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
> +               err = rocker_flow_set_ig_port(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_VLAN:
> +               err = rocker_flow_set_vlan(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
> +               err = rocker_flow_set_term_mac(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
> +               err = rocker_flow_set_ucast_routing(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING:
> +               err = rocker_flow_set_mcast_routing(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_BRIDGING:
> +               err = rocker_flow_set_bridge(dev, flow);
> +               break;
> +       case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
> +               err = rocker_flow_set_acl(dev, flow);
> +               break;
> +       default:
> +               break;
> +       }
> +
> +       return err;
> +}
> +
> +static int rocker_del_flows(struct net_device *dev,
> +                           struct net_flow_flow *flow)
> +{
> +       return -EOPNOTSUPP;
> +}
>  #endif
>
>  static const struct net_device_ops rocker_port_netdev_ops = {
> @@ -3828,6 +4342,9 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>         .ndo_flow_get_actions           = rocker_get_actions,
>         .ndo_flow_get_tbl_graph         = rocker_get_tgraph,
>         .ndo_flow_get_hdr_graph         = rocker_get_hgraph,
> +
> +       .ndo_flow_set_flows             = rocker_set_flows,
> +       .ndo_flow_del_flows             = rocker_del_flows,
>  #endif
>  };

Looks good overall to me

> diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
> index 9544339..701e139 100644
> --- a/drivers/net/ethernet/rocker/rocker_pipeline.h
> +++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
> @@ -527,6 +527,7 @@ enum rocker_flow_table_id_space {
>         ROCKER_FLOW_TABLE_ID_VLAN,
>         ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
>         ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
> +       ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING,
>         ROCKER_FLOW_TABLE_ID_BRIDGING,
>         ROCKER_FLOW_TABLE_ID_ACL_POLICY,
>         ROCKER_FLOW_TABLE_NULL = 0,
> @@ -588,7 +589,7 @@ struct net_flow_table acl_table = {
>
>  struct net_flow_table null_table = {
>         .name = "",
> -       .uid = 0,
> +       .uid = ROCKER_FLOW_TABLE_NULL,
>         .source = 0,
>         .size = 0,
>         .matches = NULL,
>

Move these changes to previous patch?
