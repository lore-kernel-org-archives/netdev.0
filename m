From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Fri, 15 Sep 2017 13:46:19 -0400
Message-ID: <CAF=yD-LZMjB5u0JRX36fYgV1HR6WqyJOGKopk5CLR=0rFBEV7g@mail.gmail.com>
References: <20170914140722.44292-1-nixiaoming@huawei.com> <CAF=yD-Jt5boxgQne4s1Fzy0y=Lq7RO4fjF6BfOCoh1bgaSECHQ@mail.gmail.com>
 <CAM_iQpWAeB+8bm9u+eHS3k_h5PSbnztXBvzTC=f0-tohdiSgzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nixiaoming <nixiaoming@huawei.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, waltje@uwalt.nl.mugnet.org,
        gw4pts@gw4pts.ampr.org, Andrey Konovalov <andreyknvl@google.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Philip Pettersson <philip.pettersson@gmail.com>,
        Alexander Potapenko <glider@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, dede.wu@huawei.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWAeB+8bm9u+eHS3k_h5PSbnztXBvzTC=f0-tohdiSgzQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 15, 2017 at 1:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Sep 14, 2017 at 7:35 AM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
>> On Thu, Sep 14, 2017 at 10:07 AM, nixiaoming <nixiaoming@huawei.com> wrote:
>>> From: l00219569 <lisimin@huawei.com>
>>>
>>> If fanout_add is preempted after running po-> fanout = match
>>> and before running __fanout_link,
>>> it will cause BUG_ON when __unregister_prot_hook call __fanout_unlink
>>>
>>> so, we need add mutex_lock(&fanout_mutex) to __unregister_prot_hook
>>
>> The packet socket code has no shortage of locks, so there are many
>> ways to avoid the race condition between fanout_add and packet_set_ring.
>>
>> Another option would be to lock the socket when calling fanout_add:
>>
>>     -               return fanout_add(sk, val & 0xffff, val >> 16);
>>     +               lock_sock(sk);
>>     +               ret = fanout_add(sk, val & 0xffff, val >> 16);
>>     +               release_sock(sk);
>>     +               return ret;
>>
>
> I don't think this is an option, because __unregister_prot_hook()
> can be called without lock_sock(), for example in packet_notifier().
>
>
>> But, for consistency, and to be able to continue to make sense of the
>> locking policy, we should use the most appropriate lock. This
>> is po->bind_lock, as it ensures atomicity between testing whether
>> a protocol hook is active through po->running and the actual existence
>> of that hook on the protocol hook list.
>
> Yeah, register_prot_hook() and unregister_prot_hook() already assume
> bind_lock.
>
> [...]
>
>>>  out:
>>>         mutex_unlock(&fanout_mutex);
>>> +       spin_unlock(&po->bind_lock);
>>
>> This function can call kzalloc with GFP_KERNEL, which may sleep. It is
>> not correct to sleep while holding a spinlock. Which is why I take the lock
>> later and test po->running again.
>
>
> Right, no need to mention the mutex_unlock() before the spin_unlock()
> is clearly wrong.
>
>
>>
>> I will clean up that patch and send it for review.
>
> How about the following patch?
>
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index c26172995511..f5c696a548ed 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1754,10 +1754,14 @@ static int fanout_add(struct sock *sk, u16 id,
> u16 type_flags)
>             match->prot_hook.dev == po->prot_hook.dev) {
>                 err = -ENOSPC;
>                 if (refcount_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
> +                       spin_lock(&po->bind_lock);
>                         __dev_remove_pack(&po->prot_hook);
> -                       po->fanout = match;
> -                       refcount_set(&match->sk_ref,
> refcount_read(&match->sk_ref) + 1);
> -                       __fanout_link(sk, po);
> +                       if (po->running) {
> +                               refcount_set(&match->sk_ref,
> refcount_read(&match->sk_ref) + 1);
> +                               po->fanout = match;
> +                               __fanout_link(sk, po);
> +                       }
> +                       spin_unlock(&po->bind_lock);
>                         err = 0;
>                 }
>         }

In case of failure we also need to unlink and free match. I
sent the following:

http://patchwork.ozlabs.org/patch/813945/
