From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cache forver in 3.2.0-rc2-00400-g866d43c ?
Date: Wed, 23 Nov 2011 20:44:07 +0100
Message-ID: <1322077447.2775.6.camel@edumazet-laptop>
References: <201111231910.37190.a.miskiewicz@gmail.com>
	 <1322072541.2775.1.camel@edumazet-laptop>
	 <201111231931.08596.a.miskiewicz@gmail.com>
	 <1322073450.2775.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:43398 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754136Ab1KWToM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 14:44:12 -0500
Received: by lahl5 with SMTP id l5so27320lah.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 11:44:11 -0800 (PST)
In-Reply-To: <1322073450.2775.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 19:37 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 23 novembre 2011 =C3=A0 19:31 +0100, Arkadiusz Mi=C5=9Bki=
ewicz a
> =C3=A9crit :
>=20
> > Mine 00400-g866d43c was after 6fe4c6d466e95d31164f14b1ac4aefb51f0f4=
f82 (which=20
> > is merge of ipv4: fix redirect handling), so I have it.
> >=20
> > (I'm using pure linus git repo)
>=20
> OK thanks for this information, I am working on a patch.
>=20
>=20

Please test the following patch, thanks !

 include/net/inetpeer.h |    1 +
 net/ipv4/route.c       |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 78c83e6..e9ff3fc 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -35,6 +35,7 @@ struct inet_peer {
=20
 	u32			metrics[RTAX_MAX];
 	u32			rate_tokens;	/* rate limiting for ICMP */
+	int			redirect_genid;
 	unsigned long		rate_last;
 	unsigned long		pmtu_expires;
 	u32			pmtu_orig;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0c74da8..be8643da 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -131,6 +131,7 @@ static int ip_rt_mtu_expires __read_mostly	=3D 10 *=
 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		=3D 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	=3D 256;
 static int rt_chain_length_max __read_mostly	=3D 20;
+static int redirect_genid;
=20
 /*
  *	Interface to generic destination cache.
@@ -837,6 +838,7 @@ static void rt_cache_invalidate(struct net *net)
=20
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
+	redirect_genid++;
 }
=20
 /*
@@ -1391,8 +1393,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr,=
 __be32 new_gw,
=20
 				peer =3D rt->peer;
 				if (peer) {
-					if (peer->redirect_learned.a4 !=3D new_gw) {
+					if (peer->redirect_learned.a4 !=3D new_gw ||
+					    peer->redirect_genid !=3D redirect_genid) {
 						peer->redirect_learned.a4 =3D new_gw;
+						peer->redirect_genid =3D redirect_genid;
 						atomic_inc(&__rt_peer_genid);
 					}
 					check_peer_redir(&rt->dst, peer);
@@ -1701,6 +1705,8 @@ static struct dst_entry *ipv4_dst_check(struct ds=
t_entry *dst, u32 cookie)
 		if (peer) {
 			check_peer_pmtu(dst, peer);
=20
+			if (peer->redirect_genid !=3D redirect_genid)
+				peer->redirect_learned.a4 =3D 0;
 			if (peer->redirect_learned.a4 &&
 			    peer->redirect_learned.a4 !=3D rt->rt_gateway) {
 				if (check_peer_redir(dst, peer))
@@ -1852,6 +1858,8 @@ static void rt_init_metrics(struct rtable *rt, co=
nst struct flowi4 *fl4,
 		dst_init_metrics(&rt->dst, peer->metrics, false);
=20
 		check_peer_pmtu(&rt->dst, peer);
+		if (peer->redirect_genid !=3D redirect_genid)
+			peer->redirect_learned.a4 =3D 0;
 		if (peer->redirect_learned.a4 &&
 		    peer->redirect_learned.a4 !=3D rt->rt_gateway) {
 			rt->rt_gateway =3D peer->redirect_learned.a4;
