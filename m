From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v1 1/2] ixgbe: Refactor the
 RSS configuration code.
Date: Mon, 30 Mar 2015 10:04:46 -0700
Message-ID: <5519822E.2090507@gmail.com>
References: <1427392599-18184-1-git-send-email-vladz@cloudius-systems.com> <1427392599-18184-2-git-send-email-vladz@cloudius-systems.com> <551977A9.7020602@redhat.com> <551980DE.9020207@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: avi@cloudius-systems.com, intel-wired-lan@lists.osuosl.org,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33089 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbbC3REt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:04:49 -0400
Received: by pacgg7 with SMTP id gg7so43375375pac.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 10:04:49 -0700 (PDT)
In-Reply-To: <551980DE.9020207@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2015 09:59 AM, Vlad Zolotarov wrote:
>
>
> On 03/30/15 19:19, Alexander Duyck wrote:
>>
>> On 03/26/2015 10:56 AM, Vlad Zolotarov wrote:
>>> This patch is a preparation for enablement of ethtool RSS
>>> indirection table
>>> and hash key querying. We don't want to read registers every time
>>> the RSS info
>>> is queried. Therefore we will store its current content in the
>>> arrays in the adapter struct and will read it from there (instead of
>>> from
>>> registers) when requested.
>>>
>>> Will change the code that writes the indirection table and hash key
>>> into the HW registers
>>> to take its content from these arrays. This will also simplify the
>>> indirection
>>> table updating ethtool callback implementation in the future.
>>>
>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>> ---
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   2 +
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 143
>>> ++++++++++++++++++--------
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |   7 ++
>>>   3 files changed, 109 insertions(+), 43 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>> index 5e44e48..402d182 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>> @@ -766,6 +766,8 @@ struct ixgbe_adapter {
>>>         u8 default_up;
>>>       unsigned long fwd_bitmask; /* Bitmask indicating in use pools */
>>> +    u8 rss_indir_tbl[IXGBE_MAX_RETA_ENTRIES];
>>> +    u32 rss_key[IXGBE_RSS_KEY_SIZE / sizeof(u32)];
>>>   };
>>>     static inline u8 ixgbe_max_rss_indices(struct ixgbe_adapter
>>> *adapter)
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index 8853d52..e3de0c9 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -3228,51 +3228,54 @@ static void ixgbe_configure_srrctl(struct
>>> ixgbe_adapter *adapter,
>>>       IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
>>>   }
>>>   -static void ixgbe_setup_reta(struct ixgbe_adapter *adapter, const
>>> u32 *seed)
>>> +/**
>>> + * Return a number of entries in the RSS indirection table
>>> + *
>>> + * @adapter: device handle
>>> + *
>>> + *  - 82598/82599/X540:     128
>>> + *  - X550(non-SRIOV mode): 512
>>> + *  - X550(SRIOV mode):     64
>>> + */
>>> +static u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
>>> +{
>>> +    if (adapter->hw.mac.type < ixgbe_mac_X550)
>>> +        return 128;
>>> +    else if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
>>> +        return 64;
>>> +    else
>>> +        return 512;
>>> +}
>>> +
>>> +/**
>>> + * Write the RETA table to HW
>>> + *
>>> + * @adapter: device handle
>>> + *
>>> + * Write the RSS redirection table stored in
>>> adapter.rss_indir_tbl[] to HW.
>>> + */
>>> +static void ixgbe_store_reta(struct ixgbe_adapter *adapter)
>>>   {
>>> +    u32 i, reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
>>>       struct ixgbe_hw *hw = &adapter->hw;
>>>       u32 reta = 0;
>>> -    int i, j;
>>> -    int reta_entries = 128;
>>> -    u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
>>>       int indices_multi;
>>> -
>>> -    /*
>>> -     * Program table for at least 2 queues w/ SR-IOV so that VFs can
>>> -     * make full use of any rings they may have.  We will use the
>>> -     * PSRTYPE register to control how many rings we use within the
>>> PF.
>>> -     */
>>> -    if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) && (rss_i < 2))
>>> -        rss_i = 2;
>>> -
>>> -    /* Fill out hash function seeds */
>>> -    for (i = 0; i < 10; i++)
>>> -        IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
>>> +    u8 *indir_tbl = adapter->rss_indir_tbl;
>>>         /* Fill out the redirection table as follows:
>>> -     * 82598: 128 (8 bit wide) entries containing pair of 4 bit RSS
>>> indices
>>> -     * 82599/X540: 128 (8 bit wide) entries containing 4 bit RSS index
>>> -     * X550: 512 (8 bit wide) entries containing 6 bit RSS index
>>> +     *  - 82598:      8 bit wide entries containing pair of 4 bit RSS
>>> +     *    indices.
>>> +     *  - 82599/X540: 8 bit wide entries containing 4 bit RSS index
>>> +     *  - X550:       8 bit wide entries containing 6 bit RSS index
>>>        */
>>>       if (adapter->hw.mac.type == ixgbe_mac_82598EB)
>>>           indices_multi = 0x11;
>>>       else
>>>           indices_multi = 0x1;
>>>   -    switch (adapter->hw.mac.type) {
>>> -    case ixgbe_mac_X550:
>>> -    case ixgbe_mac_X550EM_x:
>>> -        if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
>>> -            reta_entries = 512;
>>> -    default:
>>> -        break;
>>> -    }
>>> -
>>> -    /* Fill out redirection table */
>>> -    for (i = 0, j = 0; i < reta_entries; i++, j++) {
>>> -        if (j == rss_i)
>>> -            j = 0;
>>> -        reta = (reta << 8) | (j * indices_multi);
>>> +    /* Write redirection table to HW */
>>> +    for (i = 0; i < reta_entries; i++) {
>>> +        reta = (reta << 8) | (indices_multi * indir_tbl[i]);
>>>           if ((i & 3) == 3) {
>>>               if (i < 128)
>>>                   IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
>>
>> I am pretty sure this is being written in the wrong byte order. Entry
>> 0 should be the lowest bits in the register, not the highest.
>
> The order of entries doesn't seem to be important here.
>
> thanks,
> vlad

Huh?  It is populating the register as (0 << 24) | (1 << 16) | (2 << 8)
| (3 << 0) which means the 3rd entry is populating the entry belonging
to what should be entry 0.  This is fine as long as we aren't reporting
it or allowing changes.  However, now that it is being reported via your
changes it matters.  Otherwise if someone were to take the key and the
redirection table and do the calculations themselves the results
provided by the hardware would appear to be wrong.

In order to get the ordering right we need to either byteswap the reta
value before we write it, or generate the value in the correct order
which should be (3 << 24) | (2 << 16) | (1 << 8) | 0.

- Alex
