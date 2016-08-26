From: Chris Brandt <chris.brandt@renesas.com>
Subject: [PATCH] net: ethernet: renesas: sh_eth: do not access POST registers if not exist
Date: Fri, 26 Aug 2016 16:01:07 -0400
Message-ID: <20160826200107.20681-1-chris.brandt@renesas.com>
Cc: Chris Brandt <chris.brandt@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RZ/A1 has a TSU, but since it only has one Ethernet port, it does not
have POST registers. Therefore, if you try to write to register index
TSU_POST1 (which will be FFFF because it does not exist), it will either
panic or corrupt memory elsewhere.

Reported-by: Daniel Palmer <daniel@0x0f.com>
Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 7 +++++++
 drivers/net/ethernet/renesas/sh_eth.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 1f8240a..850a13c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -532,6 +532,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
 	.no_ade		= 1,
 	.hw_crc		= 1,
 	.tsu		= 1,
+	.tsu_no_post	= 1,
 	.shift_rd0	= 1,
 };
 
@@ -2460,6 +2461,9 @@ static void sh_eth_tsu_enable_cam_entry_post(struct net_device *ndev,
 	u32 tmp;
 	void *reg_offset;
 
+	if (mdp->cd->tsu_no_post)
+		return;
+
 	reg_offset = sh_eth_tsu_get_post_reg_offset(mdp, entry);
 	tmp = ioread32(reg_offset);
 	iowrite32(tmp | sh_eth_tsu_get_post_bit(mdp, entry), reg_offset);
@@ -2472,6 +2476,9 @@ static bool sh_eth_tsu_disable_cam_entry_post(struct net_device *ndev,
 	u32 post_mask, ref_mask, tmp;
 	void *reg_offset;
 
+	if (mdp->cd->tsu_no_post)
+		return false;
+
 	reg_offset = sh_eth_tsu_get_post_reg_offset(mdp, entry);
 	post_mask = sh_eth_tsu_get_post_mask(entry);
 	ref_mask = sh_eth_tsu_get_post_bit(mdp, entry) & ~post_mask;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index d050f37..ae34f2e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -484,6 +484,7 @@ struct sh_eth_cpu_data {
 	unsigned tpauser:1;	/* EtherC have TPAUSER */
 	unsigned bculr:1;	/* EtherC have BCULR */
 	unsigned tsu:1;		/* EtherC have TSU */
+	unsigned tsu_no_post:1;	/* EtherC have TSU, but no POST */
 	unsigned hw_swap:1;	/* E-DMAC have DE bit in EDMR */
 	unsigned rpadir:1;	/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;	/* E-DMAC DO NOT have TRIMD */
-- 
2.9.2
