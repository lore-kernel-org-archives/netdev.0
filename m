From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Tue, 17 May 2016 09:38:37 +0800
Message-ID: <573A761D.8080909@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <20160516070012-mutt-send-email-mst@redhat.com> <57397C2B.7000603@redhat.com>
 <20160516105434-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932499AbcEQBim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 21:38:42 -0400
In-Reply-To: <20160516105434-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 16:08, Michael S. Tsirkin wrote:
> On Mon, May 16, 2016 at 03:52:11PM +0800, Jason Wang wrote:
>>
>> On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 12:23, Michael S. Tsirkin wro=
te:
>>> On Mon, May 16, 2016 at 09:17:01AM +0800, Jason Wang wrote:
>>>> We used to queue tx packets in sk_receive_queue, this is less
>>>> efficient since it requires spinlocks to synchronize between produ=
cer
>>>> and consumer.
>>>>
>>>> This patch tries to address this by using circular buffer which al=
lows
>>>> lockless synchronization. This is done by switching from
>>>> sk_receive_queue to a tx skb ring with a new flag IFF_TX_RING and =
when
>>>> this is set:
>>> Why do we need a new flag? Is there a userspace-visible
>>> behaviour change?
>> Probably yes since tx_queue_length does not work.
> So the flag name should reflect the behaviour somehow, not
> the implementation.
>
>>>> - store pointer to skb in circular buffer in tun_net_xmit(), and r=
ead
>>>>    it from the circular buffer in tun_do_read().
>>>> - introduce a new proto_ops peek which could be implemented by
>>>>    specific socket which does not use sk_receive_queue.
>>>> - store skb length in circular buffer too, and implement a lockles=
s
>>>>    peek for tuntap.
>>>> - change vhost_net to use proto_ops->peek() instead
>>>> - new spinlocks were introduced to synchronize among producers (an=
d so
>>>>    did for consumers).
>>>>
>>>> Pktgen test shows about 9% improvement on guest receiving pps:
>>>>
>>>> Before: ~1480000pps
>>>> After : ~1610000pps
>>>>
>>>> (I'm not sure noblocking read is still needed, so it was not inclu=
ded
>>>>   in this patch)
>>> How do you mean? Of course we must support blocking and non-blockin=
g
>>> read - userspace uses it.
>> Ok, will add this.
>>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> ---
>>>> ---
>>>>   drivers/net/tun.c           | 157 ++++++++++++++++++++++++++++++=
+++++++++++---
>>>>   drivers/vhost/net.c         |  16 ++++-
>>>>   include/linux/net.h         |   1 +
>>>>   include/uapi/linux/if_tun.h |   1 +
>>>>   4 files changed, 165 insertions(+), 10 deletions(-)
>>>>
>>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>>>> index 425e983..6001ece 100644
>>>> --- a/drivers/net/tun.c
>>>> +++ b/drivers/net/tun.c
>>>> @@ -71,6 +71,7 @@
>>>>   #include <net/sock.h>
>>>>   #include <linux/seq_file.h>
>>>>   #include <linux/uio.h>
>>>> +#include <linux/circ_buf.h>
>>>>   #include <asm/uaccess.h>
>>>> @@ -130,6 +131,8 @@ struct tap_filter {
>>>>   #define MAX_TAP_FLOWS  4096
>>>>   #define TUN_FLOW_EXPIRE (3 * HZ)
>>>> +#define TUN_RING_SIZE 256
>>> Can we resize this according to tx_queue_len set by user?
>> We can, but it needs lots of other changes, e.g being notified when
>> tx_queue_len was changed by user.
> Some kind of notifier?

Yes, maybe.

> Probably better than a new user interface.

Ok.

>
>> And if tx_queue_length is not power of 2,
>> we probably need modulus to calculate the capacity.
> Is that really that important for speed?

Not sure, I can test.

> If yes, round it up to next power of two.

Right, this sounds a good solution.

> You can also probably wrap it with a conditional instead.
>
>>>> +#define TUN_RING_MASK (TUN_RING_SIZE - 1)
>>>>   struct tun_pcpu_stats {
>>>>   	u64 rx_packets;
>>>> @@ -142,6 +145,11 @@ struct tun_pcpu_stats {
>>>>   	u32 rx_frame_errors;
>>>>   };
>>>> +struct tun_desc {
>>>> +	struct sk_buff *skb;
>>>> +	int len; /* Cached skb len for peeking */
>>>> +};
>>>> +
>>>>   /* A tun_file connects an open character device to a tuntap netd=
evice. It
>>>>    * also contains all socket related structures (except sock_fpro=
g and tap_filter)
>>>>    * to serve as one transmit queue for tuntap device. The sock_fp=
rog and
>>>> @@ -167,6 +175,13 @@ struct tun_file {
>>>>   	};
>>>>   	struct list_head next;
>>>>   	struct tun_struct *detached;
>>>> +	/* reader lock */
>>>> +	spinlock_t rlock;
>>>> +	unsigned long tail;
>>>> +	struct tun_desc tx_descs[TUN_RING_SIZE];
>>>> +	/* writer lock */
>>>> +	spinlock_t wlock;
>>>> +	unsigned long head;
>>>>   };
>>>>   struct tun_flow_entry {
>>>> @@ -515,7 +530,27 @@ static struct tun_struct *tun_enable_queue(st=
ruct tun_file *tfile)
>>>>   static void tun_queue_purge(struct tun_file *tfile)
>>>>   {
>>>> +	unsigned long head, tail;
>>>> +	struct tun_desc *desc;
>>>> +	struct sk_buff *skb;
>>>>   	skb_queue_purge(&tfile->sk.sk_receive_queue);
>>>> +	spin_lock(&tfile->rlock);
>>>> +
>>>> +	head =3D ACCESS_ONCE(tfile->head);
>>>> +	tail =3D tfile->tail;
>>>> +
>>>> +	/* read tail before reading descriptor at tail */
>>>> +	smp_rmb();
>>> I think you mean read *head* here
>> Right.
>>
>>>
>>>> +
>>>> +	while (CIRC_CNT(head, tail, TUN_RING_SIZE) >=3D 1) {
>>>> +		desc =3D &tfile->tx_descs[tail];
>>>> +		skb =3D desc->skb;
>>>> +		kfree_skb(skb);
>>>> +		tail =3D (tail + 1) & TUN_RING_MASK;
>>>> +		/* read descriptor before incrementing tail. */
>>>> +		smp_store_release(&tfile->tail, tail & TUN_RING_MASK);
>>>> +	}
>>>> +	spin_unlock(&tfile->rlock);
>>>>   	skb_queue_purge(&tfile->sk.sk_error_queue);
>>>>   }
>>>>
>>> Barrier pairing seems messed up. Could you tag
>>> each barrier with its pair pls?
>>> E.g. add /* Barrier A for pairing */ Before barrier and
>>> its pair.
>> Ok.
>>
>> for both tun_queue_purge() and tun_do_read():
>>
>> smp_rmb() is paired with smp_store_release() in tun_net_xmit().
> this seems at least an overkill. rmb would normally be paired with wm=
b,
> not a full mb within release.

wmb is not enough here. We need guarantee the descriptor is read before=
=20
we increase head. And full mb is more heavyweight that=20
smp_store_release(). For paring, I can change to use=20
smp_load_acquire(tfile->head) in tun_do_read().

>
>> smp_store_release() is paired with spin_unlock()/spin_lock() in
>> tun_net_xmit().
> release can't be paired with unlock since that's also a release.
> lock is an acquire but from what I have seen you keep it around
> operations not in the middle.

Right, so I will switch to use load_acquire() in this case.

>
>>>> @@ -824,6 +859,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff=
 *skb, struct net_device *dev)
>>>>   	int txq =3D skb->queue_mapping;
>>>>   	struct tun_file *tfile;
>>>>   	u32 numqueues =3D 0;
>>>> +	unsigned long flags;
>>>>   	rcu_read_lock();
>>>>   	tfile =3D rcu_dereference(tun->tfiles[txq]);
>>>> @@ -888,8 +924,35 @@ static netdev_tx_t tun_net_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>>>>   	nf_reset(skb);
>>>> -	/* Enqueue packet */
>>>> -	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
>>>> +	if (tun->flags & IFF_TX_RING) {
>>>> +		unsigned long head, tail;
>>>> +
>>>> +		spin_lock_irqsave(&tfile->wlock, flags);
>>>> +
>>>> +		head =3D tfile->head;
>>>> +		tail =3D ACCESS_ONCE(tfile->tail);
>>> this should be acquire
>> Consider there's always one slot left empty, so we need to produced =
two skbs
>> here before we could corrupt consumer. So the spin_unlock()/spin_loc=
k()
>> provides ordering here?
> It's better to just follow memory barrier rules.

Ok.

>
>
>>>> + > >>+		if (CIRC_SPACE(head, tail, TUN_RING_SIZE) >=3D 1) {
>>>> +			struct tun_desc *desc =3D &tfile->tx_descs[head];
>>>> +
>>>> +			desc->skb =3D skb;
>>>> +			desc->len =3D skb->len;
>>>> +			if (skb_vlan_tag_present(skb))
>>>> +				desc->len +=3D VLAN_HLEN;
>>>> +
>>>> +			/* read descriptor before incrementing head. */
>>> write descriptor.
>> Right.
>>
>>>   so smp_wmb is enough.
>> I thought smp_store_release() was more lightweight than smp_wmb()?
> Why do you think this?  On which architecture?

Sorry, I was wrong here.
