From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 1/5] sky2: force receive checksum when using RSS
 on some hardware (v2)
Date: Fri, 8 Jul 2011 10:45:33 +0200
Message-ID: <CAHXqBF+XfArvVDXQ+JBGQ1hEne=w7u6eFTf=SQciLr48BD7h8w@mail.gmail.com>
References: <20110707155056.939223264@vyatta.com>
	<20110707155212.000920741@vyatta.com>
	<CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
	<20110707101322.784409eb@nehalam.ftrdhcpuser.net>
	<20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53300 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab1GHIpe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 04:45:34 -0400
Received: by qwk3 with SMTP id 3so841744qwk.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 01:45:33 -0700 (PDT)
In-Reply-To: <20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/8 Stephen Hemminger <shemminger@vyatta.com>:
> Found when reviewing the vendor driver. Apparently some chip versions
> require receive checksumming to be enabled in order for RSS to work.
>
> Also, if fix_features has to change some settings; put in message
> in log in similar manner to netdev_fix_features.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> v2 - enforce the requirement in fix_features rather than set features
>
> --- a/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 13:56:03.575420273=
 -0700
> +++ b/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 14:03:17.775403938=
 -0700
[...]
> @@ -4176,8 +4180,18 @@ static u32 sky2_fix_features(struct net_
> =A0 =A0 =A0 =A0/* In order to do Jumbo packets on these chips, need t=
o turn off the
> =A0 =A0 =A0 =A0 * transmit store/forward. Therefore checksum offload =
won't work.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHIP_=
ID_YUKON_EC_U)
> + =A0 =A0 =A0 if (dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHIP_=
ID_YUKON_EC_U) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "checksum offload not =
possible with jumbo frames\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features &=3D ~(NETIF_F_TSO|NETIF_F_SG=
|NETIF_F_ALL_CSUM);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Some hardware requires receive checksum for RSS to w=
ork. */
> + =A0 =A0 =A0 if ( (features & NETIF_F_RXHASH) &&
> + =A0 =A0 =A0 =A0 =A0 =A0!(features & NETIF_F_RXCSUM) &&
> + =A0 =A0 =A0 =A0 =A0 =A0(sky2->hw->flags & SKY2_HW_RSS_CHKSUM)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "receive hashing force=
s receive checksum\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_RXCSUM;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0return features;
> =A0}

I suggest using netdev_dbg() instead of netdev_warn() so it won't spam
dmesg on every features update.

Otherwise, looks good.

Best Regards,
Micha=B3 Miros=B3aw
