From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 4 2/4] NET ethernet introduce mac_platform helper
Date: Thu, 05 Jul 2012 10:44:49 +0800
Message-ID: <20120705024446.26317.49693.stgit@build.warmcat.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20120705024259.26317.16000.stgit@build.warmcat.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Green <andy@warmcat.com>

This introduces a small helper in net/ethernet, which registers a network
notifier at core_initcall time, and accepts registrations mapping expected
asynchronously-probed network device paths (like, "usb1/1-1/1-1.1/1-1.1:1.0")
and the MAC that is needed to be assigned to the device when it appears.

This allows platform code to enforce valid, consistent MAC addresses on to
devices that have not been probed at boot-time, but due to being wired on the
board are always present at the same interface.  It has been tested with USB
and SDIO probed devices.

Other parts of this series provide an OMAP API that computes a valid
locally administered MAC address from CPU ID bits that are unique for each
physical SoC, and register those against devices wired to the board.

This solves a longstanding problem in at least Panda case that there are no
reserved MACs for either onboard Ethernet nor onboard WLAN module, and without
this patch a randomized MAC is assigned to Ethernet and 00:00:00:00:00:00 or
0xdeadbeef is assigned as the WLAN MAC address.  The series provides sane,
constant locally-administered MAC addresses that have a high probability of
differing between boards.

To make use of this safely you also need to make sure that any drivers that
may compete for the bus ordinal you are using (eg, mUSB and ehci in Panda
case) are loaded in a deterministic order.

At registration it makes a copy of the incoming data, so the data may be
__initdata or otherwise transitory.  Registration can be called multiple times
so registrations from Device Tree and platform may be mixed.

Since it needs to be called quite early in boot and there is no lifecycle for
what it does, it could not be modular and is not a driver.

Via suggestions from Arnd Bergmann and Tony Lindgren (and Alan Cox for the
network notifier concept).

Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Andy Green <andy.green@linaro.org>
---
 include/net/mac-platform.h  |   39 +++++++++++
 net/Kconfig                 |    5 +
 net/ethernet/Makefile       |    3 +
 net/ethernet/mac-platform.c |  151 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 197 insertions(+), 1 deletion(-)
 create mode 100644 include/net/mac-platform.h
 create mode 100644 net/ethernet/mac-platform.c

diff --git a/include/net/mac-platform.h b/include/net/mac-platform.h
new file mode 100644
index 0000000..3a59098
--- /dev/null
+++ b/include/net/mac-platform.h
@@ -0,0 +1,39 @@
+/*
+ * mac-platform.h:  Enforces platform-defined MAC for Async probed devices
+ */
+
+#ifndef __NET_MAC_PLATFORM_H__
+#define __NET_MAC_PLATFORM_H__
+
+#include <linux/if_ether.h>
+
+/**
+ * struct mac_platform - associates asynchronously probed device path with
+ *			 MAC address to be assigned to the device when it
+ *			 is created
+ *
+ * @device_path: device path name of network device
+ * @mac: MAC address to assign to network device matching device path
+ * @list: can be left uninitialized when passing from platform
+ */
+
+struct mac_platform {
+	char *device_path;
+	u8 mac[ETH_ALEN];
+	struct list_head list; /* unused in platform data usage */
+};
+
+#ifdef CONFIG_NET
+/**
+ * mac_platform_register_device_macs - add an array of device path to monitor
+ *                                  and MAC to apply when the network device
+ *                                  at the device path appears
+ * @macs: array of struct mac_platform terminated by entry with
+ *	  NULL device_path
+ */
+int mac_platform_register_device_macs(const struct mac_platform *macs);
+#else
+static inline int mac_platform_register_device_macs(macs) { return 0; }
+#endif /* !CONFIG_NET */
+
+#endif /* __NET_MAC_PLATFORM_H__ */
diff --git a/net/Kconfig b/net/Kconfig
index 245831b..487c9e6 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -335,9 +335,12 @@ source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
 source "net/nfc/Kconfig"
 
-
 endif   # if NET
 
+# used by board / dt platform to enforce MACs for Async-probed devices
+config MAC_PLATFORM
+	bool
+
 # Used by archs to tell that they support BPF_JIT
 config HAVE_BPF_JIT
 	bool
diff --git a/net/ethernet/Makefile b/net/ethernet/Makefile
index 7cef1d8..475db2b 100644
--- a/net/ethernet/Makefile
+++ b/net/ethernet/Makefile
@@ -5,3 +5,6 @@
 obj-y					+= eth.o
 obj-$(subst m,y,$(CONFIG_IPX))		+= pe2.o
 obj-$(subst m,y,$(CONFIG_ATALK))	+= pe2.o
