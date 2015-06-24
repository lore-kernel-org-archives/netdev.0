From: igal.liberman@freescale.com
Subject: [v2,4/9] fsl/fman: Add FMan MURAM support
Date: Wed, 24 Jun 2015 22:34:56 +0300
Message-ID: <1435174496-7472-1-git-send-email-igal.liberman@freescale.com>
Reply-To: igal.liberman@freescale.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	Igal Liberman <Igal.Liberman@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0140.outbound.protection.outlook.com ([207.46.100.140]:26208
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753634AbbFXTf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 15:35:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

Add Frame Manager Multi-User RAM support.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig        |    1 +
 drivers/net/ethernet/freescale/fman/Makefile       |    6 +-
 drivers/net/ethernet/freescale/fman/fm_muram.c     |  127 ++++++++++++++++++++
 .../net/ethernet/freescale/fman/inc/fm_muram_ext.h |  112 +++++++++++++++++
 4 files changed, 244 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_muram.c
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index af42c3a..825a0d5 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -1,6 +1,7 @@
 config FSL_FMAN
 	bool "FMan support"
 	depends on FSL_SOC || COMPILE_TEST
+	select GENERIC_ALLOCATOR
 	default n
 	help
 		Freescale Data-Path Acceleration Architecture Frame Manager
diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 1841b03..55c91bd 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -1,8 +1,10 @@
-subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib
+subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib \
+				     -I$(srctree)/drivers/net/ethernet/freescale/fman/inc \
+				     -I$(srctree)/drivers/net/ethernet/freescale/fman
 
 obj-y		+= fsl_fman.o
 
-fsl_fman-objs	:= fman.o
+fsl_fman-objs	:= fman.o fm_muram.o
 
 obj-y	+= port/
 obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/fm_muram.c b/drivers/net/ethernet/freescale/fman/fm_muram.c
new file mode 100644
index 0000000..f62042a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm_muram.c
@@ -0,0 +1,127 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/* FM MURAM ... */
+#include "fm_muram_ext.h"
+
+#include <linux/io.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/genalloc.h>
+
+struct muram_info {
+	struct gen_pool *pool;
+	void __iomem *vbase;
+	uint64_t size;
+	phys_addr_t pbase;
+};
+
+struct muram_info *fm_muram_init(phys_addr_t base, uint64_t size)
+{
+	struct muram_info *p_muram;
+	void __iomem *vaddr;
+	int ret;
+
+	p_muram = kzalloc(sizeof(*p_muram), GFP_KERNEL);
+	if (!p_muram)
+		return NULL;
+
+	p_muram->pool = gen_pool_create(ilog2(64), -1);
+	if (!p_muram->pool) {
+		pr_err("%s(): MURAM pool create failed\n", __func__);
+		return NULL;
+	}
+
+	vaddr = ioremap(base, size);
+	if (!vaddr) {
+		pr_err("%s(): MURAM ioremap failed\n", __func__);
+		return NULL;
+	}
+
+	ret = gen_pool_add_virt(p_muram->pool, (unsigned long)vaddr,
+				base, size, -1);
+	if (ret < 0) {
+		pr_err("%s(): MURAM pool add failed\n", __func__);
+		iounmap(vaddr);
+		return NULL;
+	}
+
+	memset_io(vaddr, 0, (int)size);
+
+	p_muram->vbase = vaddr;
+	p_muram->pbase = base;
+	return p_muram;
+}
+
+void fm_muram_free(struct muram_info *p_muram)
+{
+	/* Destroy pool */
+	gen_pool_destroy(p_muram->pool);
+	/* Unmap memory */
+	iounmap(p_muram->vbase);
+	/* Free pointer */
+	kfree(p_muram);
+}
+
+unsigned long fm_muram_vbase_to_offset(struct muram_info *p_muram,
+				       unsigned long vaddr)
+{
+	return vaddr - (unsigned long)p_muram->vbase;
+}
+
+unsigned long fm_muram_offset_to_vbase(struct muram_info *p_muram,
+				       unsigned long offset)
+{
+	return offset + (unsigned long)p_muram->vbase;
+}
+
+int fm_muram_alloc(struct muram_info *p_muram, uint32_t size)
+{
+	unsigned long vaddr;
+
+	vaddr = gen_pool_alloc(p_muram->pool, size);
+	if (!vaddr)
+		return -ENOMEM;
+
+	memset_io((void __iomem *)vaddr, 0, (int)size);
+
+	return fm_muram_vbase_to_offset(p_muram, vaddr);
+}
+
+void fm_muram_free_mem(struct muram_info *p_muram, uint32_t offset,
+		       uint32_t size)
+{
+	unsigned long addr = fm_muram_offset_to_vbase(p_muram, offset);
+
+	gen_pool_free(p_muram->pool, addr, size);
+}
+
diff --git a/drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h b/drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h
new file mode 100644
index 0000000..0cc83338
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/fm_muram_ext.h
@@ -0,0 +1,112 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+#ifndef __FM_MURAM_EXT
+#define __FM_MURAM_EXT
+
+#include "linux/types.h"
+
+#define FM_MURAM_INVALID_ALLOCATION	-1
+
+/* Structure for FM MURAM information */
+struct muram_info;
+
+/**
+ * fm_muram_init
+ * @base:	Pointer to base of memory mapped FM-MURAM.
+ * @size:	Size of the FM-MURAM partition.
+ *
+ * Creates partition in the MURAM.
+ * The routine returns a pointer to the MURAM partition.
+ * This pointer must be passed as to all other FM-MURAM function calls.
+ * No actual initialization or configuration of FM_MURAM hardware is done by
+ * this routine.
+ *
+ * Return: pointer to FM-MURAM object, or NULL for Failure.
+ */
+struct muram_info *fm_muram_init(phys_addr_t base, uint64_t size);
+
+/**
+ * fm_muram_free
+ * @p_muram:	FM-MURAM module pointer.
+ *
+ * Frees all resources that were assigned to FM-MURAM module.
+ * Calling this routine invalidates the pointer.
+ */
+void fm_muram_free(struct muram_info *p_muram);
+
+/**
+ * fm_muram_vbase_to_offset
+ * @p_muram:	FM-MURAM module pointer.
+ * @vaddr:	The virtual address of the memory block
+ *
+ * Gives the offset of the memory region in the MURAM
+ *
+ * Return: The offset of the memory block
+ */
+unsigned long fm_muram_vbase_to_offset(struct muram_info *p_muram,
+				       unsigned long vaddr);
+
+/**
+ * fm_muram_vbase_to_offset
+ * @p_muram:	FM-MURAM module pointer.
+ * @offset:	the offset of the memory block
+ *
+ * Gives the address of the memory region from specific oddset
+ *
+ * Return: The address of the memory blocl
+ */
+unsigned long fm_muram_offset_to_vbase(struct muram_info *p_muram,
+				       unsigned long offset);
+
+/**
+ * fm_muram_alloc
+ * @p_muram:	FM-MURAM module pointer.
+ * @size:	Size of the memory to be allocated.
+ *
+ * Allocate some memory from FM-MURAM partition.
+ *
+ * Return: address of the allocated memory; NULL otherwise.
+ */
+int fm_muram_alloc(struct muram_info *p_muram, uint32_t size);
+
+/**
+ * fm_muram_free_mem
+ * p_muram:	FM-MURAM module pointer.
+ * offset:	offset of the memory region to be freed.
+ * size:	size of the memory to be freed.
+ *
+ * Free an allocated memory from FM-MURAM partition.
+ */
+void fm_muram_free_mem(struct muram_info *p_muram, uint32_t offset,
+		       uint32_t size);
+
+#endif /* __FM_MURAM_EXT */
-- 
1.7.9.5
