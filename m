From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 24/31: nf_conntrack: log packets dropped by helpers
Date: Thu, 10 Sep 2009 18:12:17 +0200 (MEST)
Message-ID: <20090910161213.31179.54678.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 74f7a6552c8d76ffc5e11eb8d9d6c07238b9ae77
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Aug 25 15:33:08 2009 +0200

    netfilter: nf_conntrack: log packets dropped by helpers
    
    Log packets dropped by helpers using the netfilter logging API. This
    is useful in combination with nfnetlink_log to analyze those packets
    in userspace for debugging.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 9ac2fdc..aa95bb8 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -26,6 +26,7 @@
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/nf_log.h>
 
 int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      struct nf_conn *ct,
@@ -113,8 +114,11 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 
 	ret = helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
 			   ct, ctinfo);
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_log_packet(NFPROTO_IPV4, hooknum, skb, in, out, NULL,
+			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
+	}
 
 	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)) {
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index a7f4cd6..5f2ec20 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -27,6 +27,7 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/nf_log.h>
 
 static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 			      struct nf_conntrack_tuple *tuple)
@@ -176,8 +177,11 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	}
 
 	ret = helper->help(skb, protoff, ct, ctinfo);
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_log_packet(NFPROTO_IPV6, hooknum, skb, in, out, NULL,
+			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
+	}
 out:
 	/* We've seen it coming out the other side: confirm it */
 	return nf_conntrack_confirm(skb);
