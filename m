From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V7 3/3] tuntap: allow polling/writing/reading when
 detached
Date: Mon, 28 Jan 2013 19:31:44 +0200
Message-ID: <20130128173144.GB31009@redhat.com>
References: <1359371119-10208-1-git-send-email-jasowang@redhat.com>
 <1359371119-10208-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1359371119-10208-4-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 28, 2013 at 07:05:19PM +0800, Jason Wang wrote:
> We forbid polling, writing and reading when the file were detached, this may
> complex the user in several cases:
> 
> - when guest pass some buffers to vhost/qemu and then disable some queues,
>   host/qemu needs to do its own cleanup on those buffers which is complex
>   sometimes. We can do this simply by allowing a user can still write to an
>   disabled queue. Write to an disabled queue will cause the packet pass to the
>   kernel and read will get nothing.
> - align the polling behavior with macvtap which never fails when the queue is
>   created. This can simplify the polling errors handling of its user (e.g vhost)
> 
> We can simply achieve this by don't assign NULL to tfile->tun when detached.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/tun.c |   25 ++++++++++++++++---------
>  1 files changed, 16 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 30a7d0e..2fb19da 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -298,11 +298,12 @@ static void tun_flow_cleanup(unsigned long data)
>  }
>  
>  static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
> -			    u16 queue_index)
> +			    struct tun_file *tfile)
>  {
>  	struct hlist_head *head;
>  	struct tun_flow_entry *e;
>  	unsigned long delay = tun->ageing_time;
> +	u16 queue_index = tfile->queue_index;
>  
>  	if (!rxhash)
>  		return;
> @@ -311,7 +312,9 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
>  
>  	rcu_read_lock();
>  
> -	if (tun->numqueues == 1)
> +	/* We may get a very small possibility of OOO during switching, not
> +	 * worth to optimize.*/
> +	if (tun->numqueues == 1 || tfile->detached)
>  		goto unlock;
>  
>  	e = tun_flow_find(head, rxhash);
> @@ -411,21 +414,21 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>  
>  	tun = rtnl_dereference(tfile->tun);
>  
> -	if (tun) {
> +	if (tun && !tfile->detached) {
>  		u16 index = tfile->queue_index;
>  		BUG_ON(index >= tun->numqueues);
>  		dev = tun->dev;
>  
>  		rcu_assign_pointer(tun->tfiles[index],
>  				   tun->tfiles[tun->numqueues - 1]);
> -		rcu_assign_pointer(tfile->tun, NULL);
>  		ntfile = rtnl_dereference(tun->tfiles[index]);
>  		ntfile->queue_index = index;
>  
>  		--tun->numqueues;
> -		if (clean)
> +		if (clean) {
> +			rcu_assign_pointer(tfile->tun, NULL);
>  			sock_put(&tfile->sk);
> -		else
> +		} else
>  			tun_disable_queue(tun, tfile);
>  
>  		synchronize_net();
> @@ -473,6 +476,10 @@ static void tun_detach_all(struct net_device *dev)
>  		rcu_assign_pointer(tfile->tun, NULL);
>  		--tun->numqueues;
>  	}
> +	list_for_each_entry(tfile, &tun->disabled, next) {
> +		wake_up_all(&tfile->wq.wait);
> +		rcu_assign_pointer(tfile->tun, NULL);
> +	}
>  	BUG_ON(tun->numqueues != 0);
>  
>  	synchronize_net();
> @@ -503,7 +510,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>  		goto out;
>  
>  	err = -EINVAL;
> -	if (rtnl_dereference(tfile->tun))
> +	if (rtnl_dereference(tfile->tun) && !tfile->detached)
>  		goto out;
>  
>  	err = -EBUSY;
> @@ -1202,7 +1209,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	tun->dev->stats.rx_packets++;
>  	tun->dev->stats.rx_bytes += len;
>  
> -	tun_flow_update(tun, rxhash, tfile->queue_index);
> +	tun_flow_update(tun, rxhash, tfile);
>  	return total_len;
>  }
>  
> @@ -1816,7 +1823,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>  		ret = tun_attach(tun, file);
>  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
>  		tun = rtnl_dereference(tfile->tun);
> -		if (!tun || !(tun->flags & TUN_TAP_MQ))
> +		if (!tun || !(tun->flags & TUN_TAP_MQ) || tfile->detached)
>  			ret = -EINVAL;
>  		else
>  			__tun_detach(tfile, false);
> -- 
> 1.7.1
