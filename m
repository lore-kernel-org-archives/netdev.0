From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 02/02]: Convert old checksum helper names
Date: Thu, 29 Nov 2007 10:57:37 +0100 (MET)
Message-ID: <20071129095736.11756.21538.sendpatchset@localhost.localdomain>
References: <20071129095733.11756.86966.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40409 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757964AbXK2J5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 04:57:39 -0500
In-Reply-To: <20071129095733.11756.86966.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Convert old checksum helper names

Kill the defines again, convert to the new checksum helper names and
remove the dependency of NET_ACT_NAT on NETFILTER.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit da8ffc485b6e8e429c51f7f1c03a0ae824eca848
tree 2198c531b224c82e74b66b3029dc8fec1c555105
parent 01879e49c8b53ea8cfb28f275db18ee7cbe54304
author Patrick McHardy <kaber@trash.net> Thu, 29 Nov 2007 10:48:52 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 29 Nov 2007 10:48:52 +0100

 include/linux/netfilter.h              |    5 -----
 net/ipv4/netfilter/ipt_ECN.c           |    6 +++---
 net/ipv4/netfilter/ipt_TOS.c           |    2 +-
 net/ipv4/netfilter/ipt_TTL.c           |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c       |    4 ++--
 net/ipv4/netfilter/nf_nat_helper.c     |   20 ++++++++++----------
 net/ipv4/netfilter/nf_nat_proto_icmp.c |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_tcp.c  |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_udp.c  |    6 +++---
 net/netfilter/xt_TCPMSS.c              |   17 +++++++++--------
 net/sched/Kconfig                      |    1 -
 net/sched/act_nat.c                    |   12 ++++++------
 12 files changed, 40 insertions(+), 45 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index e2bf6d2..f42e436 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -298,11 +298,6 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
 
-#define nf_csum_replace4	csum_replace4
-#define nf_csum_replace2	csum_replace2
-#define nf_proto_csum_replace4	inet_proto_csum_replace4
-#define nf_proto_csum_replace2	inet_proto_csum_replace2
-
 struct nf_afinfo {
 	unsigned short	family;
 	__sum16		(*checksum)(struct sk_buff *skb, unsigned int hook,
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index add1100..e8d5f68 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -38,7 +38,7 @@ set_ect_ip(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 		oldtos = iph->tos;
 		iph->tos &= ~IPT_ECN_IP_MASK;
 		iph->tos |= (einfo->ip_ect & IPT_ECN_IP_MASK);
-		nf_csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
+		csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
 	}
 	return true;
 }
@@ -71,8 +71,8 @@ set_ect_tcp(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 	if (einfo->operation & IPT_ECN_OP_SET_CWR)
 		tcph->cwr = einfo->proto.tcp.cwr;
 
-	nf_proto_csum_replace2(&tcph->check, skb,
-				oldval, ((__be16 *)tcph)[6], 0);
+	inet_proto_csum_replace2(&tcph->check, skb,
+				 oldval, ((__be16 *)tcph)[6], 0);
 	return true;
 }
 
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
index d4573ba..7b4a6ca 100644
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -38,7 +38,7 @@ target(struct sk_buff *skb,
 		iph = ip_hdr(skb);
 		oldtos = iph->tos;
 		iph->tos = (iph->tos & IPTOS_PREC_MASK) | tosinfo->tos;
-		nf_csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
+		csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
 	}
 	return XT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/ipt_TTL.c b/net/ipv4/netfilter/ipt_TTL.c
index c620a05..00ddfbe 100644
--- a/net/ipv4/netfilter/ipt_TTL.c
+++ b/net/ipv4/netfilter/ipt_TTL.c
@@ -54,8 +54,8 @@ ipt_ttl_target(struct sk_buff *skb,
 	}
 
 	if (new_ttl != iph->ttl) {
-		nf_csum_replace2(&iph->check, htons(iph->ttl << 8),
-					      htons(new_ttl << 8));
+		csum_replace2(&iph->check, htons(iph->ttl << 8),
+					   htons(new_ttl << 8));
 		iph->ttl = new_ttl;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index d237511..746c2ef 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -372,10 +372,10 @@ manip_pkt(u_int16_t proto,
 	iph = (void *)skb->data + iphdroff;
 
 	if (maniptype == IP_NAT_MANIP_SRC) {
-		nf_csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
+		csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
 		iph->saddr = target->src.u3.ip;
 	} else {
-		nf_csum_replace4(&iph->check, iph->daddr, target->dst.u3.ip);
+		csum_replace4(&iph->check, iph->daddr, target->dst.u3.ip);
 		iph->daddr = target->dst.u3.ip;
 	}
 	return 1;
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index d00b8b2..53f79a3 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -180,8 +180,8 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 								datalen, 0));
 		}
 	} else
