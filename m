From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Mon, 4 Jan 2010 16:51:09 -0200
Message-ID: <20100104185109.GA2706@sysclose.org>
References: <1262183005-28406-1-git-send-email-fleitner@redhat.com>
 <20100103.215441.43026709.davem@davemloft.net>
 <20100104112957.GA2573@sysclose.org>
 <4B41E7F7.2030003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcbhh.dreamhost.com ([208.97.132.177]:55558 "EHLO
	homiemail-a21.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753826Ab0ADSvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 13:51:14 -0500
Content-Disposition: inline
In-Reply-To: <4B41E7F7.2030003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 02:07:03PM +0100, Eric Dumazet wrote:
> Le 04/01/2010 12:29, Flavio Leitner a =E9crit :
> =20
> > Then, I tried using call_rcu() to avoid the problem you are saying,
> > but when you stop the reproducer, sk_free() will warn printing=20
> > "optmem leakage.." because the rcu callback didn't run yet.
> >=20
> >=20
>=20
> This is probably because your call_rcu() callback was trying to call =
sock_kfree_s() ?

yes, correct.

>=20
>  		rtnl_unlock();
> 		call_rcu(&iml->lock, callback_func)
>=20
> callback_func()
> {
> 	sock_kfree_s(sk, iml, sizeof(*iml));
> }
>=20
>=20
>=20
> Take a look at sock_kfree_s() definition :
>=20
> void sock_kfree_s(struct sock *sk, void *mem, int size)
> {
>         kfree(mem);
>         atomic_sub(size, &sk->sk_omem_alloc);
> }
>=20
>=20
> You can certainly try :
>=20
> 	rtnl_unlock();
> 	atomic_sub(sizeof(*iml), sk->sk_omem_alloc);
> 	call_rcu(&iml->rcu, kfree);
>=20
> (immediate sk_omem_alloc handling, but deferred kfree())

Ok, below is the new version using call_rcu(). I'm still running my
tests here, so I'm planning to resubmit it later if this version is
okay with you.

thanks!

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 724c27e..9cccd16 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -170,6 +170,7 @@ struct ip_mc_socklist {
 	struct ip_mreqn		multi;
 	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip_sf_socklist	*sflist;
+	struct rcu_head		rcu;
 };
=20
 struct ip_sf_list {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 76c0840..ed154db 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1799,7 +1799,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_=
mreqn *imr)
 	iml->next =3D inet->mc_list;
 	iml->sflist =3D NULL;
 	iml->sfmode =3D MCAST_EXCLUDE;
-	inet->mc_list =3D iml;
+	rcu_assign_pointer(inet->mc_list, iml);
 	ip_mc_inc_group(in_dev, addr);
 	err =3D 0;
 done:
@@ -1825,6 +1825,17 @@ static int ip_mc_leave_src(struct sock *sk, stru=
ct ip_mc_socklist *iml,
 	return err;
 }
=20
+
+void ip_mc_socklist_reclaim(struct rcu_head *rp)
+{
+	struct ip_mc_socklist *iml;
+
+	iml =3D container_of(rp, struct ip_mc_socklist, rcu);
+	/* sk_omem_alloc should have been decreased by the caller*/
+	kfree(iml);
+}
+
+
 /*
  *	Ask a socket to leave a group.
  */
@@ -1854,12 +1865,15 @@ int ip_mc_leave_group(struct sock *sk, struct i=
p_mreqn *imr)
=20
 		(void) ip_mc_leave_src(sk, iml, in_dev);
=20
-		*imlp =3D iml->next;
+		rcu_assign_pointer(*imlp, iml->next);
=20
 		if (in_dev)
 			ip_mc_dec_group(in_dev, group);
+
 		rtnl_unlock();
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		/* decrease mem now to avoid the memleak warning */
+		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
+		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
 		return 0;
 	}
 	if (!in_dev)
@@ -2209,30 +2223,40 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_=
addr, __be32 rmt_addr, int dif)
 	struct ip_mc_socklist *pmc;
 	struct ip_sf_socklist *psl;
 	int i;
+	int ret;
=20
+	ret =3D 1;
 	if (!ipv4_is_multicast(loc_addr))
-		return 1;
+		goto out;
=20
-	for (pmc=3Dinet->mc_list; pmc; pmc=3Dpmc->next) {
+	rcu_read_lock();
+	for (pmc=3Drcu_dereference(inet->mc_list); pmc; pmc=3Drcu_dereference=
(pmc->next)) {
 		if (pmc->multi.imr_multiaddr.s_addr =3D=3D loc_addr &&
 		    pmc->multi.imr_ifindex =3D=3D dif)
 			break;
 	}
+	ret =3D inet->mc_all;
 	if (!pmc)
-		return inet->mc_all;
+		goto unlock;
 	psl =3D pmc->sflist;
+	ret =3D (pmc->sfmode =3D=3D MCAST_EXCLUDE);
 	if (!psl)
-		return pmc->sfmode =3D=3D MCAST_EXCLUDE;
+		goto unlock;
=20
 	for (i=3D0; i<psl->sl_count; i++) {
 		if (psl->sl_addr[i] =3D=3D rmt_addr)
 			break;
 	}
+	ret =3D 0;
 	if (pmc->sfmode =3D=3D MCAST_INCLUDE && i >=3D psl->sl_count)
-		return 0;
+		goto unlock;
 	if (pmc->sfmode =3D=3D MCAST_EXCLUDE && i < psl->sl_count)
-		return 0;
-	return 1;
+		goto unlock;
+	ret =3D 1;
+unlock:
+	rcu_read_unlock();
+out:
+	return ret;
 }
=20
 /*
@@ -2245,13 +2269,17 @@ void ip_mc_drop_socket(struct sock *sk)
 	struct ip_mc_socklist *iml;
 	struct net *net =3D sock_net(sk);
=20
-	if (inet->mc_list =3D=3D NULL)
+	rcu_read_lock();
+	if (rcu_dereference(inet->mc_list) =3D=3D NULL) {
+		rcu_read_unlock();
 		return;
+	}
+	rcu_read_unlock();
=20
 	rtnl_lock();
-	while ((iml =3D inet->mc_list) !=3D NULL) {
+	while ((iml =3D rcu_dereference(inet->mc_list)) !=3D NULL) {
 		struct in_device *in_dev;
-		inet->mc_list =3D iml->next;
+		rcu_assign_pointer(inet->mc_list, iml->next);
=20
 		in_dev =3D inetdev_by_index(net, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
@@ -2259,7 +2287,9 @@ void ip_mc_drop_socket(struct sock *sk)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 			in_dev_put(in_dev);
 		}
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		/* decrease mem now to avoid the memleak warning */
+		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
+		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
 	}
 	rtnl_unlock();
 }
--=20
1.6.2.3

