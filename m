From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Fri, 09 Jan 2015 13:48:15 +0800
Message-ID: <54AF6B9F.6080104@gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com> <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com> <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home> <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com> <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com> <54AA2912.6090903@gmail.com> <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com> <54ABAC13.9070402@gmail.com> <CAEP_g=8bCR=PeSoi09jLWLtNUrxhzx45h1Wm=9D=R57AqUac2w@mail.gmail.com> <54ACCAFD.4070203@gmail.com> <CAEP_g=8EBeQUFkRRsG3sznYryd+LE9qJKWQXfS==HG2HDO=UKA@mail.gmail.com> <54AE506A.5020207@gmail.com> <CAEP_g=9hh+MG7AWEnct7CwRq
 p=ZghpbkDeQ5BhGQktDgMST1jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Du, Fan" <fan.du@intel.com>, Thomas Graf <tgraf@suug.ch>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:58627 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbAIFvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 00:51:55 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so16422132pab.7
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 21:51:54 -0800 (PST)
In-Reply-To: <CAEP_g=9hh+MG7AWEnct7CwRqp=ZghpbkDeQ5BhGQktDgMST1jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8809=E6=97=A5 03:55, Jesse Gross =E5=86=
=99=E9=81=93:
> On Thu, Jan 8, 2015 at 1:39 AM, Fan Du<fengyuleidian0615@gmail.com>  =
wrote:
>> >=E4=BA=8E 2015=E5=B9=B401=E6=9C=8808=E6=97=A5 04:52, Jesse Gross =E5=
=86=99=E9=81=93:
>>>> >>>
>>>> >>>My understanding is:
>>>>> >>> >controller sets the forwarding rules into kernel datapath, a=
ny flow not
>>>>> >>> >matching
>>>>> >>> >with the rules are threw to controller by upcall. Once the r=
ule decision
>>>>> >>> >is
>>>>> >>> >made
>>>>> >>> >by controller, then, this flow packet is pushed down to data=
path to be
>>>>> >>> >forwarded
>>>>> >>> >again according to the new rule.
>>>>> >>> >
>>>>> >>> >So I'm not sure whether pushing the over-MTU-sized packet or=
 pushing the
>>>>> >>> >forged ICMP
>>>>> >>> >without encapsulation to controller is required by current o=
vs
>>>>> >>> >implementation. By doing
>>>>> >>> >so, such over-MTU-sized packet is treated as a event for the=
 controller
>>>>> >>> >to
>>>>> >>> >be take
>>>>> >>> >care of.
>>> >>
>>> >>If flows are implementing routing (again, they are doing things l=
ike
>>> >>decrementing the TTL) then it is necessary for them to also handl=
e
>>> >>this situation using some potentially new primitives (like a size
>>> >>check). Otherwise you end up with issues like the ones that I
>>> >>mentioned above like needing to forge addresses because you don't=
 know
>>> >>what the correct ones are.
>> >
>> >
>> >Thanks for explaining, Jesse!
>> >
>> >btw, I don't get it about "to forge addresses", building ICMP messa=
ge
>> >with Guest packet doesn't require to forge address when not encapsu=
lating
>> >ICMP message with outer headers.
> Your patch has things like this (for the inner IP header):
>
> +                               new_ip->saddr =3D orig_ip->daddr;
> +                               new_ip->daddr =3D orig_ip->saddr;
>
> These addresses are owned by the endpoints, not the host generating
> generating the ICMP message, so I would consider that to be forging
> addresses.
>
>> >If the flows aren't doing things to
>>> >>
>>> >>implement routing, then you really have a flat L2 network and you
>>> >>shouldn't be doing this type of behavior at all as I described in=
 the
>>> >>original plan.
>> >
>> >
>> >For flows implementing routing scenario:
>> >First of all, over-MTU-sized packet could only be detected once the=
 flow
>> >as been consulted(each port could implement a 'check' hook to do th=
is),
>> >and just before send to the actual port.
>> >
>> >Then pushing the over-MTU-sized packet back to controller, it's the
>> >controller
>> >who will will decide whether to build ICMP message, or whatever rou=
ting
>> >behaviour
>> >it may take. And sent it back with the port information. This ICMP =
message
>> >will
>> >travel back to Guest.
>> >
>> >Why does the flow has to use primitive like a "check size"? "check =
size"
>> >will only take effect after do_output. I'm not very clear with this
>> >approach.
> Checking the size obviously needs to be an action that would take
> place before outputting in order for it to have any effect. Attaching
> a check to a port does not fit in very well with the other primitives
> of OVS, so I think an action is the obvious place to put it.
>
>> >And not all scenario involving flow with routing behaviour, just se=
t up a
>> >vxlan tunnel, and attach KVM guest or Docker onto it for playing or
>> >developing.
>> >This wouldn't necessarily require user to set additional specific f=
lows to
>> >make
>> >over-MTU-sized packet pass through the tunnel correctly. In such sc=
enario, I
>> >think the original patch in this thread to fragment tunnel packet i=
s still
>> >needed
>> >OR workout a generic component to build ICMP for all type tunnel in=
 L2
>> >level.
>> >Both of those will act as a backup plan as there is no such specifi=
c flow as
>> >default.
> In these cases, we should find a way to adjust the MTU, preferably
> automatically using virtio.

I'm gonna to argue this a bit more here.

virtio_net pose no limit at its simulated net device, actually it can f=
all into
anywhere between 68 and 65535. Most importantly, virtio_net just simula=
tes NIC,
it just can=E2=80=99t assume/presume there is an encapsulating port at =
its downstream.
How should virtio automatically adjust its upper guest MTU?



--=20
No zuo no die but I have to try.
