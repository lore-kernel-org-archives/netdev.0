From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: fix TSO race condition
Date: Thu, 18 Apr 2013 14:10:05 -0400
Message-ID: <1366308606-20435-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27297 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751419Ab3DRSeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 14:34:24 -0400
In-Reply-To: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

When driver receives a packet with gso size > 0 and when TSO is disabled,
it should be transmitted as a TSO packet to prevent Tx timeout and subsequent
firmware reset.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0e63006..5fa847f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -358,8 +358,7 @@ set_flags:
 		memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
 	}
 	opcode = TX_ETHER_PKT;
-	if ((adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
-	    skb_shinfo(skb)->gso_size > 0) {
+	if (skb_is_gso(skb)) {
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		first_desc->total_hdr_length = hdr_len;
-- 
1.5.6
