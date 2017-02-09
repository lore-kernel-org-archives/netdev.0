From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/12] nfp: add support for service processor access
Date: Thu,  9 Feb 2017 09:17:35 -0800
Message-ID: <20170209171738.17386-10-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35243 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753588AbdBIR24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:28:56 -0500
Received: by mail-pf0-f180.google.com with SMTP id f144so2019281pfa.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:28:55 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFP Service Processor (NSP) is an ARM core inside the chip which
is responsible for management and control functions.  Add support
for chip reset, FW load and external module access using the NSP.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   2 +
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  14 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |   2 +
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   |  13 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   | 417 +++++++++++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 270 +++++++++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   |  81 ++++
 7 files changed, 799 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 7765088f7e01..eab39aec5b24 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -7,6 +7,8 @@ nfp-objs := \
 	    nfpcore/nfp_hwinfo.o \
 	    nfpcore/nfp_mip.o \
 	    nfpcore/nfp_nffw.o \
+	    nfpcore/nfp_nsp.o \
+	    nfpcore/nfp_nsp_eth.o \
 	    nfpcore/nfp_resource.o \
 	    nfpcore/nfp_rtsym.o \
 	    nfpcore/nfp_target.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 1eae3e1e5fbe..3d70a8578a98 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -47,6 +47,20 @@
 
 const char *nfp_hwinfo_lookup(struct nfp_cpp *cpp, const char *lookup);
 
+/* Implemented in nfp_nsp.c */
+
+struct nfp_nsp;
+struct firmware;
+
+struct nfp_nsp *nfp_nsp_open(struct nfp_cpp *cpp);
+void nfp_nsp_close(struct nfp_nsp *state);
+int nfp_nsp_wait(struct nfp_nsp *state);
+int nfp_nsp_device_soft_reset(struct nfp_nsp *state);
+int nfp_nsp_load_fw(struct nfp_nsp *state, const struct firmware *fw);
+int nfp_nsp_read_eth_table(struct nfp_nsp *state, void *buf, unsigned int size);
+int nfp_nsp_write_eth_table(struct nfp_nsp *state,
+			    const void *buf, unsigned int size);
+
 /* Implemented in nfp_resource.c */
 
 #define NFP_RESOURCE_TBL_TARGET		NFP_CPP_TARGET_MU
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 58a15185572e..74e6f9f59bdc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -224,6 +224,8 @@ void nfp_hwinfo_cache_set(struct nfp_cpp *cpp, void *val);
 void *nfp_rtsym_cache(struct nfp_cpp *cpp);
 void nfp_rtsym_cache_set(struct nfp_cpp *cpp, void *val);
 
