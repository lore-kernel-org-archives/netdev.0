From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath hardware offload
Date: Tue, 26 Aug 2014 08:01:22 -0700
Message-ID: <D891A8EC-548C-453E-AC70-8431DAC4B8C4@cumulusnetworks.com>
References: <53F79C54.5050701@gmail.com> <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com> <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org> <53FA01AC.10507@mojatatu.com> <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com> <53FAA2A2.7070801@gmail.com> <53FB3FD5.2030905@mojatatu.com> <20140825141754.GA30140@casper.infradead.org> <53FB6122.2040901@mojatatu.com> <20140825225057.GD30140@casper.infradead.org> <53FC909D.8090000@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35985 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758562AbaHZPBf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:01:35 -0400
In-Reply-To: <53FC909D.8090000@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 26, 2014, at 6:50 AM, Roopa Prabhu <roopa@cumulusnetworks.com> w=
rote:

> On 8/25/14, 3:50 PM, Thomas Graf wrote:
>> On 08/25/14 at 12:15pm, Jamal Hadi Salim wrote:
>>> On 08/25/14 10:17, Thomas Graf wrote:
>>>> On 08/25/14 at 09:53am, Jamal Hadi Salim wrote:
>>>> fdb_add() *is* flow based. At least in my understanding, the whole
>>>> point here is to extend the idea of fdb_add() and make it understa=
nd
>>>> L2-L4 in a more generic way for the most common protocols.
>>>>=20
>>>> The reason fdb_add() is not reused is because it is Netlink specif=
ic
>>>> and only suitable for User -> HW offload. Kernel -> HW offload is
>>>> technically possible but not clean.
>>>>=20
>>> I dont think we have a problem handling any of this today.
>> Yes we do. It's restricted to L2 and we can't extend it easily
>> because it is based on NDA_*. The use of Netlink makes in-kernel
>> usage a pain. To me this is the sole reason for not using fdb_add()
>> in the first place. It seems absolutely clear though that fdb_add()
>> should be removed after the more generic ndo is in place providing
>> a superset of what fdb_add() can do today.
>>=20
>>> This is where our (shall i say strong) disagreement is.
>>> I think you will find it non-trivial to show me how you can
>>> actually take the simple L2 bridge and map it to a "flow".
>>> Since your starting point is "everything can be represented via a f=
low
>>> and some table" - we are at a crosspath.
>> OK, let me do the convertion for you:
>>=20
>> NDA_DST		unused
>> NDA_LLADDR	sw_flow_key.eth.dst
>> NDA_CACHEINFO	unused
>> NDA_PROBES	unused
>> NDA_VLAN	sw_flow_key.eth.tci
>> NDA_PORT	unused
>> NDA_VNI		sw_flow_key.tun_key.tun_id
>> NDA_IFINDEX	sw_flow_key.phys.in_port
>> NDA_MASTER	unused
>>=20
>>> The tc filter API seems to be doing just that.
>>> You have different types of classifiers - the h/w may not be able
>>> to support some classifier types - but that is a capability discove=
ry
>>> challenge.
>> Agreed but tc is only one out of many possible existing interfaces
>> we have. macvtap (given we want to extend beyond L2), routing,
>> OVS, bridge and eventually even things like a team device can and
>> should make use of offloads.
>>=20
>>> I am saying two things:
>>> 1) There are a few "fundamental" interfaces; L2 and L3 being some.
>>> Add crypto offload and a few i mentioned in  my presentation. We
>> Can you share that preso? I was not present.
>>=20
>>> know how to do those. example; there is nothing i cant do with
>>> the rtmsg that is L3. or the fdb/port/vlan filter for L2.
>>> This flow thing should stay out of those.
>> Let me remind you about the name of the structure behind all L3
>> forwarding decisions:
>>=20
>>         struct flowi4 {
>> 		[...]
>> 	}
>>=20
>> Adding a route means adding a flow. Can we please stop the flow
>> bashing? The concept of a flow is very generic, well known and alrea=
dy
>> very present in the kernel.
>>=20
>> The sw_flow_key proposed comes close to flowi4. Some fields are
>> different. They can eventually get merged. The strict IPv4/IPv6
>> separation is what makes it non obvious and probably why Jiri chose
>> the OVS representation. If you say rtmsg is complete then that clear=
ly
>> is not the case. In particular VTEP fields, ARP, and TCP flags are
>> clearly missing for many uses.
>>=20
>> Again, I'm not saying flow is the ultimate answer to everything. It
>> is not. But a lot of hardware out there is aware of flows in combina=
tion
>> with some form of action execution. Non flow based hardware can have
>> their own classifier.
>>=20
>>> 2) The flow thing should allow a variety of classifiers to be
>>> handled. Again capability discovery would take care of differences.
>> So you want the flow to represent something that is not a flow. Agai=
n,
>> this comes back to the conversation in the other email. If this is
>> all about having a single ndo I'm sure we can find common grounds on
>> that.
>=20
> From what i understood (trying to summarize here for my own benefit):
> the switchdev api currently under review proposes every switch asic o=
ffload abstraction as a flow.
> It does not mandate this via code, however, there seems to be some di=
scussion along those lines.
>=20
> The switchdev api flow ndo's need to stay for switch asic drivers tha=
t support flows directly or
> possibly want all their hw offload abstraction to be represented by t=
he flow abstraction (openvswitch, the rocker dev ). The details of how =
the flow is mapped to hw lies in the corresponding switch driver code.
>=20
> We think rtnetlink is the api to model switch asic hw tables.
> We have a working model (Cumulus) that maps rtnetlink to switch
> asic hw tables (via snooping rtnetlink msgs). This can be done by ext=
ending the switchdev api
> with new ndo's for l2 and l3.
>=20

I don=92t see it that way.  I believe sw_flow can be the intermediary r=
epresentation to span flow-based and non-flow-based HW, and from flow-b=
ased world and traditional l2/l3 world.


> Example:
>  new switchdev ndo's for fdb_add/fdb_del
>  new switchdev ndo's for l3
>=20
> Now we only need working patches that implement switchdev api ndo ops=
 for l2/l3 (this is in the works).
>=20
> As long as the current patches under review allow the extension of th=
e api to cover non-flow based l2/l3 switch asic offloads, we might be g=
ood (?).
>=20
> Thanks,
> Roopa
>=20
>=20
>=20


-scott
