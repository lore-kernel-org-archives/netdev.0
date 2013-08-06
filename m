From: Dave Jones <davej@redhat.com>
Subject: Re: bridge: disable snooping if there is no querier
Date: Tue, 6 Aug 2013 11:18:57 -0400
Message-ID: <20130806151857.GA25528@redhat.com>
References: <20130804005227.D17B3660D03@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab3HFPTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 11:19:07 -0400
Content-Disposition: inline
In-Reply-To: <20130804005227.D17B3660D03@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 04, 2013 at 12:52:27AM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Db00589af3b04=
736376f24625ab0b394642e89e29
 > Commit:     b00589af3b04736376f24625ab0b394642e89e29
 > Parent:     cf3c4c03060b688cbc389ebc5065ebcce5653e96
 > Author:     Linus L=FCssing <linus.luessing@web.de>
 > AuthorDate: Thu Aug 1 01:06:20 2013 +0200
 > Committer:  David S. Miller <davem@davemloft.net>
 > CommitDate: Wed Jul 31 17:40:21 2013 -0700
 >=20
 >     bridge: disable snooping if there is no querier
 >    =20
 >     Signed-off-by: Linus L=FCssing <linus.luessing@web.de>
 >     Signed-off-by: David S. Miller <davem@davemloft.net>
=20
 > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
 > @@ -1198,6 +1206,9 @@ static int br_ip6_multicast_query(struct net_b=
ridge *br,
 >  		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc=
)) : 1;
 >  	}
 > =20
 > +	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr)=
,
 > +				    max_delay);
 > +
 >  	if (!group)
 >  		goto out;

This addition looks suspect. max_delay looks like it could be uninitial=
ised here.

1178         unsigned long max_delay;

=2E..

1189         if (skb->len =3D=3D sizeof(*mld)) {
1190                 if (!pskb_may_pull(skb, sizeof(*mld))) {
1191                         err =3D -EINVAL;
1192                         goto out;
1193                 }
1194                 mld =3D (struct mld_msg *) icmp6_hdr(skb);
1195                 max_delay =3D msecs_to_jiffies(ntohs(mld->mld_maxd=
elay));
1196                 if (max_delay)
1197                         group =3D &mld->mld_mca;
1198         } else if (skb->len >=3D sizeof(*mld2q)) {
1199                 if (!pskb_may_pull(skb, sizeof(*mld2q))) {
1200                         err =3D -EINVAL;
1201                         goto out;
1202                 }
1203                 mld2q =3D (struct mld2_query *)icmp6_hdr(skb);
1204                 if (!mld2q->mld2q_nsrcs)
1205                         group =3D &mld2q->mld2q_mca;
1206                 max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(m=
ld2q->mld2q_mrc)) : 1;
1207         }
1208=20
1209         br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h=
->saddr),
1210                                     max_delay);

If skb_len matches neither of those conditions, we don't set it.

Explicitly set it to something on entry ? Or is there validation furthe=
r up the
callchain that skb_len will only ever be one of these two values ?

	Dave
