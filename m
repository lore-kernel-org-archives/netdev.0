From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/9] openvswitch: call only into reachable nf-nat code
Date: Mon, 28 Mar 2016 19:57:56 +0200
Message-ID: <1459187882-5357-4-git-send-email-pablo@netfilter.org>
References: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50841 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbcC1R6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 13:58:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C45ADE83A1
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7C9DCDA8FA
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C6C66DA8FA
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:09 +0200 (CEST)
In-Reply-To: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

The openvswitch code has gained support for calling into the
nf-nat-ipv4/ipv6 modules, however those can be loadable modules
in a configuration in which openvswitch is built-in, leading
to link errors:

net/built-in.o: In function `__ovs_ct_lookup':
:(.text+0x2cc2c8): undefined reference to `nf_nat_icmp_reply_translation'
:(.text+0x2cc66c): undefined reference to `nf_nat_icmpv6_reply_translation'

The dependency on (!NF_NAT || NF_NAT) prevents similar issues,
but NF_NAT is set to 'y' if any of the symbols selecting
it are built-in, but the link error happens when any of them
are modular.

A second issue is that even if CONFIG_NF_NAT_IPV6 is built-in,
CONFIG_NF_NAT_IPV4 might be completely disabled. This is unlikely
to be useful in practice, but the driver currently only handles
IPv6 being optional.

This patch improves the Kconfig dependency so that openvswitch
cannot be built-in if either of the two other symbols are set
to 'm', and it replaces the incorrect #ifdef in ovs_ct_nat_execute()
with two "if (IS_ENABLED())" checks that should catch all corner
cases also make the code more readable.

The same #ifdef exists ovs_ct_nat_to_attr(), where it does not
cause a link error, but for consistency I'm changing it the same
way.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 05752523e565 ("openvswitch: Interface with NAT.")
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/openvswitch/Kconfig     |  4 +++-
 net/openvswitch/conntrack.c | 16 ++++++++--------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 234a733..ce94729 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -7,7 +7,9 @@ config OPENVSWITCH
 	depends on INET
 	depends on !NF_CONNTRACK || \
 		   (NF_CONNTRACK && ((!NF_DEFRAG_IPV6 || NF_DEFRAG_IPV6) && \
-				     (!NF_NAT || NF_NAT)))
+				     (!NF_NAT || NF_NAT) && \
+				     (!NF_NAT_IPV4 || NF_NAT_IPV4) && \
+				     (!NF_NAT_IPV6 || NF_NAT_IPV6)))
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 47f7c62..3797879 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -535,14 +535,15 @@ static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *ct,
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED_REPLY:
-		if (skb->protocol == htons(ETH_P_IP) &&
+		if (IS_ENABLED(CONFIG_NF_NAT_IPV4) &&
+		    skb->protocol == htons(ETH_P_IP) &&
 		    ip_hdr(skb)->protocol == IPPROTO_ICMP) {
 			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
 							   hooknum))
 				err = NF_DROP;
 			goto push;
-#if IS_ENABLED(CONFIG_NF_NAT_IPV6)
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (IS_ENABLED(CONFIG_NF_NAT_IPV6) &&
+			   skb->protocol == htons(ETH_P_IPV6)) {
 			__be16 frag_off;
 			u8 nexthdr = ipv6_hdr(skb)->nexthdr;
 			int hdrlen = ipv6_skip_exthdr(skb,
@@ -557,7 +558,6 @@ static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *ct,
 					err = NF_DROP;
 				goto push;
 			}
-#endif
 		}
 		/* Non-ICMP, fall thru to initialize if needed. */
 	case IP_CT_NEW:
@@ -1239,7 +1239,8 @@ static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *info,
 	}
 
 	if (info->range.flags & NF_NAT_RANGE_MAP_IPS) {
-		if (info->family == NFPROTO_IPV4) {
+		if (IS_ENABLED(CONFIG_NF_NAT_IPV4) &&
+		    info->family == NFPROTO_IPV4) {
 			if (nla_put_in_addr(skb, OVS_NAT_ATTR_IP_MIN,
 					    info->range.min_addr.ip) ||
 			    (info->range.max_addr.ip
@@ -1247,8 +1248,8 @@ static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *info,
 			     (nla_put_in_addr(skb, OVS_NAT_ATTR_IP_MAX,
 					      info->range.max_addr.ip))))
 				return false;
-#if IS_ENABLED(CONFIG_NF_NAT_IPV6)
-		} else if (info->family == NFPROTO_IPV6) {
+		} else if (IS_ENABLED(CONFIG_NF_NAT_IPV6) &&
+			   info->family == NFPROTO_IPV6) {
 			if (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MIN,
 					     &info->range.min_addr.in6) ||
 			    (memcmp(&info->range.max_addr.in6,
@@ -1257,7 +1258,6 @@ static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *info,
 			     (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MAX,
 					       &info->range.max_addr.in6))))
 				return false;
-#endif
 		} else {
 			return false;
 		}
-- 
2.1.4
