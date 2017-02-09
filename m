From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/12] nfp: add MIP reading support
Date: Thu,  9 Feb 2017 09:17:33 -0800
Message-ID: <20170209171738.17386-8-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35329 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdBIR3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:29:41 -0500
Received: by mail-pf0-f173.google.com with SMTP id f144so2023675pfa.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:29:40 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MIP is a vector of information which linker can optionally include
in application firmware.  It will be used to retrieve the location
of symbol tables.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_mip.c   | 174 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |  10 ++
 3 files changed, 185 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 408cb219a306..9c0662170de8 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -5,6 +5,7 @@ nfp-objs := \
 	    nfpcore/nfp_cppcore.o \
 	    nfpcore/nfp_cpplib.o \
 	    nfpcore/nfp_hwinfo.o \
+	    nfpcore/nfp_mip.o \
 	    nfpcore/nfp_nffw.o \
 	    nfpcore/nfp_resource.o \
 	    nfpcore/nfp_target.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
new file mode 100644
index 000000000000..3d15dd03647e
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_mip.c
@@ -0,0 +1,174 @@
+/*
+ * Copyright (C) 2015-2017 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_mip.c
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Espen Skoglund <espen.skoglund@netronome.com>
+ */
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+#include "nfp.h"
+#include "nfp_cpp.h"
+#include "nfp_nffw.h"
+
+#define NFP_MIP_SIGNATURE	cpu_to_le32(0x0050494d)  /* "MIP\0" */
+#define NFP_MIP_VERSION		cpu_to_le32(1)
+#define NFP_MIP_MAX_OFFSET	(256 * 1024)
+
+struct nfp_mip {
+	__le32 signature;
+	__le32 mip_version;
+	__le32 mip_size;
+	__le32 first_entry;
+
+	__le32 version;
+	__le32 buildnum;
+	__le32 buildtime;
+	__le32 loadtime;
+
+	__le32 symtab_addr;
+	__le32 symtab_size;
+	__le32 strtab_addr;
+	__le32 strtab_size;
+
+	char name[16];
+	char toolchain[32];
+};
+
+/* Read memory and check if it could be a valid MIP */
+static int
+nfp_mip_try_read(struct nfp_cpp *cpp, u32 cpp_id, u64 addr, struct nfp_mip *mip)
+{
+	int ret;
+
+	ret = nfp_cpp_read(cpp, cpp_id, addr, mip, sizeof(*mip));
+	if (ret != sizeof(*mip)) {
+		nfp_err(cpp, "Failed to read MIP data (%d, %zu)\n",
+			ret, sizeof(*mip));
+		return -EIO;
+	}
+	if (mip->signature != NFP_MIP_SIGNATURE) {
+		nfp_warn(cpp, "Incorrect MIP signature (0x%08x)\n",
+			 le32_to_cpu(mip->signature));
+		return -EINVAL;
+	}
+	if (mip->mip_version != NFP_MIP_VERSION) {
+		nfp_warn(cpp, "Unsupported MIP version (%d)\n",
+			 le32_to_cpu(mip->mip_version));
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Try to locate MIP using the resource table */
+static int nfp_mip_read_resource(struct nfp_cpp *cpp, struct nfp_mip *mip)
+{
+	struct nfp_nffw_info *nffw_info;
+	u32 cpp_id;
+	u64 addr;
+	int err;
+
+	nffw_info = nfp_nffw_info_open(cpp);
+	if (IS_ERR(nffw_info))
+		return PTR_ERR(nffw_info);
+
+	err = nfp_nffw_info_mip_first(nffw_info, &cpp_id, &addr);
+	if (err)
+		goto exit_close_nffw;
+
+	err = nfp_mip_try_read(cpp, cpp_id, addr, mip);
+exit_close_nffw:
+	nfp_nffw_info_close(nffw_info);
+	return err;
+}
+
+/**
+ * nfp_mip_open() - Get device MIP structure
+ * @cpp:	NFP CPP Handle
+ *
+ * Copy MIP structure from NFP device and return it.  The returned
+ * structure is handled internally by the library and should be
+ * freed by calling nfp_mip_close().
+ *
+ * Return: pointer to mip, NULL on failure.
+ */
+const struct nfp_mip *nfp_mip_open(struct nfp_cpp *cpp)
+{
+	struct nfp_mip *mip;
+	int err;
+
+	mip = kmalloc(sizeof(*mip), GFP_KERNEL);
+	if (!mip)
+		return NULL;
+
+	err = nfp_mip_read_resource(cpp, mip);
+	if (err) {
+		kfree(mip);
+		return NULL;
+	}
+
+	return mip;
+}
+
+void nfp_mip_close(const struct nfp_mip *mip)
+{
+	kfree(mip);
+}
+
+/**
+ * nfp_mip_symtab() - Get the address and size of the MIP symbol table
+ * @mip:	MIP handle
+ * @addr:	Location for NFP DDR address of MIP symbol table
+ * @size:	Location for size of MIP symbol table
+ */
+void nfp_mip_symtab(const struct nfp_mip *mip, u32 *addr, u32 *size)
+{
+	*addr = le32_to_cpu(mip->symtab_addr);
+	*size = le32_to_cpu(mip->symtab_size);
+}
+
+/**
+ * nfp_mip_strtab() - Get the address and size of the MIP symbol name table
+ * @mip:	MIP handle
+ * @addr:	Location for NFP DDR address of MIP symbol name table
+ * @size:	Location for size of MIP symbol name table
+ */
+void nfp_mip_strtab(const struct nfp_mip *mip, u32 *addr, u32 *size)
+{
+	*addr = le32_to_cpu(mip->strtab_addr);
+	*size = le32_to_cpu(mip->strtab_size);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
index 47a6571e236d..c91138c0daab 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
@@ -48,4 +48,14 @@ struct nfp_nffw_info *nfp_nffw_info_open(struct nfp_cpp *cpp);
 void nfp_nffw_info_close(struct nfp_nffw_info *state);
 int nfp_nffw_info_mip_first(struct nfp_nffw_info *state, u32 *cpp_id, u64 *off);
 
+/* Implemented in nfp_mip.c */
+
+struct nfp_mip;
+
+const struct nfp_mip *nfp_mip_open(struct nfp_cpp *cpp);
+void nfp_mip_close(const struct nfp_mip *mip);
+
+void nfp_mip_symtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
+void nfp_mip_strtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
+
 #endif /* NFP_NFFW_H */
-- 
2.11.0
