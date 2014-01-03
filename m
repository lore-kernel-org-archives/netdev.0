From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 4/5] tg3: Poll cpmu link state on APE + ASF enabled devices
Date: Fri, 3 Jan 2014 10:09:14 -0800
Message-ID: <1388772555-916-5-git-send-email-nsujir@broadcom.com>
References: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64862 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbaACSJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:09:28 -0500
In-Reply-To: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ASF enabled devices where the mgmt firmware runs on the application
processing engine, there is a race between the tg3 driver processing a
link change event and the ASF firmware clearing the link changed bit in
the EMAC status register. This leads to link notifications to the driver
sometimes getting lost.

Poll the CPMU link state as a backup for the normal interrupt path
update if ASF is enabled.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 10 ++++++++++
 drivers/net/ethernet/broadcom/tg3.h |  2 ++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7bc8449..8f43c67 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10960,6 +10960,13 @@ static void tg3_timer(unsigned long __opaque)
 		} else if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
 			   tg3_flag(tp, 5780_CLASS)) {
 			tg3_serdes_parallel_detect(tp);
+		} else if (tg3_flag(tp, POLL_CPMU_LINK)) {
+			u32 cpmu = tr32(TG3_CPMU_STATUS);
+			bool link_up = !((cpmu & TG3_CPMU_STATUS_LINK_MASK) ==
+					 TG3_CPMU_STATUS_LINK_MASK);
+
+			if (link_up != tp->link_up)
+				tg3_setup_phy(tp, false);
 		}
 
 		tp->timer_counter = tp->timer_multiplier;
@@ -16766,6 +16773,9 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 	else
 		tg3_flag_clear(tp, POLL_SERDES);
 
+	if (tg3_flag(tp, ENABLE_APE) && tg3_flag(tp, ENABLE_ASF))
+		tg3_flag_set(tp, POLL_CPMU_LINK);
+
 	tp->rx_offset = NET_SKB_PAD + NET_IP_ALIGN;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (tg3_asic_rev(tp) == ASIC_REV_5701 &&
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 9e31ecc..ef47238 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1153,6 +1153,7 @@
 #define  TG3_CPMU_STATUS_FMSK_5717	 0x20000000
 #define  TG3_CPMU_STATUS_FMSK_5719	 0xc0000000
 #define  TG3_CPMU_STATUS_FSHFT_5719	 30
+#define  TG3_CPMU_STATUS_LINK_MASK	 0x180000
 
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
@@ -3020,6 +3021,7 @@ enum TG3_FLAGS {
 	TG3_FLAG_ENABLE_ASF,
 	TG3_FLAG_ASPM_WORKAROUND,
 	TG3_FLAG_POLL_SERDES,
+	TG3_FLAG_POLL_CPMU_LINK,
 	TG3_FLAG_MBOX_WRITE_REORDER,
 	TG3_FLAG_PCIX_TARGET_HWBUG,
 	TG3_FLAG_WOL_SPEED_100MB,
-- 
1.8.1.4
