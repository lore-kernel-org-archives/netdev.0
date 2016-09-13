From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 01/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_get_4tuple()
Date: Tue, 13 Sep 2016 21:23:56 +0530
Message-ID: <9cb101801606db45134c1468df5fa282cd9b912c.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:42841 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758622AbcIMP4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:56:49 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_get_4tuple() in libcxgb_cm.c to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/Kconfig               |  1 +
 drivers/infiniband/hw/cxgb4/Makefile              |  1 +
 drivers/infiniband/hw/cxgb4/cm.c                  | 41 +------------
 drivers/net/ethernet/chelsio/libcxgb/Makefile     |  4 +-
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 72 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 42 +++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 41 +------------
 7 files changed, 125 insertions(+), 77 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h

diff --git a/drivers/infiniband/hw/cxgb4/Kconfig b/drivers/infiniband/hw/cxgb4/Kconfig
index 23f38cf..afe8b28 100644
--- a/drivers/infiniband/hw/cxgb4/Kconfig
+++ b/drivers/infiniband/hw/cxgb4/Kconfig
@@ -1,6 +1,7 @@
 config INFINIBAND_CXGB4
 	tristate "Chelsio T4/T5 RDMA Driver"
 	depends on CHELSIO_T4 && INET && (IPV6 || IPV6=n)
+	select CHELSIO_LIB
 	select GENERIC_ALLOCATOR
 	---help---
 	  This is an iWARP/RDMA driver for the Chelsio T4 and T5
diff --git a/drivers/infiniband/hw/cxgb4/Makefile b/drivers/infiniband/hw/cxgb4/Makefile
index e11cf72..fa40b68 100644
--- a/drivers/infiniband/hw/cxgb4/Makefile
+++ b/drivers/infiniband/hw/cxgb4/Makefile
@@ -1,4 +1,5 @@
 ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
+ccflags-y += -Idrivers/net/ethernet/chelsio/libcxgb
 
 obj-$(CONFIG_INFINIBAND_CXGB4) += iw_cxgb4.o
 
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index b6a953a..e591f61 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -49,6 +49,7 @@
 
 #include <rdma/ib_addr.h>
 
+#include <libcxgb_cm.h>
 #include "iw_cxgb4.h"
 #include "clip_tbl.h"
 
@@ -2518,42 +2519,6 @@ static void reject_cr(struct c4iw_dev *dev, u32 hwtid, struct sk_buff *skb)
 	return;
 }
 
-static void get_4tuple(struct cpl_pass_accept_req *req, enum chip_type type,
-		       int *iptype, __u8 *local_ip, __u8 *peer_ip,
-		       __be16 *local_port, __be16 *peer_port)
-{
-	int eth_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
-		      ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
-		      T6_ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
-	int ip_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
-		     IP_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
-		     T6_IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
-	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
-	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
-	struct tcphdr *tcp = (struct tcphdr *)
-			     ((u8 *)(req + 1) + eth_len + ip_len);
-
-	if (ip->version == 4) {
-		PDBG("%s saddr 0x%x daddr 0x%x sport %u dport %u\n", __func__,
-		     ntohl(ip->saddr), ntohl(ip->daddr), ntohs(tcp->source),
-		     ntohs(tcp->dest));
-		*iptype = 4;
-		memcpy(peer_ip, &ip->saddr, 4);
-		memcpy(local_ip, &ip->daddr, 4);
-	} else {
-		PDBG("%s saddr %pI6 daddr %pI6 sport %u dport %u\n", __func__,
-		     ip6->saddr.s6_addr, ip6->daddr.s6_addr, ntohs(tcp->source),
-		     ntohs(tcp->dest));
-		*iptype = 6;
-		memcpy(peer_ip, ip6->saddr.s6_addr, 16);
-		memcpy(local_ip, ip6->daddr.s6_addr, 16);
-	}
-	*peer_port = tcp->source;
-	*local_port = tcp->dest;
-
-	return;
-}
-
 static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct c4iw_ep *child_ep = NULL, *parent_ep;
