From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv4 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Thu, 5 May 2011 10:47:10 -0700
Message-ID: <BANLkTin88L+YBrpdaHR57CSx3dg2dMF7Yg@mail.gmail.com>
References: <1304471935-402-3-git-send-email-maheshb@google.com>
	<1304559247-16111-1-git-send-email-maheshb@google.com>
	<BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2330 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab1EERrN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:47:13 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p45HlCWp017647
	for <netdev@vger.kernel.org>; Thu, 5 May 2011 10:47:12 -0700
Received: from bwz5 (bwz5.prod.google.com [10.188.26.5])
	by kpbe18.cbf.corp.google.com with ESMTP id p45Hj70F024246
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 5 May 2011 10:47:11 -0700
Received: by bwz5 with SMTP id 5so3483131bwz.34
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 10:47:10 -0700 (PDT)
In-Reply-To: <BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2011 at 11:59 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2011/5/5 Mahesh Bandewar <maheshb@google.com>:
>> This patch adds tg3_set_features() to handle loopback mode. Currentl=
y the
>> capability is added for the devices which support internal MAC loopb=
ack mode.
>> So when enabled, it enables internal-MAC loopback.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> Changes since v3:
>> =C2=A0(a) Corrected the condition (|| =3D> &&) where loopback capabi=
lity is added.
>> =C2=A0(b) set_features() always returns 0.
>> =C2=A0(c) Clear the loopback bit in ndo_open callback to avoid discr=
epancy.
>>
>> Changes since v2:
>> =C2=A0Implemtned Joe Perches's style change.
>>
>> Changes since v1:
>> =C2=A0Implemented Matt Carlson's suggestions.
>> =C2=A0(a) Enable this capability on the devices which are capable of=
 MAC-loopback
>> =C2=A0 =C2=A0 =C2=A0mode.
>> =C2=A0(b) check if the device is running before making changes.
>> =C2=A0(c) check bits before making changes.
>>
>> =C2=A0drivers/net/tg3.c | =C2=A0 69 ++++++++++++++++++++++++++++++++=
+++++++++++++++++++++
>> =C2=A01 files changed, 69 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index 7c7c9a8..7f7a290 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -6309,6 +6309,44 @@ dma_error:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NETDEV_TX_OK;
>> =C2=A0}
>>
>> +static int tg3_set_loopback(struct net_device *dev, u32 features)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 struct tg3 *tp =3D netdev_priv(dev);
>> + =C2=A0 =C2=A0 =C2=A0 u32 cur_mode =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 int retval =3D 0;
>
> void? You always return zero and don't check it in callers.
>
> [...]
>> @@ -9485,6 +9533,15 @@ static int tg3_open(struct net_device *dev)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_tx_start_all_queues(dev);
>>
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Reset loopback feature if it was turn=
ed on while the device was down
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to avoid and any discrepancy in featu=
res reporting.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 if (dev->features & NETIF_F_LOOPBACK) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features &=3D=
 ~NETIF_F_LOOPBACK;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->wanted_featu=
res &=3D ~NETIF_F_LOOPBACK;
>> + =C2=A0 =C2=A0 =C2=A0 }
>> +
>
> if (dev->features & NETIF_F_LOOPBACK)
> =C2=A0tg3_set_loopback(dev, dev->features);
>
Unfortunately at this stage device will not be able to set-loopback so
I resorted to clearing the bit(s).

> Whatever you do, don't modify wanted_features in drivers.
>
Since just clearing the 'features' would leave wanted_features in
discrepant state, I thought this will bring it to a sane state. So
what is a preferred way?

> BTW, similar problems (also like in previous versions) are in
> forcedeth implementation.
Yes, whatever we decide about the state of the wanted_features, I'll
implement similarly for forcedeth. Which previous problem you are
referring to? Is it the return value? There is a different kind of
failure (error while writing the register). Since update_features()
cant handle return value, I'm ignoring the return value. As far as the
correct return code is concerned, I wasn't sure what is appropriate
return code here (may be PHY_ERROR would be appropriate there) but
again I could ignore it just the way rest of the code is ignoring.

>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
