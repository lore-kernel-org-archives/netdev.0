From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 3/5] sh_eth: Implement ethtool register dump
 operations
Date: Thu, 26 Feb 2015 20:34:35 +0000
Message-ID: <1424982875.4444.74.camel@xylophone.i.decadent.org.uk>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46840 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbbBZUem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:34:42 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many different sets of registers implemented by the
different versions of this controller, and we can only expect this to
get more complicated in future.  Limit how much ethtool needs to know
by including an explicit bitmap of which registers are included in the
dump, allowing room for future growth in the number of possible
registers.

As I don't have datasheets for all of these, I've only included
registers that are:

- defined in all 5 register type arrays, or
- used by the driver, or
- documented in the datasheet I have

Add one new capability flag so we can tell whether the RTRATE
register is implemented.

Delete the TSU_ADRL0 and TSU_ADR{H,L}31 definitions, as they weren't
used and the address table is already assumed to be contiguous.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |  197 +++++++++++++++++++++++++++++++--
 drivers/net/ethernet/renesas/sh_eth.h |    9 +-
 2 files changed, 195 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index e21f8ce609cd..e6248b1c3ad5 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -137,9 +137,6 @@ static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_POST3]	= 0x0078,
 	[TSU_POST4]	= 0x007c,
 	[TSU_ADRH0]	= 0x0100,
-	[TSU_ADRL0]	= 0x0104,
-	[TSU_ADRH31]	= 0x01f8,
-	[TSU_ADRL31]	= 0x01fc,
 
 	[TXNLCR0]	= 0x0080,
 	[TXALCR0]	= 0x0084,
@@ -206,9 +203,6 @@ static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_ADSBSY]	= 0x0060,
 	[TSU_TEN]	= 0x0064,
 	[TSU_ADRH0]	= 0x0100,
-	[TSU_ADRL0]	= 0x0104,
-	[TSU_ADRH31]	= 0x01f8,
-	[TSU_ADRL31]	= 0x01fc,
 
 	[TXNLCR0]	= 0x0080,
 	[TXALCR0]	= 0x0084,
@@ -405,8 +399,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[FWALCR1]	= 0x00b4,
 
 	[TSU_ADRH0]	= 0x0100,
-	[TSU_ADRL0]	= 0x0104,
-	[TSU_ADRL31]	= 0x01fc,
 };
 
 static void sh_eth_rcv_snd_disable(struct net_device *ndev);
@@ -601,6 +593,7 @@ static struct sh_eth_cpu_data sh7757_data = {
 	.no_ade		= 1,
 	.rpadir		= 1,
 	.rpadir_value   = 2 << 16,
+	.rtrate		= 1,
 };
 
 #define SH_GIGA_ETH_BASE	0xfee00000UL
@@ -1942,6 +1935,192 @@ error_exit:
 	return ret;
 }
 
