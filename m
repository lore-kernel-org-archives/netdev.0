From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v3 2/2] net:  Check skb->rxhash in gro_receive
Date: Wed, 15 Jan 2014 08:58:06 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401150853400.14933@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34006 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbaAOQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:58:07 -0500
Received: by mail-ig0-f202.google.com with SMTP id uq10so509549igb.1
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:58:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initializing a gro_list for a packet, first check the rxhash of
the incoming skb against that of the skb's in the list. This should be
a very strong inidicator of whether the flow is going to be matched,
and potentially allows a lot of other checks to be short circuited.
Use skb_hash_raw so that we don't force the hash to be calculated.

Tested by running netperf 200 TCP_STREAMs between two machines with
GRO, HW rxhash, and 1G. Saw no performance degration, slight reduction
of time in dev_gro_receive.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 20c834e..c063c7c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3818,10 +3818,18 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 	unsigned int maclen = skb->dev->hard_header_len;
+	u32 hash = skb_get_hash_raw(skb);
 
 	for (p = napi->gro_list; p; p = p->next) {
 		unsigned long diffs;
 
+		NAPI_GRO_CB(p)->flush = 0;
+
+		if (hash != skb_get_hash_raw(p)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
 		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |= p->vlan_tci ^ skb->vlan_tci;
 		if (maclen == ETH_HLEN)
@@ -3832,7 +3840,6 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 				       skb_gro_mac_header(skb),
 				       maclen);
 		NAPI_GRO_CB(p)->same_flow = !diffs;
-		NAPI_GRO_CB(p)->flush = 0;
 	}
 }
 
-- 
1.8.5.2
