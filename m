From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V5 3/3] tuntap: allow polling/writing/reading when detached
Date: Wed, 16 Jan 2013 21:35:17 +0800
Message-ID: <50F6AC95.3080509@redhat.com>
References: <1358332441-26859-1-git-send-email-jasowang@redhat.com> <1358332441-26859-4-git-send-email-jasowang@redhat.com> <20130116105911.GA13470@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116105911.GA13470@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2013 06:59 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 16, 2013 at 06:34:01PM +0800, Jason Wang wrote:
>> We forbid polling, writing and reading when the file were detached, this may
>> complex the user in several cases:
>>
>> - when guest pass some buffers to vhost/qemu and then disable some queues,
>>   host/qemu needs to do its own cleanup on those buffers which is complex
>>   sometimes. We can do this simply by allowing a user can still write to an
>>   disabled queue. Write to an disabled queue will cause the packet pass to the
>>   kernel and read will get nothing.
>> - align the polling behavior with macvtap which never fails when the queue is
>>   created. This can simplify the polling errors handling of its user (e.g vhost)
>>
>> In order to achieve this, tfile->tun were not assign to NULL when detached. And
>> tfile->tun were converted to be RCU protected in order to let the data path can
>> check whether the file is deated in a lockless manner. This will be used to
>> prevent the flow caches from being updated for a detached queue.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>
> NAK
>
>> ---
>>  drivers/net/tun.c |   43 +++++++++++++++++++++++++------------------
>>  1 files changed, 25 insertions(+), 18 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index c81680d..3f011e0 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -139,7 +139,7 @@ struct tun_file {
>>  	unsigned int flags;
>>  	u16 queue_index;
>>  	struct list_head next;
>> -	struct tun_struct *detached;
>> +	struct tun_struct __rcu *detached;
>>  };
>>  
>>  struct tun_flow_entry {
>> @@ -295,11 +295,12 @@ static void tun_flow_cleanup(unsigned long data)
>>  }
>>  
>>  static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
>> -			    u16 queue_index)
>> +			    struct tun_file *tfile)
>>  {
>>  	struct hlist_head *head;
>>  	struct tun_flow_entry *e;
>>  	unsigned long delay = tun->ageing_time;
>> +	u16 queue_index = tfile->queue_index;
>>  
>>  	if (!rxhash)
>>  		return;
>> @@ -308,7 +309,7 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
>>  
>>  	rcu_read_lock();
>>  
>> -	if (tun->numqueues == 1)
>> +	if (tun->numqueues == 1 || !rtnl_dereference(tfile->detached))
>>  		goto unlock;
>>  
>>  	e = tun_flow_find(head, rxhash);
> Did you try to run this with lockdep enabled?
> tun_flow_update is called from tun_get_user without rtnl so
> rtnl_dereference is arguably wrong, and will cause a lockdep warning.

Yes, will correct this and test with lockdep enabled.

Thanks
>
>> @@ -384,16 +385,16 @@ static void tun_set_real_num_queues(struct tun_struct *tun)
>>  
>>  static void tun_disable_queue(struct tun_struct *tun, struct tun_file *tfile)
>>  {
>> -	tfile->detached = tun;
>> +	rcu_assign_pointer(tfile->detached, tun);
>>  	list_add_tail(&tfile->next, &tun->disabled);
>>  	++tun->numdisabled;
>>  }
>>  
>>  static struct tun_struct *tun_enable_queue(struct tun_file *tfile)
>>  {
>> -	struct tun_struct *tun = tfile->detached;
>> +	struct tun_struct *tun = rtnl_dereference(tfile->detached);
>>  
>> -	tfile->detached = NULL;
>> +	rcu_assign_pointer(tfile->detached, NULL);
>>  	list_del_init(&tfile->next);
>>  	--tun->numdisabled;
>>  	return tun;
>> @@ -402,26 +403,27 @@ static struct tun_struct *tun_enable_queue(struct tun_file *tfile)
>>  static void __tun_detach(struct tun_file *tfile, bool clean)
>>  {
>>  	struct tun_file *ntfile;
>> -	struct tun_struct *tun;
>> +	struct tun_struct *tun, *detached;
>>  	struct net_device *dev;
>>  
>>  	tun = rtnl_dereference(tfile->tun);
>> +	detached = rtnl_dereference(tfile->detached);
>>  
>> -	if (tun) {
>> +	if (tun && !detached) {
>>  		u16 index = tfile->queue_index;
>>  		BUG_ON(index >= tun->numqueues);
>>  		dev = tun->dev;
>>  
>>  		rcu_assign_pointer(tun->tfiles[index],
>>  				   tun->tfiles[tun->numqueues - 1]);
>> -		rcu_assign_pointer(tfile->tun, NULL);
>>  		ntfile = rtnl_dereference(tun->tfiles[index]);
>>  		ntfile->queue_index = index;
>>  
>>  		--tun->numqueues;
>> -		if (clean)
>> +		if (clean) {
>> +			rcu_assign_pointer(tfile->tun, NULL);
>>  			sock_put(&tfile->sk);
>> -		else
>> +		} else
>>  			tun_disable_queue(tun, tfile);
>>  
>>  		synchronize_net();
>> @@ -429,7 +431,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>>  		/* Drop read queue */
>>  		skb_queue_purge(&tfile->sk.sk_receive_queue);
>>  		tun_set_real_num_queues(tun);
>> -	} else if (tfile->detached && clean) {
>> +	} else if (detached && clean) {
>>  		tun = tun_enable_queue(tfile);
>>  		sock_put(&tfile->sk);
>>  	}
>> @@ -466,6 +468,10 @@ static void tun_detach_all(struct net_device *dev)
>>  		rcu_assign_pointer(tfile->tun, NULL);
>>  		--tun->numqueues;
>>  	}
>> +	list_for_each_entry(tfile, &tun->disabled, next) {
>> +		wake_up_all(&tfile->wq.wait);
>> +		rcu_assign_pointer(tfile->tun, NULL);
>> +	}
>>  	BUG_ON(tun->numqueues != 0);
>>  
>>  	synchronize_net();
>> @@ -496,7 +502,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>>  		goto out;
>>  
>>  	err = -EINVAL;
>> -	if (rtnl_dereference(tfile->tun))
>> +	if (rtnl_dereference(tfile->tun) && !rtnl_dereference(tfile->detached))
>>  		goto out;
>>  
>>  	err = -EBUSY;
>> @@ -504,7 +510,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>>  		goto out;
>>  
>>  	err = -E2BIG;
>> -	if (!tfile->detached &&
>> +	if (!rtnl_dereference(tfile->detached) &&
>>  	    tun->numqueues + tun->numdisabled == MAX_TAP_QUEUES)
>>  		goto out;
>>  
>> @@ -521,7 +527,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>>  	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
>>  	tun->numqueues++;
>>  
>> -	if (tfile->detached)
>> +	if (rtnl_dereference(tfile->detached))
>>  		tun_enable_queue(tfile);
>>  	else
>>  		sock_hold(&tfile->sk);
>> @@ -1195,7 +1201,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>>  	tun->dev->stats.rx_packets++;
>>  	tun->dev->stats.rx_bytes += len;
>>  
>> -	tun_flow_update(tun, rxhash, tfile->queue_index);
>> +	tun_flow_update(tun, rxhash, tfile);
>>  	return total_len;
>>  }
>>  
>> @@ -1796,7 +1802,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>>  	rtnl_lock();
>>  
>>  	if (ifr->ifr_flags & IFF_ATTACH_QUEUE) {
>> -		tun = tfile->detached;
>> +		tun = rtnl_dereference(tfile->detached);
>>  		if (!tun) {
>>  			ret = -EINVAL;
>>  			goto unlock;
>> @@ -1807,7 +1813,8 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>>  		ret = tun_attach(tun, file);
>>  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
>>  		tun = rtnl_dereference(tfile->tun);
>> -		if (!tun || !(tun->flags & TUN_TAP_MQ))
>> +		if (!tun || !(tun->flags & TUN_TAP_MQ) ||
>> +		    rtnl_dereference(tfile->detached))
>>  			ret = -EINVAL;
>>  		else
>>  			__tun_detach(tfile, false);
>> -- 
>> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
