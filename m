From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/2] net: davinci_cpdma: reduce time holding chan->lock in
 cpdma_chan_submit
Date: Wed, 27 Jul 2016 17:08:37 +0300
Message-ID: <31cab303-4712-63e5-3dd5-7cffeb3edb0f@ti.com>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
 <66d886a4-4852-096c-a3b3-3faec3eb167f@ti.com>
 <20160727071228.GH5368@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kernel@pengutronix.de>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:46277 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755903AbcG0OIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 10:08:50 -0400
In-Reply-To: <20160727071228.GH5368@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2016 10:12 AM, Uwe Kleine-K=F6nig wrote:
> Hello,
>=20
> On Tue, Jul 26, 2016 at 05:25:58PM +0300, Grygorii Strashko wrote:
>> On 07/26/2016 03:02 PM, Uwe Kleine-K=F6nig wrote:
>>> Allocating and preparing a dma descriptor doesn't need to happen un=
der
>>> the channel's lock. So do this before taking the channel's lock. Th=
e only
>>> down side is that the dma descriptor might be allocated even though=
 the
>>> channel is about to be stopped. This is unlikely though.
>>>
>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>> ---
>>>  drivers/net/ethernet/ti/davinci_cpdma.c | 38 +++++++++++++++++----=
------------
>>>  1 file changed, 20 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/=
ethernet/ti/davinci_cpdma.c
>>> index 5ffa04a306c6..ba3462707ae3 100644
>>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>>> @@ -542,24 +542,10 @@ int cpdma_chan_submit(struct cpdma_chan *chan=
, void *token, void *data,
>>>  	u32				mode;
>>>  	int				ret =3D 0;
>>> =20
>>> -	spin_lock_irqsave(&chan->lock, flags);
>>> -
>>> -	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
>>> -		ret =3D -EINVAL;
>>> -		goto unlock_ret;
>>> -	}
>>> -
>>> -	if (chan->count >=3D chan->desc_num)	{
>>> -		chan->stats.desc_alloc_fail++;
>>> -		ret =3D -ENOMEM;
>>> -		goto unlock_ret;
>>> -	}
>>
>> I'm not sure this is right thing to do. This check is expected to be=
 strict
>> and means "channel has exhausted the available descriptors, so furth=
er descs allocation does not allowed".
>=20
> I developed this patch basing on a 4.4 kernel which doesn't have
> 742fb20fd4c7 ("net: ethernet: ti: cpdma: switch to use genalloc"). Th=
ere
> my patch is more obviously correct. As currently chan->count is
> protected by chan->lock we must hold the lock for this check. If a
> failing check means we must not call cpdma_desc_alloc in the first
> place, that's bad.

Yes. That's intention of this check :(
Now it'll work as following for two (rx/tx) channels, as example
RX desc_num =3D 16 (max allowed number of descriptors)
TX desc_num =3D 16 (max allowed number of descriptors)
and with current code number of allocated descriptors will never exceed=
 16.

with your change, in corner case when TX channel's already utilized 16 =
descriptors the
following will happen:
cpdma_chan_submit()
 - cpdma_desc_alloc() -  will allocate 17th desc
 - lock
 - check for chan->count - fail
 - unlock
 - cpdma_desc_free()=20

so your patch will add additional desc_alloc/desc_free in the above cor=
ner case
and that's what i'm worry about (TEARDOWN seems ok) especially taking i=
nto account
further multi-queue feature development.

Above corner case seems might happen very rare, because of the guard ch=
eck in cpsw_ndo_start_xmit(),=20
but it could.

>=20
> But I'm not sure this is the case here. After all cpdma_desc_alloc
> doesn't do anything relevant for the hardware, right?

Right.

Thanks. I'd try to do some measurement also.
--=20
regards,
-grygorii
