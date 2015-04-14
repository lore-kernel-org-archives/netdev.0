From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Tue, 14 Apr 2015 07:52:04 +0200
Message-ID: <1428990724.6812.8.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33592 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbDNFwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:52:06 -0400
Received: by wgin8 with SMTP id n8so102812427wgi.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:52:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial discussion was:
[FYI] xfrm: Don't lookup sk_policy for timewait sockets

Forwarded frames should not have a socket attached. Especially
tw sockets will lead to panics later-on in the stack.

This was observed with TPROXY assigning a tw socket and broken
policy routing (misconfigured). As a result frame enters
forwarding path instead of input. We cannot solve this in
TPROXY as it cannot know that policy routing is broken.

Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
---
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 939992c..2fc3b3e 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -82,6 +82,10 @@ int ip_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
+	/* this should happen neither */
+	if (unlikely(skb->sk))
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
--
