From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: switchdev and VLAN ranges
Date: Mon, 12 Oct 2015 12:15:58 +0200
Message-ID: <561B885E.7070606@cumulusnetworks.com>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com>
 <5618EA2A.3020900@cumulusnetworks.com>
 <20151011071208.GA2188@nanopsycho.orion> <20151011224125.GB21128@ketchup.lan>
 <561AFB2C.2010603@cumulusnetworks.com>
 <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Jiri Pirko <jiri@resnulli.us>, Elad Raz <eladr@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32904 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbbJLKQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 06:16:01 -0400
Received: by wicge5 with SMTP id ge5so11347534wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 03:16:00 -0700 (PDT)
In-Reply-To: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2015 07:14 AM, Scott Feldman wrote:
> On Sun, Oct 11, 2015 at 5:13 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> On 10/12/2015 12:41 AM, Vivien Didelot wrote:
>>> On Oct. Sunday 11 (41) 09:12 AM, Jiri Pirko wrote:
>>>> Sat, Oct 10, 2015 at 12:36:26PM CEST, nikolay@cumulusnetworks.com =
wrote:
>>>>> On 10/10/2015 09:49 AM, Elad Raz wrote:
>>>>>>
>>>>>>> On Oct 10, 2015, at 2:30 AM, Vivien Didelot <vivien.didelot@sav=
oirfairelinux.com> wrote:
>>>>>>>
>>>>>>> I have two concerns in mind:
>>>>>>>
>>>>>>> a) if we imagine that drivers like Rocker allocate memory in th=
e prepare
>>>>>>> phase for each VID, preparing a range like 100-4000 would defin=
itely not
>>>>>>> be recommended.
>>>>>>>
>>>>>>> b) imagine that you have two Linux bridges on a switch, one usi=
ng the
>>>>>>> hardware VLAN 100. If you request the VLAN range 99-101 for the=
 other
>>>>>>> bridge members, it is not possible for the driver to say "I can
>>>>>>> accelerate VLAN 99 and 101, but not 100". It must return OPNOTS=
UPP for
>>>>>>> the whole range.
>>>>>>
>>>>>> Another concern I have with vid_being..vid_end range is the =E2=80=
=9Cflags=E2=80=9D. Where flags can be BRIDGE_VLAN_INFO_PVID.
>>>>>> There is no sense having more than one VLAN as a PVID.
>>>>>> This leave the HW vendor the choice which VLAN id they will use =
as the PVID.
>>>>>>
>>>>>
>>>>> iproute2 doesn't allow to do it but I can see that someone can ac=
tually make it
>>>>> so the flags for the range have it and it doesn't look correct. P=
erhaps we need
>>>>> something like the patch below to enforce this from kernel-side.
>>>>>
>>>>>
>>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>>>> index d78b4429505a..02b17b53e9a6 100644
>>>>> --- a/net/bridge/br_netlink.c
>>>>> +++ b/net/bridge/br_netlink.c
>>>>> @@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
>>>>>                     if (vinfo_start)
>>>>>                             return -EINVAL;
>>>>>                     vinfo_start =3D vinfo;
>>>>> +                   /* don't allow range of pvids */
>>>>> +                   if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVI=
D)
>>>>> +                           return -EINVAL;
>>>>>                     continue;
>>>>>             }
>>>>>
>>>>
>>>> Looks correct to me. Could you please submit this properly? Thanks=
!
>>>
>>> The above patch is correct, but we only solve part of the problem, =
since
>>> the range and bridge flags are exposed by switchdev_obj_port_vlan a=
s is.
>>>
>>> Thanks,
>>> -v
>>>
>>
>> Yes, the above fixes the bridge side. About the switchdev side it se=
ems like it's
>> up to the switchdev driver to do the right thing in its switchdev_op=
s. I took a
>> quick look at DSA and it seems correct, the flag isn't saved and on =
dump request
>> the flags are generated so it shouldn't be possible to export multip=
le pvids.
>> But switchdev_port_br_afspec() seems problematic, in fact I don't ev=
en see a vlan
>> id check, i.e. =3D=3D0 || >=3D VLAN_N_MASK.
>> Of course, I might be totally off point as I'm not that familiar wit=
h switchdev and
>> it's very late. :-)
>> But maybe it needs something like:
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index 6e4a4f9ad927..3dd52a53867f 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -16,6 +16,7 @@
>>  #include <linux/notifier.h>
>>  #include <linux/netdevice.h>
>>  #include <linux/if_bridge.h>
>> +#include <linux/if_vlan.h>
>>  #include <linux/list.h>
>>  #include <net/ip_fib.h>
>>  #include <net/switchdev.h>
>> @@ -716,10 +717,14 @@ static int switchdev_port_br_afspec(struct net=
_device *dev,
>>                         return -EINVAL;
>>                 vinfo =3D nla_data(attr);
>>                 vlan.flags =3D vinfo->flags;
>> +               if (!vinfo->vid || vinfo->vid >=3D VLAN_VID_MASK)
>> +                        return -EINVAL;
>>                 if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
>>                         if (vlan.vid_begin)
>>                                 return -EINVAL;
>>                         vlan.vid_begin =3D vinfo->vid;
>> +                       if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
>> +                               return -EINVAL;
>>                 } else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END=
) {
>>                         if (!vlan.vid_begin)
>>                                 return -EINVAL;
>=20
> This (and you other patch) seem right to me, if we're going to block
> setting PVID when specifying a vlan range.  Would you mind combining
> and resending both patches as one as a proper patch?
>=20

Thanks for the review, I'll prepare a small set as I'd like to keep the=
se
separate since they touch two different subsystems and will re-post.
I'll target net-next with the pvid range change and -net with the vlan
range check patch. Does this sound okay ?

Thanks,
 Nik
