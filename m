From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] [v2] i40e: avoid 64-bit division where
 possible
Date: Tue, 17 Oct 2017 22:37:40 -0700
Message-ID: <ae467f28-a972-dc2d-1bc8-e8ce4c7d9d68@intel.com>
References: <20171017155001.318184-1-arnd@arndb.de>
 <CAKgT0UfeDJomnen_2PhgnHSi27YROjTAtT=OYEj0JNVD8fzcOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Mitch Williams <mitch.a.williams@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        Filip Sadowski <filip.sadowski@intel.com>,
        "David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UfeDJomnen_2PhgnHSi27YROjTAtT=OYEj0JNVD8fzcOw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2017 10:33 AM, Alexander Duyck wrote:
> On Tue, Oct 17, 2017 at 8:49 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> The new bandwidth calculation caused a link error on 32-bit
>> architectures, like
>>
>> ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko] undefined!
>>
>> The problem is the max_tx_rate calculation that uses 64-bit integers.
>> This is not really necessary since the numbers are in MBit/s so
>> they won't be higher than 40000 for the highest support rate, and
>> are guaranteed to not exceed 2^32 in future generations either.
>>
>> Another patch from Alan Brady fixed the link error by adding
>> many calls to do_div(), which makes the code less efficent and
>> less readable than necessary.
>>
>> This changes the representation to 'u32' when dealing with MBit/s
>> and uses div_u64() to convert from u64 numbers in byte/s, reverting
>> parts of Alan's earlier fix that have become obsolete now.
>>

This patch breaks the functionality while converting the rates in
bytes/s provided by tc-layer into the Mbit/s in the driver.
I40E_BW_MBPS_DIVISOR defined in Alan's patch should be used for the
conversion, and not I40E_BW_CREDIT_DIVISOR which does the incorrect
math. I40E_BW_CREDIT_DIVISOR is in place because the device uses credit
rates in values of 50Mbps.

