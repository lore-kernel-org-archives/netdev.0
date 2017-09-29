From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH v3 7/7] i40e: Enable cloud filters via tc-flower
Date: Fri, 29 Sep 2017 08:20:35 +0200
Message-ID: <20170929062035.GB1867@nanopsycho>
References: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
 <150529679050.57063.3956015681929450874.stgit@anamdev.jf.intel.com>
 <20170913132611.GC1981@nanopsycho>
 <82e0a065-c7d6-8fe6-aedc-154dd0dd88d6@intel.com>
 <dd18a4bd-f2fc-002b-2ef9-01de9a5a4162@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        mlxsw@mellanox.com,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36776 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdI2GUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 02:20:39 -0400
Received: by mail-wr0-f195.google.com with SMTP id k10so380708wrk.3
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 23:20:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <dd18a4bd-f2fc-002b-2ef9-01de9a5a4162@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 28, 2017 at 09:22:15PM CEST, amritha.nambiar@intel.com wrote:
>On 9/14/2017 1:00 AM, Nambiar, Amritha wrote:
>> On 9/13/2017 6:26 AM, Jiri Pirko wrote:
>>> Wed, Sep 13, 2017 at 11:59:50AM CEST, amritha.nambiar@intel.com wrote:
>>>> This patch enables tc-flower based hardware offloads. tc flower
>>>> filter provided by the kernel is configured as driver specific
>>>> cloud filter. The patch implements functions and admin queue
>>>> commands needed to support cloud filters in the driver and
>>>> adds cloud filters to configure these tc-flower filters.
>>>>
>>>> The only action supported is to redirect packets to a traffic class
>>>> on the same device.
>>>
>>> So basically you are not doing redirect, you are just setting tclass for
>>> matched packets, right? Why you use mirred for this? I think that
>>> you might consider extending g_act for that:
>>>
>>> # tc filter add dev eth0 protocol ip ingress \
>>>   prio 1 flower dst_mac 3c:fd:fe:a0:d6:70 skip_sw \
>>>   action tclass 0
>>>
>> Yes, this doesn't work like a typical egress redirect, but is aimed at
>> forwarding the matched packets to a different queue-group/traffic class
>> on the same device, so some sort-of ingress redirect in the hardware. I
>> possibly may not need the mirred-redirect as you say, I'll look into the
>> g_act way of doing this with a new gact tc action.
>> 
>
>I was looking at introducing a new gact tclass action to TC. In the HW
>offload path, this sets a traffic class value for certain matched
>packets so they will be processed in a queue belonging to the traffic class.
>
># tc filter add dev eth0 protocol ip parent ffff:\
>  prio 2 flower dst_ip 192.168.3.5/32\
>  ip_proto udp dst_port 25 skip_sw\
>  action tclass 2
>
>But, I'm having trouble defining what this action means in the kernel
>datapath. For ingress, this action could just take the default path and
>do nothing and only have meaning in the HW offloaded path. For egress,

Sounds ok.


>certain qdiscs like 'multiq' and 'prio' could use this 'tclass' value
>for band selection, while the 'mqprio' qdisc selects the traffic class
>based on the skb priority in netdev_pick_tx(), so what would this action
>mean for the 'mqprio' qdisc?

I don't see why this action would have any special meaning for specific
qdiscs. The qdiscs have already mechanisms for band mapping. I don't see
why to mix it up with tclass action.

Also, you can use tclass action on qdisc clsact egress to do band
mapping. That would be symmetrical with ingress.


