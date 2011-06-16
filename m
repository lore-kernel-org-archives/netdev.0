From: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
Subject: [PATCH 04/11] net/rds: use prink_ratelimited() instead of
 printk_ratelimit()
Date: Thu, 16 Jun 2011 14:09:57 +0200
Message-ID: <639d68afea7b4b37a5b8b228f3b15f4f81a61ed8.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
References: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christian.dietrich@informatik.uni-erlangen.de
To: Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since printk_ratelimit() shouldn't be used anymore (see comment in
include/linux/printk.h), replace it with printk_ratelimited()

Signed-off-by: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
---
 net/rds/bind.c    |    4 ++--
 net/rds/ib_cm.c   |    6 +++---
 net/rds/ib_send.c |    4 ++--
 net/rds/iw_cm.c   |    9 ++++-----
 net/rds/iw_rdma.c |    9 +++++----
 net/rds/iw_send.c |    4 ++--
 net/rds/send.c    |    7 +++----
 7 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 2f6b3fc..637bde5 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -35,6 +35,7 @@
 #include <linux/in.h>
 #include <linux/if_arp.h>
 #include <linux/jhash.h>
+#include <linux/ratelimit.h>
 #include "rds.h"
 
 #define BIND_HASH_SIZE 1024
@@ -185,8 +186,7 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (!trans) {
 		ret = -EADDRNOTAVAIL;
 		rds_remove_bound(rs);
-		if (printk_ratelimit())
-			printk(KERN_INFO "RDS: rds_bind() could not find a transport, "
+		printk_ratelimited(KERN_INFO "RDS: rds_bind() could not find a transport, "
 				"load rds_tcp or rds_rdma?\n");
 		goto out;
 	}
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index fd453dd..cd67026 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 #include "ib.h"
@@ -435,13 +436,12 @@ static u32 rds_ib_protocol_compatible(struct rdma_cm_event *event)
 		version = RDS_PROTOCOL_3_0;
 		while ((common >>= 1) != 0)
 			version++;
-	} else if (printk_ratelimit()) {
-		printk(KERN_NOTICE "RDS: Connection from %pI4 using "
+	}
+	printk_ratelimited(KERN_NOTICE "RDS: Connection from %pI4 using "
 			"incompatible protocol version %u.%u\n",
 			&dp->dp_saddr,
 			dp->dp_protocol_major,
 			dp->dp_protocol_minor);
-	}
 	return version;
 }
 
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 7c4dce8..e590949 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/device.h>
 #include <linux/dmapool.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 #include "ib.h"
@@ -207,8 +208,7 @@ static struct rds_message *rds_ib_send_unmap_op(struct rds_ib_connection *ic,
 		}
 		break;
 	default:
-		if (printk_ratelimit())
-			printk(KERN_NOTICE
+		printk_ratelimited(KERN_NOTICE
 			       "RDS/IB: %s: unexpected opcode 0x%x in WR!\n",
 			       __func__, send->s_wr.opcode);
 		break;
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index c12db66..9556d28 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 #include "iw.h"
@@ -258,8 +259,7 @@ static int rds_iw_setup_qp(struct rds_connection *conn)
 	 */
 	rds_iwdev = ib_get_client_data(dev, &rds_iw_client);
 	if (!rds_iwdev) {
-		if (printk_ratelimit())
-			printk(KERN_NOTICE "RDS/IW: No client_data for device %s\n",
+		printk_ratelimited(KERN_NOTICE "RDS/IW: No client_data for device %s\n",
 					dev->name);
 		return -EOPNOTSUPP;
 	}
@@ -365,13 +365,12 @@ static u32 rds_iw_protocol_compatible(const struct rds_iw_connect_private *dp)
 		version = RDS_PROTOCOL_3_0;
 		while ((common >>= 1) != 0)
 			version++;
-	} else if (printk_ratelimit()) {
-		printk(KERN_NOTICE "RDS: Connection from %pI4 using "
+	}
+	printk_ratelimited(KERN_NOTICE "RDS: Connection from %pI4 using "
 			"incompatible protocol version %u.%u\n",
 			&dp->dp_saddr,
 			dp->dp_protocol_major,
 			dp->dp_protocol_minor);
-	}
 	return version;
 }
 
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 6deaa77..8b77edb 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -32,6 +32,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 #include "iw.h"
@@ -729,8 +730,8 @@ static int rds_iw_rdma_build_fastreg(struct rds_iw_mapping *mapping)
 	failed_wr = &f_wr;
 	ret = ib_post_send(ibmr->cm_id->qp, &f_wr, &failed_wr);
 	BUG_ON(failed_wr != &f_wr);
-	if (ret && printk_ratelimit())
-		printk(KERN_WARNING "RDS/IW: %s:%d ib_post_send returned %d\n",
+	if (ret)
+		printk_ratelimited(KERN_WARNING "RDS/IW: %s:%d ib_post_send returned %d\n",
 			__func__, __LINE__, ret);
 	return ret;
 }
@@ -751,8 +752,8 @@ static int rds_iw_rdma_fastreg_inv(struct rds_iw_mr *ibmr)
 
 	failed_wr = &s_wr;
 	ret = ib_post_send(ibmr->cm_id->qp, &s_wr, &failed_wr);
-	if (ret && printk_ratelimit()) {
-		printk(KERN_WARNING "RDS/IW: %s:%d ib_post_send returned %d\n",
+	if (ret) {
+		printk_ratelimited(KERN_WARNING "RDS/IW: %s:%d ib_post_send returned %d\n",
 			__func__, __LINE__, ret);
 		goto out;
 	}
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 545d8ee..e40c3c5 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/device.h>
 #include <linux/dmapool.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 #include "iw.h"
@@ -258,8 +259,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, void *context)
 				 * when the SEND completes. */
 				break;
 			default:
-				if (printk_ratelimit())
-					printk(KERN_NOTICE
+				printk_ratelimited(KERN_NOTICE
 						"RDS/IW: %s: unexpected opcode 0x%x in WR!\n",
 						__func__, send->s_wr.opcode);
 				break;
diff --git a/net/rds/send.c b/net/rds/send.c
index d58ae5f..aa57e22 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -35,6 +35,7 @@
 #include <net/sock.h>
 #include <linux/in.h>
 #include <linux/list.h>
+#include <linux/ratelimit.h>
 
 #include "rds.h"
 
@@ -1006,16 +1007,14 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		goto out;
 
 	if (rm->rdma.op_active && !conn->c_trans->xmit_rdma) {
-		if (printk_ratelimit())
-			printk(KERN_NOTICE "rdma_op %p conn xmit_rdma %p\n",
+		printk_ratelimited(KERN_NOTICE "rdma_op %p conn xmit_rdma %p\n",
 			       &rm->rdma, conn->c_trans->xmit_rdma);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
 
 	if (rm->atomic.op_active && !conn->c_trans->xmit_atomic) {
-		if (printk_ratelimit())
-			printk(KERN_NOTICE "atomic_op %p conn xmit_atomic %p\n",
+		printk_ratelimited(KERN_NOTICE "atomic_op %p conn xmit_atomic %p\n",
 			       &rm->atomic, conn->c_trans->xmit_atomic);
 		ret = -EOPNOTSUPP;
 		goto out;
-- 
1.7.4.1
