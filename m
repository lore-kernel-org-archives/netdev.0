From: akpm@linux-foundation.org
Subject: [patch 07/11] remove tcp header from tcp_v4_check
Date: Mon, 05 Feb 2007 16:31:05 -0800
Message-ID: <200702060032.l160W8cb004636@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	deweerdt@free.fr, frederik.deweerdt@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41463 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933113AbXBFAcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frederik Deweerdt <deweerdt@free.fr>

The tcphdr struct passed to tcp_v4_check is not used, the following
patch removes it from the parameter list.

Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/tcp.h                  |    5 ++---
 net/ipv4/netfilter/ip_nat_helper.c |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c    |    2 +-
 net/ipv4/netfilter/nf_nat_helper.c |    2 +-
 net/ipv4/tcp_ipv4.c                |   12 ++++++------
 5 files changed, 11 insertions(+), 12 deletions(-)

diff -puN include/net/tcp.h~remove-tcp-header-from-tcp_v4_check-take-2 include/net/tcp.h
--- a/include/net/tcp.h~remove-tcp-header-from-tcp_v4_check-take-2
+++ a/include/net/tcp.h
@@ -802,9 +802,8 @@ static inline void tcp_update_wl(struct 
 /*
  * Calculate(/check) TCP checksum
  */
-static inline __sum16 tcp_v4_check(struct tcphdr *th, int len,
-			       __be32 saddr, __be32 daddr,
-			       __wsum base)
+static inline __sum16 tcp_v4_check(int len, __be32 saddr,
+				   __be32 daddr, __wsum base)
 {
 	return csum_tcpudp_magic(saddr,daddr,len,IPPROTO_TCP,base);
 }
diff -puN net/ipv4/netfilter/ip_nat_helper.c~remove-tcp-header-from-tcp_v4_check-take-2 net/ipv4/netfilter/ip_nat_helper.c
--- a/net/ipv4/netfilter/ip_nat_helper.c~remove-tcp-header-from-tcp_v4_check-take-2
+++ a/net/ipv4/netfilter/ip_nat_helper.c
@@ -183,7 +183,7 @@ ip_nat_mangle_tcp_packet(struct sk_buff 
 	datalen = (*pskb)->len - iph->ihl*4;
 	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		tcph->check = 0;
-		tcph->check = tcp_v4_check(tcph, datalen,
+		tcph->check = tcp_v4_check(datalen,
 					   iph->saddr, iph->daddr,
 					   csum_partial((char *)tcph,
 					   		datalen, 0));
diff -puN net/ipv4/netfilter/ipt_REJECT.c~remove-tcp-header-from-tcp_v4_check-take-2 net/ipv4/netfilter/ipt_REJECT.c
--- a/net/ipv4/netfilter/ipt_REJECT.c~remove-tcp-header-from-tcp_v4_check-take-2
+++ a/net/ipv4/netfilter/ipt_REJECT.c
@@ -116,7 +116,7 @@ static void send_reset(struct sk_buff *o
 
 	/* Adjust TCP checksum */
 	tcph->check = 0;
-	tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
+	tcph->check = tcp_v4_check(sizeof(struct tcphdr),
 				   nskb->nh.iph->saddr,
 				   nskb->nh.iph->daddr,
 				   csum_partial((char *)tcph,
diff -puN net/ipv4/netfilter/nf_nat_helper.c~remove-tcp-header-from-tcp_v4_check-take-2 net/ipv4/netfilter/nf_nat_helper.c
--- a/net/ipv4/netfilter/nf_nat_helper.c~remove-tcp-header-from-tcp_v4_check-take-2
+++ a/net/ipv4/netfilter/nf_nat_helper.c
@@ -176,7 +176,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff 
 	datalen = (*pskb)->len - iph->ihl*4;
 	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		tcph->check = 0;
-		tcph->check = tcp_v4_check(tcph, datalen,
+		tcph->check = tcp_v4_check(datalen,
 					   iph->saddr, iph->daddr,
 					   csum_partial((char *)tcph,
 					   		datalen, 0));
diff -puN net/ipv4/tcp_ipv4.c~remove-tcp-header-from-tcp_v4_check-take-2 net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c~remove-tcp-header-from-tcp_v4_check-take-2
+++ a/net/ipv4/tcp_ipv4.c
@@ -502,11 +502,11 @@ void tcp_v4_send_check(struct sock *sk, 
 	struct tcphdr *th = skb->h.th;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~tcp_v4_check(th, len,
-					  inet->saddr, inet->daddr, 0);
+		th->check = ~tcp_v4_check(len, inet->saddr,
+					  inet->daddr, 0);
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
-		th->check = tcp_v4_check(th, len, inet->saddr, inet->daddr,
+		th->check = tcp_v4_check(len, inet->saddr, inet->daddr,
 					 csum_partial((char *)th,
 						      th->doff << 2,
 						      skb->csum));
@@ -525,7 +525,7 @@ int tcp_v4_gso_send_check(struct sk_buff
 	th = skb->h.th;
 
 	th->check = 0;
-	th->check = ~tcp_v4_check(th, skb->len, iph->saddr, iph->daddr, 0);
+	th->check = ~tcp_v4_check(skb->len, iph->saddr, iph->daddr, 0);
 	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
@@ -747,7 +747,7 @@ static int tcp_v4_send_synack(struct soc
 	if (skb) {
 		struct tcphdr *th = skb->h.th;
 
-		th->check = tcp_v4_check(th, skb->len,
+		th->check = tcp_v4_check(skb->len,
 					 ireq->loc_addr,
 					 ireq->rmt_addr,
 					 csum_partial((char *)th, skb->len,
@@ -1514,7 +1514,7 @@ static struct sock *tcp_v4_hnd_req(struc
 static __sum16 tcp_v4_checksum_init(struct sk_buff *skb)
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!tcp_v4_check(skb->h.th, skb->len, skb->nh.iph->saddr,
+		if (!tcp_v4_check(skb->len, skb->nh.iph->saddr,
 				  skb->nh.iph->daddr, skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			return 0;
_
