From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v1 1/2] ixgbe: Refactor the
 RSS configuration code.
Date: Thu, 26 Mar 2015 23:51:21 +0200
Message-ID: <55147F59.10305@cloudius-systems.com>
References: <1427392599-18184-1-git-send-email-vladz@cloudius-systems.com> <1427392599-18184-2-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250276E4B@FMSMSX105.amr.corp.intel.com> <55147233.2040300@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250276FAB@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35636 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbbCZVv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:51:26 -0400
Received: by wibbg6 with SMTP id bg6so5469082wib.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:51:25 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250276FAB@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/26/15 23:27, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Thursday, March 26, 2015 1:55 PM
>> To: Tantilov, Emil S; netdev@vger.kernel.org
>> Cc: avi@cloudius-systems.com; intel-wired-lan@lists.osuosl.org; gleb@cloudius-systems.com
>> Subject: Re: [Intel-wired-lan] [PATCH net-next v1 1/2] ixgbe: Refactor the RSS configuration code.
>>
>>
>>
>> On 03/26/15 22:20, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Vlad Zolotarov
>>>> Sent: Thursday, March 26, 2015 10:57 AM
>>>> Subject: [Intel-wired-lan] [PATCH net-next v1 1/2] ixgbe: Refactor the RSS configuration code.
>>>>
>>>> This patch is a preparation for enablement of ethtool RSS indirection table
>>>> and hash key querying. We don't want to read registers every time the RSS info
>>>> is queried. Therefore we will store its current content in the
>>>> arrays in the adapter struct and will read it from there (instead of from
>>>> registers) when requested.
>>>>
>>>> Will change the code that writes the indirection table and hash key into the HW registers
>>>> to take its content from these arrays. This will also simplify the indirection
>>>> table updating ethtool callback implementation in the future.
>>>>
>>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>>> ---
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   2 +
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 143 ++++++++++++++++++--------
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |   7 ++
>>>> 3 files changed, 109 insertions(+), 43 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>>> index 5e44e48..402d182 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>>> @@ -766,6 +766,8 @@ struct ixgbe_adapter {
>>>>
>>>> 	u8 default_up;
>>>> 	unsigned long fwd_bitmask; /* Bitmask indicating in use pools */
>>>> +	u8 rss_indir_tbl[IXGBE_MAX_RETA_ENTRIES];
>>>> +	u32 rss_key[IXGBE_RSS_KEY_SIZE / sizeof(u32)];
>>>> };
>>>>
>>>> static inline u8 ixgbe_max_rss_indices(struct ixgbe_adapter *adapter)
>>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> index 8853d52..e3de0c9 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> @@ -3228,51 +3228,54 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
>>>> 	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
>>>> }
>>>>
>>>> -static void ixgbe_setup_reta(struct ixgbe_adapter *adapter, const u32 *seed)
>>>> +/**
>>>> + * Return a number of entries in the RSS indirection table
>>> The preferred style for multiline comments is to not start with an empty "/*" checkpatch would generally
>>> catch those.
>> It's not a multi-line comment but a function description and its styling
>> is perfectly fine.
> Right - I replied under the wrong comment. There is however an old style comment that you moved that shows up in checkpatch.
>
>>>> + *
>>>> + * @adapter: device handle
>>>> + *
>>>> + *  - 82598/82599/X540:     128
>>>> + *  - X550(non-SRIOV mode): 512
>>>> + *  - X550(SRIOV mode):     64
>>>> + */
>>>> +static u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
>>>> +{
>>>> +	if (adapter->hw.mac.type < ixgbe_mac_X550)
>>>> +		return 128;
>>>> +	else if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
>>>> +		return 64;
>>>> +	else
>>>> +		return 512;
>>>> +}
>>>> +
>>>> +/**
>>>> + * Write the RETA table to HW
>>>> + *
>>>> + * @adapter: device handle
>>>> + *
>>>> + * Write the RSS redirection table stored in adapter.rss_indir_tbl[] to HW.
>>>> + */
>>>> +static void ixgbe_store_reta(struct ixgbe_adapter *adapter)
>>> What is the point of having separate functions for writing the registers? Unless you intend to use
>>> them in other parts of the code, those can be folded inside ixgbe_setupvf/reta().
>> The one that is going to implement the ethtool -X is going to use it. ;)
> Alright that makes sense.
>
>>>> {
>>>> +	u32 i, reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
>>>> 	struct ixgbe_hw *hw = &adapter->hw;
>>>> 	u32 reta = 0;
>>>> -	int i, j;
>>>> -	int reta_entries = 128;
>>>> -	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
>>>> 	int indices_multi;
>>>> -
>>>> -	/*
>>>> -	 * Program table for at least 2 queues w/ SR-IOV so that VFs can
>>>> -	 * make full use of any rings they may have.  We will use the
>>>> -	 * PSRTYPE register to control how many rings we use within the PF.
>>>> -	 */
>>>> -	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) && (rss_i < 2)) >
>>>> -		rss_i = 2;
>>>> -
>>>> -	/* Fill out hash function seeds */
>>>> -	for (i = 0; i < 10; i++)
>>>> -		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
>>>> +	u8 *indir_tbl = adapter->rss_indir_tbl;
>>>>
>>>> 	/* Fill out the redirection table as follows:
>>>> -	 * 82598: 128 (8 bit wide) entries containing pair of 4 bit RSS indices
>>>> -	 * 82599/X540: 128 (8 bit wide) entries containing 4 bit RSS index
>>>> -	 * X550: 512 (8 bit wide) entries containing 6 bit RSS index
>>>> +	 *  - 82598:      8 bit wide entries containing pair of 4 bit RSS
>>>> +	 *    indices.
>>>> +	 *  - 82599/X540: 8 bit wide entries containing 4 bit RSS index
>>>> +	 *  - X550:       8 bit wide entries containing 6 bit RSS index
>>>> 	 */
>>>> 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
>>>> 		indices_multi = 0x11;
>>>> 	else
>>>> 		indices_multi = 0x1;
>>>>
>>>> -	switch (adapter->hw.mac.type) {
>>>> -	case ixgbe_mac_X550:
>>>> -	case ixgbe_mac_X550EM_x:
>>>> -		if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
>>>> -			reta_entries = 512;
>>>> -	default:
>>>> -		break;
>>>> -	}
>>>> -
>>>> -	/* Fill out redirection table */
>>>> -	for (i = 0, j = 0; i < reta_entries; i++, j++) {
>>>> -		if (j == rss_i)
>>>> -			j = 0;
>>>> -		reta = (reta << 8) | (j * indices_multi);
>>>> +	/* Write redirection table to HW */
>>>> +	for (i = 0; i < reta_entries; i++) {
>>>> +		reta = (reta << 8) | (indices_multi * indir_tbl[i]);
>>>> 		if ((i & 3) == 3) {
>>>> 			if (i < 128)
>>>> 				IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
>>>> @@ -3283,34 +3286,88 @@ static void ixgbe_setup_reta(struct ixgbe_adapter *adapter, const u32 *seed)
>>>> 	}
>>>> }
>>>>
>>>> -static void ixgbe_setup_vfreta(struct ixgbe_adapter *adapter, const u32 *seed)
>>>> +/**
>>>> + * Write the RETA table to HW (for x550 devices in SRIOV mode)
>>>> + *
>>>> + * @adapter: device handle
>>>> + *
>>>> + * Write the RSS redirection table stored in adapter.rss_indir_tbl[] to HW.
>>>> + */
>>>> +static void ixgbe_store_vfreta(struct ixgbe_adapter *adapter)
>>>> {
>>>> +	u32 i, reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
>>>> 	struct ixgbe_hw *hw = &adapter->hw;
>>>> 	u32 vfreta = 0;
>>>> +	unsigned int pf_pool = adapter->num_vfs;
>>>> +
>>>> +	/* Write redirection table to HW */
>>>> +	for (i = 0; i < reta_entries; i++) {
>>>> +		vfreta = (vfreta << 8) | adapter->rss_indir_tbl[i];
>>>> +		if ((i & 3) == 3)
>>>> +			IXGBE_WRITE_REG(hw, IXGBE_PFVFRETA(i >> 2, pf_pool),
>>>> +					vfreta);
>>>> +	}
>>>> +}
>>>> +
>>>> +static void ixgbe_setup_reta(struct ixgbe_adapter *adapter)
>>>> +{
>>>> +	struct ixgbe_hw *hw = &adapter->hw;
>>>> +	u32 i, j;
>>>> +	u32 reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
>>>> +	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
>>>> +
>>>> +	/*
>>>> +	 * Program table for at least 2 queues w/ SR-IOV so that VFs can
>>>> +	 * make full use of any rings they may have.  We will use the
>>>> +	 * PSRTYPE register to control how many rings we use within the PF.
>>>> +	 */
> This one.

I saw this warning but it wasn't me who wrote this comment so it didn't 
feel right to fix it in the functional patch. U know what, I'll fix it 
in order to silence the checkpatch.

>
>>>> +	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) && (rss_i < 2))
>>>> +		rss_i = 2;
>>>> +
>>>> +	/* Fill out hash function seeds */
>>>> +	for (i = 0; i < 10; i++)
>>>> +		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), adapter->rss_key[i]);
>>>> +
>>>> +	/* Fill out redirection table */
>>>> +	memset(adapter->rss_indir_tbl, 0, sizeof(adapter->rss_indir_tbl));
>>>> +
>>>> +	for (i = 0, j = 0; i < reta_entries; i++, j++) {
>>>> +		if (j == rss_i)
>>>> +			j = 0;
>>>> +
>>>> +		adapter->rss_indir_tbl[i] = j;
>>>> +	}
>>>> +
>>>> +	ixgbe_store_reta(adapter);
>>>> +}
>>>> +
>>>> +static void ixgbe_setup_vfreta(struct ixgbe_adapter *adapter)
>>>> +{
>>>> +	struct ixgbe_hw *hw = &adapter->hw;
>>>> 	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
>>>> 	unsigned int pf_pool = adapter->num_vfs;
>>>> 	int i, j;
>>>>
>>>> 	/* Fill out hash function seeds */
>>>> 	for (i = 0; i < 10; i++)
>>>> -		IXGBE_WRITE_REG(hw, IXGBE_PFVFRSSRK(i, pf_pool), seed[i]);
>>>> +		IXGBE_WRITE_REG(hw, IXGBE_PFVFRSSRK(i, pf_pool),
>>>> +				adapter->rss_key[i]);
>>>>
>>>> 	/* Fill out the redirection table */
>>>> 	for (i = 0, j = 0; i < 64; i++, j++) {
>>>> 		if (j == rss_i)
>>>> 			j = 0;
>>>> -		vfreta = (vfreta << 8) | j;
>>>> -		if ((i & 3) == 3)
>>>> -			IXGBE_WRITE_REG(hw, IXGBE_PFVFRETA(i >> 2, pf_pool),
>>>> -					vfreta);
>>>> +
>>>> +		adapter->rss_indir_tbl[i] = j;
>>>> 	}
>>>> +
>>>> +	ixgbe_store_vfreta(adapter);
>>>> }
>>>>
>>>> static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
>>>> {
>>>> 	struct ixgbe_hw *hw = &adapter->hw;
>>>> 	u32 mrqc = 0, rss_field = 0, vfmrqc = 0;
>>>> -	u32 rss_key[10];
>>>> 	u32 rxcsum;
>>>>
>>>> 	/* Disable indicating checksum in descriptor, enables RSS hash */
>>>> @@ -3354,7 +3411,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
>>>> 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
>>>> 		rss_field |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
>>>>
>>>> -	netdev_rss_key_fill(rss_key, sizeof(rss_key));
>>>> +	netdev_rss_key_fill(adapter->rss_key, sizeof(adapter->rss_key));
>>>> 	if ((hw->mac.type >= ixgbe_mac_X550) &&
>>>> 	    (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)) {
>>>> 		unsigned int pf_pool = adapter->num_vfs;
>>>> @@ -3364,12 +3421,12 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
>>>> 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
>>>>
>>>> 		/* Setup RSS through the VF registers */
>>>> -		ixgbe_setup_vfreta(adapter, rss_key);
>>>> +		ixgbe_setup_vfreta(adapter);
>>>> 		vfmrqc = IXGBE_MRQC_RSSEN;
>>>> 		vfmrqc |= rss_field;
>>>> 		IXGBE_WRITE_REG(hw, IXGBE_PFVFMRQC(pf_pool), vfmrqc);
>>>> 	} else {
>>>> -		ixgbe_setup_reta(adapter, rss_key);
>>>> +		ixgbe_setup_reta(adapter);
>>>> 		mrqc |= rss_field;
>>>> 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
>>>> 	}
>>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>>>> index c3ddc94..0c671b1 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h>
>>>> @@ -311,6 +311,13 @@ struct ixgbe_thermal_sensor_data {
>>>> #define IXGBE_ERETA(_i)	(0x0EE80 + ((_i) * 4))  /* 96 of these (0-95) */
>>>> #define IXGBE_RSSRK(_i) (0x05C80 + ((_i) * 4))  /* 10 of these (0-9) */
>>>>
>>>> +/* maximum number of RETA entries among all devices supported by ixgbe
>>>> + * driver: currently it's x550 device in non-SRIOV mode
>>>> + */
>>>> +#define IXGBE_MAX_RETA_ENTRIES 512
>>>> +
>>>> +#define IXGBE_RSS_KEY_SIZE     40  /* size of RSS Hash Key in bytes */
>>>> +
>>> These defines should be in ixgbe.h
>> Why? These are HW related macros and IMHO they belong to ixgbe_type.h
>> with other HW related macros and not to ixgbe.h where SW related macros are.
> These are just size/limits defines and we keep many of those in ixgbe.h.

These are HW sizes/limits.

> If it happens that we need them in the files that deal strictly with HW then it probably makes sense to have them in ixgbe_type.h, but I don't see this being the case here.

That's a strange strategy to separate the values not by their nature but 
by the nature of their usage but whatever... I'll move it to ixgbe.h in v2.

>
> Thanks,
> Emil
>
