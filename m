From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Wed, 25 Feb 2015 07:44:09 +0100
Message-ID: <CACna6rypRBT3JijOhYmz_0U_MBBN4LKsZnHdY1MrpYtxc9ZT0w@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:60860 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbbBYGoK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 01:44:10 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so3475899igd.3
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 22:44:09 -0800 (PST)
In-Reply-To: <54ED017E.6000902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 February 2015 at 23:55, Florian Fainelli <f.fainelli@gmail.com> w=
rote:
> On 24/02/15 14:50, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 24 February 2015 at 23:30, Andy Gospodarek <gospo@cumulusnetworks=
=2Ecom> wrote:
>>> I see there is an xmit function, but no napi registration at all.
>>>
>>> Is this simply because the SoC ethernet dev is doing all the frame =
rx?
>>> Is is able to demux the frames correctly, so it is clear which swXp=
Y
>>> received the frame?  That will be necessary to ensure that standard
>>> applications that want to open sockets directly on the needed inter=
faces
>>> can still function properly.
>>
>> If you take a look at b53_port_xmit you'll start understanding why
>> there is no NAPI ;)
>>
>> As said in the commit message, these switches are really simple
>> devices. We can't actually send packets to the particular ports
>> (unless something has changed in the more recent hardware).
>
> These switches all support Broadcom tags, so you could use your host =
CPU
> Ethernet MAC to send/receive packets to/from specific ports of the
> switch, and then this is just like DSA, but everything that you say
> below is true.

OK, I'll need to learn about Broadcom tags then. Right now this is a
bit unclear for me. Are Broadcom tags supposed to be used with VLANs
at the same time?

I can get idea of sending packets in such setup. We could send packets
using VLAN interface (with VLAN tag), packets would go to all ports
assigned to the VLAN. Or we should send packets using port interface
with adding Broadcom tag there. Such packets would target a single
port. Quite easy.

But how switch would handle receiving packets from ports? If we were
using Broadcom tags and VLANs at the same time, how switch would know
if the packets received on port N should get a VLAN tag (PVID) or
should get a Broadcom tag?


>> So if we want to get any packets from switch port N we have to:
>> 1) Assign some PVID to the port N
>> 2) Put port N and "CPU port" in the same VLAN (matching PVID)
>> 3) Starting with above switch will tag every packet received on port=
 N
>> and forward it to the "CPU port"
>> 4) Listen on the Ethernet device connected to the "CPU port" for
>> packets with a proper VLAN ID
>>
>> Now with the above example there are 2 most common scenarios you may
>> want to consider:
>>
>> 1) Having full control over every port
>> It requires assigning unique VLAN for every single port. Any switchi=
ng
>> (forwarding packets) has to be done in software then.
>>
>> 2) Having few groups of ports
>> This is the most common case for home routers. You usually want to
>> have group of "LAN" ports when you don't really care which port
>> provided a given packet. This also allows using switch for offloadin=
g
>> traffic between machines the same ports group.
>
> With that use case in mind, yes, your driver is doing exactly that,
> allowing you to define VLAN membership for particular ports within a
> group, all of this gets sent to the host CPU, where the IP routing ha=
ppens.

Not really. Let's say I setup VLAN N with 3 members:
1) Port A with PVID N & UNTAGGED
2) Port B with PVID N & UNTAGGED
3) CPU port
If machine connected to port A will start sending traffic to machine
connected to port B, switch will do all the work. CPU won't be
involved.

Just for sure I've tested above and I got 650 Mb/s iperf traffic with
99% idle BCM4706 CPU.

--=20
Rafa=C5=82
