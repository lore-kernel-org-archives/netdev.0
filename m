From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4 net-next] tg3: Improve PCI function number
 detection.
Date: Sun, 6 Jan 2013 14:51:09 -0800
Message-ID: <1357512670-17636-3-git-send-email-mchan@broadcom.com>
References: <1357512670-17636-1-git-send-email-mchan@broadcom.com>
 <1357512670-17636-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1981 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab3AFWfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 17:35:06 -0500
In-Reply-To: <1357512670-17636-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the code to detect PCI function number on 5717, 5719, and 5720.
If shared memory does not have proper signature, read the function number
from register directly.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6eab7d7..3596b7b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15441,21 +15441,18 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 					      &val);
 			tp->pci_fn = val & 0x7;
 		}
-	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		tg3_read_mem(tp, NIC_SRAM_CPMU_STATUS, &val);
-		if ((val & NIC_SRAM_CPMUSTAT_SIG_MSK) ==
-		    NIC_SRAM_CPMUSTAT_SIG) {
-			tp->pci_fn = val & TG3_CPMU_STATUS_FMSK_5717;
-			tp->pci_fn = tp->pci_fn ? 1 : 0;
-		}
-	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 		tg3_read_mem(tp, NIC_SRAM_CPMU_STATUS, &val);
-		if ((val & NIC_SRAM_CPMUSTAT_SIG_MSK) ==
-		    NIC_SRAM_CPMUSTAT_SIG) {
+		if ((val & NIC_SRAM_CPMUSTAT_SIG_MSK) != NIC_SRAM_CPMUSTAT_SIG)
+			val = tr32(TG3_CPMU_STATUS);
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+			tp->pci_fn = (val & TG3_CPMU_STATUS_FMSK_5717) ? 1 : 0;
+		else
 			tp->pci_fn = (val & TG3_CPMU_STATUS_FMSK_5719) >>
 				     TG3_CPMU_STATUS_FSHFT_5719;
-		}
 	}
 
 	/* Get eeprom hw config before calling tg3_set_power_state().
-- 
1.7.1
