From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 17/18] vhost: don't bother copying iovecs in
 handle_rx(), kill memcpy_toiovecend()
Date: Tue, 3 Feb 2015 11:13:32 +0200
Message-ID: <20150203091332.GD2830@redhat.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-17-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422863977-17668-17-git-send-email-viro@ZenIV.linux.org.uk>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 02, 2015 at 07:59:36AM +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---

So this made me notice a bug in vhost introduced in 3.19.
I sent a patch for that, this one will have to be
rebased on top. Otherwise:

Acked-by: Michael S. Tsirkin <mst@redhat.com>

But, can you pls copy virtualization@lists.linux-foundation.org ?
I think some guys working on virtio might only hang out there.



>  drivers/vhost/net.c | 79 ++++++++++++++---------------------------------------
>  include/linux/uio.h |  3 --
>  lib/iovec.c         | 26 ------------------
>  3 files changed, 20 insertions(+), 88 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index d86cc9b..73c0ebf 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -84,10 +84,6 @@ struct vhost_net_ubuf_ref {
>  
>  struct vhost_net_virtqueue {
>  	struct vhost_virtqueue vq;
> -	/* hdr is used to store the virtio header.
> -	 * Since each iovec has >= 1 byte length, we never need more than
> -	 * header length entries to store the header. */
> -	struct iovec hdr[sizeof(struct virtio_net_hdr_mrg_rxbuf)];
>  	size_t vhost_hlen;
>  	size_t sock_hlen;
>  	/* vhost zerocopy support fields below: */
> @@ -235,44 +231,6 @@ static bool vhost_sock_zcopy(struct socket *sock)
>  		sock_flag(sock->sk, SOCK_ZEROCOPY);
>  }
>  
> -/* Pop first len bytes from iovec. Return number of segments used. */
> -static int move_iovec_hdr(struct iovec *from, struct iovec *to,
> -			  size_t len, int iov_count)
> -{
> -	int seg = 0;
> -	size_t size;
> -
> -	while (len && seg < iov_count) {
> -		size = min(from->iov_len, len);
> -		to->iov_base = from->iov_base;
> -		to->iov_len = size;
> -		from->iov_len -= size;
> -		from->iov_base += size;
> -		len -= size;
> -		++from;
> -		++to;
> -		++seg;
> -	}
> -	return seg;
> -}
> -/* Copy iovec entries for len bytes from iovec. */
> -static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
> -			   size_t len, int iovcount)
> -{
> -	int seg = 0;
> -	size_t size;
> -
> -	while (len && seg < iovcount) {
> -		size = min(from->iov_len, len);
> -		to->iov_base = from->iov_base;
> -		to->iov_len = size;
> -		len -= size;
> -		++from;
> -		++to;
> -		++seg;
> -	}
> -}
> -
>  /* In case of DMA done not in order in lower device driver for some reason.
>   * upend_idx is used to track end of used idx, done_idx is used to track head
>   * of used idx. Once lower device DMA done contiguously, we will signal KVM
> @@ -570,9 +528,9 @@ static void handle_rx(struct vhost_net *net)
>  		.msg_controllen = 0,
>  		.msg_flags = MSG_DONTWAIT,
>  	};
> -	struct virtio_net_hdr_mrg_rxbuf hdr = {
> -		.hdr.flags = 0,
> -		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
> +	struct virtio_net_hdr hdr = {
> +		.flags = 0,
> +		.gso_type = VIRTIO_NET_HDR_GSO_NONE
>  	};
>  	size_t total_len = 0;
>  	int err, mergeable;
> @@ -580,6 +538,7 @@ static void handle_rx(struct vhost_net *net)
>  	size_t vhost_hlen, sock_hlen;
>  	size_t vhost_len, sock_len;
>  	struct socket *sock;
> +	struct iov_iter fixup;
>  
>  	mutex_lock(&vq->mutex);
>  	sock = vq->private_data;
> @@ -624,14 +583,17 @@ static void handle_rx(struct vhost_net *net)
>  			break;
>  		}
>  		/* We don't need to be notified again. */
> -		if (unlikely((vhost_hlen)))
> -			/* Skip header. TODO: support TSO. */
> -			move_iovec_hdr(vq->iov, nvq->hdr, vhost_hlen, in);
> -		else
> -			/* Copy the header for use in VIRTIO_NET_F_MRG_RXBUF:
> -			 * needed because recvmsg can modify msg_iov. */
> -			copy_iovec_hdr(vq->iov, nvq->hdr, sock_hlen, in);
> -		iov_iter_init(&msg.msg_iter, READ, vq->iov, in, sock_len);
> +		iov_iter_init(&msg.msg_iter, READ, vq->iov, in, vhost_len);
> +		fixup = msg.msg_iter;
> +		if (unlikely((vhost_hlen))) {
> +			/* We will supply the header ourselves
> +			 * TODO: support TSO. */
> +			iov_iter_advance(&msg.msg_iter, vhost_hlen);
> +		} else {
> +			/* It'll come from socket; we'll need to patch
> +			 * ->num_buffers over if VIRTIO_NET_F_MRG_RXBUF */
> +			iov_iter_advance(&fixup, sizeof(hdr));
> +		}
>  		err = sock->ops->recvmsg(NULL, sock, &msg,
>  					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
>  		/* Userspace might have consumed the packet meanwhile:
> @@ -643,18 +605,17 @@ static void handle_rx(struct vhost_net *net)
>  			vhost_discard_vq_desc(vq, headcount);
>  			continue;
>  		}
> +		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
>  		if (unlikely(vhost_hlen) &&
> -		    memcpy_toiovecend(nvq->hdr, (unsigned char *)&hdr, 0,
> -				      vhost_hlen)) {
> +		    copy_to_iter(&hdr, sizeof(hdr), &fixup) != sizeof(hdr)) {

BTW, all iovecs are pre-validated in vhost core.
I'd like to add __copy_to_iter and __copy_from_iter that are the same
but skip the extra checks, and use that everywhere in vhost (shouln't
matter here specifically, because we don't hit this path).
>From experience, this helps gcc optimize the code resulting
in measureable performance gains.
Comments? Will you be ok with a patch like this?


>  			vq_err(vq, "Unable to write vnet_hdr at addr %p\n",
>  			       vq->iov->iov_base);
>  			break;
>  		}
> -		/* TODO: Should check and handle checksum. */
> +		/* Supply (or replace) ->num_buffers if VIRTIO_NET_F_MRG_RXBUF
> +		 * TODO: Should check and handle checksum. */
>  		if (likely(mergeable) &&
> -		    memcpy_toiovecend(nvq->hdr, (unsigned char *)&headcount,
> -				      offsetof(typeof(hdr), num_buffers),
> -				      sizeof hdr.num_buffers)) {
> +		    copy_to_iter(&headcount, 2, &fixup) != 2) {
>  			vq_err(vq, "Failed num_buffers write");
>  			vhost_discard_vq_desc(vq, headcount);
>  			break;

This made me notice we have a bug: native-endianness integer is copied out to guest.
I sent a patch, hope it'll make it in 3.19.


> diff --git a/include/linux/uio.h b/include/linux/uio.h
> index af3439f..02bd8a9 100644
> --- a/include/linux/uio.h
> +++ b/include/linux/uio.h
> @@ -137,7 +137,4 @@ size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct io
>  
>  int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
>  			int offset, int len);
> -int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
> -		      int offset, int len);
> -
>  #endif
> diff --git a/lib/iovec.c b/lib/iovec.c
> index 4a90875..d8f17a9 100644
> --- a/lib/iovec.c
> +++ b/lib/iovec.c
> @@ -3,32 +3,6 @@
>  #include <linux/uio.h>
>  
>  /*
> - *	Copy kernel to iovec. Returns -EFAULT on error.
> - */
> -
> -int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
> -		      int offset, int len)
> -{
> -	int copy;
> -	for (; len > 0; ++iov) {
> -		/* Skip over the finished iovecs */
> -		if (unlikely(offset >= iov->iov_len)) {
> -			offset -= iov->iov_len;
> -			continue;
> -		}
> -		copy = min_t(unsigned int, iov->iov_len - offset, len);
> -		if (copy_to_user(iov->iov_base + offset, kdata, copy))
> -			return -EFAULT;
> -		offset = 0;
> -		kdata += copy;
> -		len -= copy;
> -	}
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL(memcpy_toiovecend);
> -
> -/*
>   *	Copy iovec to kernel. Returns -EFAULT on error.
>   */
>  
> -- 
> 2.1.4
