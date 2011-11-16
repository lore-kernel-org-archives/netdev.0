From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 07/10] forcedeth: implement
 ndo_get_stats64() API
Date: Wed, 16 Nov 2011 21:32:33 +0100
Message-ID: <1321475553.3274.3.camel@edumazet-laptop>
References: <cover.1321420513.git.david.decotigny@google.com>
	 <dcc1ec263220b7bb1f7271933c30a8f89c19d991.1321420513.git.david.decotigny@google.com>
	 <20111116085533.0982001e@s6510.linuxnetplumber.net>
	 <1321463694.2709.1.camel@bwh-desktop>
	 <CAG88wWa7UsPSfX_NdNDkQeuWN0LYYDVckShgDj9GvMq2mtrpbQ@mail.gmail.com>
	 <1321471967.2709.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Decotigny <david.decotigny@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321471967.2709.14.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 novembre 2011 =C3=A0 19:32 +0000, Ben Hutchings a =C3=A9=
crit :
> On Wed, 2011-11-16 at 11:25 -0800, David Decotigny wrote:
> > Thanks for your feedback on these concerns.
> >=20
> > On Wed, Nov 16, 2011 at 9:14 AM, Ben Hutchings
> > <bhutchings@solarflare.com> wrote:
> > > On Wed, 2011-11-16 at 08:55 -0800, Stephen Hemminger wrote:
> > >> Or realize that the Tx side is single threaded by dev->xmit_lock=
 already
> > >> and the Rx side is single threaded by NAPI.
> > >
> > > Right.
> >=20
> > Yes, that's what I meant by "Each software stat field is updated by
> > one single writer." in a previous email. However, I think that TX a=
nd
> > RX paths are not always synchronized. So I'm afraid that if I'm usi=
ng
> > a single seqcount, I might run into trouble in the absence of a loc=
k
> > around each update.... and I'd really prefer to avoid such a lock. =
Are
> > you suggesting I should use 2 independent seqcounts? One for RX pat=
h,
> > the other for TX path, all this without a lock around writers?
>=20
> Yes, there should be 1 for each path.

David, drivers/net/ethernet/marvell/sky2.c contains code like that
(different syncpfor rx/tx)

TX path:
                        u64_stats_update_begin(&sky2->tx_stats.syncp);
                        ++sky2->tx_stats.packets;
                        sky2->tx_stats.bytes +=3D skb->len;
                        u64_stats_update_end(&sky2->tx_stats.syncp);


RX path:

        u64_stats_update_begin(&sky2->rx_stats.syncp);
        sky2->rx_stats.packets +=3D packets;
        sky2->rx_stats.bytes +=3D bytes;
        u64_stats_update_end(&sky2->rx_stats.syncp);
