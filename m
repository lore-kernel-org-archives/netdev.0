From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: Check skb->rxhash in gro_receive
Date: Thu, 9 Jan 2014 20:54:09 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:38622 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaAJE7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:59:12 -0500
Received: by mail-pa0-f74.google.com with SMTP id fa1so579807pad.3
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 20:59:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initializing a gro_list for a packet, first check the rxhash of
the incoming skb against that of the skb's in the list. This should be
a very strong inidicator of whether the flow is going to be matched,
and potentially allows a lot of other checks to be short circuited.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847..88bf426 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3794,10 +3794,14 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 	unsigned int maclen = skb->dev->hard_header_len;
+	u32 hash = skb_get_hash(skb);
 
 	for (p = napi->gro_list; p; p = p->next) {
 		unsigned long diffs;
 
+		if ((diffs = (hash != p->rxhash)))
+			goto skip;
+
 		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |= p->vlan_tci ^ skb->vlan_tci;
 		if (maclen == ETH_HLEN)
@@ -3807,6 +3811,7 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 			diffs = memcmp(skb_mac_header(p),
 				       skb_gro_mac_header(skb),
 				       maclen);
+skip:
 		NAPI_GRO_CB(p)->same_flow = !diffs;
 		NAPI_GRO_CB(p)->flush = 0;
 	}
-- 
1.8.5.1
