From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/6] nfp: be drop monitor friendly
Date: Sat,  2 Sep 2017 18:26:03 -0700
Message-ID: <20170903012605.7435-5-jakub.kicinski@netronome.com>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33350 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752960AbdICB0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:17 -0400
Received: by mail-pg0-f52.google.com with SMTP id t3so9982302pgt.0
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:16 -0700 (PDT)
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_consume_skb_any() in place of dev_kfree_skb_any()
when control frame has been successfully processed in flower
and on the driver's main TX completion path.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c    | 3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index d82d9888d676..e014d862b9b6 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -189,8 +189,11 @@ nfp_flower_cmsg_process_one_rx(struct nfp_app *app, struct sk_buff *skb)
 	default:
 		nfp_flower_cmsg_warn(app, "Cannot handle invalid repr control type %u\n",
 				     type);
+		goto out;
 	}
 
+	dev_consume_skb_any(skb);
+	return;
 out:
 	dev_kfree_skb_any(skb);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2920889fa6d6..1c0187f0af51 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -991,7 +991,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 
 		/* check for last gather fragment */
 		if (fidx == nr_frags - 1)
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 
 		tx_ring->txbufs[idx].dma_addr = 0;
 		tx_ring->txbufs[idx].skb = NULL;
-- 
2.14.1
