From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] l2tp: fix a potential skb leak in l2tp_xmit_skb()
Date: Fri, 07 Oct 2011 17:35:46 +0200
Message-ID: <1318001746.3207.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62116 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab1JGPfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 11:35:31 -0400
Received: by wwf22 with SMTP id 22so6099007wwf.1
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 08:35:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_xmit_skb() can leak one skb if skb_cow_head() returns an error.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_core.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ad4ac26..34b2dde 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1045,8 +1045,10 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
 		uhlen + hdr_len;
 	old_headroom = skb_headroom(skb);
-	if (skb_cow_head(skb, headroom))
+	if (skb_cow_head(skb, headroom)) {
+		dev_kfree_skb(skb);
 		goto abort;
+	}
 
 	new_headroom = skb_headroom(skb);
 	skb_orphan(skb);
