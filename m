From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Sun, 07 Dec 2014 11:13:58 -0800
Message-ID: <5484A6F6.3040605@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com> <54815883.80909@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
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
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39936 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbaLGTOG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 14:14:06 -0500
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/14, 3:21 PM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>> Sent: Thursday, December 04, 2014 11:02 PM
>> To: Scott Feldman
>> Cc: Ji=C5=99=C3=AD P=C3=ADrko; Jamal Hadi Salim; Benjamin LaHaise; T=
homas Graf; john
>> fastabend; stephen@networkplumber.org; John Linville;
>> nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Florian
>> Fainelli; buytenh@wantstofly.org; Aviad Raveh; Netdev; David S. Mill=
er;
>> shm@cumulusnetworks.com; Andy Gospodarek
>> Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to s=
witch asic
>> if feature flag set
>>
>> On 12/4/14, 10:41 PM, Scott Feldman wrote:
>>> On Thu, Dec 4, 2014 at 6:26 PM,  <roopa@cumulusnetworks.com> wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> This allows offloading to switch asic without having the user to s=
et
>>>> any flag. And this is done in the bridge driver to rollback kernel
>>>> settings on hw offload failure if required in the future.
>>>>
>>>> With this, it also makes sure a notification goes out only after t=
he
>>>> attributes are set both in the kernel and hw.
>>> I like this approach as it streamlines the steps for the user in
>>> setting port flags.  There is one case for FLOODING where you'll ha=
ve
>>> to turn off flooding for both, and then turn on flooding in hw.  Yo=
u
>>> don't want flooding turned on on kernel and hw.
>> ok, maybe using the higher bits as in
>> https://patchwork.ozlabs.org/patch/413211/
>>
>> might help with that. Let me think some more.
>>>> ---
>>>>    net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>>>>    1 file changed, 26 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c ind=
ex
>>>> 9f5eb55..ce173f0 100644
>>>> --- a/net/bridge/br_netlink.c
>>>> +++ b/net/bridge/br_netlink.c
>>>> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct
>> nlmsghdr *nlh)
>>>>                                   afspec, RTM_SETLINK);
>>>>           }
>>>>
>>>> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>>>> +                       dev->netdev_ops->ndo_bridge_setlink) {
>>>> +               int ret =3D dev->netdev_ops->ndo_bridge_setlink(de=
v,
>>>> + nlh);
>>> I think you want to up-level this to net/core/rtnetlink.c because
>>> you're only enabling the feature for one instance of a driver that
>>> implements ndo_bridge_setlink: the bridge driver.  If another drive=
r
>>> was MASTER and implemented ndo_bridge_setlink, you'd want same chec=
k
>>> to push setting down to SELF port driver.
>> yeah, i thought about that. But i moved it here so that rollback wou=
ld be
>> easier.
> There is a need for propagating setlink/dellink requests down multipl=
e levels.
> The use-case I have in mind is a bridge at the top, team/bond in the =
middle, and port devices at the bottom.
> A setlink for VLAN filtering attributes would come with MASTER flag s=
et, and either port or bond/team netdev.
> How would this be handled?

Good point. glad that you brought this up.
>
> The propagation rules between bridge and enslaved port device could b=
e different from those between bond/team and enslaved devices.
> The current bridge driver does not propagate VLAN filtering from brid=
ge to its ports as each port could have different configuration. In a c=
ase of a bond/team all members need to have the same configuration such=
 that the a bond/team would be indistinguishable from a simple port.
>
> Therefore rtnetlink.c might not have the knowledge for propagation ac=
ross multiple levels.
> It seems that each device which implements ndo_bridge_setlink/ndo_bri=
dge_dellink  and could have master role, need to take care of propagati=
on to its slaves.

Are you suggesting all devices in such stack will implement=20
ndo_bridge_setlink/ndo_bridge_dellink ?.
If yes,  Then that will not scale in terms of supporting all devices.

I am thinking an ndo op will not help here. On our systems, for such=20
stacked devices, the switch driver is aware of all interfaces it cares=20
about. In this case since the bond slaves are switch ports, it tracks=20
the bond too. When the bond goes into the bridge, it tracks the bond as=
=20
a bridge port.
Which means it uses any information a bridge driver calls on its port=20
via ndo_bridge_setlink(). the port can be a bond or any device as long=20
as the bridge port leads to a switch port.

As long as the bond driver does not need to do anything in software for=
=20
this when its a bridge port, seems like the bridge driver should notify=
=20
any switch devices that are interested in this setlink attributes (This=
=20
includes the vlan information that you talk about).
To me this calls for switch device ops..... to go to the switch driver=20
directly (context for this is my short talk at the BOF at LPC dusseldor=
f).
These swdev ops could be registered by the switch driver for all device=
s=20
and at the time of the callback the switch driver can decide to service=
=20
it or not, OR it could be registered only on devices the switch driver=20
is interested in. (In this case when the bond becomes part of the bridg=
e )

Will think about this some more, and will work on some RFC patches for=20
this case.

Thanks,
Roopa
