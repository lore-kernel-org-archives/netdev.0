From: Daniele Di Proietto <diproiettod@ovn.org>
Subject: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Mon, 28 Nov 2016 15:43:53 -0800
Message-ID: <20161128234353.4262-1-diproiettod@ovn.org>
Cc: Daniele Di Proietto <diproiettod@ovn.org>,
        Florian Westphal <fw@strlen.de>,
        Pravin B Shelar <pshelar@ovn.org>, Joe Stringer <joe@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36209 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754432AbcK1Xn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:43:58 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so14419767pgx.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 15:43:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
means that we still have a reference to the skb.  We should free it
before returning from handle_fragments, as stated in the comment above.

Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
CC: Florian Westphal <fw@strlen.de>
CC: Pravin B Shelar <pshelar@ovn.org>
CC: Joe Stringer <joe@ovn.org>
Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>
---
 net/openvswitch/conntrack.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 31045ef..fecefa2 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -370,8 +370,11 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		skb_orphan(skb);
 		memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
 		err = nf_ct_frag6_gather(net, skb, user);
-		if (err)
+		if (err) {
+			if (err != -EINPROGRESS)
+				kfree_skb(skb);
 			return err;
+		}
 
 		key->ip.proto = ipv6_hdr(skb)->nexthdr;
 		ovs_cb.mru = IP6CB(skb)->frag_max_size;
-- 
2.10.2
