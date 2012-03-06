From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH 0001/001] xen: multi page ring support for block
 devices
Date: Tue, 06 Mar 2012 08:34:54 +0000
Message-ID: <4F55DA3E0200007800076916@nat28.tlf.novell.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
 <7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"Paul Durrant" <Paul.Durrant@citrix.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"lersek@redhat.com" <lersek@redhat.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"dgdegra@tycho.nsa.gov" <dgdegra@tycho.nsa.gov>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbarnes@virtuousgeek.o
To: "Santosh Jodh" <Santosh.Jodh@citrix.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 05.03.12 at 22:49, Santosh Jodh <Santosh.Jodh@citrix.com> wrote:

Could this be split up into 3 patches, for easier reviewing:
- one adjusting the xenbus interface to allow for multiple ring pages (and
  maybe even that one should be split into the backend and frontend
  related parts), syncing with the similar netback effort?
- one for the blkback changes
- one for the blkfront changes?

> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -122,8 +122,8 @@ static struct xen_blkif *xen_blkif_alloc(domid_t domid)
>         return blkif;
>  }
> 
> -static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
> -                        unsigned int evtchn)
> +static int xen_blkif_map(struct xen_blkif *blkif, int ring_ref[],

As you need to touch this anyway, can you please switch this to the
proper type (grant_ref_t) rather than using plain "int" (not just here)?

> +                        unsigned int ring_order, unsigned int evtchn)
>  {
>         int err;
> 
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -135,7 +139,7 @@ static DEFINE_SPINLOCK(minor_lock);
>  static int get_id_from_freelist(struct blkfront_info *info)
>  {
>         unsigned long free = info->shadow_free;
> -       BUG_ON(free >= BLK_RING_SIZE);
> +       BUG_ON(free >= BLK_MAX_RING_SIZE);

Wouldn't you better check against the actual limit here?

>         info->shadow_free = info->shadow[free].req.u.rw.id;
>         info->shadow[free].req.u.rw.id = 0x0fffffee; /* debug */
>         return free;
> @@ -698,16 +704,19 @@ static void blkif_free(struct blkfront_info *info, int suspend)
>         flush_work_sync(&info->work);
> 
>         /* Free resources associated with old device channel. */
> -       if (info->ring_ref != GRANT_INVALID_REF) {
> -               gnttab_end_foreign_access(info->ring_ref, 0,
> -                                         (unsigned long)info->ring.sring);
> -               info->ring_ref = GRANT_INVALID_REF;
> -               info->ring.sring = NULL;
> +       for (i = 0; i < (1 << info->ring_order); i++) {
> +               if (info->ring_ref[i] != GRANT_INVALID_REF) {
> +                       gnttab_end_foreign_access(info->ring_ref[i], 0, 0);
> +                       info->ring_ref[i] = GRANT_INVALID_REF;
> +               }
>         }
> +
> +       free_pages((unsigned long)info->ring.sring, info->ring_order);

No. The freeing must continue happen in gnttab_end_foreign_access()
(with the sole exception when a page was allocated but the grant
didn't get established), since it must be suppressed/delayed when the
grant is still in use (otherwise the kernel will die on the first re-use of
the page). I just happened to fix that problem at the end of last week
in the variant of the patch that we pulled into our tree.

Further, rather than doing a non-zero order allocation here, I'd
suggest allocating individual pages and vmap()-ing them.

> +       info->ring.sring = NULL;
> +
>         if (info->irq)
>                 unbind_from_irqhandler(info->irq, info);
>         info->evtchn = info->irq = 0;
> -
>  }
> 
>  static void blkif_completion(struct blk_shadow *s)
> @@ -875,8 +883,27 @@ static int talk_to_blkback(struct xenbus_device *dev,
>  {
>         const char *message = NULL;
>         struct xenbus_transaction xbt;
> +       unsigned int ring_order;
> +       int legacy_backend;
> +       int i;
>         int err;
> 
> +       for (i = 0; i < (1 << info->ring_order); i++)
> +               info->ring_ref[i] = GRANT_INVALID_REF;
> +
> +       err = xenbus_scanf(XBT_NIL, dev->otherend, "max-ring-page-order", "%u",
> +                          &ring_order);

At least the frontend should imo also support the alternative interface
(using "max-ring-pages" etc).

> +
> +       legacy_backend = !(err == 1);
> +
> +       if (legacy_backend) {
> +               info->ring_order = 0;
> +       } else {
> +               info->ring_order = (ring_order <= xen_blkif_ring_order) ?
> +                                  ring_order :
> +                                  xen_blkif_ring_order;

min()?

> +       }
> +
>         /* Create shared ring, alloc event channel. */
>         err = setup_blkring(dev, info);
>         if (err)
> @@ -889,12 +916,35 @@ again:
>                 goto destroy_blkring;
>         }
> 
> -       err = xenbus_printf(xbt, dev->nodename,
> -                           "ring-ref", "%u", info->ring_ref);
> -       if (err) {
> -               message = "writing ring-ref";
> -               goto abort_transaction;
> +       if (legacy_backend) {

Why not use the simpler interface always when info->ring_order == 0?

> +               err = xenbus_printf(xbt, dev->nodename,
> +                                   "ring-ref", "%d", info->ring_ref[0]);
> +               if (err) {
> +                       message = "writing ring-ref";
> +                       goto abort_transaction;
> +               }
> +       } else {
> +               for (i = 0; i < (1 << info->ring_order); i++) {
> +                       char key[sizeof("ring-ref") + 2];
> +
> +                       sprintf(key, "ring-ref%d", i);
> +
> +                       err = xenbus_printf(xbt, dev->nodename,
> +                                           key, "%d", info->ring_ref[i]);
> +                       if (err) {
> +                               message = "writing ring-ref";
> +                               goto abort_transaction;
> +                       }
> +               }
> +
> +               err = xenbus_printf(xbt, dev->nodename,
> +                                   "ring-page-order", "%u", info->ring_order);
> +               if (err) {
> +                       message = "writing ring-order";
> +                       goto abort_transaction;
> +               }
>         }
> +
>         err = xenbus_printf(xbt, dev->nodename,
>                             "event-channel", "%u", info->evtchn);
>         if (err) {
> @@ -996,21 +1046,14 @@ static int blkfront_probe(struct xenbus_device *dev,
>         info->connected = BLKIF_STATE_DISCONNECTED;
>         INIT_WORK(&info->work, blkif_restart_queue);
> 
> -       for (i = 0; i < BLK_RING_SIZE; i++)
> +       for (i = 0; i < BLK_MAX_RING_SIZE; i++)
>                 info->shadow[i].req.u.rw.id = i+1;
> -       info->shadow[BLK_RING_SIZE-1].req.u.rw.id = 0x0fffffff;
> +       info->shadow[BLK_MAX_RING_SIZE-1].req.u.rw.id = 0x0fffffff;

A proper terminator must also be written in talk_to_blkback() once
the actual ring size is known.

Further, blkif_recover() must be able to deal with a change of the
allowed upper bound.

>         /* Front end dir is a number, which is used as the id. */
>         info->handle = simple_strtoul(strrchr(dev->nodename, '/')+1, NULL, 0);
>         dev_set_drvdata(&dev->dev, info);
> 
> -       err = talk_to_blkback(dev, info);

Completely removing this here is wrong afaict - what if the backend
already is in InitWait when the frontend starts?

Further, whatever is done to this call here also needs to be done in
blkfront_resume().

> -       if (err) {
> -               kfree(info);
> -               dev_set_drvdata(&dev->dev, NULL);
> -               return err;
> -       }
> -
>         return 0;
>  }
> 
> @@ -1307,6 +1349,10 @@ static void blkback_changed(struct xenbus_device *dev,
>         case XenbusStateClosed:
>                 break;
> 
> +       case XenbusStateInitWait:
> +               talk_to_blkback(dev, info);

This call can return an error.

> +               break;
> +
>         case XenbusStateConnected:
>                 blkfront_connect(info);
>                 break;
> --- a/include/xen/xenbus.h
> +++ b/include/xen/xenbus.h
> @@ -195,15 +195,23 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
>                          const char *pathfmt, ...);
> 
>  int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
> -int xenbus_map_ring_valloc(struct xenbus_device *dev,
> -                          int gnt_ref, void **vaddr);
> -int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
> -                          grant_handle_t *handle, void *vaddr);
> +
> +#define        XENBUS_MAX_RING_ORDER   2
> +#define        XENBUS_MAX_RING_PAGES   (1 << XENBUS_MAX_RING_ORDER)

Why do you need an artificial global limit here? Each driver can decide
individually what its limit should be.

Jan
