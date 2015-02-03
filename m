From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 18/18] vhost: vhost_scsi_handle_vq() should just use
 copy_from_user()
Date: Tue, 3 Feb 2015 11:05:14 +0200
Message-ID: <20150203090514.GC2830@redhat.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-18-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>, kvm@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbbBCJFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 04:05:20 -0500
Content-Disposition: inline
In-Reply-To: <1422863977-17668-18-git-send-email-viro@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 07:59:37AM +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> it has just verified that it asks no more than the length of the
> first segment of iovec.
> 
> And with that the last user of stuff in lib/iovec.c is gone.
> RIP.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Nicholas A. Bellinger <nab@linux-iscsi.org>
> Cc: kvm@vger.kernel.org
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

BTW it should really be __copy_from_user since the iovec
is pre-validated by vhost core.

Still Nicholas is rewriting it all anyway, so not worth the
time to optimize it, so

Acked-by: Michael S. Tsirkin <mst@redhat.com>

But, can you pls copy virtualization@lists.linux-foundation.org ?
I think some guys working on virtio might only hang out there.

> ---
>  drivers/vhost/scsi.c |  2 +-
>  include/linux/uio.h  |  2 --
>  lib/Makefile         |  2 +-
>  lib/iovec.c          | 36 ------------------------------------
>  4 files changed, 2 insertions(+), 40 deletions(-)
>  delete mode 100644 lib/iovec.c
> 
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index d695b16..dc78d87 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1079,7 +1079,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
>  			       req_size, vq->iov[0].iov_len);
>  			break;
>  		}
> -		ret = memcpy_fromiovecend(req, &vq->iov[0], 0, req_size);
> +		ret = copy_from_user(req, vq->iov[0].iov_base, req_size);
>  		if (unlikely(ret)) {
>  			vq_err(vq, "Faulted on virtio_scsi_cmd_req\n");
>  			break;
> diff --git a/include/linux/uio.h b/include/linux/uio.h
> index 02bd8a9..3e0cb4e 100644
> --- a/include/linux/uio.h
> +++ b/include/linux/uio.h
> @@ -135,6 +135,4 @@ static inline void iov_iter_reexpand(struct iov_iter *i, size_t count)
>  size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
>  size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
>  
> -int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
> -			int offset, int len);
>  #endif
> diff --git a/lib/Makefile b/lib/Makefile
> index 3c3b30b..1071d06 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -24,7 +24,7 @@ obj-y	+= lockref.o
>  
>  obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
>  	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
> -	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
> +	 gcd.o lcm.o list_sort.o uuid.o flex_array.o clz_ctz.o \
>  	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
>  	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
>  obj-y += string_helpers.o
> diff --git a/lib/iovec.c b/lib/iovec.c
> deleted file mode 100644
> index d8f17a9..0000000
> --- a/lib/iovec.c
> +++ /dev/null
> @@ -1,36 +0,0 @@
> -#include <linux/uaccess.h>
> -#include <linux/export.h>
> -#include <linux/uio.h>
> -
> -/*
> - *	Copy iovec to kernel. Returns -EFAULT on error.
> - */
> -
> -int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
> -			int offset, int len)
> -{
> -	/* No data? Done! */
> -	if (len == 0)
> -		return 0;
> -
> -	/* Skip over the finished iovecs */
> -	while (offset >= iov->iov_len) {
> -		offset -= iov->iov_len;
> -		iov++;
> -	}
> -
> -	while (len > 0) {
> -		u8 __user *base = iov->iov_base + offset;
> -		int copy = min_t(unsigned int, len, iov->iov_len - offset);
> -
> -		offset = 0;
> -		if (copy_from_user(kdata, base, copy))
> -			return -EFAULT;
> -		len -= copy;
> -		kdata += copy;
> -		iov++;
> -	}
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL(memcpy_fromiovecend);
> -- 
> 2.1.4
