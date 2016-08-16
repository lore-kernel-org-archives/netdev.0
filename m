From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH] net: thunderx: Fix OOPs with ethtool --register-dump
Date: Tue, 16 Aug 2016 13:30:36 -0700
Message-ID: <1471379436-2932-1-git-send-email-ddaney.cavm@gmail.com>
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

The ethtool_ops .get_regs function attempts to read the nonexistent
register NIC_QSET_SQ_0_7_CNM_CHG, which produces a "bus error" type
OOPs.

Fix by not attempting to read, and removing the definition of,
NIC_QSET_SQ_0_7_CNM_CHG.  A zero is written into the register dump to
keep the layout unchanged.

Signed-off-by: David Daney <david.daney@cavium.com>
Cc: <stable@vger.kernel.org> # 4.4.x-
---
 drivers/net/ethernet/cavium/thunder/nic_reg.h       | 1 -
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c | 5 ++++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
index afb10e3..fab35a5 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_reg.h
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -170,7 +170,6 @@
 #define   NIC_QSET_SQ_0_7_DOOR			(0x010838)
 #define   NIC_QSET_SQ_0_7_STATUS		(0x010840)
 #define   NIC_QSET_SQ_0_7_DEBUG			(0x010848)
-#define   NIC_QSET_SQ_0_7_CNM_CHG		(0x010860)
 #define   NIC_QSET_SQ_0_7_STAT_0_1		(0x010900)
 
 #define   NIC_QSET_RBDR_0_1_CFG			(0x010C00)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index d2d8ef2..ad4fddb 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -382,7 +382,10 @@ static void nicvf_get_regs(struct net_device *dev,
 		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_DOOR, q);
 		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_STATUS, q);
 		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_DEBUG, q);
-		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_CNM_CHG, q);
+		/* Padding, was NIC_QSET_SQ_0_7_CNM_CHG, which
+		 * produces bus errors when read
+		 */
+		p[i++] = 0;
 		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_STAT_0_1, q);
 		reg_offset = NIC_QSET_SQ_0_7_STAT_0_1 | (1 << 3);
 		p[i++] = nicvf_queue_reg_read(nic, reg_offset, q);
-- 
1.8.3.1
