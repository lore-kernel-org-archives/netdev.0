From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [net-next 05/16] ixgbevf: enable multiple queue support
Date: Wed, 25 Mar 2015 18:27:44 +0200
Message-ID: <5512E200.6070708@cloudius-systems.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com> <1423128950-12388-6-git-send-email-jeffrey.t.kirsher@intel.com> <55127581.2080205@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250275731@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36659 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbbCYQ1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 12:27:48 -0400
Received: by wibg7 with SMTP id g7so116037441wib.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 09:27:46 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250275731@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 16:32, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Wednesday, March 25, 2015 1:45 AM
>> Subject: Re: [net-next 05/16] ixgbevf: enable multiple queue support
>>
>>
>> On 02/05/15 11:35, Jeff Kirsher wrote:
>>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>>
>> This patch enables multiple queues and RSS support for the VF.
>>> Maximum of 2 queues are supported due to available vectors.
>>>
>>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>>> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>    drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
>>>    drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 +++++++++++++++++++---
>>>    2 files changed, 20 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> index 8c44ab2..65cda34 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>>> @@ -124,6 +124,7 @@ struct ixgbevf_ring {
>>>    
>>>    #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
>>>    #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
>>> +#define IXGBEVF_MAX_RSS_QUEUES 2
>> According to the MRQE register description in 82599 and x540 specs 2
>> (the value of IXGBEVF_MAX_RSS_QUEUES) is the minimal allowed number of
>> queues in a single pool thus it's a minimal number of VF queues - not
>> the maximal (see more comments on this below).
> The VF driver can have a maximum of 2 queues as mentioned in the description.
> The driver will attempt to allocate the maximum number of queues allowed.
>
> All of the virtualization enabled modes of MRQC.MRQE have at least 2 queues.

Exactly!
To summarize:

  - 2 is a minimum allowed number of queues that may be assigned to a 
single pool.
  - 2 is currently a maximal number of MSI-X interrupts chosen to be 
allowed to be configured by an ixgbevf driver for a single function.

That's why I said calling it a "maximum number of queues", while it is 
actually a minimum is a bit confusing.

>
>>>    #define IXGBEVF_DEFAULT_TXD   1024
>>>    #define IXGBEVF_DEFAULT_RXD   512
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c >>b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> index c9b49bf..815808f 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> @@ -1794,7 +1794,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>>>    	struct ixgbe_hw *hw = &adapter->hw;
>>>    	unsigned int def_q = 0;
>>>    	unsigned int num_tcs = 0;
>>> -	unsigned int num_rx_queues = 1;
>>> +	unsigned int num_rx_queues = adapter->num_rx_queues;
>>> +	unsigned int num_tx_queues = adapter->num_tx_queues;
>>>    	int err;
>>>    
>>>    	spin_lock_bh(&adapter->mbx_lock);
>>> @@ -1808,6 +1809,9 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>>>    		return err;
>>>    
>>>    	if (num_tcs > 1) {
>>> +		/* we need only one Tx queue */
>>> +		num_tx_queues = 1;
>>> +
>>>    		/* update default Tx ring register index */
>>>    		adapter->tx_ring[0]->reg_idx = def_q;
>>>    
>>> @@ -1816,7 +1820,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>>>    	}
>>>    
>>>    	/* if we have a bad config abort request queue reset */
>>> -	if (adapter->num_rx_queues != num_rx_queues) {
>>> +	if ((adapter->num_rx_queues != num_rx_queues) ||
>>> +	    (adapter->num_tx_queues != num_tx_queues)) {
>>>    		/* force mailbox timeout to prevent further messages */
>>>    		hw->mbx.timeout = 0;
>>>    
>>> @@ -2181,8 +2186,19 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
>>>    		return;
>>>    
>>>    	/* we need as many queues as traffic classes */
>>> -	if (num_tcs > 1)
>>> +	if (num_tcs > 1) {
>>>    		adapter->num_rx_queues = num_tcs;
>>> +	} else {
>>> +		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);
>> Emil,
>> Here u ignore the IXGBE_VF_RX_QUEUES value returned the PF (stored in
>> the hw->mac.max_rx_queues).
> Again the VF driver allocates the maximum number of queues possible it is not driven by the PF.

AFAIK VF IS driven by a PF in all related to resources configuration 
including the queues assignment. That's why VF driver has to follow the 
configuration PF defines. Otherwise VF HW may just not work as expected 
(at least as expected by the system administrator controlling the 
Hypervisor).

>
>> This will accidentally work if PF is driven
>> by a current ixgbe Linux driver but what would happen if HV is not a
>> Linux box?
> Do you know of a driver that has an issue in this configuration?

Nope, but I know for sure that VF can't ignore what PF tells u and this 
is clearly a bug. I think I have described the possible configuration 
that may lead to VF malfunction below.

>
>> What if HV decides to configure the PSRTYPE[x].RQPL to 0 and
>> decide that VF should be configured with a single queue? I maybe miss
>> something here but the above line seems bogus. Please, comment.
> PSRTYPE.RQPL - this field only has meaning when MRQC.MRQE is configured to allow multiple queues, so if I have to guess I would say that if there was such a driver it would be miss-configured, but even then the VF can have 2 queues, RSS just likely won't work.

That's an absolutely legal configuration and u are missing the main 
point here - VF has to obey by the PF rules which are controlled by the 
Hypervisor's system administrator and administrator may decide (due to 
his/her reasons, e.g. in order to save some memory) to allow only a 
single queue for each VF device and VF device driver is expected to 
listen to this command.

U r right, since u configure the minimum allowed number of queues u are 
most likely won't cause your VF HW to hang (unless I miss anything) 
however u quite break the VF-PF negotiation rules here and as a result 
in the example above RSS won't work and u won't get any traffic on the 
second queue which will surely confuse the user. This is in addition to 
that u r going to waste the resources the system administrator 
explicitly told u not to...

thanks,
vlad

>
> Thanks,
> Emil
>
>
>
