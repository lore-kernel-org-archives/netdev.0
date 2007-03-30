From: David Miller <davem@davemloft.net>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 14:43:47 -0700 (PDT)
Message-ID: <20070330.144347.68157619.davem@davemloft.net>
References: <20070329230917.63c3f79c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753981AbXC3Vv1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 17:51:27 -0400
In-Reply-To: <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 30 Mar 2007 17:33:28 +0300 (EEST)

> If there is nothing at high_seq (application hasn't given any data to=
/past=20
> that point), the search fails to find any skb and returns NULL... But=
 I=20
> have no idea how this can happen? As TCP does after(skb->seq,=20
> tp->high_seq) (even in the quoted code block) guaranteeing that somet=
hing=20
> is there after the high_seq for TCP to step temporarily on... So at l=
east=20
> one skb should have it's end_seq after tp->high_seq (actually there=20
> should be at least two valid skbs after tp->high_seq since the used=20
> sequence number space does not have holes), which should be enough to=
 get=20
> an existing skb from write_queue_find?!
>=20
> I also checked all call paths to tcp_update_scoreboard_fack to make s=
ure=20
> that snd_una hasn't gone past high_seq and found nothing suspicious (=
and=20
> that wouldn't return NULL anyway I think)...

Let's not speculate, let's find out for sure if snd_una is
surpassing high_seq while we're in this state.

Andrew please give this debugging patch a spin, and also what
is your workload?  I'd like to play with it too.

I've tried to code this patch so that if the bug triggers your
machine shouldn't crash and burn completely, just spit out the
log message.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 97b9be2..605b5a8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1936,14 +1936,32 @@ static void tcp_update_scoreboard_fack(struct s=
ock *sk, u32 entry_seq,
=20
 		if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
 		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+			if (after(tp->snd_una, tp->high_seq)) {
+				printk(KERN_ALERT "TCP BUG: snd_una>high_seq "
+				       "[%08x:%08x]\n",
+				       tp->snd_una, tp->high_seq);
+				goto skip;
+			}
 			/* RFC: should we have find_below? */
 			skb =3D tcp_write_queue_find(sk, tp->high_seq);
+			if (!skb) {
+				struct sk_buff *head =3D tcp_write_queue_head(sk);
+				struct sk_buff *tail =3D tcp_write_queue_tail(sk);
+				printk(KERN_ALERT "TCP BUG: high_seq=3D=3DNULL "
+				       "[%08x] q[%08x] t[%08x]\n",
+				       tp->high_seq,
+				       TCP_SKB_CB(head)->seq,
+				       TCP_SKB_CB(tail)->end_seq);
+				goto skip;
+				      =20
+			}
 			not_marked_skb =3D skb;
 			skb =3D tcp_write_queue_prev(sk, skb);
 			/* Timedout top is again uncertain? */
 			if (tcp_skb_timedout(sk, skb))
 				timedout_continue =3D 1;
 		}
+skip:
 		/* RFC: ...else if (!tcp_skb_timedout) do skb fragmentation? */
=20
 		/* Phase II: Marker */
