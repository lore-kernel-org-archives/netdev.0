From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/5] cnic: Fix bnx2x ring shutdown.
Date: Wed, 2 Dec 2009 17:15:36 -0800
Message-ID: <1259802939-4742-2-git-send-email-mchan@broadcom.com>
References: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3827 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbZLCBIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:08:30 -0500
In-Reply-To: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to send a HALT command to the firmware to fully shutdown the bnx2x
rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 10c5cc3..fb1cadb 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4164,8 +4164,15 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		struct cnic_local *cp = dev->cnic_priv;
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+		union l5cm_specific_data l5_data;
 
 		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 0);
+
+		l5_data.phy_address.lo = cli;
+		l5_data.phy_address.hi = 0;
+		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_HALT,
+			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
+		msleep(10);
 	}
 }
 
-- 
1.6.4.GIT


