From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 12:35:44 +0800
Message-ID: <20130516043544.GA32099@hj.localdomain>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au>
	<1368579583-13097-1-git-send-email-asias@redhat.com>
	<8761yk254u.fsf@rustcorp.com.au>
	<20130516020848.GB23441@hj.localdomain>
	<87d2sra97h.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, linux-next@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87d2sra97h.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, May 16, 2013 at 01:04:58PM +0930, Rusty Russell wrote:
> Asias He <asias@redhat.com> writes:
> > On Wed, May 15, 2013 at 02:47:53PM +0930, Rusty Russell wrote:
> >> Asias He <asias@redhat.com> writes:
> >> > scsi.c includes vhost.c which uses memcpy_fromiovec.
> >> >
> >> > This patch fixes this build failure.
> >> >
> >> >    From Randy Dunlap:
> >> >    '''
> >> >    on x86_64:
> >> >
> >> >    ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> >> >
> >> >    It needs to depend on NET since net/core/ provides that function.
> >> >    '''
> >> 
> >> Proper fix please.
> >
> > --verbose please ;-)
> >
> > Making VHOST_SCSI depends on NET looks weird but this is because vhost
> > core depends on it. A bunch of patches are cleaning this up. Since MST
> > wanted do the vhost.ko split up in 3.11, plus your WIP vringh work, so I
> > wanted the fix for 3.10 as minimum as possible.
> 
> If this isn't the only symbol causing the problem, then this should be
> mentioned in the changelog.  If it is, it should be fixed: we have
> plenty of time for that.
>
> Either way, your commit message or the commit itself needs to justify
> it!

memcpy_fromiovec is the only one causing the problem.

> 
> > Other users are using memcpy_fromiovec and friends outside net. It seems
> > a good idea to put it in a util library. e.g.  crypto/algif_skcipher.c
> > which also depends on NET for it.
> >
> >> Though I can't see why you thought this was a good idea.  Nonetheless, I
> >> shan't highlight why: I have far too much respect for your intellects
> >> and abilities.
> >> 
> >> No, don't thank me!
> >
> > Interesting.
> 
> Heh... I originally wrote an explanation, then found it a bit insulting:
> I knew I didn't need to tell you :)

;-)

> How's this?

Looks good and the commit log is more informative. 

The

   memcpy_toiovec
   memcpy_toiovecend
   memcpy_fromiovec
   memcpy_fromiovecend

are all not net specific. 

How about move them all to lib/ ?

Also need to make sure all the callers have uio.h included.  e.g.
drivers/dma/iovlock.c

> From: Rusty Russell <rusty@rustcorp.com.au>
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

-- 
Asias
