From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 3/5] vhost: introduce vhost_add_used_idx()
Date: Wed, 27 Sep 2017 08:38:24 +0800
Message-ID: <c42b7244-6d43-2ce5-46a3-ea70ec9d957f@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-4-git-send-email-jasowang@redhat.com>
 <20170926170047-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926170047-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月27日 03:13, Michael S. Tsirkin wrote:
> On Fri, Sep 22, 2017 at 04:02:33PM +0800, Jason Wang wrote:
>> This patch introduces a helper which just increase the used idx. This
>> will be used in pair with vhost_prefetch_desc_indices() by batching
>> code.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/vhost/vhost.c | 33 +++++++++++++++++++++++++++++++++
>>   drivers/vhost/vhost.h |  1 +
>>   2 files changed, 34 insertions(+)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 8424166d..6532cda 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -2178,6 +2178,39 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
>>   }
>>   EXPORT_SYMBOL_GPL(vhost_add_used);
>>   
>> +int vhost_add_used_idx(struct vhost_virtqueue *vq, int n)
>> +{
>> +	u16 old, new;
>> +
>> +	old = vq->last_used_idx;
>> +	new = (vq->last_used_idx += n);
>> +	/* If the driver never bothers to signal in a very long while,
>> +	 * used index might wrap around. If that happens, invalidate
>> +	 * signalled_used index we stored. TODO: make sure driver
>> +	 * signals at least once in 2^16 and remove this.
>> +	 */
>> +	if (unlikely((u16)(new - vq->signalled_used) < (u16)(new - old)))
>> +		vq->signalled_used_valid = false;
>> +
>> +	/* Make sure buffer is written before we update index. */
>> +	smp_wmb();
>> +	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
>> +			   &vq->used->idx)) {
>> +		vq_err(vq, "Failed to increment used idx");
>> +		return -EFAULT;
>> +	}
>> +	if (unlikely(vq->log_used)) {
>> +		/* Log used index update. */
>> +		log_write(vq->log_base,
>> +			  vq->log_addr + offsetof(struct vring_used, idx),
>> +			  sizeof(vq->used->idx));
>> +		if (vq->log_ctx)
>> +			eventfd_signal(vq->log_ctx, 1);
>> +	}
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(vhost_add_used_idx);
>> +
>>   static int __vhost_add_used_n(struct vhost_virtqueue *vq,
>>   			    struct vring_used_elem *heads,
>>   			    unsigned count)
>> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
>> index 16c2cb6..5dd6c05 100644
>> --- a/drivers/vhost/vhost.h
>> +++ b/drivers/vhost/vhost.h
>> @@ -199,6 +199,7 @@ int __vhost_get_vq_desc(struct vhost_virtqueue *vq,
>>   void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
>>   
>>   int vhost_vq_init_access(struct vhost_virtqueue *);
>> +int vhost_add_used_idx(struct vhost_virtqueue *vq, int n);
>>   int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
>>   int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
>>   		     unsigned count);
> Please change the API to hide the fact that there's an index that needs
> to be updated.

In fact, an interesting optimization on top is just call 
vhost_add_used_idx(vq, n) instead of n vhost_add_used_idx(vq, 1). That's 
the reason I leave n in the API.

Thanks

>
>> -- 
>> 2.7.4
