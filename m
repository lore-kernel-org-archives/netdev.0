From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH, v2] Xen: consolidate and simplify struct xenbus_driver
 instantiation
Date: Thu, 22 Dec 2011 09:08:13 +0000
Message-ID: <4EF3018D020000780006986E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part4A65FB6D.9__="
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <davem@davemloft.net>,
	<dmitry.torokhov@gmail.com>, <FlorianSchandinat@gmx.de>,
	"Jens Axboe" <axboe@kernel.dk>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Konrad Rzeszutek Wilk" <konrad@darnok.org>,
	"Jeremy Fitzhardinge" <jeremy@goop.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part4A65FB6D.9__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

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

v2: Restore DRV_NAME for the driver name in xen-pciback.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David S. Miller <davem@davemloft.net>

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
 include/xen/xenbus.h                       |   31 ++++++++----------------=
-----
 13 files changed, 44 insertions(+), 92 deletions(-)

--- 3.2-rc6/drivers/block/xen-blkback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/block/xen-blkback/xenbus.c
@@ -787,17 +787,14 @@ static const struct xenbus_device_id xen
 };
=20
=20
-static struct xenbus_driver xen_blkbk =3D {
-	.name =3D "vbd",
-	.owner =3D THIS_MODULE,
-	.ids =3D xen_blkbk_ids,
+static DEFINE_XENBUS_DRIVER(xen_blkbk, ,
 	.probe =3D xen_blkbk_probe,
 	.remove =3D xen_blkbk_remove,
 	.otherend_changed =3D frontend_changed
-};
+);
=20
=20
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
=20
-static struct xenbus_driver blkfront =3D {
-	.name =3D "vbd",
-	.owner =3D THIS_MODULE,
-	.ids =3D blkfront_ids,
+static DEFINE_XENBUS_DRIVER(blkfront, ,
 	.probe =3D blkfront_probe,
 	.remove =3D blkfront_remove,
 	.resume =3D blkfront_resume,
 	.otherend_changed =3D blkback_changed,
 	.is_ready =3D blkfront_is_ready,
-};
+);
=20
 static int __init xlblk_init(void)
 {
@@ -1461,7 +1458,7 @@ static int __init xlblk_init(void)
 		return -ENODEV;
 	}
=20
-	ret =3D xenbus_register_frontend(&blkfront);
+	ret =3D xenbus_register_frontend(&blkfront_driver);
 	if (ret) {
 		unregister_blkdev(XENVBD_MAJOR, DEV_NAME);
 		return ret;
@@ -1474,7 +1471,7 @@ module_init(xlblk_init);
=20
 static void __exit xlblk_exit(void)
 {
-	return xenbus_unregister_driver(&blkfront);
+	return xenbus_unregister_driver(&blkfront_driver);
 }
 module_exit(xlblk_exit);
=20
--- 3.2-rc6/drivers/input/misc/xen-kbdfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/input/misc/xen-kbdfront.c
@@ -361,15 +361,12 @@ static const struct xenbus_device_id xen
 	{ "" }
 };
=20
-static struct xenbus_driver xenkbd_driver =3D {
-	.name =3D "vkbd",
-	.owner =3D THIS_MODULE,
-	.ids =3D xenkbd_ids,
+static DEFINE_XENBUS_DRIVER(xenkbd, ,
 	.probe =3D xenkbd_probe,
 	.remove =3D xenkbd_remove,
 	.resume =3D xenkbd_resume,
 	.otherend_changed =3D xenkbd_backend_changed,
-};
+);
=20
 static int __init xenkbd_init(void)
 {
--- 3.2-rc6/drivers/net/xen-netback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netback/xenbus.c
@@ -474,17 +474,14 @@ static const struct xenbus_device_id net
 };
=20
=20
-static struct xenbus_driver netback =3D {
-	.name =3D "vif",
-	.owner =3D THIS_MODULE,
-	.ids =3D netback_ids,
+static DEFINE_XENBUS_DRIVER(netback, ,
 	.probe =3D netback_probe,
 	.remove =3D netback_remove,
 	.uevent =3D netback_uevent,
 	.otherend_changed =3D frontend_changed,
-};
+);
=20
 int xenvif_xenbus_init(void)
 {
-	return xenbus_register_backend(&netback);
+	return xenbus_register_backend(&netback_driver);
 }
