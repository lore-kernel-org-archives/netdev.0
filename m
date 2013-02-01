From: "Matthew O'Connor" <liquidhorse@gmail.com>
Subject: Backport of Balance-ALB patch from 3.8-rc2 (567b871e503316b0927e54a3d7c86d50b722d955)
 to kernels 3.0, 3.2, 3.4, 3.7.
Date: Fri, 1 Feb 2013 15:00:06 -0500
Message-ID: <CAK8PzVk8g1-jDhVmZ+jLCcw23DmDANYdxVrzuDBNPqhTVq8zqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:55749 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757125Ab3BAUAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 15:00:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original patch by Zheng Li.  Backported to kernel series 3.0, 3.2,
3.4, and 3.7.  Original patch details:

>From 567b871e503316b0927e54a3d7c86d50b722d955 Mon Sep 17 00:00:00 2001
From: "zheng.li" <zheng.x.li@oracle.com>
Date: Tue, 27 Nov 2012 23:57:04 +0000
Subject: [PATCH] bonding: rlb mode of bond should not alter ARP originating
 via bridge

Do not modify or load balance ARP packets passing through balance-alb
mode (wherein the ARP did not originate locally, and arrived via a bridge).

Modifying pass-through ARP replies causes an incorrect MAC address
to be placed into the ARP packet, rendering peers unable to communicate
with the actual destination from which the ARP reply originated.

Load balancing pass-through ARP requests causes an entry to be
created for the peer in the rlb table, and bond_alb_monitor will
occasionally issue ARP updates to all peers in the table instrucing them
as to which MAC address they should communicate with; this occurs when
some event sets rx_ntt.  In the bridged case, however, the MAC address
used for the update would be the MAC of the slave, not the actual source
MAC of the originating destination.  This would render peers unable to
communicate with the destinations beyond the bridge.

Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: David S. Miller <davem@davemloft.net>


Backports:
Signed-off-by: Matthew O'Connor (liquidhorse@gmail.com)


====== 3.0 Series ======

diff -uNr linux-3.0.0-a/drivers/net/bonding/bond_alb.c
linux-3.0.0-b/drivers/net/bonding/bond_alb.c
--- linux-3.0.0-a/drivers/net/bonding/bond_alb.c    2013-01-10
12:47:53.000000000 -0500
+++ linux-3.0.0-b/drivers/net/bonding/bond_alb.c    2013-01-10
12:50:58.000000000 -0500
@@ -666,6 +666,12 @@
     struct arp_pkt *arp = arp_pkt(skb);
     struct slave *tx_slave = NULL;

+    /* Don't modify or load balance ARPs that do not originate locally
+     * (e.g.,arrive via a bridge).
+     */
+    if (!bond_slave_has_mac(bond, arp->mac_src))
+        return NULL;
+
     if (arp->op_code == htons(ARPOP_REPLY)) {
         /* the arp must be sent on the selected
         * rx channel
diff -uNr linux-3.0.0-a/drivers/net/bonding/bonding.h
linux-3.0.0-b/drivers/net/bonding/bonding.h
--- linux-3.0.0-a/drivers/net/bonding/bonding.h    2011-07-21
22:17:23.000000000 -0400
+++ linux-3.0.0-b/drivers/net/bonding/bonding.h    2013-01-10
12:51:05.000000000 -0500
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
+#include <linux/etherdevice.h>
 #include <linux/cpumask.h>
 #include <linux/in6.h>
 #include <linux/netpoll.h>
@@ -431,6 +432,18 @@
 }
 #endif

+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+                           const u8 *mac)
+{
+    int i = 0;
+    struct slave *tmp;
+
+    bond_for_each_slave(bond, tmp, i)
+        if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+            return tmp;
+
+    return NULL;
+}

 /* exported from bond_main.c */
 extern int bond_net_id;
diff -uNr linux-3.0.0-a/include/linux/etherdevice.h
linux-3.0.0-b/include/linux/etherdevice.h
--- linux-3.0.0-a/include/linux/etherdevice.h    2011-07-21
22:17:23.000000000 -0400
+++ linux-3.0.0-b/include/linux/etherdevice.h    2013-01-10
12:51:16.000000000 -0500
@@ -275,4 +275,37 @@
 #endif
 }

