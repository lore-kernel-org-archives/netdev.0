From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/04: nf_ct_tcp: fix accepting invalid RST segments
Date: Wed, 27 May 2009 16:35:25 +0200 (MEST)
Message-ID: <20090527143523.4649.91602.sendpatchset@x2.localnet>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit bfcaa50270e18f35220a11d46e98fc6232c24606
Author: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date:   Mon May 25 17:23:15 2009 +0200

    netfilter: nf_ct_tcp: fix accepting invalid RST segments
    
    Robert L Mathews discovered that some clients send evil TCP RST segments,
    which are accepted by netfilter conntrack but discarded by the
    destination. Thus the conntrack entry is destroyed but the destination
    retransmits data until timeout.
    
    The same technique, i.e. sending properly crafted RST segments, can easily
    be used to bypass connlimit/connbytes based restrictions (the sample
    script written by Robert can be found in the netfilter mailing list
    archives).
    
    The patch below adds a new flag and new field to struct ip_ct_tcp_state so
    that checking RST segments can be made more strict and thus TCP conntrack
    can catch the invalid ones: the RST segment is accepted only if its
    sequence number higher than or equal to the highest ack we seen from the
    other direction. (The last_ack field cannot be reused because it is used
    to catch resent packets.)
    
    Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nf_conntrack_tcp.h b/include/linux/netfilter/nf_conntrack_tcp.h
index 3066789..b2f384d 100644
--- a/include/linux/netfilter/nf_conntrack_tcp.h
+++ b/include/linux/netfilter/nf_conntrack_tcp.h
@@ -35,6 +35,9 @@ enum tcp_conntrack {
 /* Has unacknowledged data */
 #define IP_CT_TCP_FLAG_DATA_UNACKNOWLEDGED	0x10
 
+/* The field td_maxack has been set */
+#define IP_CT_TCP_FLAG_MAXACK_SET		0x20
+
 struct nf_ct_tcp_flags {
 	__u8 flags;
 	__u8 mask;
@@ -46,6 +49,7 @@ struct ip_ct_tcp_state {
 	u_int32_t	td_end;		/* max of seq + len */
 	u_int32_t	td_maxend;	/* max of ack + max(win, 1) */
 	u_int32_t	td_maxwin;	/* max(win) */
+	u_int32_t	td_maxack;	/* max of ack */
 	u_int8_t	td_scale;	/* window scale factor */
 	u_int8_t	flags;		/* per direction options */
 };
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b5ccf2b..97a6e93 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -634,6 +634,14 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			sender->td_end = end;
 			sender->flags |= IP_CT_TCP_FLAG_DATA_UNACKNOWLEDGED;
 		}
+		if (tcph->ack) {
+			if (!(sender->flags & IP_CT_TCP_FLAG_MAXACK_SET)) {
+				sender->td_maxack = ack;
+				sender->flags |= IP_CT_TCP_FLAG_MAXACK_SET;
+			} else if (after(ack, sender->td_maxack))
+				sender->td_maxack = ack;
+		}
+
 		/*
 		 * Update receiver data.
 		 */
@@ -919,6 +927,16 @@ static int tcp_packet(struct nf_conn *ct,
 		return -NF_ACCEPT;
 	case TCP_CONNTRACK_CLOSE:
 		if (index == TCP_RST_SET
+		    && (ct->proto.tcp.seen[!dir].flags & IP_CT_TCP_FLAG_MAXACK_SET)
+		    && before(ntohl(th->seq), ct->proto.tcp.seen[!dir].td_maxack)) {
+			/* Invalid RST  */
+			write_unlock_bh(&tcp_lock);
+			if (LOG_INVALID(net, IPPROTO_TCP))
+				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+					  "nf_ct_tcp: invalid RST ");
+			return -NF_ACCEPT;
+		}
+		if (index == TCP_RST_SET
 		    && ((test_bit(IPS_SEEN_REPLY_BIT, &ct->status)
 			 && ct->proto.tcp.last_index == TCP_SYN_SET)
 			|| (!test_bit(IPS_ASSURED_BIT, &ct->status)
