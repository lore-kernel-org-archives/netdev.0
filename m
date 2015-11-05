From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 4/5] bnxt_en: Fix comparison of u16 sw_id against negative value.
Date: Thu, 5 Nov 2015 16:25:50 -0500
Message-ID: <1446758751-27999-5-git-send-email-mchan@broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:64059 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757025AbbKEVZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:52 -0500
In-Reply-To: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign the return value from bitmap_find_free_region() to an integer
variable and check for negative error codes first, before assigning
the bit ID to the unsigned sw_id field.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a62deff..db15c5e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5307,7 +5307,7 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	struct bnxt_ntuple_filter *fltr, *new_fltr;
 	struct flow_keys *fkeys;
 	struct ethhdr *eth = (struct ethhdr *)skb_mac_header(skb);
-	int rc = 0, idx;
+	int rc = 0, idx, bit_id;
 	struct hlist_head *head;
 
 	if (skb->encapsulation)
@@ -5345,14 +5345,15 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	rcu_read_unlock();
 
 	spin_lock_bh(&bp->ntp_fltr_lock);
-	new_fltr->sw_id = bitmap_find_free_region(bp->ntp_fltr_bmap,
-						  BNXT_NTP_FLTR_MAX_FLTR, 0);
-	if (new_fltr->sw_id < 0) {
+	bit_id = bitmap_find_free_region(bp->ntp_fltr_bmap,
+					 BNXT_NTP_FLTR_MAX_FLTR, 0);
+	if (bit_id < 0) {
 		spin_unlock_bh(&bp->ntp_fltr_lock);
 		rc = -ENOMEM;
 		goto err_free;
 	}
 
+	new_fltr->sw_id = (u16)bit_id;
 	new_fltr->flow_id = flow_id;
 	new_fltr->rxq = rxq_index;
 	hlist_add_head_rcu(&new_fltr->hash, head);
-- 
1.8.3.1
