From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 20:10:44 -0700
Message-ID: <1472094645-11452-3-git-send-email-dsa@cumulusnetworks.com>
References: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
        ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
        tgraf@suug.ch, olivier.dugeon@orange.com,
        alexander.duyck@gmail.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34291 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754764AbcHYFHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 01:07:48 -0400
Received: by mail-pa0-f48.google.com with SMTP id fi15so13341270pac.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 22:07:48 -0700 (PDT)
In-Reply-To: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
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
to segment the skb.

Afterward the inner protocol segmentation is done the skb protocol
is set to mpls for each segment and the network and mac headers
restored.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/mpls_gso.c       | 40 +++++++++++++++++++++++++++++-----------
 net/mpls/mpls_iptunnel.c  |  4 ++++
 net/openvswitch/actions.c |  9 +++++++--
 3 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 2055e57ed1c3..b4da6d8e8632 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -23,32 +23,50 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	u16 mac_offset = skb->mac_header;
 	netdev_features_t mpls_features;
+	u16 mac_len = skb->mac_len;
 	__be16 mpls_protocol;
+	unsigned int mpls_hlen;
+
+	skb_reset_network_header(skb);
+	mpls_hlen = skb_inner_network_header(skb) - skb_network_header(skb);
+	if (unlikely(!pskb_may_pull(skb, mpls_hlen)))
+		goto out;
 
 	/* Setup inner SKB. */
 	mpls_protocol = skb->protocol;
 	skb->protocol = skb->inner_protocol;
 
-	/* Push back the mac header that skb_mac_gso_segment() has pulled.
-	 * It will be re-pulled by the call to skb_mac_gso_segment() below
-	 */
-	__skb_push(skb, skb->mac_len);
+	__skb_pull(skb, mpls_hlen);
+
+	skb->mac_len = 0;
+	skb_reset_mac_header(skb);
 
 	/* Segment inner packet. */
 	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
+	if (IS_ERR_OR_NULL(segs)) {
+		skb_gso_error_unwind(skb, mpls_protocol, mpls_hlen, mac_offset,
+				     mac_len);
+		goto out;
+	}
+	skb = segs;
+
+	mpls_hlen += mac_len;
+	do {
+		skb->mac_len = mac_len;
+		skb->protocol = mpls_protocol;
 
+		skb_reset_inner_network_header(skb);
 
-	/* Restore outer protocol. */
-	skb->protocol = mpls_protocol;
+		__skb_push(skb, mpls_hlen);
 
-	/* Re-pull the mac header that the call to skb_mac_gso_segment()
-	 * above pulled.  It will be re-pushed after returning
-	 * skb_mac_gso_segment(), an indirect caller of this function.
-	 */
-	__skb_pull(skb, skb->data - skb_mac_header(skb));
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+	} while ((skb = skb->next));
 
+out:
 	return segs;
 }
 
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index aed872cc05a6..cf52cf30ac4b 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -90,7 +90,11 @@ static int mpls_xmit(struct sk_buff *skb)
 	if (skb_cow(skb, hh_len + new_header_size))
 		goto drop;
 
+	skb_set_inner_protocol(skb, skb->protocol);
+	skb_reset_inner_network_header(skb);
+
 	skb_push(skb, new_header_size);
+
 	skb_reset_network_header(skb);
 
 	skb->dev = out_dev;
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1ecbd7715f6d..ca91fc33f8a9 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -162,10 +162,16 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	if (skb_cow_head(skb, MPLS_HLEN) < 0)
 		return -ENOMEM;
 
+	if (!skb->inner_protocol) {
+		skb_set_inner_network_header(skb, skb->mac_len);
+		skb_set_inner_protocol(skb, skb->protocol);
+	}
+
 	skb_push(skb, MPLS_HLEN);
 	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
 		skb->mac_len);
 	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb->mac_len);
 
 	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
 	*new_mpls_lse = mpls->mpls_lse;
@@ -173,8 +179,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
 	update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
-	if (!skb->inner_protocol)
-		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
 
 	invalidate_flow_key(key);
@@ -198,6 +202,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 
 	__skb_pull(skb, MPLS_HLEN);
 	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb->mac_len);
 
 	/* skb_mpls_header() is used to locate the ethertype
 	 * field correctly in the presence of VLAN tags.
-- 
2.1.4
