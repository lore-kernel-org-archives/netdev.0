From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 09:42:13 +0300
Message-ID: <20130516064213.GA26995@redhat.com>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au>
	<1368579583-13097-1-git-send-email-asias@redhat.com>
	<8761yk254u.fsf@rustcorp.com.au>
	<1368657450.6899.29.camel@haakon3.risingtidesystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	Randy Dunlap <rdunlap@infradead.org>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, linux-next@vger.kernel.org
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1368657450.6899.29.camel@haakon3.risingtidesystems.com>
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

On Wed, May 15, 2013 at 03:37:30PM -0700, Nicholas A. Bellinger wrote:
> On Wed, 2013-05-15 at 14:47 +0930, Rusty Russell wrote:
> > Asias He <asias@redhat.com> writes:
> > > scsi.c includes vhost.c which uses memcpy_fromiovec.
> > >
> > > This patch fixes this build failure.
> > >
> > >    From Randy Dunlap:
> > >    '''
> > >    on x86_64:
> > >
> > >    ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> > >
> > >    It needs to depend on NET since net/core/ provides that function.
> > >    '''
> > 
> > Proper fix please.
> > 
> > Though I can't see why you thought this was a good idea.  Nonetheless, I
> > shan't highlight why: I have far too much respect for your intellects
> > and abilities.
> > 
> > No, don't thank me!
> 
> Hi Rusty & Asias,
> 
> I assume you mean something like the following patch to allow kbuild to
> work when VHOST_NET + VHOST_SCSI are both enabled and sharing vhost.o,
> yes..?
> 
> Also included is dropping the now unnecessary vhost.c include, and
> allowing vhost_work_flush() to be accessed externally as scsi.c
> currently requires.
> 
> MST, care to pick this up..?
> 
> --nab

We'll do this for 3.11, 3.10 is bugfixes only now.

> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> index 8b9226d..016387f 100644
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -1,3 +1,6 @@
> +config VHOST
> +       tristate
> +
>  config VHOST_NET
>         tristate "Host kernel accelerator for virtio net"
>         depends on NET && EVENTFD && (TUN || !TUN) && (MACVTAP || !MACVTAP)
> @@ -12,7 +15,7 @@ config VHOST_NET
>  
>  config VHOST_SCSI
>         tristate "VHOST_SCSI TCM fabric driver"
> -       depends on TARGET_CORE && EVENTFD && m
> +       depends on NET && EVENTFD && TARGET_CORE
>         select VHOST_RING
>         default n
>         ---help---
> diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
> index 654e9afb..e5b5f0b 100644
> --- a/drivers/vhost/Makefile
> +++ b/drivers/vhost/Makefile
> @@ -1,7 +1,9 @@
> +obj-$(CONFIG_VHOST) += vhost.o
> +
>  obj-$(CONFIG_VHOST_NET) += vhost_net.o
> -vhost_net-y := vhost.o net.o
> +vhost_net-objs := net.o
>  
>  obj-$(CONFIG_VHOST_SCSI) += vhost_scsi.o
> -vhost_scsi-y := scsi.o
> +vhost_scsi-objs := scsi.o
>  
>  obj-$(CONFIG_VHOST_RING) += vringh.o
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index 7014202..b5836a2 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -49,7 +49,6 @@
>  #include <linux/llist.h>
>  #include <linux/bitmap.h>
>  
> -#include "vhost.c"
>  #include "vhost.h"
>  
>  #define TCM_VHOST_VERSION  "v0.1"
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index beee7f5..8cd1562 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -123,7 +123,7 @@ static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
>         return left <= 0;
>  }
>  
> -static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
> +void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
>  {
>         unsigned seq;
>         int flushing;
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index a7ad635..50ee396 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -44,6 +44,7 @@ void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
>                      unsigned long mask, struct vhost_dev *dev);
>  int vhost_poll_start(struct vhost_poll *poll, struct file *file);
>  void vhost_poll_stop(struct vhost_poll *poll);
> +void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work);
>  void vhost_poll_flush(struct vhost_poll *poll);
>  void vhost_poll_queue(struct vhost_poll *poll);
> 
