From: Christian Borntraeger <cborntra@de.ibm.com>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Wed, 19 Jan 2005 21:52:23 +0100
Message-ID: <200501192152.23865.cborntra@de.ibm.com>
References: <20050116115431.GA13617@lst.de> <200501181653.59041.christian@borntraeger.net> <1106142567.1049.970.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>,
        pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106142567.1049.970.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
[...]
> > > Can you provision multiple of these cards per VM? if yes, is there
> > > some ID that will break it down to OSInstance:cardid?
>
> You did not answer this question.
> Let me draw a diagram to show what i think the hierachy is:
>
>   Physical Card: MAC address X
>
>
>      +--- OSInstance A
>
>      |        +-- "CARD" with IP A
>      |        +-- "CARD" with IP B
>      |        +-- "CARD" with IP C
>      |        +-- "CARD" with IP D
>
>      .
>      .
>      .
>
>      +--- OSInstance N
>
>               +-- "CARD" with IP Z
>
>
> Is the above reflective of what happens?

No. Its in the simplest case a one level hierarchy, but always outside 
Linux. 
Just for demonstration purposes, just IMAGINE, that a cards has only one 
device address (devno):

-----net-------\
               ||
            |hardware          |
            \------------------/
             |  | | | | |     | 
  /--devno---/  | | | | |     |
  |             | . . . .     |
  |             |             |
Linux1       Linux2  ....... Linuxn

> In other words, packet comes from the wire (with MAC address X); somehow
> the hypervisor(?) or firmware figures based on IP address A (assuming no
> other instance has that IP) it has to send packet to OSInstanceA.

Right. Basically, the card has a table:
DEVNO  | IP address | ROUTER?
0-ffff | ....       | primary, secondary 

If then a packet arrives it has an IP address.
The card looks this address up in this table:

   |
   |
   V
is it registered             ----yes----> forward to the device number
   |
   |
   V
is there a primary router?   ----yes----> forward to device number of the
   |                                      the primary router
   |
   |
   V
is there a secondary router? ----yes----> forward to device number of the
   |                                      the secondary router
   |
   V
drop packet. 

> OSInstanceA then selects further the CARD based on something probably in
> a descriptor?

No. The packet arrives on one "CARD" and Linux gets an "interrupt" and 
fetches the packet from that card.  You can of course have more cards per 
linux by providing more device numbers in the profile of the virtual 
machine. But that makes no sense unless you do some testing or the guest 
operating system is a hypervisor itself and can dispatch the device 
addresses to its virtual machines. 

>
> Let me get to the point:
> I think it would make sense for the "CARD" to be just another netdevice
> (call it "card" netdevice for this discussion).
> The representation of the physical card in the OSInstance is also a
> netdevice(call it physical netdevice for this discussion) as it is now
> (excpet it has no IP address ever).
> The "card netdevices" are stacked on top of the physical netdevice. This
> would be like an upside down bridge stacking relationship of
> netdevices....
> It actually is no different from a few tunnel netdevices that sit on top
> of say eth0 or multiple PPP devices on top of ethx in a PPPOE
> relationship.
> The demuxing for incoming packets is done at physical card netdevice
> to select the "card" netdevice whose receive method is then called.
> Reverse direction for transmit (we could go into details later, just
> wanna make sure this is sensible to begin with).

If I understood you right, you think that Linux has any control of the real 
hardware device and the card itself is created in the qeth linux driver as 
some obscure thing.  
No, for Linux the device backed by the 3 device addresses is as real as you 
and me. The qeth driver calls alloc_etherdev for the device represented by 
the 3 device addresses and, therefore, creating a netdevice for this card. 
Thats all we have. A card that only speaks IPv4 and IPv6 with us and that 
handles ARP for magically. To make it worse, the card only cooperates if we 
tell the card, which IP addresses we want to use. (by the way, the card 
recognizes duplicates)


> Does this sound reasonable? If yes, then if you do this you wont need to
> hack anything like IPV6 etc in your driver - they become merely
> netdevices. It should also allow for all standard features like ifconfig
> up/down etc of the "card" and setting IP addresses, VLANS etc to work as
> is. And you wont need to put any speacilized code in the driver.
> If its off tangent, then i just wasted 1/2 a cup of coffee energy typing
> away ;->

Well, I think  you havent been fully aware of the way the card works. I hope 
my explanation above makes it clearer. 
In one sentence: our Linux qeth "CARDS" _are_ already netdevices. (We are 
speaking about struct net_device, right?)

Furthermore, as long as there is only one MAC address we need one hack for 
IPv6, and Christophs version looks very nice and elegant. 

>
> > Right, without registering the IP address, you can not receive any
> > packet.
>
> If this is firmware issue, it would be wise to fix it. You should be
> able to register multiple MAC addresses hidden in the firmware (not at
> the Linux level) and have your "cards" netdevice use them. i.e the
> "card" netdevices would own those.

Well,newer cards support something like this (see the hardware announcement) 
http://www-306.ibm.com/common/ssi/fcgi-bin/ssialias?infotype=an&subtype=ca&supplier=897&appname=IBMLinkRedirect&letternum=ENUS104-346
) its called Layer 2 support. Unfortunately this feature is only available 
on a subset of cards and newer zSeries machines.

Just for explanation, there is a good reason that you only see the packets 
for your IP address: scalability of virtualization. Imagine you have a 
gigabit card shared among 80 Linuxes (quite realistic numbers). If you dont 
filter early, you have to forward all traffic to every guest system (which 
then can discard unneeded packages).  Then you have to provide an internal 
bandwith of 80 Gbit/sec. Not a good idea. Therefore you have to multiplex 
very very early and cannot set every Linux in promiscous mode for 
performance reasons. 

Furthermore, it is not that easy to change the way the card works. There are 
other operating systems like z/OS z/VSE or z/VM running on the same 
hardware. You dont hastily change the behaviour of hardware, firmware and 
operating systems which runs in lots of banks and insurance companies with 
99.999% availability without making sure that everything works flawlessly. 


> > As the logical network interface has no own MAC address you actually
> > speak IP to the card. That also means, that without some additional
> > effort, tools like tcpdump fail and you need some patches in the dhcp
> > tools.
>
> Refer to above. If you actually have your virtual/"card" netdevice on
> top of the physical netdevice have a MAC address, then all tools should
> work as is with zero changes IMO.

Right. Buts that just not the way the hardware works. 

Pick almost any random linux driver to see ugly code to cicumvent a hardware 
limitation. Have a look at the amount of traps in the kernel to fix cpu 
"errata". There is no perfect hardware. 

> > You can define options for routers to get more than your own packages,
> > but IIRC you can only define a primary and secondary router per port.
>
> Ok, this is new information - what does a "router" mean in relation to a
> port?

see above. You can have one primary and one secondary router. 

I hope that helps to understand the problem. If not, please dont hesitate to 
ask. 

Christian
