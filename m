From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sfc: lower stack usage in efx_ethtool_self_test
Date: Wed, 16 Feb 2011 14:48:38 +0100
Message-ID: <1297864118.3201.354.camel@edumazet-laptop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35739 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab1BPNso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 08:48:44 -0500
Received: by fxm20 with SMTP id 20so1390821fxm.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 05:48:43 -0800 (PST)
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/sfc/ethtool.c: In function =E2=80=98efx_ethtool_self_test=E2=
=80=99:
drivers/net/sfc/ethtool.c:613: warning: the frame size of 1200 bytes
is larger than 1024 bytes

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/sfc/ethtool.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 272cfe7..0836b37 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -569,9 +569,14 @@ static void efx_ethtool_self_test(struct net_devic=
e *net_dev,
 				  struct ethtool_test *test, u64 *data)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
-	struct efx_self_tests efx_tests;
+	struct efx_self_tests *efx_tests;
 	int already_up;
-	int rc;
+	int rc =3D -ENOMEM;
+
+	efx_tests =3D kzalloc(sizeof(*efx_tests), GFP_KERNEL);
+	if (!efx_tests)
+		goto fail;
+
=20
 	ASSERT_RTNL();
 	if (efx->state !=3D STATE_RUNNING) {
@@ -589,13 +594,11 @@ static void efx_ethtool_self_test(struct net_devi=
ce *net_dev,
 		if (rc) {
 			netif_err(efx, drv, efx->net_dev,
 				  "failed opening device.\n");
-			goto fail2;
+			goto fail1;
 		}
 	}
=20
-	memset(&efx_tests, 0, sizeof(efx_tests));
-
-	rc =3D efx_selftest(efx, &efx_tests, test->flags);
+	rc =3D efx_selftest(efx, efx_tests, test->flags);
=20
 	if (!already_up)
 		dev_close(efx->net_dev);
@@ -604,10 +607,11 @@ static void efx_ethtool_self_test(struct net_devi=
ce *net_dev,
 		   rc =3D=3D 0 ? "passed" : "failed",
 		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
=20
- fail2:
- fail1:
+fail1:
 	/* Fill ethtool results structures */
-	efx_ethtool_fill_self_tests(efx, &efx_tests, NULL, data);
+	efx_ethtool_fill_self_tests(efx, efx_tests, NULL, data);
+	kfree(efx_tests);
+fail:
 	if (rc)
 		test->flags |=3D ETH_TEST_FL_FAILED;
 }


