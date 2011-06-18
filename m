From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH #3 net-next 4/4] r8169: check firmware content sooner.
Date: Sat, 18 Jun 2011 13:27:23 +0200
Message-ID: <20110618112723.GE2573@electric-eye.fr.zoreil.com>
References: <20110618112605.GA2573@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52936 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621Ab1FRLlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 07:41:08 -0400
Content-Disposition: inline
In-Reply-To: <20110618112605.GA2573@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware checking is only performed when the firmware is loaded
instead of each time the driver inits the phy.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   63 +++++++++++++++++++++++++++++++++++---------------
 1 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7074989..bc5bb37 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1815,18 +1815,12 @@ out:
 	return rc;
 }
 
-static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+static bool rtl_fw_data_ok(struct rtl8169_private *tp, struct net_device *dev,
+			   struct rtl_fw_phy_action *pa)
 {
-	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
-	struct net_device *dev = tp->dev;
-	u32 predata, count;
+	bool rc = false;
 	size_t index;
 
-	if (!rtl_fw_format_ok(tp, rtl_fw)) {
-		netif_err(tp, probe, dev, "invalid firwmare\n");
-		return;
-	}
-
 	for (index = 0; index < pa->size; index++) {
 		u32 action = le32_to_cpu(pa->code[index]);
 		u32 regno = (action & 0x0fff0000) >> 16;
@@ -1844,25 +1838,25 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 
 		case PHY_BJMPN:
 			if (regno > index) {
-				netif_err(tp, probe, tp->dev,
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
 			if (index + 2 >= pa->size) {
-				netif_err(tp, probe, tp->dev,
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 		case PHY_COMP_EQ_SKIPN:
 		case PHY_COMP_NEQ_SKIPN:
 		case PHY_SKIPN:
 			if (index + 1 + regno >= pa->size) {
-				netif_err(tp, probe, tp->dev,
+				netif_err(tp, ifup, tp->dev,
 					  "Out of range of firmware\n");
-				return;
+				goto out;
 			}
 			break;
 
@@ -1870,14 +1864,39 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 		case PHY_WRITE_MAC_BYTE:
 		case PHY_WRITE_ERI_WORD:
 		default:
-			netif_err(tp, probe, tp->dev,
+			netif_err(tp, ifup, tp->dev,
 				  "Invalid action 0x%08x\n", action);
-			return;
+			goto out;
 		}
 	}
+	rc = true;
+out:
+	return rc;
+}
 
-	predata = 0;
-	count = 0;
+static int rtl_check_firmware(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct net_device *dev = tp->dev;
+	int rc = -EINVAL;
+
+	if (!rtl_fw_format_ok(tp, rtl_fw)) {
+		netif_err(tp, ifup, dev, "invalid firwmare\n");
+		goto out;
+	}
+
+	if (rtl_fw_data_ok(tp, dev, &rtl_fw->phy_action))
+		rc = 0;
+out:
+	return rc;
+}
+
+static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	u32 predata, count;
+	size_t index;
+
+	predata = count = 0;
 
 	for (index = 0; index < pa->size; ) {
 		u32 action = le32_to_cpu(pa->code[index]);
@@ -3605,10 +3624,16 @@ static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
 	if (rc < 0)
 		goto err_free;
 
+	rc = rtl_check_firmware(tp, rtl_fw);
+	if (rc < 0)
+		goto err_release_firmware;
+
 	tp->rtl_fw = rtl_fw;
 out:
 	return;
 
+err_release_firmware:
+	release_firmware(rtl_fw->fw);
 err_free:
 	kfree(rtl_fw);
 err_warn:
-- 
1.7.4.4

