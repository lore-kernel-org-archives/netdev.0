From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] bridge: if no STP then forward all BPDUs
Date: Wed, 25 Apr 2007 16:47:40 -0700
Message-ID: <20070425234950.768857110@linux-foundation.org>
References: <20070425234737.727790594@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55380 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423407AbXDYXzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:55:55 -0400
Content-Disposition: inline; filename=bridge-no-stp-bpdu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a bridge is not running STP, then it has no way to detect a cycle
in the network. But if it is not running STP and some other machine
or device is running STP, then if STP BPDU's get forwarded to it can
detect the cycle.

This is how the old 2.4 and early 2.6 code worked.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/bridge/br_input.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

--- bridge-2.6.22.orig/net/bridge/br_input.c
+++ bridge-2.6.22/net/bridge/br_input.c
@@ -136,8 +136,14 @@ struct sk_buff *br_handle_frame(struct n
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
-		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-				NULL, br_handle_local_finish) == 0) ? skb : NULL;
+		/* Process STP BPDU's through normal netif_receive_skb() path */
+		if (p->br->stp_enabled != BR_NO_STP) {
+			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+				    NULL, br_handle_local_finish))
+				return NULL;
+			else
+				return skb;
+		}
 	}
 
 	switch (p->state) {

-- 

