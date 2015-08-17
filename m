From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v4 2/4] net: Change pseudohdr argument of inet_proto_csum_replace* to be a bool
Date: Mon, 17 Aug 2015 13:42:25 -0700
Message-ID: <1439844147-1286627-3-git-send-email-tom@herbertland.com>
References: <1439844147-1286627-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:1258 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbbHQVkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:40:08 -0400
Received: from pps.filterd (m0042983 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7HLbOdv001809
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:40:06 -0700
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-00082601.pphosted.com with ESMTP id 1w92w2r8pb-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:40:05 -0700
Received: from pps.reinject (m0042983 [127.0.0.1])
	by pps.reinject (8.14.5/8.14.5) with SMTP id t7HLe2qZ011599
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:40:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wbp78r6dh-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 13:42:46 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 832edf2c452011e5915b0002c9931860-1a3f22b0 for <netdev@vger.kernel.org>;	Mon,
 17 Aug 2015 13:42:44 -0700
In-Reply-To: <1439844147-1286627-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_proto_csum_replace4,2,16 take a pseudohdr argument which indicates
the checksum field carries a pseudo header. This argument should be a
boolean instead of an int.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/checksum.h                   |  6 +++---
 net/core/filter.c                        |  2 +-
 net/core/utils.c                         |  4 ++--
 net/ipv4/netfilter/ipt_ECN.c             |  2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c |  4 ++--
 net/ipv4/netfilter/nf_nat_proto_icmp.c   |  2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c |  4 ++--
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c |  2 +-
 net/netfilter/nf_conntrack_seqadj.c      |  9 +++++----
 net/netfilter/nf_nat_proto_dccp.c        |  2 +-
 net/netfilter/nf_nat_proto_tcp.c         |  2 +-
 net/netfilter/nf_nat_proto_udp.c         |  2 +-
 net/netfilter/nf_nat_proto_udplite.c     |  2 +-
 net/netfilter/nf_synproxy_core.c         |  2 +-
 net/netfilter/xt_TCPMSS.c                |  8 ++++----
 net/netfilter/xt_TCPOPTSTRIP.c           |  2 +-
 net/openvswitch/actions.c                | 12 ++++++------
 net/sched/act_nat.c                      |  7 ++++---
 18 files changed, 38 insertions(+), 36 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 2d1d73c..619f344 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -140,14 +140,14 @@ static inline void csum_replace2(__sum16 *sum, __be16 old, __be16 new)
 
 struct sk_buff;
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-			      __be32 from, __be32 to, int pseudohdr);
+			      __be32 from, __be32 to, bool pseudohdr);
 void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			       const __be32 *from, const __be32 *to,
-			       int pseudohdr);
+			       bool pseudohdr);
 
 static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 					    __be16 from, __be16 to,
