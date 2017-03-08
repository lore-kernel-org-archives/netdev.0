From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/9] nfp: avoid rearming the interrupts when in busy poll
Date: Wed,  8 Mar 2017 08:57:06 -0800
Message-ID: <20170308165708.96087-8-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34424 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753661AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pg0-f46.google.com with SMTP id 77so15217032pgc.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:14 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of return code from napi_complete_done() to avoid rearming
interrupts when busy polling is on.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 397d9e82ed0e..119775d4097e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1705,10 +1705,9 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 			nfp_net_xdp_complete(r_vec->xdp_ring);
 	}
 
-	if (pkts_polled < budget) {
-		napi_complete_done(napi, pkts_polled);
-		nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_entry);
-	}
+	if (pkts_polled < budget)
+		if (napi_complete_done(napi, pkts_polled))
+			nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_entry);
 
 	return pkts_polled;
 }
-- 
2.11.0
