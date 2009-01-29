From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/20] sfc: Reinitialise the PHY completely in case of a
	PHY or NIC reset
Date: Thu, 29 Jan 2009 19:19:34 +0000
Message-ID: <1233256774.3656.29.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60720 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753552AbZA2TTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:19:37 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFFrom: Steve Hodgson <shodgson@solarflare.com>

In particular, set pause advertising bits properly.

A PHY reset is not necessary to recover from the register self-test,
so use a "invisible" reset there instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c       |   26 +++++++++++++++++++-------
 drivers/net/sfc/efx.h       |    7 ++++---
 drivers/net/sfc/selftest.c  |    7 ++++---
 drivers/net/sfc/tenxpress.c |    1 +
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7673fd9..b0e5308 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -676,9 +676,8 @@ static int efx_init_port(struct efx_nic *efx)
 	rc =3D efx->phy_op->init(efx);
 	if (rc)
 		return rc;
-	efx->phy_op->reconfigure(efx);
-
 	mutex_lock(&efx->mac_lock);
+	efx->phy_op->reconfigure(efx);
 	rc =3D falcon_switch_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 	if (rc)
@@ -1622,7 +1621,8 @@ static void efx_unregister_netdev(struct efx_nic =
*efx)
=20
 /* Tears down the entire software state and most of the hardware state
  * before reset.  */
-void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+void efx_reset_down(struct efx_nic *efx, enum reset_type method,
+		    struct ethtool_cmd *ecmd)
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
@@ -1639,6 +1639,8 @@ void efx_reset_down(struct efx_nic *efx, struct e=
thtool_cmd *ecmd)
 	efx->phy_op->get_settings(efx, ecmd);
=20
 	efx_fini_channels(efx);
+	if (efx->port_initialized && method !=3D RESET_TYPE_INVISIBLE)
+		efx->phy_op->fini(efx);
 }
=20
 /* This function will always ensure that the locks acquired in
@@ -1646,7 +1648,8 @@ void efx_reset_down(struct efx_nic *efx, struct e=
thtool_cmd *ecmd)
  * that we were unable to reinitialise the hardware, and the
  * driver should be disabled. If ok is false, then the rx and tx
  * engines are not restarted, pending a RESET_DISABLE. */
-int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool o=
k)
+int efx_reset_up(struct efx_nic *efx, enum reset_type method,
+		 struct ethtool_cmd *ecmd, bool ok)
 {
 	int rc;
=20
@@ -1658,6 +1661,15 @@ int efx_reset_up(struct efx_nic *efx, struct eth=
tool_cmd *ecmd, bool ok)
 		ok =3D false;
 	}
=20
+	if (efx->port_initialized && method !=3D RESET_TYPE_INVISIBLE) {
+		if (ok) {
+			rc =3D efx->phy_op->init(efx);
+			if (rc)
+				ok =3D false;
+		} else
+			efx->port_initialized =3D false;
+	}
+
 	if (ok) {
 		efx_init_channels(efx);
=20
@@ -1702,7 +1714,7 @@ static int efx_reset(struct efx_nic *efx)
=20
 	EFX_INFO(efx, "resetting (%d)\n", method);
=20
-	efx_reset_down(efx, &ecmd);
+	efx_reset_down(efx, method, &ecmd);
=20
 	rc =3D falcon_reset_hw(efx, method);
 	if (rc) {
@@ -1721,10 +1733,10 @@ static int efx_reset(struct efx_nic *efx)
=20
 	/* Leave device stopped if necessary */
 	if (method =3D=3D RESET_TYPE_DISABLE) {
-		efx_reset_up(efx, &ecmd, false);
+		efx_reset_up(efx, method, &ecmd, false);
 		rc =3D -EIO;
 	} else {
-		rc =3D efx_reset_up(efx, &ecmd, true);
+		rc =3D efx_reset_up(efx, method, &ecmd, true);
 	}
=20
 out_disable:
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 0dd7a53..ac20158 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -40,9 +40,10 @@ extern void efx_reconfigure_port(struct efx_nic *efx=
);
 extern void __efx_reconfigure_port(struct efx_nic *efx);
=20
 /* Reset handling */
-extern void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ec=
md);
-extern int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
-			bool ok);
+extern void efx_reset_down(struct efx_nic *efx, enum reset_type method=
,
+			   struct ethtool_cmd *ecmd);
+extern int efx_reset_up(struct efx_nic *efx, enum reset_type method,
+			struct ethtool_cmd *ecmd, bool ok);
=20
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type ty=
pe);
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index dba0d64..0a59808 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -665,6 +665,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_se=
lf_tests *tests,
 {
 	enum efx_loopback_mode loopback_mode =3D efx->loopback_mode;
 	int phy_mode =3D efx->phy_mode;
+	enum reset_type reset_method =3D RESET_TYPE_INVISIBLE;
 	struct ethtool_cmd ecmd;
 	struct efx_channel *channel;
 	int rc_test =3D 0, rc_reset =3D 0, rc;
@@ -718,21 +719,21 @@ int efx_selftest(struct efx_nic *efx, struct efx_=
self_tests *tests,
 	mutex_unlock(&efx->mac_lock);
=20
 	/* free up all consumers of SRAM (including all the queues) */
-	efx_reset_down(efx, &ecmd);
+	efx_reset_down(efx, reset_method, &ecmd);
=20
 	rc =3D efx_test_chip(efx, tests);
 	if (rc && !rc_test)
 		rc_test =3D rc;
=20
 	/* reset the chip to recover from the register test */
-	rc_reset =3D falcon_reset_hw(efx, RESET_TYPE_ALL);
+	rc_reset =3D falcon_reset_hw(efx, reset_method);
=20
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
 	efx->phy_mode &=3D ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode =3D LOOPBACK_NONE;
=20
-	rc =3D efx_reset_up(efx, &ecmd, rc_reset =3D=3D 0);
+	rc =3D efx_reset_up(efx, reset_method, &ecmd, rc_reset =3D=3D 0);
 	if (rc && !rc_reset)
 		rc_reset =3D rc;
=20
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index ec3e38b..1ab14d5 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -357,6 +357,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	rc =3D tenxpress_init(efx);
 	if (rc < 0)
 		goto fail;
+	mdio_clause45_set_pause(efx);
=20
 	if (efx->phy_type =3D=3D PHY_TYPE_SFT9001B) {
 		rc =3D device_create_file(&efx->pci_dev->dev,

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

