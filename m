From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/5] net: allow early demux to fetch noref socket
Date: Wed, 20 Sep 2017 18:54:02 +0200
Message-ID: <db75c6a6872040712a9ab97b0bac04b697c42a4c.1505926196.git.pabeni@redhat.com>
References: <cover.1505926196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQ6M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:58:12 -0400
In-Reply-To: <cover.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must be careful to avoid leaking such sockets outside
the RCU section containing the early demux call; we clear
them on nonlocal delivery.

For ipv4 we must take care of local mcast delivery, too,
since udp early demux works also for mcast addresses.

Also update all iptables/nftables extension that can
happen in the input chain and can transmit the skb outside
such patch, namely TEE, nft_dup and nfqueue.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_input.c              | 12 ++++++++++++
 net/ipv4/ipmr.c                  | 18 ++++++++++++++----
 net/ipv4/netfilter/nf_dup_ipv4.c |  3 +++
 net/ipv6/ip6_input.c             |  7 ++++++-
 net/ipv6/netfilter/nf_dup_ipv6.c |  3 +++
 net/netfilter/nf_queue.c         |  3 +++
 6 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index fa2dc8f692c6..e71abc8b698c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -349,6 +349,18 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 				__NET_INC_STATS(net, LINUX_MIB_IPRPFILTER);
 			goto drop;
 		}
+
+		/* Since the sk has no reference to the socket, we must
+		 * clear it before escaping this RCU section.
+		 * The sk is just an hint and we know we are not going to use
+		 * it outside the input path.
+		 */
+		if (skb_dst(skb)->input != ip_local_deliver
+#ifdef CONFIG_IP_MROUTE
+		    && skb_dst(skb)->input != ip_mr_input
+#endif
+		    )
+			skb_clear_noref_sk(skb);
 	}
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c9b3e6e069ae..76642af79038 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1978,11 +1978,12 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
  */
 int ip_mr_input(struct sk_buff *skb)
 {
-	struct mfc_cache *cache;
-	struct net *net = dev_net(skb->dev);
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
-	struct mr_table *mrt;
+	struct net *net = dev_net(skb->dev);
+	struct mfc_cache *cache;
 	struct net_device *dev;
+	struct mr_table *mrt;
+	struct sock *sk;
 
 	/* skb->dev passed in is the loX master dev for vrfs.
 	 * As there are no vifs associated with loopback devices,
@@ -2052,6 +2053,9 @@ int ip_mr_input(struct sk_buff *skb)
 			skb = skb2;
 		}
 
+		/* avoid leaking the noref sk on forward path */
+		skb_clear_noref_sk(skb);
+
 		read_lock(&mrt_lock);
 		vif = ipmr_find_vif(mrt, dev);
 		if (vif >= 0) {
@@ -2065,12 +2069,18 @@ int ip_mr_input(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
+	/* avoid leaking the noref sk on forward path... */
+	sk = skb_clear_noref_sk(skb);
 	read_lock(&mrt_lock);
 	ip_mr_forward(net, mrt, dev, skb, cache, local);
 	read_unlock(&mrt_lock);
 
-	if (local)
+	if (local) {
+		/* ... but preserve it for local delivery */
+		if (sk)
+			skb_set_noref_sk(skb, sk);
 		return ip_local_deliver(skb);
+	}
 
 	return 0;
 
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
index 9ee208a348f5..9aa6baffd4b9 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -65,9 +65,14 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		if (ipprot && (edemux = READ_ONCE(ipprot->early_demux)))
 			edemux(skb);
 	}
-	if (!skb_valid_dst(skb))
+	if (!skb_valid_dst(skb)) {
 		ip6_route_input(skb);
 
+		/* see comment on ipv4 edmux */
+		if (skb_dst(skb)->input != ip6_input)
+			skb_clear_noref_sk(skb);
+	}
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
