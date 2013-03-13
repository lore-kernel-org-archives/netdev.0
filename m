From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net] tg3: 5715 does not link up when autoneg off
Date: Tue, 12 Mar 2013 18:32:48 -0700
Message-ID: <1363138368-10651-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcinmiotk81@gmail.com,
	"Nithin Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab3CMBdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 21:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Sujir <nsujir@broadcom.com>

Commit d13ba512cbba7de5d55d7a3b2aae7d83c8921457 cleaned up the autoneg
advertisement by removing some dead code. One effect of this change was that
the advertisement register would not be updated if autoneg is turned off.

This exposed a bug on the 5715 device w.r.t linking. The 5715 defaults
to advertise only 10Mb Full duplex. But with autoneg disabled, it needs
the configured speed enabled in the advertisement register to link up.

This patch adds the work around to advertise all speeds on the 5715 when
autoneg is disabled.

Reported-by: Marcin Miotk <marcinmiotk81@gmail.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 93729f9..67d2663 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4130,6 +4130,14 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		tp->link_config.active_speed = tp->link_config.speed;
 		tp->link_config.active_duplex = tp->link_config.duplex;
 
+		if (tg3_asic_rev(tp) == ASIC_REV_5714) {
+			/* With autoneg disabled, 5715 only links up when the
+			 * advertisement register has the configured speed
+			 * enabled.
+			 */
+			tg3_writephy(tp, MII_ADVERTISE, ADVERTISE_ALL);
+		}
+
 		bmcr = 0;
 		switch (tp->link_config.speed) {
 		default:
-- 
1.8.1.4
