From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] nfp: TX time stamp packets before HW doorbell is rung
Date: Wed, 23 Aug 2017 14:41:50 -0700
Message-ID: <20170823214150.29989-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:32986 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdHWVl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:41:56 -0400
Received: by mail-pg0-f47.google.com with SMTP id t3so5811126pgt.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 14:41:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX completion may happen any time after HW queue was kicked.
We can't access the skb afterwards.  Move the time stamping
before ringing the doorbell.

Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
Sorry, another one just popped up.  It has been in the driver 
"for ever", it could go into net-next as well.

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1ff0c577819e..66a09e490cf5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -895,6 +895,8 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 
 	netdev_tx_sent_queue(nd_q, txbuf->real_len);
 
+	skb_tx_timestamp(skb);
+
 	tx_ring->wr_p += nr_frags + 1;
 	if (nfp_net_tx_ring_should_stop(tx_ring))
 		nfp_net_tx_ring_stop(nd_q, tx_ring);
@@ -903,8 +905,6 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	if (!skb->xmit_more || netif_xmit_stopped(nd_q))
 		nfp_net_tx_xmit_more_flush(tx_ring);
 
-	skb_tx_timestamp(skb);
-
 	return NETDEV_TX_OK;
 
 err_unmap:
-- 
2.11.0
