From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 2/5] vhost: introduce helper to prefetch desc
 index
Date: Thu, 28 Sep 2017 15:18:45 +0800
Message-ID: <502eb735-3aea-3799-1f92-87697d4ef198@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-3-git-send-email-jasowang@redhat.com>
 <20170926221435-mutt-send-email-mst@kernel.org>
 <17e9c3a9-7759-a674-bc00-414eabfed118@redhat.com>
 <20170928012906-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928012906-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月28日 06:57, Michael S. Tsirkin wrote:
> On Wed, Sep 27, 2017 at 08:35:47AM +0800, Jason Wang wrote:
>>
>> On 2017年09月27日 03:19, Michael S. Tsirkin wrote:
>>> On Fri, Sep 22, 2017 at 04:02:32PM +0800, Jason Wang wrote:
>>>> This patch introduces vhost_prefetch_desc_indices() which could batch
>>>> descriptor indices fetching and used ring updating. This intends to
>>>> reduce the cache misses of indices fetching and updating and reduce
>>>> cache line bounce when virtqueue is almost full. copy_to_user() was
>>>> used in order to benefit from modern cpus that support fast string
>>>> copy. Batched virtqueue processing will be the first user.
>>>>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> ---
>>>>    drivers/vhost/vhost.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>>>    drivers/vhost/vhost.h |  3 +++
>>>>    2 files changed, 58 insertions(+)
>>>>
>>>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>>>> index f87ec75..8424166d 100644
>>>> --- a/drivers/vhost/vhost.c
>>>> +++ b/drivers/vhost/vhost.c
>>>> @@ -2437,6 +2437,61 @@ struct vhost_msg_node *vhost_dequeue_msg(struct vhost_dev *dev,
>>>>    }
>>>>    EXPORT_SYMBOL_GPL(vhost_dequeue_msg);
>>>> +int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
>>>> +				struct vring_used_elem *heads,
>>>> +				u16 num, bool used_update)
>>> why do you need to combine used update with prefetch?
>> For better performance
>
> Why is sticking a branch in there better than requesting the update
> conditionally from the caller?

Ok, I get your point, I can split the two functions.

>
>
>
>> and I believe we don't care about the overhead when
>> we meet errors in tx.
> That's a separate question, I do not really understand how
> you can fetch a descriptor and update the used ring at the same
> time. This allows the guest to overwrite the buffer.
> I might be misunderstanding what is going on here though.

We don't update used idx, so guest can't overwrite the buffer I think?

Thanks
