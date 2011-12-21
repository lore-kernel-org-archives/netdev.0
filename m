From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Xen: consolidate and simplify struct xenbus_driver
 instantiation
Date: Wed, 21 Dec 2011 12:39:15 -0500
Message-ID: <20111221173915.GA15377@phenom.dumpdata.com>
References: <4EF210E7020000780006965E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	linux-kernel@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>, dmitry.torokhov@gmail.com,
	axboe@kernel.dk, FlorianSchandinat@gmx.de, ian.campbell@citrix.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4EF210E7020000780006965E@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2011 at 04:01:27PM +0000, Jan Beulich wrote:
> The 'name', 'owner', and 'mod_name' members are redundant with the
> identically named fields in the 'driver' sub-structure. Rather than
> switching each instance to specify these fields explicitly, introduce
> a macro to simplify this.
> 
> Eliminate further redundancy by allowing the drvname argument to
> DEFINE_XENBUS_DRIVER() to be blank (in which case the first entry from
> the ID table will be used for .driver.name).
> 
> Also eliminate the questionable xenbus_register_{back,front}end()
> wrappers - their sole remaining purpose was the checking of the
> 'owner' field, proper setting of which shouldn't be an issue anymore
> when the macro gets used.

Looks good, except:

a)  It also needs four ACKs from:

 1) block for block maintainer (Jens Axboe <axboe@kernel.dk> )
 2) kbdinput for input maintainer (Dmitry Torokhov <dmitry.torokhov@gmail.com)
 3) fbfront for the video maintainer (FlorianSchandinat@gmx.de)
 4) network for the network maintainer (Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org ,"David S. Miller" <davem@davemloft.net>)

CC-ing all of them.

b) this is changing it from xen-pciback to pciback:

> --- 3.2-rc6/drivers/xen/xen-pciback/xenbus.c
> +++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xen-pciback/xenbus.c
> @@ -707,19 +707,16 @@ static int xen_pcibk_xenbus_remove(struc
>  	return 0;
>  }
>  
> -static const struct xenbus_device_id xenpci_ids[] = {
> +static const struct xenbus_device_id xen_pcibk_ids[] = {
>  	{"pci"},
>  	{""},
>  };
>  
> -static struct xenbus_driver xenbus_xen_pcibk_driver = {
> -	.name			= DRV_NAME,
> -	.owner			= THIS_MODULE,
> -	.ids			= xenpci_ids,
> +static DEFINE_XENBUS_DRIVER(xen_pcibk, "pciback",
                                          ^^^^^^^^^
I think that should be "xen-pciback" or just DRV_NAME ?

>  	.probe			= xen_pcibk_xenbus_probe,
>  	.remove			= xen_pcibk_xenbus_remove,
>  	.otherend_changed	= xen_pcibk_frontend_changed,
> -};
> +);

Otherwise all the other changes look OK to me.

Here is the unchanged version of the patch for the other maintainers.

Xen: consolidate and simplify struct xenbus_driver instantiation

The 'name', 'owner', and 'mod_name' members are redundant with the
identically named fields in the 'driver' sub-structure. Rather than
switching each instance to specify these fields explicitly, introduce
a macro to simplify this.

Eliminate further redundancy by allowing the drvname argument to
DEFINE_XENBUS_DRIVER() to be blank (in which case the first entry from
the ID table will be used for .driver.name).

Also eliminate the questionable xenbus_register_{back,front}end()
wrappers - their sole remaining purpose was the checking of the
'owner' field, proper setting of which shouldn't be an issue anymore
when the macro gets used.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 drivers/block/xen-blkback/xenbus.c         |    9 ++------
 drivers/block/xen-blkfront.c               |   11 +++-------
 drivers/input/misc/xen-kbdfront.c          |    7 +-----
 drivers/net/xen-netback/xenbus.c           |    9 ++------
 drivers/net/xen-netfront.c                 |    9 ++------
 drivers/pci/xen-pcifront.c                 |   11 +++-------
 drivers/video/xen-fbfront.c                |    9 ++------
 drivers/xen/xen-pciback/xenbus.c           |   13 ++++--------
 drivers/xen/xenbus/xenbus_probe.c          |    7 ------
 drivers/xen/xenbus/xenbus_probe.h          |    4 ---
 drivers/xen/xenbus/xenbus_probe_backend.c  |    8 ++-----
 drivers/xen/xenbus/xenbus_probe_frontend.c |    8 ++-----
 include/xen/xenbus.h                       |   31 ++++++++---------------------
 13 files changed, 44 insertions(+), 92 deletions(-)

--- 3.2-rc6/drivers/block/xen-blkback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/block/xen-blkback/xenbus.c
@@ -787,17 +787,14 @@ static const struct xenbus_device_id xen
 };
 
 
