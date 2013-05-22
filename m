From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Tue, 21 May 2013 22:49:25 -0700
Message-ID: <1369201765.3301.299.camel@edumazet-glaptop>
References: <519B38EC.90401@yandex-team.ru>
	 <20130521120906.GD3578@linux.vnet.ibm.com>
	 <1369143885.3301.221.camel@edumazet-glaptop>
	 <519B8908.9080007@yandex-team.ru>
	 <1369150693.3301.233.camel@edumazet-glaptop>
	 <519BB90B.6080706@yandex-team.ru>
	 <1369188080.3301.268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:57214 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab3EVFt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 01:49:27 -0400
In-Reply-To: <1369188080.3301.268.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 19:01 -0700, Eric Dumazet wrote:

> Please use ACCESS_ONCE(), which is the standard way to deal with this,
> and remove the rcu_dereference_raw() in 
> hlist_nulls_for_each_entry_rcu()
> 
> something like : (for the nulls part only)

Thinking a bit more about this, I am a bit worried by other uses of
ACCESS_ONCE(ptr->field)

rcu_dereference(ptr->field) intent is to reload ptr->field every time
from memory.

Do we really need a

#define ACCESS_FIELD_ONCE(PTR, FIELD) (((volatile typeof(*PTR) *)PTR)->FIELD)

#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x)) 

and change all rcu_dererence(ptr->field) occurrences ?

I probably miss something obvious.

Anyway, following patch seems to also solve the problem, I need a sleep to understand why.


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0bf5d39..10b5c54 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -410,7 +410,7 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct hlist_nulls_head *head, unsigned int slot2)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -420,7 +420,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 begin:
 	result = NULL;
 	badness = 0;
-	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
+	udp_portaddr_for_each_entry_rcu(sk, node, head) {
 		score = compute_score2(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
@@ -483,7 +483,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 		result = udp4_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  &hslot2->head, slot2);
 		if (!result) {
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
@@ -493,7 +493,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 			result = udp4_lib_lookup2(net, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
-						  hslot2, slot2);
+						  &hslot2->head, slot2);
 		}
 		rcu_read_unlock();
 		return result;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 42923b1..b5bc667 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -200,7 +200,7 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct hlist_nulls_head *head, unsigned int slot2)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -210,7 +210,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 begin:
 	result = NULL;
 	badness = -1;
-	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
+	udp_portaddr_for_each_entry_rcu(sk, node, head) {
 		score = compute_score2(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
@@ -274,7 +274,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 		result = udp6_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  &hslot2->head, slot2);
 		if (!result) {
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
 			slot2 = hash2 & udptable->mask;
@@ -284,7 +284,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 			result = udp6_lib_lookup2(net, saddr, sport,
 						  &in6addr_any, hnum, dif,
-						  hslot2, slot2);
+						  &hslot2->head, slot2);
 		}
 		rcu_read_unlock();
 		return result;
