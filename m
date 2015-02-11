From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: [PATCH v5 2/4] gpiolib: add gpiod_get_array and gpiod_put_array functions
Date: Wed, 11 Feb 2015 17:27:58 +0100
Message-ID: <3417970.NJsESPLFsD@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexandre Courbot <gnurou@gmail.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:52161 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbbBKQ2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 11:28:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce new functions for conveniently obtaining and disposing of an entire
array of GPIOs with one function call.

Suggested-by: Alexandre Courbot <acourbot@nvidia.com>
Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>

ACPI part:
Reviewed-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Tested-by: Mika Westerberg <mika.westerberg@linux.intel.com>

DT part:
Tested-by: Rojhalat Ibrahim <imr@rtschenk.de>
---
Change log:
  v5: move the ACPI functions to gpiolib-acpi.c
  v4: - use shorter names for members of struct gpio_descs
      - rename lut_gpio_count to platform_gpio_count for clarity
      - add check for successful memory allocation
      - use ERR_CAST()
  v3: - rebase on current linux-gpio devel branch
      - fix ACPI GPIO counting
      - allow for zero-sized arrays
      - make the flags argument mandatory for the new functions
      - clarify documentation
  v2: change interface

 Documentation/gpio/consumer.txt |  33 ++++++++-
 drivers/gpio/gpiolib-acpi.c     |  84 +++++++++++++++++++++++
 drivers/gpio/gpiolib.c          | 145 ++++++++++++++++++++++++++++++++++++++++
 drivers/gpio/gpiolib.h          |   7 ++
 include/linux/gpio/consumer.h   |  46 +++++++++++++
 5 files changed, 312 insertions(+), 3 deletions(-)

diff --git a/Documentation/gpio/consumer.txt b/Documentation/gpio/consumer.txt
index d85fbae..2924f2f 100644
--- a/Documentation/gpio/consumer.txt
+++ b/Documentation/gpio/consumer.txt
@@ -58,7 +58,6 @@ pattern where a GPIO is optional, the gpiod_get_optional() and
 gpiod_get_index_optional() functions can be used. These functions return NULL
 instead of -ENOENT if no GPIO has been assigned to the requested function:
 
-
 	struct gpio_desc *gpiod_get_optional(struct device *dev,
 					     const char *con_id,
 					     enum gpiod_flags flags)
@@ -68,6 +67,27 @@ instead of -ENOENT if no GPIO has been assigned to the requested function:
 						   unsigned int index,
 						   enum gpiod_flags flags)
 
+For a function using multiple GPIOs all of those can be obtained with one call:
+
+	struct gpio_descs *gpiod_get_array(struct device *dev,
+					   const char *con_id,
+					   enum gpiod_flags flags)
+
+This function returns a struct gpio_descs which contains an array of
+descriptors:
+
+	struct gpio_descs {
+		unsigned int ndescs;
+		struct gpio_desc *desc[];
+	}
+
+The following function returns NULL instead of -ENOENT if no GPIOs have been
+assigned to the requested function:
+
+	struct gpio_descs *gpiod_get_array_optional(struct device *dev,
+						    const char *con_id,
+						    enum gpiod_flags flags)
+
 Device-managed variants of these functions are also defined:
 
 	struct gpio_desc *devm_gpiod_get(struct device *dev, const char *con_id,
@@ -91,8 +111,15 @@ A GPIO descriptor can be disposed of using the gpiod_put() function:
 
 	void gpiod_put(struct gpio_desc *desc)
 
-It is strictly forbidden to use a descriptor after calling this function. The
-device-managed variant is, unsurprisingly:
+For an array of GPIOs this function can be used:
+
+	void gpiod_put_array(struct gpio_descs *descs)
+
+It is strictly forbidden to use a descriptor after calling these functions.
+It is also not allowed to individually release descriptors (using gpiod_put())
+from an array acquired with gpiod_get_array().
+
+The device-managed variant is, unsurprisingly:
 
 	void devm_gpiod_put(struct device *dev, struct gpio_desc *desc)
 
diff --git a/drivers/gpio/gpiolib-acpi.c b/drivers/gpio/gpiolib-acpi.c
index c0929d9..c491996 100644
--- a/drivers/gpio/gpiolib-acpi.c
+++ b/drivers/gpio/gpiolib-acpi.c
@@ -712,3 +712,87 @@ void acpi_gpiochip_remove(struct gpio_chip *chip)
 	acpi_detach_data(handle, acpi_gpio_chip_dh);
 	kfree(acpi_gpio);
 }