+/**
+ * ether_addr_equal_64bits - Compare two Ethernet addresses
+ * @addr1: Pointer to an array of 8 bytes
+ * @addr2: Pointer to an other array of 8 bytes
+ *
+ * Compare two Ethernet addresses, returns true if equal, false otherwise.
+ *
+ * The function doesn't need any conditional branches and possibly uses
+ * word memory accesses on CPU allowing cheap unaligned memory reads.
+ * arrays = { byte1, byte2, byte3, byte4, byte5, byte6, pad1, pad2 }
+ *
+ * Please note that alignment of addr1 & addr2 are only guaranteed to
be 16 bits.
+ */
+
+static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
+                                           const u8 addr2[6+2])
+{
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+        unsigned long fold = ((*(unsigned long *)addr1) ^
+                              (*(unsigned long *)addr2));
+
+        if (sizeof(fold) == 8)
+                return zap_last_2bytes(fold) == 0;
+
+        fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
+                                (*(unsigned long *)(addr2 + 4)));
+        return fold == 0;
+#else
+        return ether_addr_equal(addr1, addr2);
+#endif
+}
+
+
 #endif    /* _LINUX_ETHERDEVICE_H */



====== 3.2 Series ======

diff -uprN linux-3.2.37/drivers/net/bonding/bond_alb.c
linux-3.2.37-patched/drivers/net/bonding/bond_alb.c
--- linux-3.2.37/drivers/net/bonding/bond_alb.c    2013-01-15
20:13:30.000000000 -0500
+++ linux-3.2.37-patched/drivers/net/bonding/bond_alb.c    2013-01-30
15:37:12.717485854 -0500
@@ -666,6 +666,12 @@ static struct slave *rlb_arp_xmit(struct
     struct arp_pkt *arp = arp_pkt(skb);
     struct slave *tx_slave = NULL;

+    /* Don't modify or load balance ARPs that do not originate locally
+     * (e.g.,arrive via a bridge).
+     */
+    if (!bond_slave_has_mac(bond, arp->mac_src))
+        return NULL;
+
     if (arp->op_code == htons(ARPOP_REPLY)) {
         /* the arp must be sent on the selected
         * rx channel
diff -uprN linux-3.2.37/drivers/net/bonding/bonding.h
linux-3.2.37-patched/drivers/net/bonding/bonding.h
--- linux-3.2.37/drivers/net/bonding/bonding.h    2013-01-15
20:13:30.000000000 -0500
+++ linux-3.2.37-patched/drivers/net/bonding/bonding.h    2013-01-30
15:37:12.729485790 -0500
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
+#include <linux/etherdevice.h>
 #include <linux/cpumask.h>
 #include <linux/in6.h>
 #include <linux/netpoll.h>
@@ -436,6 +437,18 @@ static inline void bond_destroy_proc_dir
 }
 #endif

+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+                           const u8 *mac)
+{
+    int i = 0;
+    struct slave *tmp;
+
+    bond_for_each_slave(bond, tmp, i)
+        if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+            return tmp;
+
+    return NULL;
+}

 /* exported from bond_main.c */
 extern int bond_net_id;
diff -uprN linux-3.2.37/include/linux/etherdevice.h
linux-3.2.37-patched/include/linux/etherdevice.h
--- linux-3.2.37/include/linux/etherdevice.h    2013-01-15
20:13:30.000000000 -0500
+++ linux-3.2.37-patched/include/linux/etherdevice.h    2013-01-30
15:37:12.729485790 -0500
@@ -275,4 +275,37 @@ static inline unsigned long compare_ethe
 #endif
 }

+/**
+ * ether_addr_equal_64bits - Compare two Ethernet addresses
+ * @addr1: Pointer to an array of 8 bytes
+ * @addr2: Pointer to an other array of 8 bytes
+ *
+ * Compare two Ethernet addresses, returns true if equal, false otherwise.
+ *
+ * The function doesn't need any conditional branches and possibly uses
+ * word memory accesses on CPU allowing cheap unaligned memory reads.
+ * arrays = { byte1, byte2, byte3, byte4, byte5, byte6, pad1, pad2 }
+ *
+ * Please note that alignment of addr1 & addr2 are only guaranteed to
be 16 bits.
+ */
+
+static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
+                                           const u8 addr2[6+2])
+{
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+        unsigned long fold = ((*(unsigned long *)addr1) ^
+                              (*(unsigned long *)addr2));
+
+        if (sizeof(fold) == 8)
+                return zap_last_2bytes(fold) == 0;
+
+        fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
+                                (*(unsigned long *)(addr2 + 4)));
+        return fold == 0;
+#else
+        return ether_addr_equal(addr1, addr2);
+#endif
+}
+
+
 #endif    /* _LINUX_ETHERDEVICE_H */



====== 3.4 Series ======

