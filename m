From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] virtio-net: rx busy polling support
Date: Thu, 17 Jul 2014 10:24:34 +0530
Message-ID: <53C7570A.7060504@gmail.com>
References: <1405491707-22706-1-git-send-email-jasowang@redhat.com>
	<1405491707-22706-4-git-send-email-jasowang@redhat.com>
	<53C63A11.4050401@gmail.com> <53C73B29.4070107@redhat.com>
	<53C742BA.3050402@gmail.com> <53C75481.1090705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Wang <jasowang@redhat.com>, rusty@rustcorp.com.au,
	mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <53C75481.1090705@redhat.com>
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

On Thursday 17 July 2014 10:13 AM, Jason Wang wrote:
> On 07/17/2014 11:27 AM, Varka Bhadram wrote:
>> On Thursday 17 July 2014 08:25 AM, Jason Wang wrote:
>>> On 07/16/2014 04:38 PM, Varka Bhadram wrote:
>>>> On 07/16/2014 11:51 AM, Jason Wang wrote:
>>>>> Add basic support for rx busy polling.
>>>>>
>>>>> Test was done between a kvm guest and an external host. Two hosts were
>>>>> connected through 40gb mlx4 cards. With both busy_poll and busy_read
>>>>> are set to 50 in guest, 1 byte netperf tcp_rr shows 116% improvement:
>>>>> transaction rate was increased from 9151.94 to 19787.37.
>>>>>
>>>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>>> Cc: Vlad Yasevich <vyasevic@redhat.com>
>>>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>> ---
>>>>>     drivers/net/virtio_net.c | 190
>>>>> ++++++++++++++++++++++++++++++++++++++++++++++-
>>>>>     1 file changed, 187 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>>>> index e417d93..4830713 100644
>>>>> --- a/drivers/net/virtio_net.c
>>>>> +++ b/drivers/net/virtio_net.c
>>>>> @@ -27,6 +27,7 @@
>>>>>     #include <linux/slab.h>
>>>>>     #include <linux/cpu.h>
>>>>>     #include <linux/average.h>
>>>>> +#include <net/busy_poll.h>
>>>>>       static int napi_weight = NAPI_POLL_WEIGHT;
>>>>>     module_param(napi_weight, int, 0444);
>>>>> @@ -94,8 +95,143 @@ struct receive_queue {
>>>>>           /* Name of this receive queue: input.$index */
>>>>>         char name[40];
>>>>> +
>>>>> +#ifdef CONFIG_NET_RX_BUSY_POLL
>>>>> +    unsigned int state;
>>>>> +#define VIRTNET_RQ_STATE_IDLE        0
>>>>> +#define VIRTNET_RQ_STATE_NAPI         1    /* NAPI or refill owns
>>>>> this RQ */
>>>>> +#define VIRTNET_RQ_STATE_POLL         2    /* poll owns this RQ */
>>>>> +#define VIRTNET_RQ_STATE_DISABLED    4    /* RQ is disabled */
>>>>> +#define VIRTNET_RQ_OWNED (VIRTNET_RQ_STATE_NAPI |
>>>>> VIRTNET_RQ_STATE_POLL)
>>>>> +#define VIRTNET_RQ_LOCKED (VIRTNET_RQ_OWNED |
>>>>> VIRTNET_RQ_STATE_DISABLED)
>>>>> +#define VIRTNET_RQ_STATE_NAPI_YIELD  8    /* NAPI or refill yielded
>>>>> this RQ */
>>>>> +#define VIRTNET_RQ_STATE_POLL_YIELD  16   /* poll yielded this RQ */
>>>>> +    spinlock_t lock;
>>>>> +#endif  /* CONFIG_NET_RX_BUSY_POLL */
>>>>>     };
>>>>>     +#ifdef CONFIG_NET_RX_BUSY_POLL
>>>>> +static inline void virtnet_rq_init_lock(struct receive_queue *rq)
>>>>> +{
>>>>> +
>>>>> +    spin_lock_init(&rq->lock);
>>>>> +    rq->state = VIRTNET_RQ_STATE_IDLE;
>>>>> +}
>>>>> +
>>>>> +/* called from the device poll routine or refill routine to get
>>>>> ownership of a
>>>>> + * receive queue.
>>>>> + */
>>>>> +static inline bool virtnet_rq_lock_napi_refill(struct receive_queue
>>>>> *rq)
>>>>> +{
>>>>> +    int rc = true;
>>>>> +
>>>> bool instead of int...?
>>> Yes, it was better.
>>>>> +    spin_lock(&rq->lock);
>>>>> +    if (rq->state & VIRTNET_RQ_LOCKED) {
>>>>> +        WARN_ON(rq->state & VIRTNET_RQ_STATE_NAPI);
>>>>> +        rq->state |= VIRTNET_RQ_STATE_NAPI_YIELD;
>>>>> +        rc = false;
>>>>> +    } else
>>>>> +        /* we don't care if someone yielded */
>>>>> +        rq->state = VIRTNET_RQ_STATE_NAPI;
>>>>> +    spin_unlock(&rq->lock);
>>>> Lock for rq->state ...?
>>>>
>>>> If yes:
>>>> spin_lock(&rq->lock);
>>>> if (rq->state & VIRTNET_RQ_LOCKED) {
>>>>       rq->state |= VIRTNET_RQ_STATE_NAPI_YIELD;
>>>>       spin_unlock(&rq->lock);
>>>>       WARN_ON(rq->state & VIRTNET_RQ_STATE_NAPI);
>>>>       rc = false;
>>>> } else {
>>>>       /* we don't care if someone yielded */
>>>>       rq->state = VIRTNET_RQ_STATE_NAPI;
>>>>       spin_unlock(&rq->lock);
>>>> }
>>> I didn't see any differences. Is this used to catch the bug of driver
>>> earlier? btw, several other rx busy polling capable driver does the same
>>> thing.
>> We need not to include WARN_ON() & rc=false under critical section.
>>
> Ok. but unless there's a bug in the driver itself, WARN_ON() should be
> just a condition check for a branch, so there should not be noticeable
> differences.
>
> Also we should not check rq->state outside the protection of lock.

Ok. I will agree with you. But 'rc' can be outside the protection of lock

-- 
Regards,
Varka Bhadram
