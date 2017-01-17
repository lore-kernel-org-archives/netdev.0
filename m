From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 05/10] drivers: base: Add
 device_find_in_class_name()
Date: Tue, 17 Jan 2017 15:21:47 -0800
Message-ID: <20170117232152.1661-6-f.fainelli@gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170117232152.1661-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add a helper function to lookup a device reference given a class name.
This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
make it more generic.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/base/core.c    | 31 +++++++++++++++++++++++++++++++
 include/linux/device.h |  2 ++
 2 files changed, 33 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 8c25e68e67d7..fb9fced38634 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -2058,6 +2058,37 @@ struct device *device_find_child(struct device *parent, void *data,
 }
 EXPORT_SYMBOL_GPL(device_find_child);
 
+static int device_class_name_match(struct device *dev, void *class)
+{
+	if (dev->class != NULL && !strcmp(dev->class->name, class))
+		return 1;
+
+	return 0;
+}
+
+/**
+ * device_find_in_class_name - device iterator for locating a particular device
+ * within the specified class name
+ * @parent: parent struct device
+ * @class_name: Class name to match against
+ *
+ * This function returns 1 if the device (specified by @parent), or one of its child
+ * is in the class whose name is specified by @class_name. Returns 0 otherwise.
+ *
+ * NOTE: you will need to drop the reference with put_device() after use.
+ */
+struct device *device_find_in_class_name(struct device *parent,
+					 char *class_name)
+{
+	if (device_class_name_match(parent, class_name)) {
+		get_device(parent);
+		return parent;
+	}
+
+	return device_find_child(parent, class_name, device_class_name_match);
+}
+EXPORT_SYMBOL_GPL(device_find_in_class_name);
+
 int __init devices_init(void)
 {
 	devices_kset = kset_create_and_add("devices", &device_uevent_ops, NULL);
diff --git a/include/linux/device.h b/include/linux/device.h
index 491b4c0ca633..fbc2a255f92e 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1120,6 +1120,8 @@ extern int device_for_each_child_reverse(struct device *dev, void *data,
 		     int (*fn)(struct device *dev, void *data));
 extern struct device *device_find_child(struct device *dev, void *data,
 				int (*match)(struct device *dev, void *data));
+extern struct device *device_find_in_class_name(struct device *parent,
+						char *class_name);
 extern int device_rename(struct device *dev, const char *new_name);
 extern int device_move(struct device *dev, struct device *new_parent,
 		       enum dpm_order dpm_order);
-- 
2.9.3
