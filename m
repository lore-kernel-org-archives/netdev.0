From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/04: tcp conntrack: fix unacknowledged data detection with NAT
Date: Mon, 29 Jun 2009 16:20:15 +0200 (MEST)
Message-ID: <20090629142010.5728.30435.sendpatchset@x2.localnet>
References: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a3a9f79e361e864f0e9d75ebe2a0cb43d17c4272
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 29 14:07:56 2009 +0200

    netfilter: tcp conntrack: fix unacknowledged data detection with NAT
    
    When NAT helpers change the TCP packet size, the highest seen sequence
    number needs to be corrected. This is currently only done upwards, when
    the packet size is reduced the sequence number is unchanged. This causes
    TCP conntrack to falsely detect unacknowledged data and decrease the
    timeout.
    
    Fix by updating the highest seen sequence number in both directions after
    packet mangling.
    
    Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index a632689..cbdd628 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -258,8 +258,8 @@ static inline bool nf_ct_kill(struct nf_conn *ct)
 /* Update TCP window tracking data when NAT mangles the packet */
 extern void nf_conntrack_tcp_update(const struct sk_buff *skb,
 				    unsigned int dataoff,
-				    struct nf_conn *ct,
-				    int dir);
+				    struct nf_conn *ct, int dir,
+				    s16 offset);
 
 /* Fake conntrack entry for untracked connections */
 extern struct nf_conn nf_conntrack_untracked;
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 155c008..09172a6 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -191,7 +191,8 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 				    ct, ctinfo);
 		/* Tell TCP window tracking about seq change */
 		nf_conntrack_tcp_update(skb, ip_hdrlen(skb),
-					ct, CTINFO2DIR(ctinfo));
+					ct, CTINFO2DIR(ctinfo),
+					(int)rep_len - (int)match_len);
 
 		nf_conntrack_event_cache(IPCT_NATSEQADJ, ct);
 	}
@@ -377,6 +378,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	struct tcphdr *tcph;
 	int dir;
 	__be32 newseq, newack;
+	s16 seqoff, ackoff;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_seq *this_way, *other_way;
 
@@ -390,15 +392,18 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 
 	tcph = (void *)skb->data + ip_hdrlen(skb);
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
-		newseq = htonl(ntohl(tcph->seq) + this_way->offset_after);
+		seqoff = this_way->offset_after;
 	else
-		newseq = htonl(ntohl(tcph->seq) + this_way->offset_before);
+		seqoff = this_way->offset_before;
 
 	if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
 		  other_way->correction_pos))
-		newack = htonl(ntohl(tcph->ack_seq) - other_way->offset_after);
+		ackoff = other_way->offset_after;
 	else
-		newack = htonl(ntohl(tcph->ack_seq) - other_way->offset_before);
+		ackoff = other_way->offset_before;
+
+	newseq = htonl(ntohl(tcph->seq) + seqoff);
+	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
 
 	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, 0);
 	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack, 0);
@@ -413,7 +418,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	if (!nf_nat_sack_adjust(skb, tcph, ct, ctinfo))
 		return 0;
 
-	nf_conntrack_tcp_update(skb, ip_hdrlen(skb), ct, dir);
+	nf_conntrack_tcp_update(skb, ip_hdrlen(skb), ct, dir, seqoff);
 
 	return 1;
 }
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 33fc0a4..97a82ba 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -720,8 +720,8 @@ static bool tcp_in_window(const struct nf_conn *ct,
 /* Caller must linearize skb at tcp header. */
 void nf_conntrack_tcp_update(const struct sk_buff *skb,
 			     unsigned int dataoff,
-			     struct nf_conn *ct,
-			     int dir)
+			     struct nf_conn *ct, int dir,
+			     s16 offset)
 {
 	const struct tcphdr *tcph = (const void *)skb->data + dataoff;
 	const struct ip_ct_tcp_state *sender = &ct->proto.tcp.seen[dir];
@@ -734,7 +734,7 @@ void nf_conntrack_tcp_update(const struct sk_buff *skb,
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
-	if (after(end, ct->proto.tcp.seen[dir].td_end))
+	if (ct->proto.tcp.seen[dir].td_end + offset == end)
 		ct->proto.tcp.seen[dir].td_end = end;
 	ct->proto.tcp.last_end = end;
 	spin_unlock_bh(&ct->lock);
