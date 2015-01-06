From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next PATCH v1 04/11] rocker: add pipeline model for rocker switch
Date: Mon, 5 Jan 2015 23:01:46 -0800
Message-ID: <CAE4R7bB6-bKh6EaZXpsXQeLx5A=MCJTCadYQoP2K5cUfOEUiEw@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194709.31070.16657.stgit@nitbit.x32>
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
Received: from mail-wi0-f173.google.com ([209.85.212.173]:61596 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbbAFHBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 02:01:47 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so4736582wiv.6
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 23:01:46 -0800 (PST)
In-Reply-To: <20141231194709.31070.16657.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 11:47 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This adds rocker support for the net_flow_get_* operations. With this
> we can interrogate rocker.
>
> Here we see that for static configurations enabling the get operations
> is simply a matter of defining a pipeline model and returning the
> structures for the core infrastructure to encapsulate into netlink
> messages.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c          |   35 +
>  drivers/net/ethernet/rocker/rocker_pipeline.h |  673 +++++++++++++++++++++++++
>  2 files changed, 708 insertions(+)
>  create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index fded127..4c6787a 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -36,6 +36,7 @@
>  #include <generated/utsrelease.h>
>
>  #include "rocker.h"
> +#include "rocker_pipeline.h"
>
>  static const char rocker_driver_name[] = "rocker";
>
> @@ -3780,6 +3781,33 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
>         return rocker_port_stp_update(rocker_port, state);
>  }
>
> +#ifdef CONFIG_NET_FLOW_TABLES

Can this #ifdef test be moved out of driver?  The if_flow core code
can stub out operations if CONFIG_NET_FLOW_TABLES isn't defined.

> +static struct net_flow_table **rocker_get_tables(struct net_device *d)
> +{
> +       return rocker_table_list;
> +}
> +
> +static struct net_flow_header **rocker_get_headers(struct net_device *d)
> +{
> +       return rocker_header_list;
> +}
> +
> +static struct net_flow_action **rocker_get_actions(struct net_device *d)
> +{
> +       return rocker_action_list;
> +}
> +
> +static struct net_flow_tbl_node **rocker_get_tgraph(struct net_device *d)
> +{
> +       return rocker_table_nodes;
> +}
> +
> +static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
> +{
> +       return rocker_header_nodes;
> +}
> +#endif
> +
>  static const struct net_device_ops rocker_port_netdev_ops = {
>         .ndo_open                       = rocker_port_open,
>         .ndo_stop                       = rocker_port_stop,
> @@ -3794,6 +3822,13 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>         .ndo_bridge_getlink             = rocker_port_bridge_getlink,
>         .ndo_switch_parent_id_get       = rocker_port_switch_parent_id_get,
>         .ndo_switch_port_stp_update     = rocker_port_switch_port_stp_update,
> +#ifdef CONFIG_NET_FLOW_TABLES

same comment here

> +       .ndo_flow_get_tables            = rocker_get_tables,
> +       .ndo_flow_get_headers           = rocker_get_headers,
> +       .ndo_flow_get_actions           = rocker_get_actions,
> +       .ndo_flow_get_tbl_graph         = rocker_get_tgraph,
> +       .ndo_flow_get_hdr_graph         = rocker_get_hgraph,
> +#endif
>  };
>
>  /********************
> diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
> new file mode 100644
> index 0000000..9544339
> --- /dev/null
> +++ b/drivers/net/ethernet/rocker/rocker_pipeline.h

Add standard header info...copyright/license.

> @@ -0,0 +1,673 @@
> +#ifndef _MY_PIPELINE_H_
> +#define _MY_PIPELINE_H_

_ROCKER_PIPELINE_H_

> +
> +#include <linux/if_flow.h>
> +
> +/* header definition */
> +#define HEADER_ETHERNET_SRC_MAC 1
> +#define HEADER_ETHERNET_DST_MAC 2
> +#define HEADER_ETHERNET_ETHERTYPE 3

Use enum?

