From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Tue, 3 Jan 2017 08:48:45 -0800
Message-ID: <586BD5ED.3070204@gmail.com>
References: <20170102223031.11541.28717.stgit@john-Precision-Tower-5810>
 <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36180 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758830AbdACQs7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:48:59 -0500
Received: by mail-pg0-f68.google.com with SMTP id n5so34040780pgh.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 08:48:59 -0800 (PST)
In-Reply-To: <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 10:14 PM, Jason Wang wrote:
> 
> 
> On 2017年01月03日 06:30, John Fastabend wrote:
>> XDP programs can not consume multiple pages so we cap the MTU to
>> avoid this case. Virtio-net however only checks the MTU at XDP
>> program load and does not block MTU changes after the program
>> has loaded.
>>
>> This patch sets/clears the max_mtu value at XDP load/unload time.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   drivers/net/virtio_net.c |    9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 5deeda6..783e842 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1699,6 +1699,9 @@ static void virtnet_init_settings(struct net_device *dev)
>>       .set_settings = virtnet_set_settings,
>>   };
>>   +#define MIN_MTU ETH_MIN_MTU
>> +#define MAX_MTU ETH_MAX_MTU
>> +
>>   static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>   {
>>       unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
>> @@ -1748,6 +1751,9 @@ static int virtnet_xdp_set(struct net_device *dev,
>> struct bpf_prog *prog)
>>               virtnet_set_queues(vi, curr_qp);
>>               return PTR_ERR(prog);
>>           }
>> +        dev->max_mtu = max_sz;
>> +    } else {
>> +        dev->max_mtu = ETH_MAX_MTU;
> 
> Or use ETH_DATA_LEN here consider we only allocate a size of GOOD_PACKET_LEN for
> each small buffer?
> 
> Thanks

OK so this logic is a bit too simply. When it resets the max_mtu I guess it
needs to read the mtu via

   virtio_cread16(vdev, ...)

or we may break the negotiated mtu.

As for capping it at GOOD_PACKET_LEN this has the nice benefit of avoiding any
underestimates in EWMA predictions because it appears min estimates are capped
at GOOD_PACKET_LEN via get_mergeable_buf_len().

Thanks,
John
