From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: dev_gro_receive() cleanup
Date: Mon, 10 Dec 2012 15:28:16 -0800
Message-ID: <1355182096.27891.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:47069 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab2LJX2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 18:28:18 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1428756dak.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 15:28:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__napi_gro_receive() is inlined from two call sites for no good reason.

Lets move the prep stuff in a function of its own, called only if/when 
needed. This saves 300 bytes on x86 :

# size net/core/dev.o.after net/core/dev.o.before
   text	   data	    bss	    dec	    hex	filename
  51968	   1238	   1040	  54246	   d3e6	net/core/dev.o.before
  51664	   1238	   1040	  53942	   d2b6	net/core/dev.o.after

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |   52 +++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a4c4a1b..4783850 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3603,6 +3603,28 @@ void napi_gro_flush(struct napi_struct *napi, bool flush_old)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
+static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
+{
+	struct sk_buff *p;
+	unsigned int maclen = skb->dev->hard_header_len;
+
+	for (p = napi->gro_list; p; p = p->next) {
+		unsigned long diffs;
+
+		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
+		diffs |= p->vlan_tci ^ skb->vlan_tci;
+		if (maclen == ETH_HLEN)
+			diffs |= compare_ether_header(skb_mac_header(p),
+						      skb_gro_mac_header(skb));
+		else if (!diffs)
+			diffs = memcmp(skb_mac_header(p),
+				       skb_gro_mac_header(skb),
+				       maclen);
+		NAPI_GRO_CB(p)->same_flow = !diffs;
+		NAPI_GRO_CB(p)->flush = 0;
+	}
+}
+
 static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
@@ -3619,6 +3641,8 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (skb_is_gso(skb) || skb_has_frag_list(skb))
 		goto normal;
 
+	gro_list_prepare(napi, skb);
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		if (ptype->type != type || !ptype->callbacks.gro_receive)
@@ -3695,30 +3719,6 @@ normal:
 	goto pull;
 }
 
-static inline gro_result_t
-__napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
-{
-	struct sk_buff *p;
-	unsigned int maclen = skb->dev->hard_header_len;
-
-	for (p = napi->gro_list; p; p = p->next) {
-		unsigned long diffs;
-
-		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
-		diffs |= p->vlan_tci ^ skb->vlan_tci;
-		if (maclen == ETH_HLEN)
-			diffs |= compare_ether_header(skb_mac_header(p),
-						      skb_gro_mac_header(skb));
-		else if (!diffs)
-			diffs = memcmp(skb_mac_header(p),
-				       skb_gro_mac_header(skb),
-				       maclen);
-		NAPI_GRO_CB(p)->same_flow = !diffs;
-		NAPI_GRO_CB(p)->flush = 0;
-	}
-
-	return dev_gro_receive(napi, skb);
-}
 
 static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
@@ -3768,7 +3768,7 @@ gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	skb_gro_reset_offset(skb);
 
-	return napi_skb_finish(__napi_gro_receive(napi, skb), skb);
+	return napi_skb_finish(dev_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
@@ -3866,7 +3866,7 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 	if (!skb)
 		return GRO_DROP;
 
-	return napi_frags_finish(napi, skb, __napi_gro_receive(napi, skb));
+	return napi_frags_finish(napi, skb, dev_gro_receive(napi, skb));
 }
 EXPORT_SYMBOL(napi_gro_frags);
 
