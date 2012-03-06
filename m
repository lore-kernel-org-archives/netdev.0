From: Santosh Jodh <Santosh.Jodh@citrix.com>
Subject: RE: [PATCH 0001/001] xen: multi page ring support for block devices
Date: Mon, 5 Mar 2012 22:21:50 -0800
Message-ID: <7914B38A4445B34AA16EB9F1352942F1010A1FA12439@SJCPMAILBOX01.citrite.net>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
 <7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
 <87ty22xxee.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Paul Durrant <Paul.Durrant@citrix.com>
To: Rusty Russell <rusty@rustcorp.com.au>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"jbeulich@novell.com" <jbeulich@novell.com>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"lersek@redhat.com" <lersek@redhat.com>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"dgdegra@tycho.nsa.gov" <dgdegra@tycho.nsa.gov>,
	David Vrabel <david.vrabel@citrix.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"waldi@debian.org" <waldi@debian.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ty22xxee.fsf@rustcorp.com.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Great feedback. I removed unsigned for the first, changed the error code and added module param name in the printk.

Please see latest patch:
---

diff --git a/drivers/block/xen-blkback/blkback.c b/drivers/block/xen-blkback/blkback.c
index 0088bf6..cc238e7 100644
--- a/drivers/block/xen-blkback/blkback.c
+++ b/drivers/block/xen-blkback/blkback.c
@@ -60,6 +60,40 @@ static int xen_blkif_reqs = 64;
 module_param_named(reqs, xen_blkif_reqs, int, 0);
 MODULE_PARM_DESC(reqs, "Number of blkback requests to allocate");

+/* Order of maximum shared ring size advertised to the front end. */
+int xen_blkif_max_ring_order = XENBUS_MAX_RING_ORDER;
+
+#define BLK_RING_SIZE(_order) __CONST_RING_SIZE(blkif, PAGE_SIZE << (_order))
+
+static int set_max_ring_order(const char *buf, struct kernel_param *kp)
+{
+       int err;
+       long order;
+
+       err = kstrtol(buf, 0, &order);
+       if (err ||
+           order < 0 ||
+           order > XENBUS_MAX_RING_ORDER)
+               return -ERANGE;
+
+       if (xen_blkif_reqs < BLK_RING_SIZE(order))
+               printk(KERN_WARNING "WARNING: "
+                      "I/O request space (%d reqs) < ring order %ld "
+                       "set by module parameter %s.max_ring_order, "
+                      "consider increasing %s.reqs to >= %ld.",
+                      xen_blkif_reqs, order, KBUILD_MODNAME, KBUILD_MODNAME,
+                      roundup_pow_of_two(BLK_RING_SIZE(order)));
+
+       xen_blkif_max_ring_order = order;
+
+       return 0;
+}
+
+module_param_call(max_ring_order,
+                 set_max_ring_order, param_get_int,
+                 &xen_blkif_max_ring_order, 0644);
+MODULE_PARM_DESC(max_ring_order, "log2 of maximum ring size, in pages.");
+
 /* Run-time switchable: /sys/module/blkback/parameters/ */
 static unsigned int log_stats;
 module_param(log_stats, int, 0644);
diff --git a/drivers/block/xen-blkback/common.h b/drivers/block/xen-blkback/common.h
index d0ee7ed..5f33a1a 100644
--- a/drivers/block/xen-blkback/common.h
+++ b/drivers/block/xen-blkback/common.h
@@ -126,6 +126,8 @@ struct blkif_x86_64_response {
        int16_t         status;          /* BLKIF_RSP_???       */
 };

+extern int xen_blkif_max_ring_order;
+
 DEFINE_RING_TYPES(blkif_common, struct blkif_common_request,
                  struct blkif_common_response);
 DEFINE_RING_TYPES(blkif_x86_32, struct blkif_x86_32_request,
diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkback/xenbus.c
index 24a2fb5..7a9d71d 100644
--- a/drivers/block/xen-blkback/xenbus.c
+++ b/drivers/block/xen-blkback/xenbus.c
@@ -122,8 +122,8 @@ static struct xen_blkif *xen_blkif_alloc(domid_t domid)
        return blkif;
 }

