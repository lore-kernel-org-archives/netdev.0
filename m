From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] net: skb_defer_rx_timestamp should check for
 phydev before setting up classify
Date: Thu, 09 Jul 2015 11:02:52 -0700
Message-ID: <20150709180252.1686.56670.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753958AbbGISCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 14:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the call skb_defer_rx_timestamp will first
check for a phydev before going in and manipulating the skb->data and
skb->len values.  By doing this we can avoid unnecessary work on network
devices that don't support phydev.  As a result we reduce the total
instruction count needed to process this on most devices.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/core/timestamping.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 43d3dd62fcc8..42689d5c468c 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -60,11 +60,15 @@ bool skb_defer_rx_timestamp(struct sk_buff *skb)
 	struct phy_device *phydev;
 	unsigned int type;
 
+	if (!skb->dev || !skb->dev->phydev || !skb->dev->phydev->drv)
+		return false;
+
 	if (skb_headroom(skb) < ETH_HLEN)
 		return false;
+
 	__skb_push(skb, ETH_HLEN);
 
-	type = classify(skb);
+	type = ptp_classify_raw(skb);
 
 	__skb_pull(skb, ETH_HLEN);
 
