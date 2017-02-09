From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/12] nfp: add rtsym support
Date: Thu,  9 Feb 2017 09:17:34 -0800
Message-ID: <20170209171738.17386-9-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36318 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754278AbdBIR2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:28:31 -0500
Received: by mail-pg0-f47.google.com with SMTP id v184so2299043pgv.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:28:30 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using application FW symbol table to look up
location of information in device memory.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |   2 +
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   |  12 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |  34 +++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c | 304 +++++++++++++++++++++
 5 files changed, 353 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 9c0662170de8..7765088f7e01 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -8,6 +8,7 @@ nfp-objs := \
 	    nfpcore/nfp_mip.o \
 	    nfpcore/nfp_nffw.o \
 	    nfpcore/nfp_resource.o \
+	    nfpcore/nfp_rtsym.o \
 	    nfpcore/nfp_target.o \
 	    nfp_main.o \
 	    nfp_net_common.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 1798ece689f7..58a15185572e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -221,6 +221,8 @@ int nfp_cpp_serial(struct nfp_cpp *cpp, const u8 **serial);
 
 void *nfp_hwinfo_cache(struct nfp_cpp *cpp);
 void nfp_hwinfo_cache_set(struct nfp_cpp *cpp, void *val);
+void *nfp_rtsym_cache(struct nfp_cpp *cpp);
+void nfp_rtsym_cache_set(struct nfp_cpp *cpp, void *val);
 
 struct nfp_cpp_area *nfp_cpp_area_alloc_with_name(struct nfp_cpp *cpp,
 						  u32 cpp_id,
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index aa94780f4dc7..ab870294c604 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -99,6 +99,7 @@ struct nfp_cpp {
 
 	/* Cached information */
 	void *hwinfo;
+	void *rtsym;
 };
 
 /* Element of the area_cache_list */
@@ -241,6 +242,7 @@ void nfp_cpp_free(struct nfp_cpp *cpp)
 		cpp->op->free(cpp);
 
 	kfree(cpp->hwinfo);
+	kfree(cpp->rtsym);
 
 	device_unregister(&cpp->dev);
 
@@ -292,6 +294,16 @@ void nfp_hwinfo_cache_set(struct nfp_cpp *cpp, void *val)
 	cpp->hwinfo = val;
 }
 
