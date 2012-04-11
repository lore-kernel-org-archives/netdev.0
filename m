From: greearb@candelatech.com
Subject: [PATCH 10/10] ath9k: Gather and report IRQ sync_cause errors.
Date: Wed, 11 Apr 2012 10:52:18 -0700
Message-ID: <1334166738-28243-11-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40916 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab2DKRy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:54:29 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Report all defined sync_cause errors in debugfs
to aid with debugging.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 aa2abaf... 8d78253... M	drivers/net/wireless/ath/ath9k/ar9002_mac.c
:100644 100644 a66a13b... d9e0824... M	drivers/net/wireless/ath/ath9k/ar9003_mac.c
:100644 100644 189ac7f... 1bd7204... M	drivers/net/wireless/ath/ath9k/debug.c
:100644 100644 17f6cc2... c34da09... M	drivers/net/wireless/ath/ath9k/debug.h
:100644 100644 d1345a8... 61b2157... M	drivers/net/wireless/ath/ath9k/hw.c
:100644 100644 aa1680a... fba99ef... M	drivers/net/wireless/ath/ath9k/hw.h
 drivers/net/wireless/ath/ath9k/ar9002_mac.c |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c |    2 +
 drivers/net/wireless/ath/ath9k/debug.c      |  113 ++++++++++++++------------
 drivers/net/wireless/ath/ath9k/debug.h      |   23 ++++++
 drivers/net/wireless/ath/ath9k/hw.c         |   49 ++++++++++++
 drivers/net/wireless/ath/ath9k/hw.h         |    6 ++
 6 files changed, 142 insertions(+), 52 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9002_mac.c b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
