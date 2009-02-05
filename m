From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Thu, 5 Feb 2009 12:06:49 +1100
Message-ID: <20090205010649.GA28046@gondor.apana.org.au>
References: <20090204104825.GA21257@gondor.apana.org.au> <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au> <20090204.165630.95274793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50487 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753874AbZBEBGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:06:54 -0500
Content-Disposition: inline
In-Reply-To: <20090204.165630.95274793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 04:56:30PM -0800, David Miller wrote:
>
> When adding new tun ioctls, you need to add compat entries
> to fs/compat_ioctl.c

Thanks for pointing this out.  We should really move this stuff
into the files where the actual ioctls live.  Now if only we
can get the janitors working on this sort of stuff.

> Please make this correction and resubmit.

Here we go.

tun: Limit amount of queued packets per device

Unlike a normal socket path, the tuntap device send path does
not have any accounting.  This means that the user-space sender
may be able to pin down arbitrary amounts of kernel memory by
continuing to send data to an end-point that is congested.

Even when this isn't an issue because of limited queueing at
most end points, this can also be a problem because its only
response to congestion is packet loss.  That is, when those
local queues at the end-point fills up, the tuntap device will
start wasting system time because it will continue to send
data there which simply gets dropped straight away.

Of course one could argue that everybody should do congestion
control end-to-end, unfortunately there are people in this world
still hooked on UDP, and they don't appear to be going away
anywhere fast.  In fact, we've always helped them by performing
accounting in our UDP code, the sole purpose of which is to
provide congestion feedback other than through packet loss.

This patch attempts to apply the same bandaid to the tuntap device.
It creates a pseudo-socket object which is used to account our
packets just as a normal socket does for UDP.  Of course things
are a little complex because we're actually reinjecting traffic
back into the stack rather than out of the stack.

The stack complexities however should have been resolved by preceding
patches.  So this one can simply start using skb_set_owner_w.

For now the accounting is essentially disabled by default for
backwards compatibility.  In particular, we set the cap to INT_MAX.
This is so that existing applications don't get confused by the
sudden arrival EAGAIN errors.

In future we may wish (or be forced to) do this by default.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index d7b81e4..a97448d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -63,6 +63,7 @@
 #include <linux/virtio_net.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/sock.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -87,6 +88,8 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
+struct tun_sock;
+
 struct tun_struct {
 	struct list_head        list;
 	unsigned int 		flags;
@@ -101,12 +104,24 @@ struct tun_struct {
 	struct fasync_struct	*fasync;
 
 	struct tap_filter       txflt;
+	struct sock		*sk;
+	struct socket		socket;
 
 #ifdef TUN_DEBUG
 	int debug;
 #endif
 };
 
+struct tun_sock {
+	struct sock		sk;
+	struct tun_struct	*tun;
+};
+
+static inline struct tun_sock *tun_sk(struct sock *sk)
+{
+	return container_of(sk, struct tun_sock, sk);
+}
+
 /* TAP filterting */
 static void addr_hash_set(u32 *mask, const u8 *addr)
 {
@@ -360,7 +375,8 @@ static void tun_net_init(struct net_device *dev)
 static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 {
 	struct tun_struct *tun = file->private_data;
-	unsigned int mask = POLLOUT | POLLWRNORM;
+	struct sock *sk = tun->sk;
+	unsigned int mask = 0;
 
 	if (!tun)
 		return -EBADFD;
@@ -372,71 +388,45 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
 
+	if (sock_writeable(sk) ||
+	    (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
+	     sock_writeable(sk)))
+		mask |= POLLOUT | POLLWRNORM;
+
 	return mask;
 }
 
 /* prepad is the amount to reserve at front.  len is length after that.
  * linear is a hint as to how much to copy (usually headers). */
-static struct sk_buff *tun_alloc_skb(size_t prepad, size_t len, size_t linear,
-				     gfp_t gfp)
+static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
+					    size_t prepad, size_t len,
+					    size_t linear, int noblock)
 {
+	struct sock *sk = tun->sk;
 	struct sk_buff *skb;
-	unsigned int i;
-
-	skb = alloc_skb(prepad + len, gfp|__GFP_NOWARN);
-	if (skb) {
-		skb_reserve(skb, prepad);
-		skb_put(skb, len);
-		return skb;
-	}
+	int err;
 
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE)
-		return NULL;
+		linear = len;
 
-	/* Start with a normal skb, and add pages. */
-	skb = alloc_skb(prepad + linear, gfp);
+	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
+				   &err);
 	if (!skb)
