From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/8] r8169: provide some firmware information via ethtool.
Date: Mon, 9 May 2011 21:06:15 +0200
Message-ID: <20110509190615.GF20687@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com> <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>,
	Fejes =?utf-8?Q?J=C3=B3zsef?= <fejes@joco.name>,
	Borislav Petkov <borislav.petkov@amd.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50177 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab1EITQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:16:05 -0400
Content-Disposition: inline
In-Reply-To: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no real firmware version yet but the manpage of ethtool
is rather terse about the driver information.

=46ormer output:
$ ethtool -i eth1
driver: r8169
version: 2.3LK-NAPI
firmware-version:
bus-info: 0000:01:00.0
$ ethtool -i eth0
driver: r8169
version: 2.3LK-NAPI
firmware-version:
bus-info: 0000:03:00.0

Current output:
$ ethtool -i eth1
driver: r8169
version: 2.3LK-NAPI
firmware-version: N/A
bus-info: 0000:01:00.0

$ ethtool -i eth0
driver: r8169
version: 2.3LK-NAPI
firmware-version: rtl_nic/rtl8168d-1.fw
bus-info: 0000:03:00.0

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
=46ixed-by Ciprian Docan <docan@eden.rutgers.edu>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: Fejes J=C3=B3zsef <fejes@joco.name>
Cc: Borislav Petkov <borislav.petkov@amd.com>
---
 drivers/net/r8169.c |   45 +++++++++++++++++++++++++------------------=
--
 1 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 81906bc..83e5202 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1188,6 +1188,19 @@ static int rtl8169_set_wol(struct net_device *de=
v, struct ethtool_wolinfo *wol)
 	return 0;
 }
=20
+static const char *rtl_lookup_firmware_name(struct rtl8169_private *tp=
)
+{
+	int i;
+
+	for (i =3D 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
+		const struct rtl_firmware_info *info =3D rtl_firmware_infos + i;
+
+		if (info->mac_version =3D=3D tp->mac_version)
+			return info->fw_name;
+	}
+	return NULL;
+}
+
 static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -1196,6 +1209,8 @@ static void rtl8169_get_drvinfo(struct net_device=
 *dev,
 	strcpy(info->driver, MODULENAME);
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
+		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
 }
=20
 static int rtl8169_get_regs_len(struct net_device *dev)
@@ -3491,33 +3506,23 @@ static void __devexit rtl8169_remove_one(struct=
 pci_dev *pdev)
=20
 static void rtl_request_firmware(struct rtl8169_private *tp)
 {
-	int i;
-
 	/* Return early if the firmware is already loaded / cached. */
-	if (!IS_ERR(tp->fw))
-		goto out;
-
-	for (i =3D 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
-		const struct rtl_firmware_info *info =3D rtl_firmware_infos + i;
+	if (IS_ERR(tp->fw)) {
+		const char *name;
=20
-		if (info->mac_version =3D=3D tp->mac_version) {
-			const char *name =3D info->fw_name;
+		name =3D rtl_lookup_firmware_name(tp);
+		if (name) {
 			int rc;
=20
 			rc =3D request_firmware(&tp->fw, name, &tp->pci_dev->dev);
-			if (rc < 0) {
-				netif_warn(tp, ifup, tp->dev, "unable to load "
-					"firmware patch %s (%d)\n", name, rc);
-				goto out_disable_request_firmware;
-			}
-			goto out;
+			if (rc >=3D 0)
+				return;
+
+			netif_warn(tp, ifup, tp->dev, "unable to load "
+				"firmware patch %s (%d)\n", name, rc);
 		}
+		tp->fw =3D NULL;
 	}
-
-out_disable_request_firmware:
-	tp->fw =3D NULL;
-out:
-	return;
 }
=20
 static int rtl8169_open(struct net_device *dev)
--=20
1.7.4.4