-static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
-                        unsigned int evtchn)
+static int xen_blkif_map(struct xen_blkif *blkif, int ring_ref[],
+                        unsigned int ring_order, unsigned int evtchn)
 {
        int err;

@@ -131,7 +131,8 @@ static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
        if (blkif->irq)
                return 0;

-       err = xenbus_map_ring_valloc(blkif->be->dev, shared_page, &blkif->blk_ring);
+       err = xenbus_map_ring_valloc(blkif->be->dev, ring_ref, 1 << ring_order,
+                                    &blkif->blk_ring);
        if (err < 0)
                return err;

@@ -140,21 +141,24 @@ static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
        {
                struct blkif_sring *sring;
                sring = (struct blkif_sring *)blkif->blk_ring;
-               BACK_RING_INIT(&blkif->blk_rings.native, sring, PAGE_SIZE);
+               BACK_RING_INIT(&blkif->blk_rings.native, sring,
+                              PAGE_SIZE << ring_order);
                break;
        }
        case BLKIF_PROTOCOL_X86_32:
        {
                struct blkif_x86_32_sring *sring_x86_32;
                sring_x86_32 = (struct blkif_x86_32_sring *)blkif->blk_ring;
-               BACK_RING_INIT(&blkif->blk_rings.x86_32, sring_x86_32, PAGE_SIZE);
+               BACK_RING_INIT(&blkif->blk_rings.x86_32, sring_x86_32,
+                              PAGE_SIZE << ring_order);
                break;
        }
        case BLKIF_PROTOCOL_X86_64:
        {
                struct blkif_x86_64_sring *sring_x86_64;
                sring_x86_64 = (struct blkif_x86_64_sring *)blkif->blk_ring;
-               BACK_RING_INIT(&blkif->blk_rings.x86_64, sring_x86_64, PAGE_SIZE);
+               BACK_RING_INIT(&blkif->blk_rings.x86_64, sring_x86_64,
+                              PAGE_SIZE << ring_order);
                break;
        }
        default:
@@ -497,6 +501,11 @@ static int xen_blkbk_probe(struct xenbus_device *dev,
        if (err)
                goto fail;

+       err = xenbus_printf(XBT_NIL, dev->nodename, "max-ring-page-order",
+                           "%u", xen_blkif_max_ring_order);
+       if (err)
+               goto fail;
+
        err = xenbus_switch_state(dev, XenbusStateInitWait);
        if (err)
                goto fail;
@@ -744,22 +753,80 @@ again:
 static int connect_ring(struct backend_info *be)
 {
        struct xenbus_device *dev = be->dev;
-       unsigned long ring_ref;
+       int ring_ref[XENBUS_MAX_RING_PAGES];
+       unsigned int ring_order;
        unsigned int evtchn;
        char protocol[64] = "";
        int err;

        DPRINTK("%s", dev->otherend);

-       err = xenbus_gather(XBT_NIL, dev->otherend, "ring-ref", "%lu",
-                           &ring_ref, "event-channel", "%u", &evtchn, NULL);
-       if (err) {
-               xenbus_dev_fatal(dev, err,
-                                "reading %s/ring-ref and event-channel",
+       err = xenbus_scanf(XBT_NIL, dev->otherend, "event-channel", "%u",
+                          &evtchn);
+       if (err != 1) {
+               err = -EINVAL;
+
+               xenbus_dev_fatal(dev, err, "reading %s/event-channel",
                                 dev->otherend);
                return err;
        }

+       printk(KERN_INFO "blkback: event-channel %u\n", evtchn);
+
+       err = xenbus_scanf(XBT_NIL, dev->otherend, "ring-page-order", "%u",
+                          &ring_order);
+       if (err != 1) {
+               DPRINTK("%s: using single page handshake", dev->otherend);
+
+               ring_order = 0;
+
+               err = xenbus_scanf(XBT_NIL, dev->otherend, "ring-ref",
+                                  "%d", &ring_ref[0]);
+               if (err != 1) {
+                       err = -EINVAL;
+
+                       xenbus_dev_fatal(dev, err, "reading %s/ring-ref",
+                                        dev->otherend);
+                       return err;
+               }
+
+               printk(KERN_INFO "blkback: ring-ref %d\n", ring_ref[0]);
+       } else {
+               unsigned int i;
+
+               if (ring_order > xen_blkif_max_ring_order) {
+                       err = -EINVAL;
+
+                       xenbus_dev_fatal(dev, err,
+                                        "%s/ring-page-order too big",
+                                        dev->otherend);
+                       return err;
+               }
+
+               for (i = 0; i < (1u << ring_order); i++) {
+                       char ring_ref_name[10];
+
+                       snprintf(ring_ref_name, sizeof(ring_ref_name),
+                                "ring-ref%u", i);
+
+                       err = xenbus_scanf(XBT_NIL, dev->otherend,
+                                          ring_ref_name, "%d",
+                                          &ring_ref[i]);
+                       if (err != 1) {
+                               err = -EINVAL;
+
+                               xenbus_dev_fatal(dev, err,
+                                                "reading %s/%s",
+                                                dev->otherend,
+                                                ring_ref_name);
+                               return err;
+                       }
+
+                       printk(KERN_INFO "blkback: ring-ref%u %d\n", i,
+                              ring_ref[i]);
+               }
+       }
+
        be->blkif->blk_protocol = BLKIF_PROTOCOL_NATIVE;
        err = xenbus_gather(XBT_NIL, dev->otherend, "protocol",
                            "%63s", protocol, NULL);
@@ -775,14 +842,11 @@ static int connect_ring(struct backend_info *be)
                xenbus_dev_fatal(dev, err, "unknown fe protocol %s", protocol);
                return -1;
        }
-       pr_info(DRV_PFX "ring-ref %ld, event-channel %d, protocol %d (%s)\n",
-               ring_ref, evtchn, be->blkif->blk_protocol, protocol);

        /* Map the shared frame, irq etc. */
-       err = xen_blkif_map(be->blkif, ring_ref, evtchn);
+       err = xen_blkif_map(be->blkif, ring_ref, ring_order, evtchn);
        if (err) {
-               xenbus_dev_fatal(dev, err, "mapping ring-ref %lu port %u",
-                                ring_ref, evtchn);
+               xenbus_dev_fatal(dev, err, "mapping ring-refs and evtchn");
                return err;
        }

diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index 2f22874..485813a 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -57,6 +57,10 @@

 #include <asm/xen/hypervisor.h>

+static int xen_blkif_ring_order;
+module_param_named(reqs, xen_blkif_ring_order, int, 0);
+MODULE_PARM_DESC(reqs, "log2 of requested ring size, in pages.");
+
 enum blkif_state {
        BLKIF_STATE_DISCONNECTED,
        BLKIF_STATE_CONNECTED,
@@ -72,7 +76,8 @@ struct blk_shadow {
 static DEFINE_MUTEX(blkfront_mutex);
 static const struct block_device_operations xlvbd_block_fops;

-#define BLK_RING_SIZE __CONST_RING_SIZE(blkif, PAGE_SIZE)
+#define BLK_RING_SIZE(_order)  __CONST_RING_SIZE(blkif, PAGE_SIZE << (_order))
+#define BLK_MAX_RING_SIZE      BLK_RING_SIZE(XENBUS_MAX_RING_ORDER)

 /*
  * We have one of these per vbd, whether ide, scsi or 'other'.  They
@@ -87,14 +92,15 @@ struct blkfront_info
        int vdevice;
        blkif_vdev_t handle;
        enum blkif_state connected;
-       int ring_ref;
+       int ring_ref[XENBUS_MAX_RING_PAGES];
+       int ring_order;
        struct blkif_front_ring ring;
        struct scatterlist sg[BLKIF_MAX_SEGMENTS_PER_REQUEST];
        unsigned int evtchn, irq;
        struct request_queue *rq;
        struct work_struct work;
        struct gnttab_free_callback callback;
-       struct blk_shadow shadow[BLK_RING_SIZE];
+       struct blk_shadow shadow[BLK_MAX_RING_SIZE];
        unsigned long shadow_free;
        unsigned int feature_flush;
        unsigned int flush_op;
@@ -111,9 +117,7 @@ static unsigned int nr_minors;
 static unsigned long *minors;
 static DEFINE_SPINLOCK(minor_lock);

-#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
-       (BLKIF_MAX_SEGMENTS_PER_REQUEST * BLK_RING_SIZE)
-#define GRANT_INVALID_REF      0
+#define GRANT_INVALID_REF      0

 #define PARTS_PER_DISK         16
 #define PARTS_PER_EXT_DISK      256
@@ -135,7 +139,7 @@ static DEFINE_SPINLOCK(minor_lock);
 static int get_id_from_freelist(struct blkfront_info *info)
 {
        unsigned long free = info->shadow_free;
-       BUG_ON(free >= BLK_RING_SIZE);
+       BUG_ON(free >= BLK_MAX_RING_SIZE);
        info->shadow_free = info->shadow[free].req.u.rw.id;
        info->shadow[free].req.u.rw.id = 0x0fffffee; /* debug */
        return free;
@@ -683,6 +687,8 @@ static void blkif_restart_queue(struct work_struct *work)

 static void blkif_free(struct blkfront_info *info, int suspend)
 {
+       int i;
+
        /* Prevent new requests being issued until we fix things up. */
        spin_lock_irq(&blkif_io_lock);
        info->connected = suspend ?
@@ -698,16 +704,19 @@ static void blkif_free(struct blkfront_info *info, int suspend)
        flush_work_sync(&info->work);

        /* Free resources associated with old device channel. */
-       if (info->ring_ref != GRANT_INVALID_REF) {
-               gnttab_end_foreign_access(info->ring_ref, 0,
-                                         (unsigned long)info->ring.sring);
-               info->ring_ref = GRANT_INVALID_REF;
-               info->ring.sring = NULL;
+       for (i = 0; i < (1 << info->ring_order); i++) {
+               if (info->ring_ref[i] != GRANT_INVALID_REF) {
+                       gnttab_end_foreign_access(info->ring_ref[i], 0, 0);
+                       info->ring_ref[i] = GRANT_INVALID_REF;
+               }
        }
+
+       free_pages((unsigned long)info->ring.sring, info->ring_order);
+       info->ring.sring = NULL;
+
        if (info->irq)
                unbind_from_irqhandler(info->irq, info);
        info->evtchn = info->irq = 0;
-
 }

 static void blkif_completion(struct blk_shadow *s)
@@ -828,25 +837,24 @@ static int setup_blkring(struct xenbus_device *dev,
        struct blkif_sring *sring;
        int err;

-       info->ring_ref = GRANT_INVALID_REF;
-
-       sring = (struct blkif_sring *)__get_free_page(GFP_NOIO | __GFP_HIGH);
+       sring = (struct blkif_sring *)__get_free_pages(GFP_NOIO | __GFP_HIGH,
+                                                      info->ring_order);
        if (!sring) {
                xenbus_dev_fatal(dev, -ENOMEM, "allocating shared ring");
                return -ENOMEM;
        }
        SHARED_RING_INIT(sring);
-       FRONT_RING_INIT(&info->ring, sring, PAGE_SIZE);
+       FRONT_RING_INIT(&info->ring, sring, PAGE_SIZE << info->ring_order);

        sg_init_table(info->sg, BLKIF_MAX_SEGMENTS_PER_REQUEST);

-       err = xenbus_grant_ring(dev, virt_to_mfn(info->ring.sring));
+       err = xenbus_grant_ring(dev, info->ring.sring, 1 << info->ring_order,
+                               info->ring_ref);
        if (err < 0) {
-               free_page((unsigned long)sring);
+               free_pages((unsigned long)sring, info->ring_order);
                info->ring.sring = NULL;
                goto fail;
        }
-       info->ring_ref = err;

        err = xenbus_alloc_evtchn(dev, &info->evtchn);
        if (err)
@@ -875,8 +883,27 @@ static int talk_to_blkback(struct xenbus_device *dev,
 {
        const char *message = NULL;
        struct xenbus_transaction xbt;
+       unsigned int ring_order;
+       int legacy_backend;
+       int i;
        int err;

+       for (i = 0; i < (1 << info->ring_order); i++)
+               info->ring_ref[i] = GRANT_INVALID_REF;
+
+       err = xenbus_scanf(XBT_NIL, dev->otherend, "max-ring-page-order", "%u",
+                          &ring_order);
+
+       legacy_backend = !(err == 1);
+
+       if (legacy_backend) {
+               info->ring_order = 0;
+       } else {
+               info->ring_order = (ring_order <= xen_blkif_ring_order) ?
+                                  ring_order :
+                                  xen_blkif_ring_order;
+       }
+
        /* Create shared ring, alloc event channel. */
        err = setup_blkring(dev, info);
        if (err)
@@ -889,12 +916,35 @@ again:
                goto destroy_blkring;
        }

-       err = xenbus_printf(xbt, dev->nodename,
-                           "ring-ref", "%u", info->ring_ref);
-       if (err) {
-               message = "writing ring-ref";
-               goto abort_transaction;
+       if (legacy_backend) {
+               err = xenbus_printf(xbt, dev->nodename,
+                                   "ring-ref", "%d", info->ring_ref[0]);
+               if (err) {
+                       message = "writing ring-ref";
+                       goto abort_transaction;
+               }
+       } else {
+               for (i = 0; i < (1 << info->ring_order); i++) {
+                       char key[sizeof("ring-ref") + 2];
+
+                       sprintf(key, "ring-ref%d", i);
+
+                       err = xenbus_printf(xbt, dev->nodename,
+                                           key, "%d", info->ring_ref[i]);
+                       if (err) {
+                               message = "writing ring-ref";
+                               goto abort_transaction;
+                       }
+               }
+
+               err = xenbus_printf(xbt, dev->nodename,
+                                   "ring-page-order", "%u", info->ring_order);
+               if (err) {
+                       message = "writing ring-order";
+                       goto abort_transaction;
+               }
        }
+
        err = xenbus_printf(xbt, dev->nodename,
                            "event-channel", "%u", info->evtchn);
        if (err) {
@@ -996,21 +1046,14 @@ static int blkfront_probe(struct xenbus_device *dev,
        info->connected = BLKIF_STATE_DISCONNECTED;
        INIT_WORK(&info->work, blkif_restart_queue);

-       for (i = 0; i < BLK_RING_SIZE; i++)
+       for (i = 0; i < BLK_MAX_RING_SIZE; i++)
                info->shadow[i].req.u.rw.id = i+1;
-       info->shadow[BLK_RING_SIZE-1].req.u.rw.id = 0x0fffffff;
+       info->shadow[BLK_MAX_RING_SIZE-1].req.u.rw.id = 0x0fffffff;

        /* Front end dir is a number, which is used as the id. */
        info->handle = simple_strtoul(strrchr(dev->nodename, '/')+1, NULL, 0);
        dev_set_drvdata(&dev->dev, info);

-       err = talk_to_blkback(dev, info);
-       if (err) {
-               kfree(info);
-               dev_set_drvdata(&dev->dev, NULL);
-               return err;
-       }
-
        return 0;
 }

@@ -1031,13 +1074,13 @@ static int blkif_recover(struct blkfront_info *info)

        /* Stage 2: Set up free list. */
        memset(&info->shadow, 0, sizeof(info->shadow));
-       for (i = 0; i < BLK_RING_SIZE; i++)
+       for (i = 0; i < BLK_MAX_RING_SIZE; i++)
                info->shadow[i].req.u.rw.id = i+1;
        info->shadow_free = info->ring.req_prod_pvt;
-       info->shadow[BLK_RING_SIZE-1].req.u.rw.id = 0x0fffffff;
+       info->shadow[BLK_MAX_RING_SIZE-1].req.u.rw.id = 0x0fffffff;

        /* Stage 3: Find pending requests and requeue them. */
-       for (i = 0; i < BLK_RING_SIZE; i++) {
+       for (i = 0; i < BLK_RING_SIZE(info->ring_order); i++) {
                /* Not in use? */
                if (!copy[i].request)
                        continue;
@@ -1299,7 +1342,6 @@ static void blkback_changed(struct xenbus_device *dev,

        switch (backend_state) {
        case XenbusStateInitialising:
-       case XenbusStateInitWait:
        case XenbusStateInitialised:
        case XenbusStateReconfiguring:
        case XenbusStateReconfigured:
@@ -1307,6 +1349,10 @@ static void blkback_changed(struct xenbus_device *dev,
        case XenbusStateClosed:
                break;

+       case XenbusStateInitWait:
+               talk_to_blkback(dev, info);
+               break;
+
        case XenbusStateConnected:
                blkfront_connect(info);
                break;
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 94b79c3..f93b59a 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -130,8 +130,8 @@ int xen_netbk_must_stop_queue(struct xenvif *vif);
 /* (Un)Map communication rings. */
 void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
 int xen_netbk_map_frontend_rings(struct xenvif *vif,
-                                grant_ref_t tx_ring_ref,
-                                grant_ref_t rx_ring_ref);
+                                int tx_ring_ref,
+                                int rx_ring_ref);

 /* (De)Register a xenvif with the netback backend. */
 void xen_netbk_add_xenvif(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 59effac..0b014cf 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1594,8 +1594,8 @@ void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 }

 int xen_netbk_map_frontend_rings(struct xenvif *vif,
-                                grant_ref_t tx_ring_ref,
-                                grant_ref_t rx_ring_ref)
+                                int tx_ring_ref,
+                                int rx_ring_ref)
 {
        void *addr;
        struct xen_netif_tx_sring *txs;
@@ -1604,7 +1604,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
        int err = -ENOMEM;

        err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-                                    tx_ring_ref, &addr);
+                                    &tx_ring_ref, 1, &addr);
        if (err)
                goto err;

@@ -1612,7 +1612,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
        BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);

        err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-                                    rx_ring_ref, &addr);
+                                    &rx_ring_ref, 1, &addr);
        if (err)
                goto err;

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 698b905..521a595 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1496,13 +1496,12 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
        SHARED_RING_INIT(txs);
        FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);

-       err = xenbus_grant_ring(dev, virt_to_mfn(txs));
+       err = xenbus_grant_ring(dev, txs, 1, &info->tx_ring_ref);
        if (err < 0) {
                free_page((unsigned long)txs);
                goto fail;
        }

-       info->tx_ring_ref = err;
        rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
        if (!rxs) {
                err = -ENOMEM;
@@ -1512,12 +1511,11 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
        SHARED_RING_INIT(rxs);
        FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);

-       err = xenbus_grant_ring(dev, virt_to_mfn(rxs));
+       err = xenbus_grant_ring(dev, rxs, 1, &info->rx_ring_ref);
        if (err < 0) {
                free_page((unsigned long)rxs);
                goto fail;
        }
-       info->rx_ring_ref = err;

        err = xenbus_alloc_evtchn(dev, &info->evtchn);
        if (err)
diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
index 1620088..95109d8 100644
--- a/drivers/pci/xen-pcifront.c
+++ b/drivers/pci/xen-pcifront.c
@@ -768,12 +768,10 @@ static int pcifront_publish_info(struct pcifront_device *pdev)
        int err = 0;
        struct xenbus_transaction trans;

-       err = xenbus_grant_ring(pdev->xdev, virt_to_mfn(pdev->sh_info));
+       err = xenbus_grant_ring(pdev->xdev, pdev->sh_info, 1, &pdev->gnt_ref);
        if (err < 0)
                goto out;

-       pdev->gnt_ref = err;
-
        err = xenbus_alloc_evtchn(pdev->xdev, &pdev->evtchn);
        if (err)
                goto out;
diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
index 64b11f9..e0834cd 100644
--- a/drivers/xen/xen-pciback/xenbus.c
+++ b/drivers/xen/xen-pciback/xenbus.c
@@ -108,7 +108,7 @@ static int xen_pcibk_do_attach(struct xen_pcibk_device *pdev, int gnt_ref,
                "Attaching to frontend resources - gnt_ref=%d evtchn=%d\n",
                gnt_ref, remote_evtchn);

-       err = xenbus_map_ring_valloc(pdev->xdev, gnt_ref, &vaddr);
+       err = xenbus_map_ring_valloc(pdev->xdev, &gnt_ref, 1, &vaddr);
        if (err < 0) {
                xenbus_dev_fatal(pdev->xdev, err,
                                "Error mapping other domain page in ours.");
diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index 566d2ad..3a14524 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -53,14 +53,16 @@ struct xenbus_map_node {
                struct vm_struct *area; /* PV */
                struct page *page;     /* HVM */
        };
-       grant_handle_t handle;
+       grant_handle_t handle[XENBUS_MAX_RING_PAGES];
+       unsigned int   nr_handles;
 };

 static DEFINE_SPINLOCK(xenbus_valloc_lock);
 static LIST_HEAD(xenbus_valloc_pages);

 struct xenbus_ring_ops {
-       int (*map)(struct xenbus_device *dev, int gnt, void **vaddr);
+       int (*map)(struct xenbus_device *dev, int gnt[], int nr_gnts,
+                  void **vaddr);
        int (*unmap)(struct xenbus_device *dev, void *vaddr);
 };

@@ -356,17 +358,38 @@ static void xenbus_switch_fatal(struct xenbus_device *dev, int depth, int err,
 /**
  * xenbus_grant_ring
  * @dev: xenbus device
- * @ring_mfn: mfn of ring to grant
-
- * Grant access to the given @ring_mfn to the peer of the given device.  Return
- * 0 on success, or -errno on error.  On error, the device will switch to
- * XenbusStateClosing, and the error will be saved in the store.
+ * @vaddr: starting virtual address of the ring
+ * @nr_pages: number of page to be granted
+ * @grefs: grant reference array to be filled in
+ * Grant access to the given @vaddr to the peer of the given device.
+ * Then fill in @grefs with grant references.  Return 0 on success, or
+ * -errno on error.  On error, the device will switch to
+ * XenbusStateClosing, and the first error will be saved in the store.
  */
-int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn)
+int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
+                     int nr_pages, int grefs[])
 {
-       int err = gnttab_grant_foreign_access(dev->otherend_id, ring_mfn, 0);
-       if (err < 0)
-               xenbus_dev_fatal(dev, err, "granting access to ring page");
+       int i;
+       int err;
+
+       for (i = 0; i < nr_pages; i++) {
+               unsigned long addr = (unsigned long)vaddr +
+                       (PAGE_SIZE * i);
+               err = gnttab_grant_foreign_access(dev->otherend_id,
+                                                 virt_to_mfn(addr), 0);
+               if (err < 0) {
+                       xenbus_dev_fatal(dev, err,
+                                        "granting access to ring page");
+                       goto fail;
+               }
+               grefs[i] = err;
+       }
+
+       return 0;
+
+fail:
+       for ( ; i >= 0; i--)
+               gnttab_end_foreign_access_ref(grefs[i], 0);
        return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_grant_ring);
@@ -447,7 +470,8 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
 /**
  * xenbus_map_ring_valloc
  * @dev: xenbus device
- * @gnt_ref: grant reference
+ * @gnt_ref: grant reference array
+ * @nr_grefs: number of grant reference
  * @vaddr: pointer to address to be filled out by mapping
  *
  * Based on Rusty Russell's skeleton driver's map_page.
@@ -458,23 +482,28 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
  * or -ENOMEM on error. If an error is returned, device will switch to
  * XenbusStateClosing and the error message will be saved in XenStore.
  */
-int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
+int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref[],
+                          int nr_grefs, void **vaddr)
 {
-       return ring_ops->map(dev, gnt_ref, vaddr);
+       return ring_ops->map(dev, gnt_ref, nr_grefs, vaddr);
 }
 EXPORT_SYMBOL_GPL(xenbus_map_ring_valloc);

+static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
+                                       struct xenbus_map_node *node);
+
 static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
-                                    int gnt_ref, void **vaddr)
+                                    int gnt_ref[], int nr_grefs, void **vaddr)
 {
-       struct gnttab_map_grant_ref op = {
-               .flags = GNTMAP_host_map | GNTMAP_contains_pte,
-               .ref   = gnt_ref,
-               .dom   = dev->otherend_id,
-       };
+       struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
        struct xenbus_map_node *node;
        struct vm_struct *area;
-       pte_t *pte;
+       pte_t *pte[XENBUS_MAX_RING_PAGES];
+       int i;
+       int err = 0;
+
+       if (nr_grefs > XENBUS_MAX_RING_PAGES)
+               return -EINVAL;

        *vaddr = NULL;

@@ -482,28 +511,44 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
        if (!node)
                return -ENOMEM;

-       area = alloc_vm_area(PAGE_SIZE, &pte);
+       area = alloc_vm_area(PAGE_SIZE * nr_grefs, pte);
        if (!area) {
                kfree(node);
                return -ENOMEM;
        }

-       op.host_addr = arbitrary_virt_to_machine(pte).maddr;
+       for (i = 0; i < nr_grefs; i++) {
+               op[i].flags = GNTMAP_host_map | GNTMAP_contains_pte,
+               op[i].ref   = gnt_ref[i],
+               op[i].dom   = dev->otherend_id,
+               op[i].host_addr = arbitrary_virt_to_machine(pte[i]).maddr;
+       };

        if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
                BUG();

-       if (op.status != GNTST_okay) {
-               free_vm_area(area);
-               kfree(node);
-               xenbus_dev_fatal(dev, op.status,
-                                "mapping in shared page %d from domain %d",
-                                gnt_ref, dev->otherend_id);
-               return op.status;
+       node->nr_handles = nr_grefs;
+       node->area = area;
+
+       for (i = 0; i < nr_grefs; i++) {
+               if (op[i].status != GNTST_okay) {
+                       err = op[i].status;
+                       node->handle[i] = INVALID_GRANT_HANDLE;
+                       continue;
+               }
+               node->handle[i] = op[i].handle;
        }

-       node->handle = op.handle;
-       node->area = area;
+       if (err != 0) {
+               for (i = 0; i < nr_grefs; i++)
+                       xenbus_dev_fatal(dev, op[i].status,
+                               "mapping in shared page %d from domain %d",
+                               gnt_ref[i], dev->otherend_id);
+
+                __xenbus_unmap_ring_vfree_pv(dev, node);
+
+               return err;
+       }

        spin_lock(&xenbus_valloc_lock);
        list_add(&node->next, &xenbus_valloc_pages);
@@ -514,25 +559,29 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
 }

 static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
-                                     int gnt_ref, void **vaddr)
+                                     int gnt_ref[], int nr_grefs, void **vaddr)
 {
        struct xenbus_map_node *node;
        int err;
        void *addr;

+       if (nr_grefs > XENBUS_MAX_RING_PAGES)
+               return -EINVAL;
+
        *vaddr = NULL;

        node = kzalloc(sizeof(*node), GFP_KERNEL);
        if (!node)
                return -ENOMEM;

-       err = alloc_xenballooned_pages(1, &node->page, false /* lowmem */);
+       err = alloc_xenballooned_pages(nr_grefs, &node->page,
+                                      false /* lowmem */);
        if (err)
                goto out_err;

        addr = pfn_to_kaddr(page_to_pfn(node->page));

-       err = xenbus_map_ring(dev, gnt_ref, &node->handle, addr);
+       err = xenbus_map_ring(dev, gnt_ref, nr_grefs, node->handle, addr);
        if (err)
                goto out_err;

@@ -544,7 +593,7 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
        return 0;

  out_err:
-       free_xenballooned_pages(1, &node->page);
+       free_xenballooned_pages(nr_grefs, &node->page);
        kfree(node);
        return err;
 }
@@ -553,36 +602,51 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
 /**
  * xenbus_map_ring
  * @dev: xenbus device
- * @gnt_ref: grant reference
- * @handle: pointer to grant handle to be filled
+ * @gnt_ref: grant reference array
+ * @nr_grefs: number of grant references
+ * @handle: pointer to grant handle array to be filled, mind the size
  * @vaddr: address to be mapped to
  *
- * Map a page of memory into this domain from another domain's grant table.
+ * Map pages of memory into this domain from another domain's grant table.
  * xenbus_map_ring does not allocate the virtual address space (you must do
- * this yourself!). It only maps in the page to the specified address.
+ * this yourself!). It only maps in the pages to the specified address.
  * Returns 0 on success, and GNTST_* (see xen/include/interface/grant_table.h)
  * or -ENOMEM on error. If an error is returned, device will switch to
- * XenbusStateClosing and the error message will be saved in XenStore.
+ * XenbusStateClosing and the last error message will be saved in XenStore.
  */
-int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
-                   grant_handle_t *handle, void *vaddr)
+int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_grefs,
+                   grant_handle_t handle[], void *vaddr)
 {
-       struct gnttab_map_grant_ref op;
-
-       gnttab_set_map_op(&op, (phys_addr_t)vaddr, GNTMAP_host_map, gnt_ref,
-                         dev->otherend_id);
+       struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
+       int i;
+       int err = GNTST_okay;   /* 0 */
+
+       for (i = 0; i < nr_grefs; i++) {
+               unsigned long addr = (unsigned long)vaddr +
+                       (PAGE_SIZE * i);
+               gnttab_set_map_op(&op[i], (phys_addr_t)addr,
+                                 GNTMAP_host_map, gnt_ref[i],
+                                 dev->otherend_id);
+       }

-       if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+       if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, op, nr_grefs))
                BUG();

