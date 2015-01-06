From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 04/11] rocker: add pipeline model for rocker
 switch
Date: Tue, 06 Jan 2015 09:00:10 -0800
Message-ID: <54AC149A.6040401@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194709.31070.16657.stgit@nitbit.x32> <CAE4R7bB6-bKh6EaZXpsXQeLx5A=MCJTCadYQoP2K5cUfOEUiEw@mail.gmail.com>
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
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36446 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbbAFRAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:00:24 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so66579721obc.0
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 09:00:24 -0800 (PST)
In-Reply-To: <CAE4R7bB6-bKh6EaZXpsXQeLx5A=MCJTCadYQoP2K5cUfOEUiEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2015 11:01 PM, Scott Feldman wrote:
> On Wed, Dec 31, 2014 at 11:47 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> This adds rocker support for the net_flow_get_* operations. With this
>> we can interrogate rocker.
>>
>> Here we see that for static configurations enabling the get operations
>> is simply a matter of defining a pipeline model and returning the
>> structures for the core infrastructure to encapsulate into netlink
>> messages.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   drivers/net/ethernet/rocker/rocker.c          |   35 +
>>   drivers/net/ethernet/rocker/rocker_pipeline.h |  673 +++++++++++++++++++++++++
>>   2 files changed, 708 insertions(+)
>>   create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..4c6787a 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -36,6 +36,7 @@
>>   #include <generated/utsrelease.h>
>>
>>   #include "rocker.h"
>> +#include "rocker_pipeline.h"
>>
>>   static const char rocker_driver_name[] = "rocker";
>>
>> @@ -3780,6 +3781,33 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
>>          return rocker_port_stp_update(rocker_port, state);
>>   }
>>
>> +#ifdef CONFIG_NET_FLOW_TABLES
>
> Can this #ifdef test be moved out of driver?  The if_flow core code
> can stub out operations if CONFIG_NET_FLOW_TABLES isn't defined.

here sure this is easy enough.

>
>> +static struct net_flow_table **rocker_get_tables(struct net_device *d)
>> +{
>> +       return rocker_table_list;
>> +}
>> +
>> +static struct net_flow_header **rocker_get_headers(struct net_device *d)
>> +{
>> +       return rocker_header_list;
>> +}
>> +
>> +static struct net_flow_action **rocker_get_actions(struct net_device *d)
>> +{
>> +       return rocker_action_list;
>> +}
>> +
>> +static struct net_flow_tbl_node **rocker_get_tgraph(struct net_device *d)
>> +{
>> +       return rocker_table_nodes;
>> +}
>> +
>> +static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
>> +{
>> +       return rocker_header_nodes;
>> +}
>> +#endif
>> +
>>   static const struct net_device_ops rocker_port_netdev_ops = {
>>          .ndo_open                       = rocker_port_open,
>>          .ndo_stop                       = rocker_port_stop,
>> @@ -3794,6 +3822,13 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>>          .ndo_bridge_getlink             = rocker_port_bridge_getlink,
>>          .ndo_switch_parent_id_get       = rocker_port_switch_parent_id_get,
>>          .ndo_switch_port_stp_update     = rocker_port_switch_port_stp_update,
>> +#ifdef CONFIG_NET_FLOW_TABLES
>
> same comment here

We could although then we need some 'depends on' logic in Kconfig
to be sure CONFIG_NET_FLOW_TABLES is enabled. I think we want to
be able to strip this code out of the main core code paths when
its not needed which means wrapping it in the ifdef in netdevice.h

>
>> +       .ndo_flow_get_tables            = rocker_get_tables,
>> +       .ndo_flow_get_headers           = rocker_get_headers,
>> +       .ndo_flow_get_actions           = rocker_get_actions,
>> +       .ndo_flow_get_tbl_graph         = rocker_get_tgraph,
>> +       .ndo_flow_get_hdr_graph         = rocker_get_hgraph,
>> +#endif
>>   };
>>
>>   /********************
>> diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
>> new file mode 100644
>> index 0000000..9544339
>> --- /dev/null
>> +++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
>
> Add standard header info...copyright/license.
>
>> @@ -0,0 +1,673 @@
>> +#ifndef _MY_PIPELINE_H_
>> +#define _MY_PIPELINE_H_
>
> _ROCKER_PIPELINE_H_
>
>> +
>> +#include <linux/if_flow.h>
>> +
>> +/* header definition */
>> +#define HEADER_ETHERNET_SRC_MAC 1
>> +#define HEADER_ETHERNET_DST_MAC 2
>> +#define HEADER_ETHERNET_ETHERTYPE 3
>
> Use enum?
>

