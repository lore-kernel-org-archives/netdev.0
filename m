From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: Fix race between device delete and open.
Date: Tue, 23 Sep 2014 11:31:20 +0300
Message-ID: <20140923083120.GE16527@redhat.com>
References: <1411418057-18937-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
	Jason Wang <jasowang@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbaIWI16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:27:58 -0400
Content-Disposition: inline
In-Reply-To: <1411418057-18937-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 04:34:17PM -0400, Vladislav Yasevich wrote:
> In macvtap device delete and open calls can race and
> this causes a list curruption of the vlan queue_list.
> 
> The race intself is triggered by the idr accessors
> that located the vlan device.  The device is stored
> into and removed from the idr under both an rtnl and
> a mutex.  However, when attempting to locate the device
> in idr, only a mutex is taken.  As a result, once cpu
> perfoming a delete may take an rtnl and wait for the mutex,
> while another cput doing an open() will take the idr
> mutex first to fetch the device pointer and later take
> an rtnl to add a queue for the device which may have
> just gotten deleted.
> 
> With this patch, we now hold the rtnl for the duration
> of the macvtap_open() call thus making sure that
> open will not race with delete.
> 
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Cc: stable@vger.kernel.org
Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 3381c4f..0c6adaa 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -112,17 +112,15 @@ out:
>  	return err;
>  }
>  
> +/* Requires RTNL */
>  static int macvtap_set_queue(struct net_device *dev, struct file *file,
>  			     struct macvtap_queue *q)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
> -	int err = -EBUSY;
>  
> -	rtnl_lock();
>  	if (vlan->numqueues == MAX_MACVTAP_QUEUES)
> -		goto out;
> +		return -EBUSY;
>  
> -	err = 0;
>  	rcu_assign_pointer(q->vlan, vlan);
>  	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
>  	sock_hold(&q->sk);
> @@ -136,9 +134,7 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
>  	vlan->numvtaps++;
>  	vlan->numqueues++;
>  
> -out:
> -	rtnl_unlock();
> -	return err;
> +	return 0;
>  }
>  
>  static int macvtap_disable_queue(struct macvtap_queue *q)
> @@ -454,11 +450,12 @@ static void macvtap_sock_destruct(struct sock *sk)
>  static int macvtap_open(struct inode *inode, struct file *file)
>  {
>  	struct net *net = current->nsproxy->net_ns;
> -	struct net_device *dev = dev_get_by_macvtap_minor(iminor(inode));
> +	struct net_device *dev;
>  	struct macvtap_queue *q;
> -	int err;
> +	int err = -ENODEV;
>  
> -	err = -ENODEV;
> +	rtnl_lock();
> +	dev = dev_get_by_macvtap_minor(iminor(inode));
>  	if (!dev)
>  		goto out;
>  
> @@ -498,6 +495,7 @@ out:
>  	if (dev)
>  		dev_put(dev);
>  
> +	rtnl_unlock();
>  	return err;
>  }
>  
> -- 
> 1.9.3