-		nf_proto_csum_replace2(&tcph->check, skb,
-				       htons(oldlen), htons(datalen), 1);
+		inet_proto_csum_replace2(&tcph->check, skb,
+					 htons(oldlen), htons(datalen), 1);
 
 	if (rep_len != match_len) {
 		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
@@ -270,8 +270,8 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 				udph->check = CSUM_MANGLED_0;
 		}
 	} else
-		nf_proto_csum_replace2(&udph->check, skb,
-				       htons(oldlen), htons(datalen), 1);
+		inet_proto_csum_replace2(&udph->check, skb,
+					 htons(oldlen), htons(datalen), 1);
 
 	return 1;
 }
@@ -310,10 +310,10 @@ sack_adjust(struct sk_buff *skb,
 			 ntohl(sack->start_seq), new_start_seq,
 			 ntohl(sack->end_seq), new_end_seq);
 
-		nf_proto_csum_replace4(&tcph->check, skb,
-				       sack->start_seq, new_start_seq, 0);
-		nf_proto_csum_replace4(&tcph->check, skb,
-				       sack->end_seq, new_end_seq, 0);
+		inet_proto_csum_replace4(&tcph->check, skb,
+					 sack->start_seq, new_start_seq, 0);
+		inet_proto_csum_replace4(&tcph->check, skb,
+					 sack->end_seq, new_end_seq, 0);
 		sack->start_seq = new_start_seq;
 		sack->end_seq = new_end_seq;
 		sackoff += sizeof(*sack);
@@ -397,8 +397,8 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	else
 		newack = htonl(ntohl(tcph->ack_seq) - other_way->offset_before);
 
-	nf_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, 0);
-	nf_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack, 0);
+	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, 0);
+	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack, 0);
 
 	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
 		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index b9fc724..088bb14 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -65,8 +65,8 @@ icmp_manip_pkt(struct sk_buff *skb,
 		return 0;
 
 	hdr = (struct icmphdr *)(skb->data + hdroff);
-	nf_proto_csum_replace2(&hdr->checksum, skb,
-			       hdr->un.echo.id, tuple->src.u.icmp.id, 0);
+	inet_proto_csum_replace2(&hdr->checksum, skb,
+				 hdr->un.echo.id, tuple->src.u.icmp.id, 0);
 	hdr->un.echo.id = tuple->src.u.icmp.id;
 	return 1;
 }
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index 6bab2e1..633c53f 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -132,8 +132,8 @@ tcp_manip_pkt(struct sk_buff *skb,
 	if (hdrsize < sizeof(*hdr))
 		return 1;
 
-	nf_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
-	nf_proto_csum_replace2(&hdr->check, skb, oldport, newport, 0);
+	inet_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+	inet_proto_csum_replace2(&hdr->check, skb, oldport, newport, 0);
 	return 1;
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index cbf1a61..9c6519c 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -117,9 +117,9 @@ udp_manip_pkt(struct sk_buff *skb,
 		portptr = &hdr->dest;
 	}
 	if (hdr->check || skb->ip_summed == CHECKSUM_PARTIAL) {
-		nf_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
-		nf_proto_csum_replace2(&hdr->check, skb, *portptr, newport,
-				       0);
+		inet_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+		inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport,
+					 0);
 		if (!hdr->check)
 			hdr->check = CSUM_MANGLED_0;
 	}
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 851e121..307c94c 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -95,8 +95,9 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 			opt[i+2] = (newmss & 0xff00) >> 8;
 			opt[i+3] = newmss & 0x00ff;
 