-       if (op.status != GNTST_okay) {
-               xenbus_dev_fatal(dev, op.status,
-                                "mapping in shared page %d from domain %d",
-                                gnt_ref, dev->otherend_id);
-       } else
-               *handle = op.handle;
+       for (i = 0; i < nr_grefs; i++) {
+               if (op[i].status != GNTST_okay) {
+                       err = op[i].status;
+                       xenbus_dev_fatal(dev, err,
+                               "mapping in shared page %d from domain %d",
+                               gnt_ref[i], dev->otherend_id);
+                       handle[i] = INVALID_GRANT_HANDLE;
+               } else
+                       handle[i] = op[i].handle;
+       }

-       return op.status;
+       if (err != GNTST_okay)
+               xenbus_unmap_ring(dev, handle, nr_grefs, vaddr);
+
+       return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_map_ring);

@@ -605,13 +669,53 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr)
 }
 EXPORT_SYMBOL_GPL(xenbus_unmap_ring_vfree);

+static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
+                                       struct xenbus_map_node *node)
+{
+       struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
+       unsigned int level;
+       int i, j;
+       int err = GNTST_okay;
+
+       j = 0;
+       for (i = 0; i < node->nr_handles; i++) {
+               unsigned long vaddr = (unsigned long)node->area->addr +
+                       (PAGE_SIZE * i);
+               if (node->handle[i] != INVALID_GRANT_HANDLE) {
+                       memset(&op[j], 0, sizeof(op[0]));
+                       op[j].host_addr = arbitrary_virt_to_machine(
+                                       lookup_address(vaddr, &level)).maddr;
+                       op[j].handle = node->handle[i];
+                       j++;
+                       node->handle[i] = INVALID_GRANT_HANDLE;
+               }
+       }
+
+       if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op, j))
+               BUG();
+
+       node->nr_handles = 0;
+
+       for (i = 0; i < j; i++) {
+               if (op[i].status != GNTST_okay) {
+                       err = op[i].status;
+                       xenbus_dev_error(dev, err,
+                               "unmapping page %d at handle %d error %d",
+                               i, op[i].handle, err);
+               }
+       }
+
+       if (err == GNTST_okay)
+               free_vm_area(node->area);
+
+       kfree(node);
+
+       return err;
+}
+
 static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)
 {
        struct xenbus_map_node *node;
-       struct gnttab_unmap_grant_ref op = {
-               .host_addr = (unsigned long)vaddr,
-       };
-       unsigned int level;

        spin_lock(&xenbus_valloc_lock);
        list_for_each_entry(node, &xenbus_valloc_pages, next) {
@@ -626,33 +730,18 @@ static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)

        if (!node) {
                xenbus_dev_error(dev, -ENOENT,
-                                "can't find mapped virtual address %p", vaddr);
+                               "can't find mapped virtual address %p", vaddr);
                return GNTST_bad_virt_addr;
        }

