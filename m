From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH] enic: fix compile on x86 and ia64 and fix Kconfig
Date: Sat, 20 Sep 2008 02:10:01 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809200202060.13272@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:1457 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751009AbYITJLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 05:11:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: fix compile on x86 and ia64 and fix Kconfig

o readq/writeq aren't defined on all archs, so define 'em conditionally here
o for ia64, include net/ip6_checksum.h for csum_ipv6_magic
o fix mangled Kconfig description

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 69c81da..8217138 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2401,7 +2401,7 @@ config EHEA
  	  will be called ehea.

  config ENIC
-	tristate "E, the Cisco 10G Ethernet NIC"
+	tristate "Cisco 10G Ethernet NIC support"
  	depends on PCI && INET
  	select INET_LRO
  	help
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 4cf5ec7..2592e52 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -34,6 +34,7 @@
  #include <linux/ip.h>
  #include <linux/ipv6.h>
  #include <linux/tcp.h>
+#include <net/ip6_checksum.h>

  #include "cq_enet_desc.h"
  #include "vnic_dev.h"
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 4d104f5..84d3592 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -29,6 +29,20 @@
  #include "vnic_dev.h"
  #include "vnic_stats.h"

+#ifndef readq
+static inline u64 readq(void __iomem *reg)
+{
+	return (((u64)readl(reg + 0x4UL) << 32) |
+		(u64)readl(reg));
+}
+
+static inline void writeq(u64 val, void __iomem *reg)
+{
+	writel(val & 0xffffffff, reg);
+	writel(val >> 32, reg + 0x4UL);
+}
+
+#endif
  struct vnic_res {
  	void __iomem *vaddr;
  	unsigned int count;