-					    int pseudohdr)
+					    bool pseudohdr)
 {
 	inet_proto_csum_replace4(sum, skb, (__force __be32)from,
 				 (__force __be32)to, pseudohdr);
diff --git a/net/core/filter.c b/net/core/filter.c
index a50dbfa..a2e1f23 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1348,7 +1348,7 @@ const struct bpf_func_proto bpf_l3_csum_replace_proto = {
 static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	u32 is_pseudo = BPF_IS_PSEUDO_HEADER(flags);
+	bool is_pseudo = !!BPF_IS_PSEUDO_HEADER(flags);
 	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
diff --git a/net/core/utils.c b/net/core/utils.c
index a7732a0..cd7d202 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -301,7 +301,7 @@ out:
 EXPORT_SYMBOL(in6_pton);
 
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-			      __be32 from, __be32 to, int pseudohdr)
+			      __be32 from, __be32 to, bool pseudohdr)
 {
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		csum_replace4(sum, from, to);
@@ -318,7 +318,7 @@ EXPORT_SYMBOL(inet_proto_csum_replace4);
 
 void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			       const __be32 *from, const __be32 *to,
-			       int pseudohdr)
+			       bool pseudohdr)
 {
 	__be32 diff[] = {
 		~from[0], ~from[1], ~from[2], ~from[3],
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4bf3dc4..2707652 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -72,7 +72,7 @@ set_ect_tcp(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 		tcph->cwr = einfo->proto.tcp.cwr;
 
 	inet_proto_csum_replace2(&tcph->check, skb,
-				 oldval, ((__be16 *)tcph)[6], 0);
+				 oldval, ((__be16 *)tcph)[6], false);
 	return true;
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index e59cc05..22f4579 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -120,7 +120,7 @@ static void nf_nat_ipv4_csum_update(struct sk_buff *skb,
 		oldip = iph->daddr;
 		newip = t->dst.u3.ip;
 	}
-	inet_proto_csum_replace4(check, skb, oldip, newip, 1);
+	inet_proto_csum_replace4(check, skb, oldip, newip, true);
 }
 
 static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
@@ -151,7 +151,7 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
 		}
 	} else
 		inet_proto_csum_replace2(check, skb,
-					 htons(oldlen), htons(datalen), 1);
+					 htons(oldlen), htons(datalen), true);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 4557b4a..7b98baa 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -67,7 +67,7 @@ icmp_manip_pkt(struct sk_buff *skb,
 
 	hdr = (struct icmphdr *)(skb->data + hdroff);
 	inet_proto_csum_replace2(&hdr->checksum, skb,
-				 hdr->un.echo.id, tuple->src.u.icmp.id, 0);
+				 hdr->un.echo.id, tuple->src.u.icmp.id, false);
 	hdr->un.echo.id = tuple->src.u.icmp.id;
 	return true;
 }
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index e76900e..70fbaed 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -124,7 +124,7 @@ static void nf_nat_ipv6_csum_update(struct sk_buff *skb,
 		newip = &t->dst.u3.in6;
 	}
 	inet_proto_csum_replace16(check, skb, oldip->s6_addr32,
-				  newip->s6_addr32, 1);
+				  newip->s6_addr32, true);
 }
 
 static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
@@ -155,7 +155,7 @@ static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
 		}
 	} else
 		inet_proto_csum_replace2(check, skb,
-					 htons(oldlen), htons(datalen), 1);
+					 htons(oldlen), htons(datalen), true);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
index 2205e8e..57593b00 100644
--- a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
@@ -73,7 +73,7 @@ icmpv6_manip_pkt(struct sk_buff *skb,
 	    hdr->icmp6_type == ICMPV6_ECHO_REPLY) {
 		inet_proto_csum_replace2(&hdr->icmp6_cksum, skb,
 					 hdr->icmp6_identifier,
-					 tuple->src.u.icmp.id, 0);
+					 tuple->src.u.icmp.id, false);
 		hdr->icmp6_identifier = tuple->src.u.icmp.id;
 	}
 	return true;
diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index ce3e840c8..dff0f0c 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -103,9 +103,9 @@ static void nf_ct_sack_block_adjust(struct sk_buff *skb,
 			 ntohl(sack->end_seq), ntohl(new_end_seq));
 
 		inet_proto_csum_replace4(&tcph->check, skb,
-					 sack->start_seq, new_start_seq, 0);
+					 sack->start_seq, new_start_seq, false);
 		inet_proto_csum_replace4(&tcph->check, skb,
-					 sack->end_seq, new_end_seq, 0);
+					 sack->end_seq, new_end_seq, false);
 		sack->start_seq = new_start_seq;
 		sack->end_seq = new_end_seq;
 		sackoff += sizeof(*sack);
@@ -193,8 +193,9 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 	newseq = htonl(ntohl(tcph->seq) + seqoff);
 	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
 
-	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, 0);
-	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack, 0);
+	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
+	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
+				 false);
 
 	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
 		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