>> Fixes: 2027d4deacb1 ("i40e: Add support setting TC max bandwidth rates")
>> Fixes: 73983b5ae011 ("i40e: fix u64 division usage")
>> Cc: Alan Brady <alan.brady@intel.com>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> So this patch looks good to me, we just need to test it to verify it
> doesn't break existing functionality. In the meantime if Alan's patch
> has gone through testing we should probably push "i40e: fix u64
> division usage" to Dave so that we can at least fix the linking issues
> on ARM and i386.
> 
> Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e.h      |  4 +-
>>  drivers/net/ethernet/intel/i40e/i40e_main.c | 70 +++++++++++------------------
>>  2 files changed, 27 insertions(+), 47 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
>> index c3f13120f3ce..c7aa0c982273 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e.h
>> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
>> @@ -407,7 +407,7 @@ struct i40e_channel {
>>         u8 enabled_tc;
>>         struct i40e_aqc_vsi_properties_data info;
>>
>> -       u64 max_tx_rate;
>> +       u32 max_tx_rate; /* in Mbits/s */
>>
>>         /* track this channel belongs to which VSI */
>>         struct i40e_vsi *parent_vsi;
>> @@ -1101,5 +1101,5 @@ static inline bool i40e_enabled_xdp_vsi(struct i40e_vsi *vsi)
>>  }
>>
>>  int i40e_create_queue_channel(struct i40e_vsi *vsi, struct i40e_channel *ch);
>> -int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate);
>> +int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u32 max_tx_rate);
>>  #endif /* _I40E_H_ */
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index 3ceda140170d..57682cc78508 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -5448,17 +5448,16 @@ int i40e_get_link_speed(struct i40e_vsi *vsi)
>>   *
>>   * Helper function to set BW limit for a given VSI
>>   **/
>> -int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
>> +int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u32 max_tx_rate)
>>  {
>>         struct i40e_pf *pf = vsi->back;
>> -       u64 credits = 0;
>>         int speed = 0;
>>         int ret = 0;
>>
>>         speed = i40e_get_link_speed(vsi);
>>         if (max_tx_rate > speed) {
>>                 dev_err(&pf->pdev->dev,
>> -                       "Invalid max tx rate %llu specified for VSI seid %d.",
>> +                       "Invalid max tx rate %u specified for VSI seid %d.",
>>                         max_tx_rate, seid);
>>                 return -EINVAL;
>>         }
>> @@ -5469,13 +5468,12 @@ int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
>>         }
>>
>>         /* Tx rate credits are in values of 50Mbps, 0 is disabled */
>> -       credits = max_tx_rate;
>> -       do_div(credits, I40E_BW_CREDIT_DIVISOR);
>> -       ret = i40e_aq_config_vsi_bw_limit(&pf->hw, seid, credits,
>> +       ret = i40e_aq_config_vsi_bw_limit(&pf->hw, seid,
>> +                                         max_tx_rate / I40E_BW_CREDIT_DIVISOR,
>>                                           I40E_MAX_BW_INACTIVE_ACCUM, NULL);
>>         if (ret)
>>                 dev_err(&pf->pdev->dev,
>> -                       "Failed set tx rate (%llu Mbps) for vsi->seid %u, err %s aq_err %s\n",
>> +                       "Failed set tx rate (%u Mbps) for vsi->seid %u, err %s aq_err %s\n",
>>                         max_tx_rate, seid, i40e_stat_str(&pf->hw, ret),
>>                         i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
>>         return ret;
>> @@ -6158,17 +6156,13 @@ int i40e_create_queue_channel(struct i40e_vsi *vsi,
>>
>>         /* configure VSI for BW limit */
>>         if (ch->max_tx_rate) {
>> -               u64 credits = ch->max_tx_rate;
>> -
>>                 if (i40e_set_bw_limit(vsi, ch->seid, ch->max_tx_rate))
>>                         return -EINVAL;
>>
>> -               do_div(credits, I40E_BW_CREDIT_DIVISOR);
>>                 dev_dbg(&pf->pdev->dev,
>> -                       "Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
>> +                       "Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
>>                         ch->max_tx_rate,
>> -                       credits,
>> -                       ch->seid);
>> +                       ch->max_tx_rate / I40E_BW_CREDIT_DIVISOR, ch->seid);
>>         }
>>
>>         /* in case of VF, this will be main SRIOV VSI */
>> @@ -6189,7 +6183,6 @@ int i40e_create_queue_channel(struct i40e_vsi *vsi,
>>  static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
>>  {
>>         struct i40e_channel *ch;
>> -       u64 max_rate = 0;
>>         int ret = 0, i;
>>
>>         /* Create app vsi with the TCs. Main VSI with TC0 is already set up */
>> @@ -6211,9 +6204,8 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
>>                         /* Bandwidth limit through tc interface is in bytes/s,
>>                          * change to Mbit/s
>>                          */
>> -                       max_rate = vsi->mqprio_qopt.max_rate[i];
>> -                       do_div(max_rate, I40E_BW_MBPS_DIVISOR);
>> -                       ch->max_tx_rate = max_rate;
>> +                       ch->max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[i],
>> +                                                 I40E_BW_CREDIT_DIVISOR);
>>

Use I40E_BW_MBPS_DIVISOR for the conversion math here.

>>                         list_add_tail(&ch->list, &vsi->ch_list);
>>
>> @@ -6643,7 +6635,6 @@ static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
>>                                      struct tc_mqprio_qopt_offload *mqprio_qopt)
>>  {
>>         u64 sum_max_rate = 0;
>> -       u64 max_rate = 0;
>>         int i;
>>
>>         if (mqprio_qopt->qopt.offset[0] != 0 ||
>> @@ -6658,9 +6649,8 @@ static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
>>                                 "Invalid min tx rate (greater than 0) specified\n");
>>                         return -EINVAL;
>>                 }
>> -               max_rate = mqprio_qopt->max_rate[i];
>> -               do_div(max_rate, I40E_BW_MBPS_DIVISOR);
>> -               sum_max_rate += max_rate;
>> +               sum_max_rate += div_u64(mqprio_qopt->max_rate[i],
>> +                                       I40E_BW_CREDIT_DIVISOR);

Use I40E_BW_MBPS_DIVISOR here.

>>
>>                 if (i >= mqprio_qopt->qopt.num_tc - 1)
>>                         break;
>> @@ -6804,18 +6794,14 @@ static int i40e_setup_tc(struct net_device *netdev, void *type_data)
>>
>>         if (pf->flags & I40E_FLAG_TC_MQPRIO) {
>>                 if (vsi->mqprio_qopt.max_rate[0]) {
>> -                       u64 max_tx_rate = vsi->mqprio_qopt.max_rate[0];
>> -
>> -                       do_div(max_tx_rate, I40E_BW_MBPS_DIVISOR);
>> +                       u32 max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[0],
>> +                                                 I40E_BW_CREDIT_DIVISOR);

Use I40E_BW_MBPS_DIVISOR here.

>>                         ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
>>                         if (!ret) {
>> -                               u64 credits = max_tx_rate;
>> -
>> -                               do_div(credits, I40E_BW_CREDIT_DIVISOR);
>>                                 dev_dbg(&vsi->back->pdev->dev,
>> -                                       "Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
>> +                                       "Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
>>                                         max_tx_rate,
>> -                                       credits,
>> +                                       max_tx_rate / I40E_BW_CREDIT_DIVISOR,
>>                                         vsi->seid);
>>                         } else {
>>                                 need_reset = true;
>> @@ -9024,15 +9010,12 @@ static int i40e_rebuild_channels(struct i40e_vsi *vsi)
>>                         return ret;
>>                 }
>>                 if (ch->max_tx_rate) {
>> -                       u64 credits = ch->max_tx_rate;
>> -
>>                         if (i40e_set_bw_limit(vsi, ch->seid,
>>                                               ch->max_tx_rate))
>>                                 return -EINVAL;
>>
>> -                       do_div(credits, I40E_BW_CREDIT_DIVISOR);
>>                         dev_dbg(&vsi->back->pdev->dev,
>> -                               "Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
>> +                               "Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
>>                                 ch->max_tx_rate,
>>                                 ch->max_tx_rate / I40E_BW_CREDIT_DIVISOR,
>>                                 ch->seid);
>> @@ -9314,21 +9297,18 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
>>         }
>>
>>         if (vsi->mqprio_qopt.max_rate[0]) {
>> -               u64 max_tx_rate = vsi->mqprio_qopt.max_rate[0];
>> -               u64 credits = 0;
>> +               u32 max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[0],
>> +                                         I40E_BW_CREDIT_DIVISOR);

Use I40E_BW_MBPS_DIVISOR here.

>>
>> -               do_div(max_tx_rate, I40E_BW_MBPS_DIVISOR);
>>                 ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
>> -               if (ret)
>> +               if (!ret)
>> +                       dev_dbg(&vsi->back->pdev->dev,
>> +                               "Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
>> +                               max_tx_rate,
>> +                               max_tx_rate / I40E_BW_CREDIT_DIVISOR,
>> +                               vsi->seid);
>> +               else
>>                         goto end_unlock;
>> -
>> -               credits = max_tx_rate;
>> -               do_div(credits, I40E_BW_CREDIT_DIVISOR);
>> -               dev_dbg(&vsi->back->pdev->dev,
>> -                       "Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
>> -                       max_tx_rate,
>> -                       credits,
>> -                       vsi->seid);
>>         }
>>
>>         ret = i40e_rebuild_cloud_filters(vsi, vsi->seid);
>> --
>> 2.9.0
>>
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@osuosl.org
>> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> 
