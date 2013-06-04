From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc V2 7/8] macvtap: add TUNSETQUEUE ioctl
Date: Tue, 04 Jun 2013 13:54:56 +0800
Message-ID: <51AD8130.1090807@redhat.com>
References: <1369994005-5943-1-git-send-email-jasowang@redhat.com> <1369994005-5943-8-git-send-email-jasowang@redhat.com> <20130602112228.GA10190@redhat.com> <51AC27BA.8050808@redhat.com> <20130603110923.GA11241@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279Ab3FDFzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 01:55:23 -0400
In-Reply-To: <20130603110923.GA11241@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 07:09 PM, Michael S. Tsirkin wrote:
> On Mon, Jun 03, 2013 at 01:20:58PM +0800, Jason Wang wrote:
>> On 06/02/2013 07:22 PM, Michael S. Tsirkin wrote:
>>> On Fri, May 31, 2013 at 05:53:24PM +0800, Jason Wang wrote:
>>>> This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
>>>> enable a queue of macvtap. This is used to be compatible at API layer of tuntap
>>>> to simplify the userspace to manage the queues.
>>>>
>>>> This is done by split the taps array into three different areas:
>>>>
>>>> - [0, numvtaps) : enabled taps
>>>> - [numvtaps, numvtaps + numdisabled) : disabled taps
>>>> - [numvtaps + numdisabled, MAX_MAXVTAP_QUEUES) : unused slots
>>>>
>>>> When a tap were enabled and disabled, it was moved to another area.
>>>>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> This seems a bit tricky. Can we just move the tap out of the
>>> array? 
>> Certainly yes.
>>> the only reason we have the array is for fast
>>> lookup on xmit.
>>> What's the reason to keep disabled queues there?
>> It saves us some space and make code simpler.
>>> To be able to track all queues for cleanups, all we need is
>>> a linked list of all queues (enabled and disabled).
>> Yes, but you need iterate both arrays and linked list which won't be
>> simpler than keeping them in place.
> No, my idea is to keep all taps in the list.
>
> If you need all taps, walks the list.
> If you need active taps, look them up in the array.
>
> Reasonable?

