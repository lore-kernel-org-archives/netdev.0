From: pablo@netfilter.org
Subject: [PATCH 6/6] netfilter: nf_nat: Handle routing changes in MASQUERADE target
Date: Tue,  4 Dec 2012 18:31:33 +0100
Message-ID: <1354642293-4114-7-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When the route changes (backup default route, VPNs) which affect a
masqueraded target, the packets were sent out with the outdated source
address. The patch addresses the issue by comparing the outgoing interface
directly with the masqueraded interface in the nat table.

Events are inefficient in this case, because it'd require adding route
events to the network core and then scanning the whole conntrack table
and re-checking the route for all entry.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat.h    |   15 +++++++++++++++
 net/ipv4/netfilter/iptable_nat.c  |    4 ++++
 net/ipv6/netfilter/ip6table_nat.c |    4 ++++
 3 files changed, 23 insertions(+)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index bd8eea7..ad14a79 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -68,4 +68,19 @@ static inline struct nf_conn_nat *nfct_nat(const struct nf_conn *ct)
 #endif
 }
 
+static inline bool nf_nat_oif_changed(unsigned int hooknum,
+				      enum ip_conntrack_info ctinfo,
+				      struct nf_conn_nat *nat,
+				      const struct net_device *out)
+{
+#if IS_ENABLED(CONFIG_IP_NF_TARGET_MASQUERADE) || \
+    IS_ENABLED(CONFIG_IP6_NF_TARGET_MASQUERADE)
+	return nat->masq_index && hooknum == NF_INET_POST_ROUTING &&
+	       CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL &&
+	       nat->masq_index != out->ifindex;
+#else
+	return false;
+#endif
+}
+
 #endif
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index ac635a7..da2c8a3 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -134,6 +134,10 @@ nf_nat_ipv4_fn(unsigned int hooknum,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
+		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out)) {
+			nf_ct_kill_acct(ct, ctinfo, skb);
+			return NF_DROP;
+		}
 	}
 
 	return nf_nat_packet(ct, ctinfo, hooknum, skb);
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index fa84cf8..6c8ae24 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -137,6 +137,10 @@ nf_nat_ipv6_fn(unsigned int hooknum,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
+		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out)) {
+			nf_ct_kill_acct(ct, ctinfo, skb);
+			return NF_DROP;
+		}
 	}
 
 	return nf_nat_packet(ct, ctinfo, hooknum, skb);
-- 
1.7.10.4

