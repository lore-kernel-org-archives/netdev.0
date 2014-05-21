From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Wed, 21 May 2014 10:54:17 +0300
Message-ID: <20140521075417.GB15279@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Xi Wang <xii@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883AbaEUHz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 03:55:27 -0400
Content-Disposition: inline
In-Reply-To: <1400278308-25372-1-git-send-email-xii@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 03:11:48PM -0700, Xi Wang wrote:
> tun_do_read always adds current thread to wait queue, even if a packet
> is ready to read. This is inefficient because both sleeper and waker
> want to acquire the wait queue spin lock when packet rate is high.
> 
> We restructure the read function and use common kernel networking
> routines to handle receive, sleep and wakeup. With the change
> available packets are checked first before the reading thread is added
> to the wait queue.
> 
> Ran performance tests with the following configuration:
> 
>  - my packet generator -> tap1 -> br0 -> tap0 -> my packet consumer
>  - sender pinned to one core and receiver pinned to another core
>  - sender send small UDP packets (64 bytes total) as fast as it can
>  - sandy bridge cores
>  - throughput are receiver side goodput numbers
> 
> The results are
> 
> baseline: 731k pkts/sec, cpu utilization at 1.50 cpus
>  changed: 783k pkts/sec, cpu utilization at 1.53 cpus
> 
> The performance difference is largely determined by packet rate and
> inter-cpu communication cost. For example, if the sender and
> receiver are pinned to different cpu sockets, the results are
> 
> baseline: 558k pkts/sec, cpu utilization at 1.71 cpus
>  changed: 690k pkts/sec, cpu utilization at 1.67 cpus
> 
> Co-authored-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Xi Wang <xii@google.com>

Less code and more performance, what's not to like.
I think userspace concerns/questions have been addressed in
this thread.

Acked-by: Michael S. Tsirkin <mst@redhat.com>


Thanks for your patience!

> ---
> 
> Changelog since v1:
>  - Added back error code. NETREG_REGISTERED behavior is different but
>    should be compatible with the previous implementation
>  - Removed non essential changes
> 
> 
>  drivers/net/tun.c | 54 ++++++++++++++++--------------------------------------
>  1 file changed, 16 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index ee328ba..98bad1f 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -498,12 +498,12 @@ static void tun_detach_all(struct net_device *dev)
>  	for (i = 0; i < n; i++) {
>  		tfile = rtnl_dereference(tun->tfiles[i]);
>  		BUG_ON(!tfile);
> -		wake_up_all(&tfile->wq.wait);
> +		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>  		RCU_INIT_POINTER(tfile->tun, NULL);
>  		--tun->numqueues;
>  	}
>  	list_for_each_entry(tfile, &tun->disabled, next) {
> -		wake_up_all(&tfile->wq.wait);
> +		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>  		RCU_INIT_POINTER(tfile->tun, NULL);
>  	}
>  	BUG_ON(tun->numqueues != 0);
> @@ -807,8 +807,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Notify and wake up reader process */
>  	if (tfile->flags & TUN_FASYNC)
>  		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
> -	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
> -				   POLLRDNORM | POLLRDBAND);
> +	tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>  
>  	rcu_read_unlock();
>  	return NETDEV_TX_OK;
> @@ -965,7 +964,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
>  
>  	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
>  
> -	poll_wait(file, &tfile->wq.wait, wait);
> +	poll_wait(file, sk_sleep(sk), wait);
>  
>  	if (!skb_queue_empty(&sk->sk_receive_queue))
>  		mask |= POLLIN | POLLRDNORM;
> @@ -1330,47 +1329,26 @@ done:
>  static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>  			   const struct iovec *iv, ssize_t len, int noblock)
>  {
> -	DECLARE_WAITQUEUE(wait, current);
>  	struct sk_buff *skb;
>  	ssize_t ret = 0;
> +	int peeked, err, off = 0;
>  
>  	tun_debug(KERN_INFO, tun, "tun_do_read\n");
>  
> -	if (unlikely(!noblock))
> -		add_wait_queue(&tfile->wq.wait, &wait);
> -	while (len) {
> -		if (unlikely(!noblock))
> -			current->state = TASK_INTERRUPTIBLE;
> +	if (!len)
> +		return ret;
>  
> -		/* Read frames from the queue */
> -		if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
> -			if (noblock) {
> -				ret = -EAGAIN;
> -				break;
> -			}
> -			if (signal_pending(current)) {
> -				ret = -ERESTARTSYS;
> -				break;
> -			}
> -			if (tun->dev->reg_state != NETREG_REGISTERED) {
> -				ret = -EIO;
> -				break;
> -			}
> -
> -			/* Nothing to read, let's sleep */
> -			schedule();
> -			continue;
> -		}
> +	if (tun->dev->reg_state != NETREG_REGISTERED)
> +		return -EIO;
>  
> +	/* Read frames from queue */
> +	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
> +				  &peeked, &off, &err);
> +	if (skb) {
>  		ret = tun_put_user(tun, tfile, skb, iv, len);
>  		kfree_skb(skb);
> -		break;
> -	}
> -
> -	if (unlikely(!noblock)) {
> -		current->state = TASK_RUNNING;
> -		remove_wait_queue(&tfile->wq.wait, &wait);
> -	}
> +	} else
> +		ret = err;
>  
>  	return ret;
>  }
> @@ -2199,8 +2177,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>  	tfile->flags = 0;
>  	tfile->ifindex = 0;
>  
> -	rcu_assign_pointer(tfile->socket.wq, &tfile->wq);
>  	init_waitqueue_head(&tfile->wq.wait);
> +	RCU_INIT_POINTER(tfile->socket.wq, &tfile->wq);
>  
>  	tfile->socket.file = file;
>  	tfile->socket.ops = &tun_socket_ops;
> -- 
> 1.9.1.423.g4596e3a
