From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20net/phy=3A=20fix=20DP83865=20phy=20interrupt=20handler?=
Date: Tue, 23 Aug 2011 09:07:14 +0200
Message-ID: <1314083234-20361-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Thorsten Schubert <tshu@msc-ge.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:41752 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750748Ab1HWHH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 03:07:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the DP83865 datasheet we need to clear
the interrupt status bit by writing a 1 to the
corresponding bit in INT_CLEAR (2:0 are reserved).

Proposed and tested by Thorsten.

Signed-off-by: Thorsten Schubert <tshu@msc-ge.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/national.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 0620ba9..04bb8fc 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -25,8 +25,9 @@
 /* DP83865 phy identifier values */
 #define DP83865_PHY_ID	0x20005c7a
=20
-#define DP83865_INT_MASK_REG 0x15
-#define DP83865_INT_MASK_STATUS 0x14
+#define DP83865_INT_STATUS	0x14
+#define DP83865_INT_MASK	0x15
+#define DP83865_INT_CLEAR	0x17
=20
 #define DP83865_INT_REMOTE_FAULT 0x0008
 #define DP83865_INT_ANE_COMPLETED 0x0010
@@ -68,21 +69,25 @@ static int ns_config_intr(struct phy_device *phydev=
)
 	int err;
=20
 	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
-		err =3D phy_write(phydev, DP83865_INT_MASK_REG,
+		err =3D phy_write(phydev, DP83865_INT_MASK,
 				DP83865_INT_MASK_DEFAULT);
 	else
-		err =3D phy_write(phydev, DP83865_INT_MASK_REG, 0);
+		err =3D phy_write(phydev, DP83865_INT_MASK, 0);
=20
 	return err;
 }
=20
 static int ns_ack_interrupt(struct phy_device *phydev)
 {
-	int ret =3D phy_read(phydev, DP83865_INT_MASK_STATUS);
+	int ret =3D phy_read(phydev, DP83865_INT_STATUS);
 	if (ret < 0)
 		return ret;
=20
-	return 0;
+	/* Clear the interrupt status bit by writing a =E2=80=9C1=E2=80=9D
+	 * to the corresponding bit in INT_CLEAR (2:0 are reserved) */
+	ret =3D phy_write(phydev, DP83865_INT_CLEAR, ret & ~0x7);
+
+	return ret;
 }
=20
 static void ns_giga_speed_fallback(struct phy_device *phydev, int mode=
)
--=20
1.7.4.4

