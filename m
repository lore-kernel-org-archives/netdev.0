From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net: Fix vlan_gro_frags vs netpoll and bonding paths
Date: Fri, 27 Aug 2010 22:50:42 +0200
Message-ID: <20100827205042.GA13844@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37676 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab0H0Uuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 16:50:50 -0400
Received: by wyb35 with SMTP id 35so3988715wyb.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 13:50:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After positive netpoll_rx_on() check in vlan_gro_receive() there is
skipped part of the "common" GRO_NORMAL path, especially "pull:" in
dev_gro_receive(), where at least eth header should be copied for
entirely paged skbs. So, eth_type_trans() can read zeroed header only.

Alas moving the netpoll_rx_on() check isn't enough here because a bit
later, in vlan_gro_common(), skb_bond_should_drop() is called, which
depends on skb->protocol and skb->pkt_type data, and can also change
eth_hdr h_dest address (which is overwritten later, btw).

To fix both problems this patch completes copying and verifying of eth
header from the fragment in vlan_gro_receive(). For that purpose the
"pull:" part of dev_gro_receive() was separated into an inline as
skb_gro_pull_in(), and there was added a "lighter" version of
napi_frags_finish(). No gro path except vlan_gro_frags() should be
affected by these changes.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/linux/netdevice.h |   33 ++++++++++++++++++++++++++++++
 net/8021q/vlan_core.c     |   16 ++++++++++----
 net/core/dev.c            |   48 +++++++++++++++++++++++++-------------------
 3 files changed, 71 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 46c36ff..ad59f76 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1339,6 +1339,36 @@ static inline void skb_gro_pull(struct sk_buff *skb, unsigned int len)
 	NAPI_GRO_CB(skb)->data_offset += len;
 }
 
+/*
+ * Complete pulling of the header(s) from the fragment
+ */
+static inline void skb_gro_pull_in(struct sk_buff *skb)
+{
+	int grow;
+
+	if (skb_headlen(skb) >= skb_gro_offset(skb))
+		return;
+
+	grow = skb_gro_offset(skb) - skb_headlen(skb);
+
+	BUG_ON(skb->end - skb->tail < grow);
+
+	memcpy(skb_tail_pointer(skb), NAPI_GRO_CB(skb)->frag0, grow);
+
+	skb->tail += grow;
+	skb->data_len -= grow;
+
+	skb_shinfo(skb)->frags[0].page_offset += grow;
+	skb_shinfo(skb)->frags[0].size -= grow;
+
+	if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
+		put_page(skb_shinfo(skb)->frags[0].page);
+		memmove(skb_shinfo(skb)->frags,
+			skb_shinfo(skb)->frags + 1,
+			--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
+	}
+}
+
 static inline void *skb_gro_header_fast(struct sk_buff *skb,
 					unsigned int offset)
 {
@@ -1701,6 +1731,9 @@ extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb,
 					  gro_result_t ret);
+extern gro_result_t	__napi_frags_finish(struct napi_struct *napi,
+					    struct sk_buff *skb,
+					    gro_result_t ret);
 extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
 extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 01ddb04..58289fe 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -139,13 +139,19 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb)
 		return GRO_DROP;
 
-	if (netpoll_rx_on(skb)) {
-		skb->protocol = eth_type_trans(skb, skb->dev);
+	/*
+	 * Complete the eth header here, mainly for skb_bond_should_drop(),
+	 * and for netpoll_rx_on() btw.
+	 */
+	skb_gro_pull_in(skb);
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	skb_gro_pull(skb, -ETH_HLEN);
+
+	if (netpoll_rx_on(skb))
 		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci)
 			? GRO_DROP : GRO_NORMAL;
-	}
 
-	return napi_frags_finish(napi, skb,
-				 vlan_gro_common(napi, grp, vlan_tci, skb));
+	return __napi_frags_finish(napi, skb,
+				   vlan_gro_common(napi, grp, vlan_tci, skb));
 }
 EXPORT_SYMBOL(vlan_gro_frags);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3721fbb..cdc0be5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3126,27 +3126,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	ret = GRO_HELD;
 
 pull:
-	if (skb_headlen(skb) < skb_gro_offset(skb)) {
-		int grow = skb_gro_offset(skb) - skb_headlen(skb);
-
-		BUG_ON(skb->end - skb->tail < grow);
-
-		memcpy(skb_tail_pointer(skb), NAPI_GRO_CB(skb)->frag0, grow);
-
-		skb->tail += grow;
-		skb->data_len -= grow;
-
-		skb_shinfo(skb)->frags[0].page_offset += grow;
-		skb_shinfo(skb)->frags[0].size -= grow;
-
-		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
-			put_page(skb_shinfo(skb)->frags[0].page);
-			memmove(skb_shinfo(skb)->frags,
-				skb_shinfo(skb)->frags + 1,
-				--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
-		}
-	}
-
+	skb_gro_pull_in(skb);
 ok:
 	return ret;
 
@@ -3267,6 +3247,32 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(napi_frags_finish);
 
+/*
+ * The lighter version of napi_frags_finish() without eth_type_trans() etc.
+ */
+gro_result_t __napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
+				 gro_result_t ret)
+{
+	switch (ret) {
+	case GRO_NORMAL:
+		if (netif_receive_skb(skb))
+			ret = GRO_DROP;
+		break;
+
+	case GRO_DROP:
+	case GRO_MERGED_FREE:
+		napi_reuse_skb(napi, skb);
+		break;
+
+	case GRO_HELD:
+	case GRO_MERGED:
+		break;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(__napi_frags_finish);
+
 struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi->skb;