+
+static unsigned int acpi_gpio_package_count(const union acpi_object *obj)
+{
+	const union acpi_object *element = obj->package.elements;
+	const union acpi_object *end = element + obj->package.count;
+	unsigned int count = 0;
+
+	while (element < end) {
+		if (element->type == ACPI_TYPE_LOCAL_REFERENCE)
+			count++;
+
+		element++;
+	}
+	return count;
+}
+
+static int acpi_find_gpio_count(struct acpi_resource *ares, void *data)
+{
+	unsigned int *count = data;
+
+	if (ares->type == ACPI_RESOURCE_TYPE_GPIO)
+		*count += ares->data.gpio.pin_table_length;
+
+	return 1;
+}
+
+/**
+ * acpi_gpio_count - return the number of GPIOs associated with a
+ *		device / function or -ENOENT if no GPIO has been
+ *		assigned to the requested function.
+ * @dev:	GPIO consumer, can be NULL for system-global GPIOs
+ * @con_id:	function within the GPIO consumer
+ */
+int acpi_gpio_count(struct device *dev, const char *con_id)
+{
+	struct acpi_device *adev = ACPI_COMPANION(dev);
+	const union acpi_object *obj;
+	const struct acpi_gpio_mapping *gm;
+	int count = -ENOENT;
+	int ret;
+	char propname[32];
+	unsigned int i;
+
+	/* Try first from _DSD */
+	for (i = 0; i < ARRAY_SIZE(gpio_suffixes); i++) {
+		if (con_id && strcmp(con_id, "gpios"))
+			snprintf(propname, sizeof(propname), "%s-%s",
+				 con_id, gpio_suffixes[i]);
+		else
+			snprintf(propname, sizeof(propname), "%s",
+				 gpio_suffixes[i]);
+
+		ret = acpi_dev_get_property(adev, propname, ACPI_TYPE_ANY,
+					    &obj);
+		if (ret == 0) {
+			if (obj->type == ACPI_TYPE_LOCAL_REFERENCE)
+				count = 1;
+			else if (obj->type == ACPI_TYPE_PACKAGE)
+				count = acpi_gpio_package_count(obj);
+		} else if (adev->driver_gpios) {
+			for (gm = adev->driver_gpios; gm->name; gm++)
+				if (strcmp(propname, gm->name) == 0) {
+					count = gm->size;
+					break;
+				}
+		}
+		if (count >= 0)
+			break;
+	}
+
+	/* Then from plain _CRS GPIOs */
+	if (count < 0) {
+		struct list_head resource_list;
+		unsigned int crs_count = 0;
+
+		INIT_LIST_HEAD(&resource_list);
+		acpi_dev_get_resources(adev, &resource_list,
+				       acpi_find_gpio_count, &crs_count);
+		acpi_dev_free_resource_list(&resource_list);
+		if (crs_count > 0)
+			count = crs_count;
+	}
+	return count;
+}
diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index b71c351..2a25fba 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -1801,6 +1801,70 @@ static struct gpio_desc *gpiod_find(struct device *dev, const char *con_id,
 	return desc;
 }
 
