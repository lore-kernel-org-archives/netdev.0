From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] openvswitch: Make IPv6 packet parsing dependent on IPv6 config
Date: Fri, 16 Nov 2012 10:43:03 -0500
Message-ID: <1353080583-14432-1-git-send-email-vyasevic@redhat.com>
References: <50a5c2e5.lgIvZwesNLp78CVD%fengguang.wu@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab2KPPnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 10:43:05 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qAGFh5GL009699
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 10:43:05 -0500
In-Reply-To: <50a5c2e5.lgIvZwesNLp78CVD%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Openvswitch attempts to use IPv6 packet parsing functions without
any dependency on IPv6 (unlike every other place in kernel).  Pull
the IPv6 code in openvswitch togeter and put a conditional that's
dependent on CONFIG_IPV6.

Resolves:
net/built-in.o: In function `ovs_flow_extract':
(.text+0xbf5d5): undefined reference to `ipv6_skip_exthdr'

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/openvswitch/flow.c |  168 ++++++++++++++++++++++++-----------------------
 1 files changed, 86 insertions(+), 82 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 98c7063..6dfaf60 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -124,6 +124,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 	(offsetof(struct sw_flow_key, field) +	\
 	 FIELD_SIZEOF(struct sw_flow_key, field))
 
+#if IS_ENABLED(CONFIG_IPV6)
 static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key,
 			 int *key_lenp)
 {
@@ -175,6 +176,89 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr));
 }
 
+static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
+			int *key_lenp, int nh_len)
+{
+	struct icmp6hdr *icmp = icmp6_hdr(skb);
+	int error = 0;
+	int key_len;
+
+	/* The ICMPv6 type and code fields use the 16-bit transport port
+	 * fields, so we need to store them in 16-bit network byte order.
+	 */
+	key->ipv6.tp.src = htons(icmp->icmp6_type);
+	key->ipv6.tp.dst = htons(icmp->icmp6_code);
+	key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+
+	if (icmp->icmp6_code == 0 &&
+	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
+	     icmp->icmp6_type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
+		int icmp_len = skb->len - skb_transport_offset(skb);
+		struct nd_msg *nd;
+		int offset;
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
+
+		/* In order to process neighbor discovery options, we need the
+		 * entire packet.
+		 */
+		if (unlikely(icmp_len < sizeof(*nd)))
+			goto out;
+		if (unlikely(skb_linearize(skb))) {
+			error = -ENOMEM;
+			goto out;
+		}
+
+		nd = (struct nd_msg *)skb_transport_header(skb);
+		key->ipv6.nd.target = nd->target;
+		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
+
+		icmp_len -= sizeof(*nd);
+		offset = 0;
+		while (icmp_len >= 8) {
+			struct nd_opt_hdr *nd_opt =
+				 (struct nd_opt_hdr *)(nd->opt + offset);
+			int opt_len = nd_opt->nd_opt_len * 8;
+
+			if (unlikely(!opt_len || opt_len > icmp_len))
+				goto invalid;
+
+			/* Store the link layer address if the appropriate
+			 * option is provided.  It is considered an error if
+			 * the same link layer option is specified twice.
+			 */
+			if (nd_opt->nd_opt_type == ND_OPT_SOURCE_LL_ADDR
+			    && opt_len == 8) {
+				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.sll)))
+					goto invalid;
+				memcpy(key->ipv6.nd.sll,
+				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+			} else if (nd_opt->nd_opt_type == ND_OPT_TARGET_LL_ADDR
+				   && opt_len == 8) {
+				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.tll)))
+					goto invalid;
+				memcpy(key->ipv6.nd.tll,
+				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+			}
+
+			icmp_len -= opt_len;
+			offset += opt_len;
+		}
+	}
+
+	goto out;
+
+invalid:
+	memset(&key->ipv6.nd.target, 0, sizeof(key->ipv6.nd.target));
+	memset(key->ipv6.nd.sll, 0, sizeof(key->ipv6.nd.sll));
+	memset(key->ipv6.nd.tll, 0, sizeof(key->ipv6.nd.tll));
+
+out:
+	*key_lenp = key_len;
+	return error;
+}
+#endif
+
 #define TCP_FLAGS_OFFSET 13
 #define TCP_FLAG_MASK 0x3f
 
@@ -487,88 +571,6 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 	return llc->ethertype;
 }
 
-static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
-			int *key_lenp, int nh_len)
-{
-	struct icmp6hdr *icmp = icmp6_hdr(skb);
-	int error = 0;
-	int key_len;
-
-	/* The ICMPv6 type and code fields use the 16-bit transport port
-	 * fields, so we need to store them in 16-bit network byte order.
-	 */
-	key->ipv6.tp.src = htons(icmp->icmp6_type);
-	key->ipv6.tp.dst = htons(icmp->icmp6_code);
-	key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
-
-	if (icmp->icmp6_code == 0 &&
-	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
-	     icmp->icmp6_type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
-		int icmp_len = skb->len - skb_transport_offset(skb);
-		struct nd_msg *nd;
-		int offset;
-
-		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
-
-		/* In order to process neighbor discovery options, we need the
-		 * entire packet.
-		 */
-		if (unlikely(icmp_len < sizeof(*nd)))
-			goto out;
-		if (unlikely(skb_linearize(skb))) {
-			error = -ENOMEM;
-			goto out;
-		}
-
-		nd = (struct nd_msg *)skb_transport_header(skb);
-		key->ipv6.nd.target = nd->target;
-		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
-
-		icmp_len -= sizeof(*nd);
-		offset = 0;
-		while (icmp_len >= 8) {
-			struct nd_opt_hdr *nd_opt =
-				 (struct nd_opt_hdr *)(nd->opt + offset);
-			int opt_len = nd_opt->nd_opt_len * 8;
-
-			if (unlikely(!opt_len || opt_len > icmp_len))
-				goto invalid;
-
-			/* Store the link layer address if the appropriate
-			 * option is provided.  It is considered an error if
-			 * the same link layer option is specified twice.
-			 */
-			if (nd_opt->nd_opt_type == ND_OPT_SOURCE_LL_ADDR
-			    && opt_len == 8) {
-				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.sll)))
-					goto invalid;
-				memcpy(key->ipv6.nd.sll,
-				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
-			} else if (nd_opt->nd_opt_type == ND_OPT_TARGET_LL_ADDR
-				   && opt_len == 8) {
-				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.tll)))
-					goto invalid;
-				memcpy(key->ipv6.nd.tll,
-				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
-			}
-
-			icmp_len -= opt_len;
-			offset += opt_len;
-		}
-	}
-
-	goto out;
-
-invalid:
-	memset(&key->ipv6.nd.target, 0, sizeof(key->ipv6.nd.target));
-	memset(key->ipv6.nd.sll, 0, sizeof(key->ipv6.nd.sll));
-	memset(key->ipv6.nd.tll, 0, sizeof(key->ipv6.nd.tll));
-
-out:
-	*key_lenp = key_len;
-	return error;
-}
-
 /**
  * ovs_flow_extract - extracts a flow key from an Ethernet frame.
  * @skb: sk_buff that contains the frame, with skb->data pointing to the
@@ -712,6 +714,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 				key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
 			}
 		}
+#if IS_ENABLED(CONFIG_IPV6)
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
@@ -752,6 +755,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 					goto out;
 			}
 		}
+#endif
 	}
 
 out:
-- 
1.7.7.6
