From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 6/6] [net-next]net: i40e: Enable cloud
 filters in i40e via tc/flower classifier
Date: Mon, 14 Aug 2017 12:21:32 -0700
Message-ID: <922adce2-f39c-196a-5a06-8973d9d2ca56@intel.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154788503.4135.7051219373661945937.stgit@anamdev.jf.intel.com>
 <84377bab-472f-7981-48df-cdf5b0528978@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitch.a.williams@intel.com
To: Shannon Nelson <shannon.nelson@oracle.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:63181 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdHNTVe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:21:34 -0400
In-Reply-To: <84377bab-472f-7981-48df-cdf5b0528978@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/2017 12:16 PM, Shannon Nelson wrote:
> On 7/31/2017 5:38 PM, Amritha Nambiar wrote:
>> This patch enables tc-flower based hardware offloads. tc/flower
>> filter provided by the kernel is configured as driver specific
>> cloud filter. The patch implements functions and admin queue
>> commands needed to support cloud filters in the driver and
>> adds cloud filters to configure these tc-flower filters.
>>
>> The only action supported is to redirect packets to a traffic class
>> on the same device.
>>
>> # tc qdisc add dev eth0 ingress
>> # ethtool -K eth0 hw-tc-offload on
>>
>> # tc filter add dev eth0 protocol ip parent ffff:\
>>    prio 1 flower dst_mac 3c:fd:fe:a0:d6:70 skip_sw indev eth0\
>>    action mirred ingress redirect dev eth0 tc 0
>>
>> # tc filter add dev eth0 protocol ip parent ffff:\
>>    prio 2 flower dst_ip 192.168.3.5/32\
>>    ip_proto udp dst_port 25 skip_sw indev eth0\
>>    action mirred ingress redirect dev eth0 tc 1
>>
>> # tc filter add dev eth0 protocol ipv6 parent ffff:\
>>    prio 3 flower dst_ip fe8::200:1\
>>    ip_proto udp dst_port 66 skip_sw indev eth0\
>>    action mirred ingress redirect dev eth0 tc 2
>>
>> Delete tc flower filter:
>> Example:
>>
>> # tc filter del dev eth0 parent ffff: prio 3 handle 0x1 flower
>> # tc filter del dev eth0 parent ffff:
>>
>> Flow Director Sideband is disabled while configuring cloud filters
>> via tc-flower.
> 
> Only while configuring, or the whole time there is a cloud filter?  This 
> is unclear here.

The entire time cloud filters exists. Will make the comment clearer in v2.

> 
>>
>> Unsupported matches when cloud filters are added using enhanced
>> big buffer cloud filter mode of underlying switch include:
>> 1. source port and source IP
>> 2. Combined MAC address and IP fields.
>> 3. Not specfying L4 port
> 
> s/specfying/specifying/

Will fix in v2.

