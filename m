From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net] bnxt_en: Fix zero padding of tx push data.
Date: Mon, 22 Feb 2016 02:10:26 -0500
Message-ID: <1456125026-16093-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:56717
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbcBVHK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 02:10:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arithmetic to zero pad the last 64-bit word in the push buffer is not
correct.

1. It should be pdata + length to get to the end.
2. 'pdata' is void pointer and passing it to PTR_ALIGN() will cast the
aligned pointer to void.  Pass 'end' which is u64 pointer to PTR_ALIGN()
instead so that the aligned pointer - 1 is the last 64-bit pointer to data.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8ab000d..82f1913 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -248,7 +248,8 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_push1->tx_bd_cfa_meta = cpu_to_le32(vlan_tag_flags);
 		tx_push1->tx_bd_cfa_action = cpu_to_le32(cfa_action);
 
-		end = PTR_ALIGN(pdata + length + 1, 8) - 1;
+		end = pdata + length;
+		end = PTR_ALIGN(end, 8) - 1;
 		*end = 0;
 
 		skb_copy_from_linear_data(skb, pdata, len);
-- 
1.8.3.1
