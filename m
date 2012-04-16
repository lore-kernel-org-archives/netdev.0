From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2 net-next] drivers/net: fix unresolved 64bit math in mellanox/mlx4/en_dcb_nl.c
Date: Mon, 16 Apr 2012 00:17:34 -0400
Message-ID: <1334549854-16370-1-git-send-email-paul.gortmaker@windriver.com>
References: <20120415.233139.452372897242947075.davem@davemloft.net>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61557 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab2DPERz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 00:17:55 -0400
In-Reply-To: <20120415.233139.452372897242947075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 109d2446052a484c58f07f71f9457bf7b71017f8

    "net/mlx4_en: Set max rate-limit for a TC"

introduced 64 bit math operations into mlx4_en_dcbnl_ieee_setmaxrate()

causing the following final link failure on an x86_32 allmodconfig

  ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx4/mlx4_en.ko] undefined!

Convert it to use div_u64() instead.

Cc: Amir Vadai <amirv@mellanox.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[ v2: add an explicit linux/math64.h include as per davem req ]

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 0cc6c96..5d367958 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/dcbnl.h>
+#include <linux/math64.h>
 
 #include "mlx4_en.h"
 
@@ -227,9 +228,9 @@ static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
 		/* Convert from Kbps into HW units, rounding result up.
 		 * Setting to 0, means unlimited BW.
 		 */
-		tmp[i] =
-			(maxrate->tc_maxrate[i] + MLX4_RATELIMIT_UNITS_IN_KB -
-			 1) / MLX4_RATELIMIT_UNITS_IN_KB;
+		tmp[i] = div_u64(maxrate->tc_maxrate[i] +
+				 MLX4_RATELIMIT_UNITS_IN_KB - 1,
+				 MLX4_RATELIMIT_UNITS_IN_KB);
 	}
 
 	err = mlx4_en_config_port_scheduler(priv, NULL, tmp);
-- 
1.7.9.1
