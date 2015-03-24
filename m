From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Tue, 24 Mar 2015 21:06:22 +0200
Message-ID: <5511B5AE.1090905@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36174 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454AbbCXTG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:06:26 -0400
Received: by wgra20 with SMTP id a20so1824514wgr.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 12:06:24 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/15 20:12, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Tuesday, March 24, 2015 3:26 AM
>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>
>>
>>
>> On 03/24/15 01:46, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vlad Zolotarov
>>>> Sent: Sunday, March 22, 2015 12:01 PM
>>>>
>>>> Subject: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>>>
>>>>     - Added a new API version support.
>>>>     - Added the query implementation in the ixgbevf.
>>>>
>>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>>> ---
>>>> New in v6:
>>>>     - Add a proper return code when an operation is blocked by PF.
>>>>
>>>> New in v3:
>>>>     - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>>>>     - Added a proper support for x550 devices.
>>>>
>>>> New in v1 (compared to RFC):
>>>>     - Use "if-else" statement instead of a "switch-case" for a single option case
>>>>       (in ixgbevf_get_reta()).
>>>> ---
>>>> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
>>>> drivers/net/ethernet/intel/ixgbevf/mbx.h          |  8 ++
>>>> drivers/net/ethernet/intel/ixgbevf/vf.c           | 92 +++++++++++++++++++++++
>>>> drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>>>> 4 files changed, 104 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c >>>b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>> index 4ee15ad..4787fcf 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>> @@ -2030,7 +2030,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
>>>> static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
>>>> {
>>>> 	struct ixgbe_hw *hw = &adapter->hw;
>>>> -	int api[] = { ixgbe_mbox_api_11,
>>>> +	int api[] = { ixgbe_mbox_api_12,
>>>> +		      ixgbe_mbox_api_11,
>>>> 		      ixgbe_mbox_api_10,
>>>> 		      ixgbe_mbox_api_unknown };
>>>> 	int err = 0, idx = 0;
>>>> @@ -3712,6 +3713,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
>>>>
>>>> 	switch (adapter->hw.api_version) {
>>>> 	case ixgbe_mbox_api_11:
>>>> +	case ixgbe_mbox_api_12:
>>>> 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
>>>> 		break;
>>>> 	default:
>>> You need another case for ixgbe_mbox_api_12 in ixgbevf_set_num_queues(), otherwise the driver will load with a >>single queue.
>> Right. I've missed this place since it's been added after the first
>> series version and 'git rebase' silently integrated it... ;)
>>
>> I have a question about this new code though. Why does ixgbevf ignores
>> IXGBE_VF_RX_QUEUES PF returns it in IXGBE_VF_GET_QUEUE?
>> PF returns there 1 by the way (see ixgbe_get_vf_queues()) despite the
>> fact it configures the VF to have up to 4 queues... I do understand why
>> it allows up to 4 queues but why does it return 1 for IXGBE_VF_RX_QUEUES
>> in IXGBE_VF_GET_QUEUE? Shouldn't it return 4 there?
> I'm not sure where you see this, on my setup ixgbevf_get_queues() gets 4 in msg[IXGBE_VF_R/TX_QUEUES] which is used to set hw->mac.max_t/rx_queues.

Right. I misread the __ALIGN_MASK() macro.
But then I can't see where max_rx_queues is used. 
ixgbevf_set_num_queues() sets adapter->num_rx_queues ignoring the above 
value if num_tcs less or equal to 1:

/* fetch queue configuration from the PF */
	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);

	spin_unlock_bh(&adapter->mbx_lock);

	if (err)
		return;

	/* we need as many queues as traffic classes */
	if (num_tcs > 1) {
		adapter->num_rx_queues = num_tcs;
	} else {
		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);

		switch (hw->api_version) {
		case ixgbe_mbox_api_11:
		case ixgbe_mbox_api_12:
			adapter->num_rx_queues = rss;
			adapter->num_tx_queues = rss;
		default:
			break;
		}
	}

This means that if PF returned in IXGBE_VF_RX_QUEUES 1 and if u have 
more than 1 CPU u will still go and configure 2 Rx queues for a VF. This 
unless I miss something again... ;)
>
> BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link down/up when querying it.

Worked just fine to me on x540.
What is your setup? How did u check it? Did u remember to patch "ip" 
tool and enable the querying?

>
> Where is this information useful anyway - what is the use case? There is no description in your patches for why all this is needed.

I'm not sure it's required to explain why would I want to add a standard 
ethtool functionality to a driver.
However, since u've asked - we are developing a software infrastructure 
that needs the ability to query the VF's indirection table and RSS hash 
key from inside the Guest OS (particularly on AWS) in order to be able 
to open the socket the way that its traffic would arrive to a specific CPU.

Once this patches are accepted here we may start asking Amazon to pull 
them too.

thanks,
vlad

>
> Thanks,
> Emil
>
>
