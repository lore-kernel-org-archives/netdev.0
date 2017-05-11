From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V4 10/10] vhost_net: try batch dequing from skb
 array
Date: Thu, 11 May 2017 10:47:47 +0800
Message-ID: <6ec5ce73-793b-56b8-51a8-fe119581a874@redhat.com>
References: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
 <1494387382-19916-11-git-send-email-jasowang@redhat.com>
 <20170510152848-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170510152848-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年05月10日 20:34, Michael S. Tsirkin wrote:
> On Wed, May 10, 2017 at 11:36:22AM +0800, Jason Wang wrote:
>> We used to dequeue one skb during recvmsg() from skb_array, this could
>> be inefficient because of the bad cache utilization and spinlock
>> touching for each packet. This patch tries to batch them by calling
>> batch dequeuing helpers explicitly on the exported skb array and pass
>> the skb back through msg_control for underlayer socket to finish the
>> userspace copying.
>>
>> Batch dequeuing is also the requirement for more batching improvement
>> on rx.
>>
>> Tests were done by pktgen on tap with XDP1 in guest on top of batch
>> zeroing:
>>
>> rx batch | pps
>>
>> 256        2.41Mpps (+6.16%)
>> 128        2.48Mpps (+8.80%)
>> 64         2.38Mpps (+3.96%) <- Default
>> 16         2.31Mpps (+1.76%)
>> 4          2.31Mpps (+1.76%)
>> 1          2.30Mpps (+1.32%)
>> 0          2.27Mpps (+7.48%)
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>>   drivers/vhost/net.c | 117 +++++++++++++++++++++++++++++++++++++++++++++++++---
>>   1 file changed, 111 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 9b51989..fbaecf3 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -28,6 +28,8 @@
>>   #include <linux/if_macvlan.h>
>>   #include <linux/if_tap.h>
>>   #include <linux/if_vlan.h>
>> +#include <linux/skb_array.h>
>> +#include <linux/skbuff.h>
>>   
>>   #include <net/sock.h>
>>   
>> @@ -85,6 +87,13 @@ struct vhost_net_ubuf_ref {
>>   	struct vhost_virtqueue *vq;
>>   };
>>   
>> +#define VHOST_RX_BATCH 64
>> +struct vhost_net_buf {
>> +	struct sk_buff *queue[VHOST_RX_BATCH];
>> +	int tail;
>> +	int head;
>> +};
>> +
> Do you strictly need to put this inline? This structure is quite big
> already. Do you see a measureabe difference if you make it
>
> 	struct sk_buff **queue;
> 	int tail;
> 	int head;
>
> ?

I don't.

>
> Will also make it easier to play with the size in the future
> should someone want to see how does it work e.g. for different
> ring sizes.
>

Ok, will do this in next version

Thanks
