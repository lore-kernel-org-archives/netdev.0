From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/6 net-next] cnic: Update TCP options setup for iSCSI.
Date: Sun, 28 Jul 2013 19:03:58 -0700
Message-ID: <1375063440-4016-4-git-send-email-mchan@broadcom.com>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
 <1375063440-4016-2-git-send-email-mchan@broadcom.com>
 <1375063440-4016-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4314 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab3G2BmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:13 -0400
In-Reply-To: <1375063440-4016-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

Update TCP delayed ACK and timestamp options setup to match latest bnx2x
firmware.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c      |   53 +++++++++++++++--------------
 drivers/net/ethernet/broadcom/cnic_defs.h |    4 +-
 drivers/scsi/bnx2i/57xx_iscsi_hsi.h       |   12 ++++--
 3 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 1a2e5ff..24f2a09 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1427,6 +1427,28 @@ static void cnic_reply_bnx2x_kcqes(struct cnic_dev *dev, int ulp_type,
 	rcu_read_unlock();
 }
 
+static void cnic_bnx2x_set_tcp_options(struct cnic_dev *dev, int time_stamps,
+				       int en_tcp_dack)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
+	u8 xstorm_flags = XSTORM_L5CM_TCP_FLAGS_WND_SCL_EN;
+	u16 tstorm_flags = 0;
+
+	if (time_stamps) {
+		xstorm_flags |= XSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
+		tstorm_flags |= TSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
+	}
+	if (en_tcp_dack)
+		tstorm_flags |= TSTORM_L5CM_TCP_FLAGS_DELAYED_ACK_EN;
+
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), xstorm_flags);
+
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
+		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), tstorm_flags);
+}
+
 static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -1506,6 +1528,10 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_HQ_SIZE_OFFSET(pfid),
 		  hq_bds);
 
+	cnic_bnx2x_set_tcp_options(dev,
+			req1->flags & ISCSI_KWQE_INIT1_TIME_STAMPS_ENABLE,
+			req1->flags & ISCSI_KWQE_INIT1_DELAYED_ACK_ENABLE);
+
 	return 0;
 }
 
@@ -2035,9 +2061,6 @@ static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
 	xstorm_buf->pseudo_header_checksum =
 		swab16(~csum_ipv6_magic(&src_ip, &dst_ip, 0, IPPROTO_TCP, 0));
 
-	if (!(kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK))
-		tstorm_buf->params |=
-			L5CM_TSTORM_CONN_BUFFER_DELAYED_ACK_ENABLE;
 	if (kwqe3->ka_timeout) {
 		tstorm_buf->ka_enable = 1;
 		tstorm_buf->ka_timeout = kwqe3->ka_timeout;
@@ -2084,25 +2107,6 @@ static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
 		 mac[0]);
 }
 
-static void cnic_bnx2x_set_tcp_timestamp(struct cnic_dev *dev, int tcp_ts)
-{
-	struct cnic_local *cp = dev->cnic_priv;
-	struct bnx2x *bp = netdev_priv(dev->netdev);
-	u8 xstorm_flags = XSTORM_L5CM_TCP_FLAGS_WND_SCL_EN;
-	u16 tstorm_flags = 0;
-
-	if (tcp_ts) {
-		xstorm_flags |= XSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
-		tstorm_flags |= TSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
-	}
-
-	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), xstorm_flags);
-
-	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
-		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), tstorm_flags);
-}
-
 static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 			      u32 num, int *work)
 {
@@ -2178,9 +2182,6 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
 		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(cp->pfid), csk->vlan_id);
 
-	cnic_bnx2x_set_tcp_timestamp(dev,
-		kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_TIME_STAMP);
-
 	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_TCP_CONNECT,
 			kwqe1->cid, ISCSI_CONNECTION_TYPE, &l5_data);
 	if (!ret)
@@ -4220,7 +4221,7 @@ static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 	u32 port = CNIC_PORT(cp);
 
 	cnic_init_bnx2x_mac(dev);
-	cnic_bnx2x_set_tcp_timestamp(dev, 1);
+	cnic_bnx2x_set_tcp_options(dev, 0, 1);
 
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
 		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(pfid), 0);
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index ede3db3..e53f09d 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -5400,8 +5400,8 @@ struct tstorm_l5cm_tcp_flags {
 	u16 flags;
 #define TSTORM_L5CM_TCP_FLAGS_VLAN_ID (0xFFF<<0)
 #define TSTORM_L5CM_TCP_FLAGS_VLAN_ID_SHIFT 0
-#define TSTORM_L5CM_TCP_FLAGS_RSRV0 (0x1<<12)
-#define TSTORM_L5CM_TCP_FLAGS_RSRV0_SHIFT 12
+#define TSTORM_L5CM_TCP_FLAGS_DELAYED_ACK_EN (0x1<<12)
+#define TSTORM_L5CM_TCP_FLAGS_DELAYED_ACK_SHIFT 12
 #define TSTORM_L5CM_TCP_FLAGS_TS_ENABLED (0x1<<13)
 #define TSTORM_L5CM_TCP_FLAGS_TS_ENABLED_SHIFT 13
 #define TSTORM_L5CM_TCP_FLAGS_RSRV1 (0x3<<14)
diff --git a/drivers/scsi/bnx2i/57xx_iscsi_hsi.h b/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
index f2db5fe..62f00da 100644
--- a/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
+++ b/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
@@ -581,8 +581,10 @@ struct iscsi_kwqe_init1 {
 #define ISCSI_KWQE_INIT1_DELAYED_ACK_ENABLE_SHIFT 4
 #define ISCSI_KWQE_INIT1_KEEP_ALIVE_ENABLE (0x1<<5)
 #define ISCSI_KWQE_INIT1_KEEP_ALIVE_ENABLE_SHIFT 5
-#define ISCSI_KWQE_INIT1_RESERVED1 (0x3<<6)
-#define ISCSI_KWQE_INIT1_RESERVED1_SHIFT 6
+#define ISCSI_KWQE_INIT1_TIME_STAMPS_ENABLE (0x1<<6)
+#define ISCSI_KWQE_INIT1_TIME_STAMPS_ENABLE_SHIFT 6
+#define ISCSI_KWQE_INIT1_RESERVED1 (0x1<<7)
+#define ISCSI_KWQE_INIT1_RESERVED1_SHIFT 7
 	u16 cq_num_wqes;
 #elif defined(__LITTLE_ENDIAN)
 	u16 cq_num_wqes;
@@ -593,8 +595,10 @@ struct iscsi_kwqe_init1 {
 #define ISCSI_KWQE_INIT1_DELAYED_ACK_ENABLE_SHIFT 4
 #define ISCSI_KWQE_INIT1_KEEP_ALIVE_ENABLE (0x1<<5)
 #define ISCSI_KWQE_INIT1_KEEP_ALIVE_ENABLE_SHIFT 5
-#define ISCSI_KWQE_INIT1_RESERVED1 (0x3<<6)
-#define ISCSI_KWQE_INIT1_RESERVED1_SHIFT 6
+#define ISCSI_KWQE_INIT1_TIME_STAMPS_ENABLE (0x1<<6)
+#define ISCSI_KWQE_INIT1_TIME_STAMPS_ENABLE_SHIFT 6
+#define ISCSI_KWQE_INIT1_RESERVED1 (0x1<<7)
+#define ISCSI_KWQE_INIT1_RESERVED1_SHIFT 7
 	u8 cq_log_wqes_per_page;
 #endif
 #if defined(__BIG_ENDIAN)
-- 
1.7.1
