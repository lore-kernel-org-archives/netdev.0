From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: reduce sparse warnings
Date: Sat, 29 Aug 2015 00:50:17 +0200
Message-ID: <1440802217-13080-10-git-send-email-pablo@netfilter.org>
References: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

bridge/netfilter/ebtables.c:290:26: warning: incorrect type in assignment (different modifiers)
-> remove __pure annotation.

ipv6/netfilter/ip6t_SYNPROXY.c:240:27: warning: cast from restricted __be16
-> switch ntohs to htons and vice versa.

netfilter/core.c:391:30: warning: symbol 'nfq_ct_nat_hook' was not declared. Should it be static?
-> delete it, got removed

net/netfilter/nf_synproxy_core.c:221:48: warning: cast to restricted __be32
-> Use __be32 instead of u32.

Tested with objdiff that these changes do not affect generated code.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c    |    2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    2 +-
 net/netfilter/core.c               |    3 ---
 net/netfilter/nf_synproxy_core.c   |    6 +++---
 4 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 18ca4b2..48b6b01 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -176,7 +176,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 	return 0;
 }
 
-static inline __pure
+static inline
 struct ebt_entry *ebt_next_entry(const struct ebt_entry *entry)
 {
 	return (void *)entry + entry->next_offset;
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index ebbb754..1e4bf99 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -237,7 +237,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	nth->ack_seq	= th->ack_seq;
 	tcp_flag_word(nth) = TCP_FLAG_ACK;
 	nth->doff	= tcp_hdr_size / 4;
-	nth->window	= ntohs(htons(th->window) >> opts->wscale);
+	nth->window	= htons(ntohs(th->window) >> opts->wscale);
 	nth->check	= 0;
 	nth->urg_ptr	= 0;
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 2a5a070..0b939b7 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -388,9 +388,6 @@ EXPORT_SYMBOL(nf_conntrack_destroy);
 struct nfq_ct_hook __rcu *nfq_ct_hook __read_mostly;
 EXPORT_SYMBOL_GPL(nfq_ct_hook);
 
-struct nfq_ct_nat_hook __rcu *nfq_ct_nat_hook __read_mostly;
-EXPORT_SYMBOL_GPL(nfq_ct_nat_hook);
-
 #endif /* CONFIG_NF_CONNTRACK */
 
 #ifdef CONFIG_NF_NAT_NEEDED
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 8fbbdb0..888b955 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -188,7 +188,7 @@ unsigned int synproxy_tstamp_adjust(struct sk_buff *skb,
 				    const struct nf_conn_synproxy *synproxy)
 {
 	unsigned int optoff, optend;
-	u32 *ptr, old;
+	__be32 *ptr, old;
 
 	if (synproxy->tsoff == 0)
 		return 1;
@@ -216,12 +216,12 @@ unsigned int synproxy_tstamp_adjust(struct sk_buff *skb,
 			if (op[0] == TCPOPT_TIMESTAMP &&
 			    op[1] == TCPOLEN_TIMESTAMP) {
 				if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY) {
-					ptr = (u32 *)&op[2];
+					ptr = (__be32 *)&op[2];
 					old = *ptr;
 					*ptr = htonl(ntohl(*ptr) -
 						     synproxy->tsoff);
 				} else {
-					ptr = (u32 *)&op[6];
+					ptr = (__be32 *)&op[6];
 					old = *ptr;
 					*ptr = htonl(ntohl(*ptr) +
 						     synproxy->tsoff);
-- 
1.7.10.4

