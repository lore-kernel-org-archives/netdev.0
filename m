From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: switchdev and VLAN ranges
Date: Sun, 11 Oct 2015 22:14:11 -0700
Message-ID: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com> <5618EA2A.3020900@cumulusnetworks.com>
 <20151011071208.GA2188@nanopsycho.orion> <20151011224125.GB21128@ketchup.lan> <561AFB2C.2010603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Jiri Pirko <jiri@resnulli.us>, Elad Raz <eladr@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35336 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbJLFOc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 01:14:32 -0400
Received: by oiao187 with SMTP id o187so21456185oia.2
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 22:14:31 -0700 (PDT)
In-Reply-To: <561AFB2C.2010603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2015 at 5:13 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 10/12/2015 12:41 AM, Vivien Didelot wrote:
>> On Oct. Sunday 11 (41) 09:12 AM, Jiri Pirko wrote:
>>> Sat, Oct 10, 2015 at 12:36:26PM CEST, nikolay@cumulusnetworks.com w=
rote:
>>>> On 10/10/2015 09:49 AM, Elad Raz wrote:
>>>>>
>>>>>> On Oct 10, 2015, at 2:30 AM, Vivien Didelot <vivien.didelot@savo=
irfairelinux.com> wrote:
>>>>>>
>>>>>> I have two concerns in mind:
>>>>>>
>>>>>> a) if we imagine that drivers like Rocker allocate memory in the=
 prepare
>>>>>> phase for each VID, preparing a range like 100-4000 would defini=
tely not
>>>>>> be recommended.
>>>>>>
>>>>>> b) imagine that you have two Linux bridges on a switch, one usin=
g the
>>>>>> hardware VLAN 100. If you request the VLAN range 99-101 for the =
other
>>>>>> bridge members, it is not possible for the driver to say "I can
>>>>>> accelerate VLAN 99 and 101, but not 100". It must return OPNOTSU=
PP for
>>>>>> the whole range.
>>>>>
>>>>> Another concern I have with vid_being..vid_end range is the =E2=80=
=9Cflags=E2=80=9D. Where flags can be BRIDGE_VLAN_INFO_PVID.
>>>>> There is no sense having more than one VLAN as a PVID.
>>>>> This leave the HW vendor the choice which VLAN id they will use a=
s the PVID.
>>>>>
>>>>
>>>> iproute2 doesn't allow to do it but I can see that someone can act=
ually make it
>>>> so the flags for the range have it and it doesn't look correct. Pe=
rhaps we need
>>>> something like the patch below to enforce this from kernel-side.
>>>>
>>>>
>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>>> index d78b4429505a..02b17b53e9a6 100644
>>>> --- a/net/bridge/br_netlink.c
>>>> +++ b/net/bridge/br_netlink.c
>>>> @@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
>>>>                     if (vinfo_start)
>>>>                             return -EINVAL;
>>>>                     vinfo_start =3D vinfo;
>>>> +                   /* don't allow range of pvids */
>>>> +                   if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID=
)
>>>> +                           return -EINVAL;
>>>>                     continue;
>>>>             }
>>>>
>>>
>>> Looks correct to me. Could you please submit this properly? Thanks!
>>
>> The above patch is correct, but we only solve part of the problem, s=
ince
>> the range and bridge flags are exposed by switchdev_obj_port_vlan as=
 is.
>>
>> Thanks,
>> -v
>>
>
> Yes, the above fixes the bridge side. About the switchdev side it see=
ms like it's
> up to the switchdev driver to do the right thing in its switchdev_ops=
=2E I took a
> quick look at DSA and it seems correct, the flag isn't saved and on d=
ump request
> the flags are generated so it shouldn't be possible to export multipl=
e pvids.
> But switchdev_port_br_afspec() seems problematic, in fact I don't eve=
n see a vlan
> id check, i.e. =3D=3D0 || >=3D VLAN_N_MASK.
> Of course, I might be totally off point as I'm not that familiar with=
 switchdev and
> it's very late. :-)
> But maybe it needs something like:
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 6e4a4f9ad927..3dd52a53867f 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -16,6 +16,7 @@
>  #include <linux/notifier.h>
>  #include <linux/netdevice.h>
>  #include <linux/if_bridge.h>
> +#include <linux/if_vlan.h>
>  #include <linux/list.h>
>  #include <net/ip_fib.h>
>  #include <net/switchdev.h>
> @@ -716,10 +717,14 @@ static int switchdev_port_br_afspec(struct net_=
device *dev,
>                         return -EINVAL;
>                 vinfo =3D nla_data(attr);
>                 vlan.flags =3D vinfo->flags;
> +               if (!vinfo->vid || vinfo->vid >=3D VLAN_VID_MASK)
> +                        return -EINVAL;
>                 if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
>                         if (vlan.vid_begin)
>                                 return -EINVAL;
>                         vlan.vid_begin =3D vinfo->vid;
> +                       if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
> +                               return -EINVAL;
>                 } else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END)=
 {
>                         if (!vlan.vid_begin)
>                                 return -EINVAL;

This (and you other patch) seem right to me, if we're going to block
setting PVID when specifying a vlan range.  Would you mind combining
and resending both patches as one as a proper patch?
