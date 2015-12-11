From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 2/7] iucv: call skb_linearize() when needed
Date: Fri, 11 Dec 2015 11:38:52 +0100
Message-ID: <1449830337-26091-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:51870 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbbLKKjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:39:10 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 10:39:09 -0000
In-Reply-To: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

When the linear buffer of the received sk_buff is shorter than
the header, use skb_linearize(). sk_buffs with short linear buffer
happen on the sending side under high traffic, and some kernel
configurations, when allocated buffer starts just before page
boundary, and IUCV transport has to send it as two separate QDIO
buffer elements, with fist element shorter than the header.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 5bc473b..ef50a94 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -2084,11 +2084,7 @@ static int afiucv_hs_callback_rx(struct sock *sk, struct sk_buff *skb)
 		return NET_RX_SUCCESS;
 	}
 
-		/* write stuff from iucv_msg to skb cb */
-	if (skb->len < sizeof(struct af_iucv_trans_hdr)) {
-		kfree_skb(skb);
-		return NET_RX_SUCCESS;
-	}
+	/* write stuff from iucv_msg to skb cb */
 	skb_pull(skb, sizeof(struct af_iucv_trans_hdr));
 	skb_reset_transport_header(skb);
 	skb_reset_network_header(skb);
@@ -2119,6 +2115,20 @@ static int afiucv_hs_rcv(struct sk_buff *skb, struct net_device *dev,
 	char nullstring[8];
 	int err = 0;
 
+	if (skb->len < (ETH_HLEN + sizeof(struct af_iucv_trans_hdr))) {
+		WARN_ONCE(1, "AF_IUCV too short skb, len=%d, min=%d",
+			  (int)skb->len,
+			  (int)(ETH_HLEN + sizeof(struct af_iucv_trans_hdr)));
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+	if (skb_headlen(skb) < (ETH_HLEN + sizeof(struct af_iucv_trans_hdr)))
+		if (skb_linearize(skb)) {
+			WARN_ONCE(1, "AF_IUCV skb_linearize failed, len=%d",
+				  (int)skb->len);
+			kfree_skb(skb);
+			return NET_RX_SUCCESS;
+		}
 	skb_pull(skb, ETH_HLEN);
 	trans_hdr = (struct af_iucv_trans_hdr *)skb->data;
 	EBCASC(trans_hdr->destAppName, sizeof(trans_hdr->destAppName));
-- 
2.3.9
