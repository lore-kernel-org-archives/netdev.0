From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] bridge: handle process all link-local frames
Date: Tue, 17 Jun 2008 09:52:12 -0700
Message-ID: <20080617165223.110719400@vyatta.com>
References: <20080617165211.615620784@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:56909 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260AbYFQQwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:52:55 -0400
Content-Disposition: inline; filename=br-link-local-pdu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any frame addressed to link-local addresses should be processed by local
receive path. The earlier code would process them only if STP was enabled.
Since there are other frames like LACP for bonding, we should always
process them.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_input.c	2008-06-17 09:10:52.000000000 -0700
+++ b/net/bridge/br_input.c	2008-06-17 09:11:23.000000000 -0700
@@ -136,14 +136,11 @@ struct sk_buff *br_handle_frame(struct n
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
-		/* Process STP BPDU's through normal netif_receive_skb() path */
-		if (p->br->stp_enabled != BR_NO_STP) {
-			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-				    NULL, br_handle_local_finish))
-				return NULL;
-			else
-				return skb;
-		}
+		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+			    NULL, br_handle_local_finish))
+			return NULL;	/* frame consumed by filter */
+		else
+			return skb;	/* continue processing */
 	}
 
 	switch (p->state) {

-- 

