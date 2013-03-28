From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] aoe: reserve enough headroom on skbs
Date: Wed, 27 Mar 2013 21:28:41 -0700
Message-ID: <1364444921.15753.32.camel@edumazet-glaptop>
References: <5151B0CE.5000000@ll.mit.edu>
	  <1364310900.1716.21.camel@edumazet-glaptop> <5151C6C3.6090408@ll.mit.edu>
	 <1364315410.1716.40.camel@edumazet-glaptop> <5151ECAC.9040404@ll.mit.edu>
	 <alpine.LFD.2.03.1303261852220.8240@linux-mips.org>
	 <5153C2E8.6050604@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Oostdyk <daveo@ll.mit.edu>, ecashin@coraid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:61140 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab3C1E2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 00:28:44 -0400
Received: by mail-da0-f46.google.com with SMTP id y19so4334261dan.5
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 21:28:44 -0700 (PDT)
In-Reply-To: <5153C2E8.6050604@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some network drivers use a non default hard_header_len

Transmitted skb should take into account dev->hard_header_len, or risk
crashes or expensive reallocations.

In the case of aoe, lets reserve MAX_HEADER bytes.

David reported a crash in defxx driver, solved by this patch.

Reported-by: David Oostdyk <daveo@ll.mit.edu>
Tested-by: David Oostdyk <daveo@ll.mit.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ed Cashin <ecashin@coraid.com>
---
 drivers/block/aoe/aoecmd.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 25ef5c0..92b6d7c 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -51,8 +51,9 @@ new_skb(ulong len)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = alloc_skb(len + MAX_HEADER, GFP_ATOMIC);
 	if (skb) {
+		skb_reserve(skb, MAX_HEADER);
 		skb_reset_mac_header(skb);
 		skb_reset_network_header(skb);
 		skb->protocol = __constant_htons(ETH_P_AOE);
