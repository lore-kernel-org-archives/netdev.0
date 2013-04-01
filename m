From: "Matthew O'Connor" <liquidhorse@gmail.com>
Subject: [PATCH 3.0-longterm] bonding: ARP packet fix for balance-ALB (mode=6)
Date: Mon, 1 Apr 2013 12:36:07 -0400
Message-ID: <CAK8PzVnNfLSnvxY83z3Em3gtJM4zWM0Xd4P3CWy3xt=7feJgMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:64697 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758899Ab3DAQgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 12:36:08 -0400
Received: by mail-wg0-f50.google.com with SMTP id k13so2309061wgh.29
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 09:36:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not modify or load balance ARP packets passing through balance-alb
mode (wherein the ARP did not originate locally, and arrived via a bridge).

This patch is backported from the upstream commit:
    From 567b871e503316b0927e54a3d7c86d50b722d955 Mon Sep 17 00:00:00 2001
    Subject: [PATCH] bonding: rlb mode of bond should not alter ARP
originating via bridge

Signed-off-by:  Matthew O'Connor <liquidhorse@gmail.com>

---
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
