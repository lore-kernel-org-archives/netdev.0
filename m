From: divy@chelsio.com
Subject: [PATCH 2/7] cxgb3 - private ioctl cleanup
Date: Sat, 24 Feb 2007 16:43:56 -0800
Message-ID: <20070225004355.20813.60704.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28213 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932896AbXBYAn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 19:43:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Clean up some private ioctls.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_ioctl.h |   33 +++++++++------------------
 drivers/net/cxgb3/cxgb3_main.c  |   48 +++------------------------------------
 2 files changed, 15 insertions(+), 66 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
index a942818..0a82fcd 100644
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
-	CHELSIO_SETMTUTAB,
-	CHELSIO_GETMTU,
-	CHELSIO_SET_PM,
-	CHELSIO_GET_PM,
-	CHELSIO_GET_TCAM,
-	CHELSIO_SET_TCAM,
-	CHELSIO_GET_TCB,
-	CHELSIO_GET_MEM,
-	CHELSIO_LOAD_FW,
-	CHELSIO_GET_PROTO,
-	CHELSIO_SET_PROTO,
-	CHELSIO_SET_TRACE_FILTER,
-	CHELSIO_SET_QSET_PARAMS,
-	CHELSIO_GET_QSET_PARAMS,
-	CHELSIO_SET_QSET_NUM,
-	CHELSIO_GET_QSET_NUM,
-	CHELSIO_SET_PKTSCHED,
+	CHELSIO_GETMTUTAB 		= 1029,
+	CHELSIO_SETMTUTAB 		= 1030,
+	CHELSIO_SET_PM 			= 1032,
+	CHELSIO_GET_PM			= 1033,
+	CHELSIO_GET_MEM			= 1038,
+	CHELSIO_LOAD_FW			= 1041,
+	CHELSIO_SET_TRACE_FILTER	= 1044,
+	CHELSIO_SET_QSET_PARAMS		= 1045,
+	CHELSIO_GET_QSET_PARAMS		= 1046,
+	CHELSIO_SET_QSET_NUM		= 1047,
+	CHELSIO_GET_QSET_NUM		= 1048,
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
