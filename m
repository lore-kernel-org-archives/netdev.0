From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 17 Aug 2016 14:49:46 -0700
Message-ID: <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com,
	alexander.duyck@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34582 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbcHQVvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 17:51:08 -0400
Received: by mail-pa0-f52.google.com with SMTP id fi15so226198pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:51:07 -0700 (PDT)
In-Reply-To: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by Lennert the MPLS GSO code is failing to properly segment
large packets. There are a couple of problems:

1. the inner protocol is not set so the gso segment functions for inner
   protocol layers are not getting run, and

2  MPLS labels for packets that use the "native" (non-OVS) MPLS code
   are not properly accounted for in mpls_gso_segment.

The MPLS GSO code was added for OVS. It is re-using skb_mac_gso_segment
to call the gso segment functions for the higher layer protocols. That
means skb_mac_gso_segment is called twice -- once with the network
protocol set to MPLS and again with the network protocol set to the
inner protocol.

This patch sets the inner skb protocol addressing item 1 above and sets
the network_header and inner_network_header to mark where the MPLS labels
start and end. The MPLS code in OVS is also updated to set the two
network markers.

>From there the MPLS GSO code uses the difference between the network
header and the inner network header to know the size of the MPLS header
that was pushed. It then pulls the MPLS header, resets the mac_len and
protocol for the inner protocol and then calls skb_mac_gso_segment
to segment the skb. Afterwards the skb protocol is set to mpls for
each segment as suggested by Simon.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/mpls_gso.c       | 24 +++++++++++++-----------
 net/mpls/mpls_iptunnel.c  |  5 +++++
 net/openvswitch/actions.c |  6 ++++++
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 2055e57ed1c3..fa6899f02cc8 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -22,33 +22,35 @@
 static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
+	int mpls_hlen = skb_inner_network_header(skb) - skb_network_header(skb);
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
+	__skb_pull(skb, mpls_hlen);
+	skb->mac_len = skb_inner_network_offset(skb);
 
 	/* Segment inner packet. */
 	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
-
+	if (IS_ERR_OR_NULL(segs)) {
+		skb_gso_error_unwind(skb, mpls_protocol, mpls_hlen, mac_offset,
+				     mac_len);
+		goto out;
+	}
 
 	/* Restore outer protocol. */
 	skb->protocol = mpls_protocol;
+	for (skb = segs; skb; skb = skb->next)
+		skb->protocol = mpls_protocol;
 
-	/* Re-pull the mac header that the call to skb_mac_gso_segment()
-	 * above pulled.  It will be re-pushed after returning
-	 * skb_mac_gso_segment(), an indirect caller of this function.
-	 */
-	__skb_pull(skb, skb->data - skb_mac_header(skb));
-
+out:
 	return segs;
 }
 
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index aed872cc05a6..55c5ab907563 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -90,7 +90,12 @@ static int mpls_xmit(struct sk_buff *skb)
 	if (skb_cow(skb, hh_len + new_header_size))
 		goto drop;
 
+	skb_set_inner_protocol(skb, skb->protocol);
+	skb_reset_inner_network_header(skb);
+	skb->encapsulation = 1;
+
 	skb_push(skb, new_header_size);
+
 	skb_reset_network_header(skb);
 
 	skb->dev = out_dev;
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1ecbd7715f6d..6d78f162a88b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		skb->mac_len);
 	skb_reset_mac_header(skb);
 
+	/* for GSO: set MPLS as network header and encapsulated protocol
+	 * header as inner network header
+	 */
+	skb_set_network_header(skb, skb->mac_len);
+	skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
+
 	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
 	*new_mpls_lse = mpls->mpls_lse;
 
-- 
2.1.4