diff -uprN linux-3.4.28/drivers/net/bonding/bond_alb.c
linux-3.4.28-patched/drivers/net/bonding/bond_alb.c
--- linux-3.4.28/drivers/net/bonding/bond_alb.c    2013-01-27
23:51:45.000000000 -0500
+++ linux-3.4.28-patched/drivers/net/bonding/bond_alb.c    2013-01-30
15:37:25.121708311 -0500
@@ -704,6 +704,12 @@ static struct slave *rlb_arp_xmit(struct
     struct arp_pkt *arp = arp_pkt(skb);
     struct slave *tx_slave = NULL;

+    /* Don't modify or load balance ARPs that do not originate locally
+     * (e.g.,arrive via a bridge).
+     */
+    if (!bond_slave_has_mac(bond, arp->mac_src))
+        return NULL;
+
     if (arp->op_code == htons(ARPOP_REPLY)) {
         /* the arp must be sent on the selected
         * rx channel
diff -uprN linux-3.4.28/drivers/net/bonding/bonding.h
linux-3.4.28-patched/drivers/net/bonding/bonding.h
--- linux-3.4.28/drivers/net/bonding/bonding.h    2013-01-27
23:51:45.000000000 -0500
+++ linux-3.4.28-patched/drivers/net/bonding/bonding.h    2013-01-30
15:37:25.121708311 -0500
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
+#include <linux/etherdevice.h>
 #include <linux/cpumask.h>
 #include <linux/in6.h>
 #include <linux/netpoll.h>
@@ -450,6 +451,18 @@ static inline void bond_destroy_proc_dir
 }
 #endif

+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+                           const u8 *mac)
+{
+    int i = 0;
+    struct slave *tmp;
+
+    bond_for_each_slave(bond, tmp, i)
+        if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+            return tmp;
+
+    return NULL;
+}

 /* exported from bond_main.c */
 extern int bond_net_id;
diff -uprN linux-3.4.28/include/linux/etherdevice.h
linux-3.4.28-patched/include/linux/etherdevice.h
--- linux-3.4.28/include/linux/etherdevice.h    2013-01-27
23:51:45.000000000 -0500
+++ linux-3.4.28-patched/include/linux/etherdevice.h    2013-01-30
15:37:25.121708311 -0500
@@ -277,4 +277,37 @@ static inline unsigned long compare_ethe
 #endif
 }

+/**
+ * ether_addr_equal_64bits - Compare two Ethernet addresses
+ * @addr1: Pointer to an array of 8 bytes
+ * @addr2: Pointer to an other array of 8 bytes
+ *
+ * Compare two Ethernet addresses, returns true if equal, false otherwise.
+ *
+ * The function doesn't need any conditional branches and possibly uses
+ * word memory accesses on CPU allowing cheap unaligned memory reads.
+ * arrays = { byte1, byte2, byte3, byte4, byte5, byte6, pad1, pad2 }
+ *
+ * Please note that alignment of addr1 & addr2 are only guaranteed to
be 16 bits.
+ */
+
+static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
+                                           const u8 addr2[6+2])
+{
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+        unsigned long fold = ((*(unsigned long *)addr1) ^
+                              (*(unsigned long *)addr2));
+
+        if (sizeof(fold) == 8)
+                return zap_last_2bytes(fold) == 0;
+
+        fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
+                                (*(unsigned long *)(addr2 + 4)));
+        return fold == 0;
+#else
+        return ether_addr_equal(addr1, addr2);
+#endif
+}
+
+
 #endif    /* _LINUX_ETHERDEVICE_H */



====== 3.7 Series ======

diff -uprN linux-3.7/drivers/net/bonding/bond_alb.c
linux-3.7-patch2/drivers/net/bonding/bond_alb.c
--- linux-3.7/drivers/net/bonding/bond_alb.c    2012-12-10
22:30:57.000000000 -0500
+++ linux-3.7-patch2/drivers/net/bonding/bond_alb.c    2013-02-01
13:55:20.062030691 -0500
@@ -694,6 +694,12 @@ static struct slave *rlb_arp_xmit(struct
     struct arp_pkt *arp = arp_pkt(skb);
     struct slave *tx_slave = NULL;

+    /* Don't modify or load balance ARPs that do not originate locally
+     * (e.g.,arrive via a bridge).
+     */
+    if (!bond_slave_has_mac(bond, arp->mac_src))
+        return NULL;
+
     if (arp->op_code == htons(ARPOP_REPLY)) {
         /* the arp must be sent on the selected
         * rx channel
diff -uprN linux-3.7/drivers/net/bonding/bonding.h
linux-3.7-patch2/drivers/net/bonding/bonding.h
--- linux-3.7/drivers/net/bonding/bonding.h    2012-12-10
22:30:57.000000000 -0500
+++ linux-3.7-patch2/drivers/net/bonding/bonding.h    2013-02-01
13:55:20.062030691 -0500
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
+#include <linux/etherdevice.h>
 #include <linux/cpumask.h>
 #include <linux/in6.h>
 #include <linux/netpoll.h>
@@ -450,6 +451,18 @@ static inline void bond_destroy_proc_dir
 }
 #endif

+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+                           const u8 *mac)
+{
+    int i = 0;
+    struct slave *tmp;
+
+    bond_for_each_slave(bond, tmp, i)
+        if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+            return tmp;
+
+    return NULL;
+}

 /* exported from bond_main.c */
 extern int bond_net_id;
