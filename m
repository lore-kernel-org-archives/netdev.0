From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 44/53] netfilter: masquerade: attach nat extension if not present
Date: Mon,  1 May 2017 12:47:11 +0200
Message-ID: <1493635640-24325-45-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49712 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378835AbdEAKtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:49:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D9E66210589
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CB844A6D6
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9F7C0FF124
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:02 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Currently the nat extension is always attached as soon as nat module is
loaded.  However, most NAT uses do not need the nat extension anymore.

Prepare to remove the add-nat-by-default by making those places that need
it attach it if its not present yet.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c | 5 +++--
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c | 5 ++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index ea91058b5f6f..dc1dea15c1b4 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -37,7 +37,6 @@ nf_nat_masquerade_ipv4(struct sk_buff *skb, unsigned int hooknum,
 	NF_CT_ASSERT(hooknum == NF_INET_POST_ROUTING);
 
 	ct = nf_ct_get(skb, &ctinfo);
-	nat = nfct_nat(ct);
 
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
 			    ctinfo == IP_CT_RELATED_REPLY));
@@ -56,7 +55,9 @@ nf_nat_masquerade_ipv4(struct sk_buff *skb, unsigned int hooknum,
 		return NF_DROP;
 	}
 
-	nat->masq_index = out->ifindex;
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat)
+		nat->masq_index = out->ifindex;
 
 	/* Transfer from original range. */
 	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
index 051b6a6bfff6..2297c9f073ba 100644
--- a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
@@ -30,6 +30,7 @@ nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 		       const struct net_device *out)
 {
 	enum ip_conntrack_info ctinfo;
+	struct nf_conn_nat *nat;
 	struct in6_addr src;
 	struct nf_conn *ct;
 	struct nf_nat_range newrange;
@@ -42,7 +43,9 @@ nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 			       &ipv6_hdr(skb)->daddr, 0, &src) < 0)
 		return NF_DROP;
 
-	nfct_nat(ct)->masq_index = out->ifindex;
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat)
+		nat->masq_index = out->ifindex;
 
 	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
 	newrange.min_addr.in6	= src;
-- 
2.1.4
