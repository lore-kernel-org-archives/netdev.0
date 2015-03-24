From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Tue, 24 Mar 2015 18:12:47 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com>
 <55113B9B.3090308@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40437 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbbCXSMu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:12:50 -0400
In-Reply-To: <55113B9B.3090308@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com] 
>Sent: Tuesday, March 24, 2015 3:26 AM
>Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>
>
>
>On 03/24/15 01:46, Tantilov, Emil S wrote:
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vlad Zolotarov
>>> Sent: Sunday, March 22, 2015 12:01 PM
>>>
>>> Subject: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>>
>>>    - Added a new API version support.
>>>    - Added the query implementation in the ixgbevf.
>>>
>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>>> ---
>>> New in v6:
>>>    - Add a proper return code when an operation is blocked by PF.
>>>
>>> New in v3:
>>>    - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>>>    - Added a proper support for x550 devices.
>>>
>>> New in v1 (compared to RFC):
>>>    - Use "if-else" statement instead of a "switch-case" for a single option case
>>>      (in ixgbevf_get_reta()).
>>> ---
>>> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
>>> drivers/net/ethernet/intel/ixgbevf/mbx.h          |  8 ++
>>> drivers/net/ethernet/intel/ixgbevf/vf.c           | 92 +++++++++++++++++++++++
>>> drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>>> 4 files changed, 104 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c >>>b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> index 4ee15ad..4787fcf 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> @@ -2030,7 +2030,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
>>> static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
>>> {
>>> 	struct ixgbe_hw *hw = &adapter->hw;
>>> -	int api[] = { ixgbe_mbox_api_11,
>>> +	int api[] = { ixgbe_mbox_api_12,
>>> +		      ixgbe_mbox_api_11,
>>> 		      ixgbe_mbox_api_10,
>>> 		      ixgbe_mbox_api_unknown };
>>> 	int err = 0, idx = 0;
>>> @@ -3712,6 +3713,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
>>>
>>> 	switch (adapter->hw.api_version) {
>>> 	case ixgbe_mbox_api_11:
>>> +	case ixgbe_mbox_api_12:
>>> 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
>>> 		break;
>>> 	default:
>> You need another case for ixgbe_mbox_api_12 in ixgbevf_set_num_queues(), otherwise the driver will load with a >>single queue.
>
>Right. I've missed this place since it's been added after the first 
>series version and 'git rebase' silently integrated it... ;)
>
>I have a question about this new code though. Why does ixgbevf ignores 
>IXGBE_VF_RX_QUEUES PF returns it in IXGBE_VF_GET_QUEUE?
>PF returns there 1 by the way (see ixgbe_get_vf_queues()) despite the 
>fact it configures the VF to have up to 4 queues... I do understand why 
>it allows up to 4 queues but why does it return 1 for IXGBE_VF_RX_QUEUES 
>in IXGBE_VF_GET_QUEUE? Shouldn't it return 4 there?

I'm not sure where you see this, on my setup ixgbevf_get_queues() gets 4 in msg[IXGBE_VF_R/TX_QUEUES] which is used to set hw->mac.max_t/rx_queues.

BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link down/up when querying it.

Where is this information useful anyway - what is the use case? There is no description in your patches for why all this is needed.

Thanks,
Emil