@@ -2582,8 +2547,8 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	get_4tuple(req, parent_ep->com.dev->rdev.lldi.adapter_type, &iptype,
-		   local_ip, peer_ip, &local_port, &peer_port);
+	cxgb_get_4tuple(req, parent_ep->com.dev->rdev.lldi.adapter_type,
+			&iptype, local_ip, peer_ip, &local_port, &peer_port);
 
 	/* Find output route */
 	if (iptype == 4)  {
diff --git a/drivers/net/ethernet/chelsio/libcxgb/Makefile b/drivers/net/ethernet/chelsio/libcxgb/Makefile
index 2362230..2534e30 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/Makefile
+++ b/drivers/net/ethernet/chelsio/libcxgb/Makefile
@@ -1,3 +1,5 @@
+ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
+
 obj-$(CONFIG_CHELSIO_LIB) += libcxgb.o
 
-libcxgb-y := libcxgb_ppm.o
+libcxgb-y := libcxgb_ppm.o libcxgb_cm.o
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
new file mode 100644
index 0000000..d7342bb
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
@@ -0,0 +1,72 @@
+/*
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
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
+ *	  copyright notice, this list of conditions and the following
+ *	  disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *	  copyright notice, this list of conditions and the following
+ *	  disclaimer in the documentation and/or other materials
+ *	  provided with the distribution.
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
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
+
+#include "libcxgb_cm.h"
+
+void
+cxgb_get_4tuple(struct cpl_pass_accept_req *req, enum chip_type type,
+		int *iptype, __u8 *local_ip, __u8 *peer_ip,
+		__be16 *local_port, __be16 *peer_port)
+{
+	int eth_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
+		      ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
+		      T6_ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
+	int ip_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
+		     IP_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
+		     T6_IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
+	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
+	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
+	struct tcphdr *tcp = (struct tcphdr *)
+			     ((u8 *)(req + 1) + eth_len + ip_len);
+
+	if (ip->version == 4) {
+		pr_debug("%s saddr 0x%x daddr 0x%x sport %u dport %u\n",
+			 __func__, ntohl(ip->saddr), ntohl(ip->daddr),
+			 ntohs(tcp->source), ntohs(tcp->dest));
+		*iptype = 4;
+		memcpy(peer_ip, &ip->saddr, 4);
+		memcpy(local_ip, &ip->daddr, 4);
+	} else {
+		pr_debug("%s saddr %pI6 daddr %pI6 sport %u dport %u\n",
+			 __func__, ip6->saddr.s6_addr, ip6->daddr.s6_addr,
+			 ntohs(tcp->source), ntohs(tcp->dest));
+		*iptype = 6;
+		memcpy(peer_ip, ip6->saddr.s6_addr, 16);
+		memcpy(local_ip, ip6->daddr.s6_addr, 16);
+	}
+	*peer_port = tcp->source;
+	*local_port = tcp->dest;
+}
+EXPORT_SYMBOL(cxgb_get_4tuple);
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
new file mode 100644
index 0000000..2ab8d9b
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
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
+ *	  copyright notice, this list of conditions and the following
+ *	  disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *	  copyright notice, this list of conditions and the following
+ *	  disclaimer in the documentation and/or other materials
+ *	  provided with the distribution.
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
+#ifndef __LIBCXGB_CM_H__
+#define __LIBCXGB_CM_H__
+
+#include <cxgb4.h>
+#include <t4_msg.h>
+
+void
+cxgb_get_4tuple(struct cpl_pass_accept_req *, enum chip_type,
+		int *, __u8 *, __u8 *, __be16 *, __be16 *);
+#endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 0ae0b13..8bb5a25 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -24,6 +24,7 @@
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 
+#include <libcxgb_cm.h>
 #include "cxgbit.h"
 #include "clip_tbl.h"
 
@@ -789,42 +790,6 @@ void _cxgbit_free_csk(struct kref *kref)
 	kfree(csk);
 }
 
-static void
-cxgbit_get_tuple_info(struct cpl_pass_accept_req *req, int *iptype,
-		      __u8 *local_ip, __u8 *peer_ip, __be16 *local_port,
-		      __be16 *peer_port)
-{
-	u32 eth_len = ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
-	u32 ip_len = IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
-	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
-	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
-	struct tcphdr *tcp = (struct tcphdr *)
-			      ((u8 *)(req + 1) + eth_len + ip_len);
-
-	if (ip->version == 4) {
-		pr_debug("%s saddr 0x%x daddr 0x%x sport %u dport %u\n",
-			 __func__,
-			 ntohl(ip->saddr), ntohl(ip->daddr),
-			 ntohs(tcp->source),
-			 ntohs(tcp->dest));
-		*iptype = 4;
-		memcpy(peer_ip, &ip->saddr, 4);
-		memcpy(local_ip, &ip->daddr, 4);
-	} else {
-		pr_debug("%s saddr %pI6 daddr %pI6 sport %u dport %u\n",
-			 __func__,
-			 ip6->saddr.s6_addr, ip6->daddr.s6_addr,
-			 ntohs(tcp->source),
-			 ntohs(tcp->dest));
-		*iptype = 6;
-		memcpy(peer_ip, ip6->saddr.s6_addr, 16);
-		memcpy(local_ip, ip6->daddr.s6_addr, 16);
-	}
-
-	*peer_port = tcp->source;
-	*local_port = tcp->dest;
-}
-
 static int
 cxgbit_our_interface(struct cxgbit_device *cdev, struct net_device *egress_dev)
 {
@@ -1340,8 +1305,8 @@ cxgbit_pass_accept_req(struct cxgbit_device *cdev, struct sk_buff *skb)
 		goto rel_skb;
 	}
 
-	cxgbit_get_tuple_info(req, &iptype, local_ip, peer_ip,
-			      &local_port, &peer_port);
+	cxgb_get_4tuple(req, cdev->lldi.adapter_type, &iptype, local_ip,
+			peer_ip, &local_port, &peer_port);
 
 	/* Find output route */
 	if (iptype == 4)  {
-- 
2.0.2
