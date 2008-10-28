From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Tue, 28 Oct 2008 23:45:15 +0100
Message-ID: <490795FB.2000201@cosmosbay.com>
References: <20081007160729.60c076c4@speedy>	<20081007.135548.56141000.davem@davemloft.net>	<48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41885 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbYJ1XtH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:49:07 -0400
In-Reply-To: <49077918.4050706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> RCUification of UDP hash tables
>=20
> Goals are :
>=20
> 1) Optimizing handling of incoming Unicast UDP frames, so that no mem=
ory
>  writes should happen in the fast path. Using an array of rwlocks (on=
e per
>  slot for example is not an option in this regard)
>=20
>  Note: Multicasts and broadcasts still will need to take a lock,
>  because doing a full lockless lookup in this case is difficult.
>=20
> 2) No expensive operations in the socket bind/unhash phases :
>   - No expensive synchronize_rcu() calls.
>=20
>   - No added rcu_head in socket structure, increasing memory needs,
>   but more important, forcing us to use call_rcu() calls,
>   that have the bad property of making sockets structure cold.
>   (rcu grace period between socket freeing and its potential reuse
>    make this socket being cold in CPU cache).
>   David did a previous patch using call_rcu() and noticed a 20%
>   impact on TCP connection rates.
>   Quoting Cristopher Lameter :
>    "Right. That results in cacheline cooldown. You'd want to recycle
>     the object as they are cache hot on a per cpu basis. That is scre=
wed
>     up by the delayed regular rcu processing. We have seen multiple
>     regressions due to cacheline cooldown.
>     The only choice in cacheline hot sensitive areas is to deal with =
the
>     complexity that comes with SLAB_DESTROY_BY_RCU or give up on RCU.=
"
>=20
>   - Because udp sockets are allocated from dedicated kmem_cache,
>   use of SLAB_DESTROY_BY_RCU can help here.
>=20
> Theory of operation :
> ---------------------
>=20
> As the lookup is lockfree (using rcu_read_lock()/rcu_read_unlock()),
> special attention must be taken by readers and writers.
>=20
> Use of SLAB_DESTROY_BY_RCU is tricky too, because a socket can be fre=
ed,
> reused, inserted in a different chain or in worst case in the same ch=
ain
> while readers could do lookups in the same time.
>=20
> In order to avoid loops, a reader must check each socket found in a c=
hain
> really belongs to the chain the reader was traversing. If it finds a
> mismatch, lookup must start again at the begining. This *restart* loo=
p
> is the reason we had to use rdlock for the multicast case, because
> we dont want to send same message several times to the same socket.
>=20
> We use RCU only for fast path. Thus, /proc/net/udp still take rdlocks=
=2E
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> include/net/sock.h |   37 ++++++++++++++++++++++++++++++++++++-
> net/core/sock.c    |    3 ++-
> net/ipv4/udp.c     |   35 ++++++++++++++++++++++++++---------
> net/ipv4/udplite.c |    1 +
> net/ipv6/udp.c     |   25 ++++++++++++++++++-------
> net/ipv6/udplite.c |    1 +
> 6 files changed, 84 insertions(+), 18 deletions(-)
>=20

On ipv6 side, I forgot to add a check before compute_score(), like I di=
d on ipv4


+	rcu_read_lock();
+begin:
+	result =3D NULL;
+	badness =3D -1;
+	sk_for_each_rcu(sk, node, &hslot->head) {

< BEGIN HERE missing part --->
		/*
		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
		 * We must check this item was not moved to another chain
		 */
		if (udp_hashfn(net, sk->sk_hash) !=3D hash)
			goto begin;

< END missing part --->
 		score =3D compute_score(sk, net, hnum, saddr, sport, daddr, dport, d=
if);
 		if (score > badness) {
 			result =3D sk;
 			badness =3D score;
 		}
 	}
-	if (result)
-		sock_hold(result);
-	read_unlock(&hslot->lock);
+	if (result) {
+		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+			result =3D NULL;
+		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
+					daddr, dport, dif) < badness)) {
+			sock_put(result);
+			goto begin;
+ 		}
+	}


I will submit a new patch serie tomorrow, with :

Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christian Be=
ll

Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV6,=20

Thanks