-		return NULL;
+		return ERR_PTR(err);
 
 	skb_reserve(skb, prepad);
 	skb_put(skb, linear);
-
-	len -= linear;
-
-	for (i = 0; i < MAX_SKB_FRAGS; i++) {
-		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-
-		f->page = alloc_page(gfp|__GFP_ZERO);
-		if (!f->page)
-			break;
-
-		f->page_offset = 0;
-		f->size = PAGE_SIZE;
-
-		skb->data_len += PAGE_SIZE;
-		skb->len += PAGE_SIZE;
-		skb->truesize += PAGE_SIZE;
-		skb_shinfo(skb)->nr_frags++;
-
-		if (len < PAGE_SIZE) {
-			len = 0;
-			break;
-		}
-		len -= PAGE_SIZE;
-	}
-
-	/* Too large, or alloc fail? */
-	if (unlikely(len)) {
-		kfree_skb(skb);
-		skb = NULL;
-	}
+	skb->data_len = len - linear;
+	skb->len += len - linear;
 
 	return skb;
 }
 
 /* Get packet from user space buffer */
-static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
+static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
+				       struct iovec *iv, size_t count,
+				       int noblock)
 {
 	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
 	struct sk_buff *skb;
@@ -468,9 +458,11 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv,
 			return -EINVAL;
 	}
 
-	if (!(skb = tun_alloc_skb(align, len, gso.hdr_len, GFP_KERNEL))) {
-		tun->dev->stats.rx_dropped++;
-		return -ENOMEM;
+	skb = tun_alloc_skb(tun, align, len, gso.hdr_len, noblock);
+	if (IS_ERR(skb)) {
+		if (PTR_ERR(skb) != -EAGAIN)
+			tun->dev->stats.rx_dropped++;
+		return PTR_ERR(skb);
 	}
 
 	if (skb_copy_datagram_from_iovec(skb, 0, iv, len)) {
@@ -556,14 +548,16 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv,
 static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 			      unsigned long count, loff_t pos)
 {
-	struct tun_struct *tun = iocb->ki_filp->private_data;
+	struct file *file = iocb->ki_filp;
+	struct tun_struct *tun = file->private_data;
 
 	if (!tun)
 		return -EBADFD;
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	return tun_get_user(tun, (struct iovec *) iv, iov_length(iv, count));
+	return tun_get_user(tun, (struct iovec *) iv, iov_length(iv, count),
+			    file->f_flags & O_NONBLOCK);
 }
 
 /* Put packet to the user space buffer */
@@ -710,8 +704,37 @@ static struct tun_struct *tun_get_by_name(struct tun_net *tn, const char *name)
 	return NULL;
 }
 
