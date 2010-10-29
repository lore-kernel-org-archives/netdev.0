From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 2/3] offloading: Support multiple vlan tags in GSO.
Date: Fri, 29 Oct 2010 15:14:54 -0700
Message-ID: <1288390495-28923-2-git-send-email-jesse@nicira.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50140 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932982Ab0J2WPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:15:04 -0400
Received: by mail-qw0-f46.google.com with SMTP id 7so2743176qwf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 15:15:03 -0700 (PDT)
In-Reply-To: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We assume that hardware TSO can't support multiple levels of vlan tags
but we allow it to be done.  Therefore, enable GSO to parse these tags
so we can fallback to software.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d21d655..8bdda70 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1794,16 +1794,18 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
 	__be16 type = skb->protocol;
+	int vlan_depth = ETH_HLEN;
 	int err;
 
-	if (type == htons(ETH_P_8021Q)) {
-		struct vlan_ethhdr *veh;
+	while (type == htons(ETH_P_8021Q)) {
+		struct vlan_hdr *vh;
 
-		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
+		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
 			return ERR_PTR(-EINVAL);
 
-		veh = (struct vlan_ethhdr *)skb->data;
-		type = veh->h_vlan_encapsulated_proto;
+		vh = (struct vlan_hdr *)(skb->data + vlan_depth);
+		type = vh->h_vlan_encapsulated_proto;
+		vlan_depth += VLAN_HLEN;
 	}
 
 	skb_reset_mac_header(skb);
-- 
1.7.1

