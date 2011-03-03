From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: Re: [PATCH] e1000: fix race condition while driver unload/reset using
 kref count
Date: Wed, 02 Mar 2011 17:47:51 -0800
Message-ID: <4D6EF347.9020508@riverbed.com>
References: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com> <alpine.WNT.2.00.1103021337560.8204@JBRANDEB-DESK2.amr.corp.intel.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.45]:57392 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162Ab1CCBsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:48:10 -0500
In-Reply-To: <alpine.WNT.2.00.1103021337560.8204@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Sorry, resending it, as it did not make it to netdev]
On 03/02/2011 02:50 PM, Brandeburg, Jesse wrote:
>
> On Wed, 2 Mar 2011, prasanna.panchamukhi@riverbed.com wrote:
>
>> This race conditions occurs with reentrant e1000_down(), which gets
>> called by multiple threads while driver unload or reset.
>> This patch fixes the race condition when one thread tries to destroy
>> the memory allocated for tx buffer_info, while another thread still
>> happen to access tx buffer_info.
>> This patch fixes the above race condition using kref count.
> I'm very interested in any test cases that you might have come up with to
> reproduce this issue.
This patch is an alternative approach to the below commit:

commit 338c15e470d818f215d651505dc169d4e92f36a4
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Wed Sep 22 18:22:42 2010 +0000

     e1000: fix occasional panic on unload


Its a very rare event.
One of the ways is to tweak the driver to reset more frequently(5 times 
per second) & do ifconfig up/down in tight loop.
Another way could be to do a module load/unload or keep rebooting the 
system in tight loop.
> The patch itself looks interesting, and probably okay, but we really need
> a reproduction case.
>
Yeah, I understand your point.
> Also, do we need to adjust the rtnl_lock stuff or do this for rx
> buffer_info structs?
kref counting  buffer_info struct is good enough.
> I'm concerned that maybe we don't understand the full flow of events
> leading up to this failure.

possible race condition because of e1000_down() being re-entrant. Multiple threads can end up calling
e1000_down() either during driver unload or reboot/reset.

below is the kernel traces
Oct 10 11:59:48 localhost kernel: EIP:    0060:[put_page+2/117]    Tainted: PF
  B VLI
Oct 10 11:59:48 localhost kernel: EIP:    0060:[<e0148432>]    Tainted: PF   B
VLI
Oct 10 11:59:48 localhost kernel: EFLAGS: 00010202   (2.6.9-34.EL-rbt-1784SMP)
Oct 10 11:59:48 localhost kernel: EIP is at put_page+0x2/0x75
Oct 10 11:59:48 localhost kernel: eax: 12a051a5   ebx: 00000002   ecx: e04b3300
   edx: 12a051a5
Oct 10 11:59:48 localhost kernel: esi: f72e8b80   edi: 00000cb7   ebp: f7d09000
   esp: e2158ebc
Oct 10 11:59:48 localhost kernel: ds: 007b   es: 007b   ss: 0068
Oct 10 11:59:48 localhost kernel: Process events/1 (pid: 7, threadinfo=e2158000
task=e2182b70)
Oct 10 11:59:48 localhost kernel: Stack: e03cea9c f72e8b80 f8b6db70 e03ceada
00000000 e03ceb98 e02d8e80 e2158ee0
Oct 10 11:59:48 localhost kernel:        f88c0000 00000000 f72e8b80 f7ce2180
e02c4a88 f7ce2180 f7d092a0 e02c4ab4
Oct 10 11:59:48 localhost kernel:        f7d092a0 00000000 0103f0f8 f7d09000
e02c4b5d f88c0000 f7d092a0 e02c2247
Oct 10 11:59:48 localhost kernel: Call Trace:

Oct 10 11:59:48 localhost kernel:  [skb_release_data+57/111]
skb_release_data+0x39/0x6f
Oct 10 11:59:48 localhost kernel:  [<e03cea9c>] skb_release_data+0x39/0x6f
Oct 10 11:59:48 localhost kernel:  [kfree_skbmem+8/21] kfree_skbmem+0x8/0x15
Oct 10 11:59:48 localhost kernel:  [<e03ceada>] kfree_skbmem+0x8/0x15
Oct 10 11:59:48 localhost kernel:  [__kfree_skb+177/343] __kfree_skb+0xb1/0x157
Oct 10 11:59:48 localhost kernel:  [<e03ceb98>] __kfree_skb+0xb1/0x157
Oct 10 11:59:48 localhost kernel:  [e1000_get_phy_info_m88+56/281]
e1000_get_phy_info_m88+0x38/0x119
Oct 10 11:59:48 localhost kernel:  [<e02d8e80>]
e1000_get_phy_info_m88+0x38/0x119
Oct 10 11:59:48 localhost kernel:  [e1000_unmap_and_free_tx_resource+156/165]
e1000_unmap_and_free_tx_resource+0x9c/0xa5
Oct 10 11:59:48 localhost kernel:  [<e02c4a88>]
e1000_unmap_and_free_tx_resource+0x9c/0xa5
Oct 10 11:59:48 localhost kernel:  [e1000_clean_tx_ring+35/162]
e1000_clean_tx_ring+0x23/0xa2
Oct 10 11:59:48 localhost kernel:  [<e02c4ab4>] e1000_clean_tx_ring+0x23/0xa2
Oct 10 11:59:48 localhost kernel:  [e1000_clean_all_tx_rings+42/56]
e1000_clean_all_tx_rings+0x2a/0x38
Oct 10 11:59:48 localhost kernel:  [<e02c4b5d>]
e1000_clean_all_tx_rings+0x2a/0x38
Oct 10 11:59:48 localhost kernel:  [e1000_down+356/380] e1000_down+0x164/0x17c
Oct 10 11:59:48 localhost kernel:  [<e02c2247>] e1000_down+0x164/0x17c
Oct 10 11:59:48 localhost kernel:  [e1000_reinit_locked+120/146]
e1000_reinit_locked+0x78/0x92
Oct 10 11:59:48 localhost kernel:  [<e02c22d7>] e1000_reinit_locked+0x78/0x92
Oct 10 11:59:48 localhost kernel:  [e1000_reset_task+21/33]
e1000_reset_task+0x15/0x21
Oct 10 11:59:48 localhost kernel:  [<e02c74a3>] e1000_reset_task+0x15/0x21
Oct 10 11:59:48 localhost kernel:  [worker_thread+432/570]
worker_thread+0x1b0/0x23a
Oct 10 11:59:48 localhost kernel:  [<e0132f8d>] worker_thread+0x1b0/0x23a
Oct 10 11:59:48 localhost kernel:  [schedule+808/2803] schedule+0x328/0xaf3
Oct 10 11:59:48 localhost kernel:  [<e0431e18>] schedule+0x328/0xaf3
Oct 10 11:59:48 localhost kernel:  [e1000_reset_task+0/33]

