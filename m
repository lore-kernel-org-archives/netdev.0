From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Disable forwarding of LRO skbs
Date: Wed, 30 Apr 2008 22:51:26 +0100
Message-ID: <20080430215125.GD14219@solarflare.com>
References: <20080430214845.GC14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:36649 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763988AbYD3Vvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:51:32 -0400
Content-Disposition: inline
In-Reply-To: <20080430214845.GC14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_warn_if_lro() to test whether an skb was received with LRO and
warn if so.

Change br_forward(), ip_forward() and ip6_forward() to call
skb_warn_if_lro() and discard the skb if it returns true.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11fd9f2..18644cd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1701,6 +1701,8 @@ static inline int skb_is_gso_v6(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
 
+extern bool skb_warn_if_lro(const struct sk_buff *skb);
+
 static inline void skb_forward_csum(struct sk_buff *skb)
 {
 	/* Unfortunately we don't support this one.  Any brave souls? */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4fe605f..bfd80c6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2582,6 +2582,15 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 	return true;
 }
 
+bool skb_warn_if_lro(const struct sk_buff *skb)
+{
+	bool ret = unlikely(skb_is_gso(skb));
+	if (ret && net_ratelimit())
+		pr_warning("%s: received packets cannot be forwarded"
+			   " while LRO is enabled\n", skb->dev->name);
+	return ret;
+}
+
 EXPORT_SYMBOL(___pskb_trim);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(kfree_skb);
@@ -2615,6 +2624,7 @@ EXPORT_SYMBOL(skb_seq_read);
 EXPORT_SYMBOL(skb_abort_seq_read);
 EXPORT_SYMBOL(skb_find_text);
 EXPORT_SYMBOL(skb_append_datato_frags);
+EXPORT_SYMBOL(skb_warn_if_lro);
 
 EXPORT_SYMBOL_GPL(skb_to_sgvec);
 EXPORT_SYMBOL_GPL(skb_cow_data);
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index bdd7c35..cfee7c2 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -91,7 +91,7 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 /* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
-	if (should_deliver(to, skb)) {
+	if (!skb_warn_if_lro(skb) && should_deliver(to, skb)) {
 		__br_forward(to, skb);
 		return;
 	}
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 4813c39..a6e4cfa 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -58,6 +58,9 @@ int ip_forward(struct sk_buff *skb)
 	struct rtable *rt;	/* Route we use */
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
+	if (skb_warn_if_lro(skb))
+		goto drop;
+
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_FWD, skb))
 		goto drop;
 
@@ -85,7 +88,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->u.dst) && !skb_is_gso(skb) &&
+	if (unlikely(skb->len > dst_mtu(&rt->u.dst) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0af2e05..c7f4eec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -409,6 +409,9 @@ int ip6_forward(struct sk_buff *skb)
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
 
+	if (skb_warn_if_lro(skb))
+		goto drop;
+
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
 		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
