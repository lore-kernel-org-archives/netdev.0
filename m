From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv2 net] sunvnet: set queue mapping when doing packet copies
Date: Thu, 29 Jan 2015 14:42:44 -0500
Message-ID: <54CA8D33.6020006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32723 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbbA2Tmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 14:42:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
queue mapping when a packet copy was required. This results in using the
wrong queue index for stops/starts, hung tx queues and watchdog timeouts
under heavy load. It also transfers the destructor, truesize, and the owning
socket for flow control (code adapted from skb_segment).

Signed-off-by: David L Stevens <david.stevens@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

--
Changes since v1:
 move truesize, destructor and socket per Eric Dumazet <eric.dumazet@gmail.com>

---
 drivers/net/ethernet/sun/sunvnet.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2b719cc..0a1d3eb 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1123,6 +1123,16 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
 			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
 		}
+		nskb->queue_mapping = skb->queue_mapping;
+		/* Following permits correct back-pressure, for protocols
+		 * using skb_set_owner_w().
+		 * Idea is to transfer ownership from skb to nskb.
+		 */
+		if (skb->destructor == sock_wfree) {
+			swap(nskb->truesize, skb->truesize);
+			swap(nskb->destructor, skb->destructor);
+			swap(nskb->sk, skb->sk);
+		}
 		dev_kfree_skb(skb);
 		skb = nskb;
 	}
-- 
1.7.1
