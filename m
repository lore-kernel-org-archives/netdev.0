From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Sun, 07 Dec 2014 20:56:56 -0800
Message-ID: <54852F98.9050304@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com> <54815883.80909@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com> <CAE4R7bAKTtWi6TbOaeNDxKkDFXf5H2E3NUdbNSizvq77ADtuNg@mail.gmail.com> <5484B773.7000809@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34848 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaLHE5G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 23:57:06 -0500
In-Reply-To: <5484B773.7000809@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/7/14, 12:24 PM, Roopa Prabhu wrote:
> On 12/5/14, 10:54 PM, Scott Feldman wrote:
>> On Fri, Dec 5, 2014 at 3:21 PM, Arad, Ronen <ronen.arad@intel.com>=20
>> wrote:
>>>
>>>> -----Original Message-----
>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>>> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>>>> Sent: Thursday, December 04, 2014 11:02 PM
>>>> To: Scott Feldman
>>>> Cc: Ji=C5=99=C3=AD P=C3=ADrko; Jamal Hadi Salim; Benjamin LaHaise;=
 Thomas Graf; john
>>>> fastabend; stephen@networkplumber.org; John Linville;
>>>> nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Flori=
an
>>>> Fainelli; buytenh@wantstofly.org; Aviad Raveh; Netdev; David S.=20
>>>> Miller;
>>>> shm@cumulusnetworks.com; Andy Gospodarek
>>>> Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to=
=20
>>>> switch asic
>>>> if feature flag set
>>>>
>>>> On 12/4/14, 10:41 PM, Scott Feldman wrote:
>>>>> On Thu, Dec 4, 2014 at 6:26 PM, <roopa@cumulusnetworks.com> wrote=
:
>>>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>>
>>>>>> This allows offloading to switch asic without having the user to=
 set
>>>>>> any flag. And this is done in the bridge driver to rollback kern=
el
>>>>>> settings on hw offload failure if required in the future.
>>>>>>
>>>>>> With this, it also makes sure a notification goes out only after=
 the
>>>>>> attributes are set both in the kernel and hw.
>>>>> I like this approach as it streamlines the steps for the user in
>>>>> setting port flags.  There is one case for FLOODING where you'll =
have
>>>>> to turn off flooding for both, and then turn on flooding in hw.  =
You
>>>>> don't want flooding turned on on kernel and hw.
>>>> ok, maybe using the higher bits as in
>>>> https://patchwork.ozlabs.org/patch/413211/
>>>>
>>>> might help with that. Let me think some more.
>>>>>> ---
>>>>>>    net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>>>>>>    1 file changed, 26 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c i=
ndex
>>>>>> 9f5eb55..ce173f0 100644
>>>>>> --- a/net/bridge/br_netlink.c
>>>>>> +++ b/net/bridge/br_netlink.c
>>>>>> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, stru=
ct
>>>> nlmsghdr *nlh)
>>>>>> afspec, RTM_SETLINK);
>>>>>>           }
>>>>>>
>>>>>> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>>>>>> + dev->netdev_ops->ndo_bridge_setlink) {
>>>>>> +               int ret =3D dev->netdev_ops->ndo_bridge_setlink(=
dev,
>>>>>> + nlh);
>>>>> I think you want to up-level this to net/core/rtnetlink.c because
>>>>> you're only enabling the feature for one instance of a driver tha=
t
>>>>> implements ndo_bridge_setlink: the bridge driver.  If another dri=
ver
>>>>> was MASTER and implemented ndo_bridge_setlink, you'd want same ch=
eck
>>>>> to push setting down to SELF port driver.
>>>> yeah, i thought about that. But i moved it here so that rollback=20
>>>> would be
>>>> easier.
>>> There is a need for propagating setlink/dellink requests down=20
>>> multiple levels.
>>> The use-case I have in mind is a bridge at the top, team/bond in th=
e=20
>>> middle, and port devices at the bottom.
>>> A setlink for VLAN filtering attributes would come with MASTER flag=
=20
>>> set, and either port or bond/team netdev.
>>> How would this be handled?
>>>
>>> The propagation rules between bridge and enslaved port device could=
=20
>>> be different from those between bond/team and enslaved devices.
>>> The current bridge driver does not propagate VLAN filtering from=20
>>> bridge to its ports as each port could have different configuration=
=2E=20
>>> In a case of a bond/team all members need to have the same=20
>>> configuration such that the a bond/team would be indistinguishable=20
>>> from a simple port.
>>>
>>> Therefore rtnetlink.c might not have the knowledge for propagation=20
>>> across multiple levels.
>>> It seems that each device which implements=20
>>> ndo_bridge_setlink/ndo_bridge_dellink  and could have master role,=20
>>> need to take care of propagation to its slaves.
>> Thanks Ronen for bringing up this use-case of stacked masters. I
>> think for VLAN filtering, the stacked master case is handled, not by
>> ndo_setlink/dellink at each level, but with ndo_vlan_rx_kill_vid and
>> ndo_vlan_rx_add_vid.  So the switch port driver can know VLAN
>> membership for port even if port is under bond which is under bridge=
,
>> by using ndo_vlan_rx_xxx and setting NETIF_F_HW_VLAN_CTAG_FILTER.  T=
he
>> bonding driver's ndo_vlan_rx_xxx handlers seem to keep ports in bond
>> VLAN membership consistent across bond.
>>
>> But in general, ndo_setlink/dellink don't work for the stack use-cas=
e
>> for other non-VLAN attributes.  Maybe the answer is to use the VLAN
>> propogation model for other attributes. ndo_setlink/dellink/getlink
>> have enough weird-isms it might be time to define cleaner ndo ops to
>> propagate the other attrs down.
> And, only the switch asic driver is interested in these attrs. So,=20
> seems like for these cases, we need to send these attrs to the=20
> switchdriver directly instead of going through the stack of netdevs ?=
=2E=20
> see my response to ronen's other email.

As I work on v3 version of the patches, thinking some more, i am going=20
to try to use the OFFLOAD feature flag to traverse the stack of netdevs=
=20
(the bond to the slaves) to get to the switch port.  This is only for=20
bridge port attrs for now.
