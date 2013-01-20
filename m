From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/net/wireless: need consider the not '\0' terminated
 string.
Date: Sun, 20 Jan 2013 15:21:20 +0800
Message-ID: <50FB9AF0.2090200@asianux.com>
References: <50EBAF8F.7030704@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:55781 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab3ATHUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 02:20:33 -0500
In-Reply-To: <50EBAF8F.7030704@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello John W. Linville:

  when you have free time, could you give a glance for this patch ?

  thanks.

gchen.


=D3=DA 2013=C4=EA01=D4=C208=C8=D5 13:33, Chen Gang =D0=B4=B5=C0:
>=20
>   in ray_cs.c:
>     the a_current_ess_id is "Null terminated unless ESSID_SIZE long"
>     so we need buffer it with '\0' firstly, before using strlen or %s=
=2E
>=20
>   additional information:
>     in drivers/net/wireless/rayctl.h:
>       "NULL terminated unless 32 long" is a comment at line 616, 664
>       ESSID_SIZE is 32, at line 190
>     in include/uapi/linux/wireless.h:
>       IW_ESSID_MAX_SIZE is also 32
>     in drivers/net/wireless/ray_cs.c:
>       use strncpy for it, without '\0' terminated, at line 639
>       use memcpy for it, assume not '\0' terminated in line 1092..109=
7
>       buffer it with '\0' firstly, before using %s, in line 2576, 259=
8..2600
>=20
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  drivers/net/wireless/ray_cs.c |   19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray=
_cs.c
> index 598ca1c..e7cf37f 100644
> --- a/drivers/net/wireless/ray_cs.c
> +++ b/drivers/net/wireless/ray_cs.c
> @@ -1107,12 +1107,15 @@ static int ray_get_essid(struct net_device *d=
ev, struct iw_request_info *info,
>  			 union iwreq_data *wrqu, char *extra)
>  {
>  	ray_dev_t *local =3D netdev_priv(dev);
> +	UCHAR tmp[IW_ESSID_MAX_SIZE + 1];
> =20
>  	/* Get the essid that was set */
>  	memcpy(extra, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
> +	memcpy(tmp, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
> +	tmp[IW_ESSID_MAX_SIZE] =3D '\0';
> =20
>  	/* Push it out ! */
> -	wrqu->essid.length =3D strlen(extra);
> +	wrqu->essid.length =3D strlen(tmp);
>  	wrqu->essid.flags =3D 1;	/* active */
> =20
>  	return 0;
> @@ -1842,6 +1845,8 @@ static irqreturn_t ray_interrupt(int irq, void =
*dev_id)
>  	UCHAR tmp;
>  	UCHAR cmd;
>  	UCHAR status;
> +	UCHAR memtmp[ESSID_SIZE + 1];
> +
> =20
>  	if (dev =3D=3D NULL)	/* Note that we want interrupts with dev->star=
t =3D=3D 0 */
>  		return IRQ_NONE;
> @@ -1901,17 +1906,21 @@ static irqreturn_t ray_interrupt(int irq, voi=
d *dev_id)
>  			break;
>  		case CCS_START_NETWORK:
>  		case CCS_JOIN_NETWORK:
> +			memcpy(memtmp, local->sparm.b4.a_current_ess_id,
> +								ESSID_SIZE);
> +			memtmp[ESSID_SIZE] =3D '\0';
> +
>  			if (status =3D=3D CCS_COMMAND_COMPLETE) {
>  				if (readb
>  				    (&pccs->var.start_network.net_initiated) =3D=3D
>  				    1) {
>  					dev_dbg(&link->dev,
>  					      "ray_cs interrupt network \"%s\" started\n",
> -					      local->sparm.b4.a_current_ess_id);
> +					      memtmp);
>  				} else {
>  					dev_dbg(&link->dev,
>  					      "ray_cs interrupt network \"%s\" joined\n",
> -					      local->sparm.b4.a_current_ess_id);
> +					      memtmp);
>  				}
>  				memcpy_fromio(&local->bss_id,
>  					      pccs->var.start_network.bssid,
> @@ -1939,12 +1948,12 @@ static irqreturn_t ray_interrupt(int irq, voi=
d *dev_id)
>  				if (status =3D=3D CCS_START_NETWORK) {
>  					dev_dbg(&link->dev,
>  					      "ray_cs interrupt network \"%s\" start failed\n",
> -					      local->sparm.b4.a_current_ess_id);
> +					      memtmp);
>  					local->timer.function =3D start_net;
>  				} else {
>  					dev_dbg(&link->dev,
>  					      "ray_cs interrupt network \"%s\" join failed\n",
> -					      local->sparm.b4.a_current_ess_id);
> +					      memtmp);
>  					local->timer.function =3D join_net;
>  				}
>  				add_timer(&local->timer);
>=20


--=20
Chen Gang

Asianux Corporation