-static struct xenbus_driver xen_blkbk = {
-	.name = "vbd",
-	.owner = THIS_MODULE,
-	.ids = xen_blkbk_ids,
+static DEFINE_XENBUS_DRIVER(xen_blkbk, ,
 	.probe = xen_blkbk_probe,
 	.remove = xen_blkbk_remove,
 	.otherend_changed = frontend_changed
-};
+);
 
 
 int xen_blkif_xenbus_init(void)
 {
-	return xenbus_register_backend(&xen_blkbk);
+	return xenbus_register_backend(&xen_blkbk_driver);
 }
--- 3.2-rc6/drivers/block/xen-blkfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/block/xen-blkfront.c
@@ -1437,16 +1437,13 @@ static const struct xenbus_device_id blk
 	{ "" }
 };
 
-static struct xenbus_driver blkfront = {
-	.name = "vbd",
-	.owner = THIS_MODULE,
-	.ids = blkfront_ids,
+static DEFINE_XENBUS_DRIVER(blkfront, ,
 	.probe = blkfront_probe,
 	.remove = blkfront_remove,
 	.resume = blkfront_resume,
 	.otherend_changed = blkback_changed,
 	.is_ready = blkfront_is_ready,
-};
+);
 
 static int __init xlblk_init(void)
 {
@@ -1461,7 +1458,7 @@ static int __init xlblk_init(void)
 		return -ENODEV;
 	}
 
-	ret = xenbus_register_frontend(&blkfront);
+	ret = xenbus_register_frontend(&blkfront_driver);
 	if (ret) {
 		unregister_blkdev(XENVBD_MAJOR, DEV_NAME);
 		return ret;
@@ -1474,7 +1471,7 @@ module_init(xlblk_init);
 
 static void __exit xlblk_exit(void)
 {
-	return xenbus_unregister_driver(&blkfront);
+	return xenbus_unregister_driver(&blkfront_driver);
 }
 module_exit(xlblk_exit);
 
--- 3.2-rc6/drivers/input/misc/xen-kbdfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/input/misc/xen-kbdfront.c
@@ -361,15 +361,12 @@ static const struct xenbus_device_id xen
 	{ "" }
 };
 
-static struct xenbus_driver xenkbd_driver = {
-	.name = "vkbd",
-	.owner = THIS_MODULE,
-	.ids = xenkbd_ids,
+static DEFINE_XENBUS_DRIVER(xenkbd, ,
 	.probe = xenkbd_probe,
 	.remove = xenkbd_remove,
 	.resume = xenkbd_resume,
 	.otherend_changed = xenkbd_backend_changed,
-};
+);
 
 static int __init xenkbd_init(void)
 {
--- 3.2-rc6/drivers/net/xen-netback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netback/xenbus.c
@@ -474,17 +474,14 @@ static const struct xenbus_device_id net
 };
 
 
-static struct xenbus_driver netback = {
-	.name = "vif",
-	.owner = THIS_MODULE,
-	.ids = netback_ids,
+static DEFINE_XENBUS_DRIVER(netback, ,
 	.probe = netback_probe,
 	.remove = netback_remove,
 	.uevent = netback_uevent,
 	.otherend_changed = frontend_changed,
-};
+);
 
 int xenvif_xenbus_init(void)
 {
-	return xenbus_register_backend(&netback);
+	return xenbus_register_backend(&netback_driver);
 }
