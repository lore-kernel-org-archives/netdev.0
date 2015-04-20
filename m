From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: [PATCH v2] ip_forward: Drop frames with attached skb->sk
Date: Mon, 20 Apr 2015 09:19:20 +0200
Message-ID: <1429514360.7091.9.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38014 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbbDTHTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 03:19:23 -0400
Received: by wiun10 with SMTP id n10so80215446wiu.1
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 00:19:22 -0700 (PDT)
Received: from de-ka-36785.green.sophos (port-92-198-130-190.static.qsc.de. [92.198.130.190])
        by mx.google.com with ESMTPSA id f8sm13947705wiy.7.2015.04.20.00.19.21
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 00:19:21 -0700 (PDT)
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

v2:
Remove useless comment

Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
---
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 939992c..3674484 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -82,6 +82,9 @@ int ip_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
+	if (unlikely(skb->sk))
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
--
