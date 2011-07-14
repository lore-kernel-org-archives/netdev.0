From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/6] cnic: Fix ring setup/shutdown code
Date: Wed, 13 Jul 2011 20:24:19 -0700
Message-ID: <1310613862-27497-3-git-send-email-mchan@broadcom.com>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
 <1310613862-27497-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4341 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
In-Reply-To: <1310613862-27497-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latest bnx2x driver uses different CID for the iSCSI rings, so
we need to pass it in the ring init data.  The rx ring is also
zeroed out to prevent stale DMA addresses from being used after
shutdown.

The same cp local variable redefined inside the else branch is
also eliminated.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/cnic.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index a881e42..bdfe155 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4923,7 +4923,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		struct client_init_ramrod_data *data;
 		union l5cm_specific_data l5_data;
 		struct ustorm_eth_rx_producers rx_prods = {0};
-		u32 off, i;
+		u32 off, i, *cid_ptr;
 
 		rx_prods.bd_prod = 0;
 		rx_prods.cqe_prod = BNX2X_MAX_RCQ_DESC_CNT;
@@ -4942,6 +4942,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 
 		data = udev->l2_buf;
+		cid_ptr = udev->l2_buf + 12;
 
 		memset(data, 0, sizeof(*data));
 
@@ -4966,12 +4967,15 @@ static void cnic_init_rings(struct cnic_dev *dev)
 				"iSCSI CLIENT_SETUP did not complete\n");
 		cnic_spq_completion(dev, DRV_CTL_RET_L2_SPQ_CREDIT_CMD, 1);
 		cnic_ring_ctl(dev, cid, cli, 1);
+		*cid_ptr = cid;
 	}
 }
 
 static void cnic_shutdown_rings(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = cp->udev;
+	void *rx_ring;
 
 	if (!test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
 		return;
@@ -4979,7 +4983,6 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		cnic_shutdown_bnx2_rx_ring(dev);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
-		struct cnic_local *cp = dev->cnic_priv;
 		u32 cli = cp->ethdev->iscsi_l2_client_id;
 		u32 cid = cp->ethdev->iscsi_l2_cid;
 		union l5cm_specific_data l5_data;
@@ -5009,6 +5012,8 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		msleep(10);
 	}
 	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
+	rx_ring = udev->l2_ring + BCM_PAGE_SIZE;
+	memset(rx_ring, 0, BCM_PAGE_SIZE);
 }
 
 static int cnic_register_netdev(struct cnic_dev *dev)
-- 
1.6.4.GIT


