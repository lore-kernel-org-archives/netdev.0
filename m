From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] phy: fix EEE checks inside the phy_init_eee.
Date: Tue, 26 Aug 2014 09:26:52 +0200
Message-ID: <1409038012-11574-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Nandini Sharma <nandini.sharma@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:48970 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755391AbaHZH1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:27:02 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q7K6cs002819
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:27:01 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hrgs3hq-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:27:01 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6AF843D
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:26:50 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D50B315EF3
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:26:57 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the Std 802.3az if the EEE Adv (Reg 7.60), Link partner ability
(Reg 7.61) and EEE capability (Register 3.20) bits return 0 this  means no EEE
is supported. So this patch fixes the checks inside the phy_init_eee function.

Signed-off-by: Nandini Sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/phy.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c94e2a2..a854d38 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1036,31 +1036,31 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		/* First check if the EEE ability is supported */
 		eee_cap = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
 						MDIO_MMD_PCS, phydev->addr);
-		if (eee_cap < 0)
-			return eee_cap;
+		if (eee_cap <= 0)
+			goto eee_exit_err;
 
 		cap = mmd_eee_cap_to_ethtool_sup_t(eee_cap);
 		if (!cap)
-			return -EPROTONOSUPPORT;
+			goto eee_exit_err;
 
 		/* Check which link settings negotiated and verify it in
 		 * the EEE advertising registers.
 		 */
 		eee_lp = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
 					       MDIO_MMD_AN, phydev->addr);
-		if (eee_lp < 0)
-			return eee_lp;
+		if (eee_lp <= 0)
+			goto eee_exit_err;
 
 		eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
 						MDIO_MMD_AN, phydev->addr);
-		if (eee_adv < 0)
-			return eee_adv;
+		if (eee_adv <= 0)
+			goto eee_exit_err;
 
 		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
 		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
 		idx = phy_find_setting(phydev->speed, phydev->duplex);
 		if (!(lp & adv & settings[idx].setting))
-			return -EPROTONOSUPPORT;
+			goto eee_exit_err;
 
 		if (clk_stop_enable) {
 			/* Configure the PHY to stop receiving xMII
@@ -1080,7 +1080,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 
 		return 0; /* EEE supported */
 	}
-
+eee_exit_err:
 	return -EPROTONOSUPPORT;
 }
 EXPORT_SYMBOL(phy_init_eee);
-- 
1.7.4.4
