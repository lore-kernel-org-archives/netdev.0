From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: icmp_route_lookup should use rt dev to determine L3 domain
Date: Thu,  3 Nov 2016 10:13:39 -0700
Message-ID: <1478193219-5288-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32945 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759055AbcKCRNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:13:44 -0400
Received: by mail-pf0-f178.google.com with SMTP id d2so34930139pfd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:13:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

icmp_send is called in response to some event. The skb may not have
the device set (skb->dev is NULL), but it is expected to have an rt.
Update icmp_route_lookup to use the rt on the skb to determine L3
domain.

Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/icmp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 38abe70e595f..774a15e9f041 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -477,7 +477,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
-	fl4->flowi4_oif = l3mdev_master_ifindex(skb_in->dev);
+	fl4->flowi4_oif = l3mdev_master_ifindex(skb_rtable(skb_in)->dst.dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key_hash(net, fl4,
@@ -502,7 +502,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type_dev_table(net, skb_in->dev,
+	if (inet_addr_type_dev_table(net, skb_rtable(skb_in)->dst.dev,
 				     fl4_dec.saddr) == RTN_LOCAL) {
 		rt2 = __ip_route_output_key(net, &fl4_dec);
 		if (IS_ERR(rt2))
-- 
2.1.4
