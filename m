From: Frank Pavlic <PAVLIC@de.ibm.com>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Wed, 19 Jan 2005 22:32:32 +0100
Message-ID: <OF0E859D23.C429AEE7-ON41256F8E.006F7D15-41256F8E.00765607@de.ibm.com>
References: <1106142567.1049.970.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Christian =?ISO-8859-1?Q?Borntr=E4ger?= <christian@borntraeger.net>,
        "David S. Miller" <davem@davemloft.net>,
        Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, waldi@debian.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1106142567.1049.970.camel@jzny.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







Mit  freundlichen Gr=FCssen / Best regards
Frank Pavlic

Linux for eServer Development
Schoenaicher Str. 220, 71032 Boeblingen
Phone:  ext. +49-(0)7031/16-2463, int. *120-2463
mailto:   pavlic@de.ibm.com




jamal <hadi@cyberus.ca> wrote on 19.01.2005 14:49:28:

>
> On Tue, 2005-01-18 at 10:53, Christian Borntr=E4ger wrote:
> > Frank, please correct me, if I am wrong....
> >
> > jamal wrote:
> > > On Mon, 2005-01-17 at 18:37, Christian Borntr=E4ger wrote:
> > > > I am trying a small simplification here:
> > > > Each physical network adapter offers hundreds of device addresses.
You
> > > > need 3 of them to have one logical network
adapter(read,write,data).
> > >
> > > the "card" concept is what you call network adapter, correct?
> > > I take it that read and write are control channels and data is wher=
e
the
> > > skb comes through?
> >
> > don't ask me about naming....
>
> thats fine,
> I think it doesnt matter what they are used for; important part is
> you need all 3 addresses to have a "card"; so got it.
>
> >
> > > >  S/390 has
> > > > hardware supported virtualization. Therefore can then use the
> > > > hypervisor (LPAR or z/VM) to give specific LPARs or VM guests
exactly 3
> > > > device addresses out of these hundreds.
> > >
> > > Can you provision multiple of these cards per VM? if yes, is there
some
> > > ID that will break it down to OSInstance:cardid?
>
> You did not answer this question.
> Let me draw a diagram to show what i think the hierachy is:
>
>   Physical Card: MAC address X
>      |
>      |
>      +--- OSInstance A
>      |        |
>      |        +-- "CARD" with IP A
>      |        +-- "CARD" with IP B
>      |        +-- "CARD" with IP C
>      |        +-- "CARD" with IP D
>      .
>      .
>      .
>      |
>      +--- OSInstance N
>               |
>               +-- "CARD" with IP Z
>
>
> Is the above reflective of what happens?

> In other words, packet comes from the wire (with MAC address X); someho=
w
> the hypervisor(?) or firmware figures based on IP address A (assuming n=
o
> other instance has that IP) it has to send packet to OSInstanceA.
> OSInstanceA then selects further the CARD based on something probably i=
n
> a descriptor?




>
> Let me get to the point:
> I think it would make sense for the "CARD" to be just another netdevice
> (call it "card" netdevice for this discussion).
> The representation of the physical card in the OSInstance is also a
> netdevice(call it physical netdevice for this discussion) as it is now
> (excpet it has no IP address ever).
> The "card netdevices" are stacked on top of the physical netdevice. Thi=
s
> would be like an upside down bridge stacking relationship of
> netdevices....
Let me break your description here. The following two lines are an output
from /proc/qeth.
Issueing a cat /proc/qeth you will get all to this Linux system frank1
attached and configured devices :
0.0.f504/0.0.f505/0.0.f503   xB5   eth0       OSD_1000       0    sw
always_q_2 no   no   64k   16
0.0.f506/0.0.f507/0.0.f508  xB5   eth1       OSD_1000       0    sw
always_q_0 no   no   64k   16

This output shows you already that for every device triple we are
initializing and registering one struct net_device at the
Linux network stack.

