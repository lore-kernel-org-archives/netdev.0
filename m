From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ip_route_input panic fix
Date: Mon, 17 Apr 2006 17:12:53 -0700
Message-ID: <20060417171253.4e988afc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10374 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932071AbWDRANA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 20:13:00 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes http://bugzilla.kernel.org/show_bug.cgi?id=6388
The bug is caused by ip_route_input dereferencing skb->nh.protocol of
the dummy skb passed dow from inet_rtm_getroute (Thanks Thomas for seeing
it). It only happens if the route requested is for a multicast IP
address.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.16.6.orig/net/ipv4/route.c
+++ linux-2.6.16.6/net/ipv4/route.c
@@ -2750,7 +2750,10 @@ int inet_rtm_getroute(struct sk_buff *in
 	/* Reserve room for dummy headers, this skb can pass
 	   through good chunk of routing engine.
 	 */
-	skb->mac.raw = skb->data;
+	skb->mac.raw = skb->nh.raw = skb->data;
+
+	/* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
+	skb->nh.iph->protocol = IPPROTO_ICMP;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
 	if (rta[RTA_SRC - 1])
