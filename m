From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 1/2] gre: fix hard header destination address checking
Date: Wed,  3 Mar 2010 16:01:13 +0200
Message-ID: <1267624874-22326-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:47207 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754211Ab0CCOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:01:50 -0500
Received: by ewy20 with SMTP id 20so924178ewy.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 06:01:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_header() can be called with zero daddr when the gre device is
configured as multipoint tunnel and still has the NOARP flag set (which is
typically cleared by the userspace arp daemon).  If the NOARP packets are
not dropped, ipgre_tunnel_xmit() will take rt->rt_gateway (= NBMA IP) and
use that for route look up (and may lead to bogus xfrm acquires).

The multicast address check is removed as sending to multicast group should
be ok.  In fact, if gre device has a multicast address as destination
ipgre_header is always called with multicast address.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/ipv4/ip_gre.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c0c5274..f47c9f7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1144,12 +1144,9 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 
 	if (saddr)
 		memcpy(&iph->saddr, saddr, 4);
-
-	if (daddr) {
+	if (daddr)
 		memcpy(&iph->daddr, daddr, 4);
-		return t->hlen;
-	}
-	if (iph->daddr && !ipv4_is_multicast(iph->daddr))
+	if (iph->daddr)
 		return t->hlen;
 
 	return -t->hlen;
-- 
1.6.3.3

