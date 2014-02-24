From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/2] ixgbe, make interrupt allocations NUMA aware
Date: Mon, 24 Feb 2014 11:49:32 -0800
Message-ID: <530BA24C.70203@intel.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com> <1393267913-28212-2-git-send-email-prarit@redhat.com> <530B9CE8.2070800@intel.com> <530BA00E.4070802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	agospoda@redhat.com, e1000-devel@lists.sourceforge.net
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58239 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184AbaBXTtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 14:49:53 -0500
In-Reply-To: <530BA00E.4070802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 11:39 AM, Prarit Bhargava wrote:
> 
> 
> On 02/24/2014 02:26 PM, Alexander Duyck wrote:
>> On 02/24/2014 10:51 AM, Prarit Bhargava wrote:
>>> The ixgbe driver creates one queue/cpu on the system in order to spread
>>> work out on all cpus rather than restricting work to a single cpu.  This
>>> model, while efficient, does not take into account the NUMA configuration
>>> of the system.
>>>
>>> This patch introduces ixgbe_num_cpus() which returns
>>> the number of online cpus if the adapter's PCI device has no NUMA
>>> restrictions, and the number of cpus in the node if the PCI device is
>>> allocated to a specific node.
>>>
>>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>>> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
>>> Cc: Don Skidmore <donald.c.skidmore@intel.com>
>>> Cc: Greg Rose <gregory.v.rose@intel.com>
>>> Cc: Alex Duyck <alexander.h.duyck@intel.com>
>>> Cc: John Ronciak <john.ronciak@intel.com>
>>> Cc: Mitch Williams <mitch.a.williams@intel.com>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: nhorman@redhat.com
>>> Cc: agospoda@redhat.com
>>> Cc: e1000-devel@lists.sourceforge.net
>>> ---
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   28 +++++++++++++++++++++---
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++---
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +++--
>>>  4 files changed, 33 insertions(+), 8 deletions(-)
>>>
>>
>> [...]
>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index 18076c4..b68a6e9 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -4953,13 +4953,13 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
>>>  	hw->subsystem_device_id = pdev->subsystem_device;
>>>  
>>>  	/* Set common capability flags and settings */
>>> -	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
>>> +	rss = min_t(int, IXGBE_MAX_RSS_INDICES, ixgbe_num_cpus(adapter));
>>>  	adapter->ring_feature[RING_F_RSS].limit = rss;
>>>  	adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
>>>  	adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
>>>  	adapter->max_q_vectors = MAX_Q_VECTORS_82599;
>>>  	adapter->atr_sample_rate = 20;
>>> -	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, num_online_cpus());
>>> +	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, ixgbe_num_cpus(adapter));
>>>  	adapter->ring_feature[RING_F_FDIR].limit = fdir;
>>>  	adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
>>>  #ifdef CONFIG_IXGBE_DCA
>>
>> This is the one bit I object to in this patch.  The flow director queue
>> count should be equal to the number of online CPUs, or at least as close
>> to it as the hardware can get.  Otherwise ATR is completely useless.
> 
> I'm reading up on ATR now and I see your point completely.  I will remove this
> chunk in V2.  OOC, however, what about my concern with ATR & the location of the
> PCI device (on a different root bridge)?  Isn't that a concern with ATR or am I
> missing something with the overall scheme of ATR?
> 
> P.
> 

The advantage to ATR is that it knows where the application requesting
the packet data resides.  The applications on remote nodes still need
access to the device and the only means of getting to it is through
memory.  If the root complex is on one node and the memory/CPU is on
another it is still cheaper to have the device push the descriptor and
packet to the memory/CPU then to have the CPU have to fetch it from our
local nodes memory and then copy it into the application memory.

RSS which is the fallback if we don't have ATR isn't application aware
so in the case of RSS we probably want to just process all of the
requests locally and hope for the best since we don't know what node the
data will eventually end up on.

Thanks,

Alex
