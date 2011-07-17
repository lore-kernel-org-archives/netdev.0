From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sun, 17 Jul 2011 23:06:57 +0200
Message-ID: <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion> <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42976 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab1GQVHS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 17:07:18 -0400
Received: by qwk3 with SMTP id 3so1246529qwk.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 14:07:17 -0700 (PDT)
In-Reply-To: <20110717194421.GA2153@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 17 lipca 2011 21:44 u=BFytkownik Jiri Pirko <jpirko@redhat.com> =
napisa=B3:
> Sun, Jul 17, 2011 at 10:36:04AM CEST, mirqus@gmail.com wrote:
>>W dniu 17 lipca 2011 09:30 u=BFytkownik Jiri Pirko <jpirko@redhat.com=
> napisa=B3:
>>> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>>>> Some devices are not able to enable/disable rx/tw vlan accel sepa=
rately.
>>>>> they depend on ndo_vlan_rx_register to know if to enable of disab=
le
>>>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>>>> this must be resolved.
>>>>>
>>>>> One solution might be to enable accel on device start every time,=
 even
>>>>> if there are no vlan up on. But this would change behaviour and m=
ight
>>>>> lead to possible regression (on older devices).
>>>>[...]
>>>>
>>>>Please describe the possible regression. As I see it, there won't b=
e
>>>>any user visible change of behaviour - network code takes care of
>>>>reinserting VLAN tag when necessary. If you think that disabling ta=
g
>>>>stripping is beneficial for cases where no VLANs are configured, it=
's
>>>>better to do that in netdev_fix_features() for devices which advert=
ise
>>>>NETIF_F_HW_VLAN_RX in hw_features.
>>>
>>> Well I just wanted to preserve current behaviour which is that in m=
any
>>> drivers vlan accel is enabled only if some vid is registered upon t=
he
>>> device and it's disabled again when no vid is registered. I can see
>>> no way to do this with current code after removing ndo_vlan_rx_regi=
ster.
>>>
>>> I expect unexpected
>>
>>:-D
>>
>>> ... problems on old cards when vlan accel would be
>>> enabled all the time, but maybe I'm wrong...
>>
>>Device has no way of knowing how the system uses VLAN tags, stripped
>>or not. Any problems would be driver problems and since you're making
>>it all use generic code, bugs will hit all drivers simultaneously or
>>(preferably) won't happen at all.
>>
>>> One idea is for device which do not support sepatate rx/tx vlan acc=
el
>>> enabling/disabling they can probably use ndo_fix_features force to
>>> enable/disable rx/tx pair together. That would resolve the situatio=
n as
>>> well giving user possibility to turn off vlan accel in case of any =
issues.
>>
>>That is exactly the idea behind ndo_fix_features.

> In netdev_fix_features add check if either one of NETIF_F_HW_VLAN_TX =
or
> NETIF_F_HW_VLAN_RX is set and in that case set the other one. Of cour=
se
> this would be done only for devices what do not support separate rx/t=
x
> vlan on/off. But how to distinguish? NETIF_F_HW_VLAN_BOTH feature fla=
g?

Not in netdev_fix_features(). This case you describe should be handled
in driver-specific
ndo_fix_features callback. Because if NETIF_F_HW_VLAN_TX is disabled,
the network core will insert the tag anyway, this would cover the
restriction:

if (!(features & NEITF_F_HW_VLAN_RX))
  features &=3D ~NETIF_F_HW_VLAN_TX;

This works, because if HW_VLAN_TX is disabled, the driver never gets
packets which need tag insertion. Besides those already in the queue,
of course.

=46or netdev_fix_features() I thought that if no VLANs are configured, =
then it
could disable NETIF_F_HW_VLAN_RX (if set in hw_features). The
conditions for disabling it need some thought. For example, if the
device is not slave to some stacking device (bonding doesn't count, as
it passes VLAN registeration to its slaves) then packets with tags
would be either dropped or have tag reinserted (for network taps).

Best Regards,
Micha=B3 Miros=B3aw
