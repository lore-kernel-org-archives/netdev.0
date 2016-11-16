From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] ixgbevf: fix invalid uses of napi_hash_del()
Date: Wed, 16 Nov 2016 07:26:50 -0800
Message-ID: <1479310010.8455.197.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36655 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbcKPP0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:26:54 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so14963333pgx.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 07:26:54 -0800 (PST)
In-Reply-To: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() before netif_napi_del() is dangerous
if a synchronize_rcu() is not enforced before NAPI struct freeing.

Lets leave this detail to core networking stack to get it right.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 7eaac3234049..bf4d7efc7dbd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2511,9 +2511,6 @@ static int ixgbevf_alloc_q_vectors(struct ixgbevf_adapter *adapter)
 	while (q_idx) {
 		q_idx--;
 		q_vector = adapter->q_vector[q_idx];
-#ifdef CONFIG_NET_RX_BUSY_POLL
-		napi_hash_del(&q_vector->napi);
-#endif
 		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
 		adapter->q_vector[q_idx] = NULL;
@@ -2537,9 +2534,6 @@ static void ixgbevf_free_q_vectors(struct ixgbevf_adapter *adapter)
 		struct ixgbevf_q_vector *q_vector = adapter->q_vector[q_idx];
 
 		adapter->q_vector[q_idx] = NULL;
-#ifdef CONFIG_NET_RX_BUSY_POLL
-		napi_hash_del(&q_vector->napi);
-#endif
 		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
 	}
