From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V3 PATCH 1/6] tuntap: move socket to tun_file
Date: Tue, 26 Jun 2012 13:55:15 +0800
Message-ID: <4FE94EC3.2060802@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625060945.6765.98618.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625082742.GA18794@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	krkumar2@in.ibm.com, tahm@linux.vnet.ibm.com, akong@redhat.com,
	davem@davemloft.net, shemminger@vyatta.com, mashirle@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625082742.GA18794@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/25/2012 04:27 PM, Michael S. Tsirkin wrote:
> On Mon, Jun 25, 2012 at 02:09:45PM +0800, Jason Wang wrote:
>> This patch moves socket structure from tun_device and to tun_file in order to
>> let it possbile for multiple sockets to be attached to tun/tap device. The
>> reference between tap device and socket was setup during TUNSETIFF as
>> usual.
>>
>> After this patch, we can go further towards multiqueue tun/tap support by
>> storing an array of pointers of tun_file in tun_device.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
> I think this changes visible userspace
> behaviour for persistent devices.
>
> Specifically, with this patch, TUNSETSNDBUF and TUNATTACHFILTER won't
> be effective if you close and reopen the device, right?

Yes, good catch.
> It's possible that no application uses either of these
> ioctls on persistent tun devices at the moment,
> but seems safer to avoid changing such behaviour.

