From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 21:42:33 -0700
Message-ID: <5195B539.7020705@infradead.org>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au> <1368579583-13097-1-git-send-email-asias@redhat.com> <8761yk254u.fsf@rustcorp.com.au> <20130516020848.GB23441@hj.localdomain> <87d2sra97h.fsf@rustcorp.com.au> <1368676505.2194.47.camel@joe-AO722> <878v3ea3v4.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Asias He <asias@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <878v3ea3v4.fsf@rustcorp.com.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/16/13 16:42, Rusty Russell wrote:
> Joe Perches <joe@perches.com> writes:
>> On Thu, 2013-05-16 at 13:04 +0930, Rusty Russell wrote:
>>> Asias He <asias@redhat.com> writes:
>>>> On Wed, May 15, 2013 at 02:47:53PM +0930, Rusty Russell wrote:
>> []
>>>> Other users are using memcpy_fromiovec and friends outside net. It seems
>>>> a good idea to put it in a util library. e.g.  crypto/algif_skcipher.c
>>>> which also depends on NET for it.
>>
>> []
>>> Subject: Hoist memcpy_fromiovec into lib/
>>
>> You'll need the "friends" memcpy_toiovec too.
>>
>> $ git grep -E \bmemcpy\w+iovec\w*"
>> crypto/algif_hash.c:    err = memcpy_toiovec(msg->msg_iov, ctx->result, len);
>> crypto/algif_skcipher.c:                        err = memcpy_fromiovec(page_address(sg_page(sg)) +
>> crypto/algif_skcipher.c:                        err = memcpy_fromiovec(page_address(sg_page(sg + i)),
>> drivers/dma/iovlock.c:#include <net/tcp.h> /* for memcpy_toiovec */
>> drivers/dma/iovlock.c:          return memcpy_toiovec(iov, kdata, len);
>> drivers/dma/iovlock.c:          err = memcpy_toiovec(iov, vaddr + offset, len);
>> drivers/isdn/mISDN/socket.c:    if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
>> drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err = memcpy_fromiovec((u8 *)va + page_o
>> drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err = memcpy_toiovec(iov, (u8 *)va + pag
> 
> Fascinating.  These all indirectly depend on NET, so there's no problem
> at the moment.  But it is a bit weird...
> 
> crypto/algif_hash.c: depends on CRYPTO_USER_API_HASH -> NET
> crypto/algif_skcipher.c: depends on CRYPTO_USER_API_SKCIPHER -> NET
> drivers/dma/iovlock.c: depends on NET_DMA -> NET
> drivers/isdn/mISDN/socket.c: depends on MISDN -> ISDN -> NET
> drivers/misc/vmw_vmci/vmci_queue_pair.c: depends on VMCI -> NET
> 
> Patch welcome.
> 
> Meanwhile, to avoid more bikeshedding I've put the patch I posted with
> all acks in my fixes branch.  One cycle through linux-next, then
> straight to Linus.
> 

I agree with whoever suggested that more be moved into /lib.
E.g., drivers/misc/vmw_vmci/Kconfig uses "depends on NET" because the
code there uses both memcpy_toiovec() and memcpy_fromiovec().
See commit ID 6d4f0139d642c45411a47879325891ce2a7c164a.


> Subject: Hoist memcpy_fromiovec into lib/
> 
> ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> 
> That function is only present with CONFIG_NET.  Turns out that
> crypto/algif_skcipher.c also uses that outside net, but it actually
> needs sockets anyway.
> 
> socket.h already include uio.h, so no callers need updating.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Acked-by: David S. Miller <davem@davemloft.net>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 428c37a..7266775 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -305,7 +305,6 @@ struct ucred {
>  
>  extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
>  
> -extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
>  extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
>  			       int offset, int len);
>  extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
> diff --git a/include/linux/uio.h b/include/linux/uio.h
> index 629aaf5..21628d3 100644
> --- a/include/linux/uio.h
> +++ b/include/linux/uio.h
> @@ -35,4 +35,6 @@ static inline size_t iov_length(const struct iovec *iov, unsigned long nr_segs)
>  }
>  
>  unsigned long iov_shorten(struct iovec *iov, unsigned long nr_segs, size_t to);
> +
> +int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
>  #endif
> diff --git a/lib/Makefile b/lib/Makefile
> index e9c52e1..2377211 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -9,7 +9,7 @@ endif
>  
>  lib-y := ctype.o string.o vsprintf.o cmdline.o \
>  	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
> -	 idr.o int_sqrt.o extable.o \
> +	 idr.o int_sqrt.o extable.o iovec.o \
>  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
>  	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
>  	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
> diff --git a/lib/iovec.c b/lib/iovec.c
> new file mode 100644
> index 0000000..632c5ea
> --- /dev/null
> +++ b/lib/iovec.c
> @@ -0,0 +1,29 @@
> +#include <linux/uaccess.h>
> +#include <linux/export.h>
> +#include <linux/uio.h>
> +
> +/*
> + *	Copy iovec to kernel. Returns -EFAULT on error.
> + *
> + *	Note: this modifies the original iovec.
> + */
> +
> +int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
> +{
> +	while (len > 0) {
> +		if (iov->iov_len) {
> +			int copy = min_t(unsigned int, len, iov->iov_len);
> +			if (copy_from_user(kdata, iov->iov_base, copy))
> +				return -EFAULT;
> +			len -= copy;
> +			kdata += copy;
> +			iov->iov_base += copy;
> +			iov->iov_len -= copy;
> +		}
> +		iov++;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(memcpy_fromiovec);
> +
> diff --git a/net/core/iovec.c b/net/core/iovec.c
> index 7e7aeb0..d81257f 100644
> --- a/net/core/iovec.c
> +++ b/net/core/iovec.c
> @@ -125,31 +125,6 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
>  EXPORT_SYMBOL(memcpy_toiovecend);
>  
>  /*
> - *	Copy iovec to kernel. Returns -EFAULT on error.
> - *
> - *	Note: this modifies the original iovec.
> - */
> -
> -int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
> -{
> -	while (len > 0) {
> -		if (iov->iov_len) {
> -			int copy = min_t(unsigned int, len, iov->iov_len);
> -			if (copy_from_user(kdata, iov->iov_base, copy))
> -				return -EFAULT;
> -			len -= copy;
> -			kdata += copy;
> -			iov->iov_base += copy;
> -			iov->iov_len -= copy;
> -		}
> -		iov++;
> -	}
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL(memcpy_fromiovec);
> -
> -/*
>   *	Copy iovec from kernel. Returns -EFAULT on error.
>   */
>  
> 


-- 
~Randy