-       op.handle = node->handle;
-       op.host_addr = arbitrary_virt_to_machine(
-               lookup_address((unsigned long)vaddr, &level)).maddr;
-
-       if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
-               BUG();
-
-       if (op.status == GNTST_okay)
-               free_vm_area(node->area);
-       else
-               xenbus_dev_error(dev, op.status,
-                                "unmapping page at handle %d error %d",
-                                node->handle, op.status);
-
-       kfree(node);
-       return op.status;
+       return __xenbus_unmap_ring_vfree_pv(dev, node);
 }

 static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
 {
        int rv;
        struct xenbus_map_node *node;
-       void *addr;
+       void *addr = NULL;

        spin_lock(&xenbus_valloc_lock);
        list_for_each_entry(node, &xenbus_valloc_pages, next) {
@@ -668,14 +757,14 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)

        if (!node) {
                xenbus_dev_error(dev, -ENOENT,
-                                "can't find mapped virtual address %p", vaddr);
+                               "can't find mapped virtual address %p", vaddr);
                return GNTST_bad_virt_addr;
        }

-       rv = xenbus_unmap_ring(dev, node->handle, addr);
+       rv = xenbus_unmap_ring(dev, node->handle, node->nr_handles, addr);

        if (!rv)
-               free_xenballooned_pages(1, &node->page);
+               free_xenballooned_pages(node->nr_handles, &node->page);
        else
                WARN(1, "Leaking %p\n", vaddr);

