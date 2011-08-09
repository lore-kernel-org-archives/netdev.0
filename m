From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] be2net: fixes
Date: Tue, 09 Aug 2011 18:23:07 +0200
Message-ID: <1312906987.2371.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
	 <1312904848.2371.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50788 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab1HIQXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 12:23:10 -0400
Received: by wwf5 with SMTP id 5so155607wwf.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 09:23:08 -0700 (PDT)
In-Reply-To: <1312904848.2371.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 17:47 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le mercredi 03 ao=C3=BBt 2011 =C3=A0 11:27 +0530, Sathya Perla a =C3=A9=
crit :
>=20
> > Pls apply.
> >=20
> > Sathya Perla (6):
> >   be2net: remove wrong and unnecessary calls to netif_carrier_off()
> >   be2net: no need to query link status
> >   be2net: non-member vlan pkts not received in promiscous mode
> >   be2net: use RX_FILTER cmd to program multicast addresses
> >   be2net: add support for flashing Teranetics PHY firmware
> >   be2net: drop pkts that do not belong to the port
> >=20
> >  drivers/net/benet/be.h         |    8 ++-
> >  drivers/net/benet/be_cmds.c    |  140 +++++++++++++---------------=
--------
> >  drivers/net/benet/be_cmds.h    |   38 ++++------
> >  drivers/net/benet/be_ethtool.c |   32 ++-------
> >  drivers/net/benet/be_hw.h      |   21 ++++--
> >  drivers/net/benet/be_main.c    |  155 ++++++++++++++++++++++++----=
------------
> >  6 files changed, 185 insertions(+), 209 deletions(-)
> >=20
>=20
> Not sure which recent be2net patch is problematic on 32bit arches :
>=20
> Kernel: arch/x86/boot/bzImage is ready  (#280)
>   Building modules, stage 2.
>   MODPOST 1854 modules
> ERROR: "__udivdi3" [drivers/net/benet/be2net.ko] undefined!
> make[1]: *** [__modpost] Erreur 1
> make: *** [modules] Erreur 2
>=20
> Please fix this, thanks.
>=20
>=20

Comes from commit ac124ff973e27802797
(be2net: cleanup and refactor stats code)

be_rx_eqd_update() now performs u64 divides.

=46ollowing patch should be enough, there is no way packet count can
overwrap a long anyway between two samples...



[PATCH] benet: fix build error on 32bit arch

Error comes from commit ac124ff973e27802797
(be2net: cleanup and refactor stats code)

ERROR: "__udivdi3" [drivers/net/benet/be2net.ko] undefined!

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1a3acca..7c98d8e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -936,7 +936,7 @@ static void be_rx_eqd_update(struct be_adapter *ada=
pter, struct be_rx_obj *rxo)
 		pkts =3D stats->rx_pkts;
 	} while (u64_stats_fetch_retry_bh(&stats->sync, start));
=20
-	stats->rx_pps =3D (pkts - stats->rx_pkts_prev) / (delta / HZ);
+	stats->rx_pps =3D (unsigned long)(pkts - stats->rx_pkts_prev) / (delt=
a / HZ);
 	stats->rx_pkts_prev =3D pkts;
 	stats->rx_jiffies =3D now;
 	eqd =3D stats->rx_pps / 110000;


