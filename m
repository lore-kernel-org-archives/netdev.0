From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Tue, 19 Jul 2011 10:13:34 +0200
Message-ID: <20110719081332.GA2219@minipsycho>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion>
 <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho>
 <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
 <20110718071300.GA2244@minipsycho>
 <CAHXqBFKgZUuLFoe+U+2nT3NVBCaPfY13BsrK=Hxqsw7oiOZe3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab1GSINm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 04:13:42 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFKgZUuLFoe+U+2nT3NVBCaPfY13BsrK=Hxqsw7oiOZe3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 19, 2011 at 09:24:29AM CEST, mirqus@gmail.com wrote:
>W dniu 18 lipca 2011 09:13 u=C5=BCytkownik Jiri Pirko <jpirko@redhat.c=
om> napisa=C5=82:
>> Sun, Jul 17, 2011 at 11:06:57PM CEST, mirqus@gmail.com wrote:
>>>W dniu 17 lipca 2011 21:44 u=C5=BCytkownik Jiri Pirko <jpirko@redhat=
=2Ecom> napisa=C5=82:
>>>> Sun, Jul 17, 2011 at 10:36:04AM CEST, mirqus@gmail.com wrote:
>>>>>W dniu 17 lipca 2011 09:30 u=C5=BCytkownik Jiri Pirko <jpirko@redh=
at.com> napisa=C5=82:
>>>>>> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>>>>>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>>>>>>> Some devices are not able to enable/disable rx/tw vlan accel s=
eparately.
>>>>>>>> they depend on ndo_vlan_rx_register to know if to enable of di=
sable
>>>>>>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>>>>>>> this must be resolved.
>>>>>>>>
>>>>>>>> One solution might be to enable accel on device start every ti=
me, even
>>>>>>>> if there are no vlan up on. But this would change behaviour an=
d might
>>>>>>>> lead to possible regression (on older devices).
>>>>>>>[...]
>>>>>>>
>>>>>>>Please describe the possible regression. As I see it, there won'=
t be
>>>>>>>any user visible change of behaviour - network code takes care o=
f
>>>>>>>reinserting VLAN tag when necessary. If you think that disabling=
 tag
>>>>>>>stripping is beneficial for cases where no VLANs are configured,=
 it's
>>>>>>>better to do that in netdev_fix_features() for devices which adv=
ertise
>>>>>>>NETIF_F_HW_VLAN_RX in hw_features.
>>>>>>
>>>>>> Well I just wanted to preserve current behaviour which is that i=
n many
>>>>>> drivers vlan accel is enabled only if some vid is registered upo=
n the
>>>>>> device and it's disabled again when no vid is registered. I can =
see
>>>>>> no way to do this with current code after removing ndo_vlan_rx_r=
egister.
>>>>>>
>>>>>> I expect unexpected
>>>>>
>>>>>:-D
>>>>>
>>>>>> ... problems on old cards when vlan accel would be
>>>>>> enabled all the time, but maybe I'm wrong...
>>>>>
>>>>>Device has no way of knowing how the system uses VLAN tags, stripp=
ed
>>>>>or not. Any problems would be driver problems and since you're mak=
ing
>>>>>it all use generic code, bugs will hit all drivers simultaneously =
or
>>>>>(preferably) won't happen at all.
>>>>>
>>>>>> One idea is for device which do not support sepatate rx/tx vlan =
accel
>>>>>> enabling/disabling they can probably use ndo_fix_features force =
to
>>>>>> enable/disable rx/tx pair together. That would resolve the situa=
tion as
>>>>>> well giving user possibility to turn off vlan accel in case of a=
ny issues.
>>>>>
>>>>>That is exactly the idea behind ndo_fix_features.
>>>
>>>> In netdev_fix_features add check if either one of NETIF_F_HW_VLAN_=
TX or
>>>> NETIF_F_HW_VLAN_RX is set and in that case set the other one. Of c=
ourse
>>>> this would be done only for devices what do not support separate r=
x/tx
>>>> vlan on/off. But how to distinguish? NETIF_F_HW_VLAN_BOTH feature =
flag?
>>>
>>>Not in netdev_fix_features(). This case you describe should be handl=
ed
>>>in driver-specific
>>
>> Well since the code would be the same in many drivers I was thinking
>> about putting it in general code...
>>
>> Anyway, would you please look at following example patch and tell me=
 if
>> it looks good to you?
>
>[...]
>> =C2=A0static u32 atl1c_fix_features(struct net_device *netdev, u32 f=
eatures)
>> =C2=A0{
>> + =C2=A0 =C2=A0 =C2=A0 u32 changed =3D netdev->features ^ features;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Since there is no support for separat=
e rx/tx vlan accel
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* enable/disable make sure these are al=
ways set in pair.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 if ((changed & NETIF_F_HW_VLAN_TX && features=
 & NETIF_F_HW_VLAN_TX) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (changed & NETIF_F_HW_VLAN_RX &=
& features & NETIF_F_HW_VLAN_RX))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features |=3D NET=
IF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
>> + =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 features &=3D ~(N=
ETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
>> +
>
>You ignored my hint about combined TX/RX offload. Is that on purpose?

Sorry but I'm probably missing what you mean.

>Your code will toggle VLAN acceleration on every
>netdev_update_features call when user requests one offload on and one
>off.

Well for hw which cannot no/off rx/tx accel separately I thought that i=
f
user wants one accel on, the accel should be enabled. According to
following table (bits set when calling driver's fix_features):

 NETIF_F_HW_VLAN_TX  NETIF_F_HW_VLAN_RX -> enable
 NETIF_F_HW_VLAN_TX !NETIF_F_HW_VLAN_RX -> enable
!NETIF_F_HW_VLAN_TX  NETIF_F_HW_VLAN_RX -> enable
!NETIF_F_HW_VLAN_TX !NETIF_F_HW_VLAN_RX -> disable

This looks logical to me...

>
>BTW, the register flag name (MAC_CTRL_RMV_VLAN) suggests that it
>controls only tag stripping. Was it tested or documented that this
>also links with tag insertion?

comment says "/* enable VLAN tag insert/strip */" therefore it looks
like this register controls both.

>
>[...]
>> +static int atl1c_set_features(struct net_device *netdev, u32 featur=
es)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 u32 changed =3D netdev->features ^ features;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Test for NETIF_F_HW_VLAN_TX as it's p=
aired with NETIF_F_HW_VLAN_RX
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* by atl1c_fix_features.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 if (changed & NETIF_F_HW_VLAN_TX)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atl1c_vlan_mode(n=
etdev, features);
>> +
>
>Test for RX is better, as it will match the name of control bit
>(MAC_CTRL_RMV_VLAN).

Yeah, why not, I think this does not matter.

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