+static int dt_gpio_count(struct device *dev, const char *con_id)
+{
+	int ret;
+	char propname[32];
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(gpio_suffixes); i++) {
+		if (con_id)
+			snprintf(propname, sizeof(propname), "%s-%s",
+				 con_id, gpio_suffixes[i]);
+		else
+			snprintf(propname, sizeof(propname), "%s",
+				 gpio_suffixes[i]);
+
+		ret = of_gpio_named_count(dev->of_node, propname);
+		if (ret >= 0)
+			break;
+	}
+	return ret;
+}
+
+static int platform_gpio_count(struct device *dev, const char *con_id)
+{
+	struct gpiod_lookup_table *table;
+	struct gpiod_lookup *p;
+	unsigned int count = 0;
+
+	table = gpiod_find_lookup_table(dev);
+	if (!table)
+		return -ENOENT;
+
+	for (p = &table->table[0]; p->chip_label; p++) {
+		if ((con_id && p->con_id && !strcmp(con_id, p->con_id)) ||
+		    (!con_id && !p->con_id))
+			count++;
+	}
+	if (!count)
+		return -ENOENT;
+
+	return count;
+}
+
+/**
+ * gpiod_count - return the number of GPIOs associated with a device / function
+ *		or -ENOENT if no GPIO has been assigned to the requested function
+ * @dev:	GPIO consumer, can be NULL for system-global GPIOs
+ * @con_id:	function within the GPIO consumer
+ */
+int gpiod_count(struct device *dev, const char *con_id)
+{
+	int count = -ENOENT;
+
+	if (IS_ENABLED(CONFIG_OF) && dev && dev->of_node)
+		count = dt_gpio_count(dev, con_id);
+	else if (IS_ENABLED(CONFIG_ACPI) && dev && ACPI_HANDLE(dev))
+		count = acpi_gpio_count(dev, con_id);
+
+	if (count < 0)
+		count = platform_gpio_count(dev, con_id);
+
+	return count;
+}
+EXPORT_SYMBOL_GPL(gpiod_count);
+
 /**
  * gpiod_get - obtain a GPIO for a given GPIO function
  * @dev:	GPIO consumer, can be NULL for system-global GPIOs
@@ -2002,6 +2066,72 @@ struct gpio_desc *__must_check __gpiod_get_index_optional(struct device *dev,
 EXPORT_SYMBOL_GPL(__gpiod_get_index_optional);
 
 /**
+ * gpiod_get_array - obtain multiple GPIOs from a multi-index GPIO function
+ * @dev:	GPIO consumer, can be NULL for system-global GPIOs
+ * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
+ *
+ * This function acquires all the GPIOs defined under a given function.
+ *
+ * Return a struct gpio_descs containing an array of descriptors, -ENOENT if
+ * no GPIO has been assigned to the requested function, or another IS_ERR()
+ * code if an error occurred while trying to acquire the GPIOs.
+ */
+struct gpio_descs *__must_check gpiod_get_array(struct device *dev,
+						const char *con_id,
+						enum gpiod_flags flags)
+{
+	struct gpio_desc *desc;
+	struct gpio_descs *descs;
+	int count;
+
+	count = gpiod_count(dev, con_id);
+	if (count < 0)
+		return ERR_PTR(count);
+
+	descs = kzalloc(sizeof(*descs) + sizeof(descs->desc[0]) * count,
+			GFP_KERNEL);
+	if (!descs)
+		return ERR_PTR(-ENOMEM);
+
+	for (descs->ndescs = 0; descs->ndescs < count; ) {
+		desc = gpiod_get_index(dev, con_id, descs->ndescs, flags);
+		if (IS_ERR(desc)) {
+			gpiod_put_array(descs);
+			return ERR_CAST(desc);
+		}
+		descs->desc[descs->ndescs] = desc;
+		descs->ndescs++;
+	}
+	return descs;
+}
+EXPORT_SYMBOL_GPL(gpiod_get_array);
+
+/**
+ * gpiod_get_array_optional - obtain multiple GPIOs from a multi-index GPIO
+ *                            function
+ * @dev:	GPIO consumer, can be NULL for system-global GPIOs
+ * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
+ *
+ * This is equivalent to gpiod_get_array(), except that when no GPIO was
+ * assigned to the requested function it will return NULL.
+ */
+struct gpio_descs *__must_check gpiod_get_array_optional(struct device *dev,
+							const char *con_id,
+							enum gpiod_flags flags)
+{
+	struct gpio_descs *descs;
+
+	descs = gpiod_get_array(dev, con_id, flags);
+	if (IS_ERR(descs) && (PTR_ERR(descs) == -ENOENT))
+		return NULL;
+
+	return descs;
+}
+EXPORT_SYMBOL_GPL(gpiod_get_array_optional);
+
+/**
  * gpiod_put - dispose of a GPIO descriptor
  * @desc:	GPIO descriptor to dispose of
  *
@@ -2013,6 +2143,21 @@ void gpiod_put(struct gpio_desc *desc)
 }
 EXPORT_SYMBOL_GPL(gpiod_put);
 
+/**
+ * gpiod_put_array - dispose of multiple GPIO descriptors
+ * @descs:	struct gpio_descs containing an array of descriptors
+ */
+void gpiod_put_array(struct gpio_descs *descs)
+{
+	unsigned int i;
+
+	for (i = 0; i < descs->ndescs; i++)
+		gpiod_put(descs->desc[i]);
+
+	kfree(descs);
+}
+EXPORT_SYMBOL_GPL(gpiod_put_array);
+
 #ifdef CONFIG_DEBUG_FS
 
 static void gpiolib_dbg_show(struct seq_file *s, struct gpio_chip *chip)
