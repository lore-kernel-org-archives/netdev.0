From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC 7/8] macvtap: add TUNSETQUEUE ioctl
Date: Thu, 23 May 2013 14:52:06 +0300
Message-ID: <20130523115206.GD17993@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
 <1369278753-2533-8-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369278753-2533-8-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 11:12:32AM +0800, Jason Wang wrote:
> This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
> enable a queue of macvtap. This is used to be compatible at API layer of tuntap
> to simplify the userspace to manage the queues.
> 
> This is done by just introduce a pointer detached which was set when the queue
> were detached. Only the queue with NULL set to this pointer can be used to
> forward packets.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Isn't this a bit too tricky?
Why keep disabled queues on the array at all?
Let's add a linked list of all queues for accounting.
Use array for enabled queues only, for data path.

> ---
>  drivers/net/macvtap.c      |  147 +++++++++++++++++++++++++++++++++++--------
>  include/linux/if_macvlan.h |    7 ++
>  2 files changed, 126 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index e3f9344..06b10a5 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -85,67 +85,131 @@ static const struct proto_ops macvtap_socket_ops;
>   */
>  static DEFINE_SPINLOCK(macvtap_lock);
>  
> +static void macvtap_swap_slot(struct macvlan_dev *vlan, int a, int b)
> +{
> +	struct macvtap_queue *q1, *q2;
> +
> +	if (a == b)
> +		return;
> +
> +	q1 = rcu_dereference_protected(vlan->taps[a],
> +				       lockdep_is_held(&macvtap_lock));
> +	q2 = rcu_dereference_protected(vlan->taps[b],
> +				       lockdep_is_held(&macvtap_lock));
> +
> +	BUG_ON(q1 == NULL || q2 == NULL);
> +
> +	rcu_assign_pointer(vlan->taps[a], vlan->taps[b]);
> +	rcu_assign_pointer(vlan->taps[b], q1);
> +
> +	q1->queue_index = b;
> +	q2->queue_index = a;
> +}
> +
>  static int macvtap_set_queue(struct net_device *dev, struct file *file,
> -				struct macvtap_queue *q)
> +			     struct macvtap_queue *q, bool enable)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	int err = -EBUSY;
> +	int total;
>  
>  	spin_lock(&macvtap_lock);
> -	if (vlan->numvtaps == MAX_MACVTAP_QUEUES)
> +
> +	total = vlan->numvtaps + vlan->numdisabled;
> +	if (!enable && total == MAX_MACVTAP_QUEUES)
> +		goto out;
> +
> +	err = -EINVAL;
> +	if (enable && q->queue_index < vlan->numvtaps)
>  		goto out;
>  
>  	err = 0;
> -	rcu_assign_pointer(q->vlan, vlan);
> -	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
> -	sock_hold(&q->sk);
>  
> -	q->file = file;
> -	q->queue_index = vlan->numvtaps;
> -	file->private_data = q;
> +	if (enable) {
> +		BUG_ON(q->queue_index >= total);
> +		macvtap_swap_slot(vlan, q->queue_index, vlan->numvtaps);
> +		--vlan->numdisabled;
> +	} else {
> +		rcu_assign_pointer(q->vlan, vlan);
> +		rcu_assign_pointer(vlan->taps[total], q);
> +		sock_hold(&q->sk);
> +
> +		q->file = file;
> +		q->queue_index = total;
> +		file->private_data = q;
> +		if (vlan->numdisabled)
> +			macvtap_swap_slot(vlan, vlan->numvtaps, total);
> +
> +		/* Make sure the pointers were seen before numvtaps. */
> +		smp_wmb();
> +	}
>  
>  	vlan->numvtaps++;
> -
>  out:
>  	spin_unlock(&macvtap_lock);
>  	return err;
>  }
>  
>  /*
> - * The file owning the queue got closed, give up both
> - * the reference that the files holds as well as the
> - * one from the macvlan_dev if that still exists.
> + * The file owning the queue got closed or disabled.
> + *
> + * If closed give up both the reference that the files holds as well as the
> + * one from the macvlan_dev if that still exists. If disabled, reshuffle the
> + * array of taps.
>   *
>   * Using the spinlock makes sure that we don't get
>   * to the queue again after destroying it.
>   */
> -static void macvtap_put_queue(struct macvtap_queue *q)
> +static int macvtap_put_queue(struct macvtap_queue *q, bool clean)

s/clean/release/
and add a comment explaining what it is.