> +struct net_flow_field ethernet_fields[3] = {

ethernet_fields[] = ...   // let compiler size it

> +       { .name = "src_mac", .uid = HEADER_ETHERNET_SRC_MAC, .bitwidth = 48},
> +       { .name = "dst_mac", .uid = HEADER_ETHERNET_DST_MAC, .bitwidth = 48},
> +       { .name = "ethertype",
> +         .uid = HEADER_ETHERNET_ETHERTYPE,
> +         .bitwidth = 16},
> +};
> +
> +#define HEADER_ETHERNET 1
> +struct net_flow_header ethernet = {
> +       .name = "ethernet",
> +       .uid = HEADER_ETHERNET,
> +       .field_sz = 3,

ARRAY_SIZE()?

> +       .fields = ethernet_fields,
> +};
> +
> +#define HEADER_VLAN_PCP 1
> +#define HEADER_VLAN_CFI 2
> +#define HEADER_VLAN_VID 3
> +#define HEADER_VLAN_ETHERTYPE 4
> +struct net_flow_field vlan_fields[4] = {

[] = ...

> +       { .name = "pcp", .uid = HEADER_VLAN_PCP, .bitwidth = 3,},
> +       { .name = "cfi", .uid = HEADER_VLAN_CFI, .bitwidth = 1,},
> +       { .name = "vid", .uid = HEADER_VLAN_VID, .bitwidth = 12,},
> +       { .name = "ethertype", .uid = HEADER_VLAN_ETHERTYPE, .bitwidth = 16,},
> +};
> +
> +#define HEADER_VLAN 2
> +struct net_flow_header vlan = {
> +       .name = "vlan",
> +       .uid = HEADER_VLAN,
> +       .field_sz = 4,

ARRAY_SIZE()

> +       .fields = vlan_fields,
> +};
> +
> +#define HEADER_IPV4_VERSION 1
> +#define HEADER_IPV4_IHL 2
> +#define HEADER_IPV4_DSCP 3
> +#define HEADER_IPV4_ECN 4
> +#define HEADER_IPV4_LENGTH 5
> +#define HEADER_IPV4_IDENTIFICATION 6
> +#define HEADER_IPV4_FLAGS 7
> +#define HEADER_IPV4_FRAGMENT_OFFSET 8
> +#define HEADER_IPV4_TTL 9
> +#define HEADER_IPV4_PROTOCOL 10
> +#define HEADER_IPV4_CSUM 11
> +#define HEADER_IPV4_SRC_IP 12
> +#define HEADER_IPV4_DST_IP 13
> +#define HEADER_IPV4_OPTIONS 14
> +struct net_flow_field ipv4_fields[14] = {
> +       { .name = "version",
> +         .uid = HEADER_IPV4_VERSION,
> +         .bitwidth = 4,},
> +       { .name = "ihl",
> +         .uid = HEADER_IPV4_IHL,
> +         .bitwidth = 4,},
> +       { .name = "dscp",
> +         .uid = HEADER_IPV4_DSCP,
> +         .bitwidth = 6,},
> +       { .name = "ecn",
> +         .uid = HEADER_IPV4_ECN,
> +         .bitwidth = 2,},
> +       { .name = "length",
> +         .uid = HEADER_IPV4_LENGTH,
> +         .bitwidth = 8,},
> +       { .name = "identification",
> +         .uid = HEADER_IPV4_IDENTIFICATION,
> +         .bitwidth = 8,},
> +       { .name = "flags",
> +         .uid = HEADER_IPV4_FLAGS,
> +         .bitwidth = 3,},
> +       { .name = "fragment_offset",
> +         .uid = HEADER_IPV4_FRAGMENT_OFFSET,
> +         .bitwidth = 13,},
> +       { .name = "ttl",
> +         .uid = HEADER_IPV4_TTL,
> +         .bitwidth = 1,},
> +       { .name = "protocol",
> +         .uid = HEADER_IPV4_PROTOCOL,
> +         .bitwidth = 8,},
> +       { .name = "csum",
> +         .uid = HEADER_IPV4_CSUM,
> +         .bitwidth = 8,},
> +       { .name = "src_ip",
> +         .uid = HEADER_IPV4_SRC_IP,
> +         .bitwidth = 32,},
> +       { .name = "dst_ip",
> +         .uid = HEADER_IPV4_DST_IP,
> +         .bitwidth = 32,},
> +       { .name = "options",
> +         .uid = HEADER_IPV4_OPTIONS,
> +         .bitwidth = -1,},
> +};
> +
> +#define HEADER_IPV4 3
> +struct net_flow_header ipv4 = {
> +       .name = "ipv4",
> +       .uid = HEADER_IPV4,
> +       .field_sz = 14,
> +       .fields = ipv4_fields,
> +};
> +
> +#define HEADER_METADATA_IN_LPORT 1
> +#define HEADER_METADATA_GOTO_TBL 2
> +#define HEADER_METADATA_GROUP_ID 3
> +struct net_flow_field metadata_fields[3] = {
> +       { .name = "in_lport",
> +         .uid = HEADER_METADATA_IN_LPORT,
> +         .bitwidth = 32,},
> +       { .name = "goto_tbl",
> +         .uid = HEADER_METADATA_GOTO_TBL,
> +         .bitwidth = 16,},
> +       { .name = "group_id",
> +         .uid = HEADER_METADATA_GROUP_ID,
> +         .bitwidth = 32,},
> +};
> +
> +#define HEADER_METADATA 4
> +struct net_flow_header metadata_t = {
> +       .name = "metadata_t",
> +       .uid = HEADER_METADATA,
> +       .field_sz = 3,
> +       .fields = metadata_fields,
> +};
> +
> +struct net_flow_header null_hdr = {.name = "",
> +                                  .uid = 0,
> +                                  .field_sz = 0,
> +                                  .fields = NULL};
> +
> +struct net_flow_header *rocker_header_list[8] = {

[] = ...

Not sure where the [8] comes from

> +       &ethernet,
> +       &vlan,
> +       &ipv4,
> +       &metadata_t,
> +       &null_hdr,

Seems just setting last entry to NULL would be cleaner:

struct foo *foo[] = {
    &one,
    &two,
    &three,
    NULL,
};

> +};
> +
> +/* action definitions */
> +struct net_flow_action_arg null_args[1] = {
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +struct net_flow_action null_action = {
> +       .name = "", .uid = 0, .args = NULL,
> +};
> +
> +struct net_flow_action_arg set_goto_table_args[2] = {
> +       {
> +               .name = "table",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U16,
> +               .value_u16 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_GOTO_TABLE 1
> +struct net_flow_action set_goto_table = {
> +       .name = "set_goto_table",
> +       .uid = ACTION_SET_GOTO_TABLE,
> +       .args = set_goto_table_args,
> +};
> +
> +struct net_flow_action_arg set_vlan_id_args[2] = {
> +       {
> +               .name = "vlan_id",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U16,
> +               .value_u16 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_VLAN_ID 2
> +struct net_flow_action set_vlan_id = {
> +       .name = "set_vlan_id",
> +       .uid = ACTION_SET_VLAN_ID,
> +       .args = set_vlan_id_args,
> +};
> +
> +/* TBD: what is the untagged bool about in vlan table */
> +#define ACTION_COPY_TO_CPU 3
> +struct net_flow_action copy_to_cpu = {
> +       .name = "copy_to_cpu",
> +       .uid = ACTION_COPY_TO_CPU,
> +       .args = null_args,
> +};
> +
> +struct net_flow_action_arg set_group_id_args[2] = {
> +       {
> +               .name = "group_id",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U32,
> +               .value_u32 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_GROUP_ID 4
> +struct net_flow_action set_group_id = {
> +       .name = "set_group_id",
> +       .uid = ACTION_SET_GROUP_ID,
> +       .args = set_group_id_args,
> +};
> +
> +#define ACTION_POP_VLAN 5
> +struct net_flow_action pop_vlan = {
> +       .name = "pop_vlan",
> +       .uid = ACTION_POP_VLAN,
> +       .args = null_args,
> +};
> +
> +struct net_flow_action_arg set_eth_src_args[2] = {
> +       {
> +               .name = "eth_src",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U64,
> +               .value_u64 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_ETH_SRC 6
> +struct net_flow_action set_eth_src = {
> +       .name = "set_eth_src",
> +       .uid = ACTION_SET_ETH_SRC,
> +       .args = set_eth_src_args,
> +};
> +
> +struct net_flow_action_arg set_eth_dst_args[2] = {
> +       {
> +               .name = "eth_dst",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U64,
> +               .value_u64 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_ETH_DST 7
> +struct net_flow_action set_eth_dst = {
> +       .name = "set_eth_dst",
> +       .uid = ACTION_SET_ETH_DST,
> +       .args = set_eth_dst_args,
> +};
> +
> +struct net_flow_action_arg set_out_port_args[2] = {
> +       {
> +               .name = "set_out_port",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_U32,
> +               .value_u32 = 0,
> +       },
> +       {
> +               .name = "",
> +               .type = NET_FLOW_ACTION_ARG_TYPE_NULL,
> +       },
> +};
> +
> +#define ACTION_SET_OUT_PORT 8
> +struct net_flow_action set_out_port = {
> +       .name = "set_out_port",
> +       .uid = ACTION_SET_OUT_PORT,
> +       .args = set_out_port_args,
> +};
> +
> +struct net_flow_action *rocker_action_list[8] = {
> +       &set_goto_table,
> +       &set_vlan_id,
> +       &copy_to_cpu,
> +       &set_group_id,
> +       &pop_vlan,
> +       &set_eth_src,
> +       &set_eth_dst,
> +       &null_action,
> +};
> +
> +/* headers graph */
> +#define HEADER_INSTANCE_ETHERNET 1
> +#define HEADER_INSTANCE_VLAN_OUTER 2
> +#define HEADER_INSTANCE_IPV4 3
> +#define HEADER_INSTANCE_IN_LPORT 4
> +#define HEADER_INSTANCE_GOTO_TABLE 5
> +#define HEADER_INSTANCE_GROUP_ID 6
> +
> +struct net_flow_jump_table parse_ethernet[3] = {
> +       {
> +               .field = {
> +                  .header = HEADER_ETHERNET,
> +                  .field = HEADER_ETHERNET_ETHERTYPE,
> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
> +                  .value_u16 = 0x0800,

How is htons/ntohs conversions happening here?

Since these are network header fields, seems you want htons(0x0800).

> +               },
> +               .node = HEADER_INSTANCE_IPV4,
> +       },
> +       {
> +               .field = {
> +                  .header = HEADER_ETHERNET,
> +                  .field = HEADER_ETHERNET_ETHERTYPE,
> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
> +                  .value_u16 = 0x8100,
> +               },
> +               .node = HEADER_INSTANCE_VLAN_OUTER,
> +       },
> +       {
> +               .field = {0},
> +               .node = 0,
> +       },

just use NULL,

> +};
> +
> +int ethernet_headers[2] = {HEADER_ETHERNET, 0};
> +
> +struct net_flow_hdr_node ethernet_header_node = {
> +       .name = "ethernet",
> +       .uid = HEADER_INSTANCE_ETHERNET,
> +       .hdrs = ethernet_headers,
> +       .jump = parse_ethernet,
> +};
> +
> +struct net_flow_jump_table parse_vlan[2] = {
> +       {
> +               .field = {
> +                  .header = HEADER_VLAN,
> +                  .field = HEADER_VLAN_ETHERTYPE,
> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
> +                  .value_u16 = 0x0800,
> +               },
> +               .node = HEADER_INSTANCE_IPV4,
> +       },
> +       {
> +               .field = {0},
> +               .node = 0,
> +       },
> +};
> +
> +int vlan_headers[2] = {HEADER_VLAN, 0};
> +struct net_flow_hdr_node vlan_header_node = {
> +       .name = "vlan",
> +       .uid = HEADER_INSTANCE_VLAN_OUTER,
> +       .hdrs = vlan_headers,
> +       .jump = parse_vlan,
> +};
> +
> +struct net_flow_jump_table terminal_headers[2] = {
> +       {
> +               .field = {0},
> +               .node = NET_FLOW_JUMP_TABLE_DONE,
> +       },
> +       {
> +               .field = {0},
> +               .node = 0,
> +       },
> +};
> +
> +int ipv4_headers[2] = {HEADER_IPV4, 0};
> +struct net_flow_hdr_node ipv4_header_node = {
> +       .name = "ipv4",
> +       .uid = HEADER_INSTANCE_IPV4,
> +       .hdrs = ipv4_headers,
> +       .jump = terminal_headers,
> +};
> +
> +int metadata_headers[2] = {HEADER_METADATA, 0};
> +struct net_flow_hdr_node in_lport_header_node = {
> +       .name = "in_lport",
> +       .uid = HEADER_INSTANCE_IN_LPORT,
> +       .hdrs = metadata_headers,
> +       .jump = terminal_headers,
> +};
> +
> +struct net_flow_hdr_node goto_table_header_node = {
> +       .name = "goto_table",
> +       .uid = HEADER_INSTANCE_GOTO_TABLE,
> +       .hdrs = metadata_headers,
> +       .jump = terminal_headers,
> +};
> +
> +struct net_flow_hdr_node group_id_header_node = {
> +       .name = "group_id",
> +       .uid = HEADER_INSTANCE_GROUP_ID,
> +       .hdrs = metadata_headers,
> +       .jump = terminal_headers,
> +};
> +
> +struct net_flow_hdr_node null_header = {.name = "", .uid = 0,};
> +
> +struct net_flow_hdr_node *rocker_header_nodes[7] = {
> +       &ethernet_header_node,
> +       &vlan_header_node,
> +       &ipv4_header_node,
> +       &in_lport_header_node,
> +       &goto_table_header_node,
> +       &group_id_header_node,
> +       &null_header,
> +};
> +
> +/* table definition */
> +struct net_flow_field_ref matches_ig_port[2] = {
> +       { .instance = HEADER_INSTANCE_IN_LPORT,
> +         .header = HEADER_METADATA,
> +         .field = HEADER_METADATA_IN_LPORT,
> +         .mask_type = NET_FLOW_MASK_TYPE_LPM},

Need other mask type, not LPM.


> +struct net_flow_table *rocker_table_list[7] = {
> +       &ingress_port_table,
> +       &vlan_table,
> +       &term_mac_table,
> +       &ucast_routing_table,
> +       &bridge_table,
> +       &acl_table,
> +       &null_table,
> +};

cool stuff

> +
> +/* Define the table graph layout */
> +struct net_flow_jump_table table_node_ig_port_next[2] = {
> +       { .field = {0}, .node = ROCKER_FLOW_TABLE_ID_VLAN},
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_ingress_port = {
> +       .uid = ROCKER_FLOW_TABLE_ID_INGRESS_PORT,
> +       .jump = table_node_ig_port_next};
> +
> +struct net_flow_jump_table table_node_vlan_next[2] = {
> +       { .field = {0}, .node = ROCKER_FLOW_TABLE_ID_TERMINATION_MAC},
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_vlan = {
> +       .uid = ROCKER_FLOW_TABLE_ID_VLAN,
> +       .jump = table_node_vlan_next};
> +
> +struct net_flow_jump_table table_node_term_mac_next[2] = {
> +       { .field = {0}, .node = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING},
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_term_mac = {
> +       .uid = ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
> +       .jump = table_node_term_mac_next};
> +
> +struct net_flow_jump_table table_node_bridge_next[2] = {
> +       { .field = {0}, .node = ROCKER_FLOW_TABLE_ID_ACL_POLICY},
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_bridge = {
> +       .uid = ROCKER_FLOW_TABLE_ID_BRIDGING,
> +       .jump = table_node_bridge_next};
> +
> +struct net_flow_jump_table table_node_ucast_routing_next[2] = {
> +       { .field = {0}, .node = ROCKER_FLOW_TABLE_ID_ACL_POLICY},
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_ucast_routing = {
> +       .uid = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
> +       .jump = table_node_ucast_routing_next};
> +
> +struct net_flow_jump_table table_node_acl_next[1] = {
> +       { .field = {0}, .node = 0},
> +};
> +
> +struct net_flow_tbl_node table_node_acl = {
> +       .uid = ROCKER_FLOW_TABLE_ID_ACL_POLICY,
> +       .jump = table_node_acl_next};
> +
> +struct net_flow_tbl_node table_node_nil = {.uid = 0, .jump = NULL};
> +
> +struct net_flow_tbl_node *rocker_table_nodes[7] = {
> +       &table_node_ingress_port,
> +       &table_node_vlan,
> +       &table_node_term_mac,
> +       &table_node_ucast_routing,
> +       &table_node_bridge,
> +       &table_node_acl,
> +       &table_node_nil,
> +};

Cool...getting tired but will review this again in v2

> +#endif /*_MY_PIPELINE_H*/

ROCKER

>