--- 3.2-rc6/drivers/net/xen-netfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netfront.c
@@ -1910,7 +1910,7 @@ static void xennet_sysfs_delif(struct ne
 
 #endif /* CONFIG_SYSFS */
 
-static struct xenbus_device_id netfront_ids[] = {
+static const struct xenbus_device_id netfront_ids[] = {
 	{ "vif" },
 	{ "" }
 };
@@ -1937,15 +1937,12 @@ static int __devexit xennet_remove(struc
 	return 0;
 }
 
-static struct xenbus_driver netfront_driver = {
-	.name = "vif",
-	.owner = THIS_MODULE,
-	.ids = netfront_ids,
+static DEFINE_XENBUS_DRIVER(netfront, ,
 	.probe = netfront_probe,
 	.remove = __devexit_p(xennet_remove),
 	.resume = netfront_resume,
 	.otherend_changed = netback_changed,
-};
+);
 
 static int __init netif_init(void)
 {
--- 3.2-rc6/drivers/pci/xen-pcifront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/pci/xen-pcifront.c
@@ -1126,14 +1126,11 @@ static const struct xenbus_device_id xen
 	{""},
 };
 
-static struct xenbus_driver xenbus_pcifront_driver = {
-	.name			= "pcifront",
-	.owner			= THIS_MODULE,
-	.ids			= xenpci_ids,
+static DEFINE_XENBUS_DRIVER(xenpci, "pcifront",
 	.probe			= pcifront_xenbus_probe,
 	.remove			= pcifront_xenbus_remove,
 	.otherend_changed	= pcifront_backend_changed,
-};
+);
 
 static int __init pcifront_init(void)
 {
@@ -1142,12 +1139,12 @@ static int __init pcifront_init(void)
 
 	pci_frontend_registrar(1 /* enable */);
 
-	return xenbus_register_frontend(&xenbus_pcifront_driver);
+	return xenbus_register_frontend(&xenpci_driver);
 }
 
 static void __exit pcifront_cleanup(void)
 {
-	xenbus_unregister_driver(&xenbus_pcifront_driver);
+	xenbus_unregister_driver(&xenpci_driver);
 	pci_frontend_registrar(0 /* disable */);
 }
 module_init(pcifront_init);
--- 3.2-rc6/drivers/video/xen-fbfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/video/xen-fbfront.c
@@ -671,20 +671,17 @@ InitWait:
 	}
 }
 