index aa2abaf..8d78253 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
@@ -136,6 +136,7 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 	}
 
 	if (sync_cause) {
+		ath9k_debug_sync_cause(common, sync_cause);
 		fatal_int =
 			(sync_cause &
 			 (AR_INTR_SYNC_HOST1_FATAL | AR_INTR_SYNC_HOST1_PERR))
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index a66a13b..d9e0824 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -306,6 +306,8 @@ static bool ar9003_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		ar9003_mci_get_isr(ah, masked);
 
 	if (sync_cause) {
+		ath9k_debug_sync_cause(common, sync_cause);
+
 		if (sync_cause & AR_INTR_SYNC_RADM_CPL_TIMEOUT) {
 			REG_WRITE(ah, AR_RC, AR_RC_HOSTIF);
 			REG_WRITE(ah, AR_RC, 0);
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 189ac7f..1bd7204 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -380,63 +380,72 @@ static ssize_t read_file_interrupt(struct file *file, char __user *user_buf,
 				   size_t count, loff_t *ppos)
 {
 	struct ath_softc *sc = file->private_data;
-	char buf[512];
 	unsigned int len = 0;
+	int rv;
+	int mxlen = 4000;
+	char *buf = kmalloc(mxlen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+#define PR_IS(a, s)							\
+	len += snprintf(buf + len, mxlen - len,				\
+			"%21s: %10u\n", a, sc->debug.stats.istats.s);
 
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
-		len += snprintf(buf + len, sizeof(buf) - len,
-			"%8s: %10u\n", "RXLP", sc->debug.stats.istats.rxlp);
-		len += snprintf(buf + len, sizeof(buf) - len,
-			"%8s: %10u\n", "RXHP", sc->debug.stats.istats.rxhp);
-		len += snprintf(buf + len, sizeof(buf) - len,
-			"%8s: %10u\n", "WATCHDOG",
-			sc->debug.stats.istats.bb_watchdog);
+		PR_IS("RXLP", rxlp);
+		PR_IS("RXHP", rxhp);
+		PR_IS("WATHDOG", bb_watchdog);
 	} else {
-		len += snprintf(buf + len, sizeof(buf) - len,
-			"%8s: %10u\n", "RX", sc->debug.stats.istats.rxok);
+		PR_IS("RX", rxok);
 	}
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "RXEOL", sc->debug.stats.istats.rxeol);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "RXORN", sc->debug.stats.istats.rxorn);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "TX", sc->debug.stats.istats.txok);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "TXURN", sc->debug.stats.istats.txurn);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "MIB", sc->debug.stats.istats.mib);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "RXPHY", sc->debug.stats.istats.rxphyerr);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "RXKCM", sc->debug.stats.istats.rx_keycache_miss);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "SWBA", sc->debug.stats.istats.swba);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "BMISS", sc->debug.stats.istats.bmiss);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "BNR", sc->debug.stats.istats.bnr);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "CST", sc->debug.stats.istats.cst);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "GTT", sc->debug.stats.istats.gtt);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "TIM", sc->debug.stats.istats.tim);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "CABEND", sc->debug.stats.istats.cabend);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "DTIMSYNC", sc->debug.stats.istats.dtimsync);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "DTIM", sc->debug.stats.istats.dtim);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "TSFOOR", sc->debug.stats.istats.tsfoor);
-	len += snprintf(buf + len, sizeof(buf) - len,
-		"%8s: %10u\n", "TOTAL", sc->debug.stats.istats.total);
-
-
-	if (len > sizeof(buf))
-		len = sizeof(buf);
-
-	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	PR_IS("RXEOL", rxeol);
+	PR_IS("RXORN", rxorn);
+	PR_IS("TX", txok);
+	PR_IS("TXURN", txurn);
+	PR_IS("MIB", mib);
+	PR_IS("RXPHY", rxphyerr);
+	PR_IS("RXKCM", rx_keycache_miss);
+	PR_IS("SWBA", swba);
+	PR_IS("BMISS", bmiss);
+	PR_IS("BNR", bnr);
+	PR_IS("CST", cst);
+	PR_IS("GTT", gtt);
+	PR_IS("TIM", tim);
+	PR_IS("CABEND", cabend);
+	PR_IS("DTIMSYNC", dtimsync);
+	PR_IS("DTIM", dtim);
+	PR_IS("TSFOOR", tsfoor);
+	PR_IS("TOTAL", total);
+
+	len += snprintf(buf + len, mxlen - len,
+			"SYNC_CAUSE stats:\n");
+
+	PR_IS("Sync-All", sync_cause_all);
+	PR_IS("RTC-IRQ", sync_rtc_irq);
+	PR_IS("MAC-IRQ", sync_mac_irq);
+	PR_IS("EEPROM-Illegal-Access", eeprom_illegal_access);
+	PR_IS("APB-Timeout", apb_timeout);
+	PR_IS("PCI-Mode-Conflict", pci_mode_conflict);
+	PR_IS("HOST1-Fatal", host1_fatal);
+	PR_IS("HOST1-Perr", host1_perr);
+	PR_IS("TRCV-FIFO-Perr", trcv_fifo_perr);
+	PR_IS("RADM-CPL-EP", radm_cpl_ep);
+	PR_IS("RADM-CPL-DLLP-Abort", radm_cpl_dllp_abort);
+	PR_IS("RADM-CPL-TLP-Abort", radm_cpl_tlp_abort);
+	PR_IS("RADM-CPL-ECRC-Err", radm_cpl_ecrc_err);
+	PR_IS("RADM-CPL-Timeout", radm_cpl_timeout);
+	PR_IS("Local-Bus-Timeout", local_timeout);
+	PR_IS("PM-Access", pm_access);
+	PR_IS("MAC-Awake", mac_awake);
+	PR_IS("MAC-Asleep", mac_asleep);
+	PR_IS("MAC-Sleep-Access", mac_sleep_access);
+
+	if (len > mxlen)
+		len = mxlen;
+
+	rv = simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	kfree(buf);
+	return rv;
 }
 
 static const struct file_operations fops_interrupt = {
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/ath/ath9k/debug.h
index 17f6cc2..c34da09 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -60,6 +60,7 @@ struct ath_buf;
  * @tsfoor: TSF out of range, indicates that the corrected TSF received
  * from a beacon differs from the PCU's internal TSF by more than a
  * (programmable) threshold
+ * @local_timeout: Internal bus timeout.
  */
 struct ath_interrupt_stats {
 	u32 total;
@@ -85,8 +86,30 @@ struct ath_interrupt_stats {
 	u32 dtim;
 	u32 bb_watchdog;
 	u32 tsfoor;
+
+	/* Sync-cause stats */
+	u32 sync_cause_all;
+	u32 sync_rtc_irq;
+	u32 sync_mac_irq;
+	u32 eeprom_illegal_access;
+	u32 apb_timeout;
+	u32 pci_mode_conflict;
+	u32 host1_fatal;
+	u32 host1_perr;
+	u32 trcv_fifo_perr;
+	u32 radm_cpl_ep;
+	u32 radm_cpl_dllp_abort;
+	u32 radm_cpl_tlp_abort;
+	u32 radm_cpl_ecrc_err;
+	u32 radm_cpl_timeout;
+	u32 local_timeout;
+	u32 pm_access;
+	u32 mac_awake;
+	u32 mac_asleep;
+	u32 mac_sleep_access;
 };
 
+
 /**
  * struct ath_tx_stats - Statistics about TX
  * @tx_pkts_all:  No. of total frames transmitted, including ones that
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index d1345a8..61b2157 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -24,6 +24,8 @@
 #include "rc.h"
 #include "ar9003_mac.h"
 #include "ar9003_mci.h"
+#include "debug.h"
+#include "ath9k.h"
 
 static bool ath9k_hw_set_reset_reg(struct ath_hw *ah, u32 type);
 
@@ -83,6 +85,53 @@ static void ath9k_hw_ani_cache_ini_regs(struct ath_hw *ah)
 /* Helper Functions */
 /********************/
 
+#ifdef CONFIG_ATH9K_DEBUGFS
+
+void ath9k_debug_sync_cause(struct ath_common *common, u32 sync_cause)
+{
+	struct ath_softc *sc = common->priv;
+	if (sync_cause)
+		sc->debug.stats.istats.sync_cause_all++;
+	if (sync_cause & AR_INTR_SYNC_RTC_IRQ)
+		sc->debug.stats.istats.sync_rtc_irq++;
+	if (sync_cause & AR_INTR_SYNC_MAC_IRQ)
+		sc->debug.stats.istats.sync_mac_irq++;
+	if (sync_cause & AR_INTR_SYNC_EEPROM_ILLEGAL_ACCESS)
+		sc->debug.stats.istats.eeprom_illegal_access++;
+	if (sync_cause & AR_INTR_SYNC_APB_TIMEOUT)
+		sc->debug.stats.istats.apb_timeout++;
+	if (sync_cause & AR_INTR_SYNC_PCI_MODE_CONFLICT)
+		sc->debug.stats.istats.pci_mode_conflict++;
+	if (sync_cause & AR_INTR_SYNC_HOST1_FATAL)
+		sc->debug.stats.istats.host1_fatal++;
+	if (sync_cause & AR_INTR_SYNC_HOST1_PERR)
+		sc->debug.stats.istats.host1_perr++;
+	if (sync_cause & AR_INTR_SYNC_TRCV_FIFO_PERR)
+		sc->debug.stats.istats.trcv_fifo_perr++;
+	if (sync_cause & AR_INTR_SYNC_RADM_CPL_EP)
+		sc->debug.stats.istats.radm_cpl_ep++;
+	if (sync_cause & AR_INTR_SYNC_RADM_CPL_DLLP_ABORT)
+		sc->debug.stats.istats.radm_cpl_dllp_abort++;
+	if (sync_cause & AR_INTR_SYNC_RADM_CPL_TLP_ABORT)
+		sc->debug.stats.istats.radm_cpl_tlp_abort++;
+	if (sync_cause & AR_INTR_SYNC_RADM_CPL_ECRC_ERR)
+		sc->debug.stats.istats.radm_cpl_ecrc_err++;
+	if (sync_cause & AR_INTR_SYNC_RADM_CPL_TIMEOUT)
+		sc->debug.stats.istats.radm_cpl_timeout++;
+	if (sync_cause & AR_INTR_SYNC_LOCAL_TIMEOUT)
+		sc->debug.stats.istats.local_timeout++;
+	if (sync_cause & AR_INTR_SYNC_PM_ACCESS)
+		sc->debug.stats.istats.pm_access++;
+	if (sync_cause & AR_INTR_SYNC_MAC_AWAKE)
+		sc->debug.stats.istats.mac_awake++;
+	if (sync_cause & AR_INTR_SYNC_MAC_ASLEEP)
+		sc->debug.stats.istats.mac_asleep++;
+	if (sync_cause & AR_INTR_SYNC_MAC_SLEEP_ACCESS)
+		sc->debug.stats.istats.mac_sleep_access++;
+}
+#endif
+
+
 static void ath9k_hw_set_clockrate(struct ath_hw *ah)
 {
 	struct ieee80211_conf *conf = &ath9k_hw_common(ah)->hw->conf;
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index aa1680a..fba99ef 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -965,6 +965,12 @@ bool ath9k_hw_check_alive(struct ath_hw *ah);
 
 bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode);
 
+#ifdef CONFIG_ATH9K_DEBUGFS
+void ath9k_debug_sync_cause(struct ath_common *common, u32 sync_cause);
+#else
+static void ath9k_debug_sync_cause(struct ath_common *common, u32 sync_cause) {}
+#endif
+
 /* Generic hw timer primitives */
 struct ath_gen_timer *ath_gen_timer_alloc(struct ath_hw *ah,
 					  void (*trigger)(void *),
-- 
1.7.3.4
