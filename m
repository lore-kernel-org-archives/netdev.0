From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 7 Jan 2015 12:52:55 -0800
Message-ID: <CAEP_g=8EBeQUFkRRsG3sznYryd+LE9qJKWQXfS==HG2HDO=UKA@mail.gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
 <54AA2912.6090903@gmail.com> <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
 <54ABAC13.9070402@gmail.com> <CAEP_g=8bCR=PeSoi09jLWLtNUrxhzx45h1Wm=9D=R57AqUac2w@mail.gmail.com>
 <54ACCAFD.4070203@gmail.com>
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
Received: from na6sys009bog026.obsmtp.com ([74.125.150.92]:57825 "HELO
	na6sys009bog026.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755092AbbAGUxQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 15:53:16 -0500
Received: by mail-qa0-f41.google.com with SMTP id s7so4435889qap.0
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 12:53:15 -0800 (PST)
In-Reply-To: <54ACCAFD.4070203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 9:58 PM, Fan Du <fengyuleidian0615@gmail.com> wr=
ote:
> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8807=E6=97=A5 03:11, Jesse Gross =E5=86=
=99=E9=81=93:
>>>>
>>>> One of the reasons for only doing path MTU discovery
>>>> >>for L3 is that it operates seamlessly as part of normal operatio=
n -
>>>> >>there is no need to forge addresses or potentially generate ICMP=
 when
>>>> >>on an L2 network. However, this ignores the IP handling that is =
going
>>>> >>on (note that in OVS it is possible for L3 to be implemented as =
a set
>>>> >>of flows coming from a controller).
>>>> >>
>>>> >>It also should not be VXLAN specific or duplicate VXLAN encapsul=
ation
>>>> >>code. As this is happening before encapsulation, the generated I=
CMP
>>>> >>does not need to be encapsulated either if it is created in the =
right
>>>> >>location.
>>>
>>> >
>>> >Yes, I agree. GRE share the same issue from the code flow.
>>> >Pushing back ICMP msg back without encapsulation without circulati=
ng
>>> > down
>>> >to physical device is possible. The "right location" as far as I k=
now
>>> >could only be in ovs_vport_send. In addition this probably require=
s
>>> > wrapper
>>> >route looking up operation for GRE/VXLAN, after get the under laye=
r
>>> > device
>>> >MTU
>>> >from the routing information, then calculate reduced MTU becomes
>>> > feasible.
>>
>> As I said, it needs to be integrated into L3 processing. In OVS this
>> would mean adding some primitives to the kernel and then exposing th=
e
>> functionality upwards into userspace/controller.
>
>
> I'm bit of confused with "L3 processing" you mentioned here... SORRY
> Apparently I'm not seeing the whole picture as you pointed out. Could=
 you
> please
> elaborate "L3 processing" a bit more? docs/codes/or other useful link=
s.
> Appreciated.

L3 processing is anywhere that routing takes place - i.e. where you
would decrement the TTL and change the MAC addresses. Part of routing
is dealing with differing MTUs, so that needs to be integrated into
the same logic.

> My understanding is:
> controller sets the forwarding rules into kernel datapath, any flow n=
ot
> matching
> with the rules are threw to controller by upcall. Once the rule decis=
ion is
> made
> by controller, then, this flow packet is pushed down to datapath to b=
e
> forwarded
> again according to the new rule.
>
> So I'm not sure whether pushing the over-MTU-sized packet or pushing =
the
> forged ICMP
> without encapsulation to controller is required by current ovs
> implementation. By doing
> so, such over-MTU-sized packet is treated as a event for the controll=
er to
> be take
> care of.

If flows are implementing routing (again, they are doing things like
decrementing the TTL) then it is necessary for them to also handle
this situation using some potentially new primitives (like a size
check). Otherwise you end up with issues like the ones that I
mentioned above like needing to forge addresses because you don't know
what the correct ones are. If the flows aren't doing things to
implement routing, then you really have a flat L2 network and you
shouldn't be doing this type of behavior at all as I described in the
original plan.
