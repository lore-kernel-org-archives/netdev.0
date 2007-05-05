From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 9/11][TG3]: Add ASPM workaround.
Date: Fri, 04 May 2007 17:55:14 -0700
Message-ID: <1178326514.4859.25.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4066 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422996AbXEEAH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:07:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add ASPM workaround.

This patch adds workaround to fix performance problems caused by slow
PCIE L1->L0 transitions on ICH8 platforms.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4fe38a0..b3681e4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3019,6 +3019,15 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		}
 	}
 
+	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND) {
+		u32 val = tr32(0x7d28);
+		if (!netif_carrier_ok(tp->dev))
+			val = (val & ~0x0000ff00) | tp->pwrmgmt_thresh;
+		else
+			val |= 0x0000ff00;
+		tw32(0x7d28, val);
+	}
+
 	return err;
 }
 
@@ -10004,6 +10013,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
 			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
 		}
+		if (tr32(VCPU_CFGSHDW) & VCPU_CFGSHDW_ASPM_DBNC)
+			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		return;
 	}
 
@@ -10131,6 +10142,14 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		/* bootcode if bit 18 is set */
 		if (cfg2 & (1 << 18))
 			tp->tg3_flags2 |= TG3_FLG2_SERDES_PREEMPHASIS;
+
+		if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+			u32 cfg3;
+
+			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &cfg3);
+			if (cfg3 & NIC_SRAM_ASPM_DEBOUNCE)
+				tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
+		}
 	}
 }
 
@@ -10997,6 +11016,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
 
+	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND)
+		tp->pwrmgmt_thresh = tr32(0x7d28) & 0x0000ff00;
+
 	return err;
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dcdfc08..d88a859 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1150,6 +1150,9 @@
 #define  VCPU_STATUS_INIT_DONE		 0x04000000
 #define  VCPU_STATUS_DRV_RESET		 0x08000000
 
+#define VCPU_CFGSHDW			0x00005104
+#define  VCPU_CFGSHDW_ASPM_DBNC		 0x00001000
+
 /* Mailboxes */
 #define GRCMBOX_BASE			0x00005600
 #define GRCMBOX_INTERRUPT_0		0x00005800 /* 64-bit */
@@ -1593,6 +1596,9 @@
 #define  SHASTA_EXT_LED_MAC		 0x00010000
 #define  SHASTA_EXT_LED_COMBO		 0x00018000
 
+#define NIC_SRAM_DATA_CFG_3		0x00000d3c
+#define  NIC_SRAM_ASPM_DEBOUNCE		 0x00000002
+
 #define NIC_SRAM_RX_MINI_BUFFER_DESC	0x00001000
 
 #define NIC_SRAM_DMA_DESC_POOL_BASE	0x00002000
@@ -2200,6 +2206,7 @@ struct tg3 {
 #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
 #define TG3_FLAG_USE_MI_INTERRUPT	0x00000010
 #define TG3_FLAG_ENABLE_ASF		0x00000020
+#define TG3_FLAG_ASPM_WORKAROUND	0x00000040
 #define TG3_FLAG_POLL_SERDES		0x00000080
 #define TG3_FLAG_MBOX_WRITE_REORDER	0x00000100
 #define TG3_FLAG_PCIX_TARGET_HWBUG	0x00000200
@@ -2288,6 +2295,7 @@ struct tg3 {
 	u32				grc_local_ctrl;
 	u32				dma_rwctrl;
 	u32				coalesce_mode;
+	u32				pwrmgmt_thresh;
 
 	/* PCI block */
 	u16				pci_chip_rev_id;


