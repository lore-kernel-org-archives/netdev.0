From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv4 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Thu, 5 May 2011 16:16:14 -0700
Message-ID: <BANLkTi=UxTgBU0ZEJ2PMAef1NzvJGqT_ZA@mail.gmail.com>
References: <1304471935-402-3-git-send-email-maheshb@google.com>
	<1304559247-16111-1-git-send-email-maheshb@google.com>
	<BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
	<BANLkTin88L+YBrpdaHR57CSx3dg2dMF7Yg@mail.gmail.com>
	<BANLkTikJ67YLGzR-3rjazkUgmffMxp1nJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:52992 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab1EEXQS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 19:16:18 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p45NGG5T016561
	for <netdev@vger.kernel.org>; Thu, 5 May 2011 16:16:16 -0700
Received: from bwz10 (bwz10.prod.google.com [10.188.26.10])
	by hpaq7.eem.corp.google.com with ESMTP id p45NFxFi011937
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 5 May 2011 16:16:15 -0700
Received: by bwz10 with SMTP id 10so2545836bwz.38
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 16:16:15 -0700 (PDT)
In-Reply-To: <BANLkTikJ67YLGzR-3rjazkUgmffMxp1nJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2011 at 11:35 AM, Micha=B3 Miros=B3aw <mirqus@gmail.com>=
 wrote:
> W dniu 5 maja 2011 19:47 u=BFytkownik Mahesh Bandewar
> <maheshb@google.com> napisa=B3:
>> On Wed, May 4, 2011 at 11:59 PM, Micha=B3 Miros=B3aw <mirqus@gmail.c=
om> wrote:
>>> 2011/5/5 Mahesh Bandewar <maheshb@google.com>:
>>>> This patch adds tg3_set_features() to handle loopback mode. Curren=
tly the
>>>> capability is added for the devices which support internal MAC loo=
pback mode.
>>>> So when enabled, it enables internal-MAC loopback.
> [...]
>>>> @@ -9485,6 +9533,15 @@ static int tg3_open(struct net_device *dev)
>>>>
>>>> =A0 =A0 =A0 =A0netif_tx_start_all_queues(dev);
>>>>
>>>> + =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0* Reset loopback feature if it was turned on whil=
e the device was down
>>>> + =A0 =A0 =A0 =A0* to avoid and any discrepancy in features report=
ing.
>>>> + =A0 =A0 =A0 =A0*/
>>>> + =A0 =A0 =A0 if (dev->features & NETIF_F_LOOPBACK) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features &=3D ~NETIF_F_LOOPBACK=
;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->wanted_features &=3D ~NETIF_F_L=
OOPBACK;
>>>> + =A0 =A0 =A0 }
>>>> +
>>>
>>> if (dev->features & NETIF_F_LOOPBACK)
>>> =A0tg3_set_loopback(dev, dev->features);
>>>
>> Unfortunately at this stage device will not be able to set-loopback =
so
>> I resorted to clearing the bit(s).
>
> ndo_fix_features+ndo_set_features might be caled before ndo_open - th=
e
> first might be just from register_netdev() so even before ndo_open
> callback.
>
ndo_open is the triggering event, so anything before that point does
not really help.

>>> Whatever you do, don't modify wanted_features in drivers.
>> Since just clearing the 'features' would leave wanted_features in
>> discrepant state, I thought this will bring it to a sane state. So
>> what is a preferred way?
>
> If you really can't do other way, driver should keep additional state
> that is checked in ndo_fix_features callback.
>
ndo_fix_features callback is called just before calling
ndo_set_features callback. Also this is called during update_features,
so having the state maintained is not really going to help in this
scenario since that is not happening when device reaches ready state
(to remove this discrepancy in the feature-set).

There must be a reason (that you did not explain!) why driver code
should not alter wanted_feature set. So in this scenario, just leaving
the wanted_features as it is and clearing the features bit is correct
/ enough?


>>> BTW, similar problems (also like in previous versions) are in
>>> forcedeth implementation.
>> Yes, whatever we decide about the state of the wanted_features, I'll
>> implement similarly for forcedeth. Which previous problem you are
>> referring to? Is it the return value? There is a different kind of
>> failure (error while writing the register). Since update_features()
>> cant handle return value, I'm ignoring the return value. As far as t=
he
>> correct return code is concerned, I wasn't sure what is appropriate
>> return code here (may be PHY_ERROR would be appropriate there) but
>> again I could ignore it just the way rest of the code is ignoring.
>
> Let's wait for this threads points to be resolved. You will probably
> change the forcedeth's implementation then anyway. :-)
>
agreed.

Thanks,
--mahesh..
> Best Regards,
> Micha=B3 Miros=B3aw
>
