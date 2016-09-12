From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Sun, 11 Sep 2016 20:07:18 -0700
Message-ID: <57D61BE6.2080002@gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
 <CALx6S34+Mgb173vReYt=yPOztcFhVU9rRZyodVc56toXP1OiHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33418 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755530AbcILDHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 23:07:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so7397367pfb.0
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 20:07:38 -0700 (PDT)
In-Reply-To: <CALx6S34+Mgb173vReYt=yPOztcFhVU9rRZyodVc56toXP1OiHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-10 08:36 AM, Tom Herbert wrote:
> On Fri, Sep 9, 2016 at 2:29 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>> e1000 supports a single TX queue so it is being shared with the stack
>> when XDP runs XDP_TX action. This requires taking the xmit lock to
>> ensure we don't corrupt the tx ring. To avoid taking and dropping the
>> lock per packet this patch adds a bundling implementation to submit
>> a bundle of packets to the xmit routine.
>>
>> I tested this patch running e1000 in a VM using KVM over a tap
>> device using pktgen to generate traffic along with 'ping -f -l 100'.
>>
>> Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> index 91d5c87..b985271 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> @@ -1738,10 +1738,18 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
>>         struct pci_dev *pdev = adapter->pdev;
>>         int size, desc_len;
>>
>> +       size = sizeof(struct e1000_rx_buffer_bundle) *
>> +                       E1000_XDP_XMIT_BUNDLE_MAX;
>> +       rxdr->xdp_buffer = vzalloc(size);
>> +       if (!rxdr->xdp_buffer)
>> +               return -ENOMEM;
>> +
>>         size = sizeof(struct e1000_rx_buffer) * rxdr->count;
>>         rxdr->buffer_info = vzalloc(size);
>> -       if (!rxdr->buffer_info)
>> +       if (!rxdr->buffer_info) {
>> +               vfree(rxdr->xdp_buffer);
> 
> This could be deferred until an XDP program is added.

Yep that would be best to avoid overhead in the normal non-XDP case.
Also I'll move the xdp prog pointer into the rx ring per Jespers comment
that I missed in this rev.

[...]

>> +
>> +static void e1000_xdp_xmit_bundle(struct e1000_rx_buffer_bundle *buffer_info,
>> +                                 struct net_device *netdev,
>> +                                 struct e1000_adapter *adapter)
>> +{
>> +       struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
>> +       struct e1000_tx_ring *tx_ring = adapter->tx_ring;
>> +       struct e1000_hw *hw = &adapter->hw;
>> +       int i = 0;
>> +
>>         /* e1000 only support a single txq at the moment so the queue is being
>>          * shared with stack. To support this requires locking to ensure the
>>          * stack and XDP are not running at the same time. Devices with
>>          * multiple queues should allocate a separate queue space.
>> +        *
>> +        * To amortize the locking cost e1000 bundles the xmits and sends as
>> +        * many as possible until either running out of descriptors or failing.
> 
> Up to E1000_XDP_XMIT_BUNDLE_MAX  at least...

Yep will fix comment.

[...]

>>
>>                 /* use prefetched values */
>> @@ -4498,8 +4536,11 @@ next_desc:
>>         rx_ring->next_to_clean = i;
>>
>>         cleaned_count = E1000_DESC_UNUSED(rx_ring);
>> -       if (cleaned_count)
>> +       if (cleaned_count) {
>> +               if (xdp_xmit)
>> +                       e1000_xdp_xmit_bundle(xdp_bundle, netdev, adapter);
>>                 adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
>> +       }
> 
> Looks good for XDP path. Is this something we can abstract out into a
> library for use by other drivers?
> 

I'm not really sure it can be abstracted much its a bit intertwined with
the normal rx receive path. But it should probably be a pattern that
gets copied so we avoid unnecessary tx work.

> 
>>
>>         adapter->total_rx_packets += total_rx_packets;
>>         adapter->total_rx_bytes += total_rx_bytes;
>>
