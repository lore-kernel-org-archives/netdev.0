From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH 13/29] drivers, media: convert
 vb2_vmarea_handler.refcount from atomic_t to refcount_t
Date: Tue, 7 Mar 2017 10:50:05 +0200
Message-ID: <20170307085005.GH3220@valkosipuli.retiisi.org.uk>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-14-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
 fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
 open-iscsi@googlegroups.com, linux-media@vger.kernel.org,
 Kees Cook <keescook@chromium.org>, linux-raid@vger.kernel.org,
 linux-bcache@vger.kernel.org, Hans Liljestrand <ishkamiel@gmail.com>,
 David Windsor <dwindsor@gmail.com>, gregkh@linuxfoundation.org,
 linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, devel@linuxdriverproject.org
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1488810076-3754-14-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hi Elena,

On Mon, Mar 06, 2017 at 04:21:00PM +0200, Elena Reshetova wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
>  drivers/media/v4l2-core/videobuf2-memops.c | 6 +++---
>  include/media/videobuf2-memops.h           | 3 ++-
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf2-memops.c b/drivers/media/v4l2-core/videobuf2-memops.c
> index 1cd322e..4bb8424 100644
> --- a/drivers/media/v4l2-core/videobuf2-memops.c
> +++ b/drivers/media/v4l2-core/videobuf2-memops.c
> @@ -96,10 +96,10 @@ static void vb2_common_vm_open(struct vm_area_struct *vma)
>  	struct vb2_vmarea_handler *h = vma->vm_private_data;
>  
>  	pr_debug("%s: %p, refcount: %d, vma: %08lx-%08lx\n",
> -	       __func__, h, atomic_read(h->refcount), vma->vm_start,
> +	       __func__, h, refcount_read(h->refcount), vma->vm_start,
>  	       vma->vm_end);
>  
> -	atomic_inc(h->refcount);
> +	refcount_inc(h->refcount);
>  }
>  
>  /**
> @@ -114,7 +114,7 @@ static void vb2_common_vm_close(struct vm_area_struct *vma)
>  	struct vb2_vmarea_handler *h = vma->vm_private_data;
>  
>  	pr_debug("%s: %p, refcount: %d, vma: %08lx-%08lx\n",
> -	       __func__, h, atomic_read(h->refcount), vma->vm_start,
> +	       __func__, h, refcount_read(h->refcount), vma->vm_start,
>  	       vma->vm_end);
>  
>  	h->put(h->arg);
> diff --git a/include/media/videobuf2-memops.h b/include/media/videobuf2-memops.h
> index 36565c7a..a6ed091 100644
> --- a/include/media/videobuf2-memops.h
> +++ b/include/media/videobuf2-memops.h
> @@ -16,6 +16,7 @@
>  
>  #include <media/videobuf2-v4l2.h>
>  #include <linux/mm.h>
> +#include <linux/refcount.h>
>  
>  /**
>   * struct vb2_vmarea_handler - common vma refcount tracking handler
> @@ -25,7 +26,7 @@
>   * @arg:	argument for @put callback
>   */
>  struct vb2_vmarea_handler {
> -	atomic_t		*refcount;
> +	refcount_t		*refcount;

This is a pointer to refcount, not refcount itself. The refcount is part of
a memory type specific struct, the types that you change in the following
three patches. I guess it would still compile and work as separate patches
but you'd sure get warnings at least.

How about merging this and the three following patches that change the memop
refcount types?

>  	void			(*put)(void *arg);
>  	void			*arg;
>  };

-- 
Kind regards,

Sakari Ailus
e-mail: sakari.ailus@iki.fi	XMPP: sailus@retiisi.org.uk
