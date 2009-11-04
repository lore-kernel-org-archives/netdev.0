From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip_frag:
Date: Wed, 04 Nov 2009 23:11:49 +0100
Message-ID: <4AF1FC25.9090006@gmail.com>
References: <4AF1F809.4090903@gmail.com> <1257372051.24051.8.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44637 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbZKDWLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:11:52 -0500
In-Reply-To: <1257372051.24051.8.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches a =C3=A9crit :
=20
> Hi Eric.  If you're going to do more of these, could you please
> convert them to the more standard kernel style as well?
>=20
> 	var =3D func(foo);
> 	if (var) {
> 		etc...
>=20
>=20

Well, rule of thumb is : dont mix cleanups with functional changes :)

But yes, I suspect David wont shout too much if I do one trivial cleanu=
p
on the fly :)

Anyway my patch title was incomplete...

Thanks

[PATCH net-next-2.6] ip_frag: dont touch device refcount

When sending fragmentation expiration ICMP V4/V6 messages,
we can avoid touching device refcount, thanks to RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |    7 ++++---
 net/ipv6/reassembly.c  |   13 ++++++-------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 575f9bd..b007f8a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -206,10 +206,11 @@ static void ip_expire(unsigned long arg)
 		struct sk_buff *head =3D qp->q.fragments;
=20
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
-		if ((head->dev =3D dev_get_by_index(net, qp->iif)) !=3D NULL) {
+		rcu_read_lock();
+		head->dev =3D dev_get_by_index_rcu(net, qp->iif);
+		if (head->dev)
 			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-			dev_put(head->dev);
-		}
+		rcu_read_unlock();
 	}
 out:
 	spin_unlock(&qp->q.lock);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index da5bd0e..dce699f 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -208,18 +208,17 @@ static void ip6_frag_expire(unsigned long data)
 	fq_kill(fq);
=20
 	net =3D container_of(fq->q.net, struct net, ipv6.frags);
-	dev =3D dev_get_by_index(net, fq->iif);
+	rcu_read_lock();
+	dev =3D dev_get_by_index_rcu(net, fq->iif);
 	if (!dev)
-		goto out;
+		goto out_rcu_unlock;
=20
-	rcu_read_lock();
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
-	rcu_read_unlock();
=20
 	/* Don't send error if the first segment did not arrive. */
 	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
-		goto out;
+		goto out_rcu_unlock;
=20
 	/*
 	   But use as source device on which LAST ARRIVED
@@ -228,9 +227,9 @@ static void ip6_frag_expire(unsigned long data)
 	 */
 	fq->q.fragments->dev =3D dev;
 	icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME,=
 0, dev);
+out_rcu_unlock:
+	rcu_read_unlock();
 out:
-	if (dev)
-		dev_put(dev);
 	spin_unlock(&fq->q.lock);
 	fq_put(fq);
 }
