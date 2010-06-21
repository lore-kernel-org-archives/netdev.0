From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Mon, 21 Jun 2010 16:11:44 +0200
Message-ID: <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20100618073950.GA12822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Dmitry Torokhov <dtor@mail.ru>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, Anisse Astier <anisse@astier.eu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>,
	Eric Miao <eric.y.miao@gmail.com>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20100618073950.GA12822@pengutronix.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes the two similar functions platform_device_register_simple
and platform_device_register_data one line inline functions using a new
generic function platform_device_register_resndata.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

still unsolved is the naming issue, what do you think about
platform_device_register?

I marked the new function as __init_or_module in a separate patch to
make reverting it a bit easier, still I think it should be possible to
fix the caller if a problem occurs.

I changed the semantic slightly to only call
platform_device_add_resources if data !=3D NULL instead of size !=3D 0.=
  The
idea is to support wrappers like:

	#define add_blablub(id, pdata) \
		platform_device_register_resndata(NULL, "blablub", id, \
			NULL, 0, pdata, sizeof(struct blablub_platform_data))

that don't fail if pdata=3DNULL.  Ditto for res.

Best regards
Uwe

changed since v1:

 - fix docbook to pick up platform_device_register_simple and
   platform_device_register_data after moving them to
   <linux/platform_device.h>
 - only add_resources and add_data if res and data are non-NULL resp.

 Documentation/DocBook/device-drivers.tmpl |    1 +
 drivers/base/platform.c                   |  104 +++++++--------------=
-------
 include/linux/platform_device.h           |   62 ++++++++++++++++-
 3 files changed, 85 insertions(+), 82 deletions(-)

diff --git a/Documentation/DocBook/device-drivers.tmpl b/Documentation/=
DocBook/device-drivers.tmpl
index 1b2dd4f..ecd35e9 100644
--- a/Documentation/DocBook/device-drivers.tmpl
+++ b/Documentation/DocBook/device-drivers.tmpl
@@ -111,6 +111,7 @@ X!Edrivers/base/attribute_container.c
 <!--
 X!Edrivers/base/interface.c
 -->
+!Iinclude/linux/platform_device.h
 !Edrivers/base/platform.c
 !Edrivers/base/bus.c
      </sect1>
diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index 26eb69d..ffcfd73 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -344,108 +344,56 @@ void platform_device_unregister(struct platform_=
device *pdev)
 EXPORT_SYMBOL_GPL(platform_device_unregister);
=20
 /**
- * platform_device_register_simple - add a platform-level device and i=
ts resources
- * @name: base name of the device we're adding
- * @id: instance id
- * @res: set of resources that needs to be allocated for the device
- * @num: number of resources
- *
- * This function creates a simple platform device that requires minima=
l
- * resource and memory management. Canned release function freeing mem=
ory
- * allocated for the device allows drivers using such devices to be
- * unloaded without waiting for the last reference to the device to be
- * dropped.
+ * platform_device_register_resndata - add a platform-level device wit=
h
+ * resources and platform-specific data
  *
- * This interface is primarily intended for use with legacy drivers wh=
ich
- * probe hardware directly.  Because such drivers create sysfs device =
nodes
- * themselves, rather than letting system infrastructure handle such d=
evice
- * enumeration tasks, they don't fully conform to the Linux driver mod=
el.
- * In particular, when such drivers are built as modules, they can't b=
e
- * "hotplugged".
- *
- * Returns &struct platform_device pointer on success, or ERR_PTR() on=
 error.
- */
-struct platform_device *platform_device_register_simple(const char *na=
me,
-							int id,
-							const struct resource *res,
-							unsigned int num)
-{
-	struct platform_device *pdev;
-	int retval;
-
-	pdev =3D platform_device_alloc(name, id);
-	if (!pdev) {
-		retval =3D -ENOMEM;
-		goto error;
-	}
-
-	if (num) {
-		retval =3D platform_device_add_resources(pdev, res, num);
-		if (retval)
-			goto error;
-	}
-
-	retval =3D platform_device_add(pdev);
-	if (retval)
-		goto error;
-
-	return pdev;
-
-error:
-	platform_device_put(pdev);
-	return ERR_PTR(retval);
-}
-EXPORT_SYMBOL_GPL(platform_device_register_simple);
-
-/**
- * platform_device_register_data - add a platform-level device with pl=
atform-specific data
  * @parent: parent device for the device we're adding
  * @name: base name of the device we're adding
  * @id: instance id
+ * @res: set of resources that needs to be allocated for the device
+ * @num: number of resources
  * @data: platform specific data for this platform device
  * @size: size of platform specific data
  *
- * This function creates a simple platform device that requires minima=
l
- * resource and memory management. Canned release function freeing mem=
ory
- * allocated for the device allows drivers using such devices to be
- * unloaded without waiting for the last reference to the device to be
- * dropped.
- *
  * Returns &struct platform_device pointer on success, or ERR_PTR() on=
 error.
  */