>
>It looks like the 'prio' qdisc uses band selection based on the
>'classid', so I was thinking of using the 'classid' through the cls
>flower filter and offload it to HW for the traffic class index, this way
>we would have the same behavior in HW offload and SW fallback and there
>would be no need for a separate tc action.
>
>In HW:
># tc filter add dev eth0 protocol ip parent ffff:\
>  prio 2 flower dst_ip 192.168.3.5/32\
>  ip_proto udp dst_port 25 skip_sw classid 1:2\
>
>filter pref 2 flower chain 0
>filter pref 2 flower chain 0 handle 0x1 classid 1:2
>  eth_type ipv4
>  ip_proto udp
>  dst_ip 192.168.3.5
>  dst_port 25
>  skip_sw
>  in_hw
>
>This will be used to route packets to traffic class 2.
>
>In SW:
># tc filter add dev eth0 protocol ip parent ffff:\
>  prio 2 flower dst_ip 192.168.3.5/32\
>  ip_proto udp dst_port 25 skip_hw classid 1:2
>
>filter pref 2 flower chain 0
>filter pref 2 flower chain 0 handle 0x1 classid 1:2
>  eth_type ipv4
>  ip_proto udp
>  dst_ip 192.168.3.5
>  dst_port 25
>  skip_hw
>  not_in_hw
>
>>>
>>>>
>>>> # tc qdisc add dev eth0 ingress
>>>> # ethtool -K eth0 hw-tc-offload on
>>>>
>>>> # tc filter add dev eth0 protocol ip parent ffff:\
>>>>  prio 1 flower dst_mac 3c:fd:fe:a0:d6:70 skip_sw\
>>>>  action mirred ingress redirect dev eth0 tclass 0
>>>>
>>>> # tc filter add dev eth0 protocol ip parent ffff:\
>>>>  prio 2 flower dst_ip 192.168.3.5/32\
>>>>  ip_proto udp dst_port 25 skip_sw\
>>>>  action mirred ingress redirect dev eth0 tclass 1
>>>>
>>>> # tc filter add dev eth0 protocol ipv6 parent ffff:\
>>>>  prio 3 flower dst_ip fe8::200:1\
>>>>  ip_proto udp dst_port 66 skip_sw\
>>>>  action mirred ingress redirect dev eth0 tclass 1
>>>>
>>>> Delete tc flower filter:
>>>> Example:
>>>>
>>>> # tc filter del dev eth0 parent ffff: prio 3 handle 0x1 flower
>>>> # tc filter del dev eth0 parent ffff:
>>>>
>>>> Flow Director Sideband is disabled while configuring cloud filters
>>>> via tc-flower and until any cloud filter exists.
>>>>
>>>> Unsupported matches when cloud filters are added using enhanced
>>>> big buffer cloud filter mode of underlying switch include:
>>>> 1. source port and source IP
>>>> 2. Combined MAC address and IP fields.
>>>> 3. Not specifying L4 port
>>>>
>>>> These filter matches can however be used to redirect traffic to
>>>> the main VSI (tc 0) which does not require the enhanced big buffer
>>>> cloud filter support.
>>>>
>>>> v3: Cleaned up some lengthy function names. Changed ipv6 address to
>>>> __be32 array instead of u8 array. Used macro for IP version. Minor
>>>> formatting changes.
>>>> v2:
>>>> 1. Moved I40E_SWITCH_MODE_MASK definition to i40e_type.h
>>>> 2. Moved dev_info for add/deleting cloud filters in else condition
>>>> 3. Fixed some format specifier in dev_err logs
>>>> 4. Refactored i40e_get_capabilities to take an additional
>>>>   list_type parameter and use it to query device and function
>>>>   level capabilities.
>>>> 5. Fixed parsing tc redirect action to check for the is_tcf_mirred_tc()
>>>>   to verify if redirect to a traffic class is supported.
>>>> 6. Added comments for Geneve fix in cloud filter big buffer AQ
>>>>   function definitions.
>>>> 7. Cleaned up setup_tc interface to rebase and work with Jiri's
>>>>   updates, separate function to process tc cls flower offloads.
>>>> 8. Changes to make Flow Director Sideband and Cloud filters mutually
>>>>   exclusive.
>>>>
>>>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
>>>> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
>>>> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
>>>> Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
>>>> ---
>>>> drivers/net/ethernet/intel/i40e/i40e.h             |   49 +
>>>> drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |    3 
>>>> drivers/net/ethernet/intel/i40e/i40e_common.c      |  189 ++++
>>>> drivers/net/ethernet/intel/i40e/i40e_main.c        |  971 +++++++++++++++++++-
>>>> drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   16 
>>>> drivers/net/ethernet/intel/i40e/i40e_type.h        |    1 
>>>> .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |    3 
>>>> 7 files changed, 1202 insertions(+), 30 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
>>>> index 6018fb6..b110519 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e.h
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
>>>> @@ -55,6 +55,8 @@
>>>> #include <linux/net_tstamp.h>
>>>> #include <linux/ptp_clock_kernel.h>
>>>> #include <net/pkt_cls.h>
>>>> +#include <net/tc_act/tc_gact.h>
>>>> +#include <net/tc_act/tc_mirred.h>
>>>> #include "i40e_type.h"
>>>> #include "i40e_prototype.h"
>>>> #include "i40e_client.h"
>>>> @@ -252,9 +254,52 @@ struct i40e_fdir_filter {
>>>> 	u32 fd_id;
>>>> };
>>>>
>>>> +#define IPV4_VERSION 4
>>>> +#define IPV6_VERSION 6
>>>> +
>>>> +#define I40E_CLOUD_FIELD_OMAC	0x01
>>>> +#define I40E_CLOUD_FIELD_IMAC	0x02
>>>> +#define I40E_CLOUD_FIELD_IVLAN	0x04
>>>> +#define I40E_CLOUD_FIELD_TEN_ID	0x08
>>>> +#define I40E_CLOUD_FIELD_IIP	0x10
>>>> +
>>>> +#define I40E_CLOUD_FILTER_FLAGS_OMAC	I40E_CLOUD_FIELD_OMAC
>>>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC	I40E_CLOUD_FIELD_IMAC
>>>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN	(I40E_CLOUD_FIELD_IMAC | \
>>>> +						 I40E_CLOUD_FIELD_IVLAN)
>>>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_TEN_ID	(I40E_CLOUD_FIELD_IMAC | \
>>>> +						 I40E_CLOUD_FIELD_TEN_ID)
>>>> +#define I40E_CLOUD_FILTER_FLAGS_OMAC_TEN_ID_IMAC (I40E_CLOUD_FIELD_OMAC | \
>>>> +						  I40E_CLOUD_FIELD_IMAC | \
>>>> +						  I40E_CLOUD_FIELD_TEN_ID)
>>>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN_TEN_ID (I40E_CLOUD_FIELD_IMAC | \
>>>> +						   I40E_CLOUD_FIELD_IVLAN | \
>>>> +						   I40E_CLOUD_FIELD_TEN_ID)
>>>> +#define I40E_CLOUD_FILTER_FLAGS_IIP	I40E_CLOUD_FIELD_IIP
>>>> +
>>>> struct i40e_cloud_filter {
>>>> 	struct hlist_node cloud_node;
>>>> 	unsigned long cookie;
>>>> +	/* cloud filter input set follows */
>>>> +	u8 dst_mac[ETH_ALEN];
>>>> +	u8 src_mac[ETH_ALEN];
>>>> +	__be16 vlan_id;
>>>> +	__be32 dst_ip;
>>>> +	__be32 src_ip;
>>>> +	__be32 dst_ipv6[4];
>>>> +	__be32 src_ipv6[4];
>>>> +	__be16 dst_port;
>>>> +	__be16 src_port;
>>>> +	u32 ip_version;
>>>> +	u8 ip_proto;	/* IPPROTO value */
>>>> +	/* L4 port type: src or destination port */
>>>> +#define I40E_CLOUD_FILTER_PORT_SRC	0x01
>>>> +#define I40E_CLOUD_FILTER_PORT_DEST	0x02
>>>> +	u8 port_type;
>>>> +	u32 tenant_id;
>>>> +	u8 flags;
>>>> +#define I40E_CLOUD_TNL_TYPE_NONE	0xff
>>>> +	u8 tunnel_type;
>>>> 	u16 seid;	/* filter control */
>>>> };
>>>>
>>>> @@ -491,6 +536,8 @@ struct i40e_pf {
>>>> #define I40E_FLAG_LINK_DOWN_ON_CLOSE_ENABLED	BIT(27)
>>>> #define I40E_FLAG_SOURCE_PRUNING_DISABLED	BIT(28)
>>>> #define I40E_FLAG_TC_MQPRIO			BIT(29)
>>>> +#define I40E_FLAG_FD_SB_INACTIVE		BIT(30)
>>>> +#define I40E_FLAG_FD_SB_TO_CLOUD_FILTER		BIT(31)
>>>>
>>>> 	struct i40e_client_instance *cinst;
>>>> 	bool stat_offsets_loaded;
>>>> @@ -573,6 +620,8 @@ struct i40e_pf {
>>>> 	u16 phy_led_val;
>>>>
>>>> 	u16 override_q_count;
>>>> +	u16 last_sw_conf_flags;
>>>> +	u16 last_sw_conf_valid_flags;
>>>> };
>>>>
>>>> /**
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
>>>> index 2e567c2..feb3d42 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
>>>> @@ -1392,6 +1392,9 @@ struct i40e_aqc_cloud_filters_element_data {
>>>> 		struct {
>>>> 			u8 data[16];
>>>> 		} v6;
>>>> +		struct {
>>>> +			__le16 data[8];
>>>> +		} raw_v6;
>>>> 	} ipaddr;
>>>> 	__le16	flags;
>>>> #define I40E_AQC_ADD_CLOUD_FILTER_SHIFT			0
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
>>>> index 9567702..d9c9665 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
>>>> @@ -5434,5 +5434,194 @@ i40e_add_pinfo_to_list(struct i40e_hw *hw,
>>>>
>>>> 	status = i40e_aq_write_ppp(hw, (void *)sec, sec->data_end,
>>>> 				   track_id, &offset, &info, NULL);
>>>> +
>>>> +	return status;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_aq_add_cloud_filters
>>>> + * @hw: pointer to the hardware structure
>>>> + * @seid: VSI seid to add cloud filters from
>>>> + * @filters: Buffer which contains the filters to be added
>>>> + * @filter_count: number of filters contained in the buffer
>>>> + *
>>>> + * Set the cloud filters for a given VSI.  The contents of the
>>>> + * i40e_aqc_cloud_filters_element_data are filled in by the caller
>>>> + * of the function.
>>>> + *
>>>> + **/
>>>> +enum i40e_status_code
>>>> +i40e_aq_add_cloud_filters(struct i40e_hw *hw, u16 seid,
>>>> +			  struct i40e_aqc_cloud_filters_element_data *filters,
>>>> +			  u8 filter_count)
>>>> +{
>>>> +	struct i40e_aq_desc desc;
>>>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>>>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>>>> +	enum i40e_status_code status;
>>>> +	u16 buff_len;
>>>> +
>>>> +	i40e_fill_default_direct_cmd_desc(&desc,
>>>> +					  i40e_aqc_opc_add_cloud_filters);
>>>> +
>>>> +	buff_len = filter_count * sizeof(*filters);
>>>> +	desc.datalen = cpu_to_le16(buff_len);
>>>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>>>> +	cmd->num_filters = filter_count;
>>>> +	cmd->seid = cpu_to_le16(seid);
>>>> +
>>>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>>>> +
>>>> +	return status;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_aq_add_cloud_filters_bb
>>>> + * @hw: pointer to the hardware structure
>>>> + * @seid: VSI seid to add cloud filters from
>>>> + * @filters: Buffer which contains the filters in big buffer to be added
>>>> + * @filter_count: number of filters contained in the buffer
>>>> + *
>>>> + * Set the big buffer cloud filters for a given VSI.  The contents of the
>>>> + * i40e_aqc_cloud_filters_element_bb are filled in by the caller of the
>>>> + * function.
>>>> + *
>>>> + **/
>>>> +i40e_status
>>>> +i40e_aq_add_cloud_filters_bb(struct i40e_hw *hw, u16 seid,
>>>> +			     struct i40e_aqc_cloud_filters_element_bb *filters,
>>>> +			     u8 filter_count)
>>>> +{
>>>> +	struct i40e_aq_desc desc;
>>>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>>>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>>>> +	i40e_status status;
>>>> +	u16 buff_len;
>>>> +	int i;
>>>> +
>>>> +	i40e_fill_default_direct_cmd_desc(&desc,
>>>> +					  i40e_aqc_opc_add_cloud_filters);
>>>> +
>>>> +	buff_len = filter_count * sizeof(*filters);
>>>> +	desc.datalen = cpu_to_le16(buff_len);
>>>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>>>> +	cmd->num_filters = filter_count;
>>>> +	cmd->seid = cpu_to_le16(seid);
>>>> +	cmd->big_buffer_flag = I40E_AQC_ADD_CLOUD_CMD_BB;
>>>> +
>>>> +	for (i = 0; i < filter_count; i++) {
>>>> +		u16 tnl_type;
>>>> +		u32 ti;
>>>> +
>>>> +		tnl_type = (le16_to_cpu(filters[i].element.flags) &
>>>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK) >>
>>>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT;
>>>> +
>>>> +		/* For Geneve, the VNI should be placed in offset shifted by a
>>>> +		 * byte than the offset for the Tenant ID for rest of the
>>>> +		 * tunnels.
>>>> +		 */
>>>> +		if (tnl_type == I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE) {
>>>> +			ti = le32_to_cpu(filters[i].element.tenant_id);
>>>> +			filters[i].element.tenant_id = cpu_to_le32(ti << 8);
>>>> +		}
>>>> +	}
>>>> +
>>>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>>>> +
>>>> +	return status;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_aq_rem_cloud_filters
>>>> + * @hw: pointer to the hardware structure
>>>> + * @seid: VSI seid to remove cloud filters from
>>>> + * @filters: Buffer which contains the filters to be removed
>>>> + * @filter_count: number of filters contained in the buffer
>>>> + *
>>>> + * Remove the cloud filters for a given VSI.  The contents of the
>>>> + * i40e_aqc_cloud_filters_element_data are filled in by the caller
>>>> + * of the function.
>>>> + *
>>>> + **/
>>>> +enum i40e_status_code
>>>> +i40e_aq_rem_cloud_filters(struct i40e_hw *hw, u16 seid,
>>>> +			  struct i40e_aqc_cloud_filters_element_data *filters,
>>>> +			  u8 filter_count)
>>>> +{
>>>> +	struct i40e_aq_desc desc;
>>>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>>>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>>>> +	enum i40e_status_code status;
>>>> +	u16 buff_len;
>>>> +
>>>> +	i40e_fill_default_direct_cmd_desc(&desc,
>>>> +					  i40e_aqc_opc_remove_cloud_filters);
>>>> +
>>>> +	buff_len = filter_count * sizeof(*filters);
>>>> +	desc.datalen = cpu_to_le16(buff_len);
>>>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>>>> +	cmd->num_filters = filter_count;
>>>> +	cmd->seid = cpu_to_le16(seid);
>>>> +
>>>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>>>> +
>>>> +	return status;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_aq_rem_cloud_filters_bb
>>>> + * @hw: pointer to the hardware structure
>>>> + * @seid: VSI seid to remove cloud filters from
>>>> + * @filters: Buffer which contains the filters in big buffer to be removed
>>>> + * @filter_count: number of filters contained in the buffer
>>>> + *
>>>> + * Remove the big buffer cloud filters for a given VSI.  The contents of the
>>>> + * i40e_aqc_cloud_filters_element_bb are filled in by the caller of the
>>>> + * function.
>>>> + *
>>>> + **/
>>>> +i40e_status
>>>> +i40e_aq_rem_cloud_filters_bb(struct i40e_hw *hw, u16 seid,
>>>> +			     struct i40e_aqc_cloud_filters_element_bb *filters,
>>>> +			     u8 filter_count)
>>>> +{
>>>> +	struct i40e_aq_desc desc;
>>>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>>>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>>>> +	i40e_status status;
>>>> +	u16 buff_len;
>>>> +	int i;
>>>> +
>>>> +	i40e_fill_default_direct_cmd_desc(&desc,
>>>> +					  i40e_aqc_opc_remove_cloud_filters);
>>>> +
>>>> +	buff_len = filter_count * sizeof(*filters);
>>>> +	desc.datalen = cpu_to_le16(buff_len);
>>>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>>>> +	cmd->num_filters = filter_count;
>>>> +	cmd->seid = cpu_to_le16(seid);
>>>> +	cmd->big_buffer_flag = I40E_AQC_ADD_CLOUD_CMD_BB;
>>>> +
>>>> +	for (i = 0; i < filter_count; i++) {
>>>> +		u16 tnl_type;
>>>> +		u32 ti;
>>>> +
>>>> +		tnl_type = (le16_to_cpu(filters[i].element.flags) &
>>>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK) >>
>>>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT;
>>>> +
>>>> +		/* For Geneve, the VNI should be placed in offset shifted by a
>>>> +		 * byte than the offset for the Tenant ID for rest of the
>>>> +		 * tunnels.
>>>> +		 */
>>>> +		if (tnl_type == I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE) {
>>>> +			ti = le32_to_cpu(filters[i].element.tenant_id);
>>>> +			filters[i].element.tenant_id = cpu_to_le32(ti << 8);
>>>> +		}
>>>> +	}
>>>> +
>>>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>>>> +
>>>> 	return status;
>>>> }
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>> index afcf08a..96ee608 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>> @@ -69,6 +69,15 @@ static int i40e_reset(struct i40e_pf *pf);
>>>> static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired);
>>>> static void i40e_fdir_sb_setup(struct i40e_pf *pf);
>>>> static int i40e_veb_get_bw_info(struct i40e_veb *veb);
>>>> +static int i40e_add_del_cloud_filter(struct i40e_vsi *vsi,
>>>> +				     struct i40e_cloud_filter *filter,
>>>> +				     bool add);
>>>> +static int i40e_add_del_cloud_filter_big_buf(struct i40e_vsi *vsi,
>>>> +					     struct i40e_cloud_filter *filter,
>>>> +					     bool add);
>>>> +static int i40e_get_capabilities(struct i40e_pf *pf,
>>>> +				 enum i40e_admin_queue_opc list_type);
>>>> +
>>>>
>>>> /* i40e_pci_tbl - PCI Device ID Table
>>>>  *
>>>> @@ -5478,7 +5487,11 @@ int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
>>>>  **/
>>>> static void i40e_remove_queue_channels(struct i40e_vsi *vsi)
>>>> {
>>>> +	enum i40e_admin_queue_err last_aq_status;
>>>> +	struct i40e_cloud_filter *cfilter;
>>>> 	struct i40e_channel *ch, *ch_tmp;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	struct hlist_node *node;
>>>> 	int ret, i;
>>>>
>>>> 	/* Reset rss size that was stored when reconfiguring rss for
>>>> @@ -5519,6 +5532,29 @@ static void i40e_remove_queue_channels(struct i40e_vsi *vsi)
>>>> 				 "Failed to reset tx rate for ch->seid %u\n",
>>>> 				 ch->seid);
>>>>
>>>> +		/* delete cloud filters associated with this channel */
>>>> +		hlist_for_each_entry_safe(cfilter, node,
>>>> +					  &pf->cloud_filter_list, cloud_node) {
>>>> +			if (cfilter->seid != ch->seid)
>>>> +				continue;
>>>> +
>>>> +			hash_del(&cfilter->cloud_node);
>>>> +			if (cfilter->dst_port)
>>>> +				ret = i40e_add_del_cloud_filter_big_buf(vsi,
>>>> +									cfilter,
>>>> +									false);
>>>> +			else
>>>> +				ret = i40e_add_del_cloud_filter(vsi, cfilter,
>>>> +								false);
>>>> +			last_aq_status = pf->hw.aq.asq_last_status;
>>>> +			if (ret)
>>>> +				dev_info(&pf->pdev->dev,
>>>> +					 "Failed to delete cloud filter, err %s aq_err %s\n",
>>>> +					 i40e_stat_str(&pf->hw, ret),
>>>> +					 i40e_aq_str(&pf->hw, last_aq_status));
>>>> +			kfree(cfilter);
>>>> +		}
>>>> +
>>>> 		/* delete VSI from FW */
>>>> 		ret = i40e_aq_delete_element(&vsi->back->hw, ch->seid,
>>>> 					     NULL);
>>>> @@ -5970,6 +6006,74 @@ static bool i40e_setup_channel(struct i40e_pf *pf, struct i40e_vsi *vsi,
>>>> }
>>>>
>>>> /**
>>>> + * i40e_validate_and_set_switch_mode - sets up switch mode correctly
>>>> + * @vsi: ptr to VSI which has PF backing
>>>> + * @l4type: true for TCP ond false for UDP
>>>> + * @port_type: true if port is destination and false if port is source
>>>> + *
>>>> + * Sets up switch mode correctly if it needs to be changed and perform
>>>> + * what are allowed modes.
>>>> + **/
>>>> +static int i40e_validate_and_set_switch_mode(struct i40e_vsi *vsi, bool l4type,
>>>> +					     bool port_type)
>>>> +{
>>>> +	u8 mode;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	struct i40e_hw *hw = &pf->hw;
>>>> +	int ret;
>>>> +
>>>> +	ret = i40e_get_capabilities(pf, i40e_aqc_opc_list_dev_capabilities);
>>>> +	if (ret)
>>>> +		return -EINVAL;
>>>> +
>>>> +	if (hw->dev_caps.switch_mode) {
>>>> +		/* if switch mode is set, support mode2 (non-tunneled for
>>>> +		 * cloud filter) for now
>>>> +		 */
>>>> +		u32 switch_mode = hw->dev_caps.switch_mode &
>>>> +							I40E_SWITCH_MODE_MASK;
>>>> +		if (switch_mode >= I40E_NVM_IMAGE_TYPE_MODE1) {
>>>> +			if (switch_mode == I40E_NVM_IMAGE_TYPE_MODE2)
>>>> +				return 0;
>>>> +			dev_err(&pf->pdev->dev,
>>>> +				"Invalid switch_mode (%d), only non-tunneled mode for cloud filter is supported\n",
>>>> +				hw->dev_caps.switch_mode);
>>>> +			return -EINVAL;
>>>> +		}
>>>> +	}
>>>> +
>>>> +	/* port_type: true for destination port and false for source port
>>>> +	 * For now, supports only destination port type
>>>> +	 */
>>>> +	if (!port_type) {
>>>> +		dev_err(&pf->pdev->dev, "src port type not supported\n");
>>>> +		return -EINVAL;
>>>> +	}
>>>> +
>>>> +	/* Set Bit 7 to be valid */
>>>> +	mode = I40E_AQ_SET_SWITCH_BIT7_VALID;
>>>> +
>>>> +	/* Set L4type to both TCP and UDP support */
>>>> +	mode |= I40E_AQ_SET_SWITCH_L4_TYPE_BOTH;
>>>> +
>>>> +	/* Set cloud filter mode */
>>>> +	mode |= I40E_AQ_SET_SWITCH_MODE_NON_TUNNEL;
>>>> +
>>>> +	/* Prep mode field for set_switch_config */
>>>> +	ret = i40e_aq_set_switch_config(hw, pf->last_sw_conf_flags,
>>>> +					pf->last_sw_conf_valid_flags,
>>>> +					mode, NULL);
>>>> +	if (ret && hw->aq.asq_last_status != I40E_AQ_RC_ESRCH)
>>>> +		dev_err(&pf->pdev->dev,
>>>> +			"couldn't set switch config bits, err %s aq_err %s\n",
>>>> +			i40e_stat_str(hw, ret),
>>>> +			i40e_aq_str(hw,
>>>> +				    hw->aq.asq_last_status));
>>>> +
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/**
>>>>  * i40e_create_queue_channel - function to create channel
>>>>  * @vsi: VSI to be configured
>>>>  * @ch: ptr to channel (it contains channel specific params)
>>>> @@ -6735,13 +6839,726 @@ static int i40e_setup_tc(struct net_device *netdev, void *type_data)
>>>> 	return ret;
>>>> }
>>>>
>>>> +/**
>>>> + * i40e_set_cld_element - sets cloud filter element data
>>>> + * @filter: cloud filter rule
>>>> + * @cld: ptr to cloud filter element data
>>>> + *
>>>> + * This is helper function to copy data into cloud filter element
>>>> + **/
>>>> +static inline void
>>>> +i40e_set_cld_element(struct i40e_cloud_filter *filter,
>>>> +		     struct i40e_aqc_cloud_filters_element_data *cld)
>>>> +{
>>>> +	int i, j;
>>>> +	u32 ipa;
>>>> +
>>>> +	memset(cld, 0, sizeof(*cld));
>>>> +	ether_addr_copy(cld->outer_mac, filter->dst_mac);
>>>> +	ether_addr_copy(cld->inner_mac, filter->src_mac);
>>>> +
>>>> +	if (filter->ip_version == IPV6_VERSION) {
>>>> +#define IPV6_MAX_INDEX	(ARRAY_SIZE(filter->dst_ipv6) - 1)
>>>> +		for (i = 0, j = 0; i < 4; i++, j += 2) {
>>>> +			ipa = be32_to_cpu(filter->dst_ipv6[IPV6_MAX_INDEX - i]);
>>>> +			ipa = cpu_to_le32(ipa);
>>>> +			memcpy(&cld->ipaddr.raw_v6.data[j], &ipa, 4);
>>>> +		}
>>>> +	} else {
>>>> +		ipa = be32_to_cpu(filter->dst_ip);
>>>> +		memcpy(&cld->ipaddr.v4.data, &ipa, 4);
>>>> +	}
>>>> +
>>>> +	cld->inner_vlan = cpu_to_le16(ntohs(filter->vlan_id));
>>>> +
>>>> +	/* tenant_id is not supported by FW now, once the support is enabled
>>>> +	 * fill the cld->tenant_id with cpu_to_le32(filter->tenant_id)
>>>> +	 */
>>>> +	if (filter->tenant_id)
>>>> +		return;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_add_del_cloud_filter - Add/del cloud filter
>>>> + * @vsi: pointer to VSI
>>>> + * @filter: cloud filter rule
>>>> + * @add: if true, add, if false, delete
>>>> + *
>>>> + * Add or delete a cloud filter for a specific flow spec.
>>>> + * Returns 0 if the filter were successfully added.
>>>> + **/
>>>> +static int i40e_add_del_cloud_filter(struct i40e_vsi *vsi,
>>>> +				     struct i40e_cloud_filter *filter, bool add)
>>>> +{
>>>> +	struct i40e_aqc_cloud_filters_element_data cld_filter;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	int ret;
>>>> +	static const u16 flag_table[128] = {
>>>> +		[I40E_CLOUD_FILTER_FLAGS_OMAC]  =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_OMAC,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC]  =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN]  =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_IVLAN,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_TEN_ID] =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_TEN_ID,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_OMAC_TEN_ID_IMAC] =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_OMAC_TEN_ID_IMAC,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN_TEN_ID] =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_IVLAN_TEN_ID,
>>>> +		[I40E_CLOUD_FILTER_FLAGS_IIP] =
>>>> +			I40E_AQC_ADD_CLOUD_FILTER_IIP,
>>>> +	};
>>>> +
>>>> +	if (filter->flags >= ARRAY_SIZE(flag_table))
>>>> +		return I40E_ERR_CONFIG;
>>>> +
>>>> +	/* copy element needed to add cloud filter from filter */
>>>> +	i40e_set_cld_element(filter, &cld_filter);
>>>> +
>>>> +	if (filter->tunnel_type != I40E_CLOUD_TNL_TYPE_NONE)
>>>> +		cld_filter.flags = cpu_to_le16(filter->tunnel_type <<
>>>> +					     I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT);
>>>> +
>>>> +	if (filter->ip_version == IPV6_VERSION)
>>>> +		cld_filter.flags |= cpu_to_le16(flag_table[filter->flags] |
>>>> +						I40E_AQC_ADD_CLOUD_FLAGS_IPV6);
>>>> +	else
>>>> +		cld_filter.flags |= cpu_to_le16(flag_table[filter->flags] |
>>>> +						I40E_AQC_ADD_CLOUD_FLAGS_IPV4);
>>>> +
>>>> +	if (add)
>>>> +		ret = i40e_aq_add_cloud_filters(&pf->hw, filter->seid,
>>>> +						&cld_filter, 1);
>>>> +	else
>>>> +		ret = i40e_aq_rem_cloud_filters(&pf->hw, filter->seid,
>>>> +						&cld_filter, 1);
>>>> +	if (ret)
>>>> +		dev_dbg(&pf->pdev->dev,
>>>> +			"Failed to %s cloud filter using l4 port %u, err %d aq_err %d\n",
>>>> +			add ? "add" : "delete", filter->dst_port, ret,
>>>> +			pf->hw.aq.asq_last_status);
>>>> +	else
>>>> +		dev_info(&pf->pdev->dev,
>>>> +			 "%s cloud filter for VSI: %d\n",
>>>> +			 add ? "Added" : "Deleted", filter->seid);
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_add_del_cloud_filter_big_buf - Add/del cloud filter using big_buf
>>>> + * @vsi: pointer to VSI
>>>> + * @filter: cloud filter rule
>>>> + * @add: if true, add, if false, delete
>>>> + *
>>>> + * Add or delete a cloud filter for a specific flow spec using big buffer.
>>>> + * Returns 0 if the filter were successfully added.
>>>> + **/
>>>> +static int i40e_add_del_cloud_filter_big_buf(struct i40e_vsi *vsi,
>>>> +					     struct i40e_cloud_filter *filter,
>>>> +					     bool add)
>>>> +{
>>>> +	struct i40e_aqc_cloud_filters_element_bb cld_filter;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	int ret;
>>>> +
>>>> +	/* Both (Outer/Inner) valid mac_addr are not supported */
>>>> +	if (is_valid_ether_addr(filter->dst_mac) &&
>>>> +	    is_valid_ether_addr(filter->src_mac))
>>>> +		return -EINVAL;
>>>> +
>>>> +	/* Make sure port is specified, otherwise bail out, for channel
>>>> +	 * specific cloud filter needs 'L4 port' to be non-zero
>>>> +	 */
>>>> +	if (!filter->dst_port)
>>>> +		return -EINVAL;
>>>> +
>>>> +	/* adding filter using src_port/src_ip is not supported at this stage */
>>>> +	if (filter->src_port || filter->src_ip ||
>>>> +	    !ipv6_addr_any((struct in6_addr *)&filter->src_ipv6))
>>>> +		return -EINVAL;
>>>> +
>>>> +	/* copy element needed to add cloud filter from filter */
>>>> +	i40e_set_cld_element(filter, &cld_filter.element);
>>>> +
>>>> +	if (is_valid_ether_addr(filter->dst_mac) ||
>>>> +	    is_valid_ether_addr(filter->src_mac) ||
>>>> +	    is_multicast_ether_addr(filter->dst_mac) ||
>>>> +	    is_multicast_ether_addr(filter->src_mac)) {
>>>> +		/* MAC + IP : unsupported mode */
>>>> +		if (filter->dst_ip)
>>>> +			return -EINVAL;
>>>> +
>>>> +		/* since we validated that L4 port must be valid before
>>>> +		 * we get here, start with respective "flags" value
>>>> +		 * and update if vlan is present or not
>>>> +		 */
>>>> +		cld_filter.element.flags =
>>>> +			cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT);
>>>> +
>>>> +		if (filter->vlan_id) {
>>>> +			cld_filter.element.flags =
>>>> +			cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT);
>>>> +		}
>>>> +
>>>> +	} else if (filter->dst_ip || filter->ip_version == IPV6_VERSION) {
>>>> +		cld_filter.element.flags =
>>>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_IP_PORT);
>>>> +		if (filter->ip_version == IPV6_VERSION)
>>>> +			cld_filter.element.flags |=
>>>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FLAGS_IPV6);
>>>> +		else
>>>> +			cld_filter.element.flags |=
>>>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FLAGS_IPV4);
>>>> +	} else {
>>>> +		dev_err(&pf->pdev->dev,
>>>> +			"either mac or ip has to be valid for cloud filter\n");
>>>> +		return -EINVAL;
>>>> +	}
>>>> +
>>>> +	/* Now copy L4 port in Byte 6..7 in general fields */
>>>> +	cld_filter.general_fields[I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD0] =
>>>> +						be16_to_cpu(filter->dst_port);
>>>> +
>>>> +	if (add) {
>>>> +		bool proto_type, port_type;
>>>> +
>>>> +		proto_type = (filter->ip_proto == IPPROTO_TCP) ? true : false;
>>>> +		port_type = (filter->port_type & I40E_CLOUD_FILTER_PORT_DEST) ?
>>>> +			     true : false;
>>>> +
>>>> +		/* For now, src port based cloud filter for channel is not
>>>> +		 * supported
>>>> +		 */
>>>> +		if (!port_type) {
>>>> +			dev_err(&pf->pdev->dev,
>>>> +				"unsupported port type (src port)\n");
>>>> +			return -EOPNOTSUPP;
>>>> +		}
>>>> +
>>>> +		/* Validate current device switch mode, change if necessary */
>>>> +		ret = i40e_validate_and_set_switch_mode(vsi, proto_type,
>>>> +							port_type);
>>>> +		if (ret) {
>>>> +			dev_err(&pf->pdev->dev,
>>>> +				"failed to set switch mode, ret %d\n",
>>>> +				ret);
>>>> +			return ret;
>>>> +		}
>>>> +
>>>> +		ret = i40e_aq_add_cloud_filters_bb(&pf->hw, filter->seid,
>>>> +						   &cld_filter, 1);
>>>> +	} else {
>>>> +		ret = i40e_aq_rem_cloud_filters_bb(&pf->hw, filter->seid,
>>>> +						   &cld_filter, 1);
>>>> +	}
>>>> +
>>>> +	if (ret)
>>>> +		dev_dbg(&pf->pdev->dev,
>>>> +			"Failed to %s cloud filter(big buffer) err %d aq_err %d\n",
>>>> +			add ? "add" : "delete", ret, pf->hw.aq.asq_last_status);
>>>> +	else
>>>> +		dev_info(&pf->pdev->dev,
>>>> +			 "%s cloud filter for VSI: %d, L4 port: %d\n",
>>>> +			 add ? "add" : "delete", filter->seid,
>>>> +			 ntohs(filter->dst_port));
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_parse_cls_flower - Parse tc flower filters provided by kernel
>>>> + * @vsi: Pointer to VSI
>>>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>>>> + * @filter: Pointer to cloud filter structure
>>>> + *
>>>> + **/
>>>> +static int i40e_parse_cls_flower(struct i40e_vsi *vsi,
>>>> +				 struct tc_cls_flower_offload *f,
>>>> +				 struct i40e_cloud_filter *filter)
>>>> +{
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	u16 addr_type = 0;
>>>> +	u8 field_flags = 0;
>>>> +
>>>> +	if (f->dissector->used_keys &
>>>> +	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_VLAN) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
>>>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_KEYID))) {
>>>> +		dev_err(&pf->pdev->dev, "Unsupported key used: 0x%x\n",
>>>> +			f->dissector->used_keys);
>>>> +		return -EOPNOTSUPP;
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_KEYID)) {
>>>> +		struct flow_dissector_key_keyid *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_ENC_KEYID,
>>>> +						  f->key);
>>>> +
>>>> +		struct flow_dissector_key_keyid *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_ENC_KEYID,
>>>> +						  f->mask);
>>>> +
>>>> +		if (mask->keyid != 0)
>>>> +			field_flags |= I40E_CLOUD_FIELD_TEN_ID;
>>>> +
>>>> +		filter->tenant_id = be32_to_cpu(key->keyid);
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
>>>> +		struct flow_dissector_key_basic *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_BASIC,
>>>> +						  f->key);
>>>> +
>>>> +		filter->ip_proto = key->ip_proto;
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
>>>> +		struct flow_dissector_key_eth_addrs *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
>>>> +						  f->key);
>>>> +
>>>> +		struct flow_dissector_key_eth_addrs *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
>>>> +						  f->mask);
>>>> +
>>>> +		/* use is_broadcast and is_zero to check for all 0xf or 0 */
>>>> +		if (!is_zero_ether_addr(mask->dst)) {
>>>> +			if (is_broadcast_ether_addr(mask->dst)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_OMAC;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad ether dest mask %pM\n",
>>>> +					mask->dst);
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		if (!is_zero_ether_addr(mask->src)) {
>>>> +			if (is_broadcast_ether_addr(mask->src)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IMAC;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad ether src mask %pM\n",
>>>> +					mask->src);
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +		ether_addr_copy(filter->dst_mac, key->dst);
>>>> +		ether_addr_copy(filter->src_mac, key->src);
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
>>>> +		struct flow_dissector_key_vlan *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_VLAN,
>>>> +						  f->key);
>>>> +		struct flow_dissector_key_vlan *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_VLAN,
>>>> +						  f->mask);
>>>> +
>>>> +		if (mask->vlan_id) {
>>>> +			if (mask->vlan_id == VLAN_VID_MASK) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IVLAN;
>>>> +
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad vlan mask 0x%04x\n",
>>>> +					mask->vlan_id);
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		filter->vlan_id = cpu_to_be16(key->vlan_id);
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
>>>> +		struct flow_dissector_key_control *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_CONTROL,
>>>> +						  f->key);
>>>> +
>>>> +		addr_type = key->addr_type;
>>>> +	}
>>>> +
>>>> +	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
>>>> +		struct flow_dissector_key_ipv4_addrs *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
>>>> +						  f->key);
>>>> +		struct flow_dissector_key_ipv4_addrs *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
>>>> +						  f->mask);
>>>> +
>>>> +		if (mask->dst) {
>>>> +			if (mask->dst == cpu_to_be32(0xffffffff)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad ip dst mask 0x%08x\n",
>>>> +					be32_to_cpu(mask->dst));
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		if (mask->src) {
>>>> +			if (mask->src == cpu_to_be32(0xffffffff)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad ip src mask 0x%08x\n",
>>>> +					be32_to_cpu(mask->dst));
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		if (field_flags & I40E_CLOUD_FIELD_TEN_ID) {
>>>> +			dev_err(&pf->pdev->dev, "Tenant id not allowed for ip filter\n");
>>>> +			return I40E_ERR_CONFIG;
>>>> +		}
>>>> +		filter->dst_ip = key->dst;
>>>> +		filter->src_ip = key->src;
>>>> +		filter->ip_version = IPV4_VERSION;
>>>> +	}
>>>> +
>>>> +	if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
>>>> +		struct flow_dissector_key_ipv6_addrs *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
>>>> +						  f->key);
>>>> +		struct flow_dissector_key_ipv6_addrs *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
>>>> +						  f->mask);
>>>> +
>>>> +		/* src and dest IPV6 address should not be LOOPBACK
>>>> +		 * (0:0:0:0:0:0:0:1), which can be represented as ::1
>>>> +		 */
>>>> +		if (ipv6_addr_loopback(&key->dst) ||
>>>> +		    ipv6_addr_loopback(&key->src)) {
>>>> +			dev_err(&pf->pdev->dev,
>>>> +				"Bad ipv6, addr is LOOPBACK\n");
>>>> +			return I40E_ERR_CONFIG;
>>>> +		}
>>>> +		if (!ipv6_addr_any(&mask->dst) || !ipv6_addr_any(&mask->src))
>>>> +			field_flags |= I40E_CLOUD_FIELD_IIP;
>>>> +
>>>> +		memcpy(&filter->src_ipv6, &key->src.s6_addr32,
>>>> +		       sizeof(filter->src_ipv6));
>>>> +		memcpy(&filter->dst_ipv6, &key->dst.s6_addr32,
>>>> +		       sizeof(filter->dst_ipv6));
>>>> +
>>>> +		/* mark it as IPv6 filter, to be used later */
>>>> +		filter->ip_version = IPV6_VERSION;
>>>> +	}
>>>> +
>>>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
>>>> +		struct flow_dissector_key_ports *key =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_PORTS,
>>>> +						  f->key);
>>>> +		struct flow_dissector_key_ports *mask =
>>>> +			skb_flow_dissector_target(f->dissector,
>>>> +						  FLOW_DISSECTOR_KEY_PORTS,
>>>> +						  f->mask);
>>>> +
>>>> +		if (mask->src) {
>>>> +			if (mask->src == cpu_to_be16(0xffff)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad src port mask 0x%04x\n",
>>>> +					be16_to_cpu(mask->src));
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		if (mask->dst) {
>>>> +			if (mask->dst == cpu_to_be16(0xffff)) {
>>>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>>>> +			} else {
>>>> +				dev_err(&pf->pdev->dev, "Bad dst port mask 0x%04x\n",
>>>> +					be16_to_cpu(mask->dst));
>>>> +				return I40E_ERR_CONFIG;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		filter->dst_port = key->dst;
>>>> +		filter->src_port = key->src;
>>>> +
>>>> +		/* For now, only supports destination port*/
>>>> +		filter->port_type |= I40E_CLOUD_FILTER_PORT_DEST;
>>>> +
>>>> +		switch (filter->ip_proto) {
>>>> +		case IPPROTO_TCP:
>>>> +		case IPPROTO_UDP:
>>>> +			break;
>>>> +		default:
>>>> +			dev_err(&pf->pdev->dev,
>>>> +				"Only UDP and TCP transport are supported\n");
>>>> +			return -EINVAL;
>>>> +		}
>>>> +	}
>>>> +	filter->flags = field_flags;
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_handle_redirect_action: Forward to a traffic class on the device
>>>> + * @vsi: Pointer to VSI
>>>> + * @ifindex: ifindex of the device to forwared to
>>>> + * @tc: traffic class index on the device
>>>> + * @filter: Pointer to cloud filter structure
>>>> + *
>>>> + **/
>>>> +static int i40e_handle_redirect_action(struct i40e_vsi *vsi, int ifindex, u8 tc,
>>>> +				       struct i40e_cloud_filter *filter)
>>>> +{
>>>> +	struct i40e_channel *ch, *ch_tmp;
>>>> +
>>>> +	/* redirect to a traffic class on the same device */
>>>> +	if (vsi->netdev->ifindex == ifindex) {
>>>> +		if (tc == 0) {
>>>> +			filter->seid = vsi->seid;
>>>> +			return 0;
>>>> +		} else if (vsi->tc_config.enabled_tc & BIT(tc)) {
>>>> +			if (!filter->dst_port) {
>>>> +				dev_err(&vsi->back->pdev->dev,
>>>> +					"Specify destination port to redirect to traffic class that is not default\n");
>>>> +				return -EINVAL;
>>>> +			}
>>>> +			if (list_empty(&vsi->ch_list))
>>>> +				return -EINVAL;
>>>> +			list_for_each_entry_safe(ch, ch_tmp, &vsi->ch_list,
>>>> +						 list) {
>>>> +				if (ch->seid == vsi->tc_seid_map[tc])
>>>> +					filter->seid = ch->seid;
>>>> +			}
>>>> +			return 0;
>>>> +		}
>>>> +	}
>>>> +	return -EINVAL;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_parse_tc_actions - Parse tc actions
>>>> + * @vsi: Pointer to VSI
>>>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>>>> + * @filter: Pointer to cloud filter structure
>>>> + *
>>>> + **/
>>>> +static int i40e_parse_tc_actions(struct i40e_vsi *vsi, struct tcf_exts *exts,
>>>> +				 struct i40e_cloud_filter *filter)
>>>> +{
>>>> +	const struct tc_action *a;
>>>> +	LIST_HEAD(actions);
>>>> +	int err;
>>>> +
>>>> +	if (!tcf_exts_has_actions(exts))
>>>> +		return -EINVAL;
>>>> +
>>>> +	tcf_exts_to_list(exts, &actions);
>>>> +	list_for_each_entry(a, &actions, list) {
>>>> +		/* Drop action */
>>>> +		if (is_tcf_gact_shot(a)) {
>>>> +			dev_err(&vsi->back->pdev->dev,
>>>> +				"Cloud filters do not support the drop action.\n");
>>>> +			return -EOPNOTSUPP;
>>>> +		}
>>>> +
>>>> +		/* Redirect to a traffic class on the same device */
>>>> +		if (!is_tcf_mirred_egress_redirect(a) && is_tcf_mirred_tc(a)) {
>>>> +			int ifindex = tcf_mirred_ifindex(a);
>>>> +			u8 tc = tcf_mirred_tc(a);
>>>> +
>>>> +			err = i40e_handle_redirect_action(vsi, ifindex, tc,
>>>> +							  filter);
>>>> +			if (err == 0)
>>>> +				return err;
>>>> +		}
>>>> +	}
>>>> +	return -EINVAL;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_configure_clsflower - Configure tc flower filters
>>>> + * @vsi: Pointer to VSI
>>>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>>>> + *
>>>> + **/
>>>> +static int i40e_configure_clsflower(struct i40e_vsi *vsi,
>>>> +				    struct tc_cls_flower_offload *cls_flower)
>>>> +{
>>>> +	struct i40e_cloud_filter *filter = NULL;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	int err = 0;
>>>> +
>>>> +	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
>>>> +	    test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
>>>> +		return -EBUSY;
>>>> +
>>>> +	if (pf->fdir_pf_active_filters ||
>>>> +	    (!hlist_empty(&pf->fdir_filter_list))) {
>>>> +		dev_err(&vsi->back->pdev->dev,
>>>> +			"Flow Director Sideband filters exists, turn ntuple off to configure cloud filters\n");
>>>> +		return -EINVAL;
>>>> +	}
>>>> +
>>>> +	if (vsi->back->flags & I40E_FLAG_FD_SB_ENABLED) {
>>>> +		dev_err(&vsi->back->pdev->dev,
>>>> +			"Disable Flow Director Sideband, configuring Cloud filters via tc-flower\n");
>>>> +		vsi->back->flags &= ~I40E_FLAG_FD_SB_ENABLED;
>>>> +		vsi->back->flags |= I40E_FLAG_FD_SB_TO_CLOUD_FILTER;
>>>> +	}
>>>> +
>>>> +	filter = kzalloc(sizeof(*filter), GFP_KERNEL);
>>>> +	if (!filter)
>>>> +		return -ENOMEM;
>>>> +
>>>> +	filter->cookie = cls_flower->cookie;
>>>> +
>>>> +	err = i40e_parse_cls_flower(vsi, cls_flower, filter);
>>>> +	if (err < 0)
>>>> +		goto err;
>>>> +
>>>> +	err = i40e_parse_tc_actions(vsi, cls_flower->exts, filter);
>>>> +	if (err < 0)
>>>> +		goto err;
>>>> +
>>>> +	/* Add cloud filter */
>>>> +	if (filter->dst_port)
>>>> +		err = i40e_add_del_cloud_filter_big_buf(vsi, filter, true);
>>>> +	else
>>>> +		err = i40e_add_del_cloud_filter(vsi, filter, true);
>>>> +
>>>> +	if (err) {
>>>> +		dev_err(&pf->pdev->dev,
>>>> +			"Failed to add cloud filter, err %s\n",
>>>> +			i40e_stat_str(&pf->hw, err));
>>>> +		err = i40e_aq_rc_to_posix(err, pf->hw.aq.asq_last_status);
>>>> +		goto err;
>>>> +	}
>>>> +
>>>> +	/* add filter to the ordered list */
>>>> +	INIT_HLIST_NODE(&filter->cloud_node);
>>>> +
>>>> +	hlist_add_head(&filter->cloud_node, &pf->cloud_filter_list);
>>>> +
>>>> +	pf->num_cloud_filters++;
>>>> +
>>>> +	return err;
>>>> +err:
>>>> +	kfree(filter);
>>>> +	return err;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_find_cloud_filter - Find the could filter in the list
>>>> + * @vsi: Pointer to VSI
>>>> + * @cookie: filter specific cookie
>>>> + *
>>>> + **/
>>>> +static struct i40e_cloud_filter *i40e_find_cloud_filter(struct i40e_vsi *vsi,
>>>> +							unsigned long *cookie)
>>>> +{
>>>> +	struct i40e_cloud_filter *filter = NULL;
>>>> +	struct hlist_node *node2;
>>>> +
>>>> +	hlist_for_each_entry_safe(filter, node2,
>>>> +				  &vsi->back->cloud_filter_list, cloud_node)
>>>> +		if (!memcmp(cookie, &filter->cookie, sizeof(filter->cookie)))
>>>> +			return filter;
>>>> +	return NULL;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_delete_clsflower - Remove tc flower filters
>>>> + * @vsi: Pointer to VSI
>>>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>>>> + *
>>>> + **/
>>>> +static int i40e_delete_clsflower(struct i40e_vsi *vsi,
>>>> +				 struct tc_cls_flower_offload *cls_flower)
>>>> +{
>>>> +	struct i40e_cloud_filter *filter = NULL;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	int err = 0;
>>>> +
>>>> +	filter = i40e_find_cloud_filter(vsi, &cls_flower->cookie);
>>>> +
>>>> +	if (!filter)
>>>> +		return -EINVAL;
>>>> +
>>>> +	hash_del(&filter->cloud_node);
>>>> +
>>>> +	if (filter->dst_port)
>>>> +		err = i40e_add_del_cloud_filter_big_buf(vsi, filter, false);
>>>> +	else
>>>> +		err = i40e_add_del_cloud_filter(vsi, filter, false);
>>>> +	if (err) {
>>>> +		kfree(filter);
>>>> +		dev_err(&pf->pdev->dev,
>>>> +			"Failed to delete cloud filter, err %s\n",
>>>> +			i40e_stat_str(&pf->hw, err));
>>>> +		return i40e_aq_rc_to_posix(err, pf->hw.aq.asq_last_status);
>>>> +	}
>>>> +
>>>> +	kfree(filter);
>>>> +	pf->num_cloud_filters--;
>>>> +
>>>> +	if (!pf->num_cloud_filters)
>>>> +		if ((pf->flags & I40E_FLAG_FD_SB_TO_CLOUD_FILTER) &&
>>>> +		    !(pf->flags & I40E_FLAG_FD_SB_INACTIVE)) {
>>>> +			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
>>>> +			pf->flags &= ~I40E_FLAG_FD_SB_TO_CLOUD_FILTER;
>>>> +			pf->flags &= ~I40E_FLAG_FD_SB_INACTIVE;
>>>> +		}
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +/**
>>>> + * i40e_setup_tc_cls_flower - flower classifier offloads
>>>> + * @netdev: net device to configure
>>>> + * @type_data: offload data
>>>> + **/
>>>> +static int i40e_setup_tc_cls_flower(struct net_device *netdev,
>>>> +				    struct tc_cls_flower_offload *cls_flower)
>>>> +{
>>>> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
>>>> +	struct i40e_vsi *vsi = np->vsi;
>>>> +
>>>> +	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
>>>> +	    cls_flower->common.chain_index)
>>>> +		return -EOPNOTSUPP;
>>>> +
>>>> +	switch (cls_flower->command) {
>>>> +	case TC_CLSFLOWER_REPLACE:
>>>> +		return i40e_configure_clsflower(vsi, cls_flower);
>>>> +	case TC_CLSFLOWER_DESTROY:
>>>> +		return i40e_delete_clsflower(vsi, cls_flower);
>>>> +	case TC_CLSFLOWER_STATS:
>>>> +		return -EOPNOTSUPP;
>>>> +	default:
>>>> +		return -EINVAL;
>>>> +	}
>>>> +}
>>>> +
>>>> static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
>>>> 			   void *type_data)
>>>> {
>>>> -	if (type != TC_SETUP_MQPRIO)
>>>> +	switch (type) {
>>>> +	case TC_SETUP_MQPRIO:
>>>> +		return i40e_setup_tc(netdev, type_data);
>>>> +	case TC_SETUP_CLSFLOWER:
>>>> +		return i40e_setup_tc_cls_flower(netdev, type_data);
>>>> +	default:
>>>> 		return -EOPNOTSUPP;
>>>> -
>>>> -	return i40e_setup_tc(netdev, type_data);
>>>> +	}
>>>> }
>>>>
>>>> /**
>>>> @@ -6939,6 +7756,13 @@ static void i40e_cloud_filter_exit(struct i40e_pf *pf)
>>>> 		kfree(cfilter);
>>>> 	}
>>>> 	pf->num_cloud_filters = 0;
>>>> +
>>>> +	if ((pf->flags & I40E_FLAG_FD_SB_TO_CLOUD_FILTER) &&
>>>> +	    !(pf->flags & I40E_FLAG_FD_SB_INACTIVE)) {
>>>> +		pf->flags |= I40E_FLAG_FD_SB_ENABLED;
>>>> +		pf->flags &= ~I40E_FLAG_FD_SB_TO_CLOUD_FILTER;
>>>> +		pf->flags &= ~I40E_FLAG_FD_SB_INACTIVE;
>>>> +	}
>>>> }
>>>>
>>>> /**
>>>> @@ -8046,7 +8870,8 @@ static int i40e_reconstitute_veb(struct i40e_veb *veb)
>>>>  * i40e_get_capabilities - get info about the HW
>>>>  * @pf: the PF struct
>>>>  **/
>>>> -static int i40e_get_capabilities(struct i40e_pf *pf)
>>>> +static int i40e_get_capabilities(struct i40e_pf *pf,
>>>> +				 enum i40e_admin_queue_opc list_type)
>>>> {
>>>> 	struct i40e_aqc_list_capabilities_element_resp *cap_buf;
>>>> 	u16 data_size;
>>>> @@ -8061,9 +8886,8 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
>>>>
>>>> 		/* this loads the data into the hw struct for us */
>>>> 		err = i40e_aq_discover_capabilities(&pf->hw, cap_buf, buf_len,
>>>> -					    &data_size,
>>>> -					    i40e_aqc_opc_list_func_capabilities,
>>>> -					    NULL);
>>>> +						    &data_size, list_type,
>>>> +						    NULL);
>>>> 		/* data loaded, buffer no longer needed */
>>>> 		kfree(cap_buf);
>>>>
>>>> @@ -8080,26 +8904,44 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
>>>> 		}
>>>> 	} while (err);
>>>>
>>>> -	if (pf->hw.debug_mask & I40E_DEBUG_USER)
>>>> -		dev_info(&pf->pdev->dev,
>>>> -			 "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
>>>> -			 pf->hw.pf_id, pf->hw.func_caps.num_vfs,
>>>> -			 pf->hw.func_caps.num_msix_vectors,
>>>> -			 pf->hw.func_caps.num_msix_vectors_vf,
>>>> -			 pf->hw.func_caps.fd_filters_guaranteed,
>>>> -			 pf->hw.func_caps.fd_filters_best_effort,
>>>> -			 pf->hw.func_caps.num_tx_qp,
>>>> -			 pf->hw.func_caps.num_vsis);
>>>> -
>>>> +	if (pf->hw.debug_mask & I40E_DEBUG_USER) {
>>>> +		if (list_type == i40e_aqc_opc_list_func_capabilities) {
>>>> +			dev_info(&pf->pdev->dev,
>>>> +				 "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
>>>> +				 pf->hw.pf_id, pf->hw.func_caps.num_vfs,
>>>> +				 pf->hw.func_caps.num_msix_vectors,
>>>> +				 pf->hw.func_caps.num_msix_vectors_vf,
>>>> +				 pf->hw.func_caps.fd_filters_guaranteed,
>>>> +				 pf->hw.func_caps.fd_filters_best_effort,
>>>> +				 pf->hw.func_caps.num_tx_qp,
>>>> +				 pf->hw.func_caps.num_vsis);
>>>> +		} else if (list_type == i40e_aqc_opc_list_dev_capabilities) {
>>>> +			dev_info(&pf->pdev->dev,
>>>> +				 "switch_mode=0x%04x, function_valid=0x%08x\n",
>>>> +				 pf->hw.dev_caps.switch_mode,
>>>> +				 pf->hw.dev_caps.valid_functions);
>>>> +			dev_info(&pf->pdev->dev,
>>>> +				 "SR-IOV=%d, num_vfs for all function=%u\n",
>>>> +				 pf->hw.dev_caps.sr_iov_1_1,
>>>> +				 pf->hw.dev_caps.num_vfs);
>>>> +			dev_info(&pf->pdev->dev,
>>>> +				 "num_vsis=%u, num_rx:%u, num_tx=%u\n",
>>>> +				 pf->hw.dev_caps.num_vsis,
>>>> +				 pf->hw.dev_caps.num_rx_qp,
>>>> +				 pf->hw.dev_caps.num_tx_qp);
>>>> +		}
>>>> +	}
>>>> +	if (list_type == i40e_aqc_opc_list_func_capabilities) {
>>>> #define DEF_NUM_VSI (1 + (pf->hw.func_caps.fcoe ? 1 : 0) \
>>>> 		       + pf->hw.func_caps.num_vfs)
>>>> -	if (pf->hw.revision_id == 0 && (DEF_NUM_VSI > pf->hw.func_caps.num_vsis)) {
>>>> -		dev_info(&pf->pdev->dev,
>>>> -			 "got num_vsis %d, setting num_vsis to %d\n",
>>>> -			 pf->hw.func_caps.num_vsis, DEF_NUM_VSI);
>>>> -		pf->hw.func_caps.num_vsis = DEF_NUM_VSI;
>>>> +		if (pf->hw.revision_id == 0 &&
>>>> +		    (pf->hw.func_caps.num_vsis < DEF_NUM_VSI)) {
>>>> +			dev_info(&pf->pdev->dev,
>>>> +				 "got num_vsis %d, setting num_vsis to %d\n",
>>>> +				 pf->hw.func_caps.num_vsis, DEF_NUM_VSI);
>>>> +			pf->hw.func_caps.num_vsis = DEF_NUM_VSI;
>>>> +		}
>>>> 	}
>>>> -
>>>> 	return 0;
>>>> }
>>>>
>>>> @@ -8141,6 +8983,7 @@ static void i40e_fdir_sb_setup(struct i40e_pf *pf)
>>>> 		if (!vsi) {
>>>> 			dev_info(&pf->pdev->dev, "Couldn't create FDir VSI\n");
>>>> 			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
>>>> +			pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> 			return;
>>>> 		}
>>>> 	}
>>>> @@ -8163,6 +9006,48 @@ static void i40e_fdir_teardown(struct i40e_pf *pf)
>>>> }
>>>>
>>>> /**
>>>> + * i40e_rebuild_cloud_filters - Rebuilds cloud filters for VSIs
>>>> + * @vsi: PF main vsi
>>>> + * @seid: seid of main or channel VSIs
>>>> + *
>>>> + * Rebuilds cloud filters associated with main VSI and channel VSIs if they
>>>> + * existed before reset
>>>> + **/
>>>> +static int i40e_rebuild_cloud_filters(struct i40e_vsi *vsi, u16 seid)
>>>> +{
>>>> +	struct i40e_cloud_filter *cfilter;
>>>> +	struct i40e_pf *pf = vsi->back;
>>>> +	struct hlist_node *node;
>>>> +	i40e_status ret;
>>>> +
>>>> +	/* Add cloud filters back if they exist */
>>>> +	if (hlist_empty(&pf->cloud_filter_list))
>>>> +		return 0;
>>>> +
>>>> +	hlist_for_each_entry_safe(cfilter, node, &pf->cloud_filter_list,
>>>> +				  cloud_node) {
>>>> +		if (cfilter->seid != seid)
>>>> +			continue;
>>>> +
>>>> +		if (cfilter->dst_port)
>>>> +			ret = i40e_add_del_cloud_filter_big_buf(vsi, cfilter,
>>>> +								true);
>>>> +		else
>>>> +			ret = i40e_add_del_cloud_filter(vsi, cfilter, true);
>>>> +
>>>> +		if (ret) {
>>>> +			dev_dbg(&pf->pdev->dev,
>>>> +				"Failed to rebuild cloud filter, err %s aq_err %s\n",
>>>> +				i40e_stat_str(&pf->hw, ret),
>>>> +				i40e_aq_str(&pf->hw,
>>>> +					    pf->hw.aq.asq_last_status));
>>>> +			return ret;
>>>> +		}
>>>> +	}
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +/**
>>>>  * i40e_rebuild_channels - Rebuilds channel VSIs if they existed before reset
>>>>  * @vsi: PF main vsi
>>>>  *
>>>> @@ -8199,6 +9084,13 @@ static int i40e_rebuild_channels(struct i40e_vsi *vsi)
>>>> 						I40E_BW_CREDIT_DIVISOR,
>>>> 				ch->seid);
>>>> 		}
>>>> +		ret = i40e_rebuild_cloud_filters(vsi, ch->seid);
>>>> +		if (ret) {
>>>> +			dev_dbg(&vsi->back->pdev->dev,
>>>> +				"Failed to rebuild cloud filters for channel VSI %u\n",
>>>> +				ch->seid);
>>>> +			return ret;
>>>> +		}
>>>> 	}
>>>> 	return 0;
>>>> }
>>>> @@ -8365,7 +9257,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
>>>> 		i40e_verify_eeprom(pf);
>>>>
>>>> 	i40e_clear_pxe_mode(hw);
>>>> -	ret = i40e_get_capabilities(pf);
>>>> +	ret = i40e_get_capabilities(pf, i40e_aqc_opc_list_func_capabilities);
>>>> 	if (ret)
>>>> 		goto end_core_reset;
>>>>
>>>> @@ -8482,6 +9374,10 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
>>>> 			goto end_unlock;
>>>> 	}
>>>>
>>>> +	ret = i40e_rebuild_cloud_filters(vsi, vsi->seid);
>>>> +	if (ret)
>>>> +		goto end_unlock;
>>>> +
>>>> 	/* PF Main VSI is rebuild by now, go ahead and rebuild channel VSIs
>>>> 	 * for this main VSI if they exist
>>>> 	 */
>>>> @@ -9404,6 +10300,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
>>>> 	    (pf->num_fdsb_msix == 0)) {
>>>> 		dev_info(&pf->pdev->dev, "Sideband Flowdir disabled, not enough MSI-X vectors\n");
>>>> 		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
>>>> +		pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> 	}
>>>> 	if ((pf->flags & I40E_FLAG_VMDQ_ENABLED) &&
>>>> 	    (pf->num_vmdq_msix == 0)) {
>>>> @@ -9521,6 +10418,7 @@ static int i40e_init_interrupt_scheme(struct i40e_pf *pf)
>>>> 				       I40E_FLAG_FD_SB_ENABLED	|
>>>> 				       I40E_FLAG_FD_ATR_ENABLED	|
>>>> 				       I40E_FLAG_VMDQ_ENABLED);
>>>> +			pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>>
>>>> 			/* rework the queue expectations without MSIX */
>>>> 			i40e_determine_queue_usage(pf);
>>>> @@ -10263,9 +11161,13 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
>>>> 		/* Enable filters and mark for reset */
>>>> 		if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
>>>> 			need_reset = true;
>>>> -		/* enable FD_SB only if there is MSI-X vector */
>>>> -		if (pf->num_fdsb_msix > 0)
>>>> +		/* enable FD_SB only if there is MSI-X vector and no cloud
>>>> +		 * filters exist
>>>> +		 */
>>>> +		if (pf->num_fdsb_msix > 0 && !pf->num_cloud_filters) {
>>>> 			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
>>>> +			pf->flags &= ~I40E_FLAG_FD_SB_INACTIVE;
>>>> +		}
>>>> 	} else {
>>>> 		/* turn off filters, mark for reset and clear SW filter list */
>>>> 		if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
>>>> @@ -10274,6 +11176,8 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
>>>> 		}
>>>> 		pf->flags &= ~(I40E_FLAG_FD_SB_ENABLED |
>>>> 			       I40E_FLAG_FD_SB_AUTO_DISABLED);
>>>> +		pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> +
>>>> 		/* reset fd counters */
>>>> 		pf->fd_add_err = 0;
>>>> 		pf->fd_atr_cnt = 0;
>>>> @@ -10857,7 +11761,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>>>> 		netdev->hw_features |= NETIF_F_NTUPLE;
>>>> 	hw_features = hw_enc_features		|
>>>> 		      NETIF_F_HW_VLAN_CTAG_TX	|
>>>> -		      NETIF_F_HW_VLAN_CTAG_RX;
>>>> +		      NETIF_F_HW_VLAN_CTAG_RX	|
>>>> +		      NETIF_F_HW_TC;
>>>>
>>>> 	netdev->hw_features |= hw_features;
>>>>
>>>> @@ -12159,8 +13064,10 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
>>>> 	*/
>>>>
>>>> 	if ((pf->hw.pf_id == 0) &&
>>>> -	    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT))
>>>> +	    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT)) {
>>>> 		flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
>>>> +		pf->last_sw_conf_flags = flags;
>>>> +	}
>>>>
>>>> 	if (pf->hw.pf_id == 0) {
>>>> 		u16 valid_flags;
>>>> @@ -12176,6 +13083,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
>>>> 					     pf->hw.aq.asq_last_status));
>>>> 			/* not a fatal problem, just keep going */
>>>> 		}
>>>> +		pf->last_sw_conf_valid_flags = valid_flags;
>>>> 	}
>>>>
>>>> 	/* first time setup */
>>>> @@ -12273,6 +13181,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
>>>> 			       I40E_FLAG_DCB_ENABLED	|
>>>> 			       I40E_FLAG_SRIOV_ENABLED	|
>>>> 			       I40E_FLAG_VMDQ_ENABLED);
>>>> +		pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> 	} else if (!(pf->flags & (I40E_FLAG_RSS_ENABLED |
>>>> 				  I40E_FLAG_FD_SB_ENABLED |
>>>> 				  I40E_FLAG_FD_ATR_ENABLED |
>>>> @@ -12287,6 +13196,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
>>>> 			       I40E_FLAG_FD_ATR_ENABLED	|
>>>> 			       I40E_FLAG_DCB_ENABLED	|
>>>> 			       I40E_FLAG_VMDQ_ENABLED);
>>>> +		pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> 	} else {
>>>> 		/* Not enough queues for all TCs */
>>>> 		if ((pf->flags & I40E_FLAG_DCB_CAPABLE) &&
>>>> @@ -12310,6 +13220,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
>>>> 			queues_left -= 1; /* save 1 queue for FD */
>>>> 		} else {
>>>> 			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
>>>> +			pf->flags |= I40E_FLAG_FD_SB_INACTIVE;
>>>> 			dev_info(&pf->pdev->dev, "not enough queues for Flow Director. Flow Director feature is disabled\n");
>>>> 		}
>>>> 	}
>>>> @@ -12613,7 +13524,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>>> 		dev_warn(&pdev->dev, "This device is a pre-production adapter/LOM. Please be aware there may be issues with your hardware. If you are experiencing problems please contact your Intel or hardware representative who provided you with this hardware.\n");
>>>>
>>>> 	i40e_clear_pxe_mode(hw);
>>>> -	err = i40e_get_capabilities(pf);
>>>> +	err = i40e_get_capabilities(pf, i40e_aqc_opc_list_func_capabilities);
>>>> 	if (err)
>>>> 		goto err_adminq_setup;
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>>>> index 92869f5..3bb6659 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>>>> @@ -283,6 +283,22 @@ i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
>>>> 		struct i40e_asq_cmd_details *cmd_details);
>>>> i40e_status i40e_aq_resume_port_tx(struct i40e_hw *hw,
>>>> 				   struct i40e_asq_cmd_details *cmd_details);
>>>> +i40e_status
>>>> +i40e_aq_add_cloud_filters_bb(struct i40e_hw *hw, u16 seid,
>>>> +			     struct i40e_aqc_cloud_filters_element_bb *filters,
>>>> +			     u8 filter_count);
>>>> +enum i40e_status_code
>>>> +i40e_aq_add_cloud_filters(struct i40e_hw *hw, u16 vsi,
>>>> +			  struct i40e_aqc_cloud_filters_element_data *filters,
>>>> +			  u8 filter_count);
>>>> +enum i40e_status_code
>>>> +i40e_aq_rem_cloud_filters(struct i40e_hw *hw, u16 vsi,
>>>> +			  struct i40e_aqc_cloud_filters_element_data *filters,
>>>> +			  u8 filter_count);
>>>> +i40e_status
>>>> +i40e_aq_rem_cloud_filters_bb(struct i40e_hw *hw, u16 seid,
>>>> +			     struct i40e_aqc_cloud_filters_element_bb *filters,
>>>> +			     u8 filter_count);
>>>> i40e_status i40e_read_lldp_cfg(struct i40e_hw *hw,
>>>> 			       struct i40e_lldp_variables *lldp_cfg);
>>>> /* i40e_common */
>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
>>>> index c019f46..af38881 100644
>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_type.h
>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
>>>> @@ -287,6 +287,7 @@ struct i40e_hw_capabilities {
>>>> #define I40E_NVM_IMAGE_TYPE_MODE1	0x6
>>>> #define I40E_NVM_IMAGE_TYPE_MODE2	0x7
>>>> #define I40E_NVM_IMAGE_TYPE_MODE3	0x8
>>>> +#define I40E_SWITCH_MODE_MASK		0xF
>>>>
>>>> 	u32  management_mode;
>>>> 	u32  mng_protocols_over_mctp;
>>>> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
>>>> index b8c78bf..4fe27f0 100644
>>>> --- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
>>>> +++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
>>>> @@ -1360,6 +1360,9 @@ struct i40e_aqc_cloud_filters_element_data {
>>>> 		struct {
>>>> 			u8 data[16];
>>>> 		} v6;
>>>> +		struct {
>>>> +			__le16 data[8];
>>>> +		} raw_v6;
>>>> 	} ipaddr;
>>>> 	__le16	flags;
>>>> #define I40E_AQC_ADD_CLOUD_FILTER_SHIFT			0
>>>>
