From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH =v2] e1000: add initial XDP support
Date: Fri, 2 Sep 2016 12:17:20 -0700
Message-ID: <57C9D040.2050600@gmail.com>
References: <20160901213944.31705.93780.stgit@john-Precision-Tower-5810>
 <20160902085031.752a97cc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        jeffrey.t.kirsher@intel.com, xiyou.wangcong@gmail.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, u9012063@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36579 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932179AbcIBTRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 15:17:35 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so5859822pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 12:17:34 -0700 (PDT)
In-Reply-To: <20160902085031.752a97cc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-01 11:50 PM, Jesper Dangaard Brouer wrote:
> On Thu, 01 Sep 2016 14:39:44 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> From: Alexei Starovoitov <ast@fb.com>
>>
>> This patch adds initial support for XDP on e1000 driver. Note e1000
>> driver does not support page recycling in general which could be
>> added as a further improvement. However XDP_DROP case will recycle.
>> XDP_TX and XDP_PASS do not support recycling yet.
>>
>> This patch includes the rcu_read_lock/rcu_read_unlock pair noted by
>> Brenden Blanco in another pending patch.
>>
>>   net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
>>
>> I tested this patch running e1000 in a VM using KVM over a tap
>> device.
>>
>> CC: William Tu <u9012063@gmail.com>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000.h      |    2 
>>  drivers/net/ethernet/intel/e1000/e1000_main.c |  170 +++++++++++++++++++++++++
>>  2 files changed, 169 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
>> index d7bdea7..5cf8a0a 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000.h
>> +++ b/drivers/net/ethernet/intel/e1000/e1000.h
>> @@ -150,6 +150,7 @@ struct e1000_adapter;
>>   */
>>  struct e1000_tx_buffer {
>>  	struct sk_buff *skb;
>> +	struct page *page;
>>  	dma_addr_t dma;
>>  	unsigned long time_stamp;
>>  	u16 length;
>> @@ -279,6 +280,7 @@ struct e1000_adapter {
>>  			     struct e1000_rx_ring *rx_ring,
>>  			     int cleaned_count);
>>  	struct e1000_rx_ring *rx_ring;      /* One per active queue */
>> +	struct bpf_prog *prog;
> 
> The bpf_prog should be in the rx_ring structure.
> 

ok sure it helps I guess if you use e1000 as a template for implementing
XDP and logically makes a bit more sense. But it doesn't functionally
matter here.


>>  	struct napi_struct napi;
>>  
>>  	int num_tx_queues;

[...]

>> +static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
>> +				 unsigned int len,
>> +				 struct net_device *netdev,
>> +				 struct e1000_adapter *adapter)
>> +{
>> +	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
>> +	struct e1000_hw *hw = &adapter->hw;
>> +	struct e1000_tx_ring *tx_ring;
>> +
>> +	if (len > E1000_MAX_DATA_PER_TXD)
>> +		return;
>> +
>> +	/* e1000 only support a single txq at the moment so the queue is being
>> +	 * shared with stack. To support this requires locking to ensure the
>> +	 * stack and XDP are not running at the same time. Devices with
>> +	 * multiple queues should allocate a separate queue space.
>> +	 */
>> +	HARD_TX_LOCK(netdev, txq, smp_processor_id());
>> +
>> +	tx_ring = adapter->tx_ring;
>> +
>> +	if (E1000_DESC_UNUSED(tx_ring) < 2)
>> +		return;
>> +
>> +	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
>> +
>> +	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
>> +
>> +	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
>> +	mmiowb();
>> +
>> +	HARD_TX_UNLOCK(netdev, txq);
>> +}
> 
> Above is going to give really bad XDP_TX performance. Both locking and
> a HW TX tailptr pointer per TX packet, that is as bad as it gets.
> 

Yep.

> You might say this is just for testing my eBPF-XDP program. BUT people
> wanting to try XDP is going to start with this driver, and they will be
> disappointed and never return (and no they will not read the comment in
> the code).

hmm perhaps we should look at a vhost_net implementation for performance
setup. My gut feeling is vhost_net is a better target for performance.

> 
> It should be fairly easy to introduce a bulking/bundling XDP_TX
> facility into the TX-ring (taking HARD_TX_LOCK a single time), and then
> flush the TX-ring at the end of the loop (in e1000_clean_jumbo_rx_irq).
> All you need is an array/stack of RX *buffer_info ptrs being build up
> in the XDP_TX case. (Experiments show minimum bulking/array size should
> be 8).
> 
> If you want to get fancy, and save space in the bulking structure,
> then you can even just use the RX ring index "i" to describe which RX
> packets need to be XDP_TX'ed. (as the driver code "owns" this part of
> the ring, until updating rx_ring->next_to_clean).
> 

Sure I'll add this seems easy enough.
