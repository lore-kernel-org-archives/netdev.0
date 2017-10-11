From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [Intel-wired-lan] [jkirsher/next-queue PATCH v4 4/6] i40e: Admin
 queue definitions for cloud filters
Date: Wed, 11 Oct 2017 16:30:45 -0700
Message-ID: <d280ca0b-a6ae-9176-ad66-498302652d7c@oracle.com>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
 <150768147360.5320.13399379759470371200.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: intel-wired-lan@osuosl.org,
        Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33533 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdJKXat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 19:30:49 -0400
In-Reply-To: <150768147360.5320.13399379759470371200.stgit@anamdev.jf.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2017 5:24 PM, Amritha Nambiar wrote:
> Add new admin queue definitions and extended fields for cloud
> filter support. Define big buffer for extended general fields
> in Add/Remove Cloud filters command.
> 
> v3: Shortened some lengthy struct names.
> v2: Added I40E_CHECK_STRUCT_LEN check to AQ command structs and
> added AQ definitions to i40evf for consistency based on Shannon's
> feedback.
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  110 ++++++++++++++++++++
>   .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  110 ++++++++++++++++++++
>   2 files changed, 216 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
> index 729976b..bcc7986 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
> @@ -1371,14 +1371,16 @@ struct i40e_aqc_add_remove_cloud_filters {
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT	0
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_MASK	(0x3FF << \
>   					I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT)
> -	u8	reserved2[4];
> +	u8	big_buffer_flag;
> +#define I40E_AQC_ADD_CLOUD_CMD_BB	1
> +	u8	reserved2[3];
>   	__le32	addr_high;
>   	__le32	addr_low;
>   };
>   
>   I40E_CHECK_CMD_LENGTH(i40e_aqc_add_remove_cloud_filters);
>   
> -struct i40e_aqc_add_remove_cloud_filters_element_data {
> +struct i40e_aqc_cloud_filters_element_data {
>   	u8	outer_mac[6];
>   	u8	inner_mac[6];
>   	__le16	inner_vlan;
> @@ -1408,6 +1410,13 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   #define I40E_AQC_ADD_CLOUD_FILTER_IMAC			0x000A
>   #define I40E_AQC_ADD_CLOUD_FILTER_OMAC_TEN_ID_IMAC	0x000B
>   #define I40E_AQC_ADD_CLOUD_FILTER_IIP			0x000C
> +/* 0x0010 to 0x0017 is for custom filters */
> +/* flag to be used when adding cloud filter: IP + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_IP_PORT		0x0010
> +/* flag to be used when adding cloud filter: Dest MAC + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT		0x0011
> +/* flag to be used when adding cloud filter: Dest MAC + VLAN + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT		0x0012

Short description comments to the side of each line would be more 
readable, and maybe don't mind too much the 80 column thing here

#define I40E_AQC_ADD_CLOUD_FILTER_IP_PORT	0x0010/* Dest IP + L4 Port */
#define I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT	0x0011 /* Dest MAC + L4 Port */
#define I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT	0x0012 /* Dest MAC + 
VLAN + L4 Port */


>   
>   #define I40E_AQC_ADD_CLOUD_FLAGS_TO_QUEUE		0x0080
>   #define I40E_AQC_ADD_CLOUD_VNK_SHIFT			6
> @@ -1442,6 +1451,49 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   	u8	response_reserved[7];
>   };
>   
> +I40E_CHECK_STRUCT_LEN(0x40, i40e_aqc_cloud_filters_element_data);
> +
> +/* i40e_aqc_cloud_filters_element_bb is used when
> + * I40E_AQC_CLOUD_CMD_BB flag is set.
> + */
> +struct i40e_aqc_cloud_filters_element_bb {
> +	struct i40e_aqc_cloud_filters_element_data element;
> +	u16     general_fields[32];
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD0	0
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD1	1
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD2	2
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD0	3
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD1	4
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD2	5
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD0	6
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD1	7
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD2	8
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD0	9
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD1	10
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD2	11
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD0	12
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD1	13
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD2	14
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD0	15
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD1	16
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD2	17
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD3	18
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD4	19
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD5	20
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD6	21
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD7	22
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD0	23
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD1	24
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD2	25
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD3	26
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD4	27
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD5	28
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD6	29
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD7	30
> +};
> +
> +I40E_CHECK_STRUCT_LEN(0x80, i40e_aqc_cloud_filters_element_bb);
> +
>   struct i40e_aqc_remove_cloud_filters_completion {
>   	__le16 perfect_ovlan_used;
>   	__le16 perfect_ovlan_free;
> @@ -1453,6 +1505,60 @@ struct i40e_aqc_remove_cloud_filters_completion {
>   
>   I40E_CHECK_CMD_LENGTH(i40e_aqc_remove_cloud_filters_completion);
>   
> +/* Replace filter Command 0x025F
> + * uses the i40e_aqc_replace_cloud_filters,
> + * and the generic indirect completion structure
> + */
> +struct i40e_filter_data {
> +	u8 filter_type;
> +	u8 input[3];
> +};
> +
> +I40E_CHECK_STRUCT_LEN(4, i40e_filter_data);
> +
> +struct i40e_aqc_replace_cloud_filters_cmd {
> +	u8      valid_flags;
> +#define I40E_AQC_REPLACE_L1_FILTER		0x0
> +#define I40E_AQC_REPLACE_CLOUD_FILTER		0x1
> +#define I40E_AQC_GET_CLOUD_FILTERS		0x2
> +#define I40E_AQC_MIRROR_CLOUD_FILTER		0x4
> +#define I40E_AQC_HIGH_PRIORITY_CLOUD_FILTER	0x8
> +	u8      old_filter_type;
> +	u8      new_filter_type;
> +	u8      tr_bit;
> +	u8      reserved[4];
> +	__le32 addr_high;
> +	__le32 addr_low;
> +};
> +
> +I40E_CHECK_CMD_LENGTH(i40e_aqc_replace_cloud_filters_cmd);
> +
> +struct i40e_aqc_replace_cloud_filters_cmd_buf {
> +	u8      data[32];
> +/* Filter type INPUT codes*/
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_ENTRIES_MAX	3
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_VALIDATED	BIT(7)
> +
> +/* Field Vector offsets */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_MAC_DA	0
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_ETH	6
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG	7
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_VLAN	8
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_OVLAN	9
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_IVLAN	10
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_TUNNLE_KEY	11
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IMAC	12
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IP_DA	14
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_OIP_DA	15
> +
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_INNER_VLAN	37
> +	struct i40e_filter_data filters[8];
> +};
> +
> +I40E_CHECK_STRUCT_LEN(0x40, i40e_aqc_replace_cloud_filters_cmd_buf);
> +
>   /* Add Mirror Rule (indirect or direct 0x0260)
>    * Delete Mirror Rule (indirect or direct 0x0261)
>    * note: some rule types (4,5) do not use an external buffer.
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
> index 463e331..0c4ff18 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
> @@ -1339,14 +1339,16 @@ struct i40e_aqc_add_remove_cloud_filters {
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT	0
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_MASK	(0x3FF << \
>   					I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT)
> -	u8	reserved2[4];
> +	u8	big_buffer_flag;
> +#define I40E_AQC_ADD_CLOUD_CMD_BB	1
> +	u8	reserved2[3];
>   	__le32	addr_high;
>   	__le32	addr_low;
>   };
>   
>   I40E_CHECK_CMD_LENGTH(i40e_aqc_add_remove_cloud_filters);
>   
> -struct i40e_aqc_add_remove_cloud_filters_element_data {
> +struct i40e_aqc_cloud_filters_element_data {
>   	u8	outer_mac[6];
>   	u8	inner_mac[6];
>   	__le16	inner_vlan;
> @@ -1376,6 +1378,13 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   #define I40E_AQC_ADD_CLOUD_FILTER_IMAC			0x000A
>   #define I40E_AQC_ADD_CLOUD_FILTER_OMAC_TEN_ID_IMAC	0x000B
>   #define I40E_AQC_ADD_CLOUD_FILTER_IIP			0x000C
> +/* 0x0010 to 0x0017 is for custom filters */
> +/* flag to be used when adding cloud filter: IP + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_IP_PORT		0x0010
> +/* flag to be used when adding cloud filter: Dest MAC + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT		0x0011
> +/* flag to be used when adding cloud filter: Dest MAC + VLAN + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT		0x0012
>   
>   #define I40E_AQC_ADD_CLOUD_FLAGS_TO_QUEUE		0x0080
>   #define I40E_AQC_ADD_CLOUD_VNK_SHIFT			6
> @@ -1410,6 +1419,49 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   	u8	response_reserved[7];
>   };
>   
> +I40E_CHECK_STRUCT_LEN(0x40, i40e_aqc_cloud_filters_element_data);
> +
> +/* i40e_aqc_cloud_filters_element_bb is used when
> + * I40E_AQC_ADD_CLOUD_CMD_BB flag is set.
> + */
> +struct i40e_aqc_cloud_filters_element_bb {
> +	struct i40e_aqc_cloud_filters_element_data element;
> +	u16     general_fields[32];
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD0	0
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD1	1
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD2	2
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD0	3
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD1	4
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD2	5
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD0	6
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD1	7
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD2	8
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD0	9
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD1	10
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD2	11
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD0	12
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD1	13
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD2	14
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD0	15
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD1	16
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD2	17
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD3	18
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD4	19
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD5	20
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD6	21
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD7	22
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD0	23
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD1	24
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD2	25
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD3	26
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD4	27
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD5	28
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD6	29
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD7	30
> +};
> +
> +I40E_CHECK_STRUCT_LEN(0x80, i40e_aqc_cloud_filters_element_bb);
> +
>   struct i40e_aqc_remove_cloud_filters_completion {
>   	__le16 perfect_ovlan_used;
>   	__le16 perfect_ovlan_free;
> @@ -1421,6 +1473,60 @@ struct i40e_aqc_remove_cloud_filters_completion {
>   
>   I40E_CHECK_CMD_LENGTH(i40e_aqc_remove_cloud_filters_completion);
>   
> +/* Replace filter Command 0x025F
> + * uses the i40e_aqc_replace_cloud_filters,
> + * and the generic indirect completion structure
> + */
> +struct i40e_filter_data {
> +	u8 filter_type;
> +	u8 input[3];
> +};
> +
> +I40E_CHECK_STRUCT_LEN(4, i40e_filter_data);
> +
> +struct i40e_aqc_replace_cloud_filters_cmd {
> +	u8      valid_flags;
> +#define I40E_AQC_REPLACE_L1_FILTER		0x0
> +#define I40E_AQC_REPLACE_CLOUD_FILTER		0x1
> +#define I40E_AQC_GET_CLOUD_FILTERS		0x2
> +#define I40E_AQC_MIRROR_CLOUD_FILTER		0x4
> +#define I40E_AQC_HIGH_PRIORITY_CLOUD_FILTER	0x8
> +	u8      old_filter_type;
> +	u8      new_filter_type;
> +	u8      tr_bit;
> +	u8      reserved[4];
> +	__le32 addr_high;
> +	__le32 addr_low;
> +};
> +
> +I40E_CHECK_CMD_LENGTH(i40e_aqc_replace_cloud_filters_cmd);
> +
> +struct i40e_aqc_replace_cloud_filters_cmd_buf {
> +	u8      data[32];
> +/* Filter type INPUT codes*/
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_ENTRIES_MAX	3
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_VALIDATED	BIT(7)
> +
> +/* Field Vector offsets */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_MAC_DA	0
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_ETH	6
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG	7
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_VLAN	8
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_OVLAN	9
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_IVLAN	10
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_TUNNLE_KEY	11
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IMAC	12
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IP_DA	14
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_OIP_DA	15
> +
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_INNER_VLAN	37
> +	struct i40e_filter_data filters[8];
> +};
> +
> +I40E_CHECK_STRUCT_LEN(0x40, i40e_aqc_replace_cloud_filters_cmd_buf);
> +
>   /* Add Mirror Rule (indirect or direct 0x0260)
>    * Delete Mirror Rule (indirect or direct 0x0261)
>    * note: some rule types (4,5) do not use an external buffer.
> 
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> 
