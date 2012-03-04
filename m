From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sun, 04 Mar 2012 07:56:50 -0800
Message-ID: <1330876610.2730.23.camel@edumazet-laptop>
References: <1330167065.2462.53.camel@edumazet-laptop>
	 <CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42338 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab2CDP4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 10:56:53 -0500
Received: by pbcun15 with SMTP id un15so1887760pbc.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 07:56:52 -0800 (PST)
In-Reply-To: <CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 mars 2012 =C3=A0 13:19 +0200, Or Gerlitz a =C3=A9crit :
> > +       ethh =3D (struct ethhdr *)skb->data;
> > +       tx_desc->ctrl.srcrb_flags16[0] =3D get_unaligned((u16 *)eth=
h->h_dest);
> > +       tx_desc->ctrl.imm =3D get_unaligned((u32 *)(ethh->h_dest + =
2));
>=20
> Hi Eric,
>=20
> commit 622121719934f60378279eb440d3cec2fc3176d2 of your triggers the
> below sparse
> warnings, could you advise what would be the correct way to fix that =
out?
>=20
> Or.
>=20
>  CHECK   drivers/net/ethernet/mellanox/mlx4/en_tx.c
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40: warning: incorrect
> type in assignment (different base types)
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40:    expected
> restricted __be16 <noident>
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40:    got unsigned
> short [unsigned] <noident>
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27: warning: incorrect
> type in assignment (different base types)
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27:    expected
> restricted __be32 [usertype] imm
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27:    got unsigned in=
t
> [unsigned] <noident>

Oh yes, I forgot about sparse, sorry.
By the way you have existing problems about ctrl_flags

drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1013:34: warning: invali=
d assignment: |=3D
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1013:34:    left side ha=
s type unsigned int
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1013:34:    right side h=
as type restricted __be32
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1015:34: warning: invali=
d assignment: &=3D
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1015:34:    left side ha=
s type unsigned int
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1015:34:    right side h=
as type restricted __be32
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1069:26: warning: incorr=
ect type in assignment (different base types)
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1069:26:    expected uns=
igned int [unsigned] [usertype] ctrl_flags
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1069:26:    got restrict=
ed __be32 [usertype] <noident>


Probably something like this is needed, but you also need to take a loo=
k
at the ctrl_flags problem.

I have to run, will submit official patch at the end of the (sunny)day,
if you dont beat me ;)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/e=
thernet/mellanox/mlx4/en_tx.c
index 2fd5140..50b3fa5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -686,8 +686,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struc=
t net_device *dev)
=20
 	/* Copy dst mac address to wqe */
 	ethh =3D (struct ethhdr *)skb->data;
-	tx_desc->ctrl.srcrb_flags16[0] =3D get_unaligned((u16 *)ethh->h_dest)=
;
-	tx_desc->ctrl.imm =3D get_unaligned((u32 *)(ethh->h_dest + 2));
+	tx_desc->ctrl.srcrb_flags16[0] =3D get_unaligned((__be16 *)ethh->h_de=
st);
+	tx_desc->ctrl.imm =3D get_unaligned((__be32 *)(ethh->h_dest + 2));
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
