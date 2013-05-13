From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net 1/2] tg3: Skip powering down function 0 on certain
 serdes devices
Date: Mon, 13 May 2013 11:03:46 -0700
Message-ID: <1368468227-18710-2-git-send-email-nsujir@broadcom.com>
References: <1368468227-18710-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	stable@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368468227-18710-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the 5718, 5719 and 5720 serdes devices, powering down function 0
results in all the other ports being powered down. Add code to skip
function 0 power down.

Cc: <stable@vger.kernel.org>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 728d42a..737f035 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2957,6 +2957,23 @@ static int tg3_5700_link_polarity(struct tg3 *tp, u32 speed)
 	return 0;
 }
 
+static bool tg3_phy_power_bug(struct tg3 *tp)
+{
+	if (tg3_asic_rev(tp) == ASIC_REV_5700 ||
+	    tg3_asic_rev(tp) == ASIC_REV_5704 ||
+	    (tg3_asic_rev(tp) == ASIC_REV_5780 &&
+	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)) ||
+	    (tg3_asic_rev(tp) == ASIC_REV_5717 &&
+	     !tp->pci_fn) ||
+	    ((tg3_asic_rev(tp) == ASIC_REV_5719 ||
+	      tg3_asic_rev(tp) == ASIC_REV_5720) &&
+	     (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
+	     !tp->pci_fn))
+		return true;
+
+	return false;
+}
+
 static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
 	u32 val;
@@ -3016,12 +3033,7 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 	/* The PHY should not be powered down on some chips because
 	 * of bugs.
 	 */
-	if (tg3_asic_rev(tp) == ASIC_REV_5700 ||
-	    tg3_asic_rev(tp) == ASIC_REV_5704 ||
-	    (tg3_asic_rev(tp) == ASIC_REV_5780 &&
-	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)) ||
-	    (tg3_asic_rev(tp) == ASIC_REV_5717 &&
-	     !tp->pci_fn))
+	if (tg3_phy_power_bug(tp))
 		return;
 
 	if (tg3_chip_rev(tp) == CHIPREV_5784_AX ||
-- 
1.8.1.4
