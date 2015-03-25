From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [net-next 05/16] ixgbevf: enable multiple queue support
Date: Wed, 25 Mar 2015 22:35:31 +0200
Message-ID: <55131C13.2000607@cloudius-systems.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com> <1423128950-12388-6-git-send-email-jeffrey.t.kirsher@intel.com> <55127581.2080205@cloudius-systems.com> <5512FEDC.7080902@redhat.com> <55131153.2090401@cloudius-systems.com> <551317A0.6090108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35921 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbbCYUff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 16:35:35 -0400
Received: by wibg7 with SMTP id g7so124068787wib.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 13:35:34 -0700 (PDT)
In-Reply-To: <551317A0.6090108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 22:16, Alexander Duyck wrote:
>
> On 03/25/2015 12:49 PM, Vlad Zolotarov wrote:
>> On 03/25/15 20:30, Alexander Duyck wrote:
>>> On 03/25/2015 01:44 AM, Vlad Zolotarov wrote:
>>>> On 02/05/15 11:35, Jeff Kirsher wrote:
>>>>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>>
>>>>
>>>>>     #define IXGBEVF_DEFAULT_TXD 1024
>>>>>   #define IXGBEVF_DEFAULT_RXD   512
>>>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c 
>>>>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>>> index c9b49bf..815808f 100644
>>>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>>>> @@ -1794,7 +1794,8 @@ static int ixgbevf_configure_dcb(struct 
>>>>> ixgbevf_adapter *adapter)
>>>>>       struct ixgbe_hw *hw = &adapter->hw;
>>>>>       unsigned int def_q = 0;
>>>>>       unsigned int num_tcs = 0;
>>>>> -    unsigned int num_rx_queues = 1;
>>>>> +    unsigned int num_rx_queues = adapter->num_rx_queues;
>>>>> +    unsigned int num_tx_queues = adapter->num_tx_queues;
>>>>>       int err;
>>>>>         spin_lock_bh(&adapter->mbx_lock);
>>>>> @@ -1808,6 +1809,9 @@ static int ixgbevf_configure_dcb(struct 
>>>>> ixgbevf_adapter *adapter)
>>>>>           return err;
>>>>>         if (num_tcs > 1) {
>>>>> +        /* we need only one Tx queue */
>>>>> +        num_tx_queues = 1;
>>>>> +
>>>>>           /* update default Tx ring register index */
>>>>>           adapter->tx_ring[0]->reg_idx = def_q;
>>>>>   @@ -1816,7 +1820,8 @@ static int ixgbevf_configure_dcb(struct 
>>>>> ixgbevf_adapter *adapter)
>>>>>       }
>>>>>         /* if we have a bad config abort request queue reset */
>>>>> -    if (adapter->num_rx_queues != num_rx_queues) {
>>>>> +    if ((adapter->num_rx_queues != num_rx_queues) ||
>>>>> +        (adapter->num_tx_queues != num_tx_queues)) {
>>>>>           /* force mailbox timeout to prevent further messages */
>>>>>           hw->mbx.timeout = 0;
>>>>>   @@ -2181,8 +2186,19 @@ static void ixgbevf_set_num_queues(struct 
>>>>> ixgbevf_adapter *adapter)
>>>>>           return;
>>>>>         /* we need as many queues as traffic classes */
>>>>> -    if (num_tcs > 1)
>>>>> +    if (num_tcs > 1) {
>>>>>           adapter->num_rx_queues = num_tcs;
>>>>> +    } else {
>>>>> +        u16 rss = min_t(u16, num_online_cpus(), 
>>>>> IXGBEVF_MAX_RSS_QUEUES);
>>>>
>>>> Emil,
>>>> Here u ignore the IXGBE_VF_RX_QUEUES value returned the PF (stored 
>>>> in the hw->mac.max_rx_queues). This will accidentally work if PF is 
>>>> driven by a current ixgbe Linux driver but what would happen if HV 
>>>> is not a Linux box? What if HV decides to configure the 
>>>> PSRTYPE[x].RQPL to 0 and decide that VF should be configured with a 
>>>> single queue? I maybe miss something here but the above line seems 
>>>> bogus. Please, comment.
>>>
>>> It isn't ignored.  The fact that num_tcs is being tested for checks 
>>> for the one case where the number of RSS queues available would be 
>>> 1, otherwise the hardware will provide at least 2 queues. 
>>
>>> If the RETA is not configured for 2 queues one of them will not be 
>>> active, but that should not be any sort of actual issue and would be 
>>> more of an administrative choice anyway as it would also limit the PF.
>>
>> This would be an administrative choice ignored by the ixgbevf driver.
>
> What are you talking about?  How is this an administrative choice? 
> When you configure SR-IOV one of the decisions is to select the queue 
> layout.

And another administrative choice may be to allow the VF to use only a 
single queue due to reasons not related to Intel HW at all. I've told 
about it before.

> There is no layout that gives the VF less than 2 queues.  Your 
> argument makes no sense.  That is why this keeps going back and forth.

My argument makes perfect sense and u would see it if u stopped thinking 
only about the ixgbe when we talk about the PF driver. One day PF driver 
may be able to get the limitation of the VF queues number from the 
system administrator and it may decide to limit it by 1.

>
>> Frankly, I don't understand why are we arguing about this for so 
>> long? It's obvious that the safest and the most correct way to write 
>> it would be to limit the num_rx_queues by the value returned by PF. 
>> It would also remove any further questions and it's a one line patch.
>> However, if u still insist to keep it the way it is then let's drop 
>> this discussion and move on.
>
> There is nothing the PF can do to deny access to the 2 queues that 
> belong to the VF, they are there.  All Emil's patch does is give the 
> VF the ability to use the 2 queues for RSS, if it decides to, in order 
> to make better use of system resources.  If the RETA is populated for 
> only one queue then worst case is that the VF is wasting resources on 
> a queue that will go unused.
>
> What concerns me is that you keep talking about a hypothetical PF 
> driver which quite frankly can't be supported by the hardware.  If 
> there is something you are working on that these changes break then I 
> would recommend coming forward with the code for it via something such 
> as an RFC so we can start a conversation, otherwise there is no way to 
> help you since we have no idea what you are talking about.

Alex, I don't need any help - on the contrary, I'm trying to help u by 
reviewing your code. For me the problem is clear - u clearly ignore your 
own design: u query the PF about the VF queues number and ignore it. U 
won't utilize the system resources any worse if u wouldn't ignore it but 
If u think this is ok - then be it. It would be u, guys, that would have 
to deal with it when and if u get any complains from the users.

I have nothing to add any more here. Do whatever u think is right for u.

Best regards,
vlad

>
> - Alex
