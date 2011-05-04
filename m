From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.2, kernel panic, probably related to framentation
 handling
Date: Wed, 04 May 2011 22:02:26 +0200
Message-ID: <1304539346.32152.81.camel@edumazet-laptop>
References: <f2c5863250c7a5fb11a189759bd736cf@visp.net.lb>
	 <1304528581.32152.15.camel@edumazet-laptop>
	 <1304532674.32152.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45205 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab1EDUCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:02:30 -0400
Received: by wya21 with SMTP id 21so1119489wya.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 13:02:29 -0700 (PDT)
In-Reply-To: <1304532674.32152.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 mai 2011 =C3=A0 20:11 +0200, Eric Dumazet a =C3=A9crit :
> Le mercredi 04 mai 2011 =C3=A0 19:03 +0200, Eric Dumazet a =C3=A9crit=
 :
>=20
> > Hi Denys
> >=20
> > Is it reproductible, and possibly on latest kernel ?
> >=20
> > We fixed some bugs lately (assuming you also use a bridge ?)
> >=20
> > Could you send the disassembled code on your kernel of icmp_send() =
?
>=20
> Oh well, I think I found the problem, I am working on a patch and sen=
d
> it shortly.
>=20
> Thanks
>=20

I believe bug is one year old (2.6.35), please try following patch.

Thanks !

[PATCH] net: ip_expire() must revalidate route

Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
added a bug in IP defragmentation handling, in case timeout is fired.

When a frame is defragmented, we use last skb dst field when building
final skb. Its dst is valid, since we are in rcu read section.

But if a timeout occurs, we take first queued fragment to build one ICM=
P
TIME EXCEEDED message. Problem is all queued skb have weak dst pointers=
,
since we escaped RCU critical section after their queueing. icmp_send()
might dereference a now freed (and possibly reused) part of memory.

Calling skb_dst_drop() and ip_route_input_noref() to revalidate route i=
s
the only possible choice.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a1151b8..b1d282f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -223,31 +223,30 @@ static void ip_expire(unsigned long arg)
=20
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments !=3D NULL=
) {
 		struct sk_buff *head =3D qp->q.fragments;
+		const struct iphdr *iph;
+		int err;
=20
 		rcu_read_lock();
 		head->dev =3D dev_get_by_index_rcu(net, qp->iif);
 		if (!head->dev)
 			goto out_rcu_unlock;
=20
+		/* skb dst is stale, drop it, and perform route lookup again */
+		skb_dst_drop(head);
+		iph =3D ip_hdr(head);
+		err =3D ip_route_input_noref(head, iph->daddr, iph->saddr,
+					   iph->tos, head->dev);
+		if (err)
+			goto out_rcu_unlock;
+
 		/*
-		 * Only search router table for the head fragment,
-		 * when defraging timeout at PRE_ROUTING HOOK.
+		 * Only an end host needs to send an ICMP
+		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (qp->user =3D=3D IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
-			const struct iphdr *iph =3D ip_hdr(head);
-			int err =3D ip_route_input(head, iph->daddr, iph->saddr,
-						 iph->tos, head->dev);
-			if (unlikely(err))
-				goto out_rcu_unlock;
-
-			/*
-			 * Only an end host needs to send an ICMP
-			 * "Fragment Reassembly Timeout" message, per RFC792.
-			 */
-			if (skb_rtable(head)->rt_type !=3D RTN_LOCAL)
-				goto out_rcu_unlock;
+		if (qp->user =3D=3D IP_DEFRAG_CONNTRACK_IN &&
+		    skb_rtable(head)->rt_type !=3D RTN_LOCAL)
+			goto out_rcu_unlock;
=20
-		}
=20
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);


