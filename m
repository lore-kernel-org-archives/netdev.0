From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv4 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Thu, 5 May 2011 08:59:28 +0200
Message-ID: <BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
References: <1304471935-402-3-git-send-email-maheshb@google.com> <1304559247-16111-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:33350 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab1EEG7s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 02:59:48 -0400
Received: by qyg14 with SMTP id 14so1377058qyg.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 23:59:48 -0700 (PDT)
In-Reply-To: <1304559247-16111-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/5 Mahesh Bandewar <maheshb@google.com>:
> This patch adds tg3_set_features() to handle loopback mode. Currently=
 the
> capability is added for the devices which support internal MAC loopba=
ck mode.
> So when enabled, it enables internal-MAC loopback.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> Changes since v3:
> =C2=A0(a) Corrected the condition (|| =3D> &&) where loopback capabil=
ity is added.
> =C2=A0(b) set_features() always returns 0.
> =C2=A0(c) Clear the loopback bit in ndo_open callback to avoid discre=
pancy.
>
> Changes since v2:
> =C2=A0Implemtned Joe Perches's style change.
>
> Changes since v1:
> =C2=A0Implemented Matt Carlson's suggestions.
> =C2=A0(a) Enable this capability on the devices which are capable of =
MAC-loopback
> =C2=A0 =C2=A0 =C2=A0mode.
> =C2=A0(b) check if the device is running before making changes.
> =C2=A0(c) check bits before making changes.
>
> =C2=A0drivers/net/tg3.c | =C2=A0 69 +++++++++++++++++++++++++++++++++=
++++++++++++++++++++
> =C2=A01 files changed, 69 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 7c7c9a8..7f7a290 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6309,6 +6309,44 @@ dma_error:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NETDEV_TX_OK;
> =C2=A0}
>
> +static int tg3_set_loopback(struct net_device *dev, u32 features)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tg3 *tp =3D netdev_priv(dev);
> + =C2=A0 =C2=A0 =C2=A0 u32 cur_mode =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int retval =3D 0;

void? You always return zero and don't check it in callers.

[...]
> @@ -9485,6 +9533,15 @@ static int tg3_open(struct net_device *dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_tx_start_all_queues(dev);
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Reset loopback feature if it was turne=
d on while the device was down
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to avoid and any discrepancy in featur=
es reporting.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (dev->features & NETIF_F_LOOPBACK) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features &=3D=
 ~NETIF_F_LOOPBACK;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->wanted_featur=
es &=3D ~NETIF_F_LOOPBACK;
> + =C2=A0 =C2=A0 =C2=A0 }
> +

if (dev->features & NETIF_F_LOOPBACK)
  tg3_set_loopback(dev, dev->features);

Whatever you do, don't modify wanted_features in drivers.

BTW, similar problems (also like in previous versions) are in
forcedeth implementation.

Best Regards,
Micha=C5=82 Miros=C5=82aw
