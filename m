From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 4/4] net: thunderx: Incorporate pass2 silicon CPI index configuration changes
Date: Fri, 23 Oct 2015 17:14:10 -0700
Message-ID: <1445645650-17328-5-git-send-email-ddaney.cavm@gmail.com>
References: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Cc: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

Add support for ThunderX pass2 CPI and MPI configuration changes.
MPI_ALG is not enabled i.e MCAM parsing is disabled.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 29 ++++++++++++++++++++------
 drivers/net/ethernet/cavium/thunder/nic_reg.h  |  4 ++++
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 52e1acb..c561fdc 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -43,6 +43,7 @@ struct nicpf {
 	u8			duplex[MAX_LMAC];
 	u32			speed[MAX_LMAC];
 	u16			cpi_base[MAX_NUM_VFS_SUPPORTED];
+	u16			rssi_base[MAX_NUM_VFS_SUPPORTED];
 	u16			rss_ind_tbl_size;
 	bool			mbx_lock[MAX_NUM_VFS_SUPPORTED];
 
@@ -396,8 +397,18 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 			padd = cpi % 8; /* 3 bits CS out of 6bits DSCP */
 
 		/* Leave RSS_SIZE as '0' to disable RSS */
-		nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
-			      (vnic << 24) | (padd << 16) | (rssi_base + rssi));
+		if (pass1_silicon(nic)) {
+			nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
+				      (vnic << 24) | (padd << 16) |
+				      (rssi_base + rssi));
+		} else {
+			/* Set MPI_ALG to '0' to disable MCAM parsing */
+			nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
+				      (padd << 16));
+			/* MPI index is same as CPI if MPI_ALG is not enabled */
+			nic_reg_write(nic, NIC_PF_MPI_0_2047_CFG | (cpi << 3),
+				      (vnic << 24) | (rssi_base + rssi));
+		}
 
 		if ((rssi + 1) >= cfg->rq_cnt)
 			continue;
@@ -410,6 +421,7 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 			rssi = ((cpi - cpi_base) & 0x38) >> 3;
 	}
 	nic->cpi_base[cfg->vf_id] = cpi_base;
+	nic->rssi_base[cfg->vf_id] = rssi_base;
 }
 
 /* Responsds to VF with its RSS indirection table size */
@@ -435,10 +447,9 @@ static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg)
 {
 	u8  qset, idx = 0;
 	u64 cpi_cfg, cpi_base, rssi_base, rssi;
+	u64 idx_addr;
 
-	cpi_base = nic->cpi_base[cfg->vf_id];
-	cpi_cfg = nic_reg_read(nic, NIC_PF_CPI_0_2047_CFG | (cpi_base << 3));
-	rssi_base = (cpi_cfg & 0x0FFF) + cfg->tbl_offset;
+	rssi_base = nic->rssi_base[cfg->vf_id] + cfg->tbl_offset;
 
 	rssi = rssi_base;
 	qset = cfg->vf_id;
@@ -455,9 +466,15 @@ static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg)
 		idx++;
 	}
 
+	cpi_base = nic->cpi_base[cfg->vf_id];
+	if (pass1_silicon(nic))
+		idx_addr = NIC_PF_CPI_0_2047_CFG;
+	else
+		idx_addr = NIC_PF_MPI_0_2047_CFG;
+	cpi_cfg = nic_reg_read(nic, idx_addr | (cpi_base << 3));
 	cpi_cfg &= ~(0xFULL << 20);
 	cpi_cfg |= (cfg->hash_bits << 20);
-	nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi_base << 3), cpi_cfg);
+	nic_reg_write(nic, idx_addr | (cpi_base << 3), cpi_cfg);
 }
 
 /* 4 level transmit side scheduler configutation
diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
index 58197bb..dd536be 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_reg.h
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -85,7 +85,11 @@
 #define   NIC_PF_ECC3_DBE_INT_W1S		(0x2708)
 #define   NIC_PF_ECC3_DBE_ENA_W1C		(0x2710)
 #define   NIC_PF_ECC3_DBE_ENA_W1S		(0x2718)
+#define   NIC_PF_MCAM_0_191_ENA			(0x100000)
+#define   NIC_PF_MCAM_0_191_M_0_5_DATA		(0x110000)
+#define   NIC_PF_MCAM_CTRL			(0x120000)
 #define   NIC_PF_CPI_0_2047_CFG			(0x200000)
+#define   NIC_PF_MPI_0_2047_CFG			(0x210000)
 #define   NIC_PF_RSSI_0_4097_RQ			(0x220000)
 #define   NIC_PF_LMAC_0_7_CFG			(0x240000)
 #define   NIC_PF_LMAC_0_7_SW_XOFF		(0x242000)
-- 
1.8.3.1
