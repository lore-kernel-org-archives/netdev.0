From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 2/2] net: davinci_cpdma: reduce time holding chan->lock in
 cpdma_chan_submit
Date: Wed, 27 Jul 2016 21:11:36 +0300
Message-ID: <8d736b86-bfd2-6757-8b83-1a1662ccf83f@linaro.org>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
 <66d886a4-4852-096c-a3b3-3faec3eb167f@ti.com>
 <20160727071228.GH5368@pengutronix.de>
 <31cab303-4712-63e5-3dd5-7cffeb3edb0f@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35279 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776AbcG0SLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 14:11:40 -0400
Received: by mail-lf0-f42.google.com with SMTP id f93so33114759lfi.2
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 11:11:39 -0700 (PDT)
In-Reply-To: <31cab303-4712-63e5-3dd5-7cffeb3edb0f@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 27.07.16 17:08, Grygorii Strashko wrote:
> On 07/27/2016 10:12 AM, Uwe Kleine-K=F6nig wrote:
>> Hello,
>>
>> On Tue, Jul 26, 2016 at 05:25:58PM +0300, Grygorii Strashko wrote:
>>> On 07/26/2016 03:02 PM, Uwe Kleine-K=F6nig wrote:
>>>> Allocating and preparing a dma descriptor doesn't need to happen u=
nder
>>>> the channel's lock. So do this before taking the channel's lock. T=
he only
>>>> down side is that the dma descriptor might be allocated even thoug=
h the
>>>> channel is about to be stopped. This is unlikely though.
>>>>
>>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>>> ---
>>>>  drivers/net/ethernet/ti/davinci_cpdma.c | 38 +++++++++++++++++---=
-------------
>>>>  1 file changed, 20 insertions(+), 18 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net=
/ethernet/ti/davinci_cpdma.c
>>>> index 5ffa04a306c6..ba3462707ae3 100644
>>>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>>>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>>>> @@ -542,24 +542,10 @@ int cpdma_chan_submit(struct cpdma_chan *cha=
n, void *token, void *data,
>>>>  	u32				mode;
>>>>  	int				ret =3D 0;
>>>>
>>>> -	spin_lock_irqsave(&chan->lock, flags);
>>>> -
>>>> -	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
>>>> -		ret =3D -EINVAL;
>>>> -		goto unlock_ret;
>>>> -	}
>>>> -
>>>> -	if (chan->count >=3D chan->desc_num)	{
>>>> -		chan->stats.desc_alloc_fail++;
>>>> -		ret =3D -ENOMEM;
>>>> -		goto unlock_ret;
>>>> -	}
>>>
>>> I'm not sure this is right thing to do. This check is expected to b=
e strict
>>> and means "channel has exhausted the available descriptors, so furt=
her descs allocation does not allowed".
>>
>> I developed this patch basing on a 4.4 kernel which doesn't have
>> 742fb20fd4c7 ("net: ethernet: ti: cpdma: switch to use genalloc"). T=
here
>> my patch is more obviously correct. As currently chan->count is
>> protected by chan->lock we must hold the lock for this check. If a
>> failing check means we must not call cpdma_desc_alloc in the first
>> place, that's bad.
The chan->count is not only case where this lock is needed unfortunatel=
y.
I like the idea to remove a bunch of locks from here (I was wondering w=
hy it needs to have
so much locks when using h/w queues, but this is the style driver is wr=
itten though)
This lock is also needed to cover stats counters at least.
In case of cpsw driver, that uses cpdam_chan, the same channel can be s=
hared
between two emacs (in dual emac mode) then the lock is needed for every=
 chan var.
So that's not rare case. In general, the optimization of cpdma is good =
idea,
but seems it can require much more changes.

>
> Yes. That's intention of this check :(
> Now it'll work as following for two (rx/tx) channels, as example
> RX desc_num =3D 16 (max allowed number of descriptors)
> TX desc_num =3D 16 (max allowed number of descriptors)
> and with current code number of allocated descriptors will never exce=
ed 16.
>
> with your change, in corner case when TX channel's already utilized 1=
6 descriptors the
> following will happen:
> cpdma_chan_submit()
>  - cpdma_desc_alloc() -  will allocate 17th desc
>  - lock
>  - check for chan->count - fail
>  - unlock
>  - cpdma_desc_free()
>
> so your patch will add additional desc_alloc/desc_free in the above c=
orner case
> and that's what i'm worry about (TEARDOWN seems ok) especially taking=
 into account
> further multi-queue feature development.
>
> Above corner case seems might happen very rare, because of the guard =
check in cpsw_ndo_start_xmit(),
> but it could.
>
>>
>> But I'm not sure this is the case here. After all cpdma_desc_alloc
>> doesn't do anything relevant for the hardware, right?
>
> Right.
>
> Thanks. I'd try to do some measurement also.
>

--=20
Regards,
Ivan Khoronzhuk
