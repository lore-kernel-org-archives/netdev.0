From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 27/62: nf_conntrack: split up IPCT_STATUS event
Date: Tue, 16 Feb 2010 15:55:56 +0100 (MET)
Message-ID: <20100216145554.2796.28533.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52020 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471Ab0BPOz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:57 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 858b31330054a9ad259feceea0ad1ce5385c47f0
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 13:48:53 2010 +0100

    netfilter: nf_conntrack: split up IPCT_STATUS event
    
    Split up the IPCT_STATUS event into an IPCT_REPLY event, which is generated
    when the IPS_SEEN_REPLY bit is set, and an IPCT_ASSURED event, which is
    generated when the IPS_ASSURED bit is set.
    
    In combination with a following patch to support selective event delivery,
    this can be used for "sparse" conntrack replication: start replicating the
    conntrack entry after it reached the ASSURED state and that way it's SYN-flood
    resistant.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 475facc..5e05fb8 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -14,19 +14,20 @@
 
 /* Connection tracking event types */
 enum ip_conntrack_events {
-	IPCT_NEW		= 0,	/* new conntrack */
-	IPCT_RELATED		= 1,	/* related conntrack */
-	IPCT_DESTROY		= 2,	/* destroyed conntrack */
-	IPCT_STATUS		= 3,	/* status has changed */
-	IPCT_PROTOINFO		= 4,	/* protocol information has changed */
-	IPCT_HELPER		= 5,	/* new helper has been set */
-	IPCT_MARK		= 6,	/* new mark has been set */
-	IPCT_NATSEQADJ		= 7,	/* NAT is doing sequence adjustment */
-	IPCT_SECMARK		= 8,	/* new security mark has been set */
+	IPCT_NEW,		/* new conntrack */
+	IPCT_RELATED,		/* related conntrack */
+	IPCT_DESTROY,		/* destroyed conntrack */
+	IPCT_REPLY,		/* connection has seen two-way traffic */
+	IPCT_ASSURED,		/* connection status has changed to assured */
+	IPCT_PROTOINFO,		/* protocol information has changed */
+	IPCT_HELPER,		/* new helper has been set */
+	IPCT_MARK,		/* new mark has been set */
+	IPCT_NATSEQADJ,		/* NAT is doing sequence adjustment */
+	IPCT_SECMARK,		/* new security mark has been set */
 };
 
 enum ip_conntrack_expect_events {
-	IPEXP_NEW		= 0,	/* new expectation */
+	IPEXP_NEW,		/* new expectation */
 };
 
 struct nf_conntrack_ecache {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0e98c32..091ff77 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -825,7 +825,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	}
 
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_STATUS, ct);
+		nf_conntrack_event_cache(IPCT_REPLY, ct);
 
 	return ret;
 }
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 16f86d6..ff594eb 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1371,7 +1371,8 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			else
 				events = IPCT_NEW;
 
-			nf_conntrack_eventmask_report((1 << IPCT_STATUS) |
+			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
+						      (1 << IPCT_ASSURED) |
 						      (1 << IPCT_HELPER) |
 						      (1 << IPCT_PROTOINFO) |
 						      (1 << IPCT_NATSEQADJ) |
@@ -1396,7 +1397,8 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		if (err == 0) {
 			nf_conntrack_get(&ct->ct_general);
 			spin_unlock_bh(&nf_conntrack_lock);
-			nf_conntrack_eventmask_report((1 << IPCT_STATUS) |
+			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
+						      (1 << IPCT_ASSURED) |
 						      (1 << IPCT_HELPER) |
 						      (1 << IPCT_PROTOINFO) |
 						      (1 << IPCT_NATSEQADJ) |
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index c99cfba..d899b1a 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -241,7 +241,7 @@ static int gre_packet(struct nf_conn *ct,
 				   ct->proto.gre.stream_timeout);
 		/* Also, more likely to be important, and not a probe. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, ct);
+		nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb,
 				   ct->proto.gre.timeout);
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index f9d930f..b68ff15 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -377,7 +377,7 @@ static int sctp_packet(struct nf_conn *ct,
 	    new_state == SCTP_CONNTRACK_ESTABLISHED) {
 		pr_debug("Setting assured bit\n");
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, ct);
+		nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	}
 
 	return NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 3c96437..ad11805 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1045,7 +1045,7 @@ static int tcp_packet(struct nf_conn *ct,
 		   after SYN_RECV or a valid answer for a picked up
 		   connection. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, ct);
+		nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	}
 	nf_ct_refresh_acct(ct, ctinfo, skb, timeout);
 
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 5c5518b..8d38f9a 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -77,7 +77,7 @@ static int udp_packet(struct nf_conn *ct,
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, ct);
+			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout);
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 458655b..0b1bc9b 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -75,7 +75,7 @@ static int udplite_packet(struct nf_conn *ct,
 				   nf_ct_udplite_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, ct);
+			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udplite_timeout);
 
