From: Andrea Galbusera <gizero@gmail.com>
Subject: [PATCH v2 1/1] powerpc: Fix multicast problem in fs_enet driver
Date: Thu, 21 Apr 2011 14:21:21 +0200
Message-ID: <1303388481-17993-1-git-send-email-gizero@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andrea Galbusera <gizero@gmail.com>
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Scott Wood <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mac-fec.c was setting individual UDP address registers instead of multicast
group address registers when joining a multicast group.
This prevented from correctly receiving UDP multicast packets.
According to datasheet, replaced hash_table_high and hash_table_low
with grp_hash_table_high and grp_hash_table_low respectively.
Also renamed hash_table_* with grp_hash_table_* in struct fec declaration
for 8xx: these registers are used only for multicast there.

Tested on a MPC5121 based board.
Build tested also against mpc866_ads_defconfig.

Signed-off-by: Andrea Galbusera <gizero@gmail.com>
---
Changes since v1:
Applied comments by Scott Wood to fix 8xx broken build with v1

 arch/powerpc/include/asm/8xx_immap.h |    4 ++--
 drivers/net/fs_enet/mac-fec.c        |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/include/asm/8xx_immap.h b/arch/powerpc/include/asm/8xx_immap.h
index 6b6dc20..bdf0563 100644
--- a/arch/powerpc/include/asm/8xx_immap.h
+++ b/arch/powerpc/include/asm/8xx_immap.h
@@ -393,8 +393,8 @@ typedef struct fec {
 	uint	fec_addr_low;		/* lower 32 bits of station address	*/
 	ushort	fec_addr_high;		/* upper 16 bits of station address	*/
 	ushort	res1;			/* reserved				*/
-	uint	fec_hash_table_high;	/* upper 32-bits of hash table		*/
-	uint	fec_hash_table_low;	/* lower 32-bits of hash table		*/
+	uint	fec_grp_hash_table_high;	/* upper 32-bits of hash table		*/
+	uint	fec_grp_hash_table_low;	/* lower 32-bits of hash table		*/
 	uint	fec_r_des_start;	/* beginning of Rx descriptor ring	*/
 	uint	fec_x_des_start;	/* beginning of Tx descriptor ring	*/
 	uint	fec_r_buff_size;	/* Rx buffer size			*/
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 61035fc..b9fbc83 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -226,8 +226,8 @@ static void set_multicast_finish(struct net_device *dev)
 	}
 
 	FC(fecp, r_cntrl, FEC_RCNTRL_PROM);
-	FW(fecp, hash_table_high, fep->fec.hthi);
-	FW(fecp, hash_table_low, fep->fec.htlo);
+	FW(fecp, grp_hash_table_high, fep->fec.hthi);
+	FW(fecp, grp_hash_table_low, fep->fec.htlo);
 }
 
 static void set_multicast_list(struct net_device *dev)
@@ -273,8 +273,8 @@ static void restart(struct net_device *dev)
 	/*
 	 * Reset all multicast.
 	 */
-	FW(fecp, hash_table_high, fep->fec.hthi);
-	FW(fecp, hash_table_low, fep->fec.htlo);
+	FW(fecp, grp_hash_table_high, fep->fec.hthi);
+	FW(fecp, grp_hash_table_low, fep->fec.htlo);
 
 	/*
 	 * Set maximum receive buffer size.
-- 
1.7.0.4
