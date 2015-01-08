From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 8 Jan 2015 11:55:00 -0800
Message-ID: <CAEP_g=9hh+MG7AWEnct7CwRqp=ZghpbkDeQ5BhGQktDgMST1jA@mail.gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
 <54AA2912.6090903@gmail.com> <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
 <54ABAC13.9070402@gmail.com> <CAEP_g=8bCR=PeSoi09jLWLtNUrxhzx45h1Wm=9D=R57AqUac2w@mail.gmail.com>
 <54ACCAFD.4070203@gmail.com> <CAEP_g=8EBeQUFkRRsG3sznYryd+LE9qJKWQXfS==HG2HDO=UKA@mail.gmail.com>
 <54AE506A.5020207@gmail.com>
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
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:53648 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751576AbbAHTzW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 14:55:22 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so4189781qcq.11
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 11:55:21 -0800 (PST)
In-Reply-To: <54AE506A.5020207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2015 at 1:39 AM, Fan Du <fengyuleidian0615@gmail.com> wr=
ote:
> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8808=E6=97=A5 04:52, Jesse Gross =E5=86=
=99=E9=81=93:
>>>
>>> My understanding is:
>>> >controller sets the forwarding rules into kernel datapath, any flo=
w not
>>> >matching
>>> >with the rules are threw to controller by upcall. Once the rule de=
cision
>>> > is
>>> >made
>>> >by controller, then, this flow packet is pushed down to datapath t=
o be
>>> >forwarded
>>> >again according to the new rule.
>>> >
>>> >So I'm not sure whether pushing the over-MTU-sized packet or pushi=
ng the
>>> >forged ICMP
>>> >without encapsulation to controller is required by current ovs
>>> >implementation. By doing
>>> >so, such over-MTU-sized packet is treated as a event for the contr=
oller
>>> > to
>>> >be take
>>> >care of.
>>
>> If flows are implementing routing (again, they are doing things like
>> decrementing the TTL) then it is necessary for them to also handle
>> this situation using some potentially new primitives (like a size
>> check). Otherwise you end up with issues like the ones that I
>> mentioned above like needing to forge addresses because you don't kn=
ow
>> what the correct ones are.
>
>
> Thanks for explaining, Jesse!
>
> btw, I don't get it about "to forge addresses", building ICMP message
> with Guest packet doesn't require to forge address when not encapsula=
ting
> ICMP message with outer headers.

Your patch has things like this (for the inner IP header):

+                               new_ip->saddr =3D orig_ip->daddr;
+                               new_ip->daddr =3D orig_ip->saddr;

These addresses are owned by the endpoints, not the host generating
generating the ICMP message, so I would consider that to be forging
addresses.

> If the flows aren't doing things to
>>
>> implement routing, then you really have a flat L2 network and you
>> shouldn't be doing this type of behavior at all as I described in th=
e
>> original plan.
>
>
> For flows implementing routing scenario:
> First of all, over-MTU-sized packet could only be detected once the f=
low
> as been consulted(each port could implement a 'check' hook to do this=
),
> and just before send to the actual port.
>
> Then pushing the over-MTU-sized packet back to controller, it's the
> controller
> who will will decide whether to build ICMP message, or whatever routi=
ng
> behaviour
> it may take. And sent it back with the port information. This ICMP me=
ssage
> will
> travel back to Guest.
>
> Why does the flow has to use primitive like a "check size"? "check si=
ze"
> will only take effect after do_output. I'm not very clear with this
> approach.

Checking the size obviously needs to be an action that would take
place before outputting in order for it to have any effect. Attaching
a check to a port does not fit in very well with the other primitives
of OVS, so I think an action is the obvious place to put it.

> And not all scenario involving flow with routing behaviour, just set =
up a
> vxlan tunnel, and attach KVM guest or Docker onto it for playing or
> developing.
> This wouldn't necessarily require user to set additional specific flo=
ws to
> make
> over-MTU-sized packet pass through the tunnel correctly. In such scen=
ario, I
> think the original patch in this thread to fragment tunnel packet is =
still
> needed
> OR workout a generic component to build ICMP for all type tunnel in L=
2
> level.
> Both of those will act as a backup plan as there is no such specific =
flow as
> default.

In these cases, we should find a way to adjust the MTU, preferably
automatically using virtio.
