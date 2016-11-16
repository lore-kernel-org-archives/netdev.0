From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] : add a missing rcu synchronization
Date: Wed, 16 Nov 2016 06:31:52 -0800
Message-ID: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34743 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753156AbcKPOby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:31:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so14512028pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:31:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add a missing synchronize_net() call to avoid potential use after free,
since we explicitly call napi_hash_del() to factorize the RCU grace
period.

Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c6909660e097..e18635b2a002 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4934,6 +4934,10 @@ static void bnxt_del_napi(struct bnxt *bp)
 		napi_hash_del(&bnapi->napi);
 		netif_napi_del(&bnapi->napi);
 	}
+	/* We called napi_hash_del() before netif_napi_del(), we need
+	 * to respect an RCU grace period before freeing napi structures.
+	 */
+	synchronize_net();
 }
 
 static void bnxt_init_napi(struct bnxt *bp)