yep changed this all to enums, array_size macros and use a
simpler null terminator throughout. Thanks.

[...]

>> +/* headers graph */
>> +#define HEADER_INSTANCE_ETHERNET 1
>> +#define HEADER_INSTANCE_VLAN_OUTER 2
>> +#define HEADER_INSTANCE_IPV4 3
>> +#define HEADER_INSTANCE_IN_LPORT 4
>> +#define HEADER_INSTANCE_GOTO_TABLE 5
>> +#define HEADER_INSTANCE_GROUP_ID 6
>> +
>> +struct net_flow_jump_table parse_ethernet[3] = {
>> +       {
>> +               .field = {
>> +                  .header = HEADER_ETHERNET,
>> +                  .field = HEADER_ETHERNET_ETHERTYPE,
>> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
>> +                  .value_u16 = 0x0800,
>
> How is htons/ntohs conversions happening here?

my current stance is to leave everything in host order in the model
and let the drivers do conversions as needed. For example some drivers
want the vlan vid in host order others network order. I think its
more readable above then with hton*() throughout.

>
> Since these are network header fields, seems you want htons(0x0800).
>
>> +               },
>> +               .node = HEADER_INSTANCE_IPV4,
>> +       },
>> +       {
>> +               .field = {
>> +                  .header = HEADER_ETHERNET,
>> +                  .field = HEADER_ETHERNET_ETHERTYPE,
>> +                  .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
>> +                  .value_u16 = 0x8100,
>> +               },
>> +               .node = HEADER_INSTANCE_VLAN_OUTER,
>> +       },
>> +       {
>> +               .field = {0},
>> +               .node = 0,
>> +       },
>
> just use NULL,

Yep done throughout.

[...]

>> +/* table definition */
>> +struct net_flow_field_ref matches_ig_port[2] = {
>> +       { .instance = HEADER_INSTANCE_IN_LPORT,
>> +         .header = HEADER_METADATA,
>> +         .field = HEADER_METADATA_IN_LPORT,
>> +         .mask_type = NET_FLOW_MASK_TYPE_LPM},
>
> Need other mask type, not LPM.

v2 will have the additional mask types.

>
>
>> +struct net_flow_table *rocker_table_list[7] = {
>> +       &ingress_port_table,
>> +       &vlan_table,
>> +       &term_mac_table,
>> +       &ucast_routing_table,
>> +       &bridge_table,
>> +       &acl_table,
>> +       &null_table,
>> +};
>
> cool stuff

bit of work to get here but sort of fun to start defining
pipelines like this.

[...]

>> +struct net_flow_tbl_node *rocker_table_nodes[7] = {
>> +       &table_node_ingress_port,
>> +       &table_node_vlan,
>> +       &table_node_term_mac,
>> +       &table_node_ucast_routing,
>> +       &table_node_bridge,
>> +       &table_node_acl,
>> +       &table_node_nil,
>> +};
>
> Cool...getting tired but will review this again in v2

Great thanks for the detailed feedback.

>
>> +#endif /*_MY_PIPELINE_H*/
>
> ROCKER
>
>>


-- 
John Fastabend         Intel Corporation
