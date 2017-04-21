From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 3/5] nfp: add NSP routine to get static information
Date: Fri, 21 Apr 2017 12:23:08 -0700
Message-ID: <20170421192310.193875-4-jakub.kicinski@netronome.com>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        David Brunecz <david.brunecz@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:33896 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424896AbdDUTXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:24 -0400
Received: by mail-yb0-f173.google.com with SMTP id 11so45562131ybw.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:24 -0700 (PDT)
In-Reply-To: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brunecz <david.brunecz@netronome.com>

Retrieve identifying information from the NSP.  For now it only
contains versions of firmware subcomponents.

Signed-off-by: David Brunecz <david.brunecz@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  7 ++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  1 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  7 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   | 24 ++++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c  | 89 ++++++++++++++++++++++
 6 files changed, 129 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 4a5d13ef92a4..4b15f0f496aa 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -9,6 +9,7 @@ nfp-objs := \
 	    nfpcore/nfp_mutex.o \
 	    nfpcore/nfp_nffw.o \
 	    nfpcore/nfp_nsp.o \
+	    nfpcore/nfp_nsp_cmds.o \
 	    nfpcore/nfp_nsp_eth.o \
 	    nfpcore/nfp_resource.o \
 	    nfpcore/nfp_rtsym.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index bea2a1a6c211..dde35dae35c5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -253,6 +253,7 @@ nfp_fw_load(struct pci_dev *pdev, struct nfp_pf *pf, struct nfp_nsp *nsp)
 
 static int nfp_nsp_init(struct pci_dev *pdev, struct nfp_pf *pf)
 {
+	struct nfp_nsp_identify *nspi;
 	struct nfp_nsp *nsp;
 	int err;
 
@@ -269,6 +270,12 @@ static int nfp_nsp_init(struct pci_dev *pdev, struct nfp_pf *pf)
 
 	pf->eth_tbl = __nfp_eth_read_ports(pf->cpp, nsp);
 
+	nspi = __nfp_nsp_identify(nsp);
+	if (nspi) {
+		dev_info(&pdev->dev, "BSP: %s\n", nspi->version);
+		kfree(nspi);
+	}
+
 	err = nfp_fw_load(pdev, pf, nsp);
 	if (err < 0) {
 		kfree(pf->eth_tbl);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 8afef7593f13..4df2ce261b3f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -63,6 +63,7 @@ void nfp_nsp_config_clear_state(struct nfp_nsp *state);
 int nfp_nsp_read_eth_table(struct nfp_nsp *state, void *buf, unsigned int size);
 int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 			    const void *buf, unsigned int size);
+int nfp_nsp_read_identify(struct nfp_nsp *state, void *buf, unsigned int size);
 
 /* Implemented in nfp_resource.c */
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 4635f42e15b0..61797c98f5fe 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -93,6 +93,7 @@ enum nfp_nsp_cmd {
 	SPCODE_FW_LOAD		= 6, /* Load fw from buffer, len in option */
 	SPCODE_ETH_RESCAN	= 7, /* Rescan ETHs, write ETH_TABLE to buf */
 	SPCODE_ETH_CONTROL	= 8, /* Update media config from buffer */
+	SPCODE_NSP_IDENTIFY	= 13, /* Read NSP version */
 
 	__MAX_SPCODE,
 };
@@ -493,3 +494,9 @@ int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 	return nfp_nsp_command_buf(state, SPCODE_ETH_CONTROL, size, buf, size,
 				   NULL, 0);
 }
+
+int nfp_nsp_read_identify(struct nfp_nsp *state, void *buf, unsigned int size)
+{
+	return nfp_nsp_command_buf(state, SPCODE_NSP_IDENTIFY, size, NULL, 0,
+				   buf, size);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
index 7d34ff145fd7..36b21e4dc56d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
@@ -147,4 +147,28 @@ int __nfp_eth_set_aneg(struct nfp_nsp *nsp, enum nfp_eth_aneg mode);
 int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed);
 int __nfp_eth_set_split(struct nfp_nsp *nsp, unsigned int lanes);
 
+/**
+ * struct nfp_nsp_identify - NSP static information
+ * @version:      opaque version string
+ * @flags:        version flags
+ * @br_primary:   branch id of primary bootloader
+ * @br_secondary: branch id of secondary bootloader
+ * @br_nsp:       branch id of NSP
+ * @primary:      version of primarary bootloader
+ * @secondary:    version id of secondary bootloader
+ * @nsp:          version id of NSP
+ */
+struct nfp_nsp_identify {
+	char version[40];
+	u8 flags;
+	u8 br_primary;
+	u8 br_secondary;
+	u8 br_nsp;
+	u16 primary;
+	u16 secondary;
+	u16 nsp;
+};
+
+struct nfp_nsp_identify *__nfp_nsp_identify(struct nfp_nsp *nsp);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c
new file mode 100644
index 000000000000..e7a263de3731
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c
@@ -0,0 +1,89 @@
+/*
+ * Copyright (C) 2017 Netronome Systems, Inc.
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
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+#include "nfp.h"
+#include "nfp_nsp.h"
+
+struct nsp_identify {
+	u8 version[40];
+	u8 flags;
+	u8 br_primary;
+	u8 br_secondary;
+	u8 br_nsp;
+	__le16 primary;
+	__le16 secondary;
+	__le16 nsp;
+	__le16 reserved;
+};
+
+struct nfp_nsp_identify *__nfp_nsp_identify(struct nfp_nsp *nsp)
+{
+	struct nfp_nsp_identify *nspi = NULL;
+	struct nsp_identify *ni;
+	int ret;
+
+	if (nfp_nsp_get_abi_ver_minor(nsp) < 15)
+		return NULL;
+
+	ni = kzalloc(sizeof(*ni), GFP_KERNEL);
+	if (!ni)
+		return NULL;
+
+	ret = nfp_nsp_read_identify(nsp, ni, sizeof(*ni));
+	if (ret < 0) {
+		nfp_err(nfp_nsp_cpp(nsp), "reading bsp version failed %d\n",
+			ret);
+		goto exit_free;
+	}
+
+	nspi = kzalloc(sizeof(*nspi), GFP_KERNEL);
+	if (!nspi)
+		goto exit_free;
+
+	memcpy(nspi->version, ni->version, sizeof(nspi->version));
+	nspi->version[sizeof(nspi->version) - 1] = '\0';
+	nspi->flags = ni->flags;
+	nspi->br_primary = ni->br_primary;
+	nspi->br_secondary = ni->br_secondary;
+	nspi->br_nsp = ni->br_nsp;
+	nspi->primary = le16_to_cpu(ni->primary);
+	nspi->secondary = le16_to_cpu(ni->secondary);
+	nspi->nsp = le16_to_cpu(ni->nsp);
+
+exit_free:
+	kfree(ni);
+	return nspi;
+}
-- 
2.11.0