Agree, I would modify the socket filer and sndbuf to be per-device 
instead of per-socket.
>
>> ---
>>   drivers/net/tun.c |  352 +++++++++++++++++++++++++++--------------------------
>>   1 files changed, 181 insertions(+), 171 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 987aeef..1f27789 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -108,9 +108,16 @@ struct tap_filter {
>>   };
>>
>>   struct tun_file {
>> +	struct sock sk;
>> +	struct socket socket;
>> +	struct socket_wq wq;
>> +	int vnet_hdr_sz;
>> +	struct tap_filter txflt;
>>   	atomic_t count;
>>   	struct tun_struct *tun;
>>   	struct net *net;
>> +	struct fasync_struct *fasync;
>> +	unsigned int flags;
>>   };
>>
>>   struct tun_sock;
>> @@ -125,29 +132,12 @@ struct tun_struct {
>>   	netdev_features_t	set_features;
>>   #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
>>   			  NETIF_F_TSO6|NETIF_F_UFO)
>> -	struct fasync_struct	*fasync;
>> -
>> -	struct tap_filter       txflt;
>> -	struct socket		socket;
>> -	struct socket_wq	wq;
>> -
>> -	int			vnet_hdr_sz;
>>
>>   #ifdef TUN_DEBUG
>>   	int debug;
>>   #endif
>>   };
>>
>> -struct tun_sock {
>> -	struct sock		sk;
>> -	struct tun_struct	*tun;
>> -};
>> -
>> -static inline struct tun_sock *tun_sk(struct sock *sk)
>> -{
>> -	return container_of(sk, struct tun_sock, sk);
>> -}
>> -
>>   static int tun_attach(struct tun_struct *tun, struct file *file)
>>   {
>>   	struct tun_file *tfile = file->private_data;
>> @@ -168,10 +158,9 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
>>   	err = 0;
>>   	tfile->tun = tun;
>>   	tun->tfile = tfile;
>> -	tun->socket.file = file;
>>   	netif_carrier_on(tun->dev);
>>   	dev_hold(tun->dev);
>> -	sock_hold(tun->socket.sk);
>> +	sock_hold(&tfile->sk);
>>   	atomic_inc(&tfile->count);
>>
>>   out:
>> @@ -181,15 +170,15 @@ out:
>>
>>   static void __tun_detach(struct tun_struct *tun)
>>   {
>> +	struct tun_file *tfile = tun->tfile;
>>   	/* Detach from net device */
>>   	netif_tx_lock_bh(tun->dev);
>>   	netif_carrier_off(tun->dev);
>>   	tun->tfile = NULL;
>> -	tun->socket.file = NULL;
>>   	netif_tx_unlock_bh(tun->dev);
>>
>>   	/* Drop read queue */
>> -	skb_queue_purge(&tun->socket.sk->sk_receive_queue);
>> +	skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
>>
>>   	/* Drop the extra count on the net device */
>>   	dev_put(tun->dev);
>> @@ -348,19 +337,12 @@ static void tun_net_uninit(struct net_device *dev)
>>   	/* Inform the methods they need to stop using the dev.
>>   	 */
>>   	if (tfile) {
>> -		wake_up_all(&tun->wq.wait);
>> +		wake_up_all(&tfile->wq.wait);
>>   		if (atomic_dec_and_test(&tfile->count))
>>   			__tun_detach(tun);
>>   	}
>>   }
>>
>> -static void tun_free_netdev(struct net_device *dev)
>> -{
>> -	struct tun_struct *tun = netdev_priv(dev);
>> -
>> -	sk_release_kernel(tun->socket.sk);
>> -}
>> -
>>   /* Net device open. */
>>   static int tun_net_open(struct net_device *dev)
>>   {
>> @@ -379,24 +361,26 @@ static int tun_net_close(struct net_device *dev)
>>   static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>   {
>>   	struct tun_struct *tun = netdev_priv(dev);
>> +	struct tun_file *tfile = tun->tfile;
>>
>>   	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
>>
>>   	/* Drop packet if interface is not attached */
>> -	if (!tun->tfile)
>> +	if (!tfile)
>>   		goto drop;
>>
>>   	/* Drop if the filter does not like it.
>>   	 * This is a noop if the filter is disabled.
>>   	 * Filter can be enabled only for the TAP devices. */
>> -	if (!check_filter(&tun->txflt, skb))
>> +	if (!check_filter(&tfile->txflt, skb))
>>   		goto drop;
>>
>> -	if (tun->socket.sk->sk_filter&&
>> -	    sk_filter(tun->socket.sk, skb))
>> +	if (tfile->socket.sk->sk_filter&&
>> +	    sk_filter(tfile->socket.sk, skb))
>>   		goto drop;
>>
>> -	if (skb_queue_len(&tun->socket.sk->sk_receive_queue)>= dev->tx_queue_len) {
>> +	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
>> +	>= dev->tx_queue_len) {
>>   		if (!(tun->flags&  TUN_ONE_QUEUE)) {
>>   			/* Normal queueing mode. */
>>   			/* Packet scheduler handles dropping of further packets. */
>> @@ -417,12 +401,12 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	skb_orphan(skb);
>>
>>   	/* Enqueue packet */
>> -	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
>> +	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
>>
>>   	/* Notify and wake up reader process */
>> -	if (tun->flags&  TUN_FASYNC)
>> -		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
>> -	wake_up_interruptible_poll(&tun->wq.wait, POLLIN |
>> +	if (tfile->flags&  TUN_FASYNC)
>> +		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
>> +	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
>>   				   POLLRDNORM | POLLRDBAND);
>>   	return NETDEV_TX_OK;
>>
>> @@ -550,11 +534,11 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
>>   	if (!tun)
>>   		return POLLERR;
>>
>> -	sk = tun->socket.sk;
>> +	sk = tfile->socket.sk;
>>
>>   	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
>>
>> -	poll_wait(file,&tun->wq.wait, wait);
>> +	poll_wait(file,&tfile->wq.wait, wait);
>>
>>   	if (!skb_queue_empty(&sk->sk_receive_queue))
>>   		mask |= POLLIN | POLLRDNORM;
>> @@ -573,11 +557,11 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
>>
>>   /* prepad is the amount to reserve at front.  len is length after that.
>>    * linear is a hint as to how much to copy (usually headers). */
>> -static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
>> +static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>>   				     size_t prepad, size_t len,
>>   				     size_t linear, int noblock)
>>   {
>> -	struct sock *sk = tun->socket.sk;
>> +	struct sock *sk = tfile->socket.sk;
>>   	struct sk_buff *skb;
>>   	int err;
>>
>> @@ -601,7 +585,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
>>   }
>>
>>   /* Get packet from user space buffer */
>> -static ssize_t tun_get_user(struct tun_struct *tun,
>> +static ssize_t tun_get_user(struct tun_file *tfile,
>>   			    const struct iovec *iv, size_t count,
>>   			    int noblock)
>>   {
>> @@ -610,8 +594,10 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>   	size_t len = count, align = NET_SKB_PAD;
>>   	struct virtio_net_hdr gso = { 0 };
>>   	int offset = 0;
>> +	struct tun_struct *tun = NULL;
>> +	bool drop = false, error = false;
>>
>> -	if (!(tun->flags&  TUN_NO_PI)) {
>> +	if (!(tfile->flags&  TUN_NO_PI)) {
>>   		if ((len -= sizeof(pi))>  count)
>>   			return -EINVAL;
>>
>> @@ -620,8 +606,9 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>   		offset += sizeof(pi);
>>   	}
>>
>> -	if (tun->flags&  TUN_VNET_HDR) {
>> -		if ((len -= tun->vnet_hdr_sz)>  count)
>> +	if (tfile->flags&  TUN_VNET_HDR) {
>> +		len -= tfile->vnet_hdr_sz;
>> +		if (len>  count)
>>   			return -EINVAL;
>>
>>   		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
>> @@ -633,41 +620,43 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>
>>   		if (gso.hdr_len>  len)
>>   			return -EINVAL;
>> -		offset += tun->vnet_hdr_sz;
>> +		offset += tfile->vnet_hdr_sz;
>>   	}
>>
>> -	if ((tun->flags&  TUN_TYPE_MASK) == TUN_TAP_DEV) {
>> +	if ((tfile->flags&  TUN_TYPE_MASK) == TUN_TAP_DEV) {
>>   		align += NET_IP_ALIGN;
>>   		if (unlikely(len<  ETH_HLEN ||
>>   			     (gso.hdr_len&&  gso.hdr_len<  ETH_HLEN)))
>>   			return -EINVAL;
>>   	}
>>
>> -	skb = tun_alloc_skb(tun, align, len, gso.hdr_len, noblock);
>> +	skb = tun_alloc_skb(tfile, align, len, gso.hdr_len, noblock);
>> +
>>   	if (IS_ERR(skb)) {
>>   		if (PTR_ERR(skb) != -EAGAIN)
>> -			tun->dev->stats.rx_dropped++;
>> -		return PTR_ERR(skb);
>> +			drop = true;
>> +		count = PTR_ERR(skb);
>> +		goto err;
>>   	}
>>
>>   	if (skb_copy_datagram_from_iovec(skb, 0, iv, offset, len)) {
>> -		tun->dev->stats.rx_dropped++;
>> +		drop = true;
>>   		kfree_skb(skb);
>> -		return -EFAULT;
>> +		count = -EFAULT;
>> +		goto err;
>>   	}
>>
>>   	if (gso.flags&  VIRTIO_NET_HDR_F_NEEDS_CSUM) {
>>   		if (!skb_partial_csum_set(skb, gso.csum_start,
>>   					  gso.csum_offset)) {
>> -			tun->dev->stats.rx_frame_errors++;
>> -			kfree_skb(skb);
>> -			return -EINVAL;
>> +			error = true;
>> +			goto err_free;
>>   		}
>>   	}
>>
>> -	switch (tun->flags&  TUN_TYPE_MASK) {
>> +	switch (tfile->flags&  TUN_TYPE_MASK) {
>>   	case TUN_TUN_DEV:
>> -		if (tun->flags&  TUN_NO_PI) {
>> +		if (tfile->flags&  TUN_NO_PI) {
>>   			switch (skb->data[0]&  0xf0) {
>>   			case 0x40:
>>   				pi.proto = htons(ETH_P_IP);
>> @@ -676,18 +665,15 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>   				pi.proto = htons(ETH_P_IPV6);
>>   				break;
>>   			default:
>> -				tun->dev->stats.rx_dropped++;
>> -				kfree_skb(skb);
>> -				return -EINVAL;
>> +				drop = true;
>> +				goto err_free;
>>   			}
>>   		}
>>
>>   		skb_reset_mac_header(skb);
>>   		skb->protocol = pi.proto;
>> -		skb->dev = tun->dev;
>>   		break;
>>   	case TUN_TAP_DEV:
>> -		skb->protocol = eth_type_trans(skb, tun->dev);
>>   		break;
>>   	}
>>
>> @@ -704,9 +690,8 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>   			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>>   			break;
>>   		default:
>> -			tun->dev->stats.rx_frame_errors++;
>> -			kfree_skb(skb);
>> -			return -EINVAL;
>> +			error = true;
>> +			goto err_free;
>>   		}
>>
>>   		if (gso.gso_type&  VIRTIO_NET_HDR_GSO_ECN)
>> @@ -714,9 +699,8 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>
>>   		skb_shinfo(skb)->gso_size = gso.gso_size;
>>   		if (skb_shinfo(skb)->gso_size == 0) {
>> -			tun->dev->stats.rx_frame_errors++;
>> -			kfree_skb(skb);
>> -			return -EINVAL;
>> +			error = true;
>> +			goto err_free;
>>   		}
>>
>>   		/* Header must be checked, and gso_segs computed. */
>> @@ -724,11 +708,38 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>>   		skb_shinfo(skb)->gso_segs = 0;
>>   	}
>>
>> -	netif_rx_ni(skb);
>> +	tun = __tun_get(tfile);
>> +	if (!tun)
>> +		return -EBADFD;
>>
>> +	switch (tfile->flags&  TUN_TYPE_MASK) {
>> +	case TUN_TUN_DEV:
>> +		skb->dev = tun->dev;
>> +		break;
>> +	case TUN_TAP_DEV:
>> +		skb->protocol = eth_type_trans(skb, tun->dev);
>> +		break;
>> +	}
>> +
>> +	netif_rx_ni(skb);
>>   	tun->dev->stats.rx_packets++;
>>   	tun->dev->stats.rx_bytes += len;
>> +	tun_put(tun);
>> +	return count;
>> +
>> +err_free:
>> +	count = -EINVAL;
>> +	kfree_skb(skb);
>> +err:
>> +	tun = __tun_get(tfile);
>> +	if (!tun)
>> +		return -EBADFD;
>>
>> +	if (drop)
>> +		tun->dev->stats.rx_dropped++;
>> +	if (error)
>> +		tun->dev->stats.rx_frame_errors++;
>> +	tun_put(tun);
>>   	return count;
>>   }
>>
>> @@ -736,30 +747,25 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
>>   			      unsigned long count, loff_t pos)
>>   {
>>   	struct file *file = iocb->ki_filp;
>> -	struct tun_struct *tun = tun_get(file);
>> +	struct tun_file *tfile = file->private_data;
>>   	ssize_t result;
>>
>> -	if (!tun)
>> -		return -EBADFD;
>> -
>> -	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
>> -
>> -	result = tun_get_user(tun, iv, iov_length(iv, count),
>> +	result = tun_get_user(tfile, iv, iov_length(iv, count),
>>   			      file->f_flags&  O_NONBLOCK);
>>
>> -	tun_put(tun);
>>   	return result;
>>   }
>>
>>   /* Put packet to the user space buffer */
>> -static ssize_t tun_put_user(struct tun_struct *tun,
>> +static ssize_t tun_put_user(struct tun_file *tfile,
>>   			    struct sk_buff *skb,
>>   			    const struct iovec *iv, int len)
>>   {
>> +	struct tun_struct *tun = NULL;
>>   	struct tun_pi pi = { 0, skb->protocol };
>>   	ssize_t total = 0;
>>
>> -	if (!(tun->flags&  TUN_NO_PI)) {
>> +	if (!(tfile->flags&  TUN_NO_PI)) {
>>   		if ((len -= sizeof(pi))<  0)
>>   			return -EINVAL;
>>
>> @@ -773,9 +779,10 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>>   		total += sizeof(pi);
>>   	}
>>
>> -	if (tun->flags&  TUN_VNET_HDR) {
>> +	if (tfile->flags&  TUN_VNET_HDR) {
>>   		struct virtio_net_hdr gso = { 0 }; /* no info leak */
>> -		if ((len -= tun->vnet_hdr_sz)<  0)
>> +		len -= tfile->vnet_hdr_sz;
>> +		if (len<  0)
>>   			return -EINVAL;
>>
>>   		if (skb_is_gso(skb)) {
>> @@ -818,7 +825,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>>   		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
>>   					       sizeof(gso))))
>>   			return -EFAULT;
>> -		total += tun->vnet_hdr_sz;
>> +		total += tfile->vnet_hdr_sz;
>>   	}
>>
>>   	len = min_t(int, skb->len, len);
>> @@ -826,29 +833,33 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>>   	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
>>   	total += skb->len;
>>
>> -	tun->dev->stats.tx_packets++;
>> -	tun->dev->stats.tx_bytes += len;
>> +	tun = __tun_get(tfile);
>> +	if (tun) {
>> +		tun->dev->stats.tx_packets++;
>> +		tun->dev->stats.tx_bytes += len;
>> +		tun_put(tun);
>> +	}
>>
>>   	return total;
>>   }
>>
>> -static ssize_t tun_do_read(struct tun_struct *tun,
>> +static ssize_t tun_do_read(struct tun_file *tfile,
>>   			   struct kiocb *iocb, const struct iovec *iv,
>>   			   ssize_t len, int noblock)
>>   {
>>   	DECLARE_WAITQUEUE(wait, current);
>>   	struct sk_buff *skb;
>>   	ssize_t ret = 0;
>> -
>> -	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
>> +	struct tun_struct *tun = NULL;
>>
>>   	if (unlikely(!noblock))
>> -		add_wait_queue(&tun->wq.wait,&wait);
>> +		add_wait_queue(&tfile->wq.wait,&wait);
>>   	while (len) {
>>   		current->state = TASK_INTERRUPTIBLE;
>>
>> +		skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue);
>>   		/* Read frames from the queue */
>> -		if (!(skb=skb_dequeue(&tun->socket.sk->sk_receive_queue))) {
>> +		if (!skb) {
>>   			if (noblock) {
>>   				ret = -EAGAIN;
>>   				break;
>> @@ -857,25 +868,38 @@ static ssize_t tun_do_read(struct tun_struct *tun,
>>   				ret = -ERESTARTSYS;
>>   				break;
>>   			}
>> +
>> +			tun = __tun_get(tfile);
>> +			if (!tun) {
>> +				ret = -EIO;
>> +				break;
>> +			}
>>   			if (tun->dev->reg_state != NETREG_REGISTERED) {
>>   				ret = -EIO;
>> +				tun_put(tun);
>>   				break;
>>   			}
>> +			tun_put(tun);
>>
>>   			/* Nothing to read, let's sleep */
>>   			schedule();
>>   			continue;
>>   		}
>> -		netif_wake_queue(tun->dev);
>>
>> -		ret = tun_put_user(tun, skb, iv, len);
>> +		tun = __tun_get(tfile);
>> +		if (tun) {
>> +			netif_wake_queue(tun->dev);
>> +			tun_put(tun);
>> +		}
>> +
>> +		ret = tun_put_user(tfile, skb, iv, len);
>>   		kfree_skb(skb);
>>   		break;
>>   	}
>>
>>   	current->state = TASK_RUNNING;
>>   	if (unlikely(!noblock))
>> -		remove_wait_queue(&tun->wq.wait,&wait);
>> +		remove_wait_queue(&tfile->wq.wait,&wait);
>>
>>   	return ret;
>>   }
>> @@ -885,21 +909,17 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
>>   {
>>   	struct file *file = iocb->ki_filp;
>>   	struct tun_file *tfile = file->private_data;
>> -	struct tun_struct *tun = __tun_get(tfile);
>>   	ssize_t len, ret;
>>
>> -	if (!tun)
>> -		return -EBADFD;
>>   	len = iov_length(iv, count);
>>   	if (len<  0) {
>>   		ret = -EINVAL;
>>   		goto out;
>>   	}
>>
>> -	ret = tun_do_read(tun, iocb, iv, len, file->f_flags&  O_NONBLOCK);
>> +	ret = tun_do_read(tfile, iocb, iv, len, file->f_flags&  O_NONBLOCK);
>>   	ret = min_t(ssize_t, ret, len);
>>   out:
>> -	tun_put(tun);
>>   	return ret;
>>   }
>>
>> @@ -911,7 +931,7 @@ static void tun_setup(struct net_device *dev)
>>   	tun->group = -1;
>>
>>   	dev->ethtool_ops =&tun_ethtool_ops;
>> -	dev->destructor = tun_free_netdev;
>> +	dev->destructor = free_netdev;
>>   }
>>
>>   /* Trivial set of netlink ops to allow deleting tun or tap
>> @@ -931,7 +951,7 @@ static struct rtnl_link_ops tun_link_ops __read_mostly = {
>>
>>   static void tun_sock_write_space(struct sock *sk)
>>   {
>> -	struct tun_struct *tun;
>> +	struct tun_file *tfile = NULL;
>>   	wait_queue_head_t *wqueue;
>>
>>   	if (!sock_writeable(sk))
>> @@ -945,37 +965,38 @@ static void tun_sock_write_space(struct sock *sk)
>>   		wake_up_interruptible_sync_poll(wqueue, POLLOUT |
>>   						POLLWRNORM | POLLWRBAND);
>>
>> -	tun = tun_sk(sk)->tun;
>> -	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
>> -}
>> -
>> -static void tun_sock_destruct(struct sock *sk)
>> -{
>> -	free_netdev(tun_sk(sk)->tun->dev);
>> +	tfile = container_of(sk, struct tun_file, sk);
>> +	kill_fasync(&tfile->fasync, SIGIO, POLL_OUT);
>>   }
>>
>>   static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
>>   		       struct msghdr *m, size_t total_len)
>>   {
>> -	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
>> -	return tun_get_user(tun, m->msg_iov, total_len,
>> -			    m->msg_flags&  MSG_DONTWAIT);
>> +	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
>> +	ssize_t result;
>> +
>> +	result = tun_get_user(tfile, m->msg_iov, total_len,
>> +			      m->msg_flags&  MSG_DONTWAIT);
>> +	return result;
>>   }
>>
>>   static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
>>   		       struct msghdr *m, size_t total_len,
>>   		       int flags)
>>   {
>> -	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
>> +	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
>>   	int ret;
>> +
>>   	if (flags&  ~(MSG_DONTWAIT|MSG_TRUNC))
>>   		return -EINVAL;
>> -	ret = tun_do_read(tun, iocb, m->msg_iov, total_len,
>> +
>> +	ret = tun_do_read(tfile, iocb, m->msg_iov, total_len,
>>   			  flags&  MSG_DONTWAIT);
>>   	if (ret>  total_len) {
>>   		m->msg_flags |= MSG_TRUNC;
>>   		ret = flags&  MSG_TRUNC ? ret : total_len;
>>   	}
>> +
>>   	return ret;
>>   }
>>
>> @@ -996,7 +1017,7 @@ static const struct proto_ops tun_socket_ops = {
>>   static struct proto tun_proto = {
>>   	.name		= "tun",
>>   	.owner		= THIS_MODULE,
>> -	.obj_size	= sizeof(struct tun_sock),
>> +	.obj_size	= sizeof(struct tun_file),
>>   };
>>
>>   static int tun_flags(struct tun_struct *tun)
>> @@ -1047,8 +1068,8 @@ static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
>>
>>   static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>   {
>> -	struct sock *sk;
>>   	struct tun_struct *tun;
>> +	struct tun_file *tfile = file->private_data;
>>   	struct net_device *dev;
>>   	int err;
>>
>> @@ -1069,7 +1090,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>   		     (tun->group != -1&&  !in_egroup_p(tun->group)))&&
>>   		!capable(CAP_NET_ADMIN))
>>   			return -EPERM;
>> -		err = security_tun_dev_attach(tun->socket.sk);
>> +		err = security_tun_dev_attach(tfile->socket.sk);
>>   		if (err<  0)
>>   			return err;
>>
>> @@ -1113,25 +1134,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>   		tun = netdev_priv(dev);
>>   		tun->dev = dev;
>>   		tun->flags = flags;
>> -		tun->txflt.count = 0;
>> -		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
>>
>> -		err = -ENOMEM;
>> -		sk = sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL,&tun_proto);
>> -		if (!sk)
>> -			goto err_free_dev;
>> -
>> -		sk_change_net(sk, net);
>> -		tun->socket.wq =&tun->wq;
>> -		init_waitqueue_head(&tun->wq.wait);
>> -		tun->socket.ops =&tun_socket_ops;
>> -		sock_init_data(&tun->socket, sk);
>> -		sk->sk_write_space = tun_sock_write_space;
>> -		sk->sk_sndbuf = INT_MAX;
>> -
>> -		tun_sk(sk)->tun = tun;
>> -
>> -		security_tun_dev_post_create(sk);
>> +		security_tun_dev_post_create(&tfile->sk);
>>
>>   		tun_net_init(dev);
>>
>> @@ -1141,15 +1145,13 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>
>>   		err = register_netdevice(tun->dev);
>>   		if (err<  0)
>> -			goto err_free_sk;
>> +			goto err_free_dev;
>>
>>   		if (device_create_file(&tun->dev->dev,&dev_attr_tun_flags) ||
>>   		    device_create_file(&tun->dev->dev,&dev_attr_owner) ||
>>   		    device_create_file(&tun->dev->dev,&dev_attr_group))
>>   			pr_err("Failed to create tun sysfs files\n");
>>
>> -		sk->sk_destruct = tun_sock_destruct;
>> -
>>   		err = tun_attach(tun, file);
>>   		if (err<  0)
>>   			goto failed;
>> @@ -1172,6 +1174,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>   	else
>>   		tun->flags&= ~TUN_VNET_HDR;
>>
>> +	/* Cache flags from tun device */
>> +	tfile->flags = tun->flags;
>>   	/* Make sure persistent devices do not get stuck in
>>   	 * xoff state.
>>   	 */
>> @@ -1181,11 +1185,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>   	strcpy(ifr->ifr_name, tun->dev->name);
>>   	return 0;
>>
>> - err_free_sk:
>> -	tun_free_netdev(dev);
>> - err_free_dev:
>> +err_free_dev:
>>   	free_netdev(dev);
>> - failed:
>> +failed:
>>   	return err;
>>   }
>>
>> @@ -1357,9 +1359,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>   	case TUNSETTXFILTER:
>>   		/* Can be set only for TAPs */
>>   		ret = -EINVAL;
>> -		if ((tun->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>> +		if ((tfile->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>>   			break;
>> -		ret = update_filter(&tun->txflt, (void __user *)arg);
>> +		ret = update_filter(&tfile->txflt, (void __user *)arg);
>>   		break;
>>
>>   	case SIOCGIFHWADDR:
>> @@ -1379,7 +1381,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>   		break;
>>
>>   	case TUNGETSNDBUF:
>> -		sndbuf = tun->socket.sk->sk_sndbuf;
>> +		sndbuf = tfile->socket.sk->sk_sndbuf;
>>   		if (copy_to_user(argp,&sndbuf, sizeof(sndbuf)))
>>   			ret = -EFAULT;
>>   		break;
>> @@ -1390,11 +1392,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>   			break;
>>   		}
>>
>> -		tun->socket.sk->sk_sndbuf = sndbuf;
>> +		tfile->socket.sk->sk_sndbuf = sndbuf;
>>   		break;
>>
>>   	case TUNGETVNETHDRSZ:
>> -		vnet_hdr_sz = tun->vnet_hdr_sz;
>> +		vnet_hdr_sz = tfile->vnet_hdr_sz;
>>   		if (copy_to_user(argp,&vnet_hdr_sz, sizeof(vnet_hdr_sz)))
>>   			ret = -EFAULT;
>>   		break;
>> @@ -1409,27 +1411,27 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>   			break;
>>   		}
>>
>> -		tun->vnet_hdr_sz = vnet_hdr_sz;
>> +		tfile->vnet_hdr_sz = vnet_hdr_sz;
>>   		break;
>>
>>   	case TUNATTACHFILTER:
>>   		/* Can be set only for TAPs */
>>   		ret = -EINVAL;
>> -		if ((tun->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>> +		if ((tfile->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>>   			break;
>>   		ret = -EFAULT;
>>   		if (copy_from_user(&fprog, argp, sizeof(fprog)))
>>   			break;
>>
>> -		ret = sk_attach_filter(&fprog, tun->socket.sk);
>> +		ret = sk_attach_filter(&fprog, tfile->socket.sk);
>>   		break;
>>
>>   	case TUNDETACHFILTER:
>>   		/* Can be set only for TAPs */
>>   		ret = -EINVAL;
>> -		if ((tun->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>> +		if ((tfile->flags&  TUN_TYPE_MASK) != TUN_TAP_DEV)
>>   			break;
>> -		ret = sk_detach_filter(tun->socket.sk);
>> +		ret = sk_detach_filter(tfile->socket.sk);
>>   		break;
>>
>>   	default:
>> @@ -1481,43 +1483,50 @@ static long tun_chr_compat_ioctl(struct file *file,
>>
>>   static int tun_chr_fasync(int fd, struct file *file, int on)
>>   {
>> -	struct tun_struct *tun = tun_get(file);
>> -	int ret;
>> -
>> -	if (!tun)
>> -		return -EBADFD;
>> -
>> -	tun_debug(KERN_INFO, tun, "tun_chr_fasync %d\n", on);
>> +	struct tun_file *tfile = file->private_data;
>> +	int ret = fasync_helper(fd, file, on,&tfile->fasync);
>>
>> -	if ((ret = fasync_helper(fd, file, on,&tun->fasync))<  0)
>> +	if (ret<  0)
>>   		goto out;
>>
>>   	if (on) {
>>   		ret = __f_setown(file, task_pid(current), PIDTYPE_PID, 0);
>>   		if (ret)
>>   			goto out;
>> -		tun->flags |= TUN_FASYNC;
>> +		tfile->flags |= TUN_FASYNC;
>>   	} else
>> -		tun->flags&= ~TUN_FASYNC;
>> +		tfile->flags&= ~TUN_FASYNC;
>>   	ret = 0;
>>   out:
>> -	tun_put(tun);
>>   	return ret;
>>   }
>>
>>   static int tun_chr_open(struct inode *inode, struct file * file)
>>   {
>> +	struct net *net = current->nsproxy->net_ns;
>>   	struct tun_file *tfile;
>>
>>   	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
>>
>> -	tfile = kmalloc(sizeof(*tfile), GFP_KERNEL);
>> +	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
>> +					&tun_proto);
>>   	if (!tfile)
>>   		return -ENOMEM;
>> -	atomic_set(&tfile->count, 0);
>> +
>>   	tfile->tun = NULL;
>> -	tfile->net = get_net(current->nsproxy->net_ns);
>> +	tfile->net = net;
>> +	tfile->txflt.count = 0;
>> +	tfile->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
>> +	tfile->socket.wq =&tfile->wq;
>> +	init_waitqueue_head(&tfile->wq.wait);
>> +	tfile->socket.file = file;
>> +	tfile->socket.ops =&tun_socket_ops;
>> +	sock_init_data(&tfile->socket,&tfile->sk);
>> +
>> +	tfile->sk.sk_write_space = tun_sock_write_space;
>> +	tfile->sk.sk_sndbuf = INT_MAX;
>>   	file->private_data = tfile;
>> +
>>   	return 0;
>>   }
>>
>> @@ -1541,14 +1550,14 @@ static int tun_chr_close(struct inode *inode, struct file *file)
>>   				unregister_netdevice(dev);
>>   			rtnl_unlock();
>>   		}
>> -	}
>>
>> -	tun = tfile->tun;
>> -	if (tun)
>> -		sock_put(tun->socket.sk);
>> +		/* drop the reference that netdevice holds */
>> +		sock_put(&tfile->sk);
>>
>> -	put_net(tfile->net);
>> -	kfree(tfile);
>> +	}
>> +
>> +	/* drop the reference that file holds */
>> +	sock_put(&tfile->sk);
>>
>>   	return 0;
>>   }
>> @@ -1676,13 +1685,14 @@ static void tun_cleanup(void)
>>   struct socket *tun_get_socket(struct file *file)
>>   {
>>   	struct tun_struct *tun;
>> +	struct tun_file *tfile = file->private_data;
>>   	if (file->f_op !=&tun_fops)
>>   		return ERR_PTR(-EINVAL);
>>   	tun = tun_get(file);
>>   	if (!tun)
>>   		return ERR_PTR(-EBADFD);
>>   	tun_put(tun);
>> -	return&tun->socket;
>> +	return&tfile->socket;
>>   }
>>   EXPORT_SYMBOL_GPL(tun_get_socket);
>>
