From: liquidhorse@gmail.com
Subject: [PATCH 3.4.y] bonding: rlb mode of bond should not alter ARP
 originating via bridge
Date: Tue, 18 Jun 2013 15:33:34 -0400
Message-ID: <20130618193334.GC29083@hv11.core.ecsorl.com>
Reply-To: liquidhorse@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SkvwRMAIpAhPCcCJ"
Cc: zheng.x.li@oracle.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

From: zheng.li <zheng.x.li@oracle.com>

[ Upstream commit 567b871e503316b0927e54a3d7c86d50b722d955 ]

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

Signed-off-by: Matthew O'Connor <liquidhorse@gmail.com>
CC: Zheng Li <zheng.x.li@oracle.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="balance-alb-3.4.patch"

diff -uprN linux-3.4.28/drivers/net/bonding/bond_alb.c linux-3.4.28-patched/drivers/net/bonding/bond_alb.c
--- linux-3.4.28/drivers/net/bonding/bond_alb.c	2013-01-27 23:51:45.000000000 -0500
+++ linux-3.4.28-patched/drivers/net/bonding/bond_alb.c	2013-01-30 15:37:25.121708311 -0500
@@ -704,6 +704,12 @@ static struct slave *rlb_arp_xmit(struct
 	struct arp_pkt *arp = arp_pkt(skb);
 	struct slave *tx_slave = NULL;
 
+	/* Don't modify or load balance ARPs that do not originate locally
+	 * (e.g.,arrive via a bridge).
+	 */
+	if (!bond_slave_has_mac(bond, arp->mac_src))
+		return NULL;
+
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* the arp must be sent on the selected
 		* rx channel
diff -uprN linux-3.4.28/drivers/net/bonding/bonding.h linux-3.4.28-patched/drivers/net/bonding/bonding.h
--- linux-3.4.28/drivers/net/bonding/bonding.h	2013-01-27 23:51:45.000000000 -0500
+++ linux-3.4.28-patched/drivers/net/bonding/bonding.h	2013-01-30 15:37:25.121708311 -0500
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
+					       const u8 *mac)
+{
+	int i = 0;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, i)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return tmp;
+
+	return NULL;
+}
 
 /* exported from bond_main.c */
 extern int bond_net_id;
diff -uprN linux-3.4.28/include/linux/etherdevice.h linux-3.4.28-patched/include/linux/etherdevice.h
--- linux-3.4.28/include/linux/etherdevice.h	2013-01-27 23:51:45.000000000 -0500
+++ linux-3.4.28-patched/include/linux/etherdevice.h	2013-01-30 15:37:25.121708311 -0500
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
+ * Please note that alignment of addr1 & addr2 are only guaranteed to be 16 bits.
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
 #endif	/* _LINUX_ETHERDEVICE_H */

--SkvwRMAIpAhPCcCJ--
