From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Tue, 3 Feb 2015 12:10:44 +0200
Message-ID: <20150203101044.GA5081@redhat.com>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
 <1416924151-28698-8-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416924151-28698-8-git-send-email-viro@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 02:02:22PM +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> allows to switch macvtap and tun from ->aio_write() to ->write_iter()
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/net/macvtap.c |   44 +++++++++++++++++++++-----------------------
>  drivers/net/tun.c     |   44 ++++++++++++++++++++++++--------------------
>  2 files changed, 45 insertions(+), 43 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 8f80045..22b4cf2 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -640,12 +640,12 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
>  
>  /* Get packet from user space buffer */
>  static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
> -				const struct iovec *iv, unsigned long total_len,
> -				size_t count, int noblock)
> +				struct iov_iter *from, int noblock)
>  {
>  	int good_linear = SKB_MAX_HEAD(NET_IP_ALIGN);
>  	struct sk_buff *skb;
>  	struct macvlan_dev *vlan;
> +	unsigned long total_len = iov_iter_count(from);
>  	unsigned long len = total_len;
>  	int err;
>  	struct virtio_net_hdr vnet_hdr = { 0 };
> @@ -653,6 +653,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  	int copylen = 0;
>  	bool zerocopy = false;
>  	size_t linear;
> +	ssize_t n;
>  
>  	if (q->flags & IFF_VNET_HDR) {
>  		vnet_hdr_len = q->vnet_hdr_sz;
> @@ -662,10 +663,11 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  			goto err;
>  		len -= vnet_hdr_len;
>  
> -		err = memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
> -					   sizeof(vnet_hdr));
> -		if (err < 0)
> +		err = -EFAULT;
> +		n = copy_from_iter(&vnet_hdr, sizeof(vnet_hdr), from);
> +		if (n != sizeof(vnet_hdr))
>  			goto err;
> +		iov_iter_advance(from, vnet_hdr_len - sizeof(vnet_hdr));
>  		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
>  		     vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
>  							vnet_hdr.hdr_len)
> @@ -680,17 +682,16 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  	if (unlikely(len < ETH_HLEN))
>  		goto err;
>  
> -	err = -EMSGSIZE;
> -	if (unlikely(count > UIO_MAXIOV))
> -		goto err;
> -
>  	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
> +		struct iov_iter i;
> +
>  		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
>  		if (copylen > good_linear)
>  			copylen = good_linear;
>  		linear = copylen;
> -		if (iov_pages(iv, vnet_hdr_len + copylen, count)
> -		    <= MAX_SKB_FRAGS)
> +		i = *from;
> +		iov_iter_advance(&i, copylen);
> +		if (iov_iter_npages(&i, INT_MAX) <= MAX_SKB_FRAGS)
>  			zerocopy = true;
>  	}
>  
> @@ -708,10 +709,9 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  		goto err;
>  
>  	if (zerocopy)
> -		err = zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
> +		err = zerocopy_sg_from_iter(skb, from);
>  	else {
> -		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
> -						   len);
> +		err = skb_copy_datagram_from_iter(skb, 0, from, len);
>  		if (!err && m && m->msg_control) {
>  			struct ubuf_info *uarg = m->msg_control;
>  			uarg->callback(uarg, false);
> @@ -764,16 +764,12 @@ err:
>  	return err;
>  }
>  
> -static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
> -				 unsigned long count, loff_t pos)
> +static ssize_t macvtap_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  {
>  	struct file *file = iocb->ki_filp;
> -	ssize_t result = -ENOLINK;
>  	struct macvtap_queue *q = file->private_data;
>  
> -	result = macvtap_get_user(q, NULL, iv, iov_length(iv, count), count,
> -				  file->f_flags & O_NONBLOCK);
> -	return result;
> +	return macvtap_get_user(q, NULL, from, file->f_flags & O_NONBLOCK);
>  }
>  
>  /* Put packet to the user space buffer */
> @@ -1081,8 +1077,9 @@ static const struct file_operations macvtap_fops = {
>  	.open		= macvtap_open,
>  	.release	= macvtap_release,
>  	.read		= new_sync_read,
> +	.write		= new_sync_write,
>  	.read_iter	= macvtap_read_iter,
> -	.aio_write	= macvtap_aio_write,
> +	.write_iter	= macvtap_write_iter,
>  	.poll		= macvtap_poll,
>  	.llseek		= no_llseek,
>  	.unlocked_ioctl	= macvtap_ioctl,
> @@ -1095,8 +1092,9 @@ static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
>  			   struct msghdr *m, size_t total_len)
>  {
>  	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
> -	return macvtap_get_user(q, m, m->msg_iov, total_len, m->msg_iovlen,
> -			    m->msg_flags & MSG_DONTWAIT);
> +	struct iov_iter from;
> +	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, total_len);
> +	return macvtap_get_user(q, m, &from, m->msg_flags & MSG_DONTWAIT);
>  }
>  
>  static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 405dfdf..4b743c6 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1012,28 +1012,29 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>  
>  /* Get packet from user space buffer */
>  static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
> -			    void *msg_control, const struct iovec *iv,
> -			    size_t total_len, size_t count, int noblock)
> +			    void *msg_control, struct iov_iter *from,
> +			    int noblock)
>  {
>  	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
>  	struct sk_buff *skb;
> +	size_t total_len = iov_iter_count(from);
>  	size_t len = total_len, align = NET_SKB_PAD, linear;
>  	struct virtio_net_hdr gso = { 0 };
>  	int good_linear;
> -	int offset = 0;
>  	int copylen;
>  	bool zerocopy = false;
>  	int err;
>  	u32 rxhash;
> +	ssize_t n;
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if (len < sizeof(pi))
>  			return -EINVAL;
>  		len -= sizeof(pi);
>  
> -		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
> +		n = copy_from_iter(&pi, sizeof(pi), from);
> +		if (n != sizeof(pi))
>  			return -EFAULT;
> -		offset += sizeof(pi);
>  	}
>  
>  	if (tun->flags & TUN_VNET_HDR) {
> @@ -1041,7 +1042,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  			return -EINVAL;
>  		len -= tun->vnet_hdr_sz;
>  
> -		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
> +		n = copy_from_iter(&gso, sizeof(gso), from);
> +		if (n != sizeof(gso))
>  			return -EFAULT;
>  
>  		if ((gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
> @@ -1050,7 +1052,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  
>  		if (gso.hdr_len > len)
>  			return -EINVAL;
> -		offset += tun->vnet_hdr_sz;
> +		iov_iter_advance(from, tun->vnet_hdr_sz);
>  	}
>  
>  	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {


Hmm does copy_from_iter actually modify the iovec?
If so, won't this break aio on tun/macvtap, by
reversing the effect of
commit 6f26c9a7555e5bcca3560919db9b852015077dae
    tun: fix tun_chr_aio_write so that aio works
?


Maybe we should change iovec_iter to avoid modifying the
underlying iovec?



> @@ -1063,6 +1065,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	good_linear = SKB_MAX_HEAD(align);
>  
>  	if (msg_control) {
> +		struct iov_iter i = *from;
> +
>  		/* There are 256 bytes to be copied in skb, so there is
>  		 * enough room for skb expand head in case it is used.
>  		 * The rest of the buffer is mapped from userspace.
> @@ -1071,7 +1075,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		if (copylen > good_linear)
>  			copylen = good_linear;
>  		linear = copylen;
> -		if (iov_pages(iv, offset + copylen, count) <= MAX_SKB_FRAGS)
> +		iov_iter_advance(&i, copylen);
> +		if (iov_iter_npages(&i, INT_MAX) <= MAX_SKB_FRAGS)
>  			zerocopy = true;
>  	}
>  
> @@ -1091,9 +1096,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	}
>  
>  	if (zerocopy)
> -		err = zerocopy_sg_from_iovec(skb, iv, offset, count);
> +		err = zerocopy_sg_from_iter(skb, from);
>  	else {
> -		err = skb_copy_datagram_from_iovec(skb, 0, iv, offset, len);
> +		err = skb_copy_datagram_from_iter(skb, 0, from, len);
>  		if (!err && msg_control) {
>  			struct ubuf_info *uarg = msg_control;
>  			uarg->callback(uarg, false);
> @@ -1207,8 +1212,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	return total_len;
>  }
>  
> -static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
> -			      unsigned long count, loff_t pos)
> +static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  {
>  	struct file *file = iocb->ki_filp;
>  	struct tun_struct *tun = tun_get(file);
> @@ -1218,10 +1222,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
>  	if (!tun)
>  		return -EBADFD;
>  
> -	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
> -
> -	result = tun_get_user(tun, tfile, NULL, iv, iov_length(iv, count),
> -			      count, file->f_flags & O_NONBLOCK);
> +	result = tun_get_user(tun, tfile, NULL, from, file->f_flags & O_NONBLOCK);
>  
>  	tun_put(tun);
>  	return result;
> @@ -1445,11 +1446,14 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
>  	int ret;
>  	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
>  	struct tun_struct *tun = __tun_get(tfile);
> +	struct iov_iter from;
>  
>  	if (!tun)
>  		return -EBADFD;
> -	ret = tun_get_user(tun, tfile, m->msg_control, m->msg_iov, total_len,
> -			   m->msg_iovlen, m->msg_flags & MSG_DONTWAIT);
> +
> +	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, total_len);
> +	ret = tun_get_user(tun, tfile, m->msg_control, &from,
> +			   m->msg_flags & MSG_DONTWAIT);
>  	tun_put(tun);
>  	return ret;
>  }
> @@ -2233,9 +2237,9 @@ static const struct file_operations tun_fops = {
>  	.owner	= THIS_MODULE,
>  	.llseek = no_llseek,
>  	.read  = new_sync_read,
> +	.write = new_sync_write,
>  	.read_iter  = tun_chr_read_iter,
> -	.write = do_sync_write,
> -	.aio_write = tun_chr_aio_write,
> +	.write_iter = tun_chr_write_iter,
>  	.poll	= tun_chr_poll,
>  	.unlocked_ioctl	= tun_chr_ioctl,
>  #ifdef CONFIG_COMPAT
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
