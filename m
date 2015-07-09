From: Roy Pledge <Roy.Pledge@freescale.com>
Subject: [PATCH 01/11] powerpc: re-add devm_ioremap_prot()
Date: Thu, 9 Jul 2015 16:21:52 -0400
Message-ID: <1436473322-21247-2-git-send-email-Roy.Pledge@freescale.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>, <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:24117
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753805AbbGIUWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 16:22:06 -0400
In-Reply-To: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Medve <Emilian.Medve@Freescale.com>

devm_ioremap_prot() was removed in commit dedd24a12,
and was introduced in commit b41e5fffe8.

This reverts commit dedd24a12fe6735898feeb06184ee346907abb5d.

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---
 arch/powerpc/include/asm/io.h |    3 +++
 arch/powerpc/lib/Makefile     |    1 +
 arch/powerpc/lib/devres.c     |   43 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)
 create mode 100644 arch/powerpc/lib/devres.c

diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index a8d2ef3..9eaf301 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -855,6 +855,9 @@ static inline void * bus_to_virt(unsigned long address)
 
 #define clrsetbits_8(addr, clear, set) clrsetbits(8, addr, clear, set)
 
+void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
+				size_t size, unsigned long flags);
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_POWERPC_IO_H */
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index a47e142..7ae60f0 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -13,6 +13,7 @@ obj-y += string.o alloc.o crtsavres.o ppc_ksyms.o code-patching.o \
 	 feature-fixups.o
 
 obj-$(CONFIG_PPC32)	+= div64.o copy_32.o
+obj-$(CONFIG_HAS_IOMEM)	+= devres.o
 
 obj64-y	+= copypage_64.o copyuser_64.o usercopy_64.o mem_64.o hweight_64.o \
 	   copyuser_power7.o string_64.o copypage_power7.o memcpy_power7.o \
diff --git a/arch/powerpc/lib/devres.c b/arch/powerpc/lib/devres.c
new file mode 100644
index 0000000..8df55fc
--- /dev/null
+++ b/arch/powerpc/lib/devres.c
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2008 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/device.h>	/* devres_*(), devm_ioremap_release() */
+#include <linux/gfp.h>
+#include <linux/io.h>		/* ioremap_prot() */
+#include <linux/export.h>	/* EXPORT_SYMBOL() */
+
+/**
+ * devm_ioremap_prot - Managed ioremap_prot()
+ * @dev: Generic device to remap IO address for
+ * @offset: BUS offset to map
+ * @size: Size of map
+ * @flags: Page flags
+ *
+ * Managed ioremap_prot().  Map is automatically unmapped on driver
+ * detach.
+ */
+void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
+				 size_t size, unsigned long flags)
+{
+	void __iomem **ptr, *addr;
+
+	ptr = devres_alloc(devm_ioremap_release, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return NULL;
+
+	addr = ioremap_prot(offset, size, flags);
+	if (addr) {
+		*ptr = addr;
+		devres_add(dev, ptr);
+	} else
+		devres_free(ptr);
+
+	return addr;
+}
+EXPORT_SYMBOL(devm_ioremap_prot);
-- 
1.7.9.5
