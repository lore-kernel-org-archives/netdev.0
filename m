From: David Miller <davem@davemloft.net>
Subject: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 06 Jan 2016 16:33:09 -0500 (EST)
Message-ID: <20160106.163309.111867454969344145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbcAFVdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 16:33:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A repeating pattern in drivers has become to use OF node information
and, if not found, platform specific host information to extract the
ethernet address for a given device.

Currently this is done with a call to of_get_mac_address() and then
some ifdef'd stuff for SPARC.

Consolidate this into a portable routine, and provide the
arch_get_platform_mac_address() weak function hook for all
architectures to implement if they want.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

As promised back in November, I'm commiting this into net-next
now.  I'd work on the conversions of existing drivers, but I'd
rather someone with access to the hardware to so.

 arch/sparc/kernel/idprom.c  |  7 +++++++
 include/linux/etherdevice.h |  3 +++
 net/ethernet/eth.c          | 31 +++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+)

diff --git a/arch/sparc/kernel/idprom.c b/arch/sparc/kernel/idprom.c
index 6bd7501..f95dd11 100644
--- a/arch/sparc/kernel/idprom.c
+++ b/arch/sparc/kernel/idprom.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/export.h>
+#include <linux/etherdevice.h>
 
 #include <asm/oplib.h>
 #include <asm/idprom.h>
@@ -60,6 +61,12 @@ static void __init display_system_type(unsigned char machtype)
 {
 }
 #endif
+
+unsigned char *arch_get_platform_mac_address(void)
+{
+	return idprom->id_ethaddr;
+}
+
 /* Calculate the IDPROM checksum (xor of the data bytes). */
 static unsigned char __init calc_idprom_cksum(struct idprom *idprom)
 {
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index eb049c6..37ff4a6 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -29,6 +29,9 @@
 #include <asm/bitsperlong.h>
 
 #ifdef __KERNEL__
+struct device;
+int eth_platform_get_mac_address(struct device *dev, u8 *mac_addr);
+unsigned char *arch_get_platform_get_mac_address(void);
 u32 eth_get_headlen(void *data, unsigned int max_len);
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev);
 extern const struct header_ops eth_header_ops;
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 9e63f25..1038717 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -52,6 +52,8 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/if_ether.h>
+#include <linux/of_net.h>
+#include <linux/pci.h>
 #include <net/dst.h>
 #include <net/arp.h>
 #include <net/sock.h>
@@ -485,3 +487,32 @@ static int __init eth_offload_init(void)
 }
 
 fs_initcall(eth_offload_init);
+
+unsigned char * __weak arch_get_platform_mac_address(void)
+{
+	return NULL;
+}
+
+int eth_platform_get_mac_address(struct device *dev, u8 *mac_addr)
+{
+	const unsigned char *addr;
+	struct device_node *dp;
+
+	if (dev_is_pci(dev))
+		dp = pci_device_to_OF_node(to_pci_dev(dev));
+	else
+		dp = dev->of_node;
+
+	addr = NULL;
+	if (dp)
+		addr = of_get_mac_address(dp);
+	if (!addr)
+		addr = arch_get_platform_mac_address();
+
+	if (!addr)
+		return -ENODEV;
+
+	ether_addr_copy(mac_addr, addr);
+	return 0;
+}
+EXPORT_SYMBOL(eth_platform_get_mac_address);
-- 
2.4.1
