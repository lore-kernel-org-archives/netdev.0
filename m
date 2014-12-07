From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Sun, 07 Dec 2014 09:33:59 -0800
Message-ID: <54848F87.6050005@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com> <54815883.80909@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com> <E4CD12F19ABA0C4D8729E087A761DC3505D8436D@ORSMSX101.amr.corp.intel.com> <CAE4R7bChFLfCX5z4FTWHfnpNuYKnkTtD64xg5BE0yAwA381w3g@mail.gmail.com> <E4CD12F19ABA0C4D8729E087A761DC3505D84532@ORSMSX101.amr.corp.intel.com>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:60298 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaLGReG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 12:34:06 -0500
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D84532@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/6/14, 12:05 AM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: Scott Feldman [mailto:sfeldma@gmail.com]
>> Sent: Friday, December 05, 2014 10:29 PM
>> To: Arad, Ronen
>> Cc: Roopa Prabhu; Netdev; Jir=C3=AD P=C3=ADrko; Jamal Hadi Salim; Be=
njamin LaHaise;
>> Thomas Graf; john fastabend; stephen@networkplumber.org; John Linvil=
le;
>> nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Florian
>> Fainelli; buytenh@wantstofly.org; Aviad Raveh; David S. Miller;
>> shm@cumulusnetworks.com; Andy Gospodarek
>> Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to s=
witch asic
>> if feature flag set
>>
>> On Fri, Dec 5, 2014 at 5:04 PM, Arad, Ronen <ronen.arad@intel.com> w=
rote:
>>> I have another case of propagation which is not covered by the prop=
osed
>> patch.
>>> A recent patch introduced default_pvid attribute for a bridge (so f=
ar
>> supported only via sysfs and not via netlink).
>>> When a port joins a bridge, it inherits a PVID from the default_pvi=
d of the
>> bridge.
>>> The bridge driver propagates that to the newly created net_bridge_p=
ort.
>> This is done in br_vlan.c:
>>> int nbp_vlan_init(struct net_bridge_port *p) {
>>>          int rc =3D 0;
>>>
>>>          if (p->br->default_pvid) {
>>>                  rc =3D nbp_vlan_add(p, p->br->default_pvid,
>>>                                    BRIDGE_VLAN_INFO_PVID |
>>>                                    BRIDGE_VLAN_INFO_UNTAGGED);
>>>          }
>>>
>>>          return rc;
>>> }
>>>
>>> When L2 switching is offloaded to the HW, this PVID setting need to=
 be
>> propagated.
>>
>> Agreed, it would be nice to have it propagated down, but there is a =
non-ideal
>> work-around.  If you set default_pvid=3D0 to turn off PVID, then the=
 switch port
>> driver can pick some internal VLAN ID just for HW purposes in matchi=
ng
>> untagged pkts.  It's non-ideal because the switch port driver needs =
to reserve
>> a block of VLAN IDs for internal usage or use some other matching
>> mechanism to keep untagged pkts within this bridge.
> This work-around let the administrator avoid using VID=3D1 as the def=
ault VLAN for untagged frames. However, it does not let the administrat=
or pick a VID of her choice.
>
>> Better to have default_pvid value propagated down.  But, default_pvi=
d is a
>> per-bridge property, not a per-bridge-port property.
>> RTM_SETLINK/RTM_GETLINK for PF_BRIDGE does have AFSPEC for per-bridg=
e
>> and PROTINFO for per-bridge-port, so it seems PVID needs to be part =
of
>> AFSPEC.
> I believe AFSPEC is not limited to per-bridge properties. It is per-b=
ridge when the netlink msg's ifindex is that of a bridge and SELF flag =
is set.
> AFSPEC is for a port when the netlink msg's ifindex is that of an ens=
laved port device and MASTER flag is set (or neither MASTER nor SELF fl=
ag is set)
> PVID is one of the flags associated with a VID in bridge_vlan_info.
correct.
> default_pvid is not currently supported by netlink. A new IFLA_BRIDGE=
_DEFAULT_PVID could be introduced to carry this property when a nlmsg i=
s directed at a bridge.
>
>
correct again. And yes,  a netlink attribute to set default pvid is due=
=2E
