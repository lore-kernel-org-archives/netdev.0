From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH]NET: Fix GSO problems in dev_hard_start_xmit()
Date: Sun, 25 Jun 2006 15:38:05 -0700
Message-ID: <1151275085.4468.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:58634 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932404AbWFYWhK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 18:37:10 -0400
To: herbert@gondor.apana.org.au, davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix 2 problems in dev_hard_start_xmit():

1. nskb->next needs to link back to skb->next if hard_start_xmit()
returns non-zero.

2. Since the total number of GSO fragments may exceed MAX_SKB_FRAGS + 1,
it needs to stop transmitting if the netif_queue is stopped.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/net/core/dev.c b/net/core/dev.c
index d293e0f..84e06ae 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1325,9 +1325,12 @@ int dev_hard_start_xmit(struct sk_buff *
 		nskb->next = NULL;
 		rc = dev->hard_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
+			nskb->next = skb->next;
 			skb->next = nskb;
 			return rc;
 		}
+		if (unlikely(netif_queue_stopped(dev) && skb->next))
+			return NETDEV_TX_BUSY;
 	} while (skb->next);
 	
 	skb->destructor = DEV_GSO_CB(skb)->destructor;