-struct platform_device *platform_device_register_data(
+struct platform_device *platform_device_register_resndata(
 		struct device *parent,
 		const char *name, int id,
+		const struct resource *res, unsigned int num,
 		const void *data, size_t size)
 {
+	int ret =3D -ENOMEM;
 	struct platform_device *pdev;
-	int retval;
=20
 	pdev =3D platform_device_alloc(name, id);
-	if (!pdev) {
-		retval =3D -ENOMEM;
-		goto error;
-	}
+	if (!pdev)
+		goto err;
=20
 	pdev->dev.parent =3D parent;
=20
-	if (size) {
-		retval =3D platform_device_add_data(pdev, data, size);
-		if (retval)
-			goto error;
+	if (res) {
+		ret =3D platform_device_add_resources(pdev, res, num);
+		if (ret)
+			goto err;
 	}
=20
-	retval =3D platform_device_add(pdev);
-	if (retval)
-		goto error;
+	if (data) {
+		ret =3D platform_device_add_data(pdev, data, size);
+		if (ret)
+			goto err;
+	}
=20
-	return pdev;
+	ret =3D platform_device_add(pdev);
+	if (ret) {
+err:
+		platform_device_put(pdev);
+		return ERR_PTR(ret);
+	}
=20
-error:
-	platform_device_put(pdev);
-	return ERR_PTR(retval);
+	return pdev;
 }
-EXPORT_SYMBOL_GPL(platform_device_register_data);
+EXPORT_SYMBOL_GPL(platform_device_register_resndata);
=20
 static int platform_drv_probe(struct device *_dev)
 {
diff --git a/include/linux/platform_device.h b/include/linux/platform_d=
evice.h
index 5417944..d7ecad0 100644
--- a/include/linux/platform_device.h
+++ b/include/linux/platform_device.h
@@ -43,10 +43,64 @@ extern struct resource *platform_get_resource_bynam=
e(struct platform_device *, u
 extern int platform_get_irq_byname(struct platform_device *, const cha=
r *);
 extern int platform_add_devices(struct platform_device **, int);
=20
-extern struct platform_device *platform_device_register_simple(const c=
har *, int id,
-					const struct resource *, unsigned int);
-extern struct platform_device *platform_device_register_data(struct de=
vice *,
-		const char *, int, const void *, size_t);
+extern struct platform_device *platform_device_register_resndata(
+		struct device *parent, const char *name, int id,
+		const struct resource *res, unsigned int num,
+		const void *data, size_t size);
+
+/**
+ * platform_device_register_simple - add a platform-level device and i=
ts resources
+ * @name: base name of the device we're adding
+ * @id: instance id
+ * @res: set of resources that needs to be allocated for the device
+ * @num: number of resources
+ *
+ * This function creates a simple platform device that requires minima=
l
+ * resource and memory management. Canned release function freeing mem=
ory
+ * allocated for the device allows drivers using such devices to be
+ * unloaded without waiting for the last reference to the device to be
+ * dropped.
+ *
+ * This interface is primarily intended for use with legacy drivers wh=
ich
+ * probe hardware directly.  Because such drivers create sysfs device =
nodes
+ * themselves, rather than letting system infrastructure handle such d=
evice
+ * enumeration tasks, they don't fully conform to the Linux driver mod=
el.
+ * In particular, when such drivers are built as modules, they can't b=
e
+ * "hotplugged".
+ *
+ * Returns &struct platform_device pointer on success, or ERR_PTR() on=
 error.
+ */
+static inline struct platform_device *platform_device_register_simple(
+		const char *name, int id,
+		const struct resource *res, unsigned int num)
+{
+	return platform_device_register_resndata(NULL, name, id,
+			res, num, NULL, 0);
+}
+
+/**
+ * platform_device_register_data - add a platform-level device with pl=
atform-specific data
+ * @parent: parent device for the device we're adding
+ * @name: base name of the device we're adding
+ * @id: instance id
+ * @data: platform specific data for this platform device
+ * @size: size of platform specific data
+ *
+ * This function creates a simple platform device that requires minima=
l
+ * resource and memory management. Canned release function freeing mem=
ory
+ * allocated for the device allows drivers using such devices to be
+ * unloaded without waiting for the last reference to the device to be
+ * dropped.
+ *
+ * Returns &struct platform_device pointer on success, or ERR_PTR() on=
 error.
+ */
+static inline struct platform_device *platform_device_register_data(
+		struct device *parent, const char *name, int id,
+		const void *data, size_t size)
+{
+	return platform_device_register_resndata(parent, name, id,
+			NULL, 0, data, size);
+}
=20
 extern struct platform_device *platform_device_alloc(const char *name,=
 int id);
 extern int platform_device_add_resources(struct platform_device *pdev,
--=20
1.7.1

