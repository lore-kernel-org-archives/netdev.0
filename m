From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 09:18:25 -0700
Message-ID: <20070330091825.c0b57081.akpm@linux-foundation.org>
References: <20070329230917.63c3f79c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Ilpo =?ISO-8859-1?B?SuRydmluZW4i?= <ilpo.jarvinen@helsinki.fi>"@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39413 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753856AbXC3QSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 12:18:49 -0400
In-Reply-To: <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Mar 2007 17:33:28 +0300 (EEST) "Ilpo J=E4rvinen" <ilpo.jarvi=
nen@helsinki.fi> wrote:

> On Thu, 29 Mar 2007, Andrew Morton wrote:
>=20
> > Full -mm lineup.  The x86_64 box was acting as a distcc server at t=
he time.
> >=20
> > Nothing hit the logs, I'm afraid. But almost all the info is in=20
> > http://userweb.kernel.org/~akpm/s5000494.jpg
> >
> > <pokes around in gdb a bit>
> >=20
> > It died in tcp_update_scoreboard_fack() here:
> >=20
> >                 if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
> >                     after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
> >                         /* RFC: should we have find_below? */
> >                         skb =3D tcp_write_queue_find(sk, tp->high_s=
eq);
> >                         not_marked_skb =3D skb;
> >                         skb =3D tcp_write_queue_prev(sk, skb);
> >                         /* Timedout top is again uncertain? */
> >                         if (tcp_skb_timedout(sk, skb))
> >                                 timedout_continue =3D 1;
> >                 }
> >=20
> >=20
> > (gdb) l *0xffffffff8048ded8
> > 0xffffffff8048ded8 is in tcp_update_scoreboard_fack (include/net/tc=
p.h:1197).
> > 1192            return skb->next;
> > 1193    }
> > 1194   =20
> > 1195    static inline struct sk_buff *tcp_write_queue_prev(struct s=
ock *sk, struct sk_buff *skb)
> > 1196    {
> > 1197            return skb->prev;
> > 1198    }
> > 1199   =20
> > 1200    #define tcp_for_write_queue(skb, sk)                       =
            \
> >=20
> > (gdb) x/10i 0xffffffff8048ded8
> > 0xffffffff8048ded8 <tcp_update_scoreboard_fack+528>:    mov    0x8(=
%rdx),%r12
> >=20
> > So if that "CR2: 0000000000000008" is the access address then it ap=
pears that
> > `skb' is NULL.  tcp_write_queue_find() didn't find nuthin.
>=20
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

Well, could I suggest that you prepare a patch which adds lots of debug=
ging
checks in that area?  I can apply it and will rerun the same workload.

