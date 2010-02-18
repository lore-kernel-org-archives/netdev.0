From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 2/3] net/macvtap: add vhost support
Date: Thu, 18 Feb 2010 12:10:05 -0800
Message-ID: <1266523805.15681.26.camel@w-sridhar.beaverton.ibm.com>
References: <201002111645.02770.arnd@arndb.de>
	 <20100215.215341.66627877.davem@davemloft.net>
	 <201002181644.29740.arnd@arndb.de>  <201002181646.50674.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eswierk@aristanetworks.com, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:37215 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758442Ab0BRUK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 15:10:29 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1IK1qU3015102
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:01:52 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1IKAB1P038112
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:10:13 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1IKAAr4031435
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:10:10 -0700
In-Reply-To: <201002181646.50674.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 16:46 +0100, Arnd Bergmann wrote:
> This adds support for passing a macvtap file descriptor into
> vhost-net, much like we already do for tun/tap.
> 
> Most of the new code is taken from the respective patch
> in the tun driver and may get consolidated in the future.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed and tested.
Acked-by: Sridhar Samudrala <sri@us.ibm.com>

> ---
>  drivers/net/macvtap.c      |   98 ++++++++++++++++++++++++++++++++++---------
>  drivers/vhost/Kconfig      |    2 +-
>  drivers/vhost/net.c        |    8 +++-
>  include/linux/if_macvlan.h |   13 ++++++
>  4 files changed, 97 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 7050997..e354501 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -58,6 +58,8 @@ static unsigned int macvtap_major;
>  static struct class *macvtap_class;
>  static struct cdev macvtap_cdev;
> 
> +static const struct proto_ops macvtap_socket_ops;
> +
>  /*
>   * RCU usage:
>   * The macvtap_queue and the macvlan_dev are loosely coupled, the
> @@ -176,7 +178,7 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>  		return -ENOLINK;
> 
>  	skb_queue_tail(&q->sk.sk_receive_queue, skb);
> -	wake_up(q->sk.sk_sleep);
> +	wake_up_interruptible_poll(q->sk.sk_sleep, POLLIN | POLLRDNORM | POLLRDBAND);
>  	return 0;
>  }
> 
> @@ -242,7 +244,7 @@ static void macvtap_sock_write_space(struct sock *sk)
>  		return;
> 
>  	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> -		wake_up_interruptible_sync(sk->sk_sleep);
> +		wake_up_interruptible_poll(sk->sk_sleep, POLLOUT | POLLWRNORM | POLLWRBAND);
>  }
> 
>  static int macvtap_open(struct inode *inode, struct file *file)
> @@ -270,6 +272,8 @@ static int macvtap_open(struct inode *inode, struct file *file)
>  	init_waitqueue_head(&q->sock.wait);
>  	q->sock.type = SOCK_RAW;
>  	q->sock.state = SS_CONNECTED;
> +	q->sock.file = file;
> +	q->sock.ops = &macvtap_socket_ops;
>  	sock_init_data(&q->sock, &q->sk);
>  	q->sk.sk_write_space = macvtap_sock_write_space;
> 
> @@ -387,32 +391,20 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
> 
>  	rcu_read_lock_bh();
>  	vlan = rcu_dereference(q->vlan);
> -	macvlan_count_rx(vlan, len, ret == 0, 0);
> +	if (vlan)
> +		macvlan_count_rx(vlan, len, ret == 0, 0);
>  	rcu_read_unlock_bh();
> 
>  	return ret ? ret : len;
>  }
> 
> -static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
> -				unsigned long count, loff_t pos)
> +static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
> +			       const struct iovec *iv, unsigned long len,
> +			       int noblock)
>  {
> -	struct file *file = iocb->ki_filp;
> -	struct macvtap_queue *q = file->private_data;
> -
>  	DECLARE_WAITQUEUE(wait, current);
>  	struct sk_buff *skb;
> -	ssize_t len, ret = 0;
> -
> -	if (!q) {
> -		ret = -ENOLINK;
> -		goto out;
> -	}
> -
> -	len = iov_length(iv, count);
> -	if (len < 0) {
> -		ret = -EINVAL;
> -		goto out;
> -	}
> +	ssize_t ret = 0;
> 
>  	add_wait_queue(q->sk.sk_sleep, &wait);
>  	while (len) {
> @@ -421,7 +413,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
>  		/* Read frames from the queue */
>  		skb = skb_dequeue(&q->sk.sk_receive_queue);
>  		if (!skb) {
> -			if (file->f_flags & O_NONBLOCK) {
> +			if (noblock) {
>  				ret = -EAGAIN;
>  				break;
>  			}
> @@ -440,7 +432,24 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
> 
>  	current->state = TASK_RUNNING;
>  	remove_wait_queue(q->sk.sk_sleep, &wait);
> +	return ret;
> +}
> +
> +static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
> +				unsigned long count, loff_t pos)
> +{
> +	struct file *file = iocb->ki_filp;
> +	struct macvtap_queue *q = file->private_data;
> +	ssize_t len, ret = 0;
> 
> +	len = iov_length(iv, count);
> +	if (len < 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	ret = macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
> +	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
>  out:
>  	return ret;
>  }
> @@ -538,6 +547,53 @@ static const struct file_operations macvtap_fops = {
>  #endif
>  };
> 
> +static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
> +			   struct msghdr *m, size_t total_len)
> +{
> +	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
> +	return macvtap_get_user(q, m->msg_iov, total_len,
> +			    m->msg_flags & MSG_DONTWAIT);
> +}
> +
> +static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
> +			   struct msghdr *m, size_t total_len,
> +			   int flags)
> +{
> +	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
> +	int ret;
> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
> +		return -EINVAL;
> +	ret = macvtap_do_read(q, iocb, m->msg_iov, total_len,
> +			  flags & MSG_DONTWAIT);
> +	if (ret > total_len) {
> +		m->msg_flags |= MSG_TRUNC;
> +		ret = flags & MSG_TRUNC ? ret : total_len;
> +	}
> +	return ret;
> +}
> +
> +/* Ops structure to mimic raw sockets with tun */
> +static const struct proto_ops macvtap_socket_ops = {
> +	.sendmsg = macvtap_sendmsg,
> +	.recvmsg = macvtap_recvmsg,
> +};
> +
> +/* Get an underlying socket object from tun file.  Returns error unless file is
> + * attached to a device.  The returned object works like a packet socket, it
> + * can be used for sock_sendmsg/sock_recvmsg.  The caller is responsible for
> + * holding a reference to the file for as long as the socket is in use. */
> +struct socket *macvtap_get_socket(struct file *file)
> +{
> +	struct macvtap_queue *q;
> +	if (file->f_op != &macvtap_fops)
> +		return ERR_PTR(-EINVAL);
> +	q = file->private_data;
> +	if (!q)
> +		return ERR_PTR(-EBADFD);
> +	return &q->sock;
> +}
> +EXPORT_SYMBOL_GPL(macvtap_get_socket);
> +
>  static int macvtap_init(void)
>  {
>  	int err;
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> index 9e93553..e4e2fd1 100644
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -1,6 +1,6 @@
>  config VHOST_NET
>  	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
> -	depends on NET && EVENTFD && (TUN || !TUN) && EXPERIMENTAL
> +	depends on NET && EVENTFD && (TUN || !TUN) && (MACVTAP || !MACVTAP) && EXPERIMENTAL
>  	---help---
>  	  This kernel module can be loaded in host kernel to accelerate
>  	  guest networking with virtio_net. Not to be confused with virtio_net
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 4c89283..91a324c 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -22,6 +22,7 @@
>  #include <linux/if_packet.h>
>  #include <linux/if_arp.h>
>  #include <linux/if_tun.h>
> +#include <linux/if_macvlan.h>
> 
>  #include <net/sock.h>
> 
> @@ -452,13 +453,16 @@ err:
>  	return ERR_PTR(r);
>  }
> 
> -static struct socket *get_tun_socket(int fd)
> +static struct socket *get_tap_socket(int fd)
>  {
>  	struct file *file = fget(fd);
>  	struct socket *sock;
>  	if (!file)
>  		return ERR_PTR(-EBADF);
>  	sock = tun_get_socket(file);
> +	if (!IS_ERR(sock))
> +		return sock;
> +	sock = macvtap_get_socket(file);
>  	if (IS_ERR(sock))
>  		fput(file);
>  	return sock;
> @@ -473,7 +477,7 @@ static struct socket *get_socket(int fd)
>  	sock = get_raw_socket(fd);
>  	if (!IS_ERR(sock))
>  		return sock;
> -	sock = get_tun_socket(fd);
> +	sock = get_tap_socket(fd);
>  	if (!IS_ERR(sock))
>  		return sock;
>  	return ERR_PTR(-ENOTSOCK);
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index f9cb9ba..b78a712 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -7,6 +7,19 @@
>  #include <linux/netlink.h>
>  #include <net/netlink.h>
> 
> +#if defined(CONFIG_MACVTAP) || defined(CONFIG_MACVTAP_MODULE)
> +struct socket *macvtap_get_socket(struct file *);
> +#else
> +#include <linux/err.h>
> +#include <linux/errno.h>
> +struct file;
> +struct socket;
> +static inline struct socket *macvtap_get_socket(struct file *f)
> +{
> +	return ERR_PTR(-EINVAL);
> +}
> +#endif /* CONFIG_MACVTAP */
> +
>  struct macvlan_port;
>  struct macvtap_queue;
> 