+ifneq ($(CONFIG_NET),)
+obj-$(CONFIG_MAC_PLATFORM)		+= mac-platform.o
+endif
diff --git a/net/ethernet/mac-platform.c b/net/ethernet/mac-platform.c
new file mode 100644
index 0000000..88e50ce
--- /dev/null
+++ b/net/ethernet/mac-platform.c
@@ -0,0 +1,151 @@
+/*
+ * Helper to allow platform code to enforce association of a locally-
+ * administered MAC address automatically on asynchronously probed devices,
+ * such as SDIO and USB based devices.
+ *
+ * Because the "device path" is used for matching, this is only useful for
+ * network assets physcally wired on the board, and also requires any
+ * different drivers that can compete for bus ordinals (eg mUSB vs ehci) to
+ * have fixed initialization ordering, eg, by having ehci in monolithic
+ * kernel
+ *
+ * Neither a driver nor a module as needs to be callable from machine file
+ * before the network devices are registered.
+ *
+ * (c) 2012 Andy Green <andy.green@linaro.org>
+ */
+
+#include <linux/netdevice.h>
+#include <net/mac-platform.h>
+
+static LIST_HEAD(mac_platform_list);
+static DEFINE_MUTEX(mac_platform_mutex);
+
+static struct mac_platform *__mac_platform_check(struct device *dev)
+{
+	const char *path;
+	const char *p;
+	const char *try;
+	int len;
+	struct device *devn;
+	struct mac_platform *tmp;
+	struct list_head *pos;
+
+	list_for_each(pos, &mac_platform_list) {
+
+		tmp = list_entry(pos, struct mac_platform, list);
+
+		try = tmp->device_path;
+
+		p = try + strlen(try);
+		devn = dev;
+
+		while (devn) {
+
+			path = dev_name(devn);
+			len = strlen(path);
+
+			if ((p - try) < len) {
+				devn = NULL;
+				continue;
+			}
+
+			p -= len;
+
+			if (strncmp(path, p, len)) {
+				devn = NULL;
+				continue;
+			}
+
+			devn = devn->parent;
+			if (p == try)
+				return tmp;
+
+			if (devn != NULL && (p - try) < 2)
+				devn = NULL;
+
+			p--;
+			if (devn != NULL && *p != '/')
+				devn = NULL;
+		}
+	}
+
+	return NULL;
+}
+
+static int mac_platform_netdev_event(struct notifier_block *this,
+						unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct sockaddr sa;
+	struct mac_platform *match;
+
+	if (event != NETDEV_REGISTER)
+		return NOTIFY_DONE;
+
+	mutex_lock(&mac_platform_mutex);
+
+	match = __mac_platform_check(dev->dev.parent);
+	if (match == NULL)
+		goto bail;
+
+	sa.sa_family = dev->type;
+	memcpy(sa.sa_data, match->mac, sizeof match->mac);
+	dev->netdev_ops->ndo_set_mac_address(dev, &sa);
+
+bail:
+	mutex_unlock(&mac_platform_mutex);
+
+	return NOTIFY_DONE;
+}
+
+int mac_platform_register_device_macs(const struct mac_platform *macs)
+{
+	struct mac_platform *next;
+	int ret = 0;
+
+	mutex_lock(&mac_platform_mutex);
+
+	while (macs->device_path) {
+
+		next = kmalloc(sizeof(struct mac_platform), GFP_KERNEL);
+		if (!next) {
+			ret = -ENOMEM;
+			goto bail;
+		}
+
+		next->device_path = kmalloc(strlen(macs->device_path) + 1,
+								   GFP_KERNEL);
+		if (!next->device_path) {
+			ret = -ENOMEM;
+			goto bail;
+		}
+
+		strcpy(next->device_path, macs->device_path);
+		memcpy(next->mac, macs->mac, sizeof macs->mac);
+		list_add(&next->list, &mac_platform_list);
+
+		macs++;
+	}
+
+bail:
+	mutex_unlock(&mac_platform_mutex);
+
+	return ret;
+}
+
+static struct notifier_block mac_platform_netdev_notifier = {
+	.notifier_call = mac_platform_netdev_event,
+	.priority = 1,
+};
+
+static int __init mac_platform_init(void)
+{
+	int ret = register_netdevice_notifier(&mac_platform_netdev_notifier);
+	if (ret)
+		pr_err("mac_platform_init: Notifier registration failed\n");
+
+	return ret;
+}
+
+core_initcall(mac_platform_init);

