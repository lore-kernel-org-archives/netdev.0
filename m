From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: fix work done in tx napi_poll
Date: Thu, 13 Nov 2014 04:12:06 +0530
Message-ID: <1415832126-31901-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:52599 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbaKLWme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 17:42:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the commit d75b1ade567 ("net: less interrupt masking in NAPI") napi repoll
is done only when work_done == budget. In tx napi poll we always return 0.
So tx napi is not called again and we do not clean up the tx ring.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 73cf165..5afe360 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1312,9 +1312,10 @@ static int enic_poll_msix_wq(struct napi_struct *napi, int budget)
 	if (!wq_work_done) {
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[intr]);
+		return 0;
 	}
 
-	return 0;
+	return budget;
 }
 
 static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
-- 
2.1.3
