From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] net: Discard and warn about LRO'd skbs received for forwarding
Date: Thu, 19 Jun 2008 19:08:34 +0100
Message-ID: <20080619180833.GU5350@solarflare.com>
References: <cover.1213898165.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:55514 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752835AbYFSSIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:08:39 -0400
Content-Disposition: inline
In-Reply-To: <cover.1213898165.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_warn_if_lro() to test whether an skb was received with LRO and
warn if so.

Change br_forward(), ip_forward() and ip6_forward() to call it) and
discard the skb if it returns true.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/skbuff.h  |   14 ++++++++++++++
 net/bridge/br_forward.c |    2 +-
 net/core/skbuff.c       |    8 ++++++++
 net/ipv4/ip_forward.c   |    3 +++
 net/ipv6/ip6_output.c   |    3 +++
 5 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..2220b9e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1702,6 +1702,20 @@ static inline int skb_is_gso_v6(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
 
+extern void __skb_warn_lro_forwarding(const struct sk_buff *skb);
+
+static inline bool skb_warn_if_lro(const struct sk_buff *skb)
+{
+	/* LRO sets gso_size but not gso_type, whereas if GSO is really
+	 * wanted then gso_type will be set. */
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	if (shinfo->gso_size != 0 && unlikely(shinfo->gso_type == 0)) {
+		__skb_warn_lro_forwarding(skb);
+		return true;
+	}
+	return false;
+}
+
 static inline void skb_forward_csum(struct sk_buff *skb)
 {
 	/* Unfortunately we don't support this one.  Any brave souls? */
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 5126457..bdd9cce 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -89,7 +89,7 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 /* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
-	if (should_deliver(to, skb)) {
+	if (!skb_warn_if_lro(skb) && should_deliver(to, skb)) {
 		__br_forward(to, skb);
 		return;
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3e18f85..2df012b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2583,6 +2583,13 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 	return true;
 }
 
+void __skb_warn_lro_forwarding(const struct sk_buff *skb)
+{
+	if (net_ratelimit())
+		pr_warning("%s: received packets cannot be forwarded"
+			   " while LRO is enabled\n", skb->dev->name);
+}
+
 EXPORT_SYMBOL(___pskb_trim);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(kfree_skb);
@@ -2616,6 +2623,7 @@ EXPORT_SYMBOL(skb_seq_read);
 EXPORT_SYMBOL(skb_abort_seq_read);
 EXPORT_SYMBOL(skb_find_text);
 EXPORT_SYMBOL(skb_append_datato_frags);
+EXPORT_SYMBOL(__skb_warn_lro_forwarding);
 
 EXPORT_SYMBOL_GPL(skb_to_sgvec);
 EXPORT_SYMBOL_GPL(skb_cow_data);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 37d36a3..da14725 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -56,6 +56,9 @@ int ip_forward(struct sk_buff *skb)
 	struct rtable *rt;	/* Route we use */
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
+	if (skb_warn_if_lro(skb))
+		goto drop;
+
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_FWD, skb))
 		goto drop;
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40a2813..fd7cd1b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -407,6 +407,9 @@ int ip6_forward(struct sk_buff *skb)
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
