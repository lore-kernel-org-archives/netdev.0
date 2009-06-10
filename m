From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 28/31: nf_ct_icmp: keep the ICMP ct entries longer
Date: Wed, 10 Jun 2009 21:46:57 +0200 (MEST)
Message-ID: <20090610194656.11112.19567.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f87fb666bb00a7afcbd7992d236e42ac544996f9
Author: Jan Kasprzak <kas@fi.muni.cz>
Date:   Mon Jun 8 15:53:43 2009 +0200

    netfilter: nf_ct_icmp: keep the ICMP ct entries longer
    
    Current conntrack code kills the ICMP conntrack entry as soon as
    the first reply is received. This is incorrect, as we then see only
    the first ICMP echo reply out of several possible duplicates as
    ESTABLISHED, while the rest will be INVALID. Also this unnecessarily
    increases the conntrackd traffic on H-A firewalls.
    
    Make all the ICMP conntrack entries (including the replied ones)
    last for the default of nf_conntrack_icmp{,v6}_timeout seconds.
    
    Signed-off-by: Jan "Yenya" Kasprzak <kas@fi.muni.cz>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/ipv4/nf_conntrack_icmp.h b/include/net/netfilter/ipv4/nf_conntrack_icmp.h
deleted file mode 100644
index 3dd22cf..0000000
--- a/include/net/netfilter/ipv4/nf_conntrack_icmp.h
+++ /dev/null
@@ -1,11 +0,0 @@
-#ifndef _NF_CONNTRACK_ICMP_H
-#define _NF_CONNTRACK_ICMP_H
-/* ICMP tracking. */
-#include <asm/atomic.h>
-
-struct ip_ct_icmp
-{
-	/* Optimization: when number in == number out, forget immediately. */
-	atomic_t count;
-};
-#endif /* _NF_CONNTRACK_ICMP_H */
diff --git a/include/net/netfilter/ipv6/nf_conntrack_icmpv6.h b/include/net/netfilter/ipv6/nf_conntrack_icmpv6.h
index 86591af..67edd50 100644
--- a/include/net/netfilter/ipv6/nf_conntrack_icmpv6.h
+++ b/include/net/netfilter/ipv6/nf_conntrack_icmpv6.h
@@ -9,7 +9,6 @@
 
 #ifndef _NF_CONNTRACK_ICMPV6_H
 #define _NF_CONNTRACK_ICMPV6_H
-#include <asm/atomic.h>
 
 #ifndef ICMPV6_NI_QUERY
 #define ICMPV6_NI_QUERY 139
@@ -18,10 +17,4 @@
 #define ICMPV6_NI_REPLY 140
 #endif
 
-struct nf_ct_icmpv6
-{
-	/* Optimization: when number in == number out, forget immediately. */
-	atomic_t count;
-};
-
 #endif /* _NF_CONNTRACK_ICMPV6_H */
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2ba36dd..2b87737 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -23,7 +23,6 @@
 #include <linux/netfilter/nf_conntrack_dccp.h>
 #include <linux/netfilter/nf_conntrack_sctp.h>
 #include <linux/netfilter/nf_conntrack_proto_gre.h>
-#include <net/netfilter/ipv4/nf_conntrack_icmp.h>
 #include <net/netfilter/ipv6/nf_conntrack_icmpv6.h>
 
 #include <net/netfilter/nf_conntrack_tuple.h>
@@ -34,8 +33,6 @@ union nf_conntrack_proto {
 	struct nf_ct_dccp dccp;
 	struct ip_ct_sctp sctp;
 	struct ip_ct_tcp tcp;
-	struct ip_ct_icmp icmp;
-	struct nf_ct_icmpv6 icmpv6;
 	struct nf_ct_gre gre;
 };
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index c6ab3d9..d71ba76 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -82,17 +82,10 @@ static int icmp_packet(struct nf_conn *ct,
 		       u_int8_t pf,
 		       unsigned int hooknum)
 {
-	/* Try to delete connection immediately after all replies:
-	   won't actually vanish as we still have skb, and del_timer
-	   means this will only run once even if count hits zero twice
-	   (theoretically possible with SMP) */
-	if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY) {
-		if (atomic_dec_and_test(&ct->proto.icmp.count))
-			nf_ct_kill_acct(ct, ctinfo, skb);
-	} else {
-		atomic_inc(&ct->proto.icmp.count);
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
-	}
+	/* Do not immediately delete the connection after the first
+	   successful reply to avoid excessive conntrackd traffic
+	   and also to handle correctly ICMP echo reply duplicates. */
+	nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
 
 	return NF_ACCEPT;
 }
@@ -116,7 +109,6 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		nf_ct_dump_tuple_ip(&ct->tuplehash[0].tuple);
 		return false;
 	}
-	atomic_set(&ct->proto.icmp.count, 0);
 	return true;
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index a0acd96..642dcb1 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -95,17 +95,10 @@ static int icmpv6_packet(struct nf_conn *ct,
 		       u_int8_t pf,
 		       unsigned int hooknum)
 {
-	/* Try to delete connection immediately after all replies:
-	   won't actually vanish as we still have skb, and del_timer
-	   means this will only run once even if count hits zero twice
-	   (theoretically possible with SMP) */
-	if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY) {
-		if (atomic_dec_and_test(&ct->proto.icmp.count))
-			nf_ct_kill_acct(ct, ctinfo, skb);
-	} else {
-		atomic_inc(&ct->proto.icmp.count);
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
-	}
+	/* Do not immediately delete the connection after the first
+	   successful reply to avoid excessive conntrackd traffic
+	   and also to handle correctly ICMP echo reply duplicates. */
+	nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
 
 	return NF_ACCEPT;
 }
@@ -131,7 +124,6 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 				      type + 128);
 		return false;
 	}
-	atomic_set(&ct->proto.icmp.count, 0);
 	return true;
 }
 
