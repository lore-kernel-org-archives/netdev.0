From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: fix potential infinite loop in SO_REUSEPORT logic
Date: Tue, 19 Jan 2016 08:36:43 -0800
Message-ID: <1453221403.1223.266.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
	 <1453170024.1223.251.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1453171769.1223.255.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGizQXqMCbSbi-CCp=Ct7-Mb+0ROtPMYVTAb_GusgQOY6VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35647 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881AbcASQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 11:36:45 -0500
In-Reply-To: <CAEfhGizQXqMCbSbi-CCp=Ct7-Mb+0ROtPMYVTAb_GusgQOY6VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using a combination of connected and un-connected sockets, Dmitry
was able to trigger soft lockups with his fuzzer.

The problem is that sockets in the SO_REUSEPORT array might have
different scores.

Right after sk2=socket(), setsockopt(sk2,...,SO_REUSEPORT, on) and
bind(sk2, ...), but _before_ the connect(sk2) is done, sk2 is added into
the soreuseport array, with a score which is smaller than the score of
first socket sk1 found in hash table (I am speaking of the regular UDP
hash table), if sk1 had the connect() done, giving a +8 to its score.

hash bucket [X] -> sk1 -> sk2 -> NULL

sk1 score = 14  (because it did a connect())
sk2 score = 6

SO_REUSEPORT fast selection is an optimization. If it turns out the
score of the selected socket does not match score of first socket, just
fallback to old SO_REUSEPORT logic instead of trying to be too smart.

Normal SO_REUSEPORT users do not mix different kind of sockets, as this
mechanism is used for load balance traffic.

Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Craig Gallek <kraigatgoog@gmail.com>
---
 net/ipv4/udp.c |   32 +++++++++++++++++++++-----------
 net/ipv6/udp.c |   32 +++++++++++++++++++++-----------
 2 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dc45b538e237..be0b21852b13 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -499,6 +499,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	int score, badness, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 hash = 0;
 
 begin:
@@ -512,14 +513,18 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, skb,
-							    sizeof(struct udphdr));
-				if (sk2) {
-					result = sk2;
-					goto found;
+				if (select_ok) {
+					struct sock *sk2;
+
+					sk2 = reuseport_select_sock(sk, hash, skb,
+							sizeof(struct udphdr));
+					if (sk2) {
+						result = sk2;
+						select_ok = false;
+						goto found;
+					}
 				}
 				matches = 1;
 			}
@@ -563,6 +568,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	int score, badness, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 hash = 0;
 
 	rcu_read_lock();
@@ -601,14 +607,18 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, skb,
+				if (select_ok) {
+					struct sock *sk2;
+
+					sk2 = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
-				if (sk2) {
-					result = sk2;
-					goto found;
+					if (sk2) {
+						result = sk2;
+						select_ok = false;
+						goto found;
+					}
 				}
 				matches = 1;
 			}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5d2c2afffe7b..22e28a44e3c8 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -257,6 +257,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	int score, badness, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 hash = 0;
 
 begin:
@@ -270,14 +271,18 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, skb,
-							    sizeof(struct udphdr));
-				if (sk2) {
-					result = sk2;
-					goto found;
+				if (select_ok) {
+					struct sock *sk2;
+
+					sk2 = reuseport_select_sock(sk, hash, skb,
+							sizeof(struct udphdr));
+					if (sk2) {
+						result = sk2;
+						select_ok = false;
+						goto found;
+					}
 				}
 				matches = 1;
 			}
@@ -321,6 +326,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	int score, badness, matches = 0, reuseport = 0;
+	bool select_ok = true;
 	u32 hash = 0;
 
 	rcu_read_lock();
@@ -358,14 +364,18 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, skb,
+				if (select_ok) {
+					struct sock *sk2;
+
+					sk2 = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
-				if (sk2) {
-					result = sk2;
-					goto found;
+					if (sk2) {
+						result = sk2;
+						select_ok = false;
+						goto found;
+					}
 				}
 				matches = 1;
 			}
