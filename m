From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/3] vhost: better detection of available buffers
Date: Tue, 15 Nov 2016 16:00:21 +0800
Message-ID: <8bf86752-4dca-3ced-4641-efa7a4a1fc6e@redhat.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <1478677113-13126-2-git-send-email-jasowang@redhat.com>
 <20161109215513-mutt-send-email-mst@kernel.org>
 <70cb5ad8-5266-b0c4-7b55-4aea4f5f01a6@redhat.com>
 <20161111054021-mutt-send-email-mst@kernel.org>
 <a2e98020-0fc5-e8c0-fd57-7d395733c693@redhat.com>
 <20161111182023-mutt-send-email-mst@kernel.org>
 <6f650bf0-1e2b-1c35-db34-5024383a6892@redhat.com>
 <20161115052753-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33916 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934210AbcKOIAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 03:00:25 -0500
In-Reply-To: <20161115052753-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月15日 11:28, Michael S. Tsirkin wrote:
> On Tue, Nov 15, 2016 at 11:16:59AM +0800, Jason Wang wrote:
>>
>> On 2016年11月12日 00:20, Michael S. Tsirkin wrote:
>>> On Fri, Nov 11, 2016 at 12:18:50PM +0800, Jason Wang wrote:
>>>> On 2016年11月11日 11:41, Michael S. Tsirkin wrote:
>>>>> On Fri, Nov 11, 2016 at 10:18:37AM +0800, Jason Wang wrote:
>>>>>>> On 2016年11月10日 03:57, Michael S. Tsirkin wrote:
>>>>>>>>> On Wed, Nov 09, 2016 at 03:38:32PM +0800, Jason Wang wrote:
>>>>>>>>>>> We should use vq->last_avail_idx instead of vq->avail_idx in the
>>>>>>>>>>> checking of vhost_vq_avail_empty() since latter is the cached avail
>>>>>>>>>>> index from guest but we want to know if there's pending available
>>>>>>>>>>> buffers in the virtqueue.
>>>>>>>>>>>
>>>>>>>>>>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>>>>>> I'm not sure why is this patch here. Is it related to
>>>>>>>>> batching somehow?
>>>>>>> Yes, we need to know whether or not there's still buffers left in the
>>>>>>> virtqueue, so need to check last_avail_idx. Otherwise, we're checking if
>>>>>>> guest has submitted new buffers.
>>>>>>>
>>>>>>>>>>> ---
>>>>>>>>>>>     drivers/vhost/vhost.c | 2 +-
>>>>>>>>>>>     1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>>>>>>>
>>>>>>>>>>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>>>>>>>>>>> index c6f2d89..fdf4cdf 100644
>>>>>>>>>>> --- a/drivers/vhost/vhost.c
>>>>>>>>>>> +++ b/drivers/vhost/vhost.c
>>>>>>>>>>> @@ -2230,7 +2230,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>>>>>>>>>>>     	if (r)
>>>>>>>>>>>     		return false;
>>>>>>>>>>> -	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
>>>>>>>>>>> +	return vhost16_to_cpu(vq, avail_idx) == vq->last_avail_idx;
>>>>>>>>>>>     }
>>>>>>>>>>>     EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);
>>>>>>>>> That might be OK for TX but it's probably wrong for RX
>>>>>>>>> where the fact that used != avail does not mean
>>>>>>>>> we have enough space to store the packet.
>>>>>>> Right, but it's no harm since it was just a hint, handle_rx() can handle
>>>>>>> this situation.
>>>>> Means busy polling will cause useless load on the CPU though.
>>>>>
>>>> Right, but,it's not easy to have 100% correct hint here. Needs more thought.
>>> What's wrong with what we have? It polls until value changes.
>>>
>> But as you said, this does not mean (in mergeable cases) we have enough
>> space to store the packet.
> Absolutely but it checks once and then only re-checks after value
> changes again.
>

Since get_rx_bufs() does not get enough buffers, we will wait for the 
kick in this case. For busy polling, we probably want to stay in the 
busy loop here.
