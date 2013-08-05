From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCHv3] bridge: disable snooping if there is no
	querier
Date: Tue, 6 Aug 2013 00:40:59 +0200
Message-ID: <20130805224059.GG25436@Linus-Debian>
References: <20130730.161035.1646022729333223847.davem@davemloft.net>
	<1375311980-25575-1-git-send-email-linus.luessing@web.de>
	<20130731.174037.1794753574143053874.davem@davemloft.net>
	<1375692066.25148.14.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	linus.luessing@web.de, David Miller <davem@davemloft.net>,
	amwang@redhat.com
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1375692066.25148.14.camel@x61.thuisdomein>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Thanks for the very quick reporting! Looks like my gcc was and still
isn't as supportive... You and the lists should have received a patch
to fix that.

Cheers, Linus


On Mon, Aug 05, 2013 at 10:41:06AM +0200, Paul Bolle wrote:
> On Wed, 2013-07-31 at 17:40 -0700, David Miller wrote:
> > > If there is no querier on a link then we won't get periodic reports=
 and
> > > therefore won't be able to learn about multicast listeners behind p=
orts,
> > > potentially leading to lost multicast packets, especially for multi=
cast
> > > listeners that joined before the creation of the bridge.
> > >=20
> > > These lost multicast packets can appear since c5c23260594
> > > ("bridge: Add multicast_querier toggle and disable queries by defau=
lt")
> > > in particular.
> > >=20
> > > With this patch we are flooding multicast packets if our querier is
> > > disabled and if we didn't detect any other querier.
> > >=20
> > > A grace period of the Maximum Response Delay of the querier is adde=
d to
> > > give multicast responses enough time to arrive and to be learned fr=
om
> > > before disabling the flooding behaviour again.
> > >=20
> > > Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
> >=20
> > Looks good, applied, thanks Linus.
>=20
> 0) This patch is part of v3.11-rc4 as commit b00589af3b0. It introduced
> a GCC warning:
>     net/bridge/br_multicast.c: In function =E2=80=98br_multicast_rcv=E2=
=80=99:
>     net/bridge/br_multicast.c:1081:36: warning: =E2=80=98max_delay=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
>     net/bridge/br_multicast.c:1178:16: note: =E2=80=98max_delay=E2=80=99=
 was declared here
>=20
> 1) Summarized, the code reads:
>=20
>         unsigned long max_delay;
>=20
>         if (skb->len =3D=3D sizeof(*mld))
>                 max_delay =3D msecs_to_jiffies(ntohs(mld->mld_maxdelay)=
);
>         else if (skb->len >=3D sizeof(*mld2q))
>                 max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q-=
>mld2q_mrc)) : 1;
>=20
>         br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->sad=
dr),
>                                     max_delay);
> =20
> So GCC notices that max_delay is still uninitialized if skb->len is
> neither equal to sizeof(*mld) nor equal or bigger than sizeof(*mld2q).
> To me it looks GCC is right here. At least, it is not obvious that
> max_delay will actually not be used in br_multicast_query_received() if
> it still is uninitialized.
>=20
> 2) I'm entirely unfamiliar to this code. So I can't say how this warnin=
g
> might be silenced.
>=20
>=20
> Paul Bolle
>=20
