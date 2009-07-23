From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 07/08: tcp conntrack: fix unacknowledged data detection with NAT
Date: Thu, 23 Jul 2009 16:15:33 +0200 (MEST)
Message-ID: <20090723141532.19029.11679.sendpatchset@x2.localnet>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e7a42c94e8d0845d10163f6c2695a8342c2ce1cd
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 3 10:37:27 2009 +0200

    netfilter: tcp conntrack: fix unacknowledged data detection with NAT
    
    Upstream commit a3a9f79e:
    
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
index 6c3f964..5d9a848 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -255,8 +255,8 @@ static inline bool nf_ct_kill(struct nf_conn *ct)
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
index cf7a42b..05ede41 100644
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
index 97a6e93..a38bc22 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -706,8 +706,8 @@ static bool tcp_in_window(const struct nf_conn *ct,
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
@@ -720,7 +720,7 @@ void nf_conntrack_tcp_update(const struct sk_buff *skb,
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
-	if (after(end, ct->proto.tcp.seen[dir].td_end))
+	if (ct->proto.tcp.seen[dir].td_end + offset == end)
 		ct->proto.tcp.seen[dir].td_end = end;
 	ct->proto.tcp.last_end = end;
 	write_unlock_bh(&tcp_lock);
