From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/6) revised network device probing.
Date: Thu, 25 Sep 2003 17:10:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925171037.18854ac3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a revised version of Al Viro's net device patchset and is updated to apply
against the current 2.6 BK tree.

It adds a second probe list for network devices that are compiled into the kernel,
but allocate their own network device rather than being handed a device.
Also restores the 2.4 behaviour where it was possible to configure the second
ethernet (via command line) without finding the first.

It is part of the incremental changes to have all network devices using dynamic
allocation.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 12:56:25 2003
+++ b/drivers/net/Space.c	Tue Sep 23 12:56:25 2003
@@ -111,6 +111,11 @@
 	int status;	/* non-zero if autoprobe has failed */
 };
 
+struct devprobe2 {
+	struct net_device *(*probe)(int unit);
+	int status;	/* non-zero if autoprobe has failed */
+};
+
 /*
  * probe_list walks a list of probe functions and calls each so long
  * as a non-zero ioaddr is given, or as long as it hasn't already failed 
@@ -136,6 +141,21 @@
 	return -ENODEV;
 }
 
+static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
+{
+	struct net_device *dev;
+	for (; p->probe; p++) {
+		if (autoprobe && p->status)
+			continue;
+		dev = p->probe(unit);
+		if (!IS_ERR(dev))
+			return 0;
+		if (autoprobe)
+			p->status = PTR_ERR(dev);
+	}
+	return -ENODEV;
+}
+
 /*
  * This is a bit of an artificial separation as there are PCI drivers
  * that also probe for EISA cards (in the PCI group) and there are ISA
@@ -376,6 +396,16 @@
 	return err;
 
 }
+ 
+static void __init ethif_probe2(int unit)
+{
+	unsigned long base_addr = netdev_boot_base("eth", unit);
+
+	if (base_addr == 1)
+		return;
+
+	return;	/* nothing yet */
+}
 
 #ifdef CONFIG_TR
 /* Token-ring device probe */
@@ -445,9 +475,12 @@
 		if (trif_probe(num))
 			break;
 #endif
-	for (num = 0; num < 8; ++num)
+	for (num = 0; num < 8; ++num) {
 		if (ethif_probe(num))
 			break;
+		ethif_probe2(num);
+	}
+
 #ifdef CONFIG_COPS
 	cops_probe(0);
 	cops_probe(1);
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Tue Sep 23 12:56:25 2003
+++ b/include/linux/netdevice.h	Tue Sep 23 12:56:25 2003
@@ -498,6 +498,7 @@
 extern void		probe_old_netdevs(void);
 extern int			netdev_boot_setup_add(char *name, struct ifmap *map);
 extern int 			netdev_boot_setup_check(struct net_device *dev);
+extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Tue Sep 23 12:56:25 2003
+++ b/net/core/dev.c	Tue Sep 23 12:56:25 2003
@@ -375,6 +375,30 @@
 	return 0;
 }
 
+
+/**
+ *	netdev_boot_base	- get address from boot time settings
+ *	@prefix: prefix for network device
+ *	@unit: id for network device
+ *
+ * 	Check boot time settings for the base address of device.
+ *	The found settings are set for the device to be used
+ *	later in the device probing.
+ *	Returns 0 if no settings found.
+ */
+unsigned long netdev_boot_base(const char *prefix, int unit)
+{
+	const struct netdev_boot_setup *s = dev_boot_setup;
+	char name[IFNAMSIZ];
+	int i;
+
+	sprintf(name, "%s%d", prefix, unit);
+	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
+		if (!strcmp(name, s[i].name))
+			return s[i].map.base_addr;
+	return 0;
+}
+
 /*
  * Saves at boot time configured settings for any netdevice.
  */
