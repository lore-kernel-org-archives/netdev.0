From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 5/6] vhost_net: poll vhost queue after marking DMA
	is done
Date: Wed, 12 Feb 2014 18:06:15 +0800
Message-ID: <52FB4797.2020101@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-6-git-send-email-jasowang@redhat.com>
	<52FB24EA.3060001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com
To: Qin Chuanyu <qinchuanyu@huawei.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <52FB24EA.3060001@huawei.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/12/2014 03:38 PM, Qin Chuanyu wrote:
> On 2013/8/30 12:29, Jason Wang wrote:
>> We used to poll vhost queue before making DMA is done, this is racy
>> if vhost
>> thread were waked up before marking DMA is done which can result the
>> signal to
>> be missed. Fix this by always poll the vhost thread before DMA is done.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/vhost/net.c |    9 +++++----
>>   1 files changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index ff60c2a..d09c17c 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -308,6 +308,11 @@ static void vhost_zerocopy_callback(struct
>> ubuf_info *ubuf, bool success)
>>       struct vhost_virtqueue *vq = ubufs->vq;
>>       int cnt = atomic_read(&ubufs->kref.refcount);
>>
>> +    /* set len to mark this desc buffers done DMA */
>> +    vq->heads[ubuf->desc].len = success ?
>> +        VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
>> +    vhost_net_ubuf_put(ubufs);
>> +
>>       /*
>>        * Trigger polling thread if guest stopped submitting new buffers:
>>        * in this case, the refcount after decrement will eventually
>> reach 1
>> @@ -318,10 +323,6 @@ static void vhost_zerocopy_callback(struct
>> ubuf_info *ubuf, bool success)
>>        */
>>       if (cnt <= 2 || !(cnt % 16))
>>           vhost_poll_queue(&vq->poll);
>> -    /* set len to mark this desc buffers done DMA */
>> -    vq->heads[ubuf->desc].len = success ?
>> -        VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
>> -    vhost_net_ubuf_put(ubufs);
>>   }
>>
>>   /* Expects to be always run from workqueue - which acts as
>>
> with this change, vq would lose protection that provided by ubufs->kref.
> if another thread is waiting at vhost_net_ubuf_put_and_wait called by
> vhost_net_release, then after vhost_net_ubuf_put, vq would been free
> by vhost_net_release soon, vhost_poll_queue(&vq->poll) may cause NULL
> pointer Exception.
>

Good catch.
> another question is that vhost_zerocopy_callback is called by kfree_skb,
> it may called in different thread context.
> vhost_poll_queue is called decided by ubufs->kref.refcount, this may
> cause there isn't any thread call  vhost_poll_queue, but at least one
> is needed. and this cause network break.
> We could repeat it by using 8 netperf thread in guest to xmit tcp to
> its host.
>
> I think if using atomic_read to decide while do vhost_poll_queue or not,
> at least a spink_lock is needed.

Then you need another ref count to protect that spinlock? Care to send
patches?

Thanks
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
