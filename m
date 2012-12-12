From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next rfc 2/2] tuntap: allow unpriveledge user to enable
 and disable queues
Date: Wed, 12 Dec 2012 11:34:38 +0800
Message-ID: <50C7FB4E.8040500@redhat.com>
References: <1355223827-57290-1-git-send-email-jasowang@redhat.com> <1355223827-57290-3-git-send-email-jasowang@redhat.com> <20121211123012.GB15435@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mprivozn@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121211123012.GB15435@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2012 08:30 PM, Michael S. Tsirkin wrote:
> On Tue, Dec 11, 2012 at 07:03:47PM +0800, Jason Wang wrote:
>> Currently, when a file is attached to tuntap through TUNSETQUEUE, the uid/gid
>> and CAP_NET_ADMIN were checked, and we use this ioctl to create and destroy
>> queues. Sometimes, userspace such as qemu need to the ability to enable and
>> disable a specific queue without priveledge since guest operating system may
>> change the number of queues it want use.
>>
>> To support this kind of ability, this patch introduce a flag enabled which is
>> used to track whether the queue is enabled by userspace. And also restrict that
>> only one deivce could be used for a queue to attach. With this patch, the DAC
>> checking when adding queues through IFF_ATTACH_QUEUE is still done and after
>> this, IFF_DETACH_QUEUE/IFF_ATTACH_QUEUE  could be used to disable/enable this
>> queue.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/tun.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++-----
>>  1 files changed, 73 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index d593f56..43831a7 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -138,6 +138,7 @@ struct tun_file {
>>  	/* only used for fasnyc */
>>  	unsigned int flags;
>>  	u16 queue_index;
>> +	bool enabled;
>>  };
>>  
>>  struct tun_flow_entry {
>> @@ -345,9 +346,11 @@ unlock:
>>  static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>>  {
>>  	struct tun_struct *tun = netdev_priv(dev);
>> +	struct tun_file *tfile;
>>  	struct tun_flow_entry *e;
>>  	u32 txq = 0;
>>  	u32 numqueues = 0;
>> +	int i;
>>  
>>  	rcu_read_lock();
>>  	numqueues = tun->numqueues;
>> @@ -366,6 +369,19 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>>  			txq -= numqueues;
>>  	}
>>  
>> +	tfile = rcu_dereference(tun->tfiles[txq]);
>> +	if (unlikely(!tfile->enabled))
> This unlikely tag is suspicious. It should be perfectly
> legal to use less queues than created.

Ok. will remove this check.
>
>> +		/* tun_detach() should make sure there's at least one queue
>> +		 * could be used to do the tranmission.
>> +		 */
>> +		for (i = 0; i < numqueues; i++) {
>> +			tfile = rcu_dereference(tun->tfiles[i]);
>> +			if (tfile->enabled) {
>> +				txq = i;
>> +				break;
>> +			}
>> +		}
>> +
> Worst case this will do a linear scan over all queueus on each packet.
> Instead, I think we need a list of all queues and only install
> the active ones in the array.

Another method is using another variable e.g. active_queues to track how
many queues were enabled. And re-shuffle the pointers during
detaching/attaching to make sure [0, active_queues) to be enabled
queues, and [active_queues, num_queues) to be disabled queues. Then we
could avoid this issue.
>
>>  	rcu_read_unlock();
>>  	return txq;
>>  }
>> @@ -386,6 +402,36 @@ static void tun_set_real_num_queues(struct tun_struct *tun)
>>  	netif_set_real_num_rx_queues(tun->dev, tun->numqueues);
>>  }
>>  
>> +static int tun_enable(struct tun_file *tfile)
>> +{
>> +	if (tfile->enabled == true)
> simply if (tfile->enabled)

Right.
>> +		return -EINVAL;
> Actually it's better to have operations be
> idempotent. If it's enabled, enabling should
> be a NOP not an error.

Ok.
>> +
>> +	tfile->enabled = true;
>> +	return 0;
>> +}
>> +
>> +static int tun_disable(struct tun_file *tfile)
>> +{
>> +	struct tun_struct *tun = rcu_dereference_protected(tfile->tun,
>> +							   lockdep_rtnl_is_held());
>> +	u16 index = tfile->queue_index;
>> +
>> +	if (!tun)
>> +		return -EINVAL;
>> +
>> +	if (tun->numqueues == 1)
>> +		return -EINVAL;
> So if there's a single queue we can't disable it,
> but if there are > 1 we can disable them all.
> This seems arbitrary.
>

The question is whether we can allow the userspace to disable all queues
which looks useless to me. So I try to forbid this.
>> +
>> +	BUG_ON(index >= tun->numqueues);
>> +	tfile->enabled = false;
>> +
>> +	synchronize_net();
>> +	tun_flow_delete_by_queue(tun, index);
>> +
>> +	return 0;
>> +}
>> +
>>  static void __tun_detach(struct tun_file *tfile, bool clean)
>>  {
>>  	struct tun_file *ntfile;
>> @@ -446,6 +492,7 @@ static void tun_detach_all(struct net_device *dev)
>>  		BUG_ON(!tfile);
>>  		wake_up_all(&tfile->wq.wait);
>>  		rcu_assign_pointer(tfile->tun, NULL);
>> +		tfile->enabled = false;
>>  		--tun->numqueues;
>>  	}
>>  	BUG_ON(tun->numqueues != 0);
>> @@ -490,6 +537,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>>  	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
>>  	sock_hold(&tfile->sk);
>>  	tun->numqueues++;
>> +	tfile->enabled = true;
>>  
>>  	tun_set_real_num_queues(tun);
>>  
>> @@ -672,6 +720,10 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	if (txq >= tun->numqueues)
>>  		goto drop;
>>  
>> +	/* Drop packet if the queue was not enabled */
>> +	if (!tfile->enabled)
>> +		goto drop;
>> +
>>  	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
>>  
>>  	BUG_ON(!tfile);
>> @@ -1010,6 +1062,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>>  	bool zerocopy = false;
>>  	int err;
>>  
>> +	if (!tfile->enabled)
>> +		return -EINVAL;
>> +
>>  	if (!(tun->flags & TUN_NO_PI)) {
>>  		if ((len -= sizeof(pi)) > total_len)
>>  			return -EINVAL;
>> @@ -1199,6 +1254,9 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>>  	struct tun_pi pi = { 0, skb->protocol };
>>  	ssize_t total = 0;
>>  
>> +	if (!tfile->enabled)
>> +		return -EINVAL;
>> +
>>  	if (!(tun->flags & TUN_NO_PI)) {
>>  		if ((len -= sizeof(pi)) < 0)
>>  			return -EINVAL;
>> @@ -1769,15 +1827,21 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>>  		if (dev->netdev_ops != &tap_netdev_ops &&
>>  			dev->netdev_ops != &tun_netdev_ops)
>>  			ret = -EINVAL;
>> -		else if (tun_not_capable(tun))
>> -			ret = -EPERM;
>> -		/* TUNSETIFF is needed to do permission checking */
>> -		else if (tun->numqueues == 0)
>> -			ret = -EPERM;
>> -		else
>> -			ret = tun_attach(tun, file);
>> +		else {
>> +			if (!rcu_dereference(tfile->tun)) {
> Should be rcu_dereference_protected.

True.
>
>> +				if (tun_not_capable(tun) ||
>> +				    tun->numqueues == 0)
>> +					ret = -EPERM;
>> +				else
>> +					ret = tun_attach(tun, file);
>> +			}
>> +			else {
>> +				/* FIXME: permission check? */
>> +				ret = tun_enable(tfile);
>> +			}
>> +		}
>>  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE)
>> -		__tun_detach(tfile, false);
>> +		tun_disable(tfile);
>>  	else
>>  		ret = -EINVAL;
>>  
>> @@ -2085,6 +2149,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>>  	tfile->socket.file = file;
>>  	tfile->socket.ops = &tun_socket_ops;
>>  
>> +	tfile->enabled = false;
>>  	sock_init_data(&tfile->socket, &tfile->sk);
>>  	sk_change_net(&tfile->sk, tfile->net);
>>  
>> -- 
>> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