> 
>>
>> These filter matches can however be used to redirect traffic to
>> the main VSI (tc 0) which does not require the enhanced big buffer
>> cloud filter support.
>>
>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
>> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
>> ---
>>   drivers/net/ethernet/intel/i40e/i40e.h           |   46 +
>>   drivers/net/ethernet/intel/i40e/i40e_common.c    |  180 ++++
>>   drivers/net/ethernet/intel/i40e/i40e_main.c      |  952 ++++++++++++++++++++++
>>   drivers/net/ethernet/intel/i40e/i40e_prototype.h |   17
>>   4 files changed, 1193 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
>> index 5c0cad5..7288265 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e.h
>> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
>> @@ -55,6 +55,8 @@
>>   #include <linux/net_tstamp.h>
>>   #include <linux/ptp_clock_kernel.h>
>>   #include <net/pkt_cls.h>
>> +#include <net/tc_act/tc_gact.h>
>> +#include <net/tc_act/tc_mirred.h>
>>   #include "i40e_type.h"
>>   #include "i40e_prototype.h"
>>   #include "i40e_client.h"
>> @@ -252,10 +254,51 @@ struct i40e_fdir_filter {
>>   	u32 fd_id;
>>   };
>>   
>> +#define I40E_CLOUD_FIELD_OMAC	0x01
>> +#define I40E_CLOUD_FIELD_IMAC	0x02
>> +#define I40E_CLOUD_FIELD_IVLAN	0x04
>> +#define I40E_CLOUD_FIELD_TEN_ID	0x08
>> +#define I40E_CLOUD_FIELD_IIP	0x10
>> +
>> +#define I40E_CLOUD_FILTER_FLAGS_OMAC	I40E_CLOUD_FIELD_OMAC
>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC	I40E_CLOUD_FIELD_IMAC
>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN	(I40E_CLOUD_FIELD_IMAC | \
>> +						 I40E_CLOUD_FIELD_IVLAN)
>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_TEN_ID	(I40E_CLOUD_FIELD_IMAC | \
>> +						 I40E_CLOUD_FIELD_TEN_ID)
>> +#define I40E_CLOUD_FILTER_FLAGS_OMAC_TEN_ID_IMAC (I40E_CLOUD_FIELD_OMAC | \
>> +						  I40E_CLOUD_FIELD_IMAC | \
>> +						  I40E_CLOUD_FIELD_TEN_ID)
>> +#define I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN_TEN_ID (I40E_CLOUD_FIELD_IMAC | \
>> +						   I40E_CLOUD_FIELD_IVLAN | \
>> +						   I40E_CLOUD_FIELD_TEN_ID)
>> +#define I40E_CLOUD_FILTER_FLAGS_IIP	I40E_CLOUD_FIELD_IIP
>> +
>>   struct i40e_cloud_filter {
>>   	struct hlist_node cloud_node;
>>   	/* cloud filter input set follows */
>>   	unsigned long cookie;
>> +	u8 dst_mac[ETH_ALEN];
>> +	u8 src_mac[ETH_ALEN];
>> +	__be16 vlan_id;
>> +	__be32 dst_ip[4];
>> +	__be32 src_ip[4];
>> +	u8 dst_ipv6[16];
>> +	u8 src_ipv6[16];
>> +	__be16 dst_port;
>> +	__be16 src_port;
>> +	/* matter only when IP based filtering is set */
>> +	bool is_ipv6;
>> +	/* IPPROTO value */
>> +	u8 ip_proto;
>> +	/* L4 port type: src or destination port */
>> +#define I40E_CLOUD_FILTER_PORT_SRC	0x01
>> +#define I40E_CLOUD_FILTER_PORT_DEST	0x02
>> +	u8 port_type;
>> +	u32 tenant_id;
>> +	u8 flags;
>> +#define I40E_CLOUD_TNL_TYPE_NONE	0xff
>> +	u8 tunnel_type;
>>   	/* filter control */
>>   	u16 seid;
>>   };
>> @@ -574,6 +617,9 @@ struct i40e_pf {
>>   	u16 phy_led_val;
>>   
>>   	u16 override_q_count;
>> +	u16 last_sw_conf_flags;
>> +	u16 last_sw_conf_valid_flags;
>> +
> 
> Unnecessary blank line
> 
>>   };
>>   
>>   /**
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
>> index d0e8138..bfbe304 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
>> @@ -5269,5 +5269,185 @@ i40e_add_pinfo_to_list(struct i40e_hw *hw,
>>   
>>   	status = i40e_aq_write_ppp(hw, (void *)sec, sec->data_end,
>>   				   track_id, &offset, &info, NULL);
>> +
>> +	return status;
>> +}
>> +
>> +/**
>> + * i40e_aq_add_cloud_filters
>> + * @hw: pointer to the hardware structure
>> + * @seid: VSI seid to add cloud filters from
>> + * @filters: Buffer which contains the filters to be added
>> + * @filter_count: number of filters contained in the buffer
>> + *
>> + * Set the cloud filters for a given VSI.  The contents of the
>> + * i40e_aqc_add_remove_cloud_filters_element_data are filled
>> + * in by the caller of the function.
>> + *
>> + **/
>> +enum i40e_status_code i40e_aq_add_cloud_filters(struct i40e_hw *hw,
>> +		u16 seid,
>> +		struct i40e_aqc_add_remove_cloud_filters_element_data *filters,
>> +		u8 filter_count)
>> +{
>> +	struct i40e_aq_desc desc;
>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>> +	enum i40e_status_code status;
>> +	u16 buff_len;
>> +
>> +	i40e_fill_default_direct_cmd_desc(&desc,
>> +					  i40e_aqc_opc_add_cloud_filters);
>> +
>> +	buff_len = filter_count * sizeof(*filters);
>> +	desc.datalen = cpu_to_le16(buff_len);
>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>> +	cmd->num_filters = filter_count;
>> +	cmd->seid = cpu_to_le16(seid);
>> +
>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>> +
>> +	return status;
>> +}
>> +
>> +/**
>> + * i40e_aq_add_cloud_filters_big_buffer
>> + * @hw: pointer to the hardware structure
>> + * @seid: VSI seid to add cloud filters from
>> + * @filters: Buffer which contains the filters in big buffer to be added
>> + * @filter_count: number of filters contained in the buffer
>> + *
>> + * Set the cloud filters for a given VSI.  The contents of the
>> + * i40e_aqc_add_remove_cloud_filters_element_big_data are filled
>> + * in by the caller of the function.
>> + *
>> + **/
>> +i40e_status i40e_aq_add_cloud_filters_big_buffer(struct i40e_hw *hw,
>> +	u16 seid,
>> +	struct i40e_aqc_add_remove_cloud_filters_element_big_data *filters,
>> +	u8 filter_count)
>> +{
>> +	struct i40e_aq_desc desc;
>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>> +	i40e_status status;
>> +	u16 buff_len;
>> +	int i;
>> +
>> +	i40e_fill_default_direct_cmd_desc(&desc,
>> +					  i40e_aqc_opc_add_cloud_filters);
>> +
>> +	buff_len = filter_count * sizeof(*filters);
>> +	desc.datalen = cpu_to_le16(buff_len);
>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>> +	cmd->num_filters = filter_count;
>> +	cmd->seid = cpu_to_le16(seid);
>> +	cmd->big_buffer_flag = I40E_AQC_ADD_REM_CLOUD_CMD_BIG_BUFFER;
>> +
>> +	for (i = 0; i < filter_count; i++) {
>> +		u16 tnl_type;
>> +		u32 ti;
>> +
>> +		tnl_type = (le16_to_cpu(filters[i].element.flags) &
>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK) >>
>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT;
>> +		if (tnl_type == I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE) {
>> +			ti = le32_to_cpu(filters[i].element.tenant_id);
>> +			filters[i].element.tenant_id = cpu_to_le32(ti << 8);
>> +		}
> 
> You might want to add a comment to explain this little hack.  I believe 
> this is for a bit of firmware weirdness?

Yes, this is to handle a firmware behavior specific to Geneve filters.
Will add the comment in v2.

> 
>> +	}
>> +
>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>> +
>> +	return status;
>> +}
>> +
>> +/**
>> + * i40e_aq_remove_cloud_filters
>> + * @hw: pointer to the hardware structure
>> + * @seid: VSI seid to remove cloud filters from
>> + * @filters: Buffer which contains the filters to be removed
>> + * @filter_count: number of filters contained in the buffer
>> + *
>> + * Remove the cloud filters for a given VSI.  The contents of the
>> + * i40e_aqc_add_remove_cloud_filters_element_data are filled
>> + * in by the caller of the function.
>> + *
>> + **/
>> +enum i40e_status_code i40e_aq_remove_cloud_filters(struct i40e_hw *hw,
>> +		u16 seid,
>> +		struct i40e_aqc_add_remove_cloud_filters_element_data *filters,
>> +		u8 filter_count)
>> +{
>> +	struct i40e_aq_desc desc;
>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>> +	enum i40e_status_code status;
>> +	u16 buff_len;
>> +
>> +	i40e_fill_default_direct_cmd_desc(&desc,
>> +					  i40e_aqc_opc_remove_cloud_filters);
>> +
>> +	buff_len = filter_count * sizeof(*filters);
>> +	desc.datalen = cpu_to_le16(buff_len);
>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>> +	cmd->num_filters = filter_count;
>> +	cmd->seid = cpu_to_le16(seid);
>> +
>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>> +
>> +	return status;
>> +}
>> +
>> +/**
>> + * i40e_aq_remove_cloud_filters_big_buffer
>> + * @hw: pointer to the hardware structure
>> + * @seid: VSI seid to remove cloud filters from
>> + * @filters: Buffer which contains the filters in big buffer to be removed
>> + * @filter_count: number of filters contained in the buffer
>> + *
>> + * Remove the cloud filters for a given VSI.  The contents of the
>> + * i40e_aqc_add_remove_cloud_filters_element_big_data are filled
>> + * in by the caller of the function.
>> + *
>> + **/
>> +i40e_status i40e_aq_remove_cloud_filters_big_buffer(
>> +	struct i40e_hw *hw,
>> +	u16 seid,
>> +	struct i40e_aqc_add_remove_cloud_filters_element_big_data *filters,
>> +	u8 filter_count)
>> +{
>> +	struct i40e_aq_desc desc;
>> +	struct i40e_aqc_add_remove_cloud_filters *cmd =
>> +	(struct i40e_aqc_add_remove_cloud_filters *)&desc.params.raw;
>> +	i40e_status status;
>> +	u16 buff_len;
>> +	int i;
>> +
>> +	i40e_fill_default_direct_cmd_desc(&desc,
>> +					  i40e_aqc_opc_remove_cloud_filters);
>> +
>> +	buff_len = filter_count * sizeof(*filters);
>> +	desc.datalen = cpu_to_le16(buff_len);
>> +	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
>> +	cmd->num_filters = filter_count;
>> +	cmd->seid = cpu_to_le16(seid);
>> +	cmd->big_buffer_flag = I40E_AQC_ADD_REM_CLOUD_CMD_BIG_BUFFER;
>> +
>> +	for (i = 0; i < filter_count; i++) {
>> +		u16 tnl_type;
>> +		u32 ti;
>> +
>> +		tnl_type = (le16_to_cpu(filters[i].element.flags) &
>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK) >>
>> +			   I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT;
>> +		if (tnl_type == I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE) {
>> +			ti = le32_to_cpu(filters[i].element.tenant_id);
>> +			filters[i].element.tenant_id = cpu_to_le32(ti << 8);
>> +		}
> 
> Same comment
> 
>> +	}
>> +
>> +	status = i40e_asq_send_command(hw, &desc, filters, buff_len, NULL);
>> +
>>   	return status;
>>   }
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index 93f6fe2..65b284e 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -69,6 +69,12 @@ static int i40e_reset(struct i40e_pf *pf);
>>   static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired);
>>   static void i40e_fdir_sb_setup(struct i40e_pf *pf);
>>   static int i40e_veb_get_bw_info(struct i40e_veb *veb);
>> +static int i40e_add_del_cloud_filter(struct i40e_vsi *vsi,
>> +				     struct i40e_cloud_filter *filter,
>> +				     bool add);
>> +static int i40e_add_del_cloud_filter_big_buf(struct i40e_vsi *vsi,
>> +					     struct i40e_cloud_filter *filter,
>> +					     bool add);
>>   
>>   /* i40e_pci_tbl - PCI Device ID Table
>>    *
>> @@ -5482,7 +5488,11 @@ int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
>>    **/
>>   static void i40e_remove_queue_channels(struct i40e_vsi *vsi)
> 
> Hmmm... I'm looking at net-next code and I don't see this function, or 
> anything else with "i40e_channel" or "queue_channel".  What are you 
> applying this patch to?  Am I missing something?
> 
>>   {
>> +	enum i40e_admin_queue_err last_aq_status;
>> +	struct i40e_cloud_filter *cfilter;
>>   	struct i40e_channel *ch, *ch_tmp;
>> +	struct i40e_pf *pf = vsi->back;
>> +	struct hlist_node *node;
>>   	int ret, i;
>>   
>>   	/* Reset rss size that was stored when reconfiguring rss for
>> @@ -5523,6 +5533,29 @@ static void i40e_remove_queue_channels(struct i40e_vsi *vsi)
>>   				 "Failed to reset tx rate for ch->seid %u\n",
>>   				 ch->seid);
>>   
>> +		/* delete cloud filters associated with this channel */
>> +		hlist_for_each_entry_safe(cfilter, node,
>> +					  &pf->cloud_filter_list, cloud_node) {
>> +			if (cfilter->seid != ch->seid)
>> +				continue;
>> +
>> +			hash_del(&cfilter->cloud_node);
>> +			if (cfilter->dst_port)
>> +				ret = i40e_add_del_cloud_filter_big_buf(vsi,
>> +									cfilter,
>> +									false);
>> +			else
>> +				ret = i40e_add_del_cloud_filter(vsi, cfilter,
>> +								false);
>> +			last_aq_status = pf->hw.aq.asq_last_status;
>> +			if (ret)
>> +				dev_info(&pf->pdev->dev,
>> +					 "fail to delete cloud filter, err %s aq_err %s\n",
>> +					 i40e_stat_str(&pf->hw, ret),
>> +					 i40e_aq_str(&pf->hw, last_aq_status));
>> +			kfree(cfilter);
>> +		}
>> +
>>   		/* delete VSI from FW */
>>   		ret = i40e_aq_delete_element(&vsi->back->hw, ch->seid,
>>   					     NULL);
>> @@ -6004,6 +6037,131 @@ static bool i40e_setup_channel(struct i40e_pf *pf, struct i40e_vsi *vsi,
>>   }
>>   
>>   /**
>> + * i40e_get_device_capabilities - get device level info about the HW
>> + * @pf: the PF struct
>> + **/
>> +static int i40e_get_device_capabilities(struct i40e_pf *pf)
> 
> Since this is almost exactly the same as the original 
> i40e_get_capabilities(), it would be better to simply add list_type_opc 
> to i40e_get_capabilities() parameter list

Will fix this in v2.

> 
>> +{
>> +	struct i40e_aqc_list_capabilities_element_resp *cap_buf;
>> +	u16 data_size;
>> +	int buf_len;
>> +	int err;
>> +
>> +	buf_len = 40 * sizeof(struct i40e_aqc_list_capabilities_element_resp);
>> +
>> +	/* proceed with query device level capabilities */
>> +	do {
>> +		cap_buf = kzalloc(buf_len, GFP_KERNEL);
>> +		if (!cap_buf)
>> +			return -ENOMEM;
>> +
>> +		/* this loads the data into the hw struct for us */
>> +		err = i40e_aq_discover_capabilities(&pf->hw, cap_buf, buf_len,
>> +					     &data_size,
>> +					     i40e_aqc_opc_list_dev_capabilities,
>> +					     NULL);
>> +		/* data loaded, buffer no longer needed */
>> +		kfree(cap_buf);
>> +
>> +		if (pf->hw.aq.asq_last_status == I40E_AQ_RC_ENOMEM) {
>> +			/* retry with a larger buffer */
>> +			buf_len = data_size;
>> +		} else if (pf->hw.aq.asq_last_status != I40E_AQ_RC_OK) {
>> +			dev_dbg(&pf->pdev->dev,
>> +				"device capability discovery failed, err %s aq_err %s\n",
>> +				i40e_stat_str(&pf->hw, err),
>> +				i40e_aq_str(&pf->hw,
>> +					    pf->hw.aq.asq_last_status));
>> +			return -ENODEV;
>> +		}
>> +	} while (err);
>> +
>> +	if (pf->hw.debug_mask & I40E_DEBUG_USER) {
>> +		dev_info(&pf->pdev->dev,
>> +			 "switch_mode=0x%04x, function_valid=0x%08x\n",
>> +			 pf->hw.dev_caps.switch_mode,
>> +			 pf->hw.dev_caps.valid_functions);
>> +		dev_info(&pf->pdev->dev,
>> +			 "SR-IOV=%d, num_vfs for all function=%u\n",
>> +			 pf->hw.dev_caps.sr_iov_1_1, pf->hw.dev_caps.num_vfs);
>> +		dev_info(&pf->pdev->dev,
>> +			 "num_vsis=%u, num_rx:%u, num_tx=%u\n",
>> +			 pf->hw.dev_caps.num_vsis, pf->hw.dev_caps.num_rx_qp,
>> +			 pf->hw.dev_caps.num_tx_qp);
>> +	}
>> +	return 0;
>> +}
>> +
>> +/**
>> + * i40e_validate_and_set_switch_mode - sets up switch mode correctly
>> + * @vsi: ptr to VSI which has PF backing
>> + * @l4type: true for TCP ond false for UDP
>> + * @port_type: true if port is destination and false if port is source
>> + *
>> + * Sets up switch mode correctly if it needs to be changed and perform
>> + * what are allowed modes.
>> + **/
>> +static int i40e_validate_and_set_switch_mode(struct i40e_vsi *vsi, bool l4type,
>> +					     bool port_type)
>> +{
>> +	u8 mode;
>> +	struct i40e_pf *pf = vsi->back;
>> +	struct i40e_hw *hw = &pf->hw;
>> +	int ret;
>> +
>> +	ret = i40e_get_device_capabilities(pf);
>> +	if (ret)
>> +		return -EINVAL;
>> +
>> +	if (hw->dev_caps.switch_mode) {
>> +		/* if switch mode is set, support mode2 (non-tunneled for
>> +		 * cloud filter) for now
>> +		 */
>> +#define I40E_SWITCH_MODE_MASK	0xF /* largest cloud filter mode is 0x8 */
> 
> Why isn't this defined in the appropriate .h file?

Will move this in v2.

> 
>> +		u32 switch_mode = hw->dev_caps.switch_mode &
>> +							I40E_SWITCH_MODE_MASK;
>> +		if (switch_mode >= I40E_NVM_IMAGE_TYPE_MODE1) {
>> +			if (switch_mode == I40E_NVM_IMAGE_TYPE_MODE2)
>> +				return 0;
>> +			dev_err(&pf->pdev->dev,
>> +				"Invalid switch_mode (%d), only non-tunneled mode for cloud filter is supported\n",
>> +				hw->dev_caps.switch_mode);
>> +			return -EINVAL;
>> +		}
>> +	}
>> +
>> +	/* port_type: true for destination port and false for source port
>> +	 * For now, supports only destination port type
>> +	 */
>> +	if (!port_type) {
>> +		dev_err(&pf->pdev->dev, "src port type not supported\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	/* Set Bit 7 to be valid */
>> +	mode = I40E_AQ_SET_SWITCH_BIT7_VALID;
>> +
>> +	/* Set L4type to both TCP and UDP support */
>> +	mode |= I40E_AQ_SET_SWITCH_L4_TYPE_BOTH;
>> +
>> +	/* Set cloud filter mode */
>> +	mode |= I40E_AQ_SET_SWITCH_MODE_NON_TUNNEL;
>> +
>> +	/* Prep mode field for set_switch_config */
>> +	ret = i40e_aq_set_switch_config(hw, pf->last_sw_conf_flags,
>> +					pf->last_sw_conf_valid_flags,
>> +					mode, NULL);
>> +	if (ret && hw->aq.asq_last_status != I40E_AQ_RC_ESRCH)
>> +		dev_err(&pf->pdev->dev,
>> +			"couldn't set switch config bits, err %s aq_err %s\n",
>> +			i40e_stat_str(hw, ret),
>> +			i40e_aq_str(hw,
>> +				    hw->aq.asq_last_status));
>> +
>> +	return ret;
>> +}
>> +
>> +/**
>>    * i40e_create_queue_channel - function to create channel
>>    * @vsi: VSI to be configured
>>    * @ch: ptr to channel (it contains channel specific params)
>> @@ -6632,6 +6790,10 @@ static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
>>   	}
>>   	if (!hw) {
>>   		pf->flags &= ~I40E_FLAG_TC_MQPRIO;
>> +		if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
>> +		    (pf->hw.func_caps.fd_filters_best_effort > 0))
>> +			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
>> +
>>   		if (tc->type == TC_SETUP_MQPRIO_EXT)
>>   			memcpy(&vsi->mqprio_qopt, tc->mqprio_qopt,
>>   			       sizeof(*tc->mqprio_qopt));
>> @@ -6682,6 +6844,11 @@ static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
>>   		       sizeof(*tc->mqprio_qopt));
>>   		pf->flags |= I40E_FLAG_TC_MQPRIO;
>>   		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
>> +		if (pf->flags & I40E_FLAG_FD_ATR_ENABLED) {
>> +			pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
>> +			dev_info(&pf->pdev->dev,
>> +				 "Disabling ATR in MQPRIO mode\n");
>> +		}
>>   		break;
>>   	default:
>>   		return -EINVAL;
>> @@ -6743,10 +6910,724 @@ static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
>>   	return ret;
>>   }
>>   
>> +/**
>> + * i40e_set_cld_element - sets cloud filter element data
>> + * @filter: cloud filter rule
>> + * @cld: ptr to cloud filter element data
>> + *
>> + * This is helper function to copy data into cloud filter element
>> + **/
>> +static inline void
>> +i40e_set_cld_element(struct i40e_cloud_filter *filter,
>> +		     struct i40e_aqc_add_remove_cloud_filters_element_data *cld)
>> +{
>> +	u8 *dest_ipaddr;
>> +	u32 ipaddr;
>> +	int i;
>> +
>> +	memset(cld, 0, sizeof(*cld));
>> +
>> +	ether_addr_copy(cld->outer_mac, filter->dst_mac);
>> +	ether_addr_copy(cld->inner_mac, filter->src_mac);
>> +
>> +	if (filter->is_ipv6) {
>> +		dest_ipaddr = (u8 *)&cld->ipaddr.v6.data;
>> +		for (i = ARRAY_SIZE(filter->dst_ipv6) - 1; i >= 0; i--) {
>> +			memcpy(dest_ipaddr, &filter->dst_ipv6[i], 1);
>> +			dest_ipaddr++;
>> +		}
>> +	} else {
>> +		ipaddr = be32_to_cpu(filter->dst_ip[0]);
>> +		memcpy(&cld->ipaddr.v4.data, &ipaddr, 4);
>> +	}
>> +
>> +	cld->inner_vlan = cpu_to_le16(ntohs(filter->vlan_id));
>> +	cld->tenant_id = cpu_to_le32(filter->tenant_id);
>> +}
>> +
>> +/**
>> + * i40e_add_del_cloud_filter - Add/del cloud filter
>> + * @vsi: pointer to VSI
>> + * @filter: cloud filter rule
>> + * @add: if true, add, if false, delete
>> + *
>> + * Add or delete a cloud filter for a specific flow spec.
>> + * Returns 0 if the filter were successfully added.
>> + **/
>> +static int i40e_add_del_cloud_filter(struct i40e_vsi *vsi,
>> +				     struct i40e_cloud_filter *filter, bool add)
>> +{
>> +	struct i40e_aqc_add_remove_cloud_filters_element_data cld_filter;
>> +	struct i40e_pf *pf = vsi->back;
>> +	int ret;
>> +	static const u16 flag_table[128] = {
>> +		[I40E_CLOUD_FILTER_FLAGS_OMAC]  =
>> +			I40E_AQC_ADD_CLOUD_FILTER_OMAC,
>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC]  =
>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC,
>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN]  =
>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_IVLAN,
>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_TEN_ID] =
>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_TEN_ID,
>> +		[I40E_CLOUD_FILTER_FLAGS_OMAC_TEN_ID_IMAC] =
>> +			I40E_AQC_ADD_CLOUD_FILTER_OMAC_TEN_ID_IMAC,
>> +		[I40E_CLOUD_FILTER_FLAGS_IMAC_IVLAN_TEN_ID] =
>> +			I40E_AQC_ADD_CLOUD_FILTER_IMAC_IVLAN_TEN_ID,
>> +		[I40E_CLOUD_FILTER_FLAGS_IIP] =
>> +			I40E_AQC_ADD_CLOUD_FILTER_IIP,
>> +	};
>> +
>> +	if (filter->flags >= ARRAY_SIZE(flag_table))
>> +		return I40E_ERR_CONFIG;
>> +
>> +	/* copy element needed to add cloud filter from filter */
>> +	i40e_set_cld_element(filter, &cld_filter);
>> +
>> +	if (filter->tunnel_type != I40E_CLOUD_TNL_TYPE_NONE)
>> +		cld_filter.flags = cpu_to_le16(filter->tunnel_type <<
>> +					     I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT);
>> +
>> +	if (filter->is_ipv6)
>> +		cld_filter.flags |= cpu_to_le16(flag_table[filter->flags] |
>> +						I40E_AQC_ADD_CLOUD_FLAGS_IPV6);
>> +	else
>> +		cld_filter.flags |= cpu_to_le16(flag_table[filter->flags] |
>> +						I40E_AQC_ADD_CLOUD_FLAGS_IPV4);
>> +
>> +	if (add)
>> +		ret = i40e_aq_add_cloud_filters(&pf->hw, filter->seid,
>> +						&cld_filter, 1);
>> +	else
>> +		ret = i40e_aq_remove_cloud_filters(&pf->hw, filter->seid,
>> +						   &cld_filter, 1);
>> +	if (ret)
>> +		dev_dbg(&pf->pdev->dev,
>> +			"Failed to %s cloud filter using l4 port %u, err %d aq_err %d\n",
>> +			add ? "add" : "delete", filter->dst_port, ret,
>> +			pf->hw.aq.asq_last_status);
>> +
>> +	dev_info(&pf->pdev->dev,
>> +		 "%s cloud filter for VSI: %d\n", add ? "Added" : "Deleted",
>> +		 filter->seid);
> 
> If there was an error, this dev_info() is lying to the user.

Will fix this in v2.

> 
>> +	return ret;
>> +}
>> +
>> +/**
>> + * i40e_add_del_cloud_filter_big_buf - Add/del cloud filter using big_buf
>> + * @vsi: pointer to VSI
>> + * @filter: cloud filter rule
>> + * @add: if true, add, if false, delete
>> + *
>> + * Add or delete a cloud filter for a specific flow spec using big buffer.
>> + * Returns 0 if the filter were successfully added.
>> + **/
>> +static int i40e_add_del_cloud_filter_big_buf(struct i40e_vsi *vsi,
>> +					     struct i40e_cloud_filter *filter,
>> +					     bool add)
>> +{
>> +	struct i40e_aqc_add_remove_cloud_filters_element_big_data cld_filter;
>> +	struct i40e_pf *pf = vsi->back;
>> +	int ret;
>> +
>> +	/* Both (Outer/Inner) valid mac_addr are not supported */
>> +	if (is_valid_ether_addr(filter->dst_mac) &&
>> +	    is_valid_ether_addr(filter->src_mac))
>> +		return -EINVAL;
>> +
>> +	/* Make sure port is specified, otherwise bail out, for channel
>> +	 * specific cloud filter needs 'L4 port' to be non-zero
>> +	 */
>> +	if (!filter->dst_port)
>> +		return -EINVAL;
>> +
>> +	/* adding filter using src_port/src_ip is not supported at this stage */
>> +	if (filter->src_port || filter->src_ip[0])
>> +		return -EINVAL;
>> +
>> +	/* copy element needed to add cloud filter from filter */
>> +	i40e_set_cld_element(filter, &cld_filter.element);
>> +
>> +	if (is_valid_ether_addr(filter->dst_mac) ||
>> +	    is_valid_ether_addr(filter->src_mac) ||
>> +	    is_multicast_ether_addr(filter->dst_mac) ||
>> +	    is_multicast_ether_addr(filter->src_mac)) {
>> +		/* MAC + IP : unsupported mode */
>> +		if (filter->dst_ip[0])
>> +			return -EINVAL;
>> +
>> +		/* since we validated that L4 port must be valid before
>> +		 * we get here, start with respective "flags" value
>> +		 * and update if vlan is present or not
>> +		 */
>> +		cld_filter.element.flags =
>> +			cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT);
>> +
>> +		if (filter->vlan_id) {
>> +			cld_filter.element.flags =
>> +			cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT);
>> +		}
> 
> 		cld_filter.element.flags = cpu_to_le16(filter->vlan_id
> 				? I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT;
> 				: I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT);
> 
> 
>> +
>> +	} else if (filter->dst_ip[0] || filter->is_ipv6) {
>> +		cld_filter.element.flags =
>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FILTER_IP_PORT);
>> +		if (filter->is_ipv6)
>> +			cld_filter.element.flags |=
>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FLAGS_IPV6);
>> +		else
>> +			cld_filter.element.flags |=
>> +				cpu_to_le16(I40E_AQC_ADD_CLOUD_FLAGS_IPV4);
> 
> 		cld_filter.element.flags |= cpu_to_le16(filter->is_ipv6
> 					? I40E_AQC_ADD_CLOUD_FLAGS_IPV6
> 					: I40E_AQC_ADD_CLOUD_FLAGS_IPV4);
> 
> 
>> +	} else {
>> +		dev_err(&pf->pdev->dev,
>> +			"either mac or ip has to be valid for cloud filter\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	/* Now copy L4 port in Byte 6..7 in general fields */
>> +	cld_filter.general_fields[I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD0] =
>> +						be16_to_cpu(filter->dst_port);
>> +
>> +	if (add) {
>> +		bool proto_type, port_type;
>> +
>> +		proto_type = (filter->ip_proto == IPPROTO_TCP) ? true : false;
>> +		port_type = (filter->port_type & I40E_CLOUD_FILTER_PORT_DEST) ?
>> +			     true : false;
>> +
>> +		/* For now, src port based cloud filter for channel is not
>> +		 * supported
>> +		 */
>> +		if (!port_type) {
>> +			dev_err(&pf->pdev->dev,
>> +				"unsupported port type (src port)\n");
>> +			return -EOPNOTSUPP;
>> +		}
>> +
>> +		/* Validate current device switch mode, change if necessary */
>> +		ret = i40e_validate_and_set_switch_mode(vsi, proto_type,
>> +							port_type);
>> +		if (ret) {
>> +			dev_err(&pf->pdev->dev,
>> +				"fail to and set switch mode, ret %d\n",
>> +				ret);
>> +			return ret;
>> +		}
>> +
>> +		ret = i40e_aq_add_cloud_filters_big_buffer(&pf->hw,
>> +							   filter->seid,
>> +							   &cld_filter, 1);
>> +	} else {
>> +		ret = i40e_aq_remove_cloud_filters_big_buffer(&pf->hw,
>> +							      filter->seid,
>> +							      &cld_filter, 1);
>> +	}
>> +
>> +	if (ret)
>> +		dev_dbg(&pf->pdev->dev,
>> +			"Failed to %s cloud filter(big buffer) err %d aq_err %d\n",
>> +			add ? "add" : "delete", ret, pf->hw.aq.asq_last_status);
>> +
>> +	dev_info(&pf->pdev->dev,
>> +		 "%s cloud filter for VSI: %d, L4 port: %d\n",
>> +		 add ? "add" : "delete", filter->seid, ntohs(filter->dst_port));
> 
> If there was an error, this dev_info is possibly lying to the user.

Will fix this in v2.

> 
>> +
>> +	return ret;
>> +}
>> +
>> +/**
>> + * i40e_parse_cls_flower - Parse tc flower filters provided by kernel
>> + * @vsi: Pointer to VSI
>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>> + * @filter: Pointer to cloud filter structure
>> + *
>> + **/
>> +static int i40e_parse_cls_flower(struct i40e_vsi *vsi,
>> +				 struct tc_cls_flower_offload *f,
>> +				 struct i40e_cloud_filter *filter)
>> +{
>> +	struct i40e_pf *pf = vsi->back;
>> +	u16 addr_type = 0;
>> +	u8 field_flags = 0;
>> +
>> +	if (f->dissector->used_keys &
>> +	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
>> +	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
>> +	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_VLAN) |
>> +	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_KEYID) |
>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) |
>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_PORTS)	|
>> +	      BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL))) {
>> +		dev_err(&pf->pdev->dev, "Unsupported key used: 0x%x\n",
>> +			f->dissector->used_keys);
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_KEYID)) {
>> +		struct flow_dissector_key_keyid *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_ENC_KEYID,
>> +						  f->key);
>> +
>> +		struct flow_dissector_key_keyid *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_ENC_KEYID,
>> +						  f->mask);
>> +
>> +		if (mask->keyid != 0)
>> +			field_flags |= I40E_CLOUD_FIELD_TEN_ID;
>> +
>> +		filter->tenant_id = be32_to_cpu(key->keyid);
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
>> +		struct flow_dissector_key_basic *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_BASIC,
>> +						  f->key);
>> +
>> +		filter->ip_proto = key->ip_proto;
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
>> +		struct flow_dissector_key_eth_addrs *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
>> +						  f->key);
>> +
>> +		struct flow_dissector_key_eth_addrs *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
>> +						  f->mask);
>> +
>> +		/* use is_broadcast and is_zero to check for all 0xf or 0 */
>> +		if (!is_zero_ether_addr(mask->dst)) {
>> +			if (is_broadcast_ether_addr(mask->dst)) {
>> +				field_flags |= I40E_CLOUD_FIELD_OMAC;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad ether dest mask %pM\n",
>> +					mask->dst);
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		if (!is_zero_ether_addr(mask->src)) {
>> +			if (is_broadcast_ether_addr(mask->src)) {
>> +				field_flags |= I40E_CLOUD_FIELD_IMAC;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad ether src mask %pM\n",
>> +					mask->src);
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +		ether_addr_copy(filter->dst_mac, key->dst);
>> +		ether_addr_copy(filter->src_mac, key->src);
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
>> +		struct flow_dissector_key_vlan *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_VLAN,
>> +						  f->key);
>> +		struct flow_dissector_key_vlan *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_VLAN,
>> +						  f->mask);
>> +
>> +		if (mask->vlan_id) {
>> +			if (mask->vlan_id == VLAN_VID_MASK) {
>> +				field_flags |= I40E_CLOUD_FIELD_IVLAN;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad vlan mask %u\n",
> 
> Should this be a %04x rather than %u?

That's right. Will fix this in v2.

> 
>> +					mask->vlan_id);
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		filter->vlan_id = cpu_to_be16(key->vlan_id);
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
>> +		struct flow_dissector_key_control *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_CONTROL,
>> +						  f->key);
>> +
>> +		addr_type = key->addr_type;
>> +	}
>> +
>> +	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
>> +		struct flow_dissector_key_ipv4_addrs *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
>> +						  f->key);
>> +		struct flow_dissector_key_ipv4_addrs *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
>> +						  f->mask);
>> +
>> +		if (mask->dst) {
>> +			if (mask->dst == cpu_to_be32(0xffffffff)) {
>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad ip dst mask 0x%08x\n",
>> +					be32_to_cpu(mask->dst));
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		if (mask->src) {
>> +			if (mask->src == cpu_to_be32(0xffffffff)) {
>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad ip src mask 0x%08x\n",
>> +					be32_to_cpu(mask->dst));
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		if (field_flags & I40E_CLOUD_FIELD_TEN_ID) {
>> +			dev_err(&pf->pdev->dev, "Tenant id not allowed for ip filter\n");
>> +			return I40E_ERR_CONFIG;
>> +		}
>> +		filter->dst_ip[0] = key->dst;
>> +		filter->src_ip[0] = key->src;
>> +	}
>> +
>> +	if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
>> +		struct flow_dissector_key_ipv6_addrs *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
>> +						  f->key);
>> +		struct flow_dissector_key_ipv6_addrs *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
>> +						  f->mask);
>> +
>> +		/* validate mask, make sure it is not IPV6_ADDR_ANY */
>> +		if (ipv6_addr_any(&mask->dst)) {
>> +			dev_err(&pf->pdev->dev, "Bad ipv6 dst mask 0x%02x\n",
>> +				IPV6_ADDR_ANY);
>> +			return I40E_ERR_CONFIG;
>> +		}
>> +
>> +		/* validate src and dest IPV6 address, make sure they are not
>> +		 * ANY (0:0:0:0:0:0:0:0) or LOOPBACK (0:0:0:0:0:0:0:1), which
>> +		 * can be represented as ::1
>> +		 */
>> +		if (ipv6_addr_any(&key->dst) || ipv6_addr_loopback(&key->dst)) {
>> +			dev_err(&pf->pdev->dev,
>> +				"Bad ipv6 dst addr is ANY or LOOPBACK\n");
>> +			return I40E_ERR_CONFIG;
>> +		}
>> +		if (ipv6_addr_loopback(&key->src)) {
>> +			dev_err(&pf->pdev->dev,
>> +				"Bad ipv6 src addr is ANY or LOOPBACK\n");
>> +			return I40E_ERR_CONFIG;
>> +		}
>> +		memcpy(&filter->src_ipv6, &key->src.s6_addr,
>> +		       ARRAY_SIZE(filter->src_ipv6));
>> +		memcpy(&filter->dst_ipv6, &key->dst.s6_addr,
>> +		       ARRAY_SIZE(filter->dst_ipv6));
>> +
>> +		/* mark it as IPv6 filter, to be used later */
>> +		filter->is_ipv6 = true;
>> +
>> +		/* and it is IP[4|6] filter type */
>> +		field_flags |= I40E_CLOUD_FIELD_IIP;
>> +	}
>> +
>> +	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
>> +		struct flow_dissector_key_ports *key =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_PORTS,
>> +						  f->key);
>> +		struct flow_dissector_key_ports *mask =
>> +			skb_flow_dissector_target(f->dissector,
>> +						  FLOW_DISSECTOR_KEY_PORTS,
>> +						  f->mask);
>> +
>> +		if (mask->src) {
>> +			if (mask->src == cpu_to_be16(0xffff)) {
>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad src port mask %u\n",
> 
> Should this be a %04x rather than %u?

Will fix this in v2.

> 
>> +					be16_to_cpu(mask->src));
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		if (mask->dst) {
>> +			if (mask->dst == cpu_to_be16(0xffff)) {
>> +				field_flags |= I40E_CLOUD_FIELD_IIP;
>> +			} else {
>> +				dev_err(&pf->pdev->dev, "Bad dst port mask %u\n",
> 
> Should this be a %04x rather than %u?
> 
>> +					be16_to_cpu(mask->dst));
>> +				return I40E_ERR_CONFIG;
>> +			}
>> +		}
>> +
>> +		filter->dst_port = key->dst;
>> +		filter->src_port = key->src;
>> +
>> +		/* For now, only supports destination port*/
>> +		filter->port_type |= I40E_CLOUD_FILTER_PORT_DEST;
>> +
>> +		switch (filter->ip_proto) {
>> +		case IPPROTO_TCP:
>> +		case IPPROTO_UDP:
>> +			break;
>> +		default:
>> +			dev_err(&pf->pdev->dev,
>> +				"Only UDP and TCP transport are supported\n");
>> +			return -EINVAL;
>> +		}
>> +	}
>> +	filter->flags = field_flags;
>> +	return 0;
>> +}
>> +
>> +/**
>> + * i40e_handle_redirect_action: Forward to a traffic class on the device
>> + * @vsi: Pointer to VSI
>> + * @ifindex: ifindex of the device to forwared to
>> + * @tc: traffic class index on the device
>> + * @filter: Pointer to cloud filter structure
>> + *
>> + **/
>> +static int i40e_handle_redirect_action(struct i40e_vsi *vsi, int ifindex, u8 tc,
>> +				       struct i40e_cloud_filter *filter)
>> +{
>> +	struct i40e_channel *ch, *ch_tmp;
>> +
>> +	/* redirect to a traffic class on the same device */
>> +	if (vsi->netdev->ifindex == ifindex) {
>> +		if (tc == 0) {
>> +			filter->seid = vsi->seid;
>> +			return 0;
>> +		} else if (vsi->tc_config.enabled_tc & BIT(tc)) {
>> +			if (!filter->dst_port) {
>> +				dev_err(&vsi->back->pdev->dev,
>> +					"Specify destination port to redirect to traffic class that is not default\n");
>> +				return -EINVAL;
>> +			}
>> +			if (list_empty(&vsi->ch_list))
>> +				return -EINVAL;
>> +			list_for_each_entry_safe(ch, ch_tmp, &vsi->ch_list,
>> +						 list) {
>> +				if (ch->seid == vsi->tc_seid_map[tc])
>> +					filter->seid = ch->seid;
>> +			}
>> +			return 0;
>> +		}
>> +	}
>> +	return -EINVAL;
>> +}
>> +
>> +/**
>> + * i40e_parse_tc_actions - Parse tc actions
>> + * @vsi: Pointer to VSI
>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>> + * @filter: Pointer to cloud filter structure
>> + *
>> + **/
>> +static int i40e_parse_tc_actions(struct i40e_vsi *vsi, struct tcf_exts *exts,
>> +				 struct i40e_cloud_filter *filter)
>> +{
>> +	const struct tc_action *a;
>> +	LIST_HEAD(actions);
>> +	int err;
>> +
>> +	if (tc_no_actions(exts))
>> +		return -EINVAL;
>> +
>> +	tcf_exts_to_list(exts, &actions);
>> +	list_for_each_entry(a, &actions, list) {
>> +		/* Drop action */
>> +		if (is_tcf_gact_shot(a)) {
>> +			dev_err(&vsi->back->pdev->dev,
>> +				"Cloud filters do not support the drop action.\n");
>> +			return -EOPNOTSUPP;
>> +		}
>> +
>> +		/* Redirect to a traffic class on the same device */
>> +		if (!is_tcf_mirred_egress_redirect(a)) {
>> +			int ifindex = tcf_mirred_ifindex(a);
>> +			int tc = tcf_mirred_tc(a);
>> +
>> +			err = i40e_handle_redirect_action(vsi, ifindex, tc,
>> +							  filter);
>> +			if (err == 0)
>> +				return err;
>> +		}
>> +	}
>> +	return -EINVAL;
>> +}
>> +
>> +/**
>> + * i40e_configure_clsflower - Configure tc flower filters
>> + * @vsi: Pointer to VSI
>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>> + *
>> + **/
>> +static int i40e_configure_clsflower(struct i40e_vsi *vsi,
>> +				    struct tc_cls_flower_offload *cls_flower)
>> +{
>> +	struct i40e_cloud_filter *filter = NULL;
>> +	struct i40e_pf *pf = vsi->back;
>> +	int err = 0;
>> +
>> +	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
>> +	    test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
>> +		return -EBUSY;
>> +
>> +	if (pf->fdir_pf_active_filters ||
>> +	    (!hlist_empty(&pf->fdir_filter_list))) {
>> +		dev_err(&vsi->back->pdev->dev,
>> +			"Flow Director Sideband filters exists, turn ntuple off to configure cloud filters\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	if (vsi->back->flags & I40E_FLAG_FD_SB_ENABLED) {
>> +		dev_err(&vsi->back->pdev->dev,
>> +			"Disable Flow Director Sideband while configuring Cloud filters via tc-flower\n");
>> +		vsi->back->flags &= ~I40E_FLAG_FD_SB_ENABLED;
>> +	}
>> +
>> +	filter = kzalloc(sizeof(*filter), GFP_KERNEL);
>> +	if (!filter)
>> +		return -ENOMEM;
>> +
>> +	filter->cookie = cls_flower->cookie;
>> +
>> +	err = i40e_parse_cls_flower(vsi, cls_flower, filter);
>> +	if (err < 0)
>> +		goto err;
>> +
>> +	err = i40e_parse_tc_actions(vsi, cls_flower->exts, filter);
>> +	if (err < 0)
>> +		goto err;
>> +
>> +	/* Add cloud filter */
>> +	if (filter->dst_port)
>> +		err = i40e_add_del_cloud_filter_big_buf(vsi, filter, true);
>> +	else
>> +		err = i40e_add_del_cloud_filter(vsi, filter, true);
>> +
>> +	if (err) {
>> +		dev_err(&pf->pdev->dev,
>> +			"Failed to add cloud filter, err %s\n",
>> +			i40e_stat_str(&pf->hw, err));
>> +		err = i40e_aq_rc_to_posix(err, pf->hw.aq.asq_last_status);
>> +		goto err;
>> +	}
>> +
>> +	/* add filter to the ordered list */
>> +	INIT_HLIST_NODE(&filter->cloud_node);
>> +
>> +	hlist_add_head(&filter->cloud_node, &pf->cloud_filter_list);
>> +
>> +	pf->num_cloud_filters++;
>> +
>> +	return err;
>> +err:
>> +	kfree(filter);
>> +	return err;
>> +}
>> +
>> +/**
>> + * i40e_find_cloud_filter - Find the could filter in the list
>> + * @vsi: Pointer to VSI
>> + * @cookie: filter specific cookie
>> + *
>> + **/
>> +static struct i40e_cloud_filter *i40e_find_cloud_filter(struct i40e_vsi *vsi,
>> +							unsigned long *cookie)
>> +{
>> +	struct i40e_cloud_filter *filter = NULL;
>> +	struct hlist_node *node2;
>> +
>> +	hlist_for_each_entry_safe(filter, node2,
>> +				  &vsi->back->cloud_filter_list, cloud_node)
>> +		if (!memcmp(cookie, &filter->cookie, sizeof(filter->cookie)))
>> +			return filter;
>> +	return NULL;
>> +}
>> +
>> +/**
>> + * i40e_delete_clsflower - Remove tc flower filters
>> + * @vsi: Pointer to VSI
>> + * @cls_flower: Pointer to struct tc_cls_flower_offload
>> + *
>> + **/
>> +static int i40e_delete_clsflower(struct i40e_vsi *vsi,
>> +				 struct tc_cls_flower_offload *cls_flower)
>> +{
>> +	struct i40e_cloud_filter *filter = NULL;
>> +	struct i40e_pf *pf = vsi->back;
>> +	int err = 0;
>> +
>> +	filter = i40e_find_cloud_filter(vsi, &cls_flower->cookie);
>> +
>> +	if (!filter)
>> +		return -EINVAL;
>> +
>> +	hash_del(&filter->cloud_node);
>> +
>> +	if (filter->dst_port)
>> +		err = i40e_add_del_cloud_filter_big_buf(vsi, filter, false);
>> +	else
>> +		err = i40e_add_del_cloud_filter(vsi, filter, false);
>> +	if (err) {
>> +		kfree(filter);
>> +		dev_err(&pf->pdev->dev,
>> +			"Failed to delete cloud filter, err %s\n",
>> +			i40e_stat_str(&pf->hw, err));
>> +		return i40e_aq_rc_to_posix(err, pf->hw.aq.asq_last_status);
> 
> Hmmm... okay, maybe those earlier functions are not really lying if they 
> have this followup to check them.
> 
>> +	}
>> +
>> +	kfree(filter);
>> +	pf->num_cloud_filters--;
>> +
>> +	if (!pf->num_cloud_filters) {
>> +		/* Re-enable FD-SB that was disabled while configuring cloud
>> +		 * filters
>> +		 */
>> +		if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
>> +		    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
>> +			if (!(pf->flags & I40E_FLAG_MFP_ENABLED &&
>> +			      pf->hw.num_partitions > 1))
>> +				pf->flags |= I40E_FLAG_FD_SB_ENABLED;
> 
> What if FD_SB was disabled for other reasons, like not enough msix 
> vectors or queues, or some other odd circumstance that turns them off?

I agree, this doesn't totally work to keep FD SB and Cloud filters
exclusive. I'll fix this in v2, perhaps with new PF flags to keep track
of the status of FD SB and Cloud filters.

> 
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>   static int __i40e_setup_tc(struct net_device *netdev, u32 handle,
>>   			   u32 chain_index, __be16 proto,
>>   			   struct tc_to_netdev *tc)
>>   {
>> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
>> +	struct i40e_vsi *vsi = np->vsi;
>> +
>> +	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
>> +	    tc->type == TC_SETUP_CLSFLOWER) {
>> +		switch (tc->cls_flower->command) {
>> +		case TC_CLSFLOWER_REPLACE:
>> +			return i40e_configure_clsflower(vsi, tc->cls_flower);
>> +		case TC_CLSFLOWER_DESTROY:
>> +			return i40e_delete_clsflower(vsi, tc->cls_flower);
>> +		case TC_CLSFLOWER_STATS:
>> +			return -EOPNOTSUPP;
>> +		default:
>> +			return -EINVAL;
>> +		}
>> +	}
>> +
>>   	return i40e_setup_tc(netdev, tc);
>>   }
>>   
>> @@ -6948,6 +7829,16 @@ static void i40e_cloud_filter_exit(struct i40e_pf *pf)
>>   		kfree(cfilter);
>>   	}
>>   	pf->num_cloud_filters = 0;
>> +
>> +	/* Re-enable FD-SB that was disabled while configuring cloud
>> +	 * filters
>> +	 */
>> +	if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
>> +	    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
>> +		if (!(pf->flags & I40E_FLAG_MFP_ENABLED &&
>> +		      pf->hw.num_partitions > 1))
>> +			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
> 
> What if FD_SB was disabled for other reasons, like not enough msix 
> vectors or queues, or some other odd circumstance that turns them off?
> 
> This is getting complex and repetative.  Maybe there needs to be a 
> little function that checks all the FD_SB conditions and can be used 
> from anywhere needed.
> 
>> +	}
>>   }
>>   
>>   /**
>> @@ -8157,6 +9048,48 @@ static void i40e_fdir_teardown(struct i40e_pf *pf)
>>   }
>>   
>>   /**
>> + * i40e_rebuild_cloud_filters - Rebuilds cloud filters for VSIs
>> + * @vsi: PF main vsi
>> + * @seid: seid of main or channel VSIs
>> + *
>> + * Rebuilds cloud filters associated with main VSI and channel VSIs if they
>> + * existed before reset
>> + **/
>> +static int i40e_rebuild_cloud_filters(struct i40e_vsi *vsi, u16 seid)
>> +{
>> +	struct i40e_cloud_filter *cfilter;
>> +	struct i40e_pf *pf = vsi->back;
>> +	struct hlist_node *node;
>> +	i40e_status ret;
>> +
>> +	/* Add cloud filters back if they exist */
>> +	if (hlist_empty(&pf->cloud_filter_list))
>> +		return 0;
>> +
>> +	hlist_for_each_entry_safe(cfilter, node, &pf->cloud_filter_list,
>> +				  cloud_node) {
>> +		if (cfilter->seid != seid)
>> +			continue;
>> +
>> +		if (cfilter->dst_port)
>> +			ret = i40e_add_del_cloud_filter_big_buf(vsi, cfilter,
>> +								true);
>> +		else
>> +			ret = i40e_add_del_cloud_filter(vsi, cfilter, true);
>> +
>> +		if (ret) {
>> +			dev_dbg(&pf->pdev->dev,
>> +				"Failed to rebuild cloud filter, err %s aq_err %s\n",
>> +				i40e_stat_str(&pf->hw, ret),
>> +				i40e_aq_str(&pf->hw,
>> +					    pf->hw.aq.asq_last_status));
>> +			return ret;
>> +		}
>> +	}
>> +	return 0;
>> +}
>> +
>> +/**
>>    * i40e_rebuild_channels - Rebuilds channel VSIs if they existed before reset
>>    * @vsi: PF main vsi
>>    *
>> @@ -8193,6 +9126,13 @@ static int i40e_rebuild_channels(struct i40e_vsi *vsi)
>>   						I40E_BW_CREDIT_DIVISOR,
>>   				ch->seid);
>>   		}
>> +		ret = i40e_rebuild_cloud_filters(vsi, ch->seid);
>> +		if (ret) {
>> +			dev_dbg(&vsi->back->pdev->dev,
>> +				"Failed to rebuild cloud filters for channel VSI %u\n",
>> +				ch->seid);
>> +			return ret;
>> +		}
>>   	}
>>   	return 0;
>>   }
>> @@ -8476,6 +9416,10 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
>>   			goto end_unlock;
>>   	}
>>   
>> +	ret = i40e_rebuild_cloud_filters(vsi, vsi->seid);
>> +	if (ret)
>> +		goto end_unlock;
>> +
>>   	/* PF Main VSI is rebuild by now, go ahead and rebuild channel VSIs
>>   	 * for this main VSI if they exist
>>   	 */
>> @@ -10846,7 +11790,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>>   		netdev->hw_features |= NETIF_F_NTUPLE;
>>   	hw_features = hw_enc_features		|
>>   		      NETIF_F_HW_VLAN_CTAG_TX	|
>> -		      NETIF_F_HW_VLAN_CTAG_RX;
>> +		      NETIF_F_HW_VLAN_CTAG_RX	|
>> +		      NETIF_F_HW_TC;
>>   
>>   	netdev->hw_features |= hw_features;
>>   
>> @@ -12123,8 +13068,10 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
>>   	*/
>>   
>>   	if ((pf->hw.pf_id == 0) &&
>> -	    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT))
>> +	    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT)) {
>>   		flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
>> +		pf->last_sw_conf_flags = flags;
>> +	}
>>   
>>   	if (pf->hw.pf_id == 0) {
>>   		u16 valid_flags;
>> @@ -12140,6 +13087,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
>>   					     pf->hw.aq.asq_last_status));
>>   			/* not a fatal problem, just keep going */
>>   		}
>> +		pf->last_sw_conf_valid_flags = valid_flags;
>>   	}
>>   
>>   	/* first time setup */
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>> index 9142d0d..e24f1ce 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
>> @@ -283,6 +283,23 @@ i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
>>   		struct i40e_asq_cmd_details *cmd_details);
>>   i40e_status i40e_aq_resume_port_tx(struct i40e_hw *hw,
>>   				   struct i40e_asq_cmd_details *cmd_details);
>> +i40e_status i40e_aq_add_cloud_filters_big_buffer(struct i40e_hw *hw,
>> +	u16 seid,
>> +	struct i40e_aqc_add_remove_cloud_filters_element_big_data *filters,
>> +	u8 filter_count);
>> +enum i40e_status_code i40e_aq_add_cloud_filters(struct i40e_hw *hw,
>> +		u16 vsi,
>> +		struct i40e_aqc_add_remove_cloud_filters_element_data *filters,
>> +		u8 filter_count);
>> +
>> +enum i40e_status_code i40e_aq_remove_cloud_filters(struct i40e_hw *hw,
>> +		u16 vsi,
>> +		struct i40e_aqc_add_remove_cloud_filters_element_data *filters,
>> +		u8 filter_count);
>> +i40e_status i40e_aq_remove_cloud_filters_big_buffer(
>> +	struct i40e_hw *hw, u16 seid,
>> +	struct i40e_aqc_add_remove_cloud_filters_element_big_data *filters,
>> +	u8 filter_count);
>>   i40e_status i40e_read_lldp_cfg(struct i40e_hw *hw,
>>   			       struct i40e_lldp_variables *lldp_cfg);
>>   /* i40e_common */
>>
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@osuosl.org
>> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>>
