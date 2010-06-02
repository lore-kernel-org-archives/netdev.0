From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] chelsio: Remove remnants of CONFIG_CHELSIO_T1_COUGAR
Date: Wed, 02 Jun 2010 11:04:28 -0700
Message-ID: <ada39x5tioj.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:56166 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932449Ab0FBSEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_CHELSIO_T1_COUGAR cannot be set (it appears nowhere in any
Kconfig files), and the code it protects could never build (cspi.h was
never added to the kernel tree).  Therefore it's pretty safe to remove
all vestiges of this dead code.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/chelsio/common.h |    1 -
 drivers/net/chelsio/subr.c   |   49 +----------------------------------------
 2 files changed, 2 insertions(+), 48 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index 036b2df..092f31a 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -286,7 +286,6 @@ struct board_info {
 	unsigned int            clock_mc3;
 	unsigned int            clock_mc4;
 	unsigned int            espi_nports;
-	unsigned int            clock_cspi;
 	unsigned int            clock_elmer0;
 	unsigned char           mdio_mdien;
 	unsigned char           mdio_mdiinv;
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 53bde15..599d178 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -185,9 +185,6 @@ static int t1_pci_intr_handler(adapter_t *adapter)
 	return 0;
 }
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-#include "cspi.h"
-#endif
 #ifdef CONFIG_CHELSIO_T1_1G
 #include "fpga_defs.h"
 
@@ -280,7 +277,7 @@ static void mi1_mdio_init(adapter_t *adapter, const struct board_info *bi)
 	t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_CFG, val);
 }
 
-#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+#if defined(CONFIG_CHELSIO_T1_1G)
 /*
  * Elmer MI1 MDIO read/write operations.
  */
@@ -317,7 +314,7 @@ static int mi1_mdio_write(struct net_device *dev, int phy_addr, int mmd_addr,
 	return 0;
 }
 
-#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+#if defined(CONFIG_CHELSIO_T1_1G)
 static const struct mdio_ops mi1_mdio_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_read,
@@ -752,31 +749,6 @@ int t1_elmer0_ext_intr_handler(adapter_t *adapter)
 					 mod_detect ? "removed" : "inserted");
 		}
 		break;
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	case CHBT_BOARD_COUGAR:
-		if (adapter->params.nports == 1) {
-			if (cause & ELMER0_GP_BIT1) {         /* Vitesse MAC */
-				struct cmac *mac = adapter->port[0].mac;
-				mac->ops->interrupt_handler(mac);
-			}
-			if (cause & ELMER0_GP_BIT5) {     /* XPAK MOD_DETECT */
-			}
-		} else {
-			int i, port_bit;
-
-			for_each_port(adapter, i) {
-				port_bit = i ? i + 1 : 0;
-				if (!(cause & (1 << port_bit)))
-					continue;
-
-				phy = adapter->port[i].phy;
-				phy_cause = phy->ops->interrupt_handler(phy);
-				if (phy_cause & cphy_cause_link_change)
-					t1_link_changed(adapter, i);
-			}
-		}
-		break;
-#endif
 	}
 	t1_tpi_write(adapter, A_ELMER0_INT_CAUSE, cause);
 	return 0;
@@ -955,7 +927,6 @@ static int board_init(adapter_t *adapter, const struct board_info *bi)
 	case CHBT_BOARD_N110:
 	case CHBT_BOARD_N210:
 	case CHBT_BOARD_CHT210:
-	case CHBT_BOARD_COUGAR:
 		t1_tpi_par(adapter, 0xf);
 		t1_tpi_write(adapter, A_ELMER0_GPO, 0x800);
 		break;
@@ -1004,10 +975,6 @@ int t1_init_hw_modules(adapter_t *adapter)
 		       adapter->regs + A_MC5_CONFIG);
 	}
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (adapter->cspi && t1_cspi_init(adapter->cspi))
-		goto out_err;
-#endif
 	if (adapter->espi && t1_espi_init(adapter->espi, bi->chip_mac,
 					  bi->espi_nports))
 		goto out_err;
@@ -1061,10 +1028,6 @@ void t1_free_sw_modules(adapter_t *adapter)
 		t1_tp_destroy(adapter->tp);
 	if (adapter->espi)
 		t1_espi_destroy(adapter->espi);
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (adapter->cspi)
-		t1_cspi_destroy(adapter->cspi);
-#endif
 }
 
 static void __devinit init_link_config(struct link_config *lc,
@@ -1084,14 +1047,6 @@ static void __devinit init_link_config(struct link_config *lc,
 	}
 }
 
-#ifdef CONFIG_CHELSIO_T1_COUGAR
-	if (bi->clock_cspi && !(adapter->cspi = t1_cspi_create(adapter))) {
-		pr_err("%s: CSPI initialization failed\n",
-		       adapter->name);
-		goto error;
-	}
-#endif
-
 /*
  * Allocate and initialize the data structures that hold the SW state of
  * the Terminator HW modules.

-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
