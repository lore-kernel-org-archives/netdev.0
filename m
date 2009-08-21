From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 3/5] RDS: Modularize RDMA and TCP transports
Date: Fri, 21 Aug 2009 15:28:33 -0700
Message-ID: <1250893715-21939-4-git-send-email-andy.grover@oracle.com>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:32902 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396AbZHUW2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:49 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMTWJL028743
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:29:33 GMT
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the building of transports as modules.

Also, improve consistency of Kconfig messages in relation to other
protocols, and move build dependency on IB from the RDS core code
to the rds_rdma module.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/Kconfig          |   26 ++++++++++++++++++++------
 net/rds/Makefile         |   11 +++++++++--
 net/rds/af_rds.c         |    8 --------
 net/rds/rdma_transport.c |    6 ++++++
 4 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index 796773b..ec753b3 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -1,14 +1,28 @@
 
 config RDS
-	tristate "Reliable Datagram Sockets (RDS) (EXPERIMENTAL)"
-	depends on INET && INFINIBAND_IPOIB && EXPERIMENTAL
-	depends on INFINIBAND && INFINIBAND_ADDR_TRANS
+	tristate "The RDS Protocol (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
 	---help---
-	  RDS provides reliable, sequenced delivery of datagrams
-	  over Infiniband.
+	  The RDS (Reliable Datagram Sockets) protocol provides reliable,
+	  sequenced delivery of datagrams over Infiniband, iWARP,
+	  or TCP.
+
+config RDS_RDMA
+	tristate "RDS over Infiniband and iWARP"
+	depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
+	---help---
+	  Allow RDS to use Infiniband and iWARP as a transport.
+	  This transport supports RDMA operations.
+
+config RDS_TCP
+	tristate "RDS over TCP"
+	depends on RDS
+	---help---
+	  Allow RDS to use TCP as a transport.
+	  This transport does not support RDMA operations.
 
 config RDS_DEBUG
-        bool "Debugging messages"
+        bool "RDS debugging messages"
 	depends on RDS
         default n
 
diff --git a/net/rds/Makefile b/net/rds/Makefile
index 51f2758..b46eca1 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -1,13 +1,20 @@
 obj-$(CONFIG_RDS) += rds.o
 rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
 			recv.o send.o stats.o sysctl.o threads.o transport.o \
-			loop.o page.o rdma.o \
-			rdma_transport.o \
+			loop.o page.o rdma.o
+
+obj-$(CONFIG_RDS_RDMA) += rds_rdma.o
+rds_rdma-objs :=	rdma_transport.o \
 			ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
 			ib_sysctl.o ib_rdma.o \
 			iw.o iw_cm.o iw_recv.o iw_ring.o iw_send.o iw_stats.o \
 			iw_sysctl.o iw_rdma.o
 
+
+obj-$(CONFIG_RDS_TCP) += rds_tcp.o
+rds_tcp-objs :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
+			tcp_send.o tcp_stats.o
+
 ifeq ($(CONFIG_RDS_DEBUG), y)
 EXTRA_CFLAGS += -DDEBUG
 endif
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index b11e7e5..108ed2e 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -39,7 +39,6 @@
 
 #include "rds.h"
 #include "rdma.h"
-#include "rdma_transport.h"
 
 /* this is just used for stats gathering :/ */
 static DEFINE_SPINLOCK(rds_sock_lock);
@@ -509,7 +508,6 @@ out:
 
 static void __exit rds_exit(void)
 {
-	rds_rdma_exit();
 	sock_unregister(rds_family_ops.family);
 	proto_unregister(&rds_proto);
 	rds_conn_exit();
@@ -549,14 +547,8 @@ static int __init rds_init(void)
 	rds_info_register_func(RDS_INFO_SOCKETS, rds_sock_info);
 	rds_info_register_func(RDS_INFO_RECV_MESSAGES, rds_sock_inc_info);
 
-	/* ib/iwarp transports currently compiled-in */
-	ret = rds_rdma_init();
-	if (ret)
-		goto out_sock;
 	goto out;
 
-out_sock:
-	sock_unregister(rds_family_ops.family);
 out_proto:
 	proto_unregister(&rds_proto);
 out_stats:
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 7a6c748..9ece910 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -203,6 +203,7 @@ err_iw_init:
 out:
 	return ret;
 }
+module_init(rds_rdma_init);
 
 void rds_rdma_exit(void)
 {
@@ -211,4 +212,9 @@ void rds_rdma_exit(void)
 	rds_ib_exit();
 	rds_iw_exit();
 }
+module_exit(rds_rdma_exit);
+
+MODULE_AUTHOR("Oracle Corporation <rds-devel@oss.oracle.com>");
+MODULE_DESCRIPTION("RDS: IB/iWARP transport");
+MODULE_LICENSE("Dual BSD/GPL");
 
-- 
1.6.0.4

