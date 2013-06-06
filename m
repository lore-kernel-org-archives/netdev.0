From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc V3 8/9] macvtap: add TUNSETQUEUE ioctl
Date: Thu, 06 Jun 2013 11:16:51 +0800
Message-ID: <51AFFF23.20608@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com> <1370414192-5830-9-git-send-email-jasowang@redhat.com> <20130605105928.GH31830@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605105928.GH31830@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2013 06:59 PM, Michael S. Tsirkin wrote:
> On Wed, Jun 05, 2013 at 02:36:31PM +0800, Jason Wang wrote:
>> This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
>> enable a queue of macvtap. This is used to be compatible at API layer of tuntap
>> to simplify the userspace to manage the queues. This is done through introducing
>> a linked list to track all taps while using vlan->taps array to only track
>> active taps.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/macvtap.c      |  133 +++++++++++++++++++++++++++++++++++++++-----
>>  include/linux/if_macvlan.h |    4 +
>>  2 files changed, 122 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 14764cc..355e6ad 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -45,6 +45,8 @@ struct macvtap_queue {
>>  	struct file *file;
>>  	unsigned int flags;
>>  	u16 queue_index;
>> +	bool enabled;
>> +	struct list_head next;
>>  };
>>  
>>  static struct proto macvtap_proto = {
>> @@ -85,14 +87,37 @@ static const struct proto_ops macvtap_socket_ops;
>>   */
>>  static DEFINE_SPINLOCK(macvtap_lock);
>>  
>> -static int macvtap_set_queue(struct net_device *dev, struct file *file,
>> +static int macvtap_enable_queue(struct net_device *dev, struct file *file,
>>  				struct macvtap_queue *q)
>>  {
>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>> +	int err = -EINVAL;
>> +
>> +	spin_lock(&macvtap_lock);
>> +
>> +	if (q->enabled)
>> +		goto out;
>> +
>> +	err = 0;
>> +	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
>> +	q->queue_index = vlan->numvtaps;
>> +	q->enabled = true;
>> +
>> +	vlan->numvtaps++;
>> +	vlan->numdisabled--;
>> +out:
>> +	spin_unlock(&macvtap_lock);
>> +	return err;
>> +}
>> +
>> +static int macvtap_set_queue(struct net_device *dev, struct file *file,
>> +			     struct macvtap_queue *q)
>> +{
>> +	struct macvlan_dev *vlan = netdev_priv(dev);
>>  	int err = -EBUSY;
>>  
>>  	spin_lock(&macvtap_lock);
>> -	if (vlan->numvtaps == MAX_MACVTAP_QUEUES)
>> +	if (vlan->numvtaps + vlan->numdisabled == MAX_MACVTAP_QUEUES)
>>  		goto out;
>>  
>>  	err = 0;
>> @@ -102,7 +127,9 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
>>  
>>  	q->file = file;
>>  	q->queue_index = vlan->numvtaps;
>> +	q->enabled = true;
>>  	file->private_data = q;
>> +	list_add_tail(&q->next, &vlan->tap_link);
>>  
>>  	vlan->numvtaps++;
>>  
>> @@ -111,6 +138,38 @@ out:
>>  	return err;
>>  }
>>  
>> +static int macvtap_disable_queue(struct macvtap_queue *q)
>> +{
>> +	struct macvlan_dev *vlan;
>> +	struct macvtap_queue *nq;
>> +	int err = 0;
>> +
>> +	spin_lock(&macvtap_lock);
>> +	vlan = rcu_dereference_protected(q->vlan,
>> +					 lockdep_is_held(&macvtap_lock));
>> +
>> +	if (!q->enabled) {
>> +		err = -EINVAL;
>> +		goto out;
>> +	}
>> +
>> +	if (vlan) {
>> +		int index = q->queue_index;
>> +		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
>> +					       lockdep_is_held(&macvtap_lock));
>> +		nq->queue_index = index;
>> +
>> +		rcu_assign_pointer(vlan->taps[index], nq);
>> +		RCU_INIT_POINTER(vlan->taps[vlan->numvtaps - 1], NULL);
>> +		q->enabled = false;
>> +
>> +		vlan->numvtaps--;
>> +		vlan->numdisabled++;
>> +	}
>> +out:
>> +	spin_unlock(&macvtap_lock);
>> +	return err;
>> +}
>>  /*
>>   * The file owning the queue got closed, give up both
>>   * the reference that the files holds as well as the
>> @@ -128,18 +187,24 @@ static void macvtap_put_queue(struct macvtap_queue *q)
>>  	vlan = rcu_dereference_protected(q->vlan,
>>  					 lockdep_is_held(&macvtap_lock));
>>  	if (vlan) {
>> +		int numvtaps = vlan->numvtaps;
>>  		int index = q->queue_index;
>> -		BUG_ON(index >= vlan->numvtaps);
>>  
>> -		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
>> -					       lockdep_is_held(&macvtap_lock));
>> -		rcu_assign_pointer(vlan->taps[index], nq);
>> -		nq->queue_index = index;
>> +		if (q->enabled) {
>> +			BUG_ON(index >= vlan->numvtaps);
>> +			nq = rcu_dereference_protected(vlan->taps[numvtaps - 1],
>> +						lockdep_is_held(&macvtap_lock));
>> +			rcu_assign_pointer(vlan->taps[index], nq);
> Do we really need these tricks?
> Can't we call macvtap_disable_queue and then only handle disable queues
> here?

We could, will do it.
>
>> +			nq->queue_index = index;
>> +
>> +			RCU_INIT_POINTER(vlan->taps[numvtaps - 1], NULL);
>> +			vlan->numvtaps--;
>> +		} else
>> +			vlan->numdisabled--;
>>  
>> -		RCU_INIT_POINTER(vlan->taps[vlan->numvtaps - 1], NULL);
>>  		RCU_INIT_POINTER(q->vlan, NULL);
>>  		sock_put(&q->sk);
>> -		--vlan->numvtaps;
>> +		list_del_init(&q->next);
>>  	}
>>  
>>  	spin_unlock(&macvtap_lock);
>> @@ -160,6 +225,10 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
>>  {
>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>>  	struct macvtap_queue *tap = NULL;
>> +	/* numvtaps here is just a hint, even if the number of active taps were
>> +	 * reduced in the same sime,
> typo

Will correct it.
>
>> since we are protected by rcu read lock,
>> +	 * we're safe here.
> I don't really understand what is this comment trying to say.
> What is protected? What is safe? safe time as what?

Will make it clear as:

"numvtaps is just a hint, even if the number of active taps were reduced
in the same tap, since the tap pointers were protected by rcu read lock,
they are safe even if some of them were being removed"

>
>> +	 */
>>  	int numvtaps = ACCESS_ONCE(vlan->numvtaps);
>>  	__u32 rxq;
>>  
>> @@ -196,20 +265,25 @@ out:
>>  static void macvtap_del_queues(struct net_device *dev)
>>  {
>>  	struct macvlan_dev *vlan = netdev_priv(dev);
>> -	struct macvtap_queue *q, *qlist[MAX_MACVTAP_QUEUES];
>> +	struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];
>>  	int i, j = 0;
>>  
>>  	spin_lock(&macvtap_lock);
>> -	for (i = 0; i < vlan->numvtaps; i++) {
>> -		q = rcu_dereference_protected(vlan->taps[i],
>> -					      lockdep_is_held(&macvtap_lock));
>> -		BUG_ON(q == NULL);
>> +	list_for_each_entry_safe(q, tmp, &vlan->tap_link, next) {
>> +		list_del_init(&q->next);
>>  		qlist[j++] = q;
>> -		RCU_INIT_POINTER(vlan->taps[i], NULL);
>>  		RCU_INIT_POINTER(q->vlan, NULL);
>> +		if (q->enabled)
>> +			vlan->numvtaps--;
>> +		else
>> +			vlan->numdisabled--;
>>  	}
>> +	for (i = 0; i < vlan->numvtaps; i++)
>> +		RCU_INIT_POINTER(vlan->taps[i], NULL);
>> +	BUG_ON(vlan->numvtaps + vlan->numdisabled != 0);
> Better two BUG_ON checks - they are both 0 right?
> And no need for != 0.

Sure.
>
>>  	/* guarantee that any future macvtap_set_queue will fail */
>>  	vlan->numvtaps = MAX_MACVTAP_QUEUES;
>> +	vlan->numdisabled = 0;
> What's this doing? We know it's 0 ...

Yes, will remove it.
>>  	spin_unlock(&macvtap_lock);
>>  
>>  	synchronize_rcu();
>> @@ -298,6 +372,9 @@ static int macvtap_newlink(struct net *src_net,
>>  			   struct nlattr *tb[],
>>  			   struct nlattr *data[])
>>  {
>> +	struct macvlan_dev *vlan = netdev_priv(dev);
>> +	INIT_LIST_HEAD(&vlan->tap_link);
>> +
>>  	/* Don't put anything that may fail after macvlan_common_newlink
>>  	 * because we can't undo what it does.
>>  	 */
>> @@ -926,6 +1003,27 @@ static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
>>  	return 0;
>>  }
>>  
>> +static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
>> +{
>> +	struct macvtap_queue *q = file->private_data;
>> +	struct macvlan_dev *vlan;
>> +	int ret = -EINVAL;
>> +
>> +	vlan = macvtap_get_vlan(q);
>> +	if (!vlan)
>> +		goto done;
> Can be just return -EINVAL, and you won't need to initialize
> above.

Ok.
>
>> +
>> +	if (flags & IFF_ATTACH_QUEUE)
>> +		ret = macvtap_enable_queue(vlan->dev, file, q);
>> +	else if (flags & IFF_DETACH_QUEUE)
>> +		ret = macvtap_disable_queue(q);
>> +
>> +	macvtap_put_vlan(vlan);
>> +
>> +done:
>> +	return ret;
>> +}
>> +
>>  /*
>>   * provide compatibility with generic tun/tap interface
>>   */
>> @@ -958,6 +1056,11 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>  		macvtap_put_vlan(vlan);
>>  		return ret;
>>  
>> +	case TUNSETQUEUE:
>> +		if (get_user(u, &ifr->ifr_flags))
>> +			return -EFAULT;
>> +		return macvtap_ioctl_set_queue(file, u);
>> +
>>  	case TUNGETFEATURES:
>>  		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
>>  			return -EFAULT;
>> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
>> index 62d8bda..87b9091 100644
>> --- a/include/linux/if_macvlan.h
>> +++ b/include/linux/if_macvlan.h
>> @@ -69,8 +69,12 @@ struct macvlan_dev {
>>  	u16			flags;
>>  	int (*receive)(struct sk_buff *skb);
>>  	int (*forward)(struct net_device *dev, struct sk_buff *skb);
>> +	/* This array tracks active taps. */
>>  	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
>> +	/* This list tracks all taps (both enabled and disabled) */
>> +	struct list_head	tap_link;
> Bad name, e.g. queue_list would be better.

Ok.
>>  	int			numvtaps;
>> +	int			numdisabled;
> So numvtaps is number of entries in the taps array.
> But to get items on list, you must add numdisabled and
> numvtaps, that's confusing.
> Instead of numdisabled, let's add a counter for
> number of entries in the tap_link list.
>
> How about numqueues?

This sounds better.
>>  	int			minor;
>>  };
>>  
>> -- 
>> 1.7.1
