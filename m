From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/6] tg3: Call netif_carrier_off() during phy reset
Date: Fri, 28 Apr 2006 16:35:06 -0700
Message-ID: <1146267307.4780.14.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:61194 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932464AbWD2BPP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:15:15 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add netif_carrier_off() call during tg3_phy_reset(). This is needed
to properly track the netif_carrier state in cases where we do a
PHY reset with interrupts disabled. The SerDes code will not run
properly if the netif_carrier state is wrong.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 73e271e..a28accb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -974,6 +974,8 @@ static int tg3_phy_reset_5703_4_5(struct
 	return err;
 }
 
+static void tg3_link_report(struct tg3 *);
+
 /* This will reset the tigon3 PHY if there is no valid
  * link unless the FORCE argument is non-zero.
  */
@@ -987,6 +989,11 @@ static int tg3_phy_reset(struct tg3 *tp)
 	if (err != 0)
 		return -EBUSY;
 
+	if (netif_running(tp->dev) && netif_carrier_ok(tp->dev)) {
+		netif_carrier_off(tp->dev);
+		tg3_link_report(tp);
+	}
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {


