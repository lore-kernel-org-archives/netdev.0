From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: [PATCH v5 3/4] gpiolib: add devm_gpiod_get_array and devm_gpiod_put_array functions
Date: Wed, 11 Feb 2015 17:28:02 +0100
Message-ID: <71195660.CBS4fRPfXg@pcimr>
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
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device managed variants of gpiod_get_array() / gpiod_put_array()
functions for conveniently obtaining and disposing of an entire array
of GPIOs with one function call.

Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
---
Change log:
  v5: no change
  v4: no change
  v3: make the flags argument mandatory for the new functions
  v2: add this patch to the set

 Documentation/gpio/consumer.txt | 14 ++++++-
 drivers/gpio/devres.c           | 89 +++++++++++++++++++++++++++++++++++++++++
 include/linux/gpio/consumer.h   | 30 ++++++++++++++
 3 files changed, 131 insertions(+), 2 deletions(-)

diff --git a/Documentation/gpio/consumer.txt b/Documentation/gpio/consumer.txt
index 2924f2f..d29a972 100644
--- a/Documentation/gpio/consumer.txt
+++ b/Documentation/gpio/consumer.txt
@@ -102,11 +102,19 @@ Device-managed variants of these functions are also defined:
 						  const char *con_id,
 						  enum gpiod_flags flags)
 
-	struct gpio_desc * devm_gpiod_get_index_optional(struct device *dev,
+	struct gpio_desc *devm_gpiod_get_index_optional(struct device *dev,
 							const char *con_id,
 							unsigned int index,
 							enum gpiod_flags flags)
 
+	struct gpio_descs *devm_gpiod_get_array(struct device *dev,
+						const char *con_id,
+						enum gpiod_flags flags)
+
+	struct gpio_descs *devm_gpiod_get_array_optional(struct device *dev,
+							 const char *con_id,
+							 enum gpiod_flags flags)
+
 A GPIO descriptor can be disposed of using the gpiod_put() function:
 
 	void gpiod_put(struct gpio_desc *desc)
@@ -119,10 +127,12 @@ It is strictly forbidden to use a descriptor after calling these functions.
 It is also not allowed to individually release descriptors (using gpiod_put())
 from an array acquired with gpiod_get_array().
 
-The device-managed variant is, unsurprisingly:
+The device-managed variants are, unsurprisingly:
 
 	void devm_gpiod_put(struct device *dev, struct gpio_desc *desc)
 
+	void devm_gpiod_put_array(struct device *dev, struct gpio_descs *descs)
+
 
 Using GPIOs
 ===========
diff --git a/drivers/gpio/devres.c b/drivers/gpio/devres.c
index 13dbd3d..fbc5cb8 100644
--- a/drivers/gpio/devres.c
+++ b/drivers/gpio/devres.c
@@ -35,6 +35,20 @@ static int devm_gpiod_match(struct device *dev, void *res, void *data)
 	return *this == *gpio;
 }
 
