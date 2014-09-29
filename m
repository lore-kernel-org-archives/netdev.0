From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gro: fix aggregation for skb using frag_list
Date: Mon, 29 Sep 2014 10:34:29 -0700
Message-ID: <1412012069.30721.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Erez Shitrit <erezsh@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33753 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbaI2Rec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:34:32 -0400
Received: by mail-pd0-f177.google.com with SMTP id w10so167003pde.22
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 10:34:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
I added a regression for linear skb that traditionally force GRO
to use the frag_list fallback.

Erez Shitrit found that at most two segments were aggregated and
the "if (skb_gro_len(p) != pinfo->gso_size)" test was failing.

This is because pinfo at this spot still points to the last skb in the
chain, instead of the first one, where we find the correct gso_size
information.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
Reported-by: Erez Shitrit <erezsh@mellanox.com>
---
 net/core/skbuff.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da1378a3e2c7..8d289697cc7a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3152,6 +3152,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
 		goto done;
 	}
+	/* switch back to head shinfo */
+	pinfo = skb_shinfo(p);
+
 	if (pinfo->frag_list)
 		goto merge;
 	if (skb_gro_len(p) != pinfo->gso_size)
