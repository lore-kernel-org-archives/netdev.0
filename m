From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 07:01:34 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFE1C8@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Martin Mares" <mj@ucw.cz>, "Zdenek Radouch" <zdenek@rcn.com>,
	"Eran Mann" <emann@mrv.com>, "Thomas Graf" <tgraf@suug.ch>,
	"Andi Kleen" <ak@muc.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>, "Henrik Nordstrom" <hno@marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First off, apologies for the all the cc's on this.  I hate doing it, but
I will only do it for this post!

-> 1) Addresses for intra-chasis communication.
-> The addresses used by the blades are intrachasis relevant only and
the
-> packets never leave the box. The blades are interconnected via some
-> L2/VLAN/bridge within the chasis.
-> 

Big assumption here.  The VLAN/Bridge/Router that I have in my chassis
is hooked up to a switch.  The switch will NOT send the packets on my
mgmt VLAN out over the network.  

(see below for more details on this.. in the "what am I missing" section
)


-> Conclusion:
-> If these packets never leave the box - no ARP will ever see them and
no
-> dynamic routing protocol will ever advertise them - therefore no IP
-> address collision. You can use _whatever_ address you want, private
-> public, IBMs, intels etc. Do we agree on this? In other words hack
not
-> needed here.

Wrong.  Packets need to leave each blade.  You cannot treat the blades
as a private entity.  You must ARP to find out the other blades MAC
address.

-> 
-> 2) The addresses for chasis-outside world communication. You have one
or
-> more dedicated gateways to connect between the outside of the chasis
to
-> inside.
-> There are many tricks you could use to somehow get the packets
to/from
-> the internal blades: NAT, forward, have aliases inside the chasis
which
-> get forwarded etc. Lets not discuss about how the the packets finaly
-> make it outside, rather just assume these packets make it outside the
-> chasis then lets explore using either 127.x or RFC1918 addresses.
-> 
-> a) using private addresses implies possibility of conflict of
addresses
-> within customer's  network. To quote Zdenek:
-> You couldn't walk in the NOC and tell them: "You can't use the 10.x
-> net to manage your equipment - my box is already using that net".
-> Conclusion:
-> You walk into the NOC and say "can i use 10.0.0.x/22 subnet" they say
"no
-> thats going to collide use 10.0.0.0/28"
-> Summary: You may need to go to your box and reconfigure its external
-> looking
-> addresses.
-> 

I _use_ to do exactly what you stated above.  When RFC 1918 first came
out I used the 10 net.  

1st bug:  Customer had the same 10.100.xx.xx/24 net that I had and my
inter-system communication wouldn't work, because all my routes got
screwed up.  (i.e the SNMP sub-agents couldn't talk with the master). 

1st response to bug:  Well can you use another network address range?
Customer response:  Hell no.

Solution to bug1:  Easy, let the user configure the mgmt network ip
address.
Customers answer to bug1 solution:  Get the hell out of here; you don't
do out-of-band mgmt.  Do you know what a security risk this is for me?
Blah blah blah....  Even though all inter-chassis communication was done
securely, I couldn't convince them. I had a customer boot me out of his
office and boot our company out **because** of my design.  Not a good
feeling.


-> a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet"
-> they say either "sorry, our routers cant route 127.x" or "no Zdenek
-> was here before you, thats going to collide use 127.0.0.0/28"
-> 

This is __EXACTLY__ the behavior we want.  I want routers to drop those
packets.  My inter-chassis communication better NOT go through a router.

-> So tell me what i am missing!
-> 

Experience.  You are missing a big key factor.  The routing part of what
you are saying is sound.  The big thing you are not getting is how the
"applications", telnet, snmp, ssh, Linux-HA, etc.. will interact with
your system.  You do NOT want to rewrite those applications to have some
knowledge of your system.  They want to connect to an IP address and
that better work (off-the-shelf).  

Therefore,

As a kernel programmer, it's easier for me to make sure the 127.xx net
works and sends the 127.xx packets to the proper network.

In conclusion:

It seems that Zdenek and I have been down this road _many_ times.  I
have shipped over 10 different routers/chassis systems.  I speak from
experience and experience alone.  I don't claim to be the smartest
person in the world, but I know what works.

This post started with a simple question of "can I do this".  The answer
I believe has been posted a long time ago.  I am not about to change the
way that I do my inter-chassis communications until the IEEE or RFC
community give me an address change for inter-chassis communication.
(which I believe is coming down the road).

And would you please subscribe to the list so I don't have the cc the
world every time?

Thanks.

-stv

