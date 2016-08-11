From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: mpls fixes for GSO
Date: Wed, 10 Aug 2016 23:43:31 -0700
Message-ID: <1470897812-8213-3-git-send-email-roopa@cumulusnetworks.com>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com,
	simon.horman@netronome.com, tom@herbertland.com, tgraf@suug.ch,
	olivier.dugeon@orange.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35731 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbcHKGuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 02:50:50 -0400
Received: by mail-pa0-f45.google.com with SMTP id i5so6952185pat.2
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 23:50:50 -0700 (PDT)
In-Reply-To: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
---
 net/mpls/mpls_gso.c      | 24 ++++++++++++++++--------
 net/mpls/mpls_iptunnel.c |  7 +++++++
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 2055e57..8829ee0 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -22,26 +22,28 @@
 static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
+	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	u16 mac_offset = skb->mac_header;
 	netdev_features_t mpls_features;
 	__be16 mpls_protocol;
+	u16 mac_len = skb->mac_len;
 
 	/* Setup inner SKB. */
 	mpls_protocol = skb->protocol;
 	skb->protocol = skb->inner_protocol;
 
-	/* Push back the mac header that skb_mac_gso_segment() has pulled.
-	 * It will be re-pulled by the call to skb_mac_gso_segment() below
-	 */
-	__skb_push(skb, skb->mac_len);
+	__skb_pull(skb, tnl_hlen);
+	skb->mac_len = skb_inner_network_offset(skb);
 
 	/* Segment inner packet. */
 	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
-
-
-	/* Restore outer protocol. */
-	skb->protocol = mpls_protocol;
+	if (IS_ERR_OR_NULL(segs)) {
+		skb_gso_error_unwind(skb, mpls_protocol, tnl_hlen, mac_offset,
+				     mac_len);
+		goto out;
+	}
 
 	/* Re-pull the mac header that the call to skb_mac_gso_segment()
 	 * above pulled.  It will be re-pushed after returning
@@ -49,6 +51,12 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 	 */
 	__skb_pull(skb, skb->data - skb_mac_header(skb));
 
+	/* Restore outer protocol. */
+	skb->protocol = mpls_protocol;
+	for (skb = segs; skb; skb = skb->next)
+		skb->protocol = mpls_protocol;
+
+out:
 	return segs;
 }
 
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index aed872c..87e035a 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -90,8 +90,15 @@ static int mpls_xmit(struct sk_buff *skb)
 	if (skb_cow(skb, hh_len + new_header_size))
 		goto drop;
 
+	skb_reset_mac_header(skb);
+	skb_reset_inner_headers(skb);
+	skb->encapsulation = 1;
+
 	skb_push(skb, new_header_size);
+
 	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb_set_inner_protocol(skb, skb->protocol);
 
 	skb->dev = out_dev;
 	skb->protocol = htons(ETH_P_MPLS_UC);
-- 
1.9.1
