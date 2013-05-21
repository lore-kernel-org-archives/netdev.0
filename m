From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/2] tg3: Ensure boot code has completed
 initialization before accessing hardware
Date: Tue, 21 May 2013 15:57:32 -0700
Message-ID: <1369177053-7117-2-git-send-email-nsujir@broadcom.com>
References: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1666 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753818Ab3EUW5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:57:47 -0400
In-Reply-To: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resetting the device, the driver waits for a signature to be
updated to know that firmware has completed initialization. However, the
call to tg3_poll_fw() is being done too late and we're writing to the
GRC_MODE register before it has completely initialized, causing
contention with firmware.  This logic has existed since day one but is
causing PCIE link to go down randomly at startup on one platform once
every few hundred reboots.

Move the tg3_poll_fw() up to before we write to the GRC_MODE register
after reset.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fb06aa1..6ba031b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8956,6 +8956,10 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tg3_halt_cpu(tp, RX_CPU_BASE);
 	}
 
+	err = tg3_poll_fw(tp);
+	if (err)
+		return err;
+
 	tw32(GRC_MODE, tp->grc_mode);
 
 	if (tg3_chip_rev_id(tp) == CHIPREV_ID_5705_A0) {
@@ -8986,10 +8990,6 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_ape_unlock(tp, TG3_APE_LOCK_GRC);
 
-	err = tg3_poll_fw(tp);
-	if (err)
-		return err;
-
 	tg3_mdio_start(tp);
 
 	if (tg3_flag(tp, PCI_EXPRESS) &&
-- 
1.8.1.4
