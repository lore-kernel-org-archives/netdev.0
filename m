From: Jon Mason <jdmason@kudzu.us>
Subject: [RFC 2/3] tg3: Use pci_set_power_state() for setting PM states
Date: Mon, 24 Feb 2014 15:34:04 -0700
Message-ID: <1393281245-3951-2-git-send-email-jdmason@kudzu.us>
References: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36018 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbaBXWeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 17:34:37 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so7221393pab.1
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 14:34:37 -0800 (PST)
In-Reply-To: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing infrastructure of pci_set_power_state() instead of
setting the relevant bits via PCI config read/write in the driver.
Also, use pci_pme_active() to set the PCI_PM_CTRL_PME_ENABLE bit in PCI
PM control register.  pci_set_power_state() and pci_pme_active() perform
the same operations as the driver did before, so there should be no
functional change.  That being said, this has not been tested.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3167ed6..36c3fd9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -16362,22 +16362,14 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 		 * for all chip writes not to mailbox registers.
 		 */
 		if (tg3_flag(tp, PCIX_MODE)) {
-			u32 pm_reg;
-
 			tg3_flag_set(tp, PCIX_TARGET_HWBUG);
 
 			/* The chip can have it's power management PCI config
 			 * space registers clobbered due to this bug.
 			 * So explicitly force the chip into D0 here.
 			 */
-			pci_read_config_dword(tp->pdev,
-					      tp->pdev->pm_cap + PCI_PM_CTRL,
-					      &pm_reg);
-			pm_reg &= ~PCI_PM_CTRL_STATE_MASK;
-			pm_reg |= PCI_PM_CTRL_PME_ENABLE | 0 /* D0 */;
-			pci_write_config_dword(tp->pdev,
-					       tp->pdev->pm_cap + PCI_PM_CTRL,
-					       pm_reg);
+			pci_set_power_state(tp->pdev, PCI_D0);
+			pci_pme_active(tp->pdev, true);
 
 			/* Also, force SERR#/PERR# in PCI command. */
 			pci_read_config_word(tp->pdev, PCI_COMMAND, &pci_cmd);
-- 
1.8.3.2
