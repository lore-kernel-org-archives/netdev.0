From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 05/11] net: rocker: add set flow rules
Date: Tue, 06 Jan 2015 07:31:25 -0800
Message-ID: <54ABFFCD.6010504@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194735.31070.55480.stgit@nitbit.x32> <CAE4R7bDvDOfr00=27xe=PKTGO_f9+SBu4j9x3-D_kCSbW9ND6w@mail.gmail.com>
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
Received: from mail-oi0-f44.google.com ([209.85.218.44]:47837 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbbAFPbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:31:39 -0500
Received: by mail-oi0-f44.google.com with SMTP id a141so18898334oig.3
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 07:31:38 -0800 (PST)
In-Reply-To: <CAE4R7bDvDOfr00=27xe=PKTGO_f9+SBu4j9x3-D_kCSbW9ND6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2015 11:23 PM, Scott Feldman wrote:
> On Wed, Dec 31, 2014 at 11:47 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> Implement set flow operations for existing rocker tables.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

[...]

>> +static int is_valid_net_flow_action(struct net_flow_action *a, int *actions)
>> +{
>> +       int i;
>> +
>> +       for (i = 0; actions[i]; i++) {
>> +               if (actions[i] == a->uid)
>> +                       return is_valid_net_flow_action_arg(a, a->uid);
>> +       }
>> +       return -EINVAL;
>> +}
>> +
>> +static int is_valid_net_flow_match(struct net_flow_field_ref *f,
>> +                                  struct net_flow_field_ref *fields)
>> +{
>> +       int i;
>> +
>> +       for (i = 0; fields[i].header; i++) {
>> +               if (f->header == fields[i].header &&
>> +                   f->field == fields[i].field)
>> +                       return 0;
>> +       }
>> +
>> +       return -EINVAL;
>> +}
>> +
>> +int is_valid_net_flow(struct net_flow_table *table, struct net_flow_flow *flow)
>> +{
>> +       struct net_flow_field_ref *fields = table->matches;
>> +       int *actions = table->actions;
>> +       int i, err;
>> +
>> +       for (i = 0; flow->actions[i].uid; i++) {
>> +               err = is_valid_net_flow_action(&flow->actions[i], actions);
>> +               if (err)
>> +                       return -EINVAL;
>> +       }
>> +
>> +       for (i = 0; flow->matches[i].header; i++) {
>> +               err = is_valid_net_flow_match(&flow->matches[i], fields);
>> +               if (err)
>> +                       return -EINVAL;
>> +       }
>> +
>> +       return 0;
>> +}
>
> All the above doesn't look rocker-specific...up-level?
>

Yes, already in the works for v2.

>> +
>> +static u32 rocker_goto_value(u32 id)
>> +{
>> +       switch (id) {
>> +       case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
>> +               return ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
>> +       case ROCKER_FLOW_TABLE_ID_VLAN:
>> +               return ROCKER_OF_DPA_TABLE_ID_VLAN;
>> +       case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
>> +               return ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
>> +       case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
>> +               return ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
>> +       case ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING:
>> +               return ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
>> +       case ROCKER_FLOW_TABLE_ID_BRIDGING:
>> +               return ROCKER_OF_DPA_TABLE_ID_BRIDGING;
>> +       case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
>> +               return ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
>> +       default:
>> +               return 0;
>> +       }
>> +}
>
> Could the OF-DPA table IDs be used in the flow table defs?  I think I
> remember your answer was no because OF-DPA uses INGRESS_PORT ID == 0,
> and 0 is a special value for if_flow tables.  Bummer.
>

A minor nuisance. I made table_id 0 a special delineating table.

>> +
>> +static int rocker_flow_set_ig_port(struct net_device *dev,
>> +                                  struct net_flow_flow *flow)
>> +{
>> +       struct rocker_port *rocker_port = netdev_priv(dev);
>> +       enum rocker_of_dpa_table_id goto_tbl;
>> +       u32 in_lport_mask = 0xffff0000;
>> +       u32 in_lport = 0;
>
> why initialize these two?

apparently a hold out from some code before I added the valid_net_flow()
check. I'll remove it.

>
>> +       int err, flags = 0;
>> +
>> +       err = is_valid_net_flow(&ingress_port_table, flow);
>> +       if (err)
>> +               return err;
>> +
>> +       /* ingress port table only supports one field/mask/action this
>> +        * simplifies the key construction and we can assume the values
>> +        * are the correct types/mask/action by valid check above. The
>> +        * user could pass multiple match/actions in a message with the
>> +        * same field multiple times currently the valid test does not
>> +        * catch this and we just use the first specified.
>> +        */
>> +       in_lport = flow->matches[0].value_u32;
>> +       in_lport_mask = flow->matches[0].mask_u32;
>> +       goto_tbl = rocker_goto_value(flow->actions[0].args[0].value_u16);
>> +
>> +       err = rocker_flow_tbl_ig_port(rocker_port, flags,
>> +                                     in_lport, in_lport_mask,
>> +                                     goto_tbl);
>> +       return err;
>> +}
>> +
>> +static int rocker_flow_set_vlan(struct net_device *dev,
>> +                               struct net_flow_flow *flow)
>> +{
>> +       enum rocker_of_dpa_table_id goto_tbl;
>> +       struct rocker_port *rocker_port = netdev_priv(dev);
>
> rocker style thing: put rocker_port decl first (sorry for being so pedantic).

no problem, making the change.

>
>> +       int i, err = 0, flags = 0;
>> +       u32 in_lport;
>> +       __be16 vlan_id, vlan_id_mask, new_vlan_id;
>> +       bool untagged, have_in_lport = false;
>> +
>> +       err = is_valid_net_flow(&vlan_table, flow);
>> +       if (err)
>> +               return err;
>> +
>> +       goto_tbl = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
>> +
>> +       /* If user does not specify vid match default to any */
>> +       vlan_id = 1;
>
> htons()?
>
> Not sure.  Rocker convention is vlan_id is network-order, but some
> places you'll see vid and that's host-order.
>

Yep this is needed.

>> +       vlan_id_mask = 0;
>> +
>> +       for (i = 0; flow->matches && flow->matches[i].instance; i++) {
>> +               switch (flow->matches[i].instance) {
>> +               case HEADER_INSTANCE_IN_LPORT:
>> +                       in_lport = flow->matches[i].value_u32;
>> +                       have_in_lport = true;
>> +                       break;
>> +               case HEADER_INSTANCE_VLAN_OUTER:
>> +                       if (flow->matches[i].field != HEADER_VLAN_VID)
>> +                               break;
>> +
>> +                       vlan_id = htons(flow->matches[i].value_u16);
>> +                       vlan_id_mask = htons(flow->matches[i].mask_u16);
>> +                       break;
>> +               default:
>> +                       return -EINVAL;
>> +               }
>> +       }
>> +
>> +       /* If user does not specify a new vlan id use default vlan id */
>> +       new_vlan_id = rocker_port_vid_to_vlan(rocker_port, vlan_id, &untagged);
>> +
>> +       for (i = 0; flow->actions && flow->actions[i].uid; i++) {
>> +               struct net_flow_action_arg *arg = &flow->actions[i].args[0];
>> +
>> +               switch (flow->actions[i].uid) {
>> +               case ACTION_SET_GOTO_TABLE:
>> +                       goto_tbl = rocker_goto_value(arg->value_u16);
>> +                       break;
>> +               case ACTION_SET_VLAN_ID:
>> +                       new_vlan_id = htons(arg->value_u16);
>> +                       if (new_vlan_id)
>> +                               untagged = false;
>> +                       break;
>> +               }
>> +       }
>> +
>> +       if (!have_in_lport)
>> +               return -EINVAL;
>
> This can be moved up, before second for loop
>

done.

>> +
>> +       err = rocker_flow_tbl_vlan(rocker_port, flags, in_lport,
>> +                                  vlan_id, vlan_id_mask, goto_tbl,
>> +                                  untagged, new_vlan_id);
>> +       return err;
>> +}
>> +
>> +static int rocker_flow_set_term_mac(struct net_device *dev,
>> +                                   struct net_flow_flow *flow)
>> +{
>> +       struct rocker_port *rocker_port = netdev_priv(dev);
>> +       __be16 vlan_id, vlan_id_mask, ethtype = 0;
>> +       const u8 *eth_dst, *eth_dst_mask;
>> +       u32 in_lport, in_lport_mask;
>> +       int i, err = 0, flags = 0;
>> +       bool copy_to_cpu;
>> +
>> +       eth_dst = NULL;
>> +       eth_dst_mask = NULL;
>> +
>
> Needed?

nope same as above hold out from an older variant of valid_net_flow().

>
>> +       err = is_valid_net_flow(&term_mac_table, flow);
>> +       if (err)
>> +               return err;
>> +
>> +       /* If user does not specify vid match default to any */
>> +       vlan_id = rocker_port->internal_vlan_id;
>> +       vlan_id_mask = 0;
>> +

[...]

>>
>>   static const struct net_device_ops rocker_port_netdev_ops = {
>> @@ -3828,6 +4342,9 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>>          .ndo_flow_get_actions           = rocker_get_actions,
>>          .ndo_flow_get_tbl_graph         = rocker_get_tgraph,
>>          .ndo_flow_get_hdr_graph         = rocker_get_hgraph,
>> +
>> +       .ndo_flow_set_flows             = rocker_set_flows,
>> +       .ndo_flow_del_flows             = rocker_del_flows,
>>   #endif
>>   };
>
> Looks good overall to me

good to hear.

>
>> diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
>> index 9544339..701e139 100644
>> --- a/drivers/net/ethernet/rocker/rocker_pipeline.h
>> +++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
>> @@ -527,6 +527,7 @@ enum rocker_flow_table_id_space {
>>          ROCKER_FLOW_TABLE_ID_VLAN,
>>          ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
>>          ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
>> +       ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING,
>>          ROCKER_FLOW_TABLE_ID_BRIDGING,
>>          ROCKER_FLOW_TABLE_ID_ACL_POLICY,
>>          ROCKER_FLOW_TABLE_NULL = 0,
>> @@ -588,7 +589,7 @@ struct net_flow_table acl_table = {
>>
>>   struct net_flow_table null_table = {
>>          .name = "",
>> -       .uid = 0,
>> +       .uid = ROCKER_FLOW_TABLE_NULL,
>>          .source = 0,
>>          .size = 0,
>>          .matches = NULL,
>>
>
> Move these changes to previous patch?
>

yep will do.

Thanks!
John


-- 
John Fastabend         Intel Corporation
