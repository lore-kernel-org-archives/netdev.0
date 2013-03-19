From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v2 net-next 1/4] flow_keys: include thoff into flow_keys for later usage
Date: Tue, 19 Mar 2013 15:34:00 +0100
Message-ID: <cc0d2911a173be99651dc39e77286aab260c3c19.1363702456.git.dborkman@redhat.com>
References: <cover.1363702456.git.dborkman@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab3CSOeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 10:34:07 -0400
In-Reply-To: <cover.1363702456.git.dborkman@redhat.com>
In-Reply-To: <cover.1363702456.git.dborkman@redhat.com>
References: <cover.1363702456.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
doing the work here anyway, also store thoff for a later usage, e.g. in
the BPF filter. Also, by having thoff 16 Bit, we do not need to pack
flow_keys and reorder choke_skb_cb.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 This patch also needs to go into the net tree, since Eric or Jason will
 post a bug fix on top of this one.

 include/net/flow_keys.h   | 1 +
 net/core/flow_dissector.c | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 80461c1..bb8271d 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -9,6 +9,7 @@ struct flow_keys {
 		__be32 ports;
 		__be16 port16[2];
 	};
+	u16 thoff;
 	u8 ip_proto;
 };
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index f8d9e03..eb9dde1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -23,7 +23,8 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
 
 bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
 {
-	int poff, nhoff = skb_network_offset(skb);
+	int poff;
+	u16 nhoff = skb_network_offset(skb);
 	u8 ip_proto;
 	__be16 proto = skb->protocol;
 
@@ -151,6 +152,8 @@ ipv6:
 			flow->ports = *ports;
 	}
 
+	flow->thoff = nhoff;
+
 	return true;
 }
 EXPORT_SYMBOL(skb_flow_dissect);
-- 
1.7.11.7
