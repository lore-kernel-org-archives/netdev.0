From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/8] ethoc: prevent overflow of rx counter
Date: Wed, 24 Nov 2010 18:34:27 +0100
Message-ID: <1290620067.3464.80.camel@edumazet-laptop>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	 <1290606058-26703-5-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:65090 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab0KXRec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 12:34:32 -0500
Received: by gwj20 with SMTP id 20so934515gwj.19
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 09:34:31 -0800 (PST)
In-Reply-To: <1290606058-26703-5-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 novembre 2010 =C3=A0 14:40 +0100, Jonas Bonn a =C3=A9cri=
t :
> Rewind cur_rx to prevent it from overflowing.
>=20
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
> ---
>  drivers/net/ethoc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
> index 53c03f2..7d1b5d8 100644
> --- a/drivers/net/ethoc.c
> +++ b/drivers/net/ethoc.c
> @@ -408,6 +408,9 @@ static int ethoc_rx(struct net_device *dev, int l=
imit)
>  	struct ethoc *priv =3D netdev_priv(dev);
>  	int count;
> =20
> +	/* Prevent overflow of priv->cur_rx by rewinding it */=09
> +	priv->cur_rx =3D priv->cur_rx % priv->num_rx;
> +
>  	for (count =3D 0; count < limit; ++count) {
>  		unsigned int entry;
>  		struct ethoc_bd bd;


Hmm... please try following code instead (no divides)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index c5a2fe0..591b698 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -413,7 +413,7 @@ static int ethoc_rx(struct net_device *dev, int lim=
it)
 		unsigned int entry;
 		struct ethoc_bd bd;
=20
-		entry =3D priv->num_tx + (priv->cur_rx % priv->num_rx);
+		entry =3D priv->num_tx + priv->cur_rx;
 		ethoc_read_bd(priv, entry, &bd);
 		if (bd.stat & RX_BD_EMPTY)
 			break;
@@ -446,7 +446,8 @@ static int ethoc_rx(struct net_device *dev, int lim=
it)
 		bd.stat &=3D ~RX_BD_STATS;
 		bd.stat |=3D  RX_BD_EMPTY;
 		ethoc_write_bd(priv, entry, &bd);
-		priv->cur_rx++;
+		if (++priv->cur_rx =3D=3D priv->num_rx)
+			priv->cur_rx =3D 0;
 	}
=20
 	return count;


