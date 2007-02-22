From: divy@chelsio.com
Subject: [PATCH 2/7] cxgb3 - private ioctl cleanup
Date: Thu, 22 Feb 2007 03:59:25 -0800
Message-ID: <20070222115925.10001.61276.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945975AbXBVL7d@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Clean up some private ioctls.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_ioctl.h |   21 ++++-------------
 drivers/net/cxgb3/cxgb3_main.c  |   48 +++------------------------------------
 2 files changed, 9 insertions(+), 60 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
index a942818..42d4bf6 100644
--- a/drivers/net/cxgb3/cxgb3_ioctl.h
+++ b/drivers/net/cxgb3/cxgb3_ioctl.h
@@ -36,28 +36,17 @@
  * Ioctl commands specific to this driver.
  */
 enum {
-	CHELSIO_SETREG = 1024,
-	CHELSIO_GETREG,
-	CHELSIO_SETTPI,
-	CHELSIO_GETTPI,
-	CHELSIO_GETMTUTAB,
+	CHELSIO_GETMTUTAB = 1024,
 	CHELSIO_SETMTUTAB,
-	CHELSIO_GETMTU,
-	CHELSIO_SET_PM,
-	CHELSIO_GET_PM,
-	CHELSIO_GET_TCAM,
-	CHELSIO_SET_TCAM,
-	CHELSIO_GET_TCB,
 	CHELSIO_GET_MEM,
 	CHELSIO_LOAD_FW,
-	CHELSIO_GET_PROTO,
-	CHELSIO_SET_PROTO,
 	CHELSIO_SET_TRACE_FILTER,
-	CHELSIO_SET_QSET_PARAMS,
 	CHELSIO_GET_QSET_PARAMS,
-	CHELSIO_SET_QSET_NUM,
+	CHELSIO_SET_QSET_PARAMS,
 	CHELSIO_GET_QSET_NUM,
-	CHELSIO_SET_PKTSCHED,
+	CHELSIO_SET_QSET_NUM,
+	CHELSIO_GET_PM,
+	CHELSIO_SET_PM,
 };
 
 struct ch_reg {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 59f2b51..7ff834e 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1552,32 +1552,6 @@ static int cxgb_extension_ioctl(struct n
 		return -EFAULT;
 
 	switch (cmd) {
-	case CHELSIO_SETREG:{
-		struct ch_reg edata;
-
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
-		if ((edata.addr & 3) != 0
-			|| edata.addr >= adapter->mmio_len)
-			return -EINVAL;
-		writel(edata.val, adapter->regs + edata.addr);
-		break;
-	}
-	case CHELSIO_GETREG:{
-		struct ch_reg edata;
-
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
-		if ((edata.addr & 3) != 0
-			|| edata.addr >= adapter->mmio_len)
-			return -EINVAL;
-		edata.val = readl(adapter->regs + edata.addr);
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		break;
-	}
 	case CHELSIO_SET_QSET_PARAMS:{
 		int i;
 		struct qset_params *q;
@@ -1841,10 +1815,10 @@ static int cxgb_extension_ioctl(struct n
 			return -EINVAL;
 
 		/*
-			* Version scheme:
-			* bits 0..9: chip version
-			* bits 10..15: chip revision
-			*/
+		 * Version scheme:
+		 * bits 0..9: chip version
+		 * bits 10..15: chip revision
+		 */
 		t.version = 3 | (adapter->params.rev << 10);
 		if (copy_to_user(useraddr, &t, sizeof(t)))
 			return -EFAULT;
@@ -1893,20 +1867,6 @@ static int cxgb_extension_ioctl(struct n
 						t.trace_rx);
 		break;
 	}
-	case CHELSIO_SET_PKTSCHED:{
-		struct ch_pktsched_params p;
-
-		if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-		if (!adapter->open_device_map)
-				return -EAGAIN;	/* uP and SGE must be running */
-		if (copy_from_user(&p, useraddr, sizeof(p)))
-				return -EFAULT;
-		send_pktsched_cmd(adapter, p.sched, p.idx, p.min, p.max,
-				  p.binding);
-		break;
-			
-	}
 	default:
 		return -EOPNOTSUPP;
 	}
