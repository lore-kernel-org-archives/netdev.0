From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv4 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Fri, 6 May 2011 08:35:07 +0200
Message-ID: <BANLkTimYK-qpjnVAsW7H78-RrkmcpXPeCw@mail.gmail.com>
References: <1304471935-402-3-git-send-email-maheshb@google.com>
 <1304559247-16111-1-git-send-email-maheshb@google.com> <BANLkTi=1Nw6A8cMNyVGnASOA_VF018ooxA@mail.gmail.com>
 <BANLkTin88L+YBrpdaHR57CSx3dg2dMF7Yg@mail.gmail.com> <BANLkTikJ67YLGzR-3rjazkUgmffMxp1nJQ@mail.gmail.com>
 <BANLkTi=UxTgBU0ZEJ2PMAef1NzvJGqT_ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49626 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284Ab1EFGf2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 02:35:28 -0400
Received: by qwk3 with SMTP id 3so2012311qwk.19
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 23:35:28 -0700 (PDT)
In-Reply-To: <BANLkTi=UxTgBU0ZEJ2PMAef1NzvJGqT_ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 6 maja 2011 01:16 u=BFytkownik Mahesh Bandewar
<maheshb@google.com> napisa=B3:
> On Thu, May 5, 2011 at 11:35 AM, Micha=B3 Miros=B3aw <mirqus@gmail.co=
m> wrote:
>> W dniu 5 maja 2011 19:47 u=BFytkownik Mahesh Bandewar
>> <maheshb@google.com> napisa=B3:
>>> On Wed, May 4, 2011 at 11:59 PM, Micha=B3 Miros=B3aw <mirqus@gmail.=
com> wrote:
>>>> 2011/5/5 Mahesh Bandewar <maheshb@google.com>:
>>>>> This patch adds tg3_set_features() to handle loopback mode. Curre=
ntly the
>>>>> capability is added for the devices which support internal MAC lo=
opback mode.
>>>>> So when enabled, it enables internal-MAC loopback.
>> [...]
>>>>> @@ -9485,6 +9533,15 @@ static int tg3_open(struct net_device *dev=
)
>>>>>
>>>>> =A0 =A0 =A0 =A0netif_tx_start_all_queues(dev);
>>>>>
>>>>> + =A0 =A0 =A0 /*
>>>>> + =A0 =A0 =A0 =A0* Reset loopback feature if it was turned on whi=
le the device was down
>>>>> + =A0 =A0 =A0 =A0* to avoid and any discrepancy in features repor=
ting.
>>>>> + =A0 =A0 =A0 =A0*/
>>>>> + =A0 =A0 =A0 if (dev->features & NETIF_F_LOOPBACK) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features &=3D ~NETIF_F_LOOPBAC=
K;
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->wanted_features &=3D ~NETIF_F_=
LOOPBACK;
>>>>> + =A0 =A0 =A0 }
>>>>> +
>>>>
>>>> if (dev->features & NETIF_F_LOOPBACK)
>>>> =A0tg3_set_loopback(dev, dev->features);
>>>>
>>> Unfortunately at this stage device will not be able to set-loopback=
 so
>>> I resorted to clearing the bit(s).
>> ndo_fix_features+ndo_set_features might be caled before ndo_open - t=
he
>> first might be just from register_netdev() so even before ndo_open
>> callback.
> ndo_open is the triggering event, so anything before that point does
> not really help.

You're right - I forgot that netif_running() becomes true just before
ndo_open is called. I have a hard time to convince myself that you
can't program the hardware for loopback just at the end of ndo_open
callback.

>>>> Whatever you do, don't modify wanted_features in drivers.
>>> Since just clearing the 'features' would leave wanted_features in
>>> discrepant state, I thought this will bring it to a sane state. So
>>> what is a preferred way?
>> If you really can't do other way, driver should keep additional stat=
e
>> that is checked in ndo_fix_features callback.
> ndo_fix_features callback is called just before calling
> ndo_set_features callback. Also this is called during update_features=
,
> so having the state maintained is not really going to help in this
> scenario since that is not happening when device reaches ready state
> (to remove this discrepancy in the feature-set).

You can call netdev_update_features() at the end of ndo_open. But that
would be the same in the end as just enabling the loopback there.

> There must be a reason (that you did not explain!) why driver code
> should not alter wanted_feature set. So in this scenario, just leavin=
g
> the wanted_features as it is and clearing the features bit is correct
> / enough?

wanted_features reflects a set of features the user wants. I assume
that no code can change the user himself, so changing wanted_features
instead would break this connection. You can view wanted_features as a
cache of user's intention. ;-)

Best Regards,
Micha=B3 Miros=B3aw
