From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ila: Perform only one translation in forwarding path
Date: Tue, 7 Jun 2016 16:09:44 -0700
Message-ID: <1465340984-3270583-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30052 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751926AbcFGXJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:09:51 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u57N8eWl016724
	for <netdev@vger.kernel.org>; Tue, 7 Jun 2016 16:09:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 23e7b8g1wp-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 16:09:50 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 ee9237ec2d0411e6839924be05956610-1adfc2e0 for <netdev@vger.kernel.org>;	Tue,
 07 Jun 2016 16:09:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting up ILA in a router we noticed that the the encapsulation
is invoked twice: once in the route input path and again upon route
output. To resolve this we add a flag set_csum_neutral for the
ila_update_ipv6_locator. If this flag is set and the checksum
neutral bit is also set we assume that checksum-neutral translation
has already been performed and take no further action. The
flag is set only in ila_output path. The flag is not set for ila_input and
ila_xlat.

Tested:

Used 3 netns to set to emulate a router and two hosts. The router
translates SIR addresses between the two destinations in other two netns.
Verified ping and netperf are functional.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila.h        | 3 ++-
 net/ipv6/ila/ila_common.c | 6 ++++--
 net/ipv6/ila/ila_lwt.c    | 4 ++--
 net/ipv6/ila/ila_xlat.c   | 8 ++++----
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index d08fd2d..e0170f6 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -109,7 +109,8 @@ static inline bool ila_csum_neutral_set(struct ila_identifier ident)
 	return !!(ident.csum_neutral);
 }
 
-void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
+void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p,
+			     bool set_csum_neutral);
 
 void ila_init_saved_csum(struct ila_params *p);
 
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index 0e94042..b3d00be 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -103,7 +103,8 @@ static void ila_csum_adjust_transport(struct sk_buff *skb,
 	iaddr->loc = p->locator;
 }
 
-void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
+void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p,
+			     bool set_csum_neutral)
 {
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct ila_addr *iaddr = ila_a2i(&ip6h->daddr);
@@ -114,7 +115,8 @@ void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 		 * is a locator being translated to a SIR address.
 		 * Perform (receiver) checksum-neutral translation.
 		 */
-		ila_csum_do_neutral(iaddr, p);
+		if (!set_csum_neutral)
+			ila_csum_do_neutral(iaddr, p);
 	} else {
 		switch (p->csum_mode) {
 		case ILA_CSUM_ADJUST_TRANSPORT:
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 1dfb641..c8314c6 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -26,7 +26,7 @@ static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate), true);
 
 	return dst->lwtstate->orig_output(net, sk, skb);
 
@@ -42,7 +42,7 @@ static int ila_input(struct sk_buff *skb)
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate), false);
 
 	return dst->lwtstate->orig_input(skb);
 
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index a90e572..e6eca5f 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -210,14 +210,14 @@ static void ila_free_cb(void *ptr, void *arg)
 	}
 }
 
-static int ila_xlat_addr(struct sk_buff *skb);
+static int ila_xlat_addr(struct sk_buff *skb, bool set_csum_neutral);
 
 static unsigned int
 ila_nf_input(void *priv,
 	     struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	ila_xlat_addr(skb);
+	ila_xlat_addr(skb, false);
 	return NF_ACCEPT;
 }
 
@@ -597,7 +597,7 @@ static struct pernet_operations ila_net_ops = {
 	.size = sizeof(struct ila_net),
 };
 
-static int ila_xlat_addr(struct sk_buff *skb)
+static int ila_xlat_addr(struct sk_buff *skb, bool set_csum_neutral)
 {
 	struct ila_map *ila;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
@@ -616,7 +616,7 @@ static int ila_xlat_addr(struct sk_buff *skb)
 
 	ila = ila_lookup_wildcards(iaddr, skb->dev->ifindex, ilan);
 	if (ila)
-		ila_update_ipv6_locator(skb, &ila->xp.ip);
+		ila_update_ipv6_locator(skb, &ila->xp.ip, set_csum_neutral);
 
 	rcu_read_unlock();
 
-- 
2.8.0.rc2