But let me take these two lines for trying to explain you how this stuff =
is
working now ,means how packets make
their way from OSA to the network stack .
As you mentioned above an ethernet frame comes from the wire .
Reading the IP address OSA (firmware or not, I don't care :-) ) checks hi=
s
local address table
if an entry for this IP address is existing. Since we have to register th=
e
IP address for eth0 and eth1
OSA knows which read/write/data channel belongs to which IP address.
So if an entry is existing in OSA's table  firmware puts the packet witho=
ut
Ethernet Header on the corresponding
data device (it's too complicated to explain in short how it really works
but for this description it's ok ) and initiate
an interrupt on the same data device of course. Now the interrupt arrives
at qeth driver.
Out of the interrupt information which is passed to qeth interrupt handle=
r
we are able to determine on which
data device the packet has arrived and thus we know the struct net_device.
 qeth processes then the interrupt, some error checks,  allocating  skb a=
nd
put the appropriate members like protocol , pkt_type and so on and passes
the IP packet to the stack !
>From Linux frank1 point of view it has two pyhsical devices ,eth0 and eth=
1
,running . But the truth is
that both are sending packets out through the same physical built OSA car=
d
,but packets going out to eth0 have to
take another way through the huge machine,means different data channel,
than packets going out through eth1 .
What do you have to do on a x86  to be able to send packets out to the
world and of course receive it on different ways?
 well you have to put in two network cards on  your PCI bus ,motherboard
respectively ...
Maybe I can answer your questions from above now :
"CARD" IP address A is nothing else than eth0 (ok to be clear: struct
qeth_card is more correctly but in struct
qeth_card we have a struct net_device member ) with IP address A, CARD wi=
th
IP address B eth1 ,and so on ...

so packets for eth0 will come directly to "CARD" and so of course to
OSInstanceA but OSInstanceA does not make
any decisions at all ,the interrupt information passed to qeth driver is
clear enough .

> It actually is no different from a few tunnel netdevices that sit on to=
p
> of say eth0 or multiple PPP devices on top of ethx in a PPPOE
> relationship.

Yes it is different since you have for every device triple one struct
net_device registered at network stack.

The problem with IPv6 is that other Linux systems like frank2 ,frank3 ....
have also device triples configured (but different from
linux 1 e.g. f508,f509,f510 on frank2 , f512,f513,f514 on frank3 ,...)
which are also from the same OSA card as frank1 has already,
all struct net_device will all get the same MAC address (one MAC per
physical network card). generating an EUI64 address which is
the base for an automatically generated IPv6 address for ethernet hardwar=
e
all ethx on all the different frank systems will get
the same IPv6 address and the result is that IPv6 traffic will stall afte=
r
a few seconds ....


> The demuxing for incoming packets is done at physical card netdevice
> to select the "card" netdevice whose receive method is then called.
> Reverse direction for transmit (we could go into details later, just
> wanna make sure this is sensible to begin with).
> Does this sound reasonable? If yes, then if you do this you wont need t=
o
> hack anything like IPV6 etc in your driver - they become merely
> netdevices. It should also allow for all standard features like ifconfi=
g
> up/down etc of the "card" and setting IP addresses, VLANS etc to work a=
s
> is. And you wont need to put any speacilized code in the driver.
> If its off tangent, then i just wasted 1/2 a cup of coffee energy typin=
g
> away ;->

I'm sorry to hear this , I can make you some if you want ;-)

>
> > Right, without registering the IP address, you can not receive any
packet.
>
> If this is firmware issue, it would be wise to fix it. You should be
> able to register multiple MAC addresses hidden in the firmware (not at
> the Linux level) and have your "cards" netdevice use them. i.e the
> "card" netdevices would own those.
>
> > As the logical network interface has no own MAC address you actually
speak
> > IP to the card. That also means, that without some additional effort,
tools
> > like tcpdump fail and you need some patches in the dhcp tools.

CORRECT, tcpdump and dhcp has to be patched

I hope my description helps to get a better understanding of the IPv6
problem and how this
works ,if not just say no to save the another 1/2 cup of coffee ;-)
if you are interested to get more detailed information about OSA running =
in
Linux I can give you a link
to a documentation which describes this stuff pretty well !