--- 3.2-rc6/drivers/net/xen-netfront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netfront.c
@@ -1910,7 +1910,7 @@ static void xennet_sysfs_delif(struct ne
=20
 #endif /* CONFIG_SYSFS */
=20
-static struct xenbus_device_id netfront_ids[] =3D {
+static const struct xenbus_device_id netfront_ids[] =3D {
 	{ "vif" },
 	{ "" }
 };
@@ -1937,15 +1937,12 @@ static int __devexit xennet_remove(struc
 	return 0;
 }
=20
-static struct xenbus_driver netfront_driver =3D {
-	.name =3D "vif",
-	.owner =3D THIS_MODULE,
-	.ids =3D netfront_ids,
+static DEFINE_XENBUS_DRIVER(netfront, ,
 	.probe =3D netfront_probe,
 	.remove =3D __devexit_p(xennet_remove),
 	.resume =3D netfront_resume,
 	.otherend_changed =3D netback_changed,
-};
+);
=20
 static int __init netif_init(void)
 {
--- 3.2-rc6/drivers/pci/xen-pcifront.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/pci/xen-pcifront.c
@@ -1126,14 +1126,11 @@ static const struct xenbus_device_id xen
 	{""},
 };
=20
-static struct xenbus_driver xenbus_pcifront_driver =3D {
-	.name			=3D "pcifront",
-	.owner			=3D THIS_MODULE,
-	.ids			=3D xenpci_ids,
+static DEFINE_XENBUS_DRIVER(xenpci, "pcifront",
 	.probe			=3D pcifront_xenbus_probe,
 	.remove			=3D pcifront_xenbus_remove,
 	.otherend_changed	=3D pcifront_backend_changed,
-};
+);
=20
 static int __init pcifront_init(void)
 {
@@ -1142,12 +1139,12 @@ static int __init pcifront_init(void)
=20
 	pci_frontend_registrar(1 /* enable */);
=20
-	return xenbus_register_frontend(&xenbus_pcifront_driver);
+	return xenbus_register_frontend(&xenpci_driver);
 }
=20
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
=20
-static struct xenbus_device_id xenfb_ids[] =3D {
+static const struct xenbus_device_id xenfb_ids[] =3D {
 	{ "vfb" },
 	{ "" }
 };
=20
-static struct xenbus_driver xenfb_driver =3D {
-	.name =3D "vfb",
-	.owner =3D THIS_MODULE,
-	.ids =3D xenfb_ids,
+static DEFINE_XENBUS_DRIVER(xenfb, ,
 	.probe =3D xenfb_probe,
 	.remove =3D xenfb_remove,
 	.resume =3D xenfb_resume,
 	.otherend_changed =3D xenfb_backend_changed,
-};
+);
=20
 static int __init xenfb_init(void)
 {
--- 3.2-rc6/drivers/xen/xen-pciback/xenbus.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xen-pciback/xenbus.c
@@ -707,19 +707,16 @@ static int xen_pcibk_xenbus_remove(struc
 	return 0;
 }
=20
-static const struct xenbus_device_id xenpci_ids[] =3D {
+static const struct xenbus_device_id xen_pcibk_ids[] =3D {
 	{"pci"},
 	{""},
 };
=20
-static struct xenbus_driver xenbus_xen_pcibk_driver =3D {
-	.name			=3D DRV_NAME,
-	.owner			=3D THIS_MODULE,
-	.ids			=3D xenpci_ids,
+static DEFINE_XENBUS_DRIVER(xen_pcibk, DRV_NAME,
 	.probe			=3D xen_pcibk_xenbus_probe,
 	.remove			=3D xen_pcibk_xenbus_remove,
 	.otherend_changed	=3D xen_pcibk_frontend_changed,
-};
+);
=20
 const struct xen_pcibk_backend *__read_mostly xen_pcibk_backend;
=20
@@ -735,11 +732,11 @@ int __init xen_pcibk_xenbus_register(voi
 	if (passthrough)
 		xen_pcibk_backend =3D &xen_pcibk_passthrough_backend;
 	pr_info(DRV_NAME ": backend is %s\n", xen_pcibk_backend->name);
-	return xenbus_register_backend(&xenbus_xen_pcibk_driver);
+	return xenbus_register_backend(&xen_pcibk_driver);
 }
=20
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
=20
 int xenbus_register_driver_common(struct xenbus_driver *drv,
-				  struct xen_bus_type *bus,
-				  struct module *owner,
-				  const char *mod_name)
+				  struct xen_bus_type *bus)
 {
-	drv->driver.name =3D drv->name;
 	drv->driver.bus =3D &bus->bus;
-	drv->driver.owner =3D owner;
-	drv->driver.mod_name =3D mod_name;
=20
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
=20
-int __xenbus_register_backend(struct xenbus_driver *drv,
-			      struct module *owner, const char *mod_name)
+int xenbus_register_backend(struct xenbus_driver *drv)
 {
 	drv->read_otherend_details =3D read_frontend_details;
=20
-	return xenbus_register_driver_common(drv, &xenbus_backend,
-					     owner, mod_name);
+	return xenbus_register_driver_common(drv, &xenbus_backend);
 }
-EXPORT_SYMBOL_GPL(__xenbus_register_backend);
+EXPORT_SYMBOL_GPL(xenbus_register_backend);
=20
 static int backend_probe_and_watch(struct notifier_block *notifier,
 				   unsigned long event,
--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe_frontend.c
+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe_frontend.c=

@@ -230,15 +230,13 @@ static void wait_for_devices(struct xenb
 			 print_device_status);
 }
=20
-int __xenbus_register_frontend(struct xenbus_driver *drv,
-			       struct module *owner, const char *mod_name)
+int xenbus_register_frontend(struct xenbus_driver *drv)
 {
 	int ret;
=20
 	drv->read_otherend_details =3D read_backend_details;
=20
-	ret =3D xenbus_register_driver_common(drv, &xenbus_frontend,
-					    owner, mod_name);
+	ret =3D xenbus_register_driver_common(drv, &xenbus_frontend);
 	if (ret)
 		return ret;
=20
@@ -247,7 +245,7 @@ int __xenbus_register_frontend(struct xe
=20
 	return 0;
 }
-EXPORT_SYMBOL_GPL(__xenbus_register_frontend);
+EXPORT_SYMBOL_GPL(xenbus_register_frontend);
=20
 static DECLARE_WAIT_QUEUE_HEAD(backend_state_wq);
 static int backend_state;
--- 3.2-rc6/include/xen/xenbus.h
+++ 3.2-rc6-struct-xenbus_driver/include/xen/xenbus.h
@@ -85,8 +85,6 @@ struct xenbus_device_id
=20
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
=20
-static inline struct xenbus_driver *to_xenbus_driver(struct device_driver =
*drv)
-{
-	return container_of(drv, struct xenbus_driver, driver);
+#define DEFINE_XENBUS_DRIVER(var, drvname, methods...)		\
+struct xenbus_driver var ## _driver =3D {				\
+	.driver.name =3D drvname + 0 ?: var ## _ids->devicetype,	\
+	.driver.owner =3D THIS_MODULE,				\
+	.ids =3D var ## _ids, ## methods				\
 }
=20
-int __must_check __xenbus_register_frontend(struct xenbus_driver *drv,
-					    struct module *owner,
-					    const char *mod_name);
-
-static inline int __must_check
-xenbus_register_frontend(struct xenbus_driver *drv)
+static inline struct xenbus_driver *to_xenbus_driver(struct device_driver =
*drv)
 {
-	WARN_ON(drv->owner !=3D THIS_MODULE);
-	return __xenbus_register_frontend(drv, THIS_MODULE, KBUILD_MODNAME)=
;
+	return container_of(drv, struct xenbus_driver, driver);
 }
=20
-int __must_check __xenbus_register_backend(struct xenbus_driver *drv,
-					   struct module *owner,
-					   const char *mod_name);
-static inline int __must_check
-xenbus_register_backend(struct xenbus_driver *drv)
-{
-	WARN_ON(drv->owner !=3D THIS_MODULE);
-	return __xenbus_register_backend(drv, THIS_MODULE, KBUILD_MODNAME);=

-}
+int __must_check xenbus_register_frontend(struct xenbus_driver *);
+int __must_check xenbus_register_backend(struct xenbus_driver *);
=20
 void xenbus_unregister_driver(struct xenbus_driver *drv);
=20



--=__Part4A65FB6D.9__=
Content-Type: text/plain; name="linux-3.2-rc6-struct-xenbus_driver.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="linux-3.2-rc6-struct-xenbus_driver.patch"

Xen: consolidate and simplify struct xenbus_driver instantiation=0A=0AThe =
'name', 'owner', and 'mod_name' members are redundant with the=0Aidenticall=
y named fields in the 'driver' sub-structure. Rather than=0Aswitching each =
instance to specify these fields explicitly, introduce=0Aa macro to =
simplify this.=0A=0AEliminate further redundancy by allowing the drvname =
argument to=0ADEFINE_XENBUS_DRIVER() to be blank (in which case the first =
entry from=0Athe ID table will be used for .driver.name).=0A=0AAlso =
eliminate the questionable xenbus_register_{back,front}end()=0Awrappers - =
their sole remaining purpose was the checking of the=0A'owner' field, =
proper setting of which shouldn't be an issue anymore=0Awhen the macro =
gets used.=0A=0Av2: Restore DRV_NAME for the driver name in xen-pciback.=0A=
=0ASigned-off-by: Jan Beulich <jbeulich@suse.com>=0ACc: Jens Axboe =
<axboe@kernel.dk>=0ACc: Dmitry Torokhov <dmitry.torokhov@gmail.com>=0ACc: =
Florian Tobias Schandinat <FlorianSchandinat@gmx.de>=0ACc: Ian Campbell =
<ian.campbell@citrix.com>=0ACc: David S. Miller <davem@davemloft.net>=0A=0A=
---=0A drivers/block/xen-blkback/xenbus.c         |    9 ++------=0A =
drivers/block/xen-blkfront.c               |   11 +++-------=0A drivers/inp=
ut/misc/xen-kbdfront.c          |    7 +-----=0A drivers/net/xen-netback/xe=
nbus.c           |    9 ++------=0A drivers/net/xen-netfront.c             =
    |    9 ++------=0A drivers/pci/xen-pcifront.c                 |   11 =
+++-------=0A drivers/video/xen-fbfront.c                |    9 ++------=0A=
 drivers/xen/xen-pciback/xenbus.c           |   13 ++++--------=0A =
drivers/xen/xenbus/xenbus_probe.c          |    7 ------=0A drivers/xen/xen=
bus/xenbus_probe.h          |    4 ---=0A drivers/xen/xenbus/xenbus_probe_b=
ackend.c  |    8 ++-----=0A drivers/xen/xenbus/xenbus_probe_frontend.c |   =
 8 ++-----=0A include/xen/xenbus.h                       |   31 ++++++++---=
------------------=0A 13 files changed, 44 insertions(+), 92 deletions(-)=
=0A=0A--- 3.2-rc6/drivers/block/xen-blkback/xenbus.c=0A+++ 3.2-rc6-struct-x=
enbus_driver/drivers/block/xen-blkback/xenbus.c=0A@@ -787,17 +787,14 @@ =
static const struct xenbus_device_id xen=0A };=0A =0A =0A-static struct =
xenbus_driver xen_blkbk =3D {=0A-	.name =3D "vbd",=0A-	.owner =3D =
THIS_MODULE,=0A-	.ids =3D xen_blkbk_ids,=0A+static DEFINE_XENBUS_DRI=
VER(xen_blkbk, ,=0A 	.probe =3D xen_blkbk_probe,=0A 	.remove =3D =
xen_blkbk_remove,=0A 	.otherend_changed =3D frontend_changed=0A-};=0A+);=
=0A =0A =0A int xen_blkif_xenbus_init(void)=0A {=0A-	return xenbus_regis=
ter_backend(&xen_blkbk);=0A+	return xenbus_register_backend(&xen_blkbk_d=
river);=0A }=0A--- 3.2-rc6/drivers/block/xen-blkfront.c=0A+++ 3.2-rc6-struc=
t-xenbus_driver/drivers/block/xen-blkfront.c=0A@@ -1437,16 +1437,13 @@ =
static const struct xenbus_device_id blk=0A 	{ "" }=0A };=0A =0A-static =
struct xenbus_driver blkfront =3D {=0A-	.name =3D "vbd",=0A-	.owner =3D =
THIS_MODULE,=0A-	.ids =3D blkfront_ids,=0A+static DEFINE_XENBUS_DRIV=
ER(blkfront, ,=0A 	.probe =3D blkfront_probe,=0A 	.remove =3D =
blkfront_remove,=0A 	.resume =3D blkfront_resume,=0A 	.otherend_c=
hanged =3D blkback_changed,=0A 	.is_ready =3D blkfront_is_ready,=0A-};=0A+)=
;=0A =0A static int __init xlblk_init(void)=0A {=0A@@ -1461,7 +1458,7 @@ =
static int __init xlblk_init(void)=0A 		return -ENODEV;=0A 	=
}=0A =0A-	ret =3D xenbus_register_frontend(&blkfront);=0A+	=
ret =3D xenbus_register_frontend(&blkfront_driver);=0A 	if (ret) {=0A 		=
unregister_blkdev(XENVBD_MAJOR, DEV_NAME);=0A 		return ret;=0A@@ =
-1474,7 +1471,7 @@ module_init(xlblk_init);=0A =0A static void __exit =
xlblk_exit(void)=0A {=0A-	return xenbus_unregister_driver(&blkfront);=
=0A+	return xenbus_unregister_driver(&blkfront_driver);=0A }=0A =
module_exit(xlblk_exit);=0A =0A--- 3.2-rc6/drivers/input/misc/xen-kbdfront.=
c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/input/misc/xen-kbdfront.c=0A@@=
 -361,15 +361,12 @@ static const struct xenbus_device_id xen=0A 	{ =
"" }=0A };=0A =0A-static struct xenbus_driver xenkbd_driver =3D {=0A-	=
.name =3D "vkbd",=0A-	.owner =3D THIS_MODULE,=0A-	.ids =3D xenkbd_ids=
,=0A+static DEFINE_XENBUS_DRIVER(xenkbd, ,=0A 	.probe =3D xenkbd_probe,=0A=
 	.remove =3D xenkbd_remove,=0A 	.resume =3D xenkbd_resume,=0A 	=
.otherend_changed =3D xenkbd_backend_changed,=0A-};=0A+);=0A =0A static =
int __init xenkbd_init(void)=0A {=0A--- 3.2-rc6/drivers/net/xen-netback/xen=
bus.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netback/xenbus.c=
=0A@@ -474,17 +474,14 @@ static const struct xenbus_device_id net=0A };=0A =
=0A =0A-static struct xenbus_driver netback =3D {=0A-	.name =3D =
"vif",=0A-	.owner =3D THIS_MODULE,=0A-	.ids =3D netback_ids,=0A+st=
atic DEFINE_XENBUS_DRIVER(netback, ,=0A 	.probe =3D netback_probe,=
=0A 	.remove =3D netback_remove,=0A 	.uevent =3D netback_uevent,=0A 	=
.otherend_changed =3D frontend_changed,=0A-};=0A+);=0A =0A int xenvif_xenbu=
s_init(void)=0A {=0A-	return xenbus_register_backend(&netback);=0A+	=
return xenbus_register_backend(&netback_driver);=0A }=0A--- 3.2-rc6/drivers=
/net/xen-netfront.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/net/xen-netf=
ront.c=0A@@ -1910,7 +1910,7 @@ static void xennet_sysfs_delif(struct ne=0A =
=0A #endif /* CONFIG_SYSFS */=0A =0A-static struct xenbus_device_id =
netfront_ids[] =3D {=0A+static const struct xenbus_device_id netfront_ids[]=
 =3D {=0A 	{ "vif" },=0A 	{ "" }=0A };=0A@@ -1937,15 +1937,12 @@ =
static int __devexit xennet_remove(struc=0A 	return 0;=0A }=0A =
=0A-static struct xenbus_driver netfront_driver =3D {=0A-	.name =3D =
"vif",=0A-	.owner =3D THIS_MODULE,=0A-	.ids =3D netfront_ids,=0A+s=
tatic DEFINE_XENBUS_DRIVER(netfront, ,=0A 	.probe =3D netfront_probe,=
=0A 	.remove =3D __devexit_p(xennet_remove),=0A 	.resume =3D =
netfront_resume,=0A 	.otherend_changed =3D netback_changed,=0A-};=0A+);=
=0A =0A static int __init netif_init(void)=0A {=0A--- 3.2-rc6/drivers/pci/x=
en-pcifront.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/pci/xen-pcifront.c=
=0A@@ -1126,14 +1126,11 @@ static const struct xenbus_device_id xen=0A 	=
{""},=0A };=0A =0A-static struct xenbus_driver xenbus_pcifront_driver =3D =
{=0A-	.name			=3D "pcifront",=0A-	.owner			=
=3D THIS_MODULE,=0A-	.ids			=3D xenpci_ids,=0A+static =
DEFINE_XENBUS_DRIVER(xenpci, "pcifront",=0A 	.probe			=
=3D pcifront_xenbus_probe,=0A 	.remove			=3D pcifront_xenbus=
_remove,=0A 	.otherend_changed	=3D pcifront_backend_changed,=0A-};=
=0A+);=0A =0A static int __init pcifront_init(void)=0A {=0A@@ -1142,12 =
+1139,12 @@ static int __init pcifront_init(void)=0A =0A 	pci_fronten=
d_registrar(1 /* enable */);=0A =0A-	return xenbus_register_frontend(&xe=
nbus_pcifront_driver);=0A+	return xenbus_register_frontend(&xenpci_dri=
ver);=0A }=0A =0A static void __exit pcifront_cleanup(void)=0A {=0A-	=
xenbus_unregister_driver(&xenbus_pcifront_driver);=0A+	xenbus_unregister_d=
river(&xenpci_driver);=0A 	pci_frontend_registrar(0 /* disable =
*/);=0A }=0A module_init(pcifront_init);=0A--- 3.2-rc6/drivers/video/xen-fb=
front.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/video/xen-fbfront.c=0A@@=
 -671,20 +671,17 @@ InitWait:=0A 	}=0A }=0A =0A-static struct =
xenbus_device_id xenfb_ids[] =3D {=0A+static const struct xenbus_device_id =
xenfb_ids[] =3D {=0A 	{ "vfb" },=0A 	{ "" }=0A };=0A =0A-static struct =
xenbus_driver xenfb_driver =3D {=0A-	.name =3D "vfb",=0A-	.owner =3D =
THIS_MODULE,=0A-	.ids =3D xenfb_ids,=0A+static DEFINE_XENBUS_DRIVER(=
xenfb, ,=0A 	.probe =3D xenfb_probe,=0A 	.remove =3D xenfb_remove,=
=0A 	.resume =3D xenfb_resume,=0A 	.otherend_changed =3D xenfb_backend=
_changed,=0A-};=0A+);=0A =0A static int __init xenfb_init(void)=0A {=0A--- =
3.2-rc6/drivers/xen/xen-pciback/xenbus.c=0A+++ 3.2-rc6-struct-xenbus_driver=
/drivers/xen/xen-pciback/xenbus.c=0A@@ -707,19 +707,16 @@ static int =
xen_pcibk_xenbus_remove(struc=0A 	return 0;=0A }=0A =0A-static const =
struct xenbus_device_id xenpci_ids[] =3D {=0A+static const struct =
xenbus_device_id xen_pcibk_ids[] =3D {=0A 	{"pci"},=0A 	{""},=0A =
};=0A =0A-static struct xenbus_driver xenbus_xen_pcibk_driver =3D {=0A-	=
.name			=3D DRV_NAME,=0A-	.owner			=
=3D THIS_MODULE,=0A-	.ids			=3D xenpci_ids,=0A+static =
DEFINE_XENBUS_DRIVER(xen_pcibk, DRV_NAME,=0A 	.probe			=
=3D xen_pcibk_xenbus_probe,=0A 	.remove			=3D xen_pcibk_xenbu=
s_remove,=0A 	.otherend_changed	=3D xen_pcibk_frontend_changed,=0A-=
};=0A+);=0A =0A const struct xen_pcibk_backend *__read_mostly xen_pcibk_bac=
kend;=0A =0A@@ -735,11 +732,11 @@ int __init xen_pcibk_xenbus_register(voi=
=0A 	if (passthrough)=0A 		xen_pcibk_backend =3D &xen_pcibk_pa=
ssthrough_backend;=0A 	pr_info(DRV_NAME ": backend is %s\n", xen_pcibk_bac=
kend->name);=0A-	return xenbus_register_backend(&xenbus_xen_pcibk_dr=
iver);=0A+	return xenbus_register_backend(&xen_pcibk_driver);=0A }=0A =
=0A void __exit xen_pcibk_xenbus_unregister(void)=0A {=0A 	destroy_wor=
kqueue(xen_pcibk_wq);=0A-	xenbus_unregister_driver(&xenbus_xen_pcibk_=
driver);=0A+	xenbus_unregister_driver(&xen_pcibk_driver);=0A }=0A--- =
3.2-rc6/drivers/xen/xenbus/xenbus_probe.c=0A+++ 3.2-rc6-struct-xenbus_drive=
r/drivers/xen/xenbus/xenbus_probe.c=0A@@ -291,14 +291,9 @@ void xenbus_dev_=
shutdown(struct device *=0A EXPORT_SYMBOL_GPL(xenbus_dev_shutdown);=0A =0A =
int xenbus_register_driver_common(struct xenbus_driver *drv,=0A-		=
		  struct xen_bus_type *bus,=0A-				  =
struct module *owner,=0A-				  const char =
*mod_name)=0A+				  struct xen_bus_type *bus)=0A =
{=0A-	drv->driver.name =3D drv->name;=0A 	drv->driver.bus =3D =
&bus->bus;=0A-	drv->driver.owner =3D owner;=0A-	drv->driver.mod_nam=
e =3D mod_name;=0A =0A 	return driver_register(&drv->driver);=0A }=0A--- =
3.2-rc6/drivers/xen/xenbus/xenbus_probe.h=0A+++ 3.2-rc6-struct-xenbus_drive=
r/drivers/xen/xenbus/xenbus_probe.h=0A@@ -53,9 +53,7 @@ extern int =
xenbus_match(struct device *_=0A extern int xenbus_dev_probe(struct device =
*_dev);=0A extern int xenbus_dev_remove(struct device *_dev);=0A extern =
int xenbus_register_driver_common(struct xenbus_driver *drv,=0A-		=
			 struct xen_bus_type *bus,=0A-				=
	 struct module *owner,=0A-					 =
const char *mod_name);=0A+					 struct =
xen_bus_type *bus);=0A extern int xenbus_probe_node(struct xen_bus_type =
*bus,=0A 			     const char *type,=0A 			=
     const char *nodename);=0A--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe_b=
ackend.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe=
_backend.c=0A@@ -232,15 +232,13 @@ int xenbus_dev_is_online(struct =
xenbus_d=0A }=0A EXPORT_SYMBOL_GPL(xenbus_dev_is_online);=0A =0A-int =
__xenbus_register_backend(struct xenbus_driver *drv,=0A-			=
      struct module *owner, const char *mod_name)=0A+int xenbus_register_ba=
ckend(struct xenbus_driver *drv)=0A {=0A 	drv->read_otherend_details =
=3D read_frontend_details;=0A =0A-	return xenbus_register_driver_commo=
n(drv, &xenbus_backend,=0A-					     =
owner, mod_name);=0A+	return xenbus_register_driver_common(drv, =
&xenbus_backend);=0A }=0A-EXPORT_SYMBOL_GPL(__xenbus_register_backend);=0A+=
EXPORT_SYMBOL_GPL(xenbus_register_backend);=0A =0A static int backend_probe=
_and_watch(struct notifier_block *notifier,=0A 				   =
unsigned long event,=0A--- 3.2-rc6/drivers/xen/xenbus/xenbus_probe_frontend=
.c=0A+++ 3.2-rc6-struct-xenbus_driver/drivers/xen/xenbus/xenbus_probe_front=
end.c=0A@@ -230,15 +230,13 @@ static void wait_for_devices(struct xenb=0A 	=
		 print_device_status);=0A }=0A =0A-int __xenbus_register_fr=
ontend(struct xenbus_driver *drv,=0A-			       struct =
module *owner, const char *mod_name)=0A+int xenbus_register_frontend(struct=
 xenbus_driver *drv)=0A {=0A 	int ret;=0A =0A 	drv->read_otherend_=
details =3D read_backend_details;=0A =0A-	ret =3D xenbus_register_dri=
ver_common(drv, &xenbus_frontend,=0A-					   =
 owner, mod_name);=0A+	ret =3D xenbus_register_driver_common(drv, =
&xenbus_frontend);=0A 	if (ret)=0A 		return ret;=0A =0A@@ =
-247,7 +245,7 @@ int __xenbus_register_frontend(struct xe=0A =0A 	=
return 0;=0A }=0A-EXPORT_SYMBOL_GPL(__xenbus_register_frontend);=0A+EXPORT_=
SYMBOL_GPL(xenbus_register_frontend);=0A =0A static DECLARE_WAIT_QUEUE_HEAD=
(backend_state_wq);=0A static int backend_state;=0A--- 3.2-rc6/include/xen/=
xenbus.h=0A+++ 3.2-rc6-struct-xenbus_driver/include/xen/xenbus.h=0A@@ =
-85,8 +85,6 @@ struct xenbus_device_id=0A =0A /* A xenbus driver. */=0A =
struct xenbus_driver {=0A-	char *name;=0A-	struct module *owner;=0A 	=
const struct xenbus_device_id *ids;=0A 	int (*probe)(struct xenbus_device =
*dev,=0A 		     const struct xenbus_device_id *id);=0A@@ =
-101,31 +99,20 @@ struct xenbus_driver {=0A 	int (*is_ready)(struct =
xenbus_device *dev);=0A };=0A =0A-static inline struct xenbus_driver =
*to_xenbus_driver(struct device_driver *drv)=0A-{=0A-	return container_of=
(drv, struct xenbus_driver, driver);=0A+#define DEFINE_XENBUS_DRIVER(var, =
drvname, methods...)		\=0A+struct xenbus_driver var ## _driver =
=3D {				\=0A+	.driver.name =3D drvname + 0 ?: =
var ## _ids->devicetype,	\=0A+	.driver.owner =3D THIS_MODULE,		=
		\=0A+	.ids =3D var ## _ids, ## methods			=
	\=0A }=0A =0A-int __must_check __xenbus_register_frontend(struct =
xenbus_driver *drv,=0A-					    struct module =
*owner,=0A-					    const char *mod_name);=
=0A-=0A-static inline int __must_check=0A-xenbus_register_frontend(struct =
xenbus_driver *drv)=0A+static inline struct xenbus_driver *to_xenbus_driver=
(struct device_driver *drv)=0A {=0A-	WARN_ON(drv->owner !=3D THIS_MODULE=
);=0A-	return __xenbus_register_frontend(drv, THIS_MODULE, KBUILD_MODNAME)=
;=0A+	return container_of(drv, struct xenbus_driver, driver);=0A }=0A =
=0A-int __must_check __xenbus_register_backend(struct xenbus_driver =
*drv,=0A-					   struct module *owner,=0A=
-					   const char *mod_name);=0A-static=
 inline int __must_check=0A-xenbus_register_backend(struct xenbus_driver =
*drv)=0A-{=0A-	WARN_ON(drv->owner !=3D THIS_MODULE);=0A-	return =
__xenbus_register_backend(drv, THIS_MODULE, KBUILD_MODNAME);=0A-}=0A+int =
__must_check xenbus_register_frontend(struct xenbus_driver *);=0A+int =
__must_check xenbus_register_backend(struct xenbus_driver *);=0A =0A void =
xenbus_unregister_driver(struct xenbus_driver *drv);=0A =0A
--=__Part4A65FB6D.9__=--
