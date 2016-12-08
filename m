From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 3/3] net: xgene: avoid bogus maybe-uninitialized warning
Date: Thu,  8 Dec 2016 22:57:05 +0100
Message-ID: <20161208215727.44841-3-arnd@arndb.de>
References: <20161208215727.44841-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Quan Nguyen <qnguyen@apm.com>, Khuong Dinh <kdinh@apm.com>,
        Toan Le <toanle@apm.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:49826 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932898AbcLHV6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:58:18 -0500
In-Reply-To: <20161208215727.44841-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some configurations, gcc cannot trace the state of variables
across a spin_unlock() barrier, leading to a warning about
correct code:

xgene_enet_main.c: In function 'xgene_enet_start_xmit':
../../../phy/mdio-xgene.h:112:14: error: 'mss_index' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Here we can trivially move the assignment before that spin_unlock,
which reliably avoids the warning.

Fixes: e3978673f514 ("drivers: net: xgene: Fix MSS programming")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6c7eea8b36af..dba4b883e9a3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -319,11 +319,11 @@ static int xgene_enet_setup_mss(struct net_device *ndev, u32 mss)
 		}
 	}
 
-	spin_unlock(&pdata->mss_lock);
-
 	/* No slots with ref_count = 0 available, return busy */
 	if (!mss_index_found)
-		return -EBUSY;
+		mss_index = -EBUSY;
+
+	spin_unlock(&pdata->mss_lock);
 
 	return mss_index;
 }
-- 
2.9.0
