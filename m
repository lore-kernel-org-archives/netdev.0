From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net]  mvpp2: use correct size for memset
Date: Thu, 24 Nov 2016 17:28:12 +0100
Message-ID: <20161124162843.3849988-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jisheng Zhang <jszhang@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:65142 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757159AbcKXQ27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:28:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc-7 detects a short memset in mvpp2, introduced in the original
merge of the driver:

drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_cls_init':
drivers/net/ethernet/marvell/mvpp2.c:3296:2: error: 'memset' used with length equal to number of elements without multiplication by element size [-Werror=memset-elt-size]

The result seems to be that we write uninitialized data into the
flow table registers, although we did not get any warning about
that uninitialized data usage.

Using sizeof() lets us initialize then entire array instead.

Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index ee857868bea5..dabc5418efcc 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3293,7 +3293,7 @@ static void mvpp2_cls_init(struct mvpp2 *priv)
 	mvpp2_write(priv, MVPP2_CLS_MODE_REG, MVPP2_CLS_MODE_ACTIVE_MASK);
 
 	/* Clear classifier flow table */
-	memset(&fe.data, 0, MVPP2_CLS_FLOWS_TBL_DATA_WORDS);
+	memset(&fe.data, 0, sizeof(fe.data));
 	for (index = 0; index < MVPP2_CLS_FLOWS_TBL_SIZE; index++) {
 		fe.index = index;
 		mvpp2_cls_flow_write(priv, &fe);
-- 
2.9.0
