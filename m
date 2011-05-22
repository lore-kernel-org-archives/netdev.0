From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 11:53:10 +0200
Message-ID: <4DD8DD06.6070202@gmail.com>
References: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com> <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com> <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion> <m17h9jp7js.fsf@fess.ebiederm.org> <4DD8CA87.8040905@gmail.com> <BANLkTi=B4c-A9ZC2apE+ZOQmgdzaJb0oEQ@mail.gmail.com> <4DD8D2FE.4080204@gmail.com> <BANLkTimQ6LAWbZMCjBhqA5By8jvxwnfjVg@mail.gmail.com> <20110522093614.GB2611@jirka.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43238 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1EVJxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 05:53:14 -0400
Received: by wya21 with SMTP id 21so3583581wya.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 02:53:12 -0700 (PDT)
In-Reply-To: <20110522093614.GB2611@jirka.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/2011 11:36, Jiri Pirko a =C3=A9crit :
> Sun, May 22, 2011 at 11:20:09AM CEST, mirqus@gmail.com wrote:
>> W dniu 22 maja 2011 11:10 u=C5=BCytkownik Nicolas de Peslo=C3=BCan
>> <nicolas.2p.debian@gmail.com>  napisa=C5=82:
>>> Le 22/05/2011 10:52, Micha=C5=82 Miros=C5=82aw a =C3=A9crit :
>>>>
>>>> 2011/5/22 Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>:
>>>>>
>>>>> Le 22/05/2011 08:34, Eric W. Biederman a =C3=A9crit :
>>>>>>
>>>>>> Jiri Pirko<jpirko@redhat.com>      writes:
>>>>>>
>>>>>>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.c=
om
>>>>>>> wrote:
>>>>>>>
>>>>>>> <snip>
>>>>>>>>
>>>>>>>> And because some setups may still require the skb not to be un=
tagged,
>>>>>>>> may be we need the ability to re-tag the skb in some situation=
s...
>>>>>>>> When a protocol handler or rx_handler is explicitly registered=
 on a
>>>>>>>> net_device which expect to receive tagged skb, we should deliv=
er
>>>>>>>> tagged skb to it... Arguably, this may sound incredible for th=
e
>>>>>>>> general case, but may be required for not-so-special cases lik=
e
>>>>>>>> bridge or protocol analyzer.
>>>>>>>
>>>>>>> Wait, what setups/code require the skb not to be untagged? If t=
here's
>>>>>>> such, it should be fixed.
>>>>>>
>>>>>> tcpdump on the non-vlan interface for one.
>>>>>
>>>>> bridge is another. More precisely, there is a difference between =
the
>>>>> following two setups:
>>>>>
>>>>> 1/ eth0 - eth0.100 - br0 - eth1.200 - eth1
>>>>>
>>>>> 2/ eth0 - br0 - eth1
>>>>>
>>>>> In case 1, it is normal and desirable for the bridge to see untag=
ged skb.
>>>>>
>>>>> In case 2, it is desirable for the bridge to see untouched (possi=
bly
>>>>> tagged)
>>>>> skb. If current bridge implementation is able to handle skb from =
which we
>>>>> removed a tag, in this situation, it means that bridge currently =
"fix
>>>>> improper untagging" by itself, by forcing re-tagging on output. I=
 think
>>>>> is
>>>>> should not be the job of protocol handlers to fix this. Again, a =
generic
>>>>> feature should to it when necessary.
>>>>>
>>>>> Think of the following setups:
>>>>>
>>>>> 3/ eth0 - br0 - eth1.200 - eth1.
>>>>> 4/ eth0 - eth0.100 - br0 - eth1
>>>>>
>>>>> What if one expect this setup to add (3) or remove (4) one level =
of vlan
>>>>> nesting? This is precisely what this setup suggest. How can we in=
struct
>>>>> the
>>>>> bridge to do so? It is not the bridge responsibility to do any vl=
an
>>>>> processing. bridge is expected to... bridge !
>>>>
>>>> I assumed that this untaging Jiri is implementing does not remove =
the
>>>> tag. It moves the information from skb->data to skb->vlan_tci, but=
 the
>>>> information contained is not otherwise changing. All your examples
>>>> should work regardless of where the tag is stored.
>>>
>>> I assumed (but didn't tested) that this untagging also change the s=
tarting
>>> point of the payload of the packet. So protocol handlers expecting =
to have
>>> the raw packet won't see the vlan header.
>>
>> That would also be the case with hardware stripped tags - they need =
to
>> look into skb->vlan_tci anyway.
>
> Exactly. Nicolas, I do not see anything wrong on always untagging in =
all
> your setups. As Michal said, vlan_tci keeps the info.

I understand this.

But I don't understand how the bridge code is expected to know whether =
it should re-tag the packet=20
or not before forwarding and which value to use as the egress vlan tag.

1/ eth0 - br0 - eth1 : the bridge is expected to retag using skb->vlan_=
tci value.

2/ eth0 - eth0.100 - br0 - eth1.200 - eth1 : the bridge is expected to =
retag using a different value=20
than skb->vlan_tci.

3/ eth0 - eth0.100 - br0 - eth1 : the bridge is expected not to re-tag,=
 because the expected=20
behavior of this setup is to untag while crossing the bridge.

4/ eth0 - eth0.100 - eth0.100.300 - br0 - eth1.400 - eth1.200 - eth1 : =
the bridge is expected to=20
retag using a different value than skb->vlan_tci. What value would skb-=
>vlan_tci hold when the skb=20
will be delivered to the bridge? 100 or 300?

 From my point of view, in both setup, the bridge will receive a single=
 value in skb->vlan_tci and=20
will lack any other indication to help it decide how to retag when forw=
arding.

I'm not against your idea to mimic hw-accel in software. But I'm concer=
n about troubles for those=20
who expect to have access to untouched packet. Your patch didn't cause =
those troubles to start=20
happening, but cause them to always happen. Before your patch, someone =
had the option to use=20
non-hw-accel NIC or to disable hw-accel feature if possible. Now, it's =
no more possible.

	Nicolas.