>  {
> -	struct macvtap_queue *nq;
>  	struct macvlan_dev *vlan;
> +	int err = -EINVAL;
>  
>  	spin_lock(&macvtap_lock);
>  	vlan = rcu_dereference_protected(q->vlan,
>  					 lockdep_is_held(&macvtap_lock));
> +
>  	if (vlan) {
> +		int total = vlan->numvtaps + vlan->numdisabled;
>  		int index = q->queue_index;
> -		BUG_ON(index >= vlan->numvtaps);
> +		bool disabled = q->queue_index >= vlan->numvtaps;
>  
> -		rcu_assign_pointer(vlan->taps[index],
> -				   vlan->taps[vlan->numvtaps - 1]);
> -		RCU_INIT_POINTER(q->vlan, NULL);
> -		nq = rcu_dereference_protected(vlan->taps[index],
> -					       lockdep_is_held(&macvtap_lock));
> -		nq->queue_index = index;
> +		if (!clean) {
> +			BUG_ON(q->queue_index >= total);
> +			if (q->queue_index >= vlan->numvtaps)
> +				goto out;
> +		}
>  
> -		sock_put(&q->sk);
> -		--vlan->numvtaps;
> -	}
> +		err = 0;
> +		macvtap_swap_slot(vlan, index, total - 1);
> +		if (!disabled && vlan->numdisabled)

What's the logic here?

> +			macvtap_swap_slot(vlan, index, vlan->numvtaps - 1);

So these swaps do a lot of RCU assign, presumably we need
synchronize_rcu as well?

> +
> +		if (clean) {
> +			RCU_INIT_POINTER(vlan->taps[total - 1], NULL);
> +			RCU_INIT_POINTER(q->vlan, NULL);
> +			sock_put(&q->sk);
> +			if (disabled)
> +				--vlan->numdisabled;
> +			else
> +				--vlan->numvtaps;
> +		} else {
> +			--vlan->numvtaps;
> +			++vlan->numdisabled;
> +		}
> +
> +	} else if (clean)
> +		err = 0;
>  
> +out:
>  	spin_unlock(&macvtap_lock);
>  
>  	synchronize_rcu();
> -	sock_put(&q->sk);
> +
> +	if (clean)
> +		sock_put(&q->sk);
> +
> +	return err;
>  }
>  
>  /*
> @@ -201,7 +265,7 @@ static void macvtap_del_queues(struct net_device *dev)
>  
>  	/* macvtap_put_queue can free some slots, so go through all slots */
>  	spin_lock(&macvtap_lock);
> -	for (i = 0; i < vlan->numvtaps; i++) {
> +	for (i = 0; i < vlan->numvtaps + vlan->numdisabled; i++) {
>  		q = rcu_dereference_protected(vlan->taps[i],
>  					      lockdep_is_held(&macvtap_lock));
>  		BUG_ON(q == NULL);
> @@ -211,6 +275,7 @@ static void macvtap_del_queues(struct net_device *dev)
>  	}
>  	/* guarantee that any future macvtap_set_queue will fail */
>  	vlan->numvtaps = MAX_MACVTAP_QUEUES;
> +	vlan->numdisabled = 0;
>  	spin_unlock(&macvtap_lock);
>  
>  	synchronize_rcu();
> @@ -384,7 +449,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
>  	if ((dev->features & NETIF_F_HIGHDMA) && (dev->features & NETIF_F_SG))
>  		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
>  
> -	err = macvtap_set_queue(dev, file, q);
> +	err = macvtap_set_queue(dev, file, q, false);
>  	if (err)
>  		sock_put(&q->sk);
>  
> @@ -398,7 +463,7 @@ out:
>  static int macvtap_release(struct inode *inode, struct file *file)
>  {
>  	struct macvtap_queue *q = file->private_data;
> -	macvtap_put_queue(q);
> +	macvtap_put_queue(q, true);
>  	return 0;
>  }
>  
> @@ -922,6 +987,27 @@ static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
>  	return 0;
>  }
>  
> +static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
> +{
> +	struct macvtap_queue *q = file->private_data;
> +	struct macvlan_dev *vlan;
> +	int ret = -EINVAL;
> +
> +	vlan = macvtap_get_vlan(q);
> +	if (!vlan)
> +		goto done;
> +
> +	if (flags & IFF_ATTACH_QUEUE)
> +		ret = macvtap_set_queue(vlan->dev, file, q, true);
> +	else if (flags & IFF_DETACH_QUEUE)
> +		ret = macvtap_put_queue(q, false);
> +
> +	macvtap_put_vlan(vlan);
> +
> +done:
> +	return ret;
> +}
> +
>  /*
>   * provide compatibility with generic tun/tap interface
>   */
> @@ -954,6 +1040,11 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		macvtap_put_vlan(vlan);
>  		return ret;
>  
> +	case TUNSETQUEUE:
> +		if (get_user(u, &ifr->ifr_flags))
> +			return -EFAULT;
> +		return macvtap_ioctl_set_queue(file, u);
> +
>  	case TUNGETFEATURES:
>  		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
>  			return -EFAULT;
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index 32e943a..f134afb 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -69,8 +69,15 @@ struct macvlan_dev {
>  	u16			flags;
>  	int (*receive)(struct sk_buff *skb);
>  	int (*forward)(struct net_device *dev, struct sk_buff *skb);
> +	/* This array tracks all taps (include disabled ones) and will be
> +	 * reshuffled to keep the following order:
> +	 * [0, numvtaps) : enabled taps,
> +	 * [numvtaps, numvtaps + numdisabled) : disabled taps,
> +	 * [numvtaps + numdisabled, MAX_MACVTAP_QUEUES) : unused slots
> +	 */
>  	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
>  	int			numvtaps;
> +	int			numdisabled;
>  	int			minor;
>  };
>  
> -- 
> 1.7.1
