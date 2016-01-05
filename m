From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb
 in error case
Date: Tue, 05 Jan 2016 10:31:06 -0800
Message-ID: <1452018666.8255.115.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
	 <1452015516.8255.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGiyu0iRJcnOUiippoOtRZzUwoSihGVb3240G9hBSh0t5bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33137 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbcAESbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 13:31:08 -0500
Received: by mail-pf0-f170.google.com with SMTP id q63so188247986pfb.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 10:31:08 -0800 (PST)
In-Reply-To: <CAEfhGiyu0iRJcnOUiippoOtRZzUwoSihGVb3240G9hBSh0t5bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 12:47 -0500, Craig Gallek wrote:
> On Tue, Jan 5, 2016 at 12:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >
> > BTW, why UDP calls reuseport_select_sock() with hdr_len == 0 sometimes ?
> hdr_len only matters when you have an skb to work with.  In both of
> the call sites of your suggested patch, NULL is passed for the skb
> parameter so hdr_len is never used.  When no skb is available, the
> code falls back to the hash-based method used in the non-BPF case.

But skb _is_ available !

We expect the BPF to always be run to get consistent selection.

udp4_lib_lookup2() can be used if the hash bucket has more than 10
sockets. SO_REUSEPORT should work the same way, ie BPF filter shoulw
work regardless of number of sockets in hash table.

diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index ae0969c0fc2e..2b0bbecbc4b5 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -220,7 +220,7 @@ struct sock *reuseport_select_sock(struct sock *sk,
 		/* paired with smp_wmb() in reuseport_add_sock() */
 		smp_rmb();
 
-		if (prog && skb)
+		if (prog)
 			sk2 = run_bpf(reuse, socks, prog, skb, hdr_len);
 		else
 			sk2 = reuse->socks[reciprocal_scale(hash, socks)];
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 835378365f25..3a66731e3af6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -493,7 +493,8 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct udp_hslot *hslot2, unsigned int slot2,
+		struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -514,7 +515,8 @@ begin:
 				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -573,7 +575,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 		result = udp4_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  hslot2, slot2, skb);
 		if (!result) {
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
@@ -583,7 +585,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 			result = udp4_lib_lookup2(net, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
-						  hslot2, slot2);
+						  hslot2, slot2, skb);
 		}
 		rcu_read_unlock();
 		return result;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 56fcb55fda31..5d2c2afffe7b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -251,7 +251,8 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct udp_hslot *hslot2, unsigned int slot2,
+		struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -272,7 +273,8 @@ begin:
 				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -331,7 +333,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 		result = udp6_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  hslot2, slot2, skb);
 		if (!result) {
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
 			slot2 = hash2 & udptable->mask;
@@ -341,7 +343,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 			result = udp6_lib_lookup2(net, saddr, sport,
 						  &in6addr_any, hnum, dif,
-						  hslot2, slot2);
+						  hslot2, slot2, skb);
 		}
 		rcu_read_unlock();
 		return result;