@@ -687,6 +776,7 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
  * xenbus_unmap_ring
  * @dev: xenbus device
  * @handle: grant handle
+ * @nr_handles: number of grant handle
  * @vaddr: addr to unmap
  *
  * Unmap a page of memory in this domain that was imported from another domain.
@@ -694,21 +784,37 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
  * (see xen/include/interface/grant_table.h).
  */
 int xenbus_unmap_ring(struct xenbus_device *dev,
-                     grant_handle_t handle, void *vaddr)
+                       grant_handle_t handle[], int nr_handles,
+                       void *vaddr)
 {
-       struct gnttab_unmap_grant_ref op;
-
-       gnttab_set_unmap_op(&op, (phys_addr_t)vaddr, GNTMAP_host_map, handle);
+       struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
+       int i, j;
+       int err = GNTST_okay;
+
+       j = 0;
+       for (i = 0; i < nr_handles; i++) {
+               unsigned long addr = (unsigned long)vaddr +
+                       (PAGE_SIZE * i);
+               if (handle[i] != INVALID_GRANT_HANDLE) {
+                       gnttab_set_unmap_op(&op[j++], (phys_addr_t)addr,
+                                           GNTMAP_host_map, handle[i]);
+                       handle[i] = INVALID_GRANT_HANDLE;
+               }
+       }

-       if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+       if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op, j))
                BUG();