+void *nfp_rtsym_cache(struct nfp_cpp *cpp)
+{
+	return cpp->rtsym;
+}
+
+void nfp_rtsym_cache_set(struct nfp_cpp *cpp, void *val)
+{
+	cpp->rtsym = val;
+}
+
 /**
  * nfp_cpp_area_alloc_with_name() - allocate a new CPP area
  * @cpp:	CPP device handle
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
index c91138c0daab..988badd230d1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
@@ -58,4 +58,38 @@ void nfp_mip_close(const struct nfp_mip *mip);
 void nfp_mip_symtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
 void nfp_mip_strtab(const struct nfp_mip *mip, u32 *addr, u32 *size);
 
+/* Implemented in nfp_rtsym.c */
+
+#define NFP_RTSYM_TYPE_NONE		0
+#define NFP_RTSYM_TYPE_OBJECT		1
+#define NFP_RTSYM_TYPE_FUNCTION		2
+#define NFP_RTSYM_TYPE_ABS		3
+
+#define NFP_RTSYM_TARGET_NONE		0
+#define NFP_RTSYM_TARGET_LMEM		-1
+#define NFP_RTSYM_TARGET_EMU_CACHE	-7
+
+/**
+ * struct nfp_rtsym - RTSYM descriptor
+ * @name:	Symbol name
+ * @addr:	Address in the domain/target's address space
+ * @size:	Size (in bytes) of the symbol
+ * @type:	NFP_RTSYM_TYPE_* of the symbol
+ * @target:	CPP Target identifier, or NFP_RTSYM_TARGET_*
+ * @domain:	CPP Target Domain (island)
+ */
+struct nfp_rtsym {
+	const char *name;
+	u64 addr;
+	u64 size;
+	int type;
+	int target;
+	int domain;
+};
+
+int nfp_rtsym_count(struct nfp_cpp *cpp);
+const struct nfp_rtsym *nfp_rtsym_get(struct nfp_cpp *cpp, int idx);
+const struct nfp_rtsym *nfp_rtsym_lookup(struct nfp_cpp *cpp, const char *name);
+u64 nfp_rtsym_read_le(struct nfp_cpp *cpp, const char *name, int *error);
+
 #endif /* NFP_NFFW_H */
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
new file mode 100644
index 000000000000..c659b1d999be
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
@@ -0,0 +1,304 @@
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
+ * nfp_rtsym.c
+ * Interface for accessing run-time symbol table
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Espen Skoglund <espen.skoglund@netronome.com>
+ *          Francois H. Theron <francois.theron@netronome.com>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/io-64-nonatomic-hi-lo.h>
+
+#include "nfp.h"
+#include "nfp_cpp.h"
+#include "nfp_nffw.h"
+#include "nfp6000/nfp6000.h"
+
+/* These need to match the linker */
+#define SYM_TGT_LMEM		0
+#define SYM_TGT_EMU_CACHE	0x17
+
+struct nfp_rtsym_entry {
+	u8	type;
+	u8	target;
+	u8	island;
+	u8	addr_hi;
+	__le32	addr_lo;
+	__le16	name;
+	u8	menum;
+	u8	size_hi;
+	__le32	size_lo;
+};
+
+struct nfp_rtsym_cache {
+	int num;
+	char *strtab;
+	struct nfp_rtsym symtab[];
+};
+
+static int nfp_meid(u8 island_id, u8 menum)
+{
+	return (island_id & 0x3F) == island_id && menum < 12 ?
+		(island_id << 4) | (menum + 4) : -1;
+}
+
+static void
+nfp_rtsym_sw_entry_init(struct nfp_rtsym_cache *cache, u32 strtab_size,
+			struct nfp_rtsym *sw, struct nfp_rtsym_entry *fw)
+{
+	sw->type = fw->type;
+	sw->name = cache->strtab + le16_to_cpu(fw->name) % strtab_size;
+	sw->addr = ((u64)fw->addr_hi << 32) | le32_to_cpu(fw->addr_lo);
+	sw->size = ((u64)fw->size_hi << 32) | le32_to_cpu(fw->size_lo);
+
+	switch (fw->target) {
+	case SYM_TGT_LMEM:
+		sw->target = NFP_RTSYM_TARGET_LMEM;
+		break;
+	case SYM_TGT_EMU_CACHE:
+		sw->target = NFP_RTSYM_TARGET_EMU_CACHE;
+		break;
+	default:
+		sw->target = fw->target;
+		break;
+	}
+
+	if (fw->menum != 0xff)
+		sw->domain = nfp_meid(fw->island, fw->menum);
+	else if (fw->island != 0xff)
+		sw->domain = fw->island;
+	else
+		sw->domain = -1;
+}
+
+static int nfp_rtsymtab_probe(struct nfp_cpp *cpp)
+{
+	const u32 dram = NFP_CPP_ID(NFP_CPP_TARGET_MU, NFP_CPP_ACTION_RW, 0) |
+		NFP_ISL_EMEM0;
+	u32 strtab_addr, symtab_addr, strtab_size, symtab_size;
+	struct nfp_rtsym_entry *rtsymtab;
+	struct nfp_rtsym_cache *cache;
+	const struct nfp_mip *mip;
+	int err, n, size;
+
+	mip = nfp_mip_open(cpp);
+	if (!mip)
+		return -EIO;
+
+	nfp_mip_strtab(mip, &strtab_addr, &strtab_size);
+	nfp_mip_symtab(mip, &symtab_addr, &symtab_size);
+	nfp_mip_close(mip);
+
+	if (!symtab_size || !strtab_size || symtab_size % sizeof(*rtsymtab))
+		return -ENXIO;
+
+	/* Align to 64 bits */
+	symtab_size = round_up(symtab_size, 8);
+	strtab_size = round_up(strtab_size, 8);
+
+	rtsymtab = kmalloc(symtab_size, GFP_KERNEL);
+	if (!rtsymtab)
+		return -ENOMEM;
+
+	size = sizeof(*cache);
+	size += symtab_size / sizeof(*rtsymtab) * sizeof(struct nfp_rtsym);
+	size +=	strtab_size + 1;
+	cache = kmalloc(size, GFP_KERNEL);
+	if (!cache) {
+		err = -ENOMEM;
+		goto err_free_rtsym_raw;
+	}
+
+	cache->num = symtab_size / sizeof(*rtsymtab);
+	cache->strtab = (void *)&cache->symtab[cache->num];
+
+	err = nfp_cpp_read(cpp, dram, symtab_addr, rtsymtab, symtab_size);
+	if (err != symtab_size)
+		goto err_free_cache;
+
+	err = nfp_cpp_read(cpp, dram, strtab_addr, cache->strtab, strtab_size);
+	if (err != strtab_size)
+		goto err_free_cache;
+	cache->strtab[strtab_size] = '\0';
+
+	for (n = 0; n < cache->num; n++)
+		nfp_rtsym_sw_entry_init(cache, strtab_size,
+					&cache->symtab[n], &rtsymtab[n]);
+
+	kfree(rtsymtab);
+	nfp_rtsym_cache_set(cpp, cache);
+	return 0;
+
+err_free_cache:
+	kfree(cache);
+err_free_rtsym_raw:
+	kfree(rtsymtab);
+	return err;
+}
+
+static struct nfp_rtsym_cache *nfp_rtsym(struct nfp_cpp *cpp)
+{
+	struct nfp_rtsym_cache *cache;
+	int err;
+
+	cache = nfp_rtsym_cache(cpp);
+	if (cache)
+		return cache;
+
+	err = nfp_rtsymtab_probe(cpp);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	return nfp_rtsym_cache(cpp);
+}
+
+/**
+ * nfp_rtsym_count() - Get the number of RTSYM descriptors
+ * @cpp:	NFP CPP handle
+ *
+ * Return: Number of RTSYM descriptors, or -ERRNO
+ */
+int nfp_rtsym_count(struct nfp_cpp *cpp)
+{
+	struct nfp_rtsym_cache *cache;
+
+	cache = nfp_rtsym(cpp);
+	if (IS_ERR(cache))
+		return PTR_ERR(cache);
+
+	return cache->num;
+}
+
+/**
+ * nfp_rtsym_get() - Get the Nth RTSYM descriptor
+ * @cpp:	NFP CPP handle
+ * @idx:	Index (0-based) of the RTSYM descriptor
+ *
+ * Return: const pointer to a struct nfp_rtsym descriptor, or NULL
+ */
+const struct nfp_rtsym *nfp_rtsym_get(struct nfp_cpp *cpp, int idx)
+{
+	struct nfp_rtsym_cache *cache;
+
+	cache = nfp_rtsym(cpp);
+	if (IS_ERR(cache))
+		return NULL;
+
+	if (idx >= cache->num)
+		return NULL;
+
+	return &cache->symtab[idx];
+}
+
+/**
+ * nfp_rtsym_lookup() - Return the RTSYM descriptor for a symbol name
+ * @cpp:	NFP CPP handle
+ * @name:	Symbol name
+ *
+ * Return: const pointer to a struct nfp_rtsym descriptor, or NULL
+ */
+const struct nfp_rtsym *nfp_rtsym_lookup(struct nfp_cpp *cpp, const char *name)
+{
+	struct nfp_rtsym_cache *cache;
+	int n;
+
+	cache = nfp_rtsym(cpp);
+	if (IS_ERR(cache))
+		return NULL;
+
+	for (n = 0; n < cache->num; n++) {
+		if (strcmp(name, cache->symtab[n].name) == 0)
+			return &cache->symtab[n];
+	}
+
+	return NULL;
+}
+
+/**
+ * nfp_rtsym_read_le() - Read a simple unsigned scalar value from symbol
+ * @cpp:	NFP CPP handle
+ * @name:	Symbol name
+ * @error:	Poniter to error code (optional)
+ *
+ * Lookup a symbol, map, read it and return it's value. Value of the symbol
+ * will be interpreted as a simple little-endian unsigned value. Symbol can
+ * be 4 or 8 bytes in size.
+ *
+ * Return: value read, on error sets the error and returns ~0ULL.
+ */
+u64 nfp_rtsym_read_le(struct nfp_cpp *cpp, const char *name, int *error)
+{
+	const struct nfp_rtsym *sym;
+	u32 val32, id;
+	u64 val;
+	int err;
+
+	sym = nfp_rtsym_lookup(cpp, name);
+	if (!sym)
+		return -ENOENT;
+
+	id = NFP_CPP_ISLAND_ID(sym->target, NFP_CPP_ACTION_RW, 0, sym->domain);
+
+	switch (sym->size) {
+	case 4:
+		err = nfp_cpp_readl(cpp, id, sym->addr, &val32);
+		val = val32;
+		break;
+	case 8:
+		err = nfp_cpp_readq(cpp, id, sym->addr, &val);
+		break;
+	default:
+		nfp_err(cpp,
+			"rtsym '%s' unsupported or non-scalar size: %lld\n",
+			name, sym->size);
+		err = -EINVAL;
+		break;
+	}
+
+	if (err == sym->size)
+		err = 0;
+	else if (err >= 0)
+		err = -EIO;
+
+	if (error)
+		*error = err;
+
+	if (err)
+		return ~0ULL;
+	return val;
+}
-- 
2.11.0