-static struct xenbus_device_id xenfb_ids[] = {
+static const struct xenbus_device_id xenfb_ids[] = {
 	{ "vfb" },
 	{ "" }
 };
 
-static struct xenbus_driver xenfb_driver = {
-	.name = "vfb",
-	.owner = THIS_MODULE,
-	.ids = xenfb_ids,
+static DEFINE_XENBUS_DRIVER(xenfb, ,
 	.probe = xenfb_probe,
 	.remove = xenfb_remove,
 	.resume = xenfb_resume,
 	.otherend_changed = xenfb_backend_changed,
-};
+);
 
 static int __init xenfb_init(void)
 {
--- 3.2-rc6/drivers/xen/xen-pciback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xen-pciback/xenbus.c
@@ -707,19 +707,16 @@ static int xen_pcibk_xenbus_remove(struc
 	return 0;
 }
 
-static const struct xenbus_device_id xenpci_ids[] = {
+static const struct xenbus_device_id xen_pcibk_ids[] = {
 	{"pci"},
 	{""},
 };
 
-static struct xenbus_driver xenbus_xen_pcibk_driver = {
-	.name			= DRV_NAME,
-	.owner			= THIS_MODULE,
-	.ids			= xenpci_ids,
+static DEFINE_XENBUS_DRIVER(xen_pcibk, "pciback",
 	.probe			= xen_pcibk_xenbus_probe,
 	.remove			= xen_pcibk_xenbus_remove,
 	.otherend_changed	= xen_pcibk_frontend_changed,
-};
+);
 
 const struct xen_pcibk_backend *__read_mostly xen_pcibk_backend;
 
@@ -735,11 +732,11 @@ int __init xen_pcibk_xenbus_register(voi
 	if (passthrough)
 		xen_pcibk_backend = &xen_pcibk_passthrough_backend;
 	pr_info(DRV_NAME ": backend is %s\n", xen_pcibk_backend->name);
-	return xenbus_register_backend(&xenbus_xen_pcibk_driver);
+	return xenbus_register_backend(&xen_pcibk_driver);
 }
 
 void __exit xen_pcibk_xenbus_unregister(void)
 {
 	destroy_workqueue(xen_pcibk_wq);
-	xenbus_unregister_driver(&xenbus_xen_pcibk_driver);
+	xenbus_unregister_driver(&xen_pcibk_driver);
 }
--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe.c
@@ -291,14 +291,9 @@ void xenbus_dev_shutdown(struct device *
 EXPORT_SYMBOL_GPL(xenbus_dev_shutdown);
 
 int xenbus_register_driver_common(struct xenbus_driver *drv,
-				  struct xen_bus_type *bus,
-				  struct module *owner,
-				  const char *mod_name)
+				  struct xen_bus_type *bus)
 {
-	drv->driver.name = drv->name;
 	drv->driver.bus = &bus->bus;
-	drv->driver.owner = owner;
-	drv->driver.mod_name = mod_name;
 
 	return driver_register(&drv->driver);
 }
--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe.h
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe.h
@@ -53,9 +53,7 @@ extern int xenbus_match(struct device *_
 extern int xenbus_dev_probe(struct device *_dev);
 extern int xenbus_dev_remove(struct device *_dev);
 extern int xenbus_register_driver_common(struct xenbus_driver *drv,
-					 struct xen_bus_type *bus,
-					 struct module *owner,
-					 const char *mod_name);
+					 struct xen_bus_type *bus);
 extern int xenbus_probe_node(struct xen_bus_type *bus,
 			     const char *type,
 			     const char *nodename);
--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe_backend.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe_backend.c
@@ -232,15 +232,13 @@ int xenbus_dev_is_online(struct xenbus_d
 }
 EXPORT_SYMBOL_GPL(xenbus_dev_is_online);
 
-int __xenbus_register_backend(struct xenbus_driver *drv,
-			      struct module *owner, const char *mod_name)
+int xenbus_register_backend(struct xenbus_driver *drv)
 {
 	drv->read_otherend_details = read_frontend_details;
 
-	return xenbus_register_driver_common(drv, &xenbus_backend,
-					     owner, mod_name);
+	return xenbus_register_driver_common(drv, &xenbus_backend);
 }
-EXPORT_SYMBOL_GPL(__xenbus_register_backend);
+EXPORT_SYMBOL_GPL(xenbus_register_backend);
 
 static int backend_probe_and_watch(struct notifier_block *notifier,
 				   unsigned long event,
--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe_frontend.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe_frontend.c
@@ -230,15 +230,13 @@ static void wait_for_devices(struct xenb
 			 print_device_status);
 }
 
-int __xenbus_register_frontend(struct xenbus_driver *drv,
-			       struct module *owner, const char *mod_name)
+int xenbus_register_frontend(struct xenbus_driver *drv)
 {
 	int ret;
 
 	drv->read_otherend_details = read_backend_details;
 
-	ret = xenbus_register_driver_common(drv, &xenbus_frontend,
-					    owner, mod_name);
+	ret = xenbus_register_driver_common(drv, &xenbus_frontend);
 	if (ret)
 		return ret;
 
@@ -247,7 +245,7 @@ int __xenbus_register_frontend(struct xe
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(__xenbus_register_frontend);
+EXPORT_SYMBOL_GPL(xenbus_register_frontend);
 
 static DECLARE_WAIT_QUEUE_HEAD(backend_state_wq);
 static int backend_state;
--- 3.2-rc6/include/xen/xenbus.h
+++ 3.2-rc6-struct-xenbus_driver/include/xen/xenbus.h
@@ -85,8 +85,6 @@ struct xenbus_device_id
 
 /* A xenbus driver. */
 struct xenbus_driver {
-	char *name;
-	struct module *owner;
 	const struct xenbus_device_id *ids;
 	int (*probe)(struct xenbus_device *dev,
 		     const struct xenbus_device_id *id);
@@ -101,31 +99,20 @@ struct xenbus_driver {
 	int (*is_ready)(struct xenbus_device *dev);
 };
 
-static inline struct xenbus_driver *to_xenbus_driver(struct device_driver *drv)
-{
-	return container_of(drv, struct xenbus_driver, driver);
+#define DEFINE_XENBUS_DRIVER(var, drvname, methods...)		\
+struct xenbus_driver var ## _driver = {				\
+	.driver.name = drvname + 0 ?: var ## _ids->devicetype,	\
+	.driver.owner = THIS_MODULE,				\
+	.ids = var ## _ids, ## methods				\
 }
 
-int __must_check __xenbus_register_frontend(struct xenbus_driver *drv,
-					    struct module *owner,
-					    const char *mod_name);
-
-static inline int __must_check
-xenbus_register_frontend(struct xenbus_driver *drv)
+static inline struct xenbus_driver *to_xenbus_driver(struct device_driver *drv)
 {
-	WARN_ON(drv->owner != THIS_MODULE);
-	return __xenbus_register_frontend(drv, THIS_MODULE, KBUILD_MODNAME);
+	return container_of(drv, struct xenbus_driver, driver);
 }
 
-int __must_check __xenbus_register_backend(struct xenbus_driver *drv,
-					   struct module *owner,
-					   const char *mod_name);
-static inline int __must_check
-xenbus_register_backend(struct xenbus_driver *drv)
-{
-	WARN_ON(drv->owner != THIS_MODULE);
-	return __xenbus_register_backend(drv, THIS_MODULE, KBUILD_MODNAME);
-}
+int __must_check xenbus_register_frontend(struct xenbus_driver *);
+int __must_check xenbus_register_backend(struct xenbus_driver *);
 
 void xenbus_unregister_driver(struct xenbus_driver *drv);
 
