From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH RFC 2/3] dsa: Add support for multiple cpu ports.
Date: Sun, 31 May 2015 03:05:36 +0300
Message-ID: <CAHNKnsQamP++m2nu51oUAgk7vpEToaKM2unv8aePA=etc=Pdxg@mail.gmail.com>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
 <1432926814-22648-3-git-send-email-andrew@lunn.ch> <871thyfer0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:35219 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbbEaAF5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 20:05:57 -0400
Received: by yken206 with SMTP id n206so33486080yke.2
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 17:05:56 -0700 (PDT)
In-Reply-To: <871thyfer0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-30 15:09 GMT+03:00 Bj=C3=B8rn Mork <bjorn@mork.no>:
> Andrew Lunn <andrew@lunn.ch> writes:
>
>> Some boards have two CPU interfaces connected to the switch, e.g. Wi=
=46i
>> access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, a=
nd
>> two port connected to the SoC.
>>
>> This patch extends DSA to allows both CPU ports to be used. The "cpu=
"
>> node in the DSA tree can now have a phandle to the host interface it
>> connects to. Each user port can have a phandle to a cpu port which
>> should be used for traffic between the port and the CPU. Thus simple
>> load sharing over the two CPU ports can be achieved.
>>
>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>> ---
>>  Documentation/devicetree/bindings/net/dsa/dsa.txt |  66 +++++++++++=
+-
>>  drivers/net/dsa/mv88e6xxx.c                       |   8 +-
>>  include/net/dsa.h                                 |  28 +++++-
>>  net/dsa/dsa.c                                     | 109 +++++++++++=
+++++++----
>>  net/dsa/dsa_priv.h                                |   6 ++
>>  net/dsa/slave.c                                   |  10 +-
>>  net/dsa/tag_brcm.c                                |   2 +-
>>  net/dsa/tag_dsa.c                                 |   2 +-
>>  net/dsa/tag_edsa.c                                |   2 +-
>>  net/dsa/tag_trailer.c                             |   2 +-
>>  10 files changed, 206 insertions(+), 29 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Doc=
umentation/devicetree/bindings/net/dsa/dsa.txt
>> index f0b4cd72411d..34f7f18026e5 100644
>> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
>> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
>> @@ -58,13 +58,24 @@ Optionnal property:
>>                         Documentation/devicetree/bindings/net/ethern=
et.txt
>>                         for details.
>>
>> +- ethernet           : Optional for "cpu" ports. A phandle to an et=
hernet
>> +                          device which will be used by this CPU por=
t for
>> +                       passing packets to/from the host. If not pre=
sent,
>> +                       the port will use the "dsa,ethernet" propert=
y
>> +                       defined above.
>> +
>> +- cpu                        : Option for non "cpu"/"dsa" ports. A =
phandle to a
>> +                       "cpu" port, which will be used for passing p=
ackets
>> +                       from this port to the host. If not present, =
the first
>> +                       "cpu" port will be used.
>> +
>

=46orgive me my intrusion. Maybe I could answer to some of your questio=
ns.

> I'm in deep water here, but this scheme sounds a little too static to=
 me
> if I understand your proposal correctly.  Why would you want to creat=
e a
> static mapping of CPU ports to external ports for any given device?

Vendor already assumes that this mapping is static and DT just
describes this assumption. Single switch chip with two ports connected
to CPU on such devices is cheaper than switch chip + dedicated phy
chip. In other words, one of the switch ports just used as independent
phy and Andrew's patch gives an ability to perfectly describe such
situation.

> To me, that's part of the switch VLAN configuration.
>
AFAIK DSA is designed to allow L3 routing between ports as opposed to
switching and VLANs at L2.
DSA facilitates work of hardware designer by providing more
configurable chips. If so then interconnection tasks should be
resolved by kernel in "plug-and-play" manner, just as kernel assigns
memory regions to PCI devices :)

> My experience with these devices is limited to running OpenWRT on an
> WRT1900AC, having a Marvell 88E6172 switch.  And using the OpenWRT
> switch API of course. There I've found it very useful to be able to m=
ix
> and match the two CPU ports as I like with the external ports. How yo=
u
> want the CPU ports used is not as much depeing on device properties a=
s
> on your network configuration, IMHO.  How many and which links do you
> have?  What bandwith are they? Trunks or not?  Etc.  You cannot descr=
ibe
> these answers as device properties, because they aren't.
>
Nobody forbids to run custom kernel with custom DT in case of custom se=
tup :)

> You can currently configure this as you like in OpenWRT using their
> usual swconfig tool.  The CPU ports are added or removed from VLANs l=
ike
> any other port on the switch, and that feels very natural for me as a=
n
> end user.  The only distinction necessary to know, is your 'ethernet'
> property above:  Which host device is this switch port connected to.
>
> So I wonder: Do you plan to put all of the switch config into DT?  Wh=
ere
> does that stop? How about trunking between external ports and CPU por=
ts?
> Will every VLAN in the trunk have to go into DT too?
>
IMHO VLANs shouldn't be described by DT. VLANs is part of network
configuration and should be configured by end user, if he needs them.
In the same time, DSA configuration is part of hw configuration and
that's why it placed in DT.

In any case, Andrew as an author could give a better explanation. So
let's wait for his answer.

--=20
Sergey
