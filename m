From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] tuntap: rx batching
Date: Wed, 9 Nov 2016 18:38:38 +0200
Message-ID: <20161109183259-mutt-send-email-mst@kernel.org>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54596 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934118AbcKIQij (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:38:39 -0500
Content-Disposition: inline
In-Reply-To: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2016 at 03:38:31PM +0800, Jason Wang wrote:
> Backlog were used for tuntap rx, but it can only process 1 packet at
> one time since it was scheduled during sendmsg() synchronously in
> process context. This lead bad cache utilization so this patch tries
> to do some batching before call rx NAPI. This is done through:
> 
> - accept MSG_MORE as a hint from sendmsg() caller, if it was set,
>   batch the packet temporarily in a linked list and submit them all
>   once MSG_MORE were cleared.
> - implement a tuntap specific NAPI handler for processing this kind of
>   possible batching. (This could be done by extending backlog to
>   support skb like, but using a tun specific one looks cleaner and
>   easier for future extension).
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

So why do we need an extra queue? This is not what hardware devices do.
How about adding the packet to queue unconditionally, deferring
signalling until we get sendmsg without MSG_MORE?


> ---
>  drivers/net/tun.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 65 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 1588469..d40583b 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -74,6 +74,7 @@
>  #include <linux/skb_array.h>
>  
>  #include <asm/uaccess.h>
> +#include <linux/interrupt.h>
>  
>  /* Uncomment to enable debugging */
>  /* #define TUN_DEBUG 1 */
> @@ -169,6 +170,8 @@ struct tun_file {
>  	struct list_head next;
>  	struct tun_struct *detached;
>  	struct skb_array tx_array;
> +	struct napi_struct napi;
> +	struct sk_buff_head process_queue;
>  };
>  
>  struct tun_flow_entry {
> @@ -522,6 +525,8 @@ static void tun_queue_purge(struct tun_file *tfile)
>  	while ((skb = skb_array_consume(&tfile->tx_array)) != NULL)
>  		kfree_skb(skb);
>  
> +	skb_queue_purge(&tfile->sk.sk_write_queue);
> +	skb_queue_purge(&tfile->process_queue);
>  	skb_queue_purge(&tfile->sk.sk_error_queue);
>  }
>  
> @@ -532,6 +537,11 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>  
>  	tun = rtnl_dereference(tfile->tun);
>  
> +	if (tun && clean) {
> +		napi_disable(&tfile->napi);
> +		netif_napi_del(&tfile->napi);
> +	}
> +
>  	if (tun && !tfile->detached) {
>  		u16 index = tfile->queue_index;
>  		BUG_ON(index >= tun->numqueues);
> @@ -587,6 +597,7 @@ static void tun_detach_all(struct net_device *dev)
>  
>  	for (i = 0; i < n; i++) {
>  		tfile = rtnl_dereference(tun->tfiles[i]);
> +		napi_disable(&tfile->napi);
>  		BUG_ON(!tfile);
>  		tfile->socket.sk->sk_shutdown = RCV_SHUTDOWN;
>  		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
> @@ -603,6 +614,7 @@ static void tun_detach_all(struct net_device *dev)
>  	synchronize_net();
>  	for (i = 0; i < n; i++) {
>  		tfile = rtnl_dereference(tun->tfiles[i]);
> +		netif_napi_del(&tfile->napi);
>  		/* Drop read queue */
>  		tun_queue_purge(tfile);
>  		sock_put(&tfile->sk);
> @@ -618,6 +630,41 @@ static void tun_detach_all(struct net_device *dev)
>  		module_put(THIS_MODULE);
>  }
>  
> +static int tun_poll(struct napi_struct *napi, int budget)
> +{
> +	struct tun_file *tfile = container_of(napi, struct tun_file, napi);
> +	struct sk_buff_head *input_queue =
> +	       &tfile->socket.sk->sk_write_queue;
> +	struct sk_buff *skb;
> +	unsigned int received = 0;
> +
> +	while (1) {
> +		while ((skb = __skb_dequeue(&tfile->process_queue))) {
> +			netif_receive_skb(skb);
> +			if (++received >= budget)
> +				return received;
> +		}
> +
> +		spin_lock(&input_queue->lock);
> +		if (skb_queue_empty(input_queue)) {
> +			spin_unlock(&input_queue->lock);
> +			break;
> +		}
> +		skb_queue_splice_tail_init(input_queue, &tfile->process_queue);
> +		spin_unlock(&input_queue->lock);
> +	}
> +
> +	if (received < budget) {
> +		napi_complete(napi);
> +		if (skb_peek(&tfile->socket.sk->sk_write_queue) &&
> +		    unlikely(napi_schedule_prep(napi))) {
> +			__napi_schedule(napi);
> +		}
> +	}
> +
> +	return received;
> +}
> +
>  static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filter)
>  {
>  	struct tun_file *tfile = file->private_data;
> @@ -666,9 +713,11 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
>  
>  	if (tfile->detached)
>  		tun_enable_queue(tfile);
> -	else
> +	else {
>  		sock_hold(&tfile->sk);
> -
> +		netif_napi_add(tun->dev, &tfile->napi, tun_poll, 64);
> +		napi_enable(&tfile->napi);
> +	}
>  	tun_set_real_num_queues(tun);
>  
>  	/* device is allowed to go away first, so no need to hold extra
> @@ -1150,7 +1199,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>  /* Get packet from user space buffer */
>  static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  			    void *msg_control, struct iov_iter *from,
> -			    int noblock)
> +			    int noblock, bool more)
>  {
>  	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
>  	struct sk_buff *skb;
> @@ -1296,7 +1345,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	skb_probe_transport_header(skb, 0);
>  
>  	rxhash = skb_get_hash(skb);
> -	netif_rx_ni(skb);
> +	skb_queue_tail(&tfile->socket.sk->sk_write_queue, skb);
> +
> +	if (!more) {
> +		local_bh_disable();
> +		napi_schedule(&tfile->napi);
> +		local_bh_enable();

Why do we need to disable bh here? I thought napi_schedule can
be called from any context.

> +	}
>  
>  	stats = get_cpu_ptr(tun->pcpu_stats);
>  	u64_stats_update_begin(&stats->syncp);
> @@ -1319,7 +1374,8 @@ static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  	if (!tun)
>  		return -EBADFD;
>  
> -	result = tun_get_user(tun, tfile, NULL, from, file->f_flags & O_NONBLOCK);
> +	result = tun_get_user(tun, tfile, NULL, from,
> +			      file->f_flags & O_NONBLOCK, false);
>  
>  	tun_put(tun);
>  	return result;
> @@ -1579,7 +1635,8 @@ static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
>  		return -EBADFD;
>  
>  	ret = tun_get_user(tun, tfile, m->msg_control, &m->msg_iter,
> -			   m->msg_flags & MSG_DONTWAIT);
> +			   m->msg_flags & MSG_DONTWAIT,
> +			   m->msg_flags & MSG_MORE);
>  	tun_put(tun);
>  	return ret;
>  }
> @@ -2336,6 +2393,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>  	file->private_data = tfile;
>  	INIT_LIST_HEAD(&tfile->next);
>  
> +	skb_queue_head_init(&tfile->process_queue);
> +
>  	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
>  
>  	return 0;
> -- 
> 2.7.4
