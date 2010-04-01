From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: Added GRO support
Date: Thu, 1 Apr 2010 14:10:21 +0300
Message-ID: <1270120221.22338.5.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com
To: "David Miller [davem"@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2799 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165Ab0DALKg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 07:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding GRO support on top of the HW LRO (TPA) support =E2=80=93
there is no measurable performance drawback of adding GRO
on top of it, and it allows better performance when LRO (TPA)
is turned off for virtualization or bridging.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6c042a7..f4ea99d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
=20
-#define DRV_MODULE_VERSION	"1.52.1-7"
-#define DRV_MODULE_RELDATE	"2010/02/28"
+#define DRV_MODULE_VERSION	"1.52.1-8"
+#define DRV_MODULE_RELDATE	"2010/04/01"
 #define BNX2X_BC_VER		0x040200
=20
 #include <linux/firmware.h>
@@ -1441,12 +1441,12 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, st=
ruct bnx2x_fastpath *fp,
 #ifdef BCM_VLAN
 			if ((bp->vlgrp !=3D NULL) && is_vlan_cqe &&
 			    (!is_not_hwaccel_vlan_cqe))
-				vlan_hwaccel_receive_skb(skb, bp->vlgrp,
-						le16_to_cpu(cqe->fast_path_cqe.
-							    vlan_tag));
+				vlan_gro_receive(&fp->napi, bp->vlgrp,
+						 le16_to_cpu(cqe->fast_path_cqe.
+							     vlan_tag), skb);
 			else
 #endif
-				netif_receive_skb(skb);
+				napi_gro_receive(&fp->napi, skb);
 		} else {
 			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
 			   " - dropping packet!\n");
@@ -1699,11 +1699,11 @@ reuse_rx:
 		if ((bp->vlgrp !=3D NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
 		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
 		     PARSING_FLAGS_VLAN))
-			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
-				le16_to_cpu(cqe->fast_path_cqe.vlan_tag));
+			vlan_gro_receive(&fp->napi, bp->vlgrp,
+				le16_to_cpu(cqe->fast_path_cqe.vlan_tag), skb);
 		else
 #endif
-			netif_receive_skb(skb);
+			napi_gro_receive(&fp->napi, skb);
=20
=20
 next_rx:
@@ -8935,6 +8935,8 @@ static int __devinit bnx2x_init_bp(struct bnx2x *=
bp)
 	bp->multi_mode =3D multi_mode;
=20
=20
+	bp->dev->features |=3D NETIF_F_GRO;
+
 	/* Set TPA flags */
 	if (disable_tpa) {
 		bp->flags &=3D ~TPA_ENABLE_FLAG;
--=20
1.6.3.3