diff --git a/net/netfilter/nf_nat_proto_dccp.c b/net/netfilter/nf_nat_proto_dccp.c
index b8067b5..15c47b2 100644
--- a/net/netfilter/nf_nat_proto_dccp.c
+++ b/net/netfilter/nf_nat_proto_dccp.c
@@ -69,7 +69,7 @@ dccp_manip_pkt(struct sk_buff *skb,
 	l3proto->csum_update(skb, iphdroff, &hdr->dccph_checksum,
 			     tuple, maniptype);
 	inet_proto_csum_replace2(&hdr->dccph_checksum, skb, oldport, newport,
-				 0);
+				 false);
 	return true;
 }
 
diff --git a/net/netfilter/nf_nat_proto_tcp.c b/net/netfilter/nf_nat_proto_tcp.c
index 37f5505..4f8820f 100644
--- a/net/netfilter/nf_nat_proto_tcp.c
+++ b/net/netfilter/nf_nat_proto_tcp.c
@@ -70,7 +70,7 @@ tcp_manip_pkt(struct sk_buff *skb,
 		return true;
 
 	l3proto->csum_update(skb, iphdroff, &hdr->check, tuple, maniptype);
-	inet_proto_csum_replace2(&hdr->check, skb, oldport, newport, 0);
+	inet_proto_csum_replace2(&hdr->check, skb, oldport, newport, false);
 	return true;
 }
 
diff --git a/net/netfilter/nf_nat_proto_udp.c b/net/netfilter/nf_nat_proto_udp.c
index b0ede2f..b1e6272 100644
--- a/net/netfilter/nf_nat_proto_udp.c
+++ b/net/netfilter/nf_nat_proto_udp.c
@@ -57,7 +57,7 @@ udp_manip_pkt(struct sk_buff *skb,
 		l3proto->csum_update(skb, iphdroff, &hdr->check,
 				     tuple, maniptype);
 		inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport,
-					 0);
+					 false);
 		if (!hdr->check)
 			hdr->check = CSUM_MANGLED_0;
 	}
diff --git a/net/netfilter/nf_nat_proto_udplite.c b/net/netfilter/nf_nat_proto_udplite.c
index 368f14e..58340c9 100644
--- a/net/netfilter/nf_nat_proto_udplite.c
+++ b/net/netfilter/nf_nat_proto_udplite.c
@@ -56,7 +56,7 @@ udplite_manip_pkt(struct sk_buff *skb,
 	}
 
 	l3proto->csum_update(skb, iphdroff, &hdr->check, tuple, maniptype);
-	inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport, 0);
+	inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport, false);
 	if (!hdr->check)
 		hdr->check = CSUM_MANGLED_0;
 
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index d7f1685..14f8b43 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -225,7 +225,7 @@ unsigned int synproxy_tstamp_adjust(struct sk_buff *skb,
 						     synproxy->tsoff);
 				}
 				inet_proto_csum_replace4(&th->check, skb,
-							 old, *ptr, 0);
+							 old, *ptr, false);
 				return 1;
 			}
 			optoff += op[1];
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 8c3190e..8c02501 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -144,7 +144,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 
 			inet_proto_csum_replace2(&tcph->check, skb,
 						 htons(oldmss), htons(newmss),
-						 0);
+						 false);
 			return 0;
 		}
 	}
@@ -185,18 +185,18 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	memmove(opt + TCPOLEN_MSS, opt, len - sizeof(struct tcphdr));
 
 	inet_proto_csum_replace2(&tcph->check, skb,
-				 htons(len), htons(len + TCPOLEN_MSS), 1);
+				 htons(len), htons(len + TCPOLEN_MSS), true);
 	opt[0] = TCPOPT_MSS;
 	opt[1] = TCPOLEN_MSS;
 	opt[2] = (newmss & 0xff00) >> 8;
 	opt[3] = newmss & 0x00ff;
 
