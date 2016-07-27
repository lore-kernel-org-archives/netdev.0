From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 2/2] net: davinci_cpdma: reduce time holding chan->lock
 in cpdma_chan_submit
Date: Wed, 27 Jul 2016 09:12:28 +0200
Message-ID: <20160727071228.GH5368@pengutronix.de>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
 <66d886a4-4852-096c-a3b3-3faec3eb167f@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:36989 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbcG0HMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 03:12:33 -0400
Content-Disposition: inline
In-Reply-To: <66d886a4-4852-096c-a3b3-3faec3eb167f@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Jul 26, 2016 at 05:25:58PM +0300, Grygorii Strashko wrote:
> On 07/26/2016 03:02 PM, Uwe Kleine-K=F6nig wrote:
> > Allocating and preparing a dma descriptor doesn't need to happen un=
der
> > the channel's lock. So do this before taking the channel's lock. Th=
e only
> > down side is that the dma descriptor might be allocated even though=
 the
> > channel is about to be stopped. This is unlikely though.
> >=20
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> > ---
> >  drivers/net/ethernet/ti/davinci_cpdma.c | 38 +++++++++++++++++----=
------------
> >  1 file changed, 20 insertions(+), 18 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/=
ethernet/ti/davinci_cpdma.c
> > index 5ffa04a306c6..ba3462707ae3 100644
> > --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> > +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> > @@ -542,24 +542,10 @@ int cpdma_chan_submit(struct cpdma_chan *chan=
, void *token, void *data,
> >  	u32				mode;
> >  	int				ret =3D 0;
> > =20
> > -	spin_lock_irqsave(&chan->lock, flags);
> > -
> > -	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
> > -		ret =3D -EINVAL;
> > -		goto unlock_ret;
> > -	}
> > -
> > -	if (chan->count >=3D chan->desc_num)	{
> > -		chan->stats.desc_alloc_fail++;
> > -		ret =3D -ENOMEM;
> > -		goto unlock_ret;
> > -	}
>=20
> I'm not sure this is right thing to do. This check is expected to be =
strict
> and means "channel has exhausted the available descriptors, so furthe=
r descs allocation does not allowed".

I developed this patch basing on a 4.4 kernel which doesn't have
742fb20fd4c7 ("net: ethernet: ti: cpdma: switch to use genalloc"). Ther=
e
my patch is more obviously correct. As currently chan->count is
protected by chan->lock we must hold the lock for this check. If a
failing check means we must not call cpdma_desc_alloc in the first
place, that's bad.

But I'm not sure this is the case here. After all cpdma_desc_alloc
doesn't do anything relevant for the hardware, right?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
