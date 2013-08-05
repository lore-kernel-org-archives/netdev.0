From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCHv3] bridge: disable snooping if there is no querier
Date: Mon, 05 Aug 2013 10:41:06 +0200
Message-ID: <1375692066.25148.14.camel@x61.thuisdomein>
References: <20130730.161035.1646022729333223847.davem@davemloft.net>
	 <1375311980-25575-1-git-send-email-linus.luessing@web.de>
	 <20130731.174037.1794753574143053874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linus.luessing@web.de, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	amwang@redhat.com, linux@baker-net.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130731.174037.1794753574143053874.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 17:40 -0700, David Miller wrote:
> > If there is no querier on a link then we won't get periodic reports=
 and
> > therefore won't be able to learn about multicast listeners behind p=
orts,
> > potentially leading to lost multicast packets, especially for multi=
cast
> > listeners that joined before the creation of the bridge.
> >=20
> > These lost multicast packets can appear since c5c23260594
> > ("bridge: Add multicast_querier toggle and disable queries by defau=
lt")
> > in particular.
> >=20
> > With this patch we are flooding multicast packets if our querier is
> > disabled and if we didn't detect any other querier.
> >=20
> > A grace period of the Maximum Response Delay of the querier is adde=
d to
> > give multicast responses enough time to arrive and to be learned fr=
om
> > before disabling the flooding behaviour again.
> >=20
> > Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
>=20
> Looks good, applied, thanks Linus.

0) This patch is part of v3.11-rc4 as commit b00589af3b0. It introduced
a GCC warning:
    net/bridge/br_multicast.c: In function =E2=80=98br_multicast_rcv=E2=
=80=99:
    net/bridge/br_multicast.c:1081:36: warning: =E2=80=98max_delay=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
    net/bridge/br_multicast.c:1178:16: note: =E2=80=98max_delay=E2=80=99=
 was declared here

1) Summarized, the code reads:

        unsigned long max_delay;

        if (skb->len =3D=3D sizeof(*mld))
                max_delay =3D msecs_to_jiffies(ntohs(mld->mld_maxdelay)=
);
        else if (skb->len >=3D sizeof(*mld2q))
                max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q-=
>mld2q_mrc)) : 1;

        br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->sad=
dr),
                                    max_delay);
=20
So GCC notices that max_delay is still uninitialized if skb->len is
neither equal to sizeof(*mld) nor equal or bigger than sizeof(*mld2q).
To me it looks GCC is right here. At least, it is not obvious that
max_delay will actually not be used in br_multicast_query_received() if
it still is uninitialized.

2) I'm entirely unfamiliar to this code. So I can't say how this warnin=
g
might be silenced.


Paul Bolle
