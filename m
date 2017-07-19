From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next 3/8] netvsc: change order of steps in setting
 queues
Date: Wed, 19 Jul 2017 19:06:08 +0000
Message-ID: <MWHPR21MB0479BE1317BC37659BAE913CCAA60@MWHPR21MB0479.namprd21.prod.outlook.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
 <20170719185319.25871-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        KY Srinivasan <kys@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0101.outbound.protection.outlook.com ([104.47.38.101]:2400
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754209AbdGSTGL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 15:06:11 -0400
In-Reply-To: <20170719185319.25871-4-sthemmin@microsoft.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, July 19, 2017 2:53 PM
> To: KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; Stephen Hemminger <sthemmin@microsoft.com>
> Cc: devel@linuxdriverproject.org; netdev@vger.kernel.org
> Subject: [PATCH net-next 3/8] netvsc: change order of steps in setting
> queues
>=20
> This fixes the error unwind logic for incorrect number of queues.
> If netif_set_real_num_XX_queues failed then rndis_filter_device_add
> would have been called twice. Since input arguments are already
> ranged checked this is a hypothetical only problem, not possible
> in actual code.
>=20
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> index e8e82a6a4b1a..91637336d1fb 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -724,17 +724,15 @@ static int netvsc_set_queues(struct net_device
> *net, struct hv_device *dev,
>  	device_info.ring_size =3D ring_size;
>  	device_info.max_num_vrss_chns =3D num_chn;
>=20
> -	ret =3D rndis_filter_device_add(dev, &device_info);
> -	if (ret)
> -		return ret;
> -
>  	ret =3D netif_set_real_num_tx_queues(net, num_chn);
>  	if (ret)
>  		return ret;
>=20
>  	ret =3D netif_set_real_num_rx_queues(net, num_chn);
> +	if (ret)
> +		return ret;
>=20
> -	return ret;
> +	return rndis_filter_device_add(dev, &device_info);
>  }

The existing code has a bug here. After rndis_filter_device_add(),
the number of queues granted by the host may change:
        net_device->num_chn =3D 1 +
                init_packet->msg.v5_msg.subchn_comp.num_subchannels;
So we should call rndis_filter_device_add() first, then
assign net_device->num_chn to "real number tx queues".

Thanks,
- Haiyang