-	inet_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
+	inet_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), false);
 
 	oldval = ((__be16 *)tcph)[6];
 	tcph->doff += TCPOLEN_MSS/4;
 	inet_proto_csum_replace2(&tcph->check, skb,
-				 oldval, ((__be16 *)tcph)[6], 0);
+				 oldval, ((__be16 *)tcph)[6], false);
 	return TCPOLEN_MSS;
 }
 
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index 625fa1d..eb92bff 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -80,7 +80,7 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 				n <<= 8;
 			}
 			inet_proto_csum_replace2(&tcph->check, skb, htons(o),
-						 htons(n), 0);
+						 htons(n), false);
 		}
 		memset(opt + i, TCPOPT_NOP, optl);
 	}
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 14da52d..4f42007 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -284,14 +284,14 @@ static void update_ip_l4_checksum(struct sk_buff *skb, struct iphdr *nh,
 	if (nh->protocol == IPPROTO_TCP) {
 		if (likely(transport_len >= sizeof(struct tcphdr)))
 			inet_proto_csum_replace4(&tcp_hdr(skb)->check, skb,
-						 addr, new_addr, 1);
+						 addr, new_addr, true);
 	} else if (nh->protocol == IPPROTO_UDP) {
 		if (likely(transport_len >= sizeof(struct udphdr))) {
 			struct udphdr *uh = udp_hdr(skb);
 
 			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
 				inet_proto_csum_replace4(&uh->check, skb,
-							 addr, new_addr, 1);
+							 addr, new_addr, true);
 				if (!uh->check)
 					uh->check = CSUM_MANGLED_0;
 			}
@@ -316,14 +316,14 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 	if (l4_proto == NEXTHDR_TCP) {
 		if (likely(transport_len >= sizeof(struct tcphdr)))
 			inet_proto_csum_replace16(&tcp_hdr(skb)->check, skb,
-						  addr, new_addr, 1);
+						  addr, new_addr, true);
 	} else if (l4_proto == NEXTHDR_UDP) {
 		if (likely(transport_len >= sizeof(struct udphdr))) {
 			struct udphdr *uh = udp_hdr(skb);
 
 			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
 				inet_proto_csum_replace16(&uh->check, skb,
-							  addr, new_addr, 1);
+							  addr, new_addr, true);
 				if (!uh->check)
 					uh->check = CSUM_MANGLED_0;
 			}
@@ -331,7 +331,7 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 	} else if (l4_proto == NEXTHDR_ICMP) {
 		if (likely(transport_len >= sizeof(struct icmp6hdr)))
 			inet_proto_csum_replace16(&icmp6_hdr(skb)->icmp6_cksum,
-						  skb, addr, new_addr, 1);
+						  skb, addr, new_addr, true);
 	}
 }
 
@@ -498,7 +498,7 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 static void set_tp_port(struct sk_buff *skb, __be16 *port,
 			__be16 new_port, __sum16 *check)
 {
-	inet_proto_csum_replace2(check, skb, *port, new_port, 0);
+	inet_proto_csum_replace2(check, skb, *port, new_port, false);
 	*port = new_port;
 }
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 5be0b3c..b7c4ead 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -162,7 +162,8 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 			goto drop;
 
 		tcph = (void *)(skb_network_header(skb) + ihl);
-		inet_proto_csum_replace4(&tcph->check, skb, addr, new_addr, 1);
+		inet_proto_csum_replace4(&tcph->check, skb, addr, new_addr,
+					 true);
 		break;
 	}
 	case IPPROTO_UDP:
@@ -178,7 +179,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		udph = (void *)(skb_network_header(skb) + ihl);
 		if (udph->check || skb->ip_summed == CHECKSUM_PARTIAL) {
 			inet_proto_csum_replace4(&udph->check, skb, addr,
-						 new_addr, 1);
+						 new_addr, true);
 			if (!udph->check)
 				udph->check = CSUM_MANGLED_0;
 		}
@@ -231,7 +232,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 			iph->saddr = new_addr;
 
 		inet_proto_csum_replace4(&icmph->checksum, skb, addr, new_addr,
-					 0);
+					 false);
 		break;
 	}
 	default:
-- 
1.8.1