Looks so, will change in next version.
>
>>>> ---
>>>>  drivers/net/macvtap.c      |  167 ++++++++++++++++++++++++++++++++++++++++----
>>>>  include/linux/if_macvlan.h |    7 ++
>>>>  2 files changed, 159 insertions(+), 15 deletions(-)
>>>>
>>>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>> index eac49cb..03b781c 100644
>>>> --- a/drivers/net/macvtap.c
>>>> +++ b/drivers/net/macvtap.c
>>>> @@ -85,32 +85,126 @@ static const struct proto_ops macvtap_socket_ops;
>>>>   */
>>>>  static DEFINE_SPINLOCK(macvtap_lock);
>>>>  
>>>> -static int macvtap_set_queue(struct net_device *dev, struct file *file,
>>>> +static void macvtap_swap_slot(struct macvlan_dev *vlan, int a, int b)
>>>> +{
>>>> +	struct macvtap_queue *q1, *q2;
>>>> +
>>>> +	if (a == b)
>>>> +		return;
>>>> +
>>>> +	q1 = rcu_dereference_protected(vlan->taps[a],
>>>> +				       lockdep_is_held(&macvtap_lock));
>>>> +	q2 = rcu_dereference_protected(vlan->taps[b],
>>>> +				       lockdep_is_held(&macvtap_lock));
>>>> +
>>>> +	BUG_ON(q1 == NULL || q2 == NULL);
>>>> +
>>>> +	rcu_assign_pointer(vlan->taps[a], q2);
>>>> +	rcu_assign_pointer(vlan->taps[b], q1);
>>>> +
>>>> +	q1->queue_index = b;
>>>> +	q2->queue_index = a;
>>>> +}
>>>> +
>>>> +static int macvtap_enable_queue(struct net_device *dev, struct file *file,
>>>>  				struct macvtap_queue *q)
>>>>  {
>>>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>>>> +	int err = -EINVAL;
>>>> +	int total;
>>>> +
>>>> +	spin_lock(&macvtap_lock);
>>>> +	total = vlan->numvtaps + vlan->numdisabled;
>>>> +
>>>> +	if (q->queue_index < vlan->numvtaps)
>>>> +		goto out;
>>>> +
>>>> +	err = 0;
>>>> +
>>>> +	BUG_ON(q->queue_index >= total);
>>>> +	macvtap_swap_slot(vlan, q->queue_index, vlan->numvtaps);
>>>> +
>>>> +	/* Make sure the pointers were seen before indices. */
>>>> +	wmb();
>>> Which indices?  We only care about numvtaps right?
>>> So let's just say so.
>> ok
>>> Why is this wmb and not smp_wmb()?
>> will correct it.
>>>> +
>>>> +	vlan->numdisabled--;
>>>> +	vlan->numvtaps++;
>>>> +out:
>>>> +	spin_unlock(&macvtap_lock);
>>>> +	return err;
>>>> +}
>>>> +
>>>> +static int macvtap_set_queue(struct net_device *dev, struct file *file,
>>>> +			     struct macvtap_queue *q)
>>>> +{
>>>> +	struct macvlan_dev *vlan = netdev_priv(dev);
>>>>  	int err = -EBUSY;
>>>> +	int total;
>>>>  
>>>>  	spin_lock(&macvtap_lock);
>>>> -	if (vlan->numvtaps == MAX_MACVTAP_QUEUES)
>>>> +
>>>> +	total = vlan->numvtaps + vlan->numdisabled;
>>>> +	if (total == MAX_MACVTAP_QUEUES)
>>>>  		goto out;
>>>>  
>>>>  	err = 0;
>>>> +
>>>>  	rcu_assign_pointer(q->vlan, vlan);
>>>> -	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
>>>> +	rcu_assign_pointer(vlan->taps[total], q);
>>>>  	sock_hold(&q->sk);
>>>>  
>>>>  	q->file = file;
>>>> -	q->queue_index = vlan->numvtaps;
>>>> +	q->queue_index = total;
>>>>  	file->private_data = q;
>>>> +	if (vlan->numdisabled)
>>>> +		macvtap_swap_slot(vlan, vlan->numvtaps, total);
>>>>  
>>>> -	vlan->numvtaps++;
>>>> +	/* Make sure the pointers were seen before indices. */
>>>> +	wmb();
>>>>  
>>>> +	vlan->numvtaps++;
>>>>  out:
>>>>  	spin_unlock(&macvtap_lock);
>>>>  	return err;
>>>>  }
>>>>  
>>>> +static int macvtap_disable_queue(struct macvtap_queue *q)
>>>> +{
>>>> +	struct macvlan_dev *vlan;
>>>> +	int err = -EINVAL;
>>>> +
>>>> +	spin_lock(&macvtap_lock);
>>>> +	vlan = rcu_dereference_protected(q->vlan,
>>>> +					 lockdep_is_held(&macvtap_lock));
>>>> +
>>>> +	if (vlan) {
>>>> +		int total = vlan->numvtaps + vlan->numdisabled;
>>>> +		int index = q->queue_index;
>>>> +
>>>> +		BUG_ON(q->queue_index >= total);
>>>> +		if (q->queue_index >= vlan->numvtaps)
>>>> +			goto out;
>>>> +
>>>> +		err = 0;
>>>> +		macvtap_swap_slot(vlan, index, total - 1);
>>>> +		if (vlan->numdisabled)
>>>> +			/* If there's disabled taps, the above swap will cause
>>>> +			 * a disabled tap to be moved to enabled area. So
>>>> +			 * another swap is needed to keep the right order.
>>>> +			 */
>>>> +			macvtap_swap_slot(vlan, index, vlan->numvtaps - 1);
>>>> +
>>>> +		/* make sure the pointers were seen before indices */
>>>> +		wmb();
>>> Hmm this looks questionable. The code near rmb first
>>> checks numvtaps then dereferences the queue.
>>> So it might see a new queue but old value of numvtaps.
>> Right, barriers here were just best effort to reduce the possibility of
>> wrong queue selection when changing the number of queues.
> If this is an optimization, I'd say benchmark it and
> see if it helps performance.
>
> I don't expect it to have any effect really.
> In fact, the re-ordering of queues that this patch does
> is likely to cause packet reorering and hurt performance
> more.

Yes, so I will remove the barriers.

The re-ordering seems to be the easiest way to do fast lookup of active
queues. We could use indirection to avoid the re-ordering of queues,
it's hard to eliminate OOO packets. If we don't depends on changing the
number of queues frequently, we're ok.
>
> I'm guessing the only thing we need for correctness
> is ACCESS_ONCE on numvtaps?

Did't see how it help.
>
>>>> +
>>>> +		vlan->numvtaps--;
>>>> +		vlan->numdisabled++;
>>>> +	}
>>>> +
>>>> +out:
>>>> +	spin_unlock(&macvtap_lock);
>>>> +	return err;
>>>> +}
>>>>  /*
>>>>   * The file owning the queue got closed, give up both
>>>>   * the reference that the files holds as well as the
>>>> @@ -121,25 +215,38 @@ out:
>>>>   */
>>>>  static void macvtap_put_queue(struct macvtap_queue *q)
>>>>  {
>>>> -	struct macvtap_queue *nq;
>>>>  	struct macvlan_dev *vlan;
>>>>  
>>>>  	spin_lock(&macvtap_lock);
>>>>  	vlan = rcu_dereference_protected(q->vlan,
>>>>  					 lockdep_is_held(&macvtap_lock));
>>>> +
>>>>  	if (vlan) {
>>>> +		int total = vlan->numvtaps + vlan->numdisabled;
>>>>  		int index = q->queue_index;
>>>> -		BUG_ON(index >= vlan->numvtaps);
>>>> +		bool disabled = q->queue_index >= vlan->numvtaps;
>>>> +
>>>> +		BUG_ON(q->queue_index >= total);
>>>> +		macvtap_swap_slot(vlan, index, total - 1);
>>>> +		if (!disabled && vlan->numdisabled)
>>>> +			/* If there's disabled taps, the above swap will cause
>>>> +			 * a disabled tap to be moved to enabled area. So
>>>> +			 * another swap is needed to keep the right order.
>>>> +			 */
>>>> +			macvtap_swap_slot(vlan, index, vlan->numvtaps - 1);
>>>> +
>>>> +		RCU_INIT_POINTER(vlan->taps[total - 1], NULL);
>>>> +		RCU_INIT_POINTER(q->vlan, NULL);
>>>> +		sock_put(&q->sk);
>>>>  
>>>> -		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
>>>> -					       lockdep_is_held(&macvtap_lock));
>>>> -		rcu_assign_pointer(vlan->taps[index], nq);
>>>> -		nq->queue_index = index;
>>>> +		/* Make sure the pointers were seen before indices */
>>> Here it's one pointer, right?
>> Right.
>>>> +		wmb();
>>> Same issue as above, looks even more worrying
>>> as queue is freed here.
>> The read side were protected by rcu_read_lock(), so no worries here.
> Okay so basically numvtaps is just a hint,
> it can be wrong and nothing too bad happens?
>
> OK, but let's document this.

Sure.
>
>>>>  
>>>> -		RCU_INIT_POINTER(q->vlan, NULL);
>>>> +		if (disabled)
>>>> +			vlan->numdisabled--;
>>>> +		else
>>>> +			vlan->numvtaps--;
>>>>  
>>>> -		sock_put(&q->sk);
>>>> -		--vlan->numvtaps;
>>>>  	}
>>>>  
>>>>  	spin_unlock(&macvtap_lock);
>>>> @@ -166,6 +273,9 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
>>>>  	if (!numvtaps)
>>>>  		goto out;
>>>>  
>>>> +	/* Check taps after numvtaps were exposed. */
>>>> +	rmb();
>>>> +
>>> Except this doesn't seem to handle case where taps are going away ...
>> We're protected by rcu read lock here so even though it choose the queue
>> which is going to be destroyed temporarily, the socket won't be freed
>> before the packets were queued in the socket.
>>>>  	/* Check if we can use flow to select a queue */
>>>>  	rxq = skb_get_rxhash(skb);
>>>>  	if (rxq) {
>>>> @@ -201,7 +311,7 @@ static void macvtap_del_queues(struct net_device *dev)
>>>>  
>>>>  	/* macvtap_put_queue can free some slots, so go through all slots */
>>>>  	spin_lock(&macvtap_lock);
>>>> -	for (i = 0; i < vlan->numvtaps; i++) {
>>>> +	for (i = 0; i < vlan->numvtaps + vlan->numdisabled; i++) {
>>>>  		q = rcu_dereference_protected(vlan->taps[i],
>>>>  					      lockdep_is_held(&macvtap_lock));
>>>>  		BUG_ON(q == NULL);
>>>> @@ -211,6 +321,7 @@ static void macvtap_del_queues(struct net_device *dev)
>>>>  	}
>>>>  	/* guarantee that any future macvtap_set_queue will fail */
>>>>  	vlan->numvtaps = MAX_MACVTAP_QUEUES;
>>>> +	vlan->numdisabled = 0;
>>>>  	spin_unlock(&macvtap_lock);
>>>>  
>>>>  	synchronize_rcu();
>>>> @@ -927,6 +1038,27 @@ static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
>>>>  	return 0;
>>>>  }
>>>>  
>>>> +static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
>>>> +{
>>>> +	struct macvtap_queue *q = file->private_data;
>>>> +	struct macvlan_dev *vlan;
>>>> +	int ret = -EINVAL;
>>>> +
>>>> +	vlan = macvtap_get_vlan(q);
>>>> +	if (!vlan)
>>>> +		goto done;
>>>> +
>>>> +	if (flags & IFF_ATTACH_QUEUE)
>>>> +		ret = macvtap_enable_queue(vlan->dev, file, q);
>>>> +	else if (flags & IFF_DETACH_QUEUE)
>>>> +		ret = macvtap_disable_queue(q);
>>>> +
>>>> +	macvtap_put_vlan(vlan);
>>>> +
>>>> +done:
>>>> +	return ret;
>>>> +}
>>>> +
>>>>  /*
>>>>   * provide compatibility with generic tun/tap interface
>>>>   */
>>>> @@ -959,6 +1091,11 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>>>  		macvtap_put_vlan(vlan);
>>>>  		return ret;
>>>>  
>>>> +	case TUNSETQUEUE:
>>>> +		if (get_user(u, &ifr->ifr_flags))
>>>> +			return -EFAULT;
>>>> +		return macvtap_ioctl_set_queue(file, u);
>>>> +
>>>>  	case TUNGETFEATURES:
>>>>  		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
>>>>  			return -EFAULT;
>>>> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
>>>> index 62d8bda..d528f38 100644
>>>> --- a/include/linux/if_macvlan.h
>>>> +++ b/include/linux/if_macvlan.h
>>>> @@ -69,8 +69,15 @@ struct macvlan_dev {
>>>>  	u16			flags;
>>>>  	int (*receive)(struct sk_buff *skb);
>>>>  	int (*forward)(struct net_device *dev, struct sk_buff *skb);
>>>> +	/* This array tracks all taps (include disabled ones) and will be
>>>> +	 * reshuffled to keep the following order:
>>>> +	 * [0, numvtaps) : enabled taps,
>>>> +	 * [numvtaps, numvtaps + numdisabled) : disabled taps,
>>>> +	 * [numvtaps + numdisabled, MAX_MACVTAP_QUEUES) : unused slots
>>>> +	 */
>>>>  	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
>>>>  	int			numvtaps;
>>>> +	int			numdisabled;
>>>>  	int			minor;
>>>>  };
>>>>  
>>>> -- 
>>>> 1.7.1
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
