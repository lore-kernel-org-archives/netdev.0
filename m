From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 02/11] net: allow early demux to fetch noref socket
Date: Fri, 22 Sep 2017 23:06:26 +0200
Message-ID: <e899d1802d51e022e47e88cff37ffcd2bf7a36cc.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752115AbdIVVHA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:00 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must be careful to avoid leaking such sockets outside
the RCU section containing the early demux call; we clear
them on nonlocal delivery.

For ipv4 we clear sknoref even for multicast traffic entering
the ip_mr_input() path; we will lose the mcast early demux
optimization when the host is acting as multicast router, but
that will help to keep to code simple.

Also update all iptables/nftables extension that can
happen in the input chain and can transmit the skb outside
such patch, namely TEE, nft_dup and nfqueue.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_input.c              | 8 ++++++++
 net/ipv4/netfilter/nf_dup_ipv4.c | 3 +++
 net/ipv6/ip6_input.c             | 4 ++++
 net/ipv6/netfilter/nf_dup_ipv6.c | 3 +++
 net/netfilter/nf_queue.c         | 3 +++
 5 files changed, 21 insertions(+)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index fa2dc8f692c6..5690ef09da28 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -351,6 +351,14 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+	/* Since the sk has no reference to the socket, we must
+	 * clear it before escaping this RCU section.
+	 * The sk is just an hint and we know we are not going to use
+	 * it outside the input path.
+	 */
+	if (skb_dst(skb)->input != ip_local_deliver)
+		skb_clear_noref_sk(skb);
+
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	if (unlikely(skb_dst(skb)->tclassid)) {
 		struct ip_rt_acct *st = this_cpu_ptr(ip_rt_acct);
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index 39895b9ddeb9..bf8b78492fc8 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -71,6 +71,9 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	nf_reset(skb);
 	nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 #endif
+	/* Avoid leaking noref sk outside the input path */
+	skb_clear_noref_sk(skb);
+
 	/*
 	 * If we are in PREROUTING/INPUT, decrease the TTL to mitigate potential
 	 * loops between two hosts.
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 9ee208a348f5..e15ec2d36b9e 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -68,6 +68,10 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (!skb_valid_dst(skb))
 		ip6_route_input(skb);
 
+	/* see comment on ipv4 edmux */
+	if (skb_dst(skb)->input != ip6_input)
+		skb_clear_noref_sk(skb);
+
 	return dst_input(skb);
 }
 
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 4a7ddeddbaab..939f6a2238f9 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -60,6 +60,9 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	nf_reset(skb);
 	nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
 #endif
+	/* Avoid leaking noref sk outside the input path */
+	skb_clear_noref_sk(skb);
+
 	if (hooknum == NF_INET_PRE_ROUTING ||
 	    hooknum == NF_INET_LOCAL_IN) {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index f7e21953b1de..100eff08cb51 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -145,6 +145,9 @@ static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
 		.size	= sizeof(*entry) + afinfo->route_key_size,
 	};
 
+	/* Avoid leaking noref sk outside the input path */
+	skb_clear_noref_sk(skb);
+
 	nf_queue_entry_get_refs(entry);
 	skb_dst_force(skb);
 	afinfo->saveroute(skb, entry);
-- 
2.13.5
