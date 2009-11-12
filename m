From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH] TI Davinci EMAC : Fix Console Hang when bringing the interface down
Date: Thu, 12 Nov 2009 17:25:42 +0530
Message-ID: <1258026942-2947-1-git-send-email-srk@ti.com>
Cc: Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:38598 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163AbZKLLzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 06:55:40 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id nACBthOw026593
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 05:55:46 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the NAPI poll function(emac_poll), check for netif_running()
is unnecassary. In addition to associated runtime overhead, it
also results in a continuous softirq loop when the interface is
brought down under heavy traffic(tested wit Traffic Generator).
Once the interface is disabled, the poll function always returns
zero(with the check for netif_running) and napi_complete() would
never get called resulting in softirq loop.

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
---
This patch has been validated on the OMAP-L138 platform. The smsc911x
driver has a similar issue. Will post a patch for that separately.

 drivers/net/davinci_emac.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index f72c56d..2533413 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2140,9 +2140,6 @@ static int emac_poll(struct napi_struct *napi, int budget)
 	u32 status = 0;
 	u32 num_pkts = 0;
 
-	if (!netif_running(ndev))
-		return 0;
-
 	/* Check interrupt vectors and call packet processing */
 	status = emac_read(EMAC_MACINVECTOR);
 
-- 
1.6.2.4

