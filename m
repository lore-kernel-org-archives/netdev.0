From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/3] add dev_to_node()
Date: Mon, 30 Oct 2006 15:15:01 +0100
Message-ID: <20061030141501.GC7164__24409.326099749$1162218228$gmane$org@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:18903 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751707AbWJ3OUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 09:20:15 -0500
Received: from verein.lst.de (localhost [127.0.0.1])
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id k9UEKAWv007844
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 15:20:10 +0100
Received: (from hch@localhost)
	by verein.lst.de (8.12.3/8.12.3/Debian-6.6) id k9UEKA0X007842
	for netdev@vger.kernel.org; Mon, 30 Oct 2006 15:20:10 +0100
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	linux-mm@kvack.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davem suggested to get the node-affinity information directly from
struct device instead of having the caller extreact it from the
pci_dev.  This patch adds dev_to_node() to the topology API for that.
The implementation is rather ugly as we need to compare the bus
operations which we can't do inline in a header without pulling all
kinds of mess in.

Thus provide an out of line dev_to_node for ppc and let everyone else
use the dummy variant in asm-generic.h for now.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/asm-generic/topology.h
===================================================================
--- linux-2.6.orig/include/asm-generic/topology.h	2006-10-10 14:53:52.000000000 +0200
+++ linux-2.6/include/asm-generic/topology.h	2006-10-30 13:42:22.000000000 +0100
@@ -45,11 +45,14 @@
 #define pcibus_to_node(node)	(-1)
 #endif
 
+#ifndef dev_to_node
+#define dev_to_node(dev)	(-1)
+#endif
+
 #ifndef pcibus_to_cpumask
 #define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) == -1 ? \
 					CPU_MASK_ALL : \
 					node_to_cpumask(pcibus_to_node(bus)) \
 				)
 #endif
-
 #endif /* _ASM_GENERIC_TOPOLOGY_H */
Index: linux-2.6/include/asm-powerpc/topology.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/topology.h	2006-10-10 14:53:52.000000000 +0200
+++ linux-2.6/include/asm-powerpc/topology.h	2006-10-30 14:03:44.000000000 +0100
@@ -5,6 +5,7 @@
 
 struct sys_device;
 struct device_node;
+struct device;
 
 #ifdef CONFIG_NUMA
 
@@ -33,6 +34,7 @@
 
 struct pci_bus;
 extern int pcibus_to_node(struct pci_bus *bus);
+int dev_to_node(struct device *dev);
 
 #define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) == -1 ? \
 					CPU_MASK_ALL : \
Index: linux-2.6/arch/powerpc/kernel/pci_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/pci_64.c	2006-10-23 17:21:43.000000000 +0200
+++ linux-2.6/arch/powerpc/kernel/pci_64.c	2006-10-30 14:02:40.000000000 +0100
@@ -1424,4 +1424,12 @@
 	return phb->node;
 }
 EXPORT_SYMBOL(pcibus_to_node);
+
+int dev_to_node(struct device *dev)
+{
+	if (dev->bus == &pci_bus_type)
+		return pcibus_to_node(to_pci_dev(dev)->bus);
+	return -1;
+}
+EXPORT_SYMBOL(dev_to_node);
 #endif
