From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next] tg3: Update link_up flag for phylib devices
Date: Thu, 7 Mar 2013 18:45:27 -0800
Message-ID: <1362710727-15438-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hirofumi@mail.parknet.co.jp,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3211 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933068Ab3CHCq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 21:46:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f4a46d1f46a8fece34edd2023e054072b02e110d introduced a bug where
the ifconfig stats would remain 0 for phylib devices. This is due to
tp->link_up flag never becoming true causing tg3_periodic_fetch_stats()
to return.

The link_up flag was being updated in tg3_test_and_report_link_chg()
after setting up the phy. This function however, is not called for
phylib devices since the driver does not do the phy setup.

This patch moves the link_up flag update into the common
tg3_link_report() function that gets called for phylib devices as well
for non phylib devices when the link state changes.

To avoid updating link_up twice, we replace tg3_carrier_...() calls that
are followed by tg3_link_report(), with netif_carrier_...(). We can then
remove the unused tg3_carrier_on() function.

Reported-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2b2bee6..0c1a2ef 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1870,6 +1870,8 @@ static void tg3_link_report(struct tg3 *tp)
 
 		tg3_ump_link_report(tp);
 	}
+
+	tp->link_up = netif_carrier_ok(tp->dev);
 }
 
 static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
@@ -2523,12 +2525,6 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	return err;
 }
 
-static void tg3_carrier_on(struct tg3 *tp)
-{
-	netif_carrier_on(tp->dev);
-	tp->link_up = true;
-}
-
 static void tg3_carrier_off(struct tg3 *tp)
 {
 	netif_carrier_off(tp->dev);
@@ -2554,7 +2550,7 @@ static int tg3_phy_reset(struct tg3 *tp)
 		return -EBUSY;
 
 	if (netif_running(tp->dev) && tp->link_up) {
-		tg3_carrier_off(tp);
+		netif_carrier_off(tp->dev);
 		tg3_link_report(tp);
 	}
 
@@ -4403,9 +4399,9 @@ static bool tg3_test_and_report_link_chg(struct tg3 *tp, int curr_link_up)
 {
 	if (curr_link_up != tp->link_up) {
 		if (curr_link_up) {
-			tg3_carrier_on(tp);
+			netif_carrier_on(tp->dev);
 		} else {
-			tg3_carrier_off(tp);
+			netif_carrier_off(tp->dev);
 			if (tp->phy_flags & TG3_PHYFLG_MII_SERDES)
 				tp->phy_flags &= ~TG3_PHYFLG_PARALLEL_DETECT;
 		}
-- 
1.8.1.4
