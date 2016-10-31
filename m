From: Dongli Zhang <dongli.zhang@oracle.com>
Subject: [PATCH 1/1] xen-netfront: do not cast grant table reference to signed short
Date: Mon, 31 Oct 2016 13:38:29 +0800
Message-ID: <1477892309-7150-1-git-send-email-dongli.zhang@oracle.com>
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
        jgross@suse.com
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34678 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758852AbcJaFkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 01:40:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While grant reference is of type uint32_t, xen-netfront erroneously casts
it to signed short in BUG_ON().

This would lead to the xen domU panic during boot-up or migration when it
is attached with lots of paravirtual devices.

Signed-off-by: Dongli Zhang <dongli.zhang@oracle.com>
---
 drivers/net/xen-netfront.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e17879d..189a28d 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -304,7 +304,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		queue->rx_skbs[id] = skb;
 
 		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
-		BUG_ON((signed short)ref < 0);
+		WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));
 		queue->grant_rx_ref[id] = ref;
 
 		page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
@@ -428,7 +428,7 @@ static void xennet_tx_setup_grant(unsigned long gfn, unsigned int offset,
 	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
 	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
 	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
-	BUG_ON((signed short)ref < 0);
+	WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));
 
 	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
 					gfn, GNTMAP_readonly);
-- 
2.7.4
