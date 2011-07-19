From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Tue, 19 Jul 2011 09:24:29 +0200
Message-ID: <CAHXqBFKgZUuLFoe+U+2nT3NVBCaPfY13BsrK=Hxqsw7oiOZe3A@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion> <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho> <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
 <20110718071300.GA2244@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58597 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab1GSHYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 03:24:50 -0400
Received: by qwk3 with SMTP id 3so1854954qwk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 00:24:49 -0700 (PDT)
In-Reply-To: <20110718071300.GA2244@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 18 lipca 2011 09:13 u=BFytkownik Jiri Pirko <jpirko@redhat.com> =
napisa=B3:
> Sun, Jul 17, 2011 at 11:06:57PM CEST, mirqus@gmail.com wrote:
>>W dniu 17 lipca 2011 21:44 u=BFytkownik Jiri Pirko <jpirko@redhat.com=
> napisa=B3:
>>> Sun, Jul 17, 2011 at 10:36:04AM CEST, mirqus@gmail.com wrote:
>>>>W dniu 17 lipca 2011 09:30 u=BFytkownik Jiri Pirko <jpirko@redhat.c=
om> napisa=B3:
>>>>> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>>>>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>>>>>> Some devices are not able to enable/disable rx/tw vlan accel se=
parately.
>>>>>>> they depend on ndo_vlan_rx_register to know if to enable of dis=
able
>>>>>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>>>>>> this must be resolved.
>>>>>>>
>>>>>>> One solution might be to enable accel on device start every tim=
e, even
>>>>>>> if there are no vlan up on. But this would change behaviour and=
 might
>>>>>>> lead to possible regression (on older devices).
>>>>>>[...]
>>>>>>
>>>>>>Please describe the possible regression. As I see it, there won't=
 be
>>>>>>any user visible change of behaviour - network code takes care of
>>>>>>reinserting VLAN tag when necessary. If you think that disabling =
tag
>>>>>>stripping is beneficial for cases where no VLANs are configured, =
it's
>>>>>>better to do that in netdev_fix_features() for devices which adve=
rtise
>>>>>>NETIF_F_HW_VLAN_RX in hw_features.
>>>>>
>>>>> Well I just wanted to preserve current behaviour which is that in=
 many
>>>>> drivers vlan accel is enabled only if some vid is registered upon=
 the
>>>>> device and it's disabled again when no vid is registered. I can s=
ee
>>>>> no way to do this with current code after removing ndo_vlan_rx_re=
gister.
>>>>>
>>>>> I expect unexpected
>>>>
>>>>:-D
>>>>
>>>>> ... problems on old cards when vlan accel would be
>>>>> enabled all the time, but maybe I'm wrong...
>>>>
>>>>Device has no way of knowing how the system uses VLAN tags, strippe=
d
>>>>or not. Any problems would be driver problems and since you're maki=
ng
>>>>it all use generic code, bugs will hit all drivers simultaneously o=
r
>>>>(preferably) won't happen at all.
>>>>
>>>>> One idea is for device which do not support sepatate rx/tx vlan a=
ccel
>>>>> enabling/disabling they can probably use ndo_fix_features force t=
o
>>>>> enable/disable rx/tx pair together. That would resolve the situat=
ion as
>>>>> well giving user possibility to turn off vlan accel in case of an=
y issues.
>>>>
>>>>That is exactly the idea behind ndo_fix_features.
>>
>>> In netdev_fix_features add check if either one of NETIF_F_HW_VLAN_T=
X or
>>> NETIF_F_HW_VLAN_RX is set and in that case set the other one. Of co=
urse
>>> this would be done only for devices what do not support separate rx=
/tx
>>> vlan on/off. But how to distinguish? NETIF_F_HW_VLAN_BOTH feature f=
lag?
>>
>>Not in netdev_fix_features(). This case you describe should be handle=
d
>>in driver-specific
>
> Well since the code would be the same in many drivers I was thinking
> about putting it in general code...
>
> Anyway, would you please look at following example patch and tell me =
if
> it looks good to you?

[...]
> =A0static u32 atl1c_fix_features(struct net_device *netdev, u32 featu=
res)
> =A0{
> + =A0 =A0 =A0 u32 changed =3D netdev->features ^ features;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Since there is no support for separate rx/tx vlan =
accel
> + =A0 =A0 =A0 =A0* enable/disable make sure these are always set in p=
air.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((changed & NETIF_F_HW_VLAN_TX && features & NETIF_F=
_HW_VLAN_TX) ||
> + =A0 =A0 =A0 =A0 =A0 (changed & NETIF_F_HW_VLAN_RX && features & NET=
IF_F_HW_VLAN_RX))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_HW_VLAN_TX | NETI=
=46_F_HW_VLAN_RX;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features &=3D ~(NETIF_F_HW_VLAN_TX | NE=
TIF_F_HW_VLAN_RX);
> +

You ignored my hint about combined TX/RX offload. Is that on purpose?
Your code will toggle VLAN acceleration on every
netdev_update_features call when user requests one offload on and one
off.

BTW, the register flag name (MAC_CTRL_RMV_VLAN) suggests that it
controls only tag stripping. Was it tested or documented that this
also links with tag insertion?

[...]
> +static int atl1c_set_features(struct net_device *netdev, u32 feature=
s)
> +{
> + =A0 =A0 =A0 u32 changed =3D netdev->features ^ features;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Test for NETIF_F_HW_VLAN_TX as it's paired with NE=
TIF_F_HW_VLAN_RX
> + =A0 =A0 =A0 =A0* by atl1c_fix_features.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (changed & NETIF_F_HW_VLAN_TX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atl1c_vlan_mode(netdev, features);
> +

Test for RX is better, as it will match the name of control bit
(MAC_CTRL_RMV_VLAN).

Best Regards,
Micha=B3 Miros=B3aw
