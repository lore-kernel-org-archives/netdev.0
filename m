From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCHv3 6/6] tun: experimental zero copy tx support
Date: Mon, 04 Jun 2012 12:48:17 +0800
Message-ID: <4FCC3E11.7010006@redhat.com>
References: <cover.1338735323.git.mst@redhat.com> <5ace2b9c3f15259cdf29af03f9231faac673e719.1338735323.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net, Ian Campbell <Ian.Campbell@citrix.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5ace2b9c3f15259cdf29af03f9231faac673e719.1338735323.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/13/2012 08:34 PM, Michael S. Tsirkin wrote:
> Let vhost-net utilize zero copy tx when used with tun.
>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> ---
>   drivers/net/tun.c | 146 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 134 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index fe5cd2f3..74d7e5e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -100,6 +100,8 @@ do {								\
>   } while (0)
>   #endif
>
> +#define GOODCOPY_LEN 128
> +
>   #define FLT_EXACT_COUNT 8
>   struct tap_filter {
>   	unsigned int    count;    /* Number of addrs. Zero means disabled */
> @@ -602,19 +604,100 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
>   	return skb;
>   }
>
> +/* set skb frags from iovec, this can move to core network code for reuse */
> +static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
> +				  int offset, size_t count)
> +{
> +	int len = iov_length(from, count) - offset;
> +	int copy = skb_headlen(skb);
> +	int size, offset1 = 0;
> +	int i = 0;
> +
> +	/* Skip over from offset */
> +	while (count&&  (offset>= from->iov_len)) {
> +		offset -= from->iov_len;
> +		++from;
> +		--count;
> +	}
> +
> +	/* copy up to skb headlen */
> +	while (count&&  (copy>  0)) {
> +		size = min_t(unsigned int, copy, from->iov_len - offset);
> +		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
> +				   size))
> +			return -EFAULT;
> +		if (copy>  size) {
> +			++from;
> +			--count;
> +			offset = 0;
> +		} else
> +			offset += size;
> +		copy -= size;
> +		offset1 += size;
> +	}
> +
> +	if (len == offset1)
> +		return 0;
> +
> +	while (count--) {
> +		struct page *page[MAX_SKB_FRAGS];
> +		int num_pages;
> +		unsigned long base;
> +		unsigned long truesize;
> +
> +		len = from->iov_len - offset;
> +		if (!len) {
> +			offset = 0;
> +			++from;
> +			continue;
> +		}
> +		base = (unsigned long)from->iov_base + offset;
> +		size = ((base&  ~PAGE_MASK) + len + ~PAGE_MASK)>>  PAGE_SHIFT;
> +		if (i + size>  MAX_SKB_FRAGS)
> +			return -EMSGSIZE;
> +		num_pages = get_user_pages_fast(base, size, 0,&page[i]);
> +		if (num_pages != size) {
> +			for (i = 0; i<  num_pages; i++)
> +				put_page(page[i]);
> +			return -EFAULT;
> +		}
> +		truesize = size * PAGE_SIZE;
> +		skb->data_len += len;
> +		skb->len += len;
> +		skb->truesize += truesize;
> +		atomic_add(truesize,&skb->sk->sk_wmem_alloc);
> +		while (len) {
> +			int off = base&  ~PAGE_MASK;
> +			int size = min_t(int, len, PAGE_SIZE - off);
> +			__skb_fill_page_desc(skb, i, page[i], off, size);
> +			skb_shinfo(skb)->nr_frags++;
> +			/* increase sk_wmem_alloc */
> +			base += size;
> +			len -= size;
> +			i++;
> +		}
> +		offset = 0;
> +		++from;
> +	}
> +	return 0;
> +}
> +
>   /* Get packet from user space buffer */
> -static ssize_t tun_get_user(struct tun_struct *tun,
> -			    const struct iovec *iv, size_t count,
> -			    int noblock)
> +static ssize_t tun_get_user(struct tun_struct *tun, void *msg_control,
> +			    const struct iovec *iv, size_t total_len,
> +			    size_t count, int noblock)
>   {

Looks like V2 uses count as the number of vectors and V3 correct this, 
so does V3 still have any issue during test?
>   	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
>   	struct sk_buff *skb;
> -	size_t len = count, align = NET_SKB_PAD;
> +	size_t len = total_len, align = NET_SKB_PAD;
>   	struct virtio_net_hdr gso = { 0 };
>   	int offset = 0;
> +	int copylen;
> +	bool zerocopy = false;
> +	int err;
>
>   	if (!(tun->flags&  TUN_NO_PI)) {
> -		if ((len -= sizeof(pi))>  count)
> +		if ((len -= sizeof(pi))>  total_len)
>   			return -EINVAL;
>
>   		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
> @@ -623,7 +706,7 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>   	}
>
>   	if (tun->flags&  TUN_VNET_HDR) {
> -		if ((len -= tun->vnet_hdr_sz)>  count)
> +		if ((len -= tun->vnet_hdr_sz)>  total_len)
>   			return -EINVAL;
>
>   		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
> @@ -645,14 +728,46 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>   			return -EINVAL;
>   	}
>   

Add a check of UIO_MAXIOV like macvtap? Other looks good to me.
Thanks.
> -	skb = tun_alloc_skb(tun, align, len, gso.hdr_len, noblock);
> +	if (msg_control)
> +		zerocopy = true;
> +
> +	if (zerocopy) {
> +		/* Userspace may produce vectors with count greater than
> +		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
> +		 * to let the rest of data to be fit in the frags.
> +		 */
> +		if (count>  MAX_SKB_FRAGS) {
> +			copylen = iov_length(iv, count - MAX_SKB_FRAGS);
> +			if (copylen<  offset)
> +				copylen = 0;
> +			else
> +				copylen -= offset;
> +		} else
> +				copylen = 0;
> +		/* There are 256 bytes to be copied in skb, so there is enough
> +		 * room for skb expand head in case it is used.
> +		 * The rest of the buffer is mapped from userspace.
> +		 */
> +		if (copylen<  gso.hdr_len)
> +			copylen = gso.hdr_len;
> +		if (!copylen)
> +			copylen = GOODCOPY_LEN;
> +	} else
> +		copylen = len;
> +
> +	skb = tun_alloc_skb(tun, align, copylen, gso.hdr_len, noblock);
>   	if (IS_ERR(skb)) {
>   		if (PTR_ERR(skb) != -EAGAIN)
>   			tun->dev->stats.rx_dropped++;
>   		return PTR_ERR(skb);
>   	}
>
> -	if (skb_copy_datagram_from_iovec(skb, 0, iv, offset, len)) {
> +	if (zerocopy)
> +		err = zerocopy_sg_from_iovec(skb, iv, offset, count);
> +	else
> +		err = skb_copy_datagram_from_iovec(skb, 0, iv, offset, len);
> +
> +	if (err) {
>   		tun->dev->stats.rx_dropped++;
>   		kfree_skb(skb);
>   		return -EFAULT;
> @@ -726,12 +841,18 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>   		skb_shinfo(skb)->gso_segs = 0;
>   	}
>
> +	/* copy skb_ubuf_info for callback when skb has no error */
> +	if (zerocopy) {
> +		skb_shinfo(skb)->destructor_arg = msg_control;
> +		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +	}
> +
>   	netif_rx_ni(skb);
>
>   	tun->dev->stats.rx_packets++;
>   	tun->dev->stats.rx_bytes += len;
>
> -	return count;
> +	return total_len;
>   }
>
>   static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
> @@ -746,7 +867,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
>
>   	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
>
> -	result = tun_get_user(tun, iv, iov_length(iv, count),
> +	result = tun_get_user(tun, NULL, iv, iov_length(iv, count), count,
>   			      file->f_flags&  O_NONBLOCK);
>
>   	tun_put(tun);
> @@ -960,8 +1081,8 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
>   		       struct msghdr *m, size_t total_len)
>   {
>   	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
> -	return tun_get_user(tun, m->msg_iov, total_len,
> -			    m->msg_flags&  MSG_DONTWAIT);
> +	return tun_get_user(tun, m->msg_control, m->msg_iov, total_len,
> +			    m->msg_iovlen, m->msg_flags&  MSG_DONTWAIT);
>   }
>
>   static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
> @@ -1130,6 +1251,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>   		sock_init_data(&tun->socket, sk);
>   		sk->sk_write_space = tun_sock_write_space;
>   		sk->sk_sndbuf = INT_MAX;
> +		sock_set_flag(sk, SOCK_ZEROCOPY);
>
>   		tun_sk(sk)->tun = tun;
>
