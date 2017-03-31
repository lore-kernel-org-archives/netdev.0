From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 net-next 7/7] vhost_net: try batch dequing from skb
 array
Date: Fri, 31 Mar 2017 14:47:32 +0800
Message-ID: <18c7c8fe-51a6-c3ca-d9a1-a07836bc44d2@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
 <1490858550-7763-8-git-send-email-jasowang@redhat.com>
 <20170330165332-mutt-send-email-mst@kernel.org>
 <07e86eec-7102-f635-b840-4f2efc3c1570@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07e86eec-7102-f635-b840-4f2efc3c1570@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年03月31日 12:02, Jason Wang wrote:
>
>
> On 2017年03月30日 22:21, Michael S. Tsirkin wrote:
>> On Thu, Mar 30, 2017 at 03:22:30PM +0800, Jason Wang wrote:
>>> We used to dequeue one skb during recvmsg() from skb_array, this could
>>> be inefficient because of the bad cache utilization
>> which cache does this refer to btw?
>
> Both icache and dcache more or less.
>
>>
>>> and spinlock
>>> touching for each packet.
>> Do you mean the effect of extra two atomics here?
>
> In fact four, packet length peeking needs another two.
>
>>
>>> This patch tries to batch them by calling
>>> batch dequeuing helpers explicitly on the exported skb array and pass
>>> the skb back through msg_control for underlayer socket to finish the
>>> userspace copying.
>>>
>>> Tests were done by XDP1:
>>> - small buffer:
>>>    Before: 1.88Mpps
>>>    After : 2.25Mpps (+19.6%)
>>> - mergeable buffer:
>>>    Before: 1.83Mpps
>>>    After : 2.10Mpps (+14.7%)
>>>
>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> Looks like I misread the code previously. More comments below,
>> sorry about not asking these questions earlier.
>>
>>> ---
>>>   drivers/vhost/net.c | 64 
>>> +++++++++++++++++++++++++++++++++++++++++++++++++----
>>>   1 file changed, 60 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>>> index 9b51989..ffa78c6 100644
>>> --- a/drivers/vhost/net.c
>>> +++ b/drivers/vhost/net.c
>>> @@ -28,6 +28,8 @@
>>>   #include <linux/if_macvlan.h>
>>>   #include <linux/if_tap.h>
>>>   #include <linux/if_vlan.h>
>>> +#include <linux/skb_array.h>
>>> +#include <linux/skbuff.h>
>>>     #include <net/sock.h>
>>>   @@ -85,6 +87,7 @@ struct vhost_net_ubuf_ref {
>>>       struct vhost_virtqueue *vq;
>>>   };
>>>   +#define VHOST_RX_BATCH 64
>>>   struct vhost_net_virtqueue {
>>>       struct vhost_virtqueue vq;
>>>       size_t vhost_hlen;
>> Could you please try playing with batch size and see
>> what the effect is?
>
> Ok. I tried 32 which seems slower than 64 but still faster than no 
> batching.

Ok, result is:

no batching   1.88Mpps
RX_BATCH=1    1.93Mpps
RX_BATCH=4    2.11Mpps
RX_BATCH=16   2.14Mpps
RX_BATCH=64   2.25Mpps
RX_BATCH=256  2.18Mpps


>
>>
>>> @@ -99,6 +102,10 @@ struct vhost_net_virtqueue {
>>>       /* Reference counting for outstanding ubufs.
>>>        * Protected by vq mutex. Writers must also take device mutex. */
>>>       struct vhost_net_ubuf_ref *ubufs;
>>> +    struct skb_array *rx_array;
>>> +    void *rxq[VHOST_RX_BATCH];
>>> +    int rt;
>>> +    int rh;
>>>   };
>>>     struct vhost_net {
>>> @@ -201,6 +208,8 @@ static void vhost_net_vq_reset(struct vhost_net *n)
>>>           n->vqs[i].ubufs = NULL;
>>>           n->vqs[i].vhost_hlen = 0;
>>>           n->vqs[i].sock_hlen = 0;
>>> +        n->vqs[i].rt = 0;
>>> +        n->vqs[i].rh = 0;
>>>       }
>>>     }
>>> @@ -503,13 +512,30 @@ static void handle_tx(struct vhost_net *net)
>>>       mutex_unlock(&vq->mutex);
>>>   }
>>>   -static int peek_head_len(struct sock *sk)
>>> +static int fetch_skbs(struct vhost_net_virtqueue *rvq)
>>> +{
>>> +    if (rvq->rh != rvq->rt)
>>> +        goto out;
>>> +
>>> +    rvq->rh = rvq->rt = 0;
>>> +    rvq->rt = skb_array_consume_batched(rvq->rx_array, rvq->rxq,
>>> +                        VHOST_RX_BATCH);
>>> +    if (!rvq->rt)
>>> +        return 0;
>>> +out:
>>> +    return __skb_array_len_with_tag(rvq->rxq[rvq->rh]);
>>> +}
>>> +
>>> +static int peek_head_len(struct vhost_net_virtqueue *rvq, struct 
>>> sock *sk)
>>>   {
>>>       struct socket *sock = sk->sk_socket;
>>>       struct sk_buff *head;
>>>       int len = 0;
>>>       unsigned long flags;
>>>   +    if (rvq->rx_array)
>>> +        return fetch_skbs(rvq);
>>> +
>>>       if (sock->ops->peek_len)
>>>           return sock->ops->peek_len(sock);
>>>   @@ -535,12 +561,14 @@ static int sk_has_rx_data(struct sock *sk)
>>>       return skb_queue_empty(&sk->sk_receive_queue);
>>>   }
>>>   -static int vhost_net_rx_peek_head_len(struct vhost_net *net, 
>>> struct sock *sk)
>>> +static int vhost_net_rx_peek_head_len(struct vhost_net *net,
>>> +                      struct sock *sk)
>>>   {
>>> +    struct vhost_net_virtqueue *rvq = &net->vqs[VHOST_NET_VQ_RX];
>>>       struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
>>>       struct vhost_virtqueue *vq = &nvq->vq;
>>>       unsigned long uninitialized_var(endtime);
>>> -    int len = peek_head_len(sk);
>>> +    int len = peek_head_len(rvq, sk);
>>>         if (!len && vq->busyloop_timeout) {
>>>           /* Both tx vq and rx socket were polled here */
>>> @@ -561,7 +589,7 @@ static int vhost_net_rx_peek_head_len(struct 
>>> vhost_net *net, struct sock *sk)
>>>               vhost_poll_queue(&vq->poll);
>>>           mutex_unlock(&vq->mutex);
>>>   -        len = peek_head_len(sk);
>>> +        len = peek_head_len(rvq, sk);
>>>       }
>>>         return len;
>>> @@ -699,6 +727,8 @@ static void handle_rx(struct vhost_net *net)
>>>           /* On error, stop handling until the next kick. */
>>>           if (unlikely(headcount < 0))
>>>               goto out;
>>> +        if (nvq->rx_array)
>>> +            msg.msg_control = nvq->rxq[nvq->rh++];
>>>           /* On overrun, truncate and discard */
>>>           if (unlikely(headcount > UIO_MAXIOV)) {
>>>               iov_iter_init(&msg.msg_iter, READ, vq->iov, 1, 1);
>> So there's a bit of a mystery here. vhost code isn't
>> batched, all we are batching is the fetch from the tun ring.
>
> I've already had vhost batching code on top (e.g descriptor indices 
> prefetching and used ring batched updating like dpdk). Baching dequing 
> from skb array is the requirement for them.
>
>>
>> So what is the source of the speedup?
>
> Well, perf diff told something like this:
>
>     13.69%   +2.05%  [kernel.vmlinux]  [k] copy_user_generic_string
>     10.77%   +2.04%  [vhost]           [k] vhost_signal
>      9.59%   -3.28%  [kernel.vmlinux]  [k] copy_to_iter
>      7.22%           [tun]             [k] tun_peek_len
>      6.06%   -1.50%  [tun]             [k] tun_do_read.part.45
>      4.83%   +4.13%  [vhost]           [k] vhost_get_vq_desc
>      4.61%   -4.42%  [kernel.vmlinux]  [k] _raw_spin_lock
>
> Batching eliminate 95% calls for raw_spin_lock.
>
>>
>> Are queued spinlocks that expensive? They shouldn't be ...
>> Could you try using virt_spin_lock instead (at least as a quick hack)
>> to see whether that helps?
>
> Will try.

I suspect it will have much difference, virt_spin_lock() has:

     do {
         while (atomic_read(&lock->val) != 0)
             cpu_relax();
     } while (atomic_cmpxchg(&lock->val, 0, _Q_LOCKED_VAL) != 0);

while queued_spin_lock():

     val = atomic_cmpxchg_acquire(&lock->val, 0, _Q_LOCKED_VAL);
     if (likely(val == 0))
         return;
     queued_spin_lock_slowpath(lock, val);

Since no other consumers during the test, the only difference is queued 
version use a relaxed version of atomic_cmpxchg_acquire().

Thanks

>
>>> @@ -841,6 +871,8 @@ static int vhost_net_open(struct inode *inode, 
>>> struct file *f)
>>>           n->vqs[i].done_idx = 0;
>>>           n->vqs[i].vhost_hlen = 0;
>>>           n->vqs[i].sock_hlen = 0;
>>> +        n->vqs[i].rt = 0;
>>> +        n->vqs[i].rh = 0;
>>>       }
>>>       vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
>>>
>>> @@ -856,11 +888,15 @@ static struct socket *vhost_net_stop_vq(struct 
>>> vhost_net *n,
>>>                       struct vhost_virtqueue *vq)
>>>   {
>>>       struct socket *sock;
>>> +    struct vhost_net_virtqueue *nvq =
>>> +        container_of(vq, struct vhost_net_virtqueue, vq);
>>>         mutex_lock(&vq->mutex);
>>>       sock = vq->private_data;
>>>       vhost_net_disable_vq(n, vq);
>>>       vq->private_data = NULL;
>>> +    while (nvq->rh != nvq->rt)
>>> +        kfree_skb(nvq->rxq[nvq->rh++]);
>>>       mutex_unlock(&vq->mutex);
>>>       return sock;
>>>   }
>> So I didn't realise it but of course the effect will be
>> dropped packets if we just connect and disconnect without
>> consuming anything.
>
> Any reason that we need care about this?
>
>>
>> So I think it's worth it to try analysing the speedup a bit
>> and see whether we can get the gains without queueing
>> the skbs in vhost.
>
> Technically, other userspace may do recvmsg in the same time. So it's 
> not easy to gain the same speedup as this patch.
>
>>> @@ -953,6 +989,25 @@ static struct socket *get_raw_socket(int fd)
>>>       return ERR_PTR(r);
>>>   }
>>>   +static struct skb_array *get_tap_skb_array(int fd)
>> That's a confusing name, pls prefix with vhost_, not tap.
>
> Ok, but I just follow the name of existing code (e.g the below 
> get_tap_socket).
>
> Thanks
>
>>
>>> +{
>>> +    struct skb_array *array;
>>> +    struct file *file = fget(fd);
>>> +
>>> +    if (!file)
>>> +        return NULL;
>>> +    array = tun_get_skb_array(file);
>>> +    if (!IS_ERR(array))
>>> +        goto out;
>>> +    array = tap_get_skb_array(file);
>>> +    if (!IS_ERR(array))
>>> +        goto out;
>>> +    array = NULL;
>>> +out:
>>> +    fput(file);
>>> +    return array;
>>> +}
>>> +
>>>   static struct socket *get_tap_socket(int fd)
>>>   {
>>>       struct file *file = fget(fd);
>>> @@ -1029,6 +1084,7 @@ static long vhost_net_set_backend(struct 
>>> vhost_net *n, unsigned index, int fd)
>>>             vhost_net_disable_vq(n, vq);
>>>           vq->private_data = sock;
>>> +        nvq->rx_array = get_tap_skb_array(fd);
>>>           r = vhost_vq_init_access(vq);
>>>           if (r)
>>>               goto err_used;
>>> -- 
>>> 2.7.4
>
