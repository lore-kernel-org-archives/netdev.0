From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next RFC 4/6] Introduce sample tc action
Date: Tue, 18 Oct 2016 10:58:00 +0000
Message-ID: <DB3PR05MB0764DA26C8250B6C8DFD537CACD30@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <1476276069-5315-5-git-send-email-jiri@resnulli.us>
 <58025A90.9010608@cumulusnetworks.com>
 <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com>
 <58056A08.5070809@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Ido Schimmel" <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        "Yotam Gigi" <yotam.gi@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0078.outbound.protection.outlook.com ([104.47.2.78]:36992
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1760079AbcJRLbC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 07:31:02 -0400
In-Reply-To: <58056A08.5070809@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
>Sent: Tuesday, October 18, 2016 3:17 AM
>To: Jamal Hadi Salim <jhs@mojatatu.com>
>Cc: Jiri Pirko <jiri@resnulli.us>; netdev@vger.kernel.org; davem@davemloft=
.net;
>Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad
>Raz <eladr@mellanox.com>; Nogah Frankel <nogahf@mellanox.com>; Or Gerlitz
><ogerlitz@mellanox.com>; geert+renesas@glider.be;
>stephen@networkplumber.org; xiyou.wangcong@gmail.com; linux@roeck-us.net;
>Shrijeet Mukherjee <shm@cumulusnetworks.com>
>Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
>
>On 10/17/16, 3:10 AM, Jamal Hadi Salim wrote:
>>
>> Some comments:
>> IIUC, the main struggle seems to be whether the redirect to dummy0
>> is useful or not? i.e instead of just letting the packets go up the
>> stack on eth1?
>
>yep, correct...given existing workflow for the non-offloaded case is
>to receive sample packets via bpf filter on socket or
>use netlink as a sample delivery mechanism (NFLOG eg)
>
>
>> It seems like sflowd needs to read off eth1 via packet socket?
>> To be backward compatible - supporting that approach seems sensible.

I am not sure whether using socket is backward compatible. hsflowd=20
expects nflog packets, and ife packets will not be understood.

We planned on adding support on hsflowd in IFE encapsulated packets from
tuntap device.=20

Did I understand you correctly?

>>
>> Note:
>> There is a clear efficiency benefit of both using IFE encoding and
>> redirecting to dummy0.
>> 1) Redirecting to dummy0 implies you dont need to exercise a bpf
>> filter around every packet that comes off eth1.
>> I understand there are probably not millions of pps for this case;
>> but in a non-offloaded cases it could be millions pps.
>> And in case of sampling over many ethx devices, you can redirect
>> samples from many other ethx devices.
>> So making dummy0 the sflow device is a win.
>> 2) Encaping an IFE header implies a much more efficient bpf filter
>> (IFE ethertype is an excellent discriminator for bpf).
>>
>> Additional benefit is as mentioned before - redirecting to a device
>> means you can send it remotely over ethernet to a more powerful
>> machine without having to cross kernel-userspace. Redirecting instead
>> of mirroring to tuntap is also an interesting option.
>
>sure, this seems like a good option to have.
>generally you have one instance of the sampling agent on a hyper visor or =
switch.
>But, if you have use-cases where monitoring agents run external, sure.
>would have preferred if it was optional or an addon and not the default.
>
>Regarding the device, yeah, agree there are pros and cons.
>An additional device just to sample packets seems like an overkill.
>But, if there is no other other option, and there are benefits to it, no o=
bjections.
>Hopefully we can add another option on the existing api to skip the device=
 in the
>future.
>
>
>>
>>
>> On 16-10-15 12:34 PM, Roopa Prabhu wrote:
>>> On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotam.gi@gmail.com>
>>
>>
>>>> +
>>>> +struct sample_packet_metadata {
>>>> +    int sample_size;
>>>> +    int orig_size;
>>>> +    int ifindex;
>>>> +};
>>>> +
>>> This metadata does not look extensible.. can it be made to ?
>>>
>>
>> Sure it can...

I will update the userspace API to be more generice: I will drop this struc=
t and
let the user (iproute2 currently)  build the netlink packet himself (as Or=
=20
Gerlitz suggested).

>>
>>> With sflow in context, you need a pair of ifindex numbers to encode ing=
ress and
>egress ports.
>>
>> What is the use case for both?
>
>I have heard that most monitoring tools have moved to ingress only samplin=
g
>because of operational
>complexity (use case is sflow). I think hardware also supports ingress and=
 egress
>only sampling.
>better to have an option to reflect that in the api.

Agree. I will add both ingress and egress ports in the IFE. Both the hardwa=
re=20
Implementation and kernel implementation don't support setting both, but=20
It is good to have that option.

>
>>> Ideally you would also include a sequence number and a count of the tot=
al
>number of packets
>> > that were candidates for sampling.
>>
>> Sequence number may make sense (they will help show a gap if something
>> gets dropped). But i am not sure about the stats consuming such space.
>> Stats are something that can be queried (tc stats should have a record
>> of how many bytes/packets )
>
>sure, thats fine.

Will add sequence number.

>>
>>> The OVS implementation is a good example, the metadata includes all the
>actions applied
>>> to the packet in the kernel data path.
>>>
>>
>> Again not sure what the use case would be (and why waste such space
>> especially when you are sending over the wire with such details).
>
>All this is being used currently.., But, this can be other api's sflow use=
s
>for monitoring.
>http://openvswitch.org/support/ovscon2014/17/1400-ovs-sflow.pdf
>=09
>Does not have to be part of the main/basic sampling api...
>it was just an example.
>

I guess that making the API extensible solves this, isn't it?

>>
>>>> +    rcu_read_lock();
>>>> +    retval =3D READ_ONCE(s->tcf_action);
>>>> +
>>>> +    if (++s->packet_counter % s->rate =3D=3D 0) {
>>>
>>> The sampling function isn't random
>>>
>>> if (++s->packet_counter % s->rate =3D=3D 0) {
>>>
>>> This is unsuitable for sFlow, which is specific about the random sampli=
ng
>function required.
>>> BPF, OVS, and the
>>> ULOG statistics module include efficient kernel based random sampling
>functions that could be used instead.
>>>
>>
>> If i understood correctly, the above is a fallback sampling algorithm.
>> In the case of the spectrum it already does the sampling in the ASIC
>> so there is no need to repeat it in software.
>> Agreed that in that case the sampling approach is not sufficiently
>> random.
>
>yes. and since the same sampling api will be used for offloaded and non-of=
floaded
>case,
>the sampling algo here for the non-offloaded case...can do better .. atlea=
st match
>the existing
>api efficiency. We would want people to use the same api for the offload a=
nd non-
>offloaded case.

Yep, spectrum does not have this functionality, and this is why I did not i=
mplement in
sample sw implementation too. I agree that it should be there.

In my opinion, it should be optional param (like random_type or something),=
 that the
spectrum offload support will not implement (until hardware will support it=
).

>
>thanks,
>Roopa
