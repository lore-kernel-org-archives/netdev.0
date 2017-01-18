From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Wed, 18 Jan 2017 11:54:21 +0800
Message-ID: <34158479-8d4a-3761-a02e-66c474aca53e@redhat.com>
References: <20170117181351.98291-1-rolf.neugebauer@docker.com>
 <20170117202515-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rppt@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdARDyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 22:54:25 -0500
In-Reply-To: <20170117202515-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月18日 02:27, Michael S. Tsirkin wrote:
> On Tue, Jan 17, 2017 at 06:13:51PM +0000, Rolf Neugebauer wrote:
>> This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a
>> subtle change in how the virtio_net flags are derived from the SKBs
>> ip_summed field.
>>
>> With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
>> when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
>> ip_summed == CHECKSUM_NONE, which should be the same.
>>
>> Further, the virtio spec 1.0 / CS04 explicitly says that
>> VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.
>>
>> Signed-off-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Fixes: fd2a0437dc33 ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
> Fixes: e858fae2b0b8 (" virtio_net: use common code for virtio_net_hdr and skb GSO conversion")
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>
> Should be backported into stable as well.

Looks like a side effect is that we will never see this on receive path? 
We probably need a hint for virtio_net_hdr_from_skb().

Thanks

>
>
>> ---
>>   include/linux/virtio_net.h | 2 --
>>   1 file changed, 2 deletions(-)
>>
>> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
>> index 66204007d7ac..56436472ccc7 100644
>> --- a/include/linux/virtio_net.h
>> +++ b/include/linux/virtio_net.h
>> @@ -91,8 +91,6 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>>   				skb_checksum_start_offset(skb));
>>   		hdr->csum_offset = __cpu_to_virtio16(little_endian,
>>   				skb->csum_offset);
>> -	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
>> -		hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
>>   	} /* else everything is zero */
>>   
>>   	return 0;
>> -- 
>> 2.11.0
