From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv3 6/7] tap: tap as an independent module
Date: Mon, 30 Jan 2017 11:12:01 -0800
Message-ID: <1485803522-16564-7-git-send-email-sainath.grandhi@intel.com>
References: <1485803522-16564-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485803522-16564-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes tap a separate module for other types of virtual interfaces, for example,
ipvlan to use.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/Kconfig                       | 15 +++++++++++++++
 drivers/net/Makefile                      |  3 +--
 drivers/net/{macvtap_main.c => macvtap.c} |  0
 drivers/net/tap.c                         | 11 +++++++++++
 drivers/vhost/Kconfig                     |  2 +-
 include/linux/if_tap.h                    |  4 ++--
 6 files changed, 30 insertions(+), 5 deletions(-)
 rename drivers/net/{macvtap_main.c => macvtap.c} (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 95c32f2..1c88437 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -135,6 +135,7 @@ config MACVTAP
 	tristate "MAC-VLAN based tap driver"
 	depends on MACVLAN
 	depends on INET
+	depends on TAP
 	help
 	  This adds a specialized tap character device driver that is based
 	  on the MAC-VLAN network interface, called macvtap. A macvtap device
@@ -284,6 +285,20 @@ config TUN
 
 	  If you don't know what to use this for, you don't need it.
 
+config TAP
+        tristate "TAP module support for virtual interfaces"
+        ---help---
+          TAP module serves two purposes. This can be used as library of functions
+          for virtual interfaces to implement tap functionality.
+
+          This module also includes character device file and socket operations
+          that can be used by virtual interface implementing tap.
+
+          To compile this driver as a module, choose M here: the module
+          will be called tap.
+
+          If you don't know what to use this for, you don't need it.
+
 config TUN_VNET_CROSS_LE
 	bool "Support for cross-endian vnet headers on little-endian kernels"
 	default n
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 19b03a9..7dd86ca 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_PHYLIB) += phy/
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
+obj-$(CONFIG_TAP) += tap.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
@@ -29,8 +30,6 @@ obj-$(CONFIG_GTP) += gtp.o
 obj-$(CONFIG_NLMON) += nlmon.o
 obj-$(CONFIG_NET_VRF) += vrf.o
 
-macvtap-objs := macvtap_main.o tap.o
-
 #
 # Networking Drivers
 #
diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap.c
similarity index 100%
rename from drivers/net/macvtap_main.c
rename to drivers/net/macvtap.c
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 1219ee9..9f49280 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -311,6 +311,7 @@ void tap_del_queues(struct tap_dev *tap)
 	/* guarantee that any future tap_set_queue will fail */
 	tap->numvtaps = MAX_TAP_QUEUES;
 }
+EXPORT_SYMBOL_GPL(tap_del_queues);
 
 rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 {
@@ -388,6 +389,7 @@ rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 	kfree_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
+EXPORT_SYMBOL_GPL(tap_handle_frame);
 
 static struct major_info *tap_get_major(int major)
 {
@@ -422,6 +424,7 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 	mutex_unlock(&tap_major->minor_lock);
 	return retval < 0 ? retval : 0;
 }
+EXPORT_SYMBOL_GPL(tap_get_minor);
 
 void tap_free_minor(dev_t major, struct tap_dev *tap)
 {
@@ -438,6 +441,7 @@ void tap_free_minor(dev_t major, struct tap_dev *tap)
 	}
 	mutex_unlock(&tap_major->minor_lock);
 }
+EXPORT_SYMBOL_GPL(tap_free_minor);
 
 static struct tap_dev *dev_get_by_tap_file(int major, int minor)
 {
@@ -1193,6 +1197,7 @@ int tap_queue_resize(struct tap_dev *tap)
 	kfree(arrays);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(tap_queue_resize);
 
 static int tap_list_add(dev_t major, const char *device_name)
 {
@@ -1235,6 +1240,7 @@ int tap_create_cdev(struct cdev *tap_cdev,
 out1:
 	return err;
 }
+EXPORT_SYMBOL_GPL(tap_create_cdev);
 
 void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
 {
@@ -1248,3 +1254,8 @@ void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
 	unregister_chrdev_region(major, TAP_NUM_DEVS);
 	idr_destroy(&tap_major->minor_idr);
 }
+EXPORT_SYMBOL_GPL(tap_destroy_cdev);
+
+MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
+MODULE_AUTHOR("Sainath Grandhi <sainath.grandhi@intel.com>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 40764ec..cfdecea 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -1,6 +1,6 @@
 config VHOST_NET
 	tristate "Host kernel accelerator for virtio net"
-	depends on NET && EVENTFD && (TUN || !TUN) && (MACVTAP || !MACVTAP)
+	depends on NET && EVENTFD && (TUN || !TUN) && (TAP || !TAP)
 	select VHOST
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index 362e71c..3482c3c 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -1,7 +1,7 @@
 #ifndef _LINUX_IF_TAP_H_
 #define _LINUX_IF_TAP_H_
 
-#if IS_ENABLED(CONFIG_MACVTAP)
+#if IS_ENABLED(CONFIG_TAP)
 struct socket *tap_get_socket(struct file *);
 #else
 #include <linux/err.h>
@@ -12,7 +12,7 @@ static inline struct socket *tap_get_socket(struct file *f)
 {
 	return ERR_PTR(-EINVAL);
 }
-#endif /* CONFIG_MACVTAP */
+#endif /* CONFIG_TAP */
 
 #include <net/sock.h>
 #include <linux/skb_array.h>
-- 
2.7.4