Thanks
Prasanna


> Jesse
>
>> Signed-off-by: Prasanna S. Panchamukhi<prasanna.panchamukhi@riverbed.com>
>> ---
>>   drivers/net/e1000/e1000.h      |    2 +
>>   drivers/net/e1000/e1000_main.c |   41 +++++++++++++++++++++++++++++++++++++--
>>   2 files changed, 40 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
>> index a881dd0..36f55b3 100644
>> --- a/drivers/net/e1000/e1000.h
>> +++ b/drivers/net/e1000/e1000.h
>> @@ -168,6 +168,8 @@ struct e1000_tx_ring {
>>   	unsigned int next_to_clean;
>>   	/* array of buffer information structs */
>>   	struct e1000_buffer *buffer_info;
>> +	spinlock_t bufinfo_lock; /* protect access to buffer_info */
>> +	struct kref bufinfo_refcount; /* refcount access to buffer info */
>>
>>   	u16 tdh;
>>   	u16 tdt;
>> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
>> index beec573..336d3e1 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -1531,6 +1531,8 @@ setup_tx_desc_die:
>>
>>   	txdr->next_to_use = 0;
>>   	txdr->next_to_clean = 0;
>> +	spin_lock_init(&txdr->bufinfo_lock);
>> +	kref_init(&txdr->bufinfo_refcount);
>>
>>   	return 0;
>>   }
>> @@ -1880,6 +1882,22 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
>>   	ew32(RCTL, rctl);
>>   }
>>
>> +/*
>> + * Free tx buffer info resources, only when no other thread is
>> + * accessing it. Access to buffer_info is refcounted by bufinfo_refcount,
>> + * hence memory allocated must be destroyed when bufinfo_refcount
>> + * becomes zero. This routine gets executed when bufinfo_refcount
>> + * becomes zero.
>> + */
>> +static void e1000_free_tx_buffer_info(struct kref *ref)
>> +{
>> +	struct e1000_tx_ring *tx_ring =
>> +		container_of(ref, struct e1000_tx_ring, bufinfo_refcount);
>> +
>> +	vfree(tx_ring->buffer_info);
>> +	tx_ring->buffer_info = NULL;
>> +}
>> +
>>   /**
>>    * e1000_free_tx_resources - Free Tx Resources per Queue
>>    * @adapter: board private structure
>> @@ -1895,8 +1913,9 @@ static void e1000_free_tx_resources(struct e1000_adapter *adapter,
>>
>>   	e1000_clean_tx_ring(adapter, tx_ring);
>>
>> -	vfree(tx_ring->buffer_info);
>> -	tx_ring->buffer_info = NULL;
>> +	spin_lock(&tx_ring->bufinfo_lock);
>> +	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
>> +	spin_unlock(&tx_ring->bufinfo_lock);
>>
>>   	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
>>   			  tx_ring->dma);
>> @@ -1954,8 +1973,20 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
>>   	unsigned long size;
>>   	unsigned int i;
>>
>> -	/* Free all the Tx ring sk_buffs */
>> +	spin_lock(&tx_ring->bufinfo_lock);
>> +	/*
>> +	 * Check buffer_info is not NULL, and
>> +	 * increment the refcount to prevent
>> +	 * the buffer getting freed underneath.
>> +	 */
>> +	if (tx_ring->buffer_info == NULL) {
>> +		spin_unlock(&tx_ring->bufinfo_lock);
>> +		return;
>> +	}
>> +	kref_get(&tx_ring->bufinfo_refcount);
>> +	spin_unlock(&tx_ring->bufinfo_lock);
>>
>> +	/* Free all the Tx ring sk_buffs */
>>   	for (i = 0; i<  tx_ring->count; i++) {
>>   		buffer_info =&tx_ring->buffer_info[i];
>>   		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
>> @@ -1968,6 +1999,10 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
>>
>>   	memset(tx_ring->desc, 0, tx_ring->size);
>>
>> +	spin_lock(&tx_ring->bufinfo_lock);
>> +	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
>> +	spin_unlock(&tx_ring->bufinfo_lock);
>> +
>>   	tx_ring->next_to_use = 0;
>>   	tx_ring->next_to_clean = 0;
>>   	tx_ring->last_tx_tso = 0;
>>

