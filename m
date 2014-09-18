From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH 3/3] bridge;
 Automatically filter vlans configured on top of bridge
Date: Thu, 18 Sep 2014 18:47:47 +0900
Message-ID: <541AAA43.1070200@lab.ntt.co.jp>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<1410554691-18467-4-git-send-email-vyasevic@redhat.com>
	<5415B6C2.5030702@gmail.com> <54170372.4080903@redhat.com>
	<54181EC1.2010608@lab.ntt.co.jp> <54183BCF.8070506@redhat.com>
	<54184BB9.8010802@gmail.com> <54185095.4020102@redhat.com>
	<5418D4F3.5070701@lab.ntt.co.jp> <54199753.8050608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com, Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <54199753.8050608@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2014/09/17 23:14, Vlad Yasevich wrote:
> On 09/16/2014 08:25 PM, Toshiaki Makita wrote:
>> On 2014/09/17 0:00, Vlad Yasevich wrote:
>>> On 09/16/2014 10:39 AM, Toshiaki Makita wrote:
>>>> (14/09/16 (=E7=81=AB) 22:31), Vlad Yasevich wrote:
>>>>> On 09/16/2014 07:28 AM, Toshiaki Makita wrote:
>>>>>> On 2014/09/16 0:19, Vlad Yasevich wrote:
>>>>>>> On 09/14/2014 11:39 AM, Toshiaki Makita wrote:
>>>>>>>> (14/09/13 (=E5=9C=9F) 5:44), Vladislav Yasevich wrote:
>>>>>>>>> If the user configures vlan devices on top of the bridge,
>>>>>>>>> automatically set up filter entries for it as long as
>>>>>>>>> bridge vlan protocol matches that of the vlan.
>>>>>>>>> This allows the user to atomatically receive vlan traffic
>>>>>>>>> for the vlans that are convifgured.
>>>>>>>>
>>>>>>>> Changing br->vlan_proto seems to cause inconsistency between vla=
n
>>>>>>>> interfaces and filter settings.
>>>>>>>> Can we automatically change filters when setting vlan_proto?
>>>>>>>>
>>>>>>>
>>>>>>> I thought we already do that in br_vlan_set_proto()?  Nothing
>>>>>>> here introduces any new kinds of issue with that code.
>>>>>>
>>>>>> I'm referring to a case like this:
>>>>>> 1. create br0.10 (802.1ad)
>>>>>> 2. change br->vlan_proto into 88a8
>>>>>>
>>>>>> When creating br0.10 (1), br->vlan_proto is 8100 and different fro=
m
>>>>>> protocol of br0.10, so it is ignored by br_vlan_rx_add_vid().
>>>>>> After changing br->vlan_proto (2), we might expect vlan 10 is not
>>>>>> filtered on br0, but it will be filtered.
>>>>>
>>>>> Ok, I see what you mean.  This one is a bit tough.  Our options are=
:
>>>>>   1) Return an error when configuring br0.10.  This might break use=
r-space.  Not good.
>>>>>   2) Ignore protocol when crating the filter.  This is not good eit=
her as the user
>>>>>      may not switch the bridge vlan_proto value and we'd end up wit=
h a wrong filter.
>>>>>   3) Re-implement .1ad support per-vlan instead of per-bridge.
>>>>>
>>>>> You see another other alternatives?
>>>>
>>>> We might be able to configure filterings on changing vlan_proto.
>>>> 4) Memorize different protocol's filtering requests in
>>>> br_vlan_rx_add_vid() and use them when switching vlan_proto.
>>>
>>> If we do this, we might as well take it one small step further and ma=
ke per-vlan protocol
>>> support.
>>>
>>>> 5) Scan vlan devices on bridge device when changing vlan_proto.
>>>>
>>>
>>> The scan could work...  walk the upper devices looking for vlans and =
add/delete filters
>>> based on the protocol of the vlan devices.
>>>
>>> Seems kind of hacky, but let me give this one a try...
>>
>> dev->vlan_info->vid_list might be a more appropriate list since
>> vlan_vid_add() can be called not only by vlan devices.
>=20
> That's private to vlan implementation and I don't think this is a good =
reason
> to expose it.

I'm not thinking that scanning directly this list is appropriate.
My point is that vlan layer manages the exact vid list that dev is
required to unfilter and we maybe don't want to manage such lists
redundantly.
We can make APIs to utilize the vid list indirectly.

A simple (but inefficient) way is to make a function like
"bool vlan_has_vid(dev, proto, vid)" and check for all 4094 vids using it=
.

A possible more efficient way is the one using bitmap. We can make a
function vlan_vids_inuse(dev, proto, bitmap) and get bitmap of vids,
like udp_lib_lport_inuse().

Thanks,
Toshiaki Makita