-       if (op.status != GNTST_okay)
-               xenbus_dev_error(dev, op.status,
-                                "unmapping page at handle %d error %d",
-                                handle, op.status);
+       for (i = 0; i < j; i++) {
+               if (op[i].status != GNTST_okay) {
+                       err = op[i].status;
+                       xenbus_dev_error(dev, err,
+                               "unmapping page at handle %d error %d",
+                               handle[i], err);
+               }
+       }

-       return op.status;
+       return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_unmap_ring);

diff --git a/drivers/xen/xenbus/xenbus_probe.c b/drivers/xen/xenbus/xenbus_probe.c
index 3864967..62b92d2 100644
--- a/drivers/xen/xenbus/xenbus_probe.c
+++ b/drivers/xen/xenbus/xenbus_probe.c
@@ -718,6 +718,7 @@ static int __init xenstored_local_init(void)
        return err;
 }

+extern void xenbus_ring_ops_init(void);
 static int __init xenbus_init(void)
 {
        int err = 0;
@@ -767,6 +768,8 @@ static int __init xenbus_init(void)
        proc_mkdir("xen", NULL);
 #endif

+       xenbus_ring_ops_init();
+
 out_error:
        return err;
 }
diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
index e8c599b..cdbd948 100644
--- a/include/xen/xenbus.h
+++ b/include/xen/xenbus.h
@@ -195,15 +195,23 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
                         const char *pathfmt, ...);

 int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
-int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
-int xenbus_map_ring_valloc(struct xenbus_device *dev,
-                          int gnt_ref, void **vaddr);
-int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
-                          grant_handle_t *handle, void *vaddr);
+
+#define        XENBUS_MAX_RING_ORDER   2
+#define        XENBUS_MAX_RING_PAGES   (1 << XENBUS_MAX_RING_ORDER)
+
+#define INVALID_GRANT_HANDLE           (~0U)
+
+int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
+                     int nr_pages, int grefs[]);
+int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref[],
+                          int nr_grefs, void **vaddr);
+int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_grefs,
+                   grant_handle_t handle[], void *vaddr);

 int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr);
 int xenbus_unmap_ring(struct xenbus_device *dev,
-                     grant_handle_t handle, void *vaddr);
+                     grant_handle_t handle[], int nr_handles,
+                     void *vaddr);

 int xenbus_alloc_evtchn(struct xenbus_device *dev, int *port);
 int xenbus_bind_evtchn(struct xenbus_device *dev, int remote_port, int *port);
