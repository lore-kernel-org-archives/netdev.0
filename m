From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
Date: Wed, 19 Nov 2014 14:41:12 -0500
Message-ID: <546CF258.9050205@gmail.com>
References: <1416338897-13007-1-git-send-email-vyasevic@redhat.com> <87618083B2453E4A8714035B62D679925019F38A@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:65387 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbaKSTlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 14:41:20 -0500
Received: by mail-qa0-f47.google.com with SMTP id s7so902181qap.6
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 11:41:19 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D679925019F38A@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2014 03:24 PM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Vladislav Yasevich
>> Sent: Tuesday, November 18, 2014 11:28 AM
>> To: netdev@vger.kernel.org
>> Cc: Vladislav Yasevich; Kirsher, Jeffrey T; Keller, Jacob E
>> Subject: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
>>
>> IXGBE adapater seems to require that vlan filtering be enabled if VMDQ
>> or SRIOV are enabled.  When those functions are disabled,
>> vlan filtering may be disabled in promiscuous mode.
>>
>> Prior to commit a9b8943ee129e11045862d6d6e25c5b63c95403c
>>    ixgbe: remove vlan_filter_disable and enable functions
>>
>> the logic was correct.  However, after the commit the logic
>> got reversed and vlan filtered in now turned on when VMDQ/SRIOV
>> is disabled.
>>
>> This patch changes the condition to enable hw vlan filtered
>> when VMDQ or SRIOV is enabled.
>>
>> Fixes: a9b8943ee129e11045862d6d6e25c5b63c95403c (ixgbe:
>> remove
>> vlan_filter_disable and enable functions)
>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> CC: Jacob Keller <jacob.e.keller@intel.com>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index d2df4e3..3f81c7a 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct
>> net_device *netdev)
>> 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
>> 		 * that hardware VLAN filters remain enabled.
>> 		 */
>> -		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>> -					IXGBE_FLAG_SRIOV_ENABLED)))
>> +		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
>> +				      IXGBE_FLAG_SRIOV_ENABLED))
>> 			vlnctrl |= (IXGBE_VLNCTRL_VFE |
>> IXGBE_VLNCTRL_CFIEN);
>> 	} else {
>> 		if (netdev->flags & IFF_ALLMULTI) {
> 
> The current logic is correct and it's like this on purpose as it should be obvious by the comment preceding this check. 

Actually the comment right now does not match what the code is doing.

The comment states:
                /* Only disable hardware filter vlans in promiscuous mode
                 * if SR-IOV and VMDQ are disabled - otherwise ensure
                 * that hardware VLAN filters remain enabled.
                 */

However, the code currently will _enable_ vlan filtering if VMDQ/SRIOV
is _disabled_ in promiscuous mode.


> The reason for not disabling the vlan filters in promisc mode is because this can break VLAN isolation between VMs which is considered a security risk.

But VLAN isolation between VMs isn't enforced if you have a simple bridged
setup without VMDQs or SRIOV enabled.  Bridge makes all devices promiscuous
and should receive all VLANs.

-vlad

> 
> There is another patch that was proposed:
> http://marc.info/?l=linux-netdev&m=141586938625969
> 
> which should do what you want using an ethtool toggle.
> 
> Thanks,
> Emil
> 
> 
