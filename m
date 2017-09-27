From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 2/5] vhost: introduce helper to prefetch desc
 index
Date: Wed, 27 Sep 2017 08:35:47 +0800
Message-ID: <17e9c3a9-7759-a674-bc00-414eabfed118@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-3-git-send-email-jasowang@redhat.com>
 <20170926221435-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926221435-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月27日 03:19, Michael S. Tsirkin wrote:
> On Fri, Sep 22, 2017 at 04:02:32PM +0800, Jason Wang wrote:
>> This patch introduces vhost_prefetch_desc_indices() which could batch
>> descriptor indices fetching and used ring updating. This intends to
>> reduce the cache misses of indices fetching and updating and reduce
>> cache line bounce when virtqueue is almost full. copy_to_user() was
>> used in order to benefit from modern cpus that support fast string
>> copy. Batched virtqueue processing will be the first user.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/vhost/vhost.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>   drivers/vhost/vhost.h |  3 +++
>>   2 files changed, 58 insertions(+)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index f87ec75..8424166d 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -2437,6 +2437,61 @@ struct vhost_msg_node *vhost_dequeue_msg(struct vhost_dev *dev,
>>   }
>>   EXPORT_SYMBOL_GPL(vhost_dequeue_msg);
>>   
>> +int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
>> +				struct vring_used_elem *heads,
>> +				u16 num, bool used_update)
> why do you need to combine used update with prefetch?

For better performance and I believe we don't care about the overhead 
when we meet errors in tx.

>
>> +{
>> +	int ret, ret2;
>> +	u16 last_avail_idx, last_used_idx, total, copied;
>> +	__virtio16 avail_idx;
>> +	struct vring_used_elem __user *used;
>> +	int i;
>> +
>> +	if (unlikely(vhost_get_avail(vq, avail_idx, &vq->avail->idx))) {
>> +		vq_err(vq, "Failed to access avail idx at %p\n",
>> +		       &vq->avail->idx);
>> +		return -EFAULT;
>> +	}
>> +	last_avail_idx = vq->last_avail_idx & (vq->num - 1);
>> +	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
>> +	total = vq->avail_idx - vq->last_avail_idx;
>> +	ret = total = min(total, num);
>> +
>> +	for (i = 0; i < ret; i++) {
>> +		ret2 = vhost_get_avail(vq, heads[i].id,
>> +				      &vq->avail->ring[last_avail_idx]);
>> +		if (unlikely(ret2)) {
>> +			vq_err(vq, "Failed to get descriptors\n");
>> +			return -EFAULT;
>> +		}
>> +		last_avail_idx = (last_avail_idx + 1) & (vq->num - 1);
>> +	}
>> +
>> +	if (!used_update)
>> +		return ret;
>> +
>> +	last_used_idx = vq->last_used_idx & (vq->num - 1);
>> +	while (total) {
>> +		copied = min((u16)(vq->num - last_used_idx), total);
>> +		ret2 = vhost_copy_to_user(vq,
>> +					  &vq->used->ring[last_used_idx],
>> +					  &heads[ret - total],
>> +					  copied * sizeof(*used));
>> +
>> +		if (unlikely(ret2)) {
>> +			vq_err(vq, "Failed to update used ring!\n");
>> +			return -EFAULT;
>> +		}
>> +
>> +		last_used_idx = 0;
>> +		total -= copied;
>> +	}
>> +
>> +	/* Only get avail ring entries after they have been exposed by guest. */
>> +	smp_rmb();
> Barrier before return is a very confusing API. I guess it's designed to
> be used in a specific way to make it necessary - but what is it?

Looks like a and we need do this after reading avail_idx.

Thanks

>
>
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL(vhost_prefetch_desc_indices);
>>   
>>   static int __init vhost_init(void)
>>   {
>> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
>> index 39ff897..16c2cb6 100644
>> --- a/drivers/vhost/vhost.h
>> +++ b/drivers/vhost/vhost.h
>> @@ -228,6 +228,9 @@ ssize_t vhost_chr_read_iter(struct vhost_dev *dev, struct iov_iter *to,
>>   ssize_t vhost_chr_write_iter(struct vhost_dev *dev,
>>   			     struct iov_iter *from);
>>   int vhost_init_device_iotlb(struct vhost_dev *d, bool enabled);
>> +int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
>> +				struct vring_used_elem *heads,
>> +				u16 num, bool used_update);
>>   
>>   #define vq_err(vq, fmt, ...) do {                                  \
>>   		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
>> -- 
>> 2.7.4
