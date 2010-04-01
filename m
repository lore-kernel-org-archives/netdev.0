From: "Sean Hefty" <sean.hefty@intel.com>
Subject: [PATCH 1/26] rdma/cm: define native IB address
Date: Thu, 1 Apr 2010 10:08:41 -0700
Message-ID: <F4B90A5C68C04784A828ACBDDF917EF5@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <linux-rdma@vger.kernel.org>,
	"'Linux Netdev List'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29531 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372Ab0DARJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 13:09:03 -0400
References: 
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define AF_IB and sockaddr_ib to allow the rdma_cm to use native IB
addressing.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---

 include/linux/socket.h |    2 +
 include/rdma/ib.h      |   89 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 7b3aae2..966e268 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -181,6 +181,7 @@ struct ucred {
 #define AF_PPPOX	24	/* PPPoX sockets		*/
 #define AF_WANPIPE	25	/* Wanpipe API Sockets */
 #define AF_LLC		26	/* Linux LLC			*/
+#define AF_IB		27	/* Native InfiniBand address	*/
 #define AF_CAN		29	/* Controller Area Network      */
 #define AF_TIPC		30	/* TIPC sockets			*/
 #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
@@ -221,6 +222,7 @@ struct ucred {
 #define PF_PPPOX	AF_PPPOX
 #define PF_WANPIPE	AF_WANPIPE
 #define PF_LLC		AF_LLC
+#define PF_IB		AF_IB
 #define PF_CAN		AF_CAN
 #define PF_TIPC		AF_TIPC
 #define PF_BLUETOOTH	AF_BLUETOOTH
diff --git a/include/rdma/ib.h b/include/rdma/ib.h
new file mode 100644
index 0000000..cf8f9e7
--- /dev/null
+++ b/include/rdma/ib.h
@@ -0,0 +1,89 @@
+/*
+ * Copyright (c) 2010 Intel Corporation.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
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
+#if !defined(_RDMA_IB_H)
+#define _RDMA_IB_H
+
+#include <linux/types.h>
+
+struct ib_addr {
+	union {
+		__u8		uib_addr8[16];
+		__be16		uib_addr16[8];
+		__be32		uib_addr32[4];
+		__be64		uib_addr64[2];
+	} ib_u;
+#define sib_addr8		ib_u.uib_addr8
+#define sib_addr16		ib_u.uib_addr16
+#define sib_addr32		ib_u.uib_addr32
+#define sib_addr64		ib_u.uib_addr64
+#define sib_raw			ib_u.uib_addr8
+#define sib_subnet_prefix	ib_u.uib_addr64[0]
+#define sib_interface_id	ib_u.uib_addr64[1]
+};
+
+static inline int ib_addr_any(const struct ib_addr *a)
+{
+	return ((a->sib_addr64[0] | a->sib_addr64[1]) == 0);
+}
+
+static inline int ib_addr_loopback(const struct ib_addr *a)
+{
+	return ((a->sib_addr32[0] | a->sib_addr32[1] |
+		 a->sib_addr32[2] | (a->sib_addr32[3] ^ htonl(1))) == 0);
+}
+
+static inline void ib_addr_set(struct ib_addr *addr,
+			       __be32 w1, __be32 w2, __be32 w3, __be32 w4)
+{
+	addr->sib_addr32[0] = w1;
+	addr->sib_addr32[1] = w2;
+	addr->sib_addr32[2] = w3;
+	addr->sib_addr32[3] = w4;
+}
+
+static inline int ib_addr_cmp(const struct ib_addr *a1, const struct ib_addr *a2)
+{
+	return memcmp(a1, a2, sizeof(struct ib_addr));
+}
+
+struct sockaddr_ib {
+	unsigned short int	sib_family;	/* AF_IB */
+	__be16			sib_pkey;
+	__be32			sib_flowinfo;
+	struct ib_addr		sib_addr;
+	__be64			sib_sid;
+	__be64			sib_sid_mask;
+	__u64			sib_scope_id;
+};
+
+#endif /* _RDMA_IB_H */



