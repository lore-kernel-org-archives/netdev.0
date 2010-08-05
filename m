From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Fix napi_gro_frags vs netpoll path
Date: Thu, 5 Aug 2010 11:03:55 +0000
Message-ID: <20100805110355.GA19965@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42030 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758849Ab0HELEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 07:04:02 -0400
Received: by fxm14 with SMTP id 14so2748501fxm.19
        for <netdev@vger.kernel.org>; Thu, 05 Aug 2010 04:04:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While looking at Xioahui's patch I noticed this "unless I miss
something" bug.

Jarek P.
------------------>

The netpoll_rx_on() check in dev_gro_receive() skips part of the
"common" GRO_NORMAL path, especially "pull:" in dev_gro_receive(),
where at least eth header should be copied for entirely paged skbs.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index e1c1cdc..2b50896 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3072,7 +3072,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int mac_len;
 	enum gro_result ret;
 
-	if (!(skb->dev->features & NETIF_F_GRO))
+	if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
 		goto normal;
 
 	if (skb_is_gso(skb) || skb_has_frags(skb))
@@ -3159,9 +3159,6 @@ __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 
-	if (netpoll_rx_on(skb))
-		return GRO_NORMAL;
-
 	for (p = napi->gro_list; p; p = p->next) {
 		NAPI_GRO_CB(p)->same_flow =
 			(p->dev == skb->dev) &&
