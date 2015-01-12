From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Mon, 12 Jan 2015 10:48:45 -0800
Message-ID: <CAEP_g=-ieFjaDJspNkDjS64qDZEiRXDocDpjDm4dTPMYARGRZg@mail.gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
 <54AA2912.6090903@gmail.com> <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
 <54ABAC13.9070402@gmail.com> <CAEP_g=8bCR=PeSoi09jLWLtNUrxhzx45h1Wm=9D=R57AqUac2w@mail.gmail.com>
 <54ACCAFD.4070203@gmail.com> <CAEP_g=8EBeQUFkRRsG3sznYryd+LE9qJKWQXfS==HG2HDO=UKA@mail.gmail.com>
 <54AE506A.5020207@gmail.com> <CAEP_g=9hh+MG7AWEnct7CwRqp=ZghpbkDeQ5BhGQktDgMST1jA@mail.gmail.com>
 <54AF6A60.5090804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Du, Fan" <fan.du@intel.com>, Thomas Graf <tgraf@suug.ch>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog006.obsmtp.com ([74.125.150.52]:38933 "HELO
	na6sys009bog006.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752237AbbALStH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 13:49:07 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so19481183qcx.12
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 10:49:06 -0800 (PST)
In-Reply-To: <54AF6A60.5090804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 9:42 PM, Fan Du <fengyuleidian0615@gmail.com> wr=
ote:
> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8809=E6=97=A5 03:55, Jesse Gross =E5=86=
=99=E9=81=93:
>
>> On Thu, Jan 8, 2015 at 1:39 AM, Fan Du <fengyuleidian0615@gmail.com>
>> wrote:
>>>
>>> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8808=E6=97=A5 04:52, Jesse Gross =E5=
=86=99=E9=81=93:
>>>>>
>>>>>
>>>>> My understanding is:
>>>>>>
>>>>>> controller sets the forwarding rules into kernel datapath, any f=
low
>>>>>> not
>>>>>> matching
>>>>>> with the rules are threw to controller by upcall. Once the rule
>>>>>> decision
>>>>>> is
>>>>>> made
>>>>>> by controller, then, this flow packet is pushed down to datapath=
 to be
>>>>>> forwarded
>>>>>> again according to the new rule.
>>>>>>
>>>>>> So I'm not sure whether pushing the over-MTU-sized packet or pus=
hing
>>>>>> the
>>>>>> forged ICMP
>>>>>> without encapsulation to controller is required by current ovs
>>>>>> implementation. By doing
>>>>>> so, such over-MTU-sized packet is treated as a event for the
>>>>>> controller
>>>>>> to
>>>>>> be take
>>>>>> care of.
>>>>
>>>>
>>>> If flows are implementing routing (again, they are doing things li=
ke
>>>> decrementing the TTL) then it is necessary for them to also handle
>>>> this situation using some potentially new primitives (like a size
>>>> check). Otherwise you end up with issues like the ones that I
>>>> mentioned above like needing to forge addresses because you don't =
know
>>>> what the correct ones are.
>>>
>>>
>>>
>>> Thanks for explaining, Jesse!
>>>
>>> btw, I don't get it about "to forge addresses", building ICMP messa=
ge
>>> with Guest packet doesn't require to forge address when not encapsu=
lating
>>> ICMP message with outer headers.
>>
>>
>> Your patch has things like this (for the inner IP header):
>>
>> +                               new_ip->saddr =3D orig_ip->daddr;
>> +                               new_ip->daddr =3D orig_ip->saddr;
>>
>> These addresses are owned by the endpoints, not the host generating
>> generating the ICMP message, so I would consider that to be forging
>> addresses.
>>
>>> If the flows aren't doing things to
>>>>
>>>>
>>>> implement routing, then you really have a flat L2 network and you
>>>> shouldn't be doing this type of behavior at all as I described in =
the
>>>> original plan.
>>>
>>>
>>>
>>> For flows implementing routing scenario:
>>> First of all, over-MTU-sized packet could only be detected once the=
 flow
>>> as been consulted(each port could implement a 'check' hook to do th=
is),
>>> and just before send to the actual port.
>>>
>>> Then pushing the over-MTU-sized packet back to controller, it's the
>>> controller
>>> who will will decide whether to build ICMP message, or whatever rou=
ting
>>> behaviour
>>> it may take. And sent it back with the port information. This ICMP
>>> message
>>> will
>>> travel back to Guest.
>>>
>>> Why does the flow has to use primitive like a "check size"? "check =
size"
>>> will only take effect after do_output. I'm not very clear with this
>>> approach.
>>
>>
>> Checking the size obviously needs to be an action that would take
>> place before outputting in order for it to have any effect. Attachin=
g
>> a check to a port does not fit in very well with the other primitive=
s
>> of OVS, so I think an action is the obvious place to put it.
>
>
> If flow is defined as:
>
>         CHECK_SIZE -> OUTPUT
>
> Then traversing actions at CHECK_SIZE needs to find the exactly OUTPU=
T port,
> thus get its underlay encapsulation method as well as valid route for
> physical
> NIC MTU, with those information can calculation whether GSOed packets
> exceeds physical MTU. This is feasible anyway at the first look. Afte=
r this,
> it's the controller responsibility to handle such event.
>
> If the CHECK_SIZE returns positive(over-MTU-sized packets show up), t=
hen
> call
> output_userspace to push this packet upper wards.
>
> I'm not sure this vague idea is the expected behaviour as required by=
 "L3
> processing".

Yes, I think that's the right path.
