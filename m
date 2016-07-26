From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/2] net: davinci_cpdma: reduce time holding chan->lock in
 cpdma_chan_submit
Date: Tue, 26 Jul 2016 17:25:58 +0300
Message-ID: <66d886a4-4852-096c-a3b3-3faec3eb167f@ti.com>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:51993 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703AbcGZO0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 10:26:10 -0400
In-Reply-To: <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2016 03:02 PM, Uwe Kleine-K=C3=B6nig wrote:
> Allocating and preparing a dma descriptor doesn't need to happen unde=
r
> the channel's lock. So do this before taking the channel's lock. The =
only
> down side is that the dma descriptor might be allocated even though t=
he
> channel is about to be stopped. This is unlikely though.
>=20
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> ---
>  drivers/net/ethernet/ti/davinci_cpdma.c | 38 +++++++++++++++++------=
----------
>  1 file changed, 20 insertions(+), 18 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/et=
hernet/ti/davinci_cpdma.c
> index 5ffa04a306c6..ba3462707ae3 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -542,24 +542,10 @@ int cpdma_chan_submit(struct cpdma_chan *chan, =
void *token, void *data,
>  	u32				mode;
>  	int				ret =3D 0;
> =20
> -	spin_lock_irqsave(&chan->lock, flags);
> -
> -	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
> -		ret =3D -EINVAL;
> -		goto unlock_ret;
> -	}
> -
> -	if (chan->count >=3D chan->desc_num)	{
> -		chan->stats.desc_alloc_fail++;
> -		ret =3D -ENOMEM;
> -		goto unlock_ret;
> -	}

I'm not sure this is right thing to do. This check is expected to be st=
rict
and means "channel has exhausted the available descriptors, so further =
descs allocation does not allowed".


This also might affect on Ivan's work [1] "[PATCH 0/4]  net: ethernet: =
ti: cpsw: add multi-queue support"



[1] https://lkml.org/lkml/2016/6/30/603
--=20
regards,
-grygorii