+static void devm_gpiod_release_array(struct device *dev, void *res)
+{
+	struct gpio_descs **descs = res;
+
+	gpiod_put_array(*descs);
+}
+
+static int devm_gpiod_match_array(struct device *dev, void *res, void *data)
+{
+	struct gpio_descs **this = res, **gpios = data;
+
+	return *this == *gpios;
+}
+
 /**
  * devm_gpiod_get - Resource-managed gpiod_get()
  * @dev:	GPIO consumer
@@ -170,6 +184,66 @@ struct gpio_desc *__must_check __devm_gpiod_get_index_optional(struct device *de
 EXPORT_SYMBOL(__devm_gpiod_get_index_optional);
 
 /**
+ * devm_gpiod_get_array - Resource-managed gpiod_get_array()
+ * @dev:	GPIO consumer
+ * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
+ *
+ * Managed gpiod_get_array(). GPIO descriptors returned from this function are
+ * automatically disposed on driver detach. See gpiod_get_array() for detailed
+ * information about behavior and return values.
+ */
+struct gpio_descs *__must_check devm_gpiod_get_array(struct device *dev,
+						     const char *con_id,
+						     enum gpiod_flags flags)
+{
+	struct gpio_descs **dr;
+	struct gpio_descs *descs;
+
+	dr = devres_alloc(devm_gpiod_release_array,
+			  sizeof(struct gpio_descs *), GFP_KERNEL);
+	if (!dr)
+		return ERR_PTR(-ENOMEM);
+
+	descs = gpiod_get_array(dev, con_id, flags);
+	if (IS_ERR(descs)) {
+		devres_free(dr);
+		return descs;
+	}
+
+	*dr = descs;
+	devres_add(dev, dr);
+
+	return descs;
+}
+EXPORT_SYMBOL(devm_gpiod_get_array);
+
+/**
+ * devm_gpiod_get_array_optional - Resource-managed gpiod_get_array_optional()
+ * @dev:	GPIO consumer
+ * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
+ *
+ * Managed gpiod_get_array_optional(). GPIO descriptors returned from this
+ * function are automatically disposed on driver detach.
+ * See gpiod_get_array_optional() for detailed information about behavior and
+ * return values.
+ */
+struct gpio_descs *__must_check
+devm_gpiod_get_array_optional(struct device *dev, const char *con_id,
+			      enum gpiod_flags flags)
+{
+	struct gpio_descs *descs;
+
+	descs = devm_gpiod_get_array(dev, con_id, flags);
+	if (IS_ERR(descs) && (PTR_ERR(descs) == -ENOENT))
+		return NULL;
+
+	return descs;
+}
+EXPORT_SYMBOL(devm_gpiod_get_array_optional);
+
+/**
  * devm_gpiod_put - Resource-managed gpiod_put()
  * @desc:	GPIO descriptor to dispose of
  *
@@ -184,6 +258,21 @@ void devm_gpiod_put(struct device *dev, struct gpio_desc *desc)
 }
 EXPORT_SYMBOL(devm_gpiod_put);
 
+/**
+ * devm_gpiod_put_array - Resource-managed gpiod_put_array()
+ * @descs:	GPIO descriptor array to dispose of
+ *
+ * Dispose of an array of GPIO descriptors obtained with devm_gpiod_get_array().
+ * Normally this function will not be called as the GPIOs will be disposed of
+ * by the resource management code.
+ */
+void devm_gpiod_put_array(struct device *dev, struct gpio_descs *descs)
+{
+	WARN_ON(devres_release(dev, devm_gpiod_release_array,
+			       devm_gpiod_match_array, &descs));
+}
+EXPORT_SYMBOL(devm_gpiod_put_array);
+
 
 
 
diff --git a/include/linux/gpio/consumer.h b/include/linux/gpio/consumer.h
index f71cad6..6611a53 100644
--- a/include/linux/gpio/consumer.h
+++ b/include/linux/gpio/consumer.h
@@ -83,7 +83,14 @@ struct gpio_desc *__must_check __devm_gpiod_get_optional(struct device *dev,
 struct gpio_desc *__must_check
 __devm_gpiod_get_index_optional(struct device *dev, const char *con_id,
 			      unsigned int index, enum gpiod_flags flags);
+struct gpio_descs *__must_check devm_gpiod_get_array(struct device *dev,
+						     const char *con_id,
+						     enum gpiod_flags flags);
+struct gpio_descs *__must_check
+devm_gpiod_get_array_optional(struct device *dev, const char *con_id,
+			      enum gpiod_flags flags);
 void devm_gpiod_put(struct device *dev, struct gpio_desc *desc);
+void devm_gpiod_put_array(struct device *dev, struct gpio_descs *descs);
 
 int gpiod_get_direction(struct gpio_desc *desc);
 int gpiod_direction_input(struct gpio_desc *desc);
@@ -227,6 +234,20 @@ __devm_gpiod_get_index_optional(struct device *dev, const char *con_id,
 	return ERR_PTR(-ENOSYS);
 }
 
+static inline struct gpio_descs *__must_check
+devm_gpiod_get_array(struct device *dev, const char *con_id,
+		     enum gpiod_flags flags)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static inline struct gpio_descs *__must_check
+devm_gpiod_get_array_optional(struct device *dev, const char *con_id,
+			      enum gpiod_flags flags)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
 static inline void devm_gpiod_put(struct device *dev, struct gpio_desc *desc)
 {
 	might_sleep();
@@ -235,6 +256,15 @@ static inline void devm_gpiod_put(struct device *dev, struct gpio_desc *desc)
 	WARN_ON(1);
 }
 
+static inline void devm_gpiod_put_array(struct device *dev,
+					struct gpio_descs *descs)
+{
+	might_sleep();
+
+	/* GPIO can never have been requested */
+	WARN_ON(1);
+}
+
 
 static inline int gpiod_get_direction(const struct gpio_desc *desc)
 {
-- 
2.0.5