-			nf_proto_csum_replace2(&tcph->check, skb,
-					       htons(oldmss), htons(newmss), 0);
+			inet_proto_csum_replace2(&tcph->check, skb,
+						 htons(oldmss), htons(newmss),
+						 0);
 			return 0;
 		}
 	}
@@ -117,19 +118,19 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
 	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
 
-	nf_proto_csum_replace2(&tcph->check, skb,
-			       htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
+	inet_proto_csum_replace2(&tcph->check, skb,
+				 htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
 	opt[0] = TCPOPT_MSS;
 	opt[1] = TCPOLEN_MSS;
 	opt[2] = (newmss & 0xff00) >> 8;
 	opt[3] = newmss & 0x00ff;
 
-	nf_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
+	inet_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
 
 	oldval = ((__be16 *)tcph)[6];
 	tcph->doff += TCPOLEN_MSS/4;
-	nf_proto_csum_replace2(&tcph->check, skb,
-				oldval, ((__be16 *)tcph)[6], 0);
+	inet_proto_csum_replace2(&tcph->check, skb,
+				 oldval, ((__be16 *)tcph)[6], 0);
 	return TCPOLEN_MSS;
 }
 
@@ -152,7 +153,7 @@ xt_tcpmss_target4(struct sk_buff *skb,
 	if (ret > 0) {
 		iph = ip_hdr(skb);
 		newlen = htons(ntohs(iph->tot_len) + ret);
-		nf_csum_replace2(&iph->check, iph->tot_len, newlen);
+		csum_replace2(&iph->check, iph->tot_len, newlen);
 		iph->tot_len = newlen;
 	}
 	return XT_CONTINUE;
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 9c15c48..f5ab54b 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -445,7 +445,6 @@ config NET_ACT_IPT
 config NET_ACT_NAT
         tristate "Stateless NAT"
         depends on NET_CLS_ACT
-        select NETFILTER
         ---help---
 	  Say Y here to do stateless NAT on IPv4 packets.  You should use
 	  netfilter for NAT unless you know what you are doing.
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index c96273b..da5c1ea 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -151,7 +151,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		else
 			iph->daddr = new_addr;
 
-		nf_csum_replace4(&iph->check, addr, new_addr);
+		csum_replace4(&iph->check, addr, new_addr);
 	}
 
 	ihl = iph->ihl * 4;
@@ -169,7 +169,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 			goto drop;
 
 		tcph = (void *)(skb_network_header(skb) + ihl);
-		nf_proto_csum_replace4(&tcph->check, skb, addr, new_addr, 1);
+		inet_proto_csum_replace4(&tcph->check, skb, addr, new_addr, 1);
 		break;
 	}
 	case IPPROTO_UDP:
@@ -184,8 +184,8 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 
 		udph = (void *)(skb_network_header(skb) + ihl);
 		if (udph->check || skb->ip_summed == CHECKSUM_PARTIAL) {
-			nf_proto_csum_replace4(&udph->check, skb, addr,
-					       new_addr, 1);
+			inet_proto_csum_replace4(&udph->check, skb, addr,
+						 new_addr, 1);
 			if (!udph->check)
 				udph->check = CSUM_MANGLED_0;
 		}
@@ -232,8 +232,8 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		else
 			iph->saddr = new_addr;
 
-		nf_proto_csum_replace4(&icmph->checksum, skb, addr, new_addr,
-				       1);
+		inet_proto_csum_replace4(&icmph->checksum, skb, addr, new_addr,
+					 1);
 		break;
 	}
 	default:
