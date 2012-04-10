From: pablo@netfilter.org
Subject: [PATCH 2/5] netfilter: ip6_tables: ip6t_ext_hdr is now static inline
Date: Tue, 10 Apr 2012 14:48:58 +0200
Message-ID: <1334062141-3962-3-git-send-email-pablo@netfilter.org>
References: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44934 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758632Ab2DJMtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 08:49:19 -0400
In-Reply-To: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

We may hit this in xt_LOG:

net/built-in.o:xt_LOG.c:function dump_ipv6_packet:
	error: undefined reference to 'ip6t_ext_hdr'

happens with these config options:

CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_IP6_NF_IPTABLES=m

ip6t_ext_hdr is fairly small and it is called in the packet path.
Make it static inline.

Reported-by: Simon Kirby <sim@netnation.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ipv6/ip6_tables.h |   12 +++++++++++-
 net/ipv6/netfilter/ip6_tables.c           |   14 --------------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index f549adc..1bc898b 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -287,7 +287,17 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  struct xt_table *table);
 
 /* Check for an extension */
-extern int ip6t_ext_hdr(u8 nexthdr);
+static inline int
+ip6t_ext_hdr(u8 nexthdr)
+{	return (nexthdr == IPPROTO_HOPOPTS) ||
+	       (nexthdr == IPPROTO_ROUTING) ||
+	       (nexthdr == IPPROTO_FRAGMENT) ||
+	       (nexthdr == IPPROTO_ESP) ||
+	       (nexthdr == IPPROTO_AH) ||
+	       (nexthdr == IPPROTO_NONE) ||
+	       (nexthdr == IPPROTO_DSTOPTS);
+}
+
 /* find specified header and get offset to it */
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 			 int target, unsigned short *fragoff);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 94874b0..9d4e155 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -78,19 +78,6 @@ EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
 
    Hence the start of any table is given by get_table() below.  */
 
-/* Check for an extension */
-int
-ip6t_ext_hdr(u8 nexthdr)
-{
-	return  (nexthdr == IPPROTO_HOPOPTS)   ||
-		(nexthdr == IPPROTO_ROUTING)   ||
-		(nexthdr == IPPROTO_FRAGMENT)  ||
-		(nexthdr == IPPROTO_ESP)       ||
-		(nexthdr == IPPROTO_AH)        ||
-		(nexthdr == IPPROTO_NONE)      ||
-		(nexthdr == IPPROTO_DSTOPTS);
-}
-
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
@@ -2366,7 +2353,6 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
-EXPORT_SYMBOL(ip6t_ext_hdr);
 EXPORT_SYMBOL(ipv6_find_hdr);
 
 module_init(ip6_tables_init);
-- 
1.7.2.5
