From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Tue, 19 Jul 2011 10:24:58 +0200
Message-ID: <CAHXqBFKZ2Y+SgFLFaBD6rpHoVX30PMp1ECwxhie3AAUqjMZ6UQ@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion> <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho> <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
 <20110718071300.GA2244@minipsycho> <CAHXqBFKgZUuLFoe+U+2nT3NVBCaPfY13BsrK=Hxqsw7oiOZe3A@mail.gmail.com>
 <20110719081332.GA2219@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:37035 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1GSIZS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 04:25:18 -0400
Received: by qyk9 with SMTP id 9so2267667qyk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 01:25:18 -0700 (PDT)
In-Reply-To: <20110719081332.GA2219@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 19 lipca 2011 10:13 u=BFytkownik Jiri Pirko <jpirko@redhat.com> =
napisa=B3:
> Tue, Jul 19, 2011 at 09:24:29AM CEST, mirqus@gmail.com wrote:
>>W dniu 18 lipca 2011 09:13 u=BFytkownik Jiri Pirko <jpirko@redhat.com=
> napisa=B3:
>>> =A0static u32 atl1c_fix_features(struct net_device *netdev, u32 fea=
tures)
>>> =A0{
>>> + =A0 =A0 =A0 u32 changed =3D netdev->features ^ features;
>>> +
>>> + =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0* Since there is no support for separate rx/tx vla=
n accel
>>> + =A0 =A0 =A0 =A0* enable/disable make sure these are always set in=
 pair.
>>> + =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 if ((changed & NETIF_F_HW_VLAN_TX && features & NETIF=
_F_HW_VLAN_TX) ||
>>> + =A0 =A0 =A0 =A0 =A0 (changed & NETIF_F_HW_VLAN_RX && features & N=
ETIF_F_HW_VLAN_RX))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_HW_VLAN_TX | NE=
TIF_F_HW_VLAN_RX;
>>> + =A0 =A0 =A0 else
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features &=3D ~(NETIF_F_HW_VLAN_TX | =
NETIF_F_HW_VLAN_RX);
>>> +
>>
>>You ignored my hint about combined TX/RX offload. Is that on purpose?
> Sorry but I'm probably missing what you mean.

You could replace above code with:

if (!(features & NETIF_F_HW_VLAN_RX))
  features &=3D ~NETIF_F_HW_VLAN_TX;

>>Your code will toggle VLAN acceleration on every
>>netdev_update_features call when user requests one offload on and one
>>off.
>
> Well for hw which cannot no/off rx/tx accel separately I thought that=
 if
> user wants one accel on, the accel should be enabled. According to
> following table (bits set when calling driver's fix_features):
>
> =A0NETIF_F_HW_VLAN_TX =A0NETIF_F_HW_VLAN_RX -> enable
> =A0NETIF_F_HW_VLAN_TX !NETIF_F_HW_VLAN_RX -> enable
> !NETIF_F_HW_VLAN_TX =A0NETIF_F_HW_VLAN_RX -> enable
> !NETIF_F_HW_VLAN_TX !NETIF_F_HW_VLAN_RX -> disable
>
> This looks logical to me...

If user requests eg. +TX -RX, you will have ndo_fix_features called
with +TX -RX, possibly multiple times. This generates this sequence:

current features: -TX,-RX
  -> changed: TX -> return +TX,+RX
  -> set_features +TX,+TX
current_features: +TX,+RX
  -> changed: RX -> return -TX,-RX
  -> set_features -TX,-RX
=2E..

(And you cannot control when fix_features will be called.)

If you don't agree with the hint above (about forcing TX off when RX
is off, leaving the rest alone), then its better to remove TX from
hw_features and copy it's state from RX in ndo_fix_features. Like
this:

[init]
  netdev->hw_features |=3D NETIF_F_HW_VLAN_RX;
[fix_features]
  if (features & NETIF_F_HW_VLAN_RX)
    features |=3D NETIF_F_HW_VLAN_TX;
  else
    features &=3D ~NETIF_F_HW_VLAN_TX;

Best Regards,
Micha=B3 Miros=B3aw
