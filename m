From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: [PATCH v3 1/2] gianfar: Fix missing sock reference when processing TX time stamps
Date: Tue, 10 Jan 2012 10:26:50 +0100
Message-ID: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <afleming@freescale.com>,
	<avorontsov@mvista.com>, <richardcochran@gmail.com>,
	<eric.dumazet@gmail.com>,
	Manfred Rudigier <manfred.rudigier@omicron.at>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:42294 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754854Ab2AJJ14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:27:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is not enough headroom in the skb a private copy will be made.
However, the private copy had no reference to the socket and consequently
no time stamp could be queued on the socket error queue during the
skb_tstamp_tx function. This patch fixes this issue by also stealing the
sock reference from the original skb after making the private copy.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/ethernet/freescale/gianfar.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 83199fd..e11d422 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2086,6 +2086,10 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
+
+		/* Steal sock reference for processing TX time stamps */
+		swap(skb_new->sk, skb->sk);
+		swap(skb_new->destructor, skb->destructor);
 		kfree_skb(skb);
 		skb = skb_new;
 	}
-- 
1.7.0.4