+/* If it is ever necessary to increase SH_ETH_REG_DUMP_MAX_REGS, the
+ * version must be bumped as well.  Just adding registers up to that
+ * limit is fine, as long as the existing register indices don't
+ * change.
+ */
+#define SH_ETH_REG_DUMP_VERSION		1
+#define SH_ETH_REG_DUMP_MAX_REGS	256
+
+static size_t __sh_eth_get_regs(struct net_device *ndev, u32 *buf)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_cpu_data *cd = mdp->cd;
+	u32 *valid_map;
+	size_t len;
+
+	BUILD_BUG_ON(SH_ETH_MAX_REGISTER_OFFSET > SH_ETH_REG_DUMP_MAX_REGS);
+
+	/* Dump starts with a bitmap that tells ethtool which
+	 * registers are defined for this chip.
+	 */
+	len = DIV_ROUND_UP(SH_ETH_REG_DUMP_MAX_REGS, 32);
+	if (buf) {
+		valid_map = buf;
+		buf += len;
+	} else {
+		valid_map = NULL;
+	}
+
+	/* Add a register to the dump, if it has a defined offset.
+	 * This automatically skips most undefined registers, but for
+	 * some it is also necessary to check a capability flag in
+	 * struct sh_eth_cpu_data.
+	 */
+#define mark_reg_valid(reg) valid_map[reg / 32] |= 1U << (reg % 32)
+#define add_reg_from(reg, read_expr) do {				\
+		if (mdp->reg_offset[reg] != SH_ETH_OFFSET_INVALID) {	\
+			if (buf) {					\
+				mark_reg_valid(reg);			\
+				*buf++ = read_expr;			\
+			}						\
+			++len;						\
+		}							\
+	} while (0)
+#define add_reg(reg) add_reg_from(reg, sh_eth_read(ndev, reg))
+#define add_tsu_reg(reg) add_reg_from(reg, sh_eth_tsu_read(mdp, reg))
+
+	add_reg(EDSR);
+	add_reg(EDMR);
+	add_reg(EDTRR);
+	add_reg(EDRRR);
+	add_reg(EESR);
+	add_reg(EESIPR);
+	add_reg(TDLAR);
+	add_reg(TDFAR);
+	add_reg(TDFXR);
+	add_reg(TDFFR);
+	add_reg(RDLAR);
+	add_reg(RDFAR);
+	add_reg(RDFXR);
+	add_reg(RDFFR);
+	add_reg(TRSCER);
+	add_reg(RMFCR);
+	add_reg(TFTR);
+	add_reg(FDR);
+	add_reg(RMCR);
+	add_reg(TFUCR);
+	add_reg(RFOCR);
+	if (cd->rmiimode)
+		add_reg(RMIIMODE);
+	add_reg(FCFTR);
+	if (cd->rpadir)
+		add_reg(RPADIR);
+	if (!cd->no_trimd)
+		add_reg(TRIMD);
+	add_reg(ECMR);
+	add_reg(ECSR);
+	add_reg(ECSIPR);
+	add_reg(PIR);
+	if (!cd->no_psr)
+		add_reg(PSR);
+	add_reg(RDMLR);
+	add_reg(RFLR);
+	add_reg(IPGR);
+	if (cd->apr)
+		add_reg(APR);
+	if (cd->mpr)
+		add_reg(MPR);
+	add_reg(RFCR);
+	add_reg(RFCF);
+	if (cd->tpauser)
+		add_reg(TPAUSER);
+	add_reg(TPAUSECR);
+	add_reg(GECMR);
+	if (cd->bculr)
+		add_reg(BCULR);
+	add_reg(MAHR);
+	add_reg(MALR);
+	add_reg(TROCR);
+	add_reg(CDCR);
+	add_reg(LCCR);
+	add_reg(CNDCR);
+	add_reg(CEFCR);
+	add_reg(FRECR);
+	add_reg(TSFRCR);
+	add_reg(TLFRCR);
+	add_reg(CERCR);
+	add_reg(CEECR);
+	add_reg(MAFCR);
+	if (cd->rtrate)
+		add_reg(RTRATE);
+	if (cd->hw_crc)
+		add_reg(CSMR);
+	if (cd->select_mii)
+		add_reg(RMII_MII);
+	add_reg(ARSTR);
+	if (cd->tsu) {
+		add_tsu_reg(TSU_CTRST);
+		add_tsu_reg(TSU_FWEN0);
+		add_tsu_reg(TSU_FWEN1);
+		add_tsu_reg(TSU_FCM);
+		add_tsu_reg(TSU_BSYSL0);
+		add_tsu_reg(TSU_BSYSL1);
+		add_tsu_reg(TSU_PRISL0);
+		add_tsu_reg(TSU_PRISL1);
+		add_tsu_reg(TSU_FWSL0);
+		add_tsu_reg(TSU_FWSL1);
+		add_tsu_reg(TSU_FWSLC);
+		add_tsu_reg(TSU_QTAG0);
+		add_tsu_reg(TSU_QTAG1);
+		add_tsu_reg(TSU_QTAGM0);
+		add_tsu_reg(TSU_QTAGM1);
+		add_tsu_reg(TSU_FWSR);
+		add_tsu_reg(TSU_FWINMK);
+		add_tsu_reg(TSU_ADQT0);
+		add_tsu_reg(TSU_ADQT1);
+		add_tsu_reg(TSU_VTAG0);
+		add_tsu_reg(TSU_VTAG1);
+		add_tsu_reg(TSU_ADSBSY);
+		add_tsu_reg(TSU_TEN);
+		add_tsu_reg(TSU_POST1);
+		add_tsu_reg(TSU_POST2);
+		add_tsu_reg(TSU_POST3);
+		add_tsu_reg(TSU_POST4);
+		if (mdp->reg_offset[TSU_ADRH0] != SH_ETH_OFFSET_INVALID) {
+			/* This is the start of a table, not just a single
+			 * register.
+			 */
+			if (buf) {
+				unsigned int i;
+
+				mark_reg_valid(TSU_ADRH0);
+				for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES * 2; i++)
+					*buf++ = ioread32(
+						mdp->tsu_addr +
+						mdp->reg_offset[TSU_ADRH0] +
+						i * 4);
+			}
+			len += SH_ETH_TSU_CAM_ENTRIES * 2;
+		}
+	}
+
+#undef mark_reg_valid
+#undef add_reg_from
+#undef add_reg
+#undef add_tsu_reg
+
+	return len * 4;
+}
+
+static int sh_eth_get_regs_len(struct net_device *ndev)
+{
+	return __sh_eth_get_regs(ndev, NULL);
+}
+
+static void sh_eth_get_regs(struct net_device *ndev, struct ethtool_regs *regs,
+			    void *buf)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	regs->version = SH_ETH_REG_DUMP_VERSION;
+
+	pm_runtime_get_sync(&mdp->pdev->dev);
+	__sh_eth_get_regs(ndev, buf);
+	pm_runtime_put_sync(&mdp->pdev->dev);
+}
+
 static int sh_eth_nway_reset(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -2087,6 +2266,8 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_settings	= sh_eth_get_settings,
 	.set_settings	= sh_eth_set_settings,
+	.get_regs_len	= sh_eth_get_regs_len,
+	.get_regs	= sh_eth_get_regs,
 	.nway_reset	= sh_eth_nway_reset,
 	.get_msglevel	= sh_eth_get_msglevel,
 	.set_msglevel	= sh_eth_set_msglevel,
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 33a360c4fd10..06dbbe5201cb 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -32,6 +32,10 @@
 #define SH_ETH_TSU_CAM_ENTRIES	32
 
 enum {
+	/* IMPORTANT: To keep ethtool register dump working, add new
+	 * register names immediately before SH_ETH_MAX_REGISTER_OFFSET.
+	 */
+
 	/* E-DMAC registers */
 	EDSR = 0,
 	EDMR,
@@ -131,9 +135,7 @@ enum {
 	TSU_POST3,
 	TSU_POST4,
 	TSU_ADRH0,
-	TSU_ADRL0,
-	TSU_ADRH31,
-	TSU_ADRL31,
+	/* TSU_ADR{H,L}{0..31} are assumed to be contiguous */
 
 	TXNLCR0,
 	TXALCR0,
@@ -491,6 +493,7 @@ struct sh_eth_cpu_data {
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
 	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
 	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
+	unsigned rtrate:1;	/* EtherC has RTRATE register */
 };
 
 struct sh_eth_private {
-- 
1.7.10.4
