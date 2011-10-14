From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 10:05:09 +0200
Message-ID: <1318579509.2533.110.camel@edumazet-laptop>
References: <1318576791.2533.99.camel@edumazet-laptop>
	 <20111014.034224.1197576516015404466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60417 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1JNIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 04:05:16 -0400
Received: by wwn22 with SMTP id 22so403628wwn.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 01:05:14 -0700 (PDT)
In-Reply-To: <20111014.034224.1197576516015404466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 03:42 -0400, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 14 Oct 2011 09:19:51 +0200
>=20
> > Many drivers allocates big skb to store a single TCP frame.
> > (WIFI drivers, or NIC using PAGE_SIZE fragments)
> >=20
> > Its now common to get skb->truesize bigger than 4096 to store a ~15=
00
> > bytes TCP frame.
> >=20
> > TCP sessions with large RTT and packet losses can fill their Out Of
> > Order queue with such oversized skbs, and hit their sk_rcvbuf limit=
,
> > starting a pruning of complete OFO queue, without giving chance to
> > receive the missing packet(s) and moving skbs from OFO to receive q=
ueue.
> >=20
> > This patch adds skb_reduce_truesize() helper, and uses it for all s=
kbs
> > queued into OFO queue.
> >=20
> > Spending some time to perform a copy is worth the pain, since it pe=
rmits
> > SACK processing to have a chance to complete over the RTT barrier.
> >=20
> > This greatly improves user experience, without added cost on fast p=
ath.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> No objection from me, although I wish wireless drivers were able to
> size their SKBs more appropriately.  I wonder how many problems that
> look like "OMG we gotz da Buffer Bloat, arrr!" are actually due to
> this truesize issue.
>=20
> I think such large truesize SKBs will cause problems even in non loss
> situations, in that the receive buffer will hit it's limits more
> quickly.  I not sure that the receive buffer autotuning is built to
> handle this sort of scenerio as a common occurance.
>=20
> You might want to check if this is the actual root cause of your
> problems.  If the receive buffer autotuning doesn't expand the receiv=
e
> buffer enough to hold two windows worth of these large truesize SKBs,
> that's the real reason why we end up pruning.
>=20
> We have to decide if these kinds of SKBs are acceptable as a normal
> situation for MSS sized frames.  And if they are then it's probably
> a good idea to adjust the receive buffer autotuning code too.
>=20
> Although I realize it might be difficult, getting rid of these weird
> SKBs in the first place would be ideal.
>=20
> It would also be a good idea to put the truesize inaccuracies into
> perspective when selecting how to fix this.  It's trying to prevent
> 1 byte packets not accounting for the 256 byte SKB and metadata.
> That kind of case with such a high ratio of wastage is important.
>=20
> On the other hand, using 2048 bytes for a 1500 byte packet and claimi=
ng
> the truesize is 1500 + sizeof(metadata)... that might be an acceptabl=
e
> lie to tell :-)  This is especially true if it allows an easy solutio=
n
> to this wireless problem.
>=20
> Just some thoughts...  and I wonder if the wireless thing is due to
> some hardware limitation or similar.
>=20

This patch specifically addresses the OFO problem, trying to lower
memory usage for machines handling lot of sockets (proxies for example)

=46or the general case, I believe we have to tune/change
tcp_win_from_space() to take into account general tendancy to get fat
skbs.

sysctl_tcp_adv_win_scale is not fine enough today, and default value (2=
)
gives too much collapses. It's also a very complex setting, I am pretty
sure nobody knows how to use it.

tcp_win_from_space(int space) -> 75% of space  [ default ]

Only current kernels choices are to set it to one/-1 :

tcp_win_from_space(int space) -> 50% of space

or -2 :

tcp_win_from_space(int space) -> 25% of space
