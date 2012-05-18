From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 08/10] RDMA/cxgb4: Use vmalloc for debugfs qp dump. Allows dumping thousands of qps.
Date: Fri, 18 May 2012 15:29:31 +0530
Message-ID: <1337335173-3226-9-git-send-email-vipul@chelsio.com>
References: <1337335173-3226-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7678 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161081Ab2ERK1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 06:27:30 -0400
In-Reply-To: <1337335173-3226-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Log active open failures of interest.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c     |   18 ++++++++++++++++++
 drivers/infiniband/hw/cxgb4/device.c |    4 ++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 6ce401a..55ab284 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1413,6 +1413,24 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 		return 0;
 	}
 
+	/*
+	 * Log interesting failures.
+	 */
+	switch (status) {
+	case CPL_ERR_CONN_RESET:
+	case CPL_ERR_CONN_TIMEDOUT:
+		break;
+	default:
+		printk(KERN_INFO MOD "Active open failure - "
+		       "atid %u status %u errno %d %pI4:%u->%pI4:%u\n",
+		       atid, status, status2errno(status),
+		       &ep->com.local_addr.sin_addr.s_addr,
+		       ntohs(ep->com.local_addr.sin_port),
+		       &ep->com.remote_addr.sin_addr.s_addr,
+		       ntohs(ep->com.remote_addr.sin_port));
+		break;
+	}
+
 	connect_reply_upcall(ep, status2errno(status));
 	state_set(&ep->com, DEAD);
 
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index bdb398f..8545629 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -121,7 +121,7 @@ static int qp_release(struct inode *inode, struct file *file)
 		printk(KERN_INFO "%s null qpd?\n", __func__);
 		return 0;
 	}
-	kfree(qpd->buf);
+	vfree(qpd->buf);
 	kfree(qpd);
 	return 0;
 }
@@ -145,7 +145,7 @@ static int qp_open(struct inode *inode, struct file *file)
 	spin_unlock_irq(&qpd->devp->lock);
 
 	qpd->bufsize = count * 128;
-	qpd->buf = kmalloc(qpd->bufsize, GFP_KERNEL);
+	qpd->buf = vmalloc(qpd->bufsize);
 	if (!qpd->buf) {
 		ret = -ENOMEM;
 		goto err1;
-- 
1.7.1
