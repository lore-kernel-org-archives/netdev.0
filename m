From: kaber@trash.net
Subject: [PATCH 01/79] netfilter: nf_conntrack: don't always initialize ct->proto
Date: Wed, 19 Jan 2011 20:14:01 +0100
Message-ID: <1295464519-21763-2-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51971 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab1ASTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:24 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

ct->proto is big(60 bytes) due to structure ip_ct_tcp, and we don't need
to initialize the whole for all the other protocols. This patch moves
proto to the end of structure nf_conn, and pushes the initialization down
to the individual protocols.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack.h    |    6 +++---
 net/netfilter/nf_conntrack_core.c       |    3 ++-
 net/netfilter/nf_conntrack_netlink.c    |    1 +
 net/netfilter/nf_conntrack_proto_dccp.c |    3 +++
 net/netfilter/nf_conntrack_proto_sctp.c |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c  |   14 +++-----------
 6 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index caf17db..abfff1e 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -116,14 +116,14 @@ struct nf_conn {
 	u_int32_t secmark;
 #endif
 
-	/* Storage reserved for other modules: */
-	union nf_conntrack_proto proto;
-
 	/* Extensions */
 	struct nf_ct_ext *ext;
 #ifdef CONFIG_NET_NS
 	struct net *ct_net;
 #endif
+
+	/* Storage reserved for other modules, must be the last member */
+	union nf_conntrack_proto proto;
 };
 
 static inline struct nf_conn *
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 27a5ea6..0ba7d48 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -651,7 +651,8 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
 	 */
 	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
-	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
+	       offsetof(struct nf_conn, proto) -
+	       offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
 	spin_lock_init(&ct->lock);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b729ace..7f59be8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1375,6 +1375,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	}
 #endif
 
+	memset(&ct->proto, 0, sizeof(ct->proto));
 	if (cda[CTA_PROTOINFO]) {
 		err = ctnetlink_change_protoinfo(ct, cda);
 		if (err < 0)
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 5292560..9ae57c5 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -452,6 +452,9 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	ct->proto.dccp.role[IP_CT_DIR_ORIGINAL] = CT_DCCP_ROLE_CLIENT;
 	ct->proto.dccp.role[IP_CT_DIR_REPLY] = CT_DCCP_ROLE_SERVER;
 	ct->proto.dccp.state = CT_DCCP_NONE;
+	ct->proto.dccp.last_pkt = DCCP_PKT_REQUEST;
+	ct->proto.dccp.last_dir = IP_CT_DIR_ORIGINAL;
+	ct->proto.dccp.handshake_seq = 0;
 	return true;
 
 out_invalid:
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c6049c2..6f4ee70 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -413,6 +413,7 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	    test_bit(SCTP_CID_COOKIE_ACK, map))
 		return false;
 
+	memset(&ct->proto.sctp, 0, sizeof(ct->proto.sctp));
 	new_state = SCTP_CONNTRACK_MAX;
 	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
 		/* Don't need lock here: this conntrack not in circulation yet */
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 3fb2b73..6f38d0e 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1066,9 +1066,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	BUG_ON(th == NULL);
 
 	/* Don't need lock here: this conntrack not in circulation yet */
-	new_state
-		= tcp_conntracks[0][get_conntrack_index(th)]
-		[TCP_CONNTRACK_NONE];
+	new_state = tcp_conntracks[0][get_conntrack_index(th)][TCP_CONNTRACK_NONE];
 
 	/* Invalid: delete conntrack */
 	if (new_state >= TCP_CONNTRACK_MAX) {
@@ -1077,6 +1075,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	}
 
 	if (new_state == TCP_CONNTRACK_SYN_SENT) {
+		memset(&ct->proto.tcp, 0, sizeof(ct->proto.tcp));
 		/* SYN packet */
 		ct->proto.tcp.seen[0].td_end =
 			segment_seq_plus_len(ntohl(th->seq), skb->len,
@@ -1088,11 +1087,11 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 			ct->proto.tcp.seen[0].td_end;
 
 		tcp_options(skb, dataoff, th, &ct->proto.tcp.seen[0]);
-		ct->proto.tcp.seen[1].flags = 0;
 	} else if (nf_ct_tcp_loose == 0) {
 		/* Don't try to pick up connections. */
 		return false;
 	} else {
+		memset(&ct->proto.tcp, 0, sizeof(ct->proto.tcp));
 		/*
 		 * We are in the middle of a connection,
 		 * its history is lost for us.
@@ -1107,7 +1106,6 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		ct->proto.tcp.seen[0].td_maxend =
 			ct->proto.tcp.seen[0].td_end +
 			ct->proto.tcp.seen[0].td_maxwin;
-		ct->proto.tcp.seen[0].td_scale = 0;
 
 		/* We assume SACK and liberal window checking to handle
 		 * window scaling */
@@ -1116,13 +1114,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 					      IP_CT_TCP_FLAG_BE_LIBERAL;
 	}
 
-	ct->proto.tcp.seen[1].td_end = 0;
-	ct->proto.tcp.seen[1].td_maxend = 0;
-	ct->proto.tcp.seen[1].td_maxwin = 0;
-	ct->proto.tcp.seen[1].td_scale = 0;
-
 	/* tcp_packet will set them */
-	ct->proto.tcp.state = TCP_CONNTRACK_NONE;
 	ct->proto.tcp.last_index = TCP_NONE_SET;
 
 	pr_debug("tcp_new: sender end=%u maxend=%u maxwin=%u scale=%i "
-- 
1.7.2.3