+void nfp_nffw_cache_flush(struct nfp_cpp *cpp);
+
 struct nfp_cpp_area *nfp_cpp_area_alloc_with_name(struct nfp_cpp *cpp,
 						  u32 cpp_id,
 						  const char *name,
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index ab870294c604..40108e66c654 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -305,6 +305,19 @@ void nfp_rtsym_cache_set(struct nfp_cpp *cpp, void *val)
 }
 
 /**
+ * nfp_nffw_cache_flush() - Flush cached firmware information
+ * @cpp:	NFP CPP handle
+ *
+ * Flush cached firmware information.  This function should be called
+ * every time firmware is loaded on unloaded.
+ */
+void nfp_nffw_cache_flush(struct nfp_cpp *cpp)
+{
+	kfree(nfp_rtsym_cache(cpp));
+	nfp_rtsym_cache_set(cpp, NULL);
+}
+
+/**
  * nfp_cpp_area_alloc_with_name() - allocate a new CPP area
  * @cpp:	CPP device handle
  * @dest:	NFP CPP ID
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
new file mode 100644
index 000000000000..f07f2fc3fba0
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -0,0 +1,417 @@
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
+ * nfp_nsp.c
+ * Author: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *         Jason McMullan <jason.mcmullan@netronome.com>
+ */
+
+#include <linux/bitfield.h>
+#include <linux/delay.h>
+#include <linux/firmware.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/sizes.h>
+#include <linux/slab.h>
+
+#define NFP_SUBSYS "nfp_nsp"
+
+#include "nfp.h"
+#include "nfp_cpp.h"
+
+/* Offsets relative to the CSR base */
+#define NSP_STATUS		0x00
+#define   NSP_STATUS_MAGIC	GENMASK_ULL(63, 48)
+#define   NSP_STATUS_MAJOR	GENMASK_ULL(47, 44)
+#define   NSP_STATUS_MINOR	GENMASK_ULL(43, 32)
+#define   NSP_STATUS_CODE	GENMASK_ULL(31, 16)
+#define   NSP_STATUS_RESULT	GENMASK_ULL(15, 8)
+#define   NSP_STATUS_BUSY	BIT_ULL(0)
+
+#define NSP_COMMAND		0x08
+#define   NSP_COMMAND_OPTION	GENMASK_ULL(63, 32)
+#define   NSP_COMMAND_CODE	GENMASK_ULL(31, 16)
+#define   NSP_COMMAND_START	BIT_ULL(0)
+
+/* CPP address to retrieve the data from */
+#define NSP_BUFFER		0x10
+#define   NSP_BUFFER_CPP	GENMASK_ULL(63, 40)
+#define   NSP_BUFFER_PCIE	GENMASK_ULL(39, 38)
+#define   NSP_BUFFER_ADDRESS	GENMASK_ULL(37, 0)
+
+#define NSP_DFLT_BUFFER		0x18
+
+#define NSP_DFLT_BUFFER_CONFIG	0x20
+#define   NSP_DFLT_BUFFER_SIZE_MB	GENMASK_ULL(7, 0)
+
+#define NSP_MAGIC		0xab10
+#define NSP_MAJOR		0
+#define NSP_MINOR		(__MAX_SPCODE - 1)
+
+#define NSP_CODE_MAJOR		GENMASK(15, 12)
+#define NSP_CODE_MINOR		GENMASK(11, 0)
+
+enum nfp_nsp_cmd {
+	SPCODE_NOOP		= 0, /* No operation */
+	SPCODE_SOFT_RESET	= 1, /* Soft reset the NFP */
+	SPCODE_FW_DEFAULT	= 2, /* Load default (UNDI) FW */
+	SPCODE_PHY_INIT		= 3, /* Initialize the PHY */
+	SPCODE_MAC_INIT		= 4, /* Initialize the MAC */
+	SPCODE_PHY_RXADAPT	= 5, /* Re-run PHY RX Adaptation */
+	SPCODE_FW_LOAD		= 6, /* Load fw from buffer, len in option */
+	SPCODE_ETH_RESCAN	= 7, /* Rescan ETHs, write ETH_TABLE to buf */
+	SPCODE_ETH_CONTROL	= 8, /* Update media config from buffer */
+
+	__MAX_SPCODE,
+};
+
+struct nfp_nsp {
+	struct nfp_cpp *cpp;
+	struct nfp_resource *res;
+};
+
+static int nfp_nsp_check(struct nfp_nsp *state)
+{
+	struct nfp_cpp *cpp = state->cpp;
+	u64 nsp_status, reg;
+	u32 nsp_cpp;
+	int err;
+
+	nsp_cpp = nfp_resource_cpp_id(state->res);
+	nsp_status = nfp_resource_address(state->res) + NSP_STATUS;
+
+	err = nfp_cpp_readq(cpp, nsp_cpp, nsp_status, &reg);
+	if (err < 0)
+		return err;
+
+	if (FIELD_GET(NSP_STATUS_MAGIC, reg) != NSP_MAGIC) {
+		nfp_err(cpp, "Cannot detect NFP Service Processor\n");
+		return -ENODEV;
+	}
+
+	if (FIELD_GET(NSP_STATUS_MAJOR, reg) != NSP_MAJOR ||
+	    FIELD_GET(NSP_STATUS_MINOR, reg) < NSP_MINOR) {
+		nfp_err(cpp, "Unsupported ABI %lld.%lld\n",
+			FIELD_GET(NSP_STATUS_MAJOR, reg),
+			FIELD_GET(NSP_STATUS_MINOR, reg));
+		return -EINVAL;
+	}
+
+	if (reg & NSP_STATUS_BUSY) {
+		nfp_err(cpp, "Service processor busy!\n");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+/**
+ * nfp_nsp_open() - Prepare for communication and lock the NSP resource.
+ * @cpp:	NFP CPP Handle
+ */
+struct nfp_nsp *nfp_nsp_open(struct nfp_cpp *cpp)
+{
+	struct nfp_resource *res;
+	struct nfp_nsp *state;
+	int err;
+
+	res = nfp_resource_acquire(cpp, NFP_RESOURCE_NSP);
+	if (IS_ERR(res))
+		return (void *)res;
+
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		nfp_resource_release(res);
+		return ERR_PTR(-ENOMEM);
+	}
+	state->cpp = cpp;
+	state->res = res;
+
+	err = nfp_nsp_check(state);
+	if (err) {
+		nfp_nsp_close(state);
+		return ERR_PTR(err);
+	}
+
+	return state;
+}
+
+/**
+ * nfp_nsp_close() - Clean up and unlock the NSP resource.
+ * @state:	NFP SP state
+ */
+void nfp_nsp_close(struct nfp_nsp *state)
+{
+	nfp_resource_release(state->res);
+	kfree(state);
+}
+
+static int
+nfp_nsp_wait_reg(struct nfp_cpp *cpp, u64 *reg,
+		 u32 nsp_cpp, u64 addr, u64 mask, u64 val)
+{
+	const unsigned long wait_until = jiffies + 30 * HZ;
+	int err;
+
+	for (;;) {
+		const unsigned long start_time = jiffies;
+
+		err = nfp_cpp_readq(cpp, nsp_cpp, addr, reg);
+		if (err < 0)
+			return err;
+
+		if ((*reg & mask) == val)
+			return 0;
+
+		err = msleep_interruptible(100);
+		if (err)
+			return err;
+
+		if (time_after(start_time, wait_until))
+			return -ETIMEDOUT;
+	}
+}
+
+/**
+ * nfp_nsp_command() - Execute a command on the NFP Service Processor
+ * @state:	NFP SP state
+ * @code:	NFP SP Command Code
+ * @option:	NFP SP Command Argument
+ * @buff_cpp:	NFP SP Buffer CPP Address info
+ * @buff_addr:	NFP SP Buffer Host address
+ *
+ * Return: 0 for success with no result
+ *
+ *	 1..255 for NSP completion with a result code
+ *
+ *	-EAGAIN if the NSP is not yet present
+ *	-ENODEV if the NSP is not a supported model
+ *	-EBUSY if the NSP is stuck
+ *	-EINTR if interrupted while waiting for completion
+ *	-ETIMEDOUT if the NSP took longer than 30 seconds to complete
+ */
+static int nfp_nsp_command(struct nfp_nsp *state, u16 code, u32 option,
+			   u32 buff_cpp, u64 buff_addr)
+{
+	u64 reg, nsp_base, nsp_buffer, nsp_status, nsp_command;
+	struct nfp_cpp *cpp = state->cpp;
+	u32 nsp_cpp;
+	int err;
+
+	nsp_cpp = nfp_resource_cpp_id(state->res);
+	nsp_base = nfp_resource_address(state->res);
+	nsp_status = nsp_base + NSP_STATUS;
+	nsp_command = nsp_base + NSP_COMMAND;
+	nsp_buffer = nsp_base + NSP_BUFFER;
+
+	err = nfp_nsp_check(state);
+	if (err)
+		return err;
+
+	if (!FIELD_FIT(NSP_BUFFER_CPP, buff_cpp >> 8) ||
+	    !FIELD_FIT(NSP_BUFFER_ADDRESS, buff_addr)) {
+		nfp_err(cpp, "Host buffer out of reach %08x %016llx\n",
+			buff_cpp, buff_addr);
+		return -EINVAL;
+	}
+
+	err = nfp_cpp_writeq(cpp, nsp_cpp, nsp_buffer,
+			     FIELD_PREP(NSP_BUFFER_CPP, buff_cpp >> 8) |
+			     FIELD_PREP(NSP_BUFFER_ADDRESS, buff_addr));
+	if (err < 0)
+		return err;
+
+	err = nfp_cpp_writeq(cpp, nsp_cpp, nsp_command,
+			     FIELD_PREP(NSP_COMMAND_OPTION, option) |
+			     FIELD_PREP(NSP_COMMAND_CODE, code) |
+			     FIELD_PREP(NSP_COMMAND_START, 1));
+	if (err < 0)
+		return err;
+
+	/* Wait for NSP_COMMAND_START to go to 0 */
+	err = nfp_nsp_wait_reg(cpp, &reg,
+			       nsp_cpp, nsp_command, NSP_COMMAND_START, 0);
+	if (err) {
+		nfp_err(cpp, "Error %d waiting for code 0x%04x to start\n",
+			err, code);
+		return err;
+	}
+
+	/* Wait for NSP_STATUS_BUSY to go to 0 */
+	err = nfp_nsp_wait_reg(cpp, &reg,
+			       nsp_cpp, nsp_status, NSP_STATUS_BUSY, 0);
+	if (err) {
+		nfp_err(cpp, "Error %d waiting for code 0x%04x to complete\n",
+			err, code);
+		return err;
+	}
+
+	err = FIELD_GET(NSP_STATUS_RESULT, reg);
+	if (err) {
+		nfp_warn(cpp, "Result (error) code set: %d command: %d\n",
+			 -err, code);
+		return -err;
+	}
+
+	err = nfp_cpp_readq(cpp, nsp_cpp, nsp_command, &reg);
+	if (err < 0)
+		return err;
+
+	return FIELD_GET(NSP_COMMAND_OPTION, reg);
+}
+
+static int nfp_nsp_command_buf(struct nfp_nsp *nsp, u16 code, u32 option,
+			       const void *in_buf, unsigned int in_size,
+			       void *out_buf, unsigned int out_size)
+{
+	struct nfp_cpp *cpp = nsp->cpp;
+	unsigned int max_size;
+	u64 reg, cpp_buf;
+	int ret, err;
+	u32 cpp_id;
+
+	err = nfp_cpp_readq(cpp, nfp_resource_cpp_id(nsp->res),
+			    nfp_resource_address(nsp->res) + NSP_STATUS, &reg);
+	if (err < 0)
+		return err;
+
+	if (FIELD_GET(NSP_STATUS_MINOR, reg) < 13) {
+		nfp_err(cpp, "NSP: Code 0x%04x with buffer not supported (ABI %lld.%lld)\n",
+			code, FIELD_GET(NSP_STATUS_MAJOR, reg),
+			FIELD_GET(NSP_STATUS_MINOR, reg));
+		return -EOPNOTSUPP;
+	}
+
+	err = nfp_cpp_readq(cpp, nfp_resource_cpp_id(nsp->res),
+			    nfp_resource_address(nsp->res) +
+			    NSP_DFLT_BUFFER_CONFIG,
+			    &reg);
+	if (err < 0)
+		return err;
+
+	max_size = max(in_size, out_size);
+	if (FIELD_GET(NSP_DFLT_BUFFER_SIZE_MB, reg) * SZ_1M < max_size) {
+		nfp_err(cpp, "NSP: default buffer too small for command 0x%04x (%llu < %u)\n",
+			code, FIELD_GET(NSP_DFLT_BUFFER_SIZE_MB, reg) * SZ_1M,
+			max_size);
+		return -EINVAL;
+	}
+
+	err = nfp_cpp_readq(cpp, nfp_resource_cpp_id(nsp->res),
+			    nfp_resource_address(nsp->res) +
+			    NSP_DFLT_BUFFER,
+			    &reg);
+	if (err < 0)
+		return err;
+
+	cpp_id = FIELD_GET(NSP_BUFFER_CPP, reg) << 8;
+	cpp_buf = FIELD_GET(NSP_BUFFER_ADDRESS, reg);
+
+	if (in_buf && in_size) {
+		err = nfp_cpp_write(cpp, cpp_id, cpp_buf, in_buf, in_size);
+		if (err < 0)
+			return err;
+	}
+
+	ret = nfp_nsp_command(nsp, code, option, cpp_id, cpp_buf);
+	if (ret < 0)
+		return ret;
+
+	if (out_buf && out_size) {
+		err = nfp_cpp_read(cpp, cpp_id, cpp_buf, out_buf, out_size);
+		if (err < 0)
+			return err;
+	}
+
+	return ret;
+}
+
+int nfp_nsp_wait(struct nfp_nsp *state)
+{
+	const unsigned long wait_until = jiffies + 30 * HZ;
+	int err;
+
+	nfp_dbg(state->cpp, "Waiting for NSP to respond (30 sec max).\n");
+
+	for (;;) {
+		const unsigned long start_time = jiffies;
+
+		err = nfp_nsp_command(state, SPCODE_NOOP, 0, 0, 0);
+		if (err != -EAGAIN)
+			break;
+
+		err = msleep_interruptible(100);
+		if (err)
+			break;
+
+		if (time_after(start_time, wait_until)) {
+			err = -ETIMEDOUT;
+			break;
+		}
+	}
+	if (err)
+		nfp_err(state->cpp, "NSP failed to respond %d\n", err);
+
+	return err;
+}
+
+int nfp_nsp_device_soft_reset(struct nfp_nsp *state)
+{
+	int err;
+
+	err = nfp_nsp_command(state, SPCODE_SOFT_RESET, 0, 0, 0);
+
+	nfp_nffw_cache_flush(state->cpp);
+
+	return err;
+}
+
+int nfp_nsp_load_fw(struct nfp_nsp *state, const struct firmware *fw)
+{
+	return nfp_nsp_command_buf(state, SPCODE_FW_LOAD, fw->size, fw->data,
+				   fw->size, NULL, 0);
+}
+
+int nfp_nsp_read_eth_table(struct nfp_nsp *state, void *buf, unsigned int size)
+{
+	return nfp_nsp_command_buf(state, SPCODE_ETH_RESCAN, size, NULL, 0,
+				   buf, size);
+}
+
+int nfp_nsp_write_eth_table(struct nfp_nsp *state,
+			    const void *buf, unsigned int size)
+{
+	return nfp_nsp_command_buf(state, SPCODE_ETH_CONTROL, size, buf, size,
+				   NULL, 0);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
new file mode 100644
index 000000000000..1ece1f8ae4b3
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -0,0 +1,270 @@
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
+/* Authors: David Brunecz <david.brunecz@netronome.com>
+ *          Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason Mcmullan <jason.mcmullan@netronome.com>
+ */
+
+#include <linux/bitfield.h>
+#include <linux/ethtool.h>
+#include <linux/if_ether.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#include "nfp.h"
+#include "nfp_nsp_eth.h"
+#include "nfp6000/nfp6000.h"
+
+#define NSP_ETH_NBI_PORT_COUNT		24
+#define NSP_ETH_MAX_COUNT		(2 * NSP_ETH_NBI_PORT_COUNT)
+#define NSP_ETH_TABLE_SIZE		(NSP_ETH_MAX_COUNT *		\
+					 sizeof(struct eth_table_entry))
+
+#define NSP_ETH_PORT_LANES		GENMASK_ULL(3, 0)
+#define NSP_ETH_PORT_INDEX		GENMASK_ULL(15, 8)
+#define NSP_ETH_PORT_LABEL		GENMASK_ULL(53, 48)
+#define NSP_ETH_PORT_PHYLABEL		GENMASK_ULL(59, 54)
+
+#define NSP_ETH_PORT_LANES_MASK		cpu_to_le64(NSP_ETH_PORT_LANES)
+
+#define NSP_ETH_STATE_ENABLED		BIT_ULL(1)
+#define NSP_ETH_STATE_TX_ENABLED	BIT_ULL(2)
+#define NSP_ETH_STATE_RX_ENABLED	BIT_ULL(3)
+#define NSP_ETH_STATE_RATE		GENMASK_ULL(11, 8)
+
+#define NSP_ETH_CTRL_ENABLED		BIT_ULL(1)
+#define NSP_ETH_CTRL_TX_ENABLED		BIT_ULL(2)
+#define NSP_ETH_CTRL_RX_ENABLED		BIT_ULL(3)
+
+enum nfp_eth_rate {
+	RATE_INVALID = 0,
+	RATE_10M,
+	RATE_100M,
+	RATE_1G,
+	RATE_10G,
+	RATE_25G,
+};
+
+struct eth_table_entry {
+	__le64 port;
+	__le64 state;
+	u8 mac_addr[6];
+	u8 resv[2];
+	__le64 control;
+};
+
+static unsigned int nfp_eth_rate(enum nfp_eth_rate rate)
+{
+	unsigned int rate_xlate[] = {
+		[RATE_INVALID]		= 0,
+		[RATE_10M]		= SPEED_10,
+		[RATE_100M]		= SPEED_100,
+		[RATE_1G]		= SPEED_1000,
+		[RATE_10G]		= SPEED_10000,
+		[RATE_25G]		= SPEED_25000,
+	};
+
+	if (rate >= ARRAY_SIZE(rate_xlate))
+		return 0;
+
+	return rate_xlate[rate];
+}
+
+static void nfp_eth_copy_mac_reverse(u8 *dst, const u8 *src)
+{
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		dst[ETH_ALEN - i - 1] = src[i];
+}
+
+static void
+nfp_eth_port_translate(const struct eth_table_entry *src, unsigned int index,
+		       struct nfp_eth_table_port *dst)
+{
+	unsigned int rate;
+	u64 port, state;
+
+	port = le64_to_cpu(src->port);
+	state = le64_to_cpu(src->state);
+
+	dst->eth_index = FIELD_GET(NSP_ETH_PORT_INDEX, port);
+	dst->index = index;
+	dst->nbi = index / NSP_ETH_NBI_PORT_COUNT;
+	dst->base = index % NSP_ETH_NBI_PORT_COUNT;
+	dst->lanes = FIELD_GET(NSP_ETH_PORT_LANES, port);
+
+	dst->enabled = FIELD_GET(NSP_ETH_STATE_ENABLED, state);
+	dst->tx_enabled = FIELD_GET(NSP_ETH_STATE_TX_ENABLED, state);
+	dst->rx_enabled = FIELD_GET(NSP_ETH_STATE_RX_ENABLED, state);
+
+	rate = nfp_eth_rate(FIELD_GET(NSP_ETH_STATE_RATE, state));
+	dst->speed = dst->lanes * rate;
+
+	nfp_eth_copy_mac_reverse(dst->mac_addr, src->mac_addr);
+
+	snprintf(dst->label, sizeof(dst->label) - 1, "%llu.%llu",
+		 FIELD_GET(NSP_ETH_PORT_PHYLABEL, port),
+		 FIELD_GET(NSP_ETH_PORT_LABEL, port));
+}
+
+/**
+ * nfp_eth_read_ports() - retrieve port information
+ * @cpp:	NFP CPP handle
+ *
+ * Read the port information from the device.  Returned structure should
+ * be freed with kfree() once no longer needed.
+ *
+ * Return: populated ETH table or NULL on error.
+ */
+struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp)
+{
+	struct nfp_eth_table *ret;
+	struct nfp_nsp *nsp;
+
+	nsp = nfp_nsp_open(cpp);
+	if (IS_ERR(nsp))
+		return NULL;
+
+	ret = __nfp_eth_read_ports(cpp, nsp);
+	nfp_nsp_close(nsp);
+
+	return ret;
+}
+
+struct nfp_eth_table *
+__nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
+{
+	struct eth_table_entry *entries;
+	struct nfp_eth_table *table;
+	unsigned int cnt;
+	int i, j, ret;
+
+	entries = kzalloc(NSP_ETH_TABLE_SIZE, GFP_KERNEL);
+	if (!entries)
+		return NULL;
+
+	ret = nfp_nsp_read_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
+	if (ret < 0) {
+		nfp_err(cpp, "reading port table failed %d\n", ret);
+		kfree(entries);
+		return NULL;
+	}
+
+	/* Some versions of flash will give us 0 instead of port count */
+	cnt = ret;
+	if (!cnt) {
+		for (i = 0; i < NSP_ETH_MAX_COUNT; i++)
+			if (entries[i].port & NSP_ETH_PORT_LANES_MASK)
+				cnt++;
+	}
+
+	table = kzalloc(sizeof(*table) +
+			sizeof(struct nfp_eth_table_port) * cnt, GFP_KERNEL);
+	if (!table) {
+		kfree(entries);
+		return NULL;
+	}
+
+	table->count = cnt;
+	for (i = 0, j = 0; i < NSP_ETH_MAX_COUNT; i++)
+		if (entries[i].port & NSP_ETH_PORT_LANES_MASK)
+			nfp_eth_port_translate(&entries[i], i,
+					       &table->ports[j++]);
+
+	kfree(entries);
+
+	return table;
+}
+
+/**
+ * nfp_eth_set_mod_enable() - set PHY module enable control bit
+ * @cpp:	NFP CPP handle
+ * @idx:	NFP chip-wide port index
+ * @enable:	Desired state
+ *
+ * Enable or disable PHY module (this usually means setting the TX lanes
+ * disable bits).
+ *
+ * Return: 0 or -ERRNO.
+ */
+int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
+{
+	struct eth_table_entry *entries;
+	struct nfp_nsp *nsp;
+	u64 reg;
+	int ret;
+
+	entries = kzalloc(NSP_ETH_TABLE_SIZE, GFP_KERNEL);
+	if (!entries)
+		return -ENOMEM;
+
+	nsp = nfp_nsp_open(cpp);
+	if (IS_ERR(nsp)) {
+		kfree(entries);
+		return PTR_ERR(nsp);
+	}
+
+	ret = nfp_nsp_read_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
+	if (ret < 0) {
+		nfp_err(cpp, "reading port table failed %d\n", ret);
+		goto exit_close_nsp;
+	}
+
+	if (!(entries[idx].port & NSP_ETH_PORT_LANES_MASK)) {
+		nfp_warn(cpp, "trying to set port state on disabled port %d\n",
+			 idx);
+		ret = -EINVAL;
+		goto exit_close_nsp;
+	}
+
+	/* Check if we are already in requested state */
+	reg = le64_to_cpu(entries[idx].state);
+	if (enable == FIELD_GET(NSP_ETH_CTRL_ENABLED, reg)) {
+		ret = 0;
+		goto exit_close_nsp;
+	}
+
+	reg = le64_to_cpu(entries[idx].control);
+	reg &= ~NSP_ETH_CTRL_ENABLED;
+	reg |= FIELD_PREP(NSP_ETH_CTRL_ENABLED, enable);
+	entries[idx].control = cpu_to_le64(reg);
+
+	ret = nfp_nsp_write_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
+exit_close_nsp:
+	nfp_nsp_close(nsp);
+	kfree(entries);
+
+	return ret < 0 ? ret : 0;
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
new file mode 100644
index 000000000000..edf703d319c8
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
@@ -0,0 +1,81 @@
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
+#ifndef NSP_NSP_ETH_H
+#define NSP_NSP_ETH_H 1
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+
+/**
+ * struct nfp_eth_table - ETH table information
+ * @count:	number of table entries
+ * @ports:	table of ports
+ *
+ * @eth_index:	port index according to legacy ethX numbering
+ * @index:	chip-wide first channel index
+ * @nbi:	NBI index
+ * @base:	first channel index (within NBI)
+ * @lanes:	number of channels
+ * @speed:	interface speed (in Mbps)
+ * @mac_addr:	interface MAC address
+ * @label:	interface id string
+ * @enabled:	is enabled?
+ * @tx_enabled:	is TX enabled?
+ * @rx_enabled:	is RX enabled?
+ */
+struct nfp_eth_table {
+	unsigned int count;
+	struct nfp_eth_table_port {
+		unsigned int eth_index;
+		unsigned int index;
+		unsigned int nbi;
+		unsigned int base;
+		unsigned int lanes;
+		unsigned int speed;
+
+		u8 mac_addr[ETH_ALEN];
+		char label[8];
+
+		bool enabled;
+		bool tx_enabled;
+		bool rx_enabled;
+	} ports[0];
+};
+
+struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp);
+struct nfp_eth_table *
+__nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp);
+int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable);
+
+#endif
-- 
2.11.0