+static void tun_sock_write_space(struct sock *sk)
+{
+	struct tun_struct *tun;
+
+	if (!sock_writeable(sk))
+		return;
+
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up_interruptible_sync(sk->sk_sleep);
+
+	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
+		return;
+
+	tun = container_of(sk, struct tun_sock, sk)->tun;
+	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
+}
+
+static void tun_sock_destruct(struct sock *sk)
+{
+	dev_put(container_of(sk, struct tun_sock, sk)->tun->dev);
+}
+
+static struct proto tun_proto = {
+	.name		= "tun",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct tun_sock),
+};
+
 static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 {
+	struct sock *sk;
 	struct tun_net *tn;
 	struct tun_struct *tun;
 	struct net_device *dev;
@@ -771,14 +794,31 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->flags = flags;
 		tun->txflt.count = 0;
 
+		err = -ENOMEM;
+		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
+		if (!sk)
+			goto err_free_dev;
+
+		/* This ref count is for tun->sk. */
+		dev_hold(dev);
+		sock_init_data(&tun->socket, sk);
+		sk->sk_write_space = tun_sock_write_space;
+		sk->sk_destruct = tun_sock_destruct;
+		sk->sk_sndbuf = INT_MAX;
+		sk->sk_sleep = &tun->read_wait;
+
+		tun->sk = sk;
+		container_of(sk, struct tun_sock, sk)->tun = tun;
+
 		tun_net_init(dev);
 
 		if (strchr(dev->name, '%')) {
 			err = dev_alloc_name(dev, dev->name);
 			if (err < 0)
-				goto err_free_dev;
+				goto err_free_sk;
 		}
 
+		err = -EINVAL;
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_dev;
@@ -816,6 +856,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
 
+ err_free_sk:
+	sock_put(sk);
  err_free_dev:
 	free_netdev(dev);
  failed:
@@ -898,6 +940,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 	struct tun_struct *tun = file->private_data;
 	void __user* argp = (void __user*)arg;
 	struct ifreq ifr;
+	int sndbuf;
 	int ret;
 
 	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
@@ -1034,6 +1077,18 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		rtnl_unlock();
 		return ret;
 
+	case TUNGETSNDBUF:
+		sndbuf = tun->sk->sk_sndbuf;
+		if (copy_to_user(argp, &sndbuf, sizeof(sndbuf)))
+			return -EFAULT;
+		return 0;
+
+	case TUNSETSNDBUF:
+		if (copy_from_user(&sndbuf, argp, sizeof(sndbuf)))
+			return -EFAULT;
+		tun->sk->sk_sndbuf = sndbuf;
+		return 0;
+
 	default:
 		return -EINVAL;
 	};
@@ -1097,6 +1152,7 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 
 	if (!(tun->flags & TUN_PERSIST)) {
 		list_del(&tun->list);
+		sock_put(tun->sk);
 		unregister_netdevice(tun->dev);
 	}
 
@@ -1238,6 +1294,7 @@ static void tun_exit_net(struct net *net)
 	rtnl_lock();
 	list_for_each_entry_safe(tun, nxt, &tn->dev_list, list) {
 		DBG(KERN_INFO "%s cleaned up\n", tun->dev->name);
+		sock_put(tun->sk);
 		unregister_netdevice(tun->dev);
 	}
 	rtnl_unlock();
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index c8f8d59..c03c10d 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1988,6 +1988,8 @@ COMPATIBLE_IOCTL(TUNSETGROUP)
 COMPATIBLE_IOCTL(TUNGETFEATURES)
 COMPATIBLE_IOCTL(TUNSETOFFLOAD)
 COMPATIBLE_IOCTL(TUNSETTXFILTER)
+COMPATIBLE_IOCTL(TUNGETSNDBUF)
+COMPATIBLE_IOCTL(TUNSETSNDBUF)
 /* Big V */
 COMPATIBLE_IOCTL(VT_SETMODE)
 COMPATIBLE_IOCTL(VT_GETMODE)
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 8529f57..049d6c9 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -46,6 +46,8 @@
 #define TUNSETOFFLOAD  _IOW('T', 208, unsigned int)
 #define TUNSETTXFILTER _IOW('T', 209, unsigned int)
 #define TUNGETIFF      _IOR('T', 210, unsigned int)
+#define TUNGETSNDBUF   _IOR('T', 211, int)
+#define TUNSETSNDBUF   _IOW('T', 212, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
