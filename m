From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/47] netfilter: conntrack: remove protocol name from l3proto struct
Date: Mon,  4 Sep 2017 00:41:42 +0200
Message-ID: <1504478516-13224-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52890 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753438AbdICWmK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:42:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 99C25190F63
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 89454B502E
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:43 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

no need to waste storage for something that is only needed
in one place and can be deduced from protocol number.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |  3 ---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  1 -
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  1 -
 net/netfilter/nf_conntrack_l3proto_generic.c   |  1 -
 net/netfilter/nf_conntrack_standalone.c        | 12 +++++++++++-
 5 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 6a27ffea7480..e31861e4fa6a 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -23,9 +23,6 @@ struct nf_conntrack_l3proto {
 	/* size of tuple nlattr, fills a hole */
 	u16 nla_size;
 
-	/* Protocol name */
-	const char *name;
-
 	/*
 	 * Try to fill in the third arg: nhoff is offset of l3 proto
          * hdr.  Return true if possible.
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 9fb8cb033d80..9f7ea862068c 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -353,7 +353,6 @@ static void ipv4_hooks_unregister(struct net *net)
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.l3proto	 = PF_INET,
-	.name		 = "ipv4",
 	.pkt_to_tuple	 = ipv4_pkt_to_tuple,
 	.invert_tuple	 = ipv4_invert_tuple,
 	.print_tuple	 = ipv4_print_tuple,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 6b4d59fd0214..91d37fbe28de 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -348,7 +348,6 @@ static void ipv6_hooks_unregister(struct net *net)
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.l3proto		= PF_INET6,
-	.name			= "ipv6",
 	.pkt_to_tuple		= ipv6_pkt_to_tuple,
 	.invert_tuple		= ipv6_invert_tuple,
 	.print_tuple		= ipv6_print_tuple,
diff --git a/net/netfilter/nf_conntrack_l3proto_generic.c b/net/netfilter/nf_conntrack_l3proto_generic.c
index cf9ace70bece..0387971582bc 100644
--- a/net/netfilter/nf_conntrack_l3proto_generic.c
+++ b/net/netfilter/nf_conntrack_l3proto_generic.c
@@ -64,7 +64,6 @@ static int generic_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_generic __read_mostly = {
 	.l3proto	 = PF_UNSPEC,
-	.name		 = "unknown",
 	.pkt_to_tuple	 = generic_pkt_to_tuple,
 	.invert_tuple	 = generic_invert_tuple,
 	.print_tuple	 = generic_print_tuple,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 5b6c675d55b1..359d7e6a4503 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -198,6 +198,16 @@ ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
 }
 #endif
 
+static const char* l3proto_name(u16 proto)
+{
+	switch (proto) {
+	case AF_INET: return "ipv4";
+	case AF_INET6: return "ipv6";
+	}
+
+	return "unknown";
+}
+
 /* return 0 on success, 1 in case of error */
 static int ct_seq_show(struct seq_file *s, void *v)
 {
@@ -231,7 +241,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 
 	ret = -ENOSPC;
 	seq_printf(s, "%-8s %u %-8s %u %ld ",
-		   l3proto->name, nf_ct_l3num(ct),
+		   l3proto_name(l3proto->l3proto), nf_ct_l3num(ct),
 		   l4proto->name, nf_ct_protonum(ct),
 		   nf_ct_expires(ct)  / HZ);
 
-- 
2.1.4
