From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Mon, 18 Jan 2016 18:49:29 -0800
Message-ID: <1453171769.1223.255.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
	 <1453170024.1223.251.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453170024.1223.251.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-18 at 18:20 -0800, Eric Dumazet wrote:

> Same reason really.
> 
> Right after sk2=socket(), setsockopt(sk2,...,SO_REUSEPORT, on) and
> bind(sk2, ...), but _before_ the connect(sk2) is done, sk2 is added into
> the soreuseport array, with a score which is smaller than the score of
> first socket sk1 found in hash table (I am speaking of the regular UDP
> hash table), if sk1 had the connect() done, giving a +8 to its score.
> 
> So the bug has nothing to do with rcu or rcu_bh, it is just an infinite
> loop caused by different scores.
> 
> 
> hash bucket [X] -> sk1 -> sk2 -> NULL
> 
> sk1 score = 14  (because it did a connect())
> sk2 score = 6
> 
> I guess we should relax the test done after atomic_inc_not_zero_hint()
> to only test the base keys : 
> (net, ipv6_only_sock, inet->inet_rcv_saddr & inet->inet_num)

One way to fix the issue it to not call reuseport_select_sock() if loop
was restarted, and fallback to the old mechanism : If the optimized
version might have a problem, just fallback to the safe thing.

IPv4 only patch :

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dc45b538e237..8f1b2a9c90f8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -500,6 +500,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	struct hlist_nulls_node *node;
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
+	bool select_ok = true;
 
 begin:
 	result = NULL;
@@ -512,14 +513,18 @@ begin:
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
@@ -564,6 +569,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
+	bool select_ok = true;
 
 	rcu_read_lock();
 	if (hslot->count > 10) {
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
+						select_ok = false;
+						result = sk2;
+						goto found;
+					}
 				}
 				matches = 1;
 			}
