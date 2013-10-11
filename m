From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Thu, 10 Oct 2013 19:35:51 -0700
Message-ID: <20131010193551.462fc1f8@nehalam.linuxnetplumber.net>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
	<20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
	<52571481.5010907@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33800 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab3JKCfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 22:35:55 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so3610331pad.7
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 19:35:55 -0700 (PDT)
In-Reply-To: <52571481.5010907@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I was thinking would be better.

Don't want these packets leaking into PRE_ROUTEING chain or have
any chance to get flooded out other ports.

Compile tested only...

I could use another goto instead but that becomes spaghetti and
never like to jump back into a block.


--- a/net/bridge/br_input.c	2013-10-06 14:48:24.946450042 -0700
+++ b/net/bridge/br_input.c	2013-10-10 19:32:14.227926344 -0700
@@ -152,6 +152,16 @@ static int br_handle_local_finish(struct
 	return 0;	 /* process further */
 }
 
+/* Deliver packet to local host only */
+static rx_handler_result_t br_local_only(struct sk_buff *skb)
+{
+	if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+		    NULL, br_handle_local_finish))
+		return RX_HANDLER_CONSUMED; /* consumed by filter */
+	else
+		return RX_HANDLER_PASS;	/* continue processing */
+}
+
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -206,18 +216,20 @@ rx_handler_result_t br_handle_frame(stru
 				goto forward;
 		}
 
-		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish)) {
-			return RX_HANDLER_CONSUMED; /* consumed by filter */
-		} else {
-			*pskb = skb;
-			return RX_HANDLER_PASS;	/* continue processing */
-		}
+		*pskb = skb;
+		return br_local_only(skb);
 	}
 
 forward:
 	switch (p->state) {
+	case BR_STATE_DISABLED:
+		if (!ether_addr_equal(p->br->dev->dev_addr, dest))
+			goto drop;
+
+		skb->pkt_type = PACKET_HOST;
+		*pskb = skb;
+		return br_local_only(skb);
+
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook) {
