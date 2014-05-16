From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies too many slots
Date: Fri, 16 May 2014 12:08:16 +0100
Message-ID: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32711 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870AbaEPLIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 07:08:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some workload, such as Redis can generate SKBs which make use of
compound pages. Netfront doesn't quite like that because it doesn't want
to send packet that occupies exessive slots to the backend as backend
might deem it malicious. On the flip side these packets are actually
legit, the size check at the beginning of xennet_start_xmit ensures that
packet size is below 64K.

So we linearize SKB if it occupies too many slots. If the linearization
fails then the SKB is dropped.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Stefan Bader <stefan.bader@canonical.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netfront.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 895355d..b378dcd 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -573,9 +573,20 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
-		net_alert_ratelimited(
-			"xennet: skb rides the rocket: %d slots\n", slots);
-		goto drop;
+		if (skb_linearize(skb)) {
+			net_alert_ratelimited(
+				"xennet: failed to linearize skb, skb dropped\n");
+			goto drop;
+		}
+		data = skb->data;
+		offset = offset_in_page(data);
+		len = skb_headlen(skb);
+		slots = DIV_ROUND_UP(offset + len, PAGE_SIZE);
+		if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
+			net_alert_ratelimited(
+				"xennet: still too many slots after linerization: %d", slots);
+			goto drop;
+		}
 	}
 
 	spin_lock_irqsave(&np->tx_lock, flags);
-- 
1.7.10.4
