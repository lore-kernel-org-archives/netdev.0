From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [net-next][PATCH 01/13] RDS: Drop stale iWARP RDMA transport
Date: Sat, 20 Feb 2016 03:29:52 -0800
Message-ID: <1455967804-27644-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455967804-27644-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RDS iWarp support code has become stale and non testable. As
indicated earlier, am dropping the support for it.

If new iWarp user(s) shows up in future, we can adapat the RDS IB
transprt for the special RDMA READ sink case. iWarp needs an MR
for the RDMA READ sink.

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 Documentation/networking/rds.txt |   4 +-
 net/rds/Kconfig                  |   7 +-
 net/rds/Makefile                 |   4 +-
 net/rds/iw.c                     | 312 -------------
 net/rds/iw.h                     | 398 ----------------
 net/rds/iw_cm.c                  | 769 ------------------------------
 net/rds/iw_rdma.c                | 837 ---------------------------------
 net/rds/iw_recv.c                | 904 ------------------------------------
 net/rds/iw_ring.c                | 169 -------
 net/rds/iw_send.c                | 981 ---------------------------------------
 net/rds/iw_stats.c               |  95 ----
 net/rds/iw_sysctl.c              | 123 -----
 net/rds/rdma_transport.c         |  13 +-
 net/rds/rdma_transport.h         |   5 -
 14 files changed, 7 insertions(+), 4614 deletions(-)
 delete mode 100644 net/rds/iw.c
 delete mode 100644 net/rds/iw.h
 delete mode 100644 net/rds/iw_cm.c
 delete mode 100644 net/rds/iw_rdma.c
 delete mode 100644 net/rds/iw_recv.c
 delete mode 100644 net/rds/iw_ring.c
 delete mode 100644 net/rds/iw_send.c
 delete mode 100644 net/rds/iw_stats.c
 delete mode 100644 net/rds/iw_sysctl.c

diff --git a/Documentation/networking/rds.txt b/Documentation/networking/rds.txt
index e1a3d59..9d219d8 100644
--- a/Documentation/networking/rds.txt
+++ b/Documentation/networking/rds.txt
@@ -19,9 +19,7 @@ to N*N if you use a connection-oriented socket transport like TCP.
 
 RDS is not Infiniband-specific; it was designed to support different
 transports.  The current implementation used to support RDS over TCP as well
-as IB. Work is in progress to support RDS over iWARP, and using DCE to
-guarantee no dropped packets on Ethernet, it may be possible to use RDS over
-UDP in the future.
+as IB.
 
 The high-level semantics of RDS from the application's point of view are
 
diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index f2c670b..bffde4b 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -4,14 +4,13 @@ config RDS
 	depends on INET
 	---help---
 	  The RDS (Reliable Datagram Sockets) protocol provides reliable,
-	  sequenced delivery of datagrams over Infiniband, iWARP,
-	  or TCP.
+	  sequenced delivery of datagrams over Infiniband or TCP.
 
 config RDS_RDMA
-	tristate "RDS over Infiniband and iWARP"
+	tristate "RDS over Infiniband"
 	depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
 	---help---
-	  Allow RDS to use Infiniband and iWARP as a transport.
+	  Allow RDS to use Infiniband as a transport.
 	  This transport supports RDMA operations.
 
 config RDS_TCP
diff --git a/net/rds/Makefile b/net/rds/Makefile
index 56d3f60..19e5485 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -6,9 +6,7 @@ rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
 obj-$(CONFIG_RDS_RDMA) += rds_rdma.o
 rds_rdma-y :=	rdma_transport.o \
 			ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
-			ib_sysctl.o ib_rdma.o \
-			iw.o iw_cm.o iw_recv.o iw_ring.o iw_send.o iw_stats.o \
-			iw_sysctl.o iw_rdma.o
+			ib_sysctl.o ib_rdma.o
 
 
 obj-$(CONFIG_RDS_TCP) += rds_tcp.o
diff --git a/net/rds/iw.c b/net/rds/iw.c
deleted file mode 100644
index f4a9fff..0000000
diff --git a/net/rds/iw.h b/net/rds/iw.h
deleted file mode 100644
index 5af01d1..0000000
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
deleted file mode 100644
index aea4c91..0000000
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
deleted file mode 100644
index b09a40c..0000000
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
deleted file mode 100644
index a66d179..0000000
diff --git a/net/rds/iw_ring.c b/net/rds/iw_ring.c
deleted file mode 100644
index da8e3b6..0000000
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
deleted file mode 100644
index e20bd50..0000000
diff --git a/net/rds/iw_stats.c b/net/rds/iw_stats.c
deleted file mode 100644
index 5fe67f6..0000000
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
deleted file mode 100644
index 139239d..0000000
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 9c1fed8..4f4b3d8 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -49,9 +49,7 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 	rdsdebug("conn %p id %p handling event %u (%s)\n", conn, cm_id,
 		 event->event, rdma_event_msg(event->event));
 
-	if (cm_id->device->node_type == RDMA_NODE_RNIC)
-		trans = &rds_iw_transport;
-	else
+	if (cm_id->device->node_type == RDMA_NODE_IB_CA)
 		trans = &rds_ib_transport;
 
 	/* Prevent shutdown from tearing down the connection
@@ -200,10 +198,6 @@ static int rds_rdma_init(void)
 	if (ret)
 		goto out;
 
-	ret = rds_iw_init();
-	if (ret)
-		goto err_iw_init;
-
 	ret = rds_ib_init();
 	if (ret)
 		goto err_ib_init;
@@ -211,8 +205,6 @@ static int rds_rdma_init(void)
 	goto out;
 
 err_ib_init:
-	rds_iw_exit();
-err_iw_init:
 	rds_rdma_listen_stop();
 out:
 	return ret;
@@ -224,11 +216,10 @@ static void rds_rdma_exit(void)
 	/* stop listening first to ensure no new connections are attempted */
 	rds_rdma_listen_stop();
 	rds_ib_exit();
-	rds_iw_exit();
 }
 module_exit(rds_rdma_exit);
 
 MODULE_AUTHOR("Oracle Corporation <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>");
-MODULE_DESCRIPTION("RDS: IB/iWARP transport");
+MODULE_DESCRIPTION("RDS: IB transport");
 MODULE_LICENSE("Dual BSD/GPL");
 
diff --git a/net/rds/rdma_transport.h b/net/rds/rdma_transport.h
index faba4e3..ff2010e 100644
--- a/net/rds/rdma_transport.h
+++ b/net/rds/rdma_transport.h
@@ -16,9 +16,4 @@ extern struct rds_transport rds_ib_transport;
 int rds_ib_init(void);
 void rds_ib_exit(void);
 
-/* from iw.c */
-extern struct rds_transport rds_iw_transport;
-int rds_iw_init(void);
-void rds_iw_exit(void);
-
 #endif
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