diff --git a/drivers/gpio/gpiolib.h b/drivers/gpio/gpiolib.h
index 3cbf3dd..054b401 100644
--- a/drivers/gpio/gpiolib.h
+++ b/drivers/gpio/gpiolib.h
@@ -40,6 +40,8 @@ void acpi_gpiochip_free_interrupts(struct gpio_chip *chip);
 struct gpio_desc *acpi_get_gpiod_by_index(struct acpi_device *adev,
 					  const char *propname, int index,
 					  struct acpi_gpio_info *info);
+
+int acpi_gpio_count(struct device *dev, const char *con_id);
 #else
 static inline void acpi_gpiochip_add(struct gpio_chip *chip) { }
 static inline void acpi_gpiochip_remove(struct gpio_chip *chip) { }
@@ -56,6 +58,11 @@ acpi_get_gpiod_by_index(struct acpi_device *adev, const char *propname,
 {
 	return ERR_PTR(-ENOSYS);
 }
+
+static inline int acpi_gpio_count(struct device *dev, const char *con_id)
+{
+	return -ENODEV;
+}
 #endif
 
 struct gpio_desc *of_get_named_gpiod_flags(struct device_node *np,
diff --git a/include/linux/gpio/consumer.h b/include/linux/gpio/consumer.h
index 45afc2d..f71cad6 100644
--- a/include/linux/gpio/consumer.h
+++ b/include/linux/gpio/consumer.h
@@ -16,6 +16,15 @@ struct device;
  */
 struct gpio_desc;
 
+/**
+ * Struct containing an array of descriptors that can be obtained using
+ * gpiod_get_array().
+ */
+struct gpio_descs {
+	unsigned int ndescs;
+	struct gpio_desc *desc[];
+};
+
 #define GPIOD_FLAGS_BIT_DIR_SET		BIT(0)
 #define GPIOD_FLAGS_BIT_DIR_OUT		BIT(1)
 #define GPIOD_FLAGS_BIT_DIR_VAL		BIT(2)
@@ -34,6 +43,9 @@ enum gpiod_flags {
 
 #ifdef CONFIG_GPIOLIB
 
+/* Return the number of GPIOs associated with a device / function */
+int gpiod_count(struct device *dev, const char *con_id);
+
 /* Acquire and dispose GPIOs */
 struct gpio_desc *__must_check __gpiod_get(struct device *dev,
 					 const char *con_id,
@@ -49,7 +61,14 @@ struct gpio_desc *__must_check __gpiod_get_index_optional(struct device *dev,
 							const char *con_id,
 							unsigned int index,
 							enum gpiod_flags flags);
+struct gpio_descs *__must_check gpiod_get_array(struct device *dev,
+						const char *con_id,
+						enum gpiod_flags flags);
+struct gpio_descs *__must_check gpiod_get_array_optional(struct device *dev,
+							const char *con_id,
+							enum gpiod_flags flags);
 void gpiod_put(struct gpio_desc *desc);
+void gpiod_put_array(struct gpio_descs *descs);
 
 struct gpio_desc *__must_check __devm_gpiod_get(struct device *dev,
 					      const char *con_id,
@@ -113,6 +132,11 @@ struct gpio_desc *devm_get_gpiod_from_child(struct device *dev,
 					    struct fwnode_handle *child);
 #else /* CONFIG_GPIOLIB */
 
+static inline int gpiod_count(struct device *dev, const char *con_id)
+{
+	return 0;
+}
+
 static inline struct gpio_desc *__must_check __gpiod_get(struct device *dev,
 						const char *con_id,
 						enum gpiod_flags flags)
@@ -142,6 +166,20 @@ __gpiod_get_index_optional(struct device *dev, const char *con_id,
 	return ERR_PTR(-ENOSYS);
 }
 
+static inline struct gpio_descs *__must_check
+gpiod_get_array(struct device *dev, const char *con_id,
+		enum gpiod_flags flags)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct gpio_descs *__must_check
+gpiod_get_array_optional(struct device *dev, const char *con_id,
+			 enum gpiod_flags flags)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
 static inline void gpiod_put(struct gpio_desc *desc)
 {
 	might_sleep();
@@ -150,6 +188,14 @@ static inline void gpiod_put(struct gpio_desc *desc)
 	WARN_ON(1);
 }
 
+static inline void gpiod_put_array(struct gpio_descs *descs)
+{
+	might_sleep();
+
+	/* GPIO can never have been requested */
+	WARN_ON(1);
+}
+
 static inline struct gpio_desc *__must_check
 __devm_gpiod_get(struct device *dev,
 		 const char *con_id,
-- 
2.0.5
