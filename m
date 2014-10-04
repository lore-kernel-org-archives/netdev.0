From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf next 1/3] bridge: prepend inet_skb_param dummy to bridge cb
Date: Sat,  4 Oct 2014 03:04:28 +0200
Message-ID: <1412384670-17794-2-git-send-email-fw@strlen.de>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
Cc: bsd@redhat.com, stephen@networkplumber.org, netdev@cger.kernel.org,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	davidn@davidnewall.com, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412384670-17794-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bridge can make upcalls into the ip stack, especially
when bridge netfilter is involved, we can end up calling ip_fragment().

IPv4 functions, however, may (rightfully) depend on skb->cb[]
containing the IPCB area, where eg. earlier-parsed ip options
reside.

However, since bridge has its own cb area, this has caused several
crashes in the past, and several call sites in br_netfilter since
zero ->cb again before invoking netfilter hooks.

We've tried to cure these in the past by applying memsets of skb->cb
where needed, and parsing ip options within the bridge layer.

This isn't such a great idea since we e.g. lose max fragment size
information stored there via ipv4 defrag.

Also, since 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP
stack) bridge handling of received packets with ipv4 options is broken
in different ways (crash, then discarding of such packets).

This patch, originally proposed by Eric Dumazet, prepends
inet_skb_param padding so IPCB contents will be preserved (e.g.
ipv4 defrag info).

This is a first step in fixing handling of ipv4 packets with options.

br_input_skb_cb is now exactly 48 bytes.

Cc: Bandan Das <bsd@redhat.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br.c         | 2 ++
 net/bridge/br_private.h | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 44425af..4ee730e 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -147,6 +147,8 @@ static int __init br_init(void)
 {
 	int err;
 
+	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
+
 	err = stp_proto_register(&br_stp_proto);
 	if (err < 0) {
 		pr_err("bridge: can't register sap for STP\n");
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f53592f..559938f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -19,6 +19,8 @@
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
 #include <linux/if_vlan.h>
+#include <linux/ipv6.h>
+#include <net/ip.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -304,6 +306,10 @@ struct net_bridge
 };
 
 struct br_input_skb_cb {
+	union {
+		struct inet_skb_parm inet4_parm;
+		struct inet6_skb_parm inet6_param;
+	} inet_parm;
 	struct net_device *brdev;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
-- 
2.0.4

