From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 02/11] fjes: Add setting/getting register value feature via ioctl
Date: Mon, 11 Apr 2016 17:10:04 +0900
Message-ID: <1460362204-15078-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:59838 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcDKIS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:27 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 53E50AC00D3
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:21 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces setting/getting register value feature
via ioctl. This feature is useful for debugging.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_ioctl.h |  7 +++++++
 drivers/net/fjes/fjes_main.c  | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/drivers/net/fjes/fjes_ioctl.h b/drivers/net/fjes/fjes_ioctl.h
index 35adfda..61619f7 100644
--- a/drivers/net/fjes/fjes_ioctl.h
+++ b/drivers/net/fjes/fjes_ioctl.h
@@ -25,6 +25,8 @@
 #define FJES_IOCTL_TRACE_START		(SIOCDEVPRIVATE + 1)
 #define FJES_IOCTL_TRACE_STOP		(SIOCDEVPRIVATE + 2)
 #define FJES_IOCTL_TRACE_GETCFG		(SIOCDEVPRIVATE + 3)
+#define FJES_IOCTL_DEV_GETREG		(SIOCDEVPRIVATE + 4)
+#define FJES_IOCTL_DEV_SETREG		(SIOCDEVPRIVATE + 5)
 
 struct fjes_ioctl_trace_start_req_val {
 	u32	mode;
@@ -70,6 +72,11 @@ struct fjes_ioctl_trace_param {
 	union fjes_ioctl_trace_res_val	res;
 };
 
+struct fjes_ioctl_dev_reg_param {
+	u32	offset;
+	u32	val;
+};
+
 #define FJES_IOCTL_TRACE_START_ERR_NORMAL		(0x0000)
 #define FJES_IOCTL_TRACE_START_ERR_BUSY			(0x0001)
 #define FJES_IOCTL_TRACE_START_ERR_PARAM		(0x0100)
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index bc6e31d..40cf65d 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -977,6 +977,40 @@ static int fjes_ioctl_trace_getcfg(struct net_device *netdev, struct ifreq *rq)
 	return 0;
 }
 
+static int fjes_ioctl_reg_read(struct net_device *netdev, struct ifreq *rq)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_ioctl_dev_reg_param reg;
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (copy_from_user(&reg, rq->ifr_data, sizeof(reg)))
+		return -EFAULT;
+
+	reg.val = rd32(reg.offset);
+
+	if (copy_to_user(rq->ifr_data, &reg, sizeof(reg)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int fjes_ioctl_reg_write(struct net_device *netdev, struct ifreq *rq)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_ioctl_dev_reg_param reg;
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (copy_from_user(&reg, rq->ifr_data, sizeof(reg)))
+		return -EFAULT;
+
+	wr32(reg.offset, reg.val);
+
+	if (copy_to_user(rq->ifr_data, &reg, sizeof(reg)))
+		return -EFAULT;
+
+	return 0;
+}
+
 static int fjes_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 {
 	switch (cmd) {
@@ -986,7 +1020,12 @@ static int fjes_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 		return fjes_ioctl_trace_stop(netdev, rq);
 	case FJES_IOCTL_TRACE_GETCFG:
 		return fjes_ioctl_trace_getcfg(netdev, rq);
+	case FJES_IOCTL_DEV_GETREG:
+		return fjes_ioctl_reg_read(netdev, rq);
+	case FJES_IOCTL_DEV_SETREG:
+		return fjes_ioctl_reg_write(netdev, rq);
 	default:
+
 		return -EOPNOTSUPP;
 	}
 }
-- 
2.4.3
