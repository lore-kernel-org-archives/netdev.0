From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 19/21] net: thunderx: Configure tunnelling protocol parsing
Date: Fri, 12 Aug 2016 16:51:42 +0530
Message-ID: <1471000904-21715-20-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Zyta Szpak <zr@semihalf.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32852 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbcHLLXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 07:23:16 -0400
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zyta Szpak <zr@semihalf.com>

This patch enables parsing of inner layers for tunnelled packets.

Signed-off-by: Zyta Szpak <zr@semihalf.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 21 +++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h  | 13 +++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 167291b..25618d2 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -835,6 +835,25 @@ static int nic_reset_stat_counters(struct nicpf *nic,
 	return 0;
 }
 
+static void nic_enable_tunnel_parsing(struct nicpf *nic, int vf)
+{
+	u64 prot_def = (IPV6_PROT << 32) | (IPV4_PROT << 16) | ET_PROT;
+	u64 vxlan_prot_def = (IPV6_PROT_DEF << 32) |
+			      (IPV4_PROT_DEF) << 16 | ET_PROT_DEF;
+
+	/* Configure tunnel parsing parameters */
+	nic_reg_write(nic, NIC_PF_RX_GENEVE_DEF,
+		      (1ULL << 63 | UDP_GENEVE_PORT_NUM));
+	nic_reg_write(nic, NIC_PF_RX_GENEVE_PROT_DEF,
+		      ((7ULL << 61) | prot_def));
+	nic_reg_write(nic, NIC_PF_RX_NVGRE_PROT_DEF,
+		      ((7ULL << 61) | prot_def));
+	nic_reg_write(nic, NIC_PF_RX_VXLAN_DEF_0_1,
+		      ((1ULL << 63) | UDP_VXLAN_PORT_NUM));
+	nic_reg_write(nic, NIC_PF_RX_VXLAN_PROT_DEF,
+		      ((0xfULL << 60) | vxlan_prot_def));
+}
+
 static void nic_enable_vf(struct nicpf *nic, int vf, bool enable)
 {
 	int bgx, lmac;
@@ -908,6 +927,8 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		 */
 		if (pass2_silicon(nic->pdev))
 			nic_reg_write(nic, NIC_PF_RX_CFG, 0x01);
+		if (!pass1_silicon(nic->pdev))
+			nic_enable_tunnel_parsing(nic, vf);
 		break;
 	case NIC_MBOX_MSG_RQ_BP_CFG:
 		reg_addr = NIC_PF_QSET_0_127_RQ_0_7_BP_CFG |
diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
index b4a7953..db9c632 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_reg.h
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -36,6 +36,19 @@
 #define   NIC_PF_MAILBOX_ENA_W1C		(0x0450)
 #define   NIC_PF_MAILBOX_ENA_W1S		(0x0470)
 #define   NIC_PF_RX_ETYPE_0_7			(0x0500)
+#define   NIC_PF_RX_GENEVE_DEF			(0x0580)
+#define    UDP_GENEVE_PORT_NUM				0x17C1ULL
+#define   NIC_PF_RX_GENEVE_PROT_DEF		(0x0588)
+#define    IPV6_PROT					0x86DDULL
+#define    IPV4_PROT					0x800ULL
+#define    ET_PROT					0x6558ULL
+#define   NIC_PF_RX_NVGRE_PROT_DEF		(0x0598)
+#define   NIC_PF_RX_VXLAN_DEF_0_1		(0x05A0)
+#define    UDP_VXLAN_PORT_NUM				0x12B5
+#define   NIC_PF_RX_VXLAN_PROT_DEF		(0x05B0)
+#define    IPV6_PROT_DEF				0x2ULL
+#define    IPV4_PROT_DEF				0x1ULL
+#define    ET_PROT_DEF					0x3ULL
 #define   NIC_PF_RX_CFG				(0x05D0)
 #define   NIC_PF_PKIND_0_15_CFG			(0x0600)
 #define   NIC_PF_ECC0_FLIP0			(0x1000)
-- 
2.7.4
