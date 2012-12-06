From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: gro: fix possible panic in skb_gro_receive()
Date: Thu, 06 Dec 2012 15:54:59 -0800
Message-ID: <1354838099.10983.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60477 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab2LFXzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:55:03 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4855284pbc.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 15:55:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 2e71a6f8084e (net: gro: selective flush of packets) added
a bug for skbs using frag_list. This part of the GRO stack is rarely
used, as it needs skb not using a page fragment for their skb->head.

Most drivers do use a page fragment, but some of them use GFP_KERNEL
allocations for the initial fill of their RX ring buffer.

napi_gro_flush() overwrite skb->prev that was used for these skb to
point to the last skb in frag_list.

Fix this using a separate field in struct napi_gro_cb to point to the
last fragment.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    2 ++
 net/core/skbuff.c         |    6 +++---
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8eda02..a848ffc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1488,6 +1488,9 @@ struct napi_gro_cb {
 
 	/* Used in ipv6_gro_receive() */
 	int	proto;
+
+	/* used in skb_gro_receive() slow path */
+	struct sk_buff *last;
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
diff --git a/net/core/dev.c b/net/core/dev.c
index c0946cb..e5942bf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3451,6 +3451,8 @@ static int napi_gro_complete(struct sk_buff *skb)
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
 	int err = -ENOENT;
 
+	BUILD_BUG_ON(sizeof(struct napi_gro_cb) > sizeof(skb->cb));
+
 	if (NAPI_GRO_CB(skb)->count == 1) {
 		skb_shinfo(skb)->gso_size = 0;
 		goto out;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4007c14..3f0636c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3004,7 +3004,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
 	pinfo->gso_size = 0;
 	skb_header_release(p);
-	nskb->prev = p;
+	NAPI_GRO_CB(nskb)->last = p;
 
 	nskb->data_len += p->len;
 	nskb->truesize += p->truesize;
@@ -3030,8 +3030,8 @@ merge:
 
 	__skb_pull(skb, offset);
 
-	p->prev->next = skb;
-	p->prev = skb;
+	NAPI_GRO_CB(p)->last->next = skb;
+	NAPI_GRO_CB(p)->last = skb;
 	skb_header_release(skb);
 
 done:
