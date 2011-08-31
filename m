From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Wed, 31 Aug 2011 18:55:07 +0200
Message-ID: <20110831185507.50a1940c@alice>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
	<1314802836-9862-2-git-send-email-mschmidt@redhat.com>
	<201108311816.30468.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Vlad Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756877Ab1HaRpp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 13:45:45 -0400
In-Reply-To: <201108311816.30468.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 18:16:30 +0300 Vlad Zolotarov wrote:
> This is bogus - what if bnx2x_reload_if_running(dev)
> (bnx2x_nic_load()) failes? The original dev->features would be
> lost... Pls., see my latest response on your previouse patch series
> thread.

OK, so the conclusion in the other thread was to restore the features
before returning. Here's an updated patch.


Subject: [PATCH] bnx2x: remove TPA_ENABLE_FLAG

TPA_ENABLE_FLAG is unnecessary, because it mirrors NETIF_F_LRO.

"Cheating" in bnx2x_set_features() was suggested by Micha=C5=82 Miros=C5=
=82aw.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   31 ++++++++++++--=
-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    7 +---
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/=
ethernet/broadcom/bnx2x/bnx2x.h
index 735e491..5d5f323 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1174,7 +1174,7 @@ struct bnx2x {
 #define USING_MSIX_FLAG			(1 << 5)
 #define USING_MSI_FLAG			(1 << 6)
 #define DISABLE_MSI_FLAG		(1 << 7)
-#define TPA_ENABLE_FLAG			(1 << 8)
+
 #define NO_MCP_FLAG			(1 << 9)
=20
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a08b101..399e71c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -62,7 +62,7 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int =
index)
 	 * set the tpa flag for each queue. The tpa flag determines the queue
 	 * minimal size so it must be set prior to queue memory allocation
 	 */
-	fp->disable_tpa =3D ((bp->flags & TPA_ENABLE_FLAG) =3D=3D 0);
+	fp->disable_tpa =3D !(bp->dev->features & NETIF_F_LRO);
=20
 #ifdef BCM_CNIC
 	/* We don't want TPA on an FCoE L2 ring */
@@ -3410,13 +3410,10 @@ u32 bnx2x_fix_features(struct net_device *dev, =
u32 features)
 int bnx2x_set_features(struct net_device *dev, u32 features)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
-	u32 flags =3D bp->flags;
 	bool bnx2x_reload =3D false;
=20
-	if (features & NETIF_F_LRO)
-		flags |=3D TPA_ENABLE_FLAG;
-	else
-		flags &=3D ~TPA_ENABLE_FLAG;
+	if ((features ^ dev->features) & NETIF_F_LRO)
+		bnx2x_reload =3D true;
=20
 	if (features & NETIF_F_LOOPBACK) {
 		if (bp->link_params.loopback_mode !=3D LOOPBACK_BMAC) {
@@ -3430,14 +3427,22 @@ int bnx2x_set_features(struct net_device *dev, =
u32 features)
 		}
 	}
=20
-	if (flags ^ bp->flags) {
-		bp->flags =3D flags;
-		bnx2x_reload =3D true;
-	}
-
 	if (bnx2x_reload) {
-		if (bp->recovery_state =3D=3D BNX2X_RECOVERY_DONE)
-			return bnx2x_reload_if_running(dev);
+		if (bp->recovery_state =3D=3D BNX2X_RECOVERY_DONE) {
+			/*
+			 * Cheat! Normally dev->features will be set after we
+			 * return, but that's too late. We need to know how to
+			 * configure the NIC when reloading it, so copy the
+			 * features beforehand. Restore them after reload to
+			 * avoid any possible confusion of the caller.
+			 */
+			int ret;
+			u32 orig_features =3D dev->features;
+			dev->features =3D features;
+			ret =3D bnx2x_reload_if_running(dev);
+			dev->features =3D orig_features;
+			return ret;
+		}
 		/* else: bnx2x_nic_load() will be called at end of recovery */
 	}
=20
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e7b584b..fd32c04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9757,13 +9757,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x=
 *bp)
 	bp->multi_mode =3D multi_mode;
=20
 	/* Set TPA flags */
-	if (disable_tpa) {
-		bp->flags &=3D ~TPA_ENABLE_FLAG;
+	if (disable_tpa)
 		bp->dev->features &=3D ~NETIF_F_LRO;
-	} else {
-		bp->flags |=3D TPA_ENABLE_FLAG;
+	else
 		bp->dev->features |=3D NETIF_F_LRO;
-	}
 	bp->disable_tpa =3D disable_tpa;
=20
 	if (CHIP_IS_E1(bp))
--=20
1.7.6
