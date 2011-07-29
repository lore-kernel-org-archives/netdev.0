From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 17:11:46 +0200
Message-ID: <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C302.8050304@hippy.csoma.elte.hu>
	 <1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729.073910.59762029845942660.davem@davemloft.net>
	 <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C76B.5010700@hippy.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: synapse <synapse@hippy.csoma.elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50183 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab1G2PLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 11:11:49 -0400
Received: by wwe5 with SMTP id 5so3665860wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 08:11:48 -0700 (PDT)
In-Reply-To: <4E32C76B.5010700@hippy.csoma.elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 16:44 +0200, synapse a =C3=A9crit :
> On 07/29/11 16:41, Eric Dumazet wrote:
> > Le vendredi 29 juillet 2011 =C3=A0 07:39 -0700, David Miller a =C3=A9=
crit :
> >> From: Eric Dumazet<eric.dumazet@gmail.com>
> >> Date: Fri, 29 Jul 2011 16:36:24 +0200
> >>
> >>> Hmm, I'll take a look, but check_peer_redir() seems suspicious at=
 first
> >>> glance.
> >> I take full responsibility for any bugs you discover in it :-)
> >
> > ;)
> >
> > Bug origin is commit f39925dbde7788cfb96419c0f092b086aa325c0f
> > ipv4: Cache learned redirect information in inetpeer.
> >
> > I'll cook a patch ASAP
> >
> wow that was QUICK :)
>=20
> When you're done I'll check it ASAP
>=20
> Gergely Kalman

Thats tricky, because I am not sure we dont need RCU protection since w=
e
can now exchange dst neighbour on the fly.

=46ollowing patch would only reduce the window of bug, not a complete
fix...

David, any opinion on this ?


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1730689..6afc4eb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1628,16 +1628,18 @@ static int check_peer_redir(struct dst_entry *d=
st, struct inet_peer *peer)
 {
 	struct rtable *rt =3D (struct rtable *) dst;
 	__be32 orig_gw =3D rt->rt_gateway;
-	struct neighbour *n;
+	struct neighbour *n, *old_n;
=20
 	dst_confirm(&rt->dst);
=20
-	neigh_release(dst_get_neighbour(&rt->dst));
-	dst_set_neighbour(&rt->dst, NULL);
-
 	rt->rt_gateway =3D peer->redirect_learned.a4;
-	rt_bind_neighbour(rt);
-	n =3D dst_get_neighbour(&rt->dst);
+
+	n =3D ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	old_n =3D xchg(&rt->dst._neighbour, n);
+	if (old_n)
+		neigh_release(old_n);
 	if (!n || !(n->nud_state & NUD_VALID)) {
 		if (n)
 			neigh_event_send(n, NULL);


