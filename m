From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 13:57:06 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFE2AF@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Henrik Nordstrom" <hno@marasystems.com>, "Martin Mares" <mj@ucw.cz>,
        "Zdenek Radouch" <zdenek@rcn.com>, "Eran Mann" <emann@mrv.com>,
        "Thomas Graf" <tgraf@suug.ch>, "Andi Kleen" <ak@muc.de>,
        <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's not the routing of the packet that gets screwed up.  It's the
applications that my "intra" communication use.  

I do this...

I have a redundant system.  So two Ethernet switches that go to either a
switch/hubbed/routed network.  Not controlled by me, but by my
customers.

So you have duplicate three wire coming into both ends of my chassis.

------ net 1 --------|                   | ---- net 1 ----
                     |                   | 
------- net 2 -------|  Chassis 21 slots | ----- net 2 ----
                     |                   |
------- net 3 -------|                   | ---- net 3 ----


all three of those "outside" nets get to me by either a bridge, router
or hub.

My 19 boards internal need to talk to each other ALONG with talking to
the outside world.

Boards in slot 1/21 are the switches.
so boards 2-20 are my linux blades that talk to each other.

The switch is configured to have the VLANS.  Management traffic I tag on
a VLAN.  So when my host controller or any of the other linux blades
need to do host communication, they talk to ip address 127.100.xx.xx
which is associated with a VLAN tagged interface.

Traffic being sent to the outside world is tagged as it comes in from
the outside world (so I know where it came from), and sent to the proper
board.  
L2 switching stuff.

Traffic that I send back out to the outside world is tagged when it
leaves one of my blades so the switch knows which port to send it back
out on.  (net 1, net 2 or net 3)


Ok.. that being said...

The _only_ way I can have normal applications (ie. ping, telnet, nfs) to
work and _guarantee_ not intra communication problems is if I use the
127.xx net.  

I'm not sure what you are not getting.  I'm not talking about basic
routing.  I'm talking about getting applications not to collide.

Let me give you and example.

If I were to use the 10.100.xx.xx network for example.  I have an snmp
master-agent/sub-agent configuration.  So I have a host controller with
the 10.100.0.1 address and my subagents are 10.100.0.<slotnum>

Everything works great, everyone is happy, until someone from the
outside world (say net 2) tries to telnet to me with a host address of
say 10.100.0.73.  Well, my host controller will route that packet onto
my private network.  So when I go to respond to the telnet request I
will tag it for my internal network because that is what the FIB routing
tells it to do.

There it is.  I'm not going to spend anymore time on this, and neither
should you.  Like I said, I've been doing this for a darn long time, and
I have, as yet, to see anyone who can make this problem just work.
Other than the way I did it.  (I along with many others)

have a happy day.

-stv
 

-> -----Original Message-----
-> From: jamal [mailto:hadi@cyberus.ca]
-> Sent: Wednesday, March 09, 2005 11:41 AM
-> To: Steve Iribarne
-> Cc: Henrik Nordstrom; Martin Mares; Zdenek Radouch; Eran Mann; Thomas
-> Graf; Andi Kleen; netdev@oss.sgi.com; linux-net@vger.kernel.org
-> Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
-> 
-> On Wed, 2005-03-09 at 12:33, Steve Iribarne wrote:
-> > -> Your blades --> VLANX/SubnetX
-> > ->      --> [some L3 switch]
-> >
-> > umm.. I have a L2 switch... not L3 switch.
-> >
-> 
-> Lets go over this slowly so we can hopefully resolve why we dont see
eye
-> to eye. I am not sure why i am spending all this energy on this.
-> 
-> Lets get the diagrams better:
-> 
-> 1) your case:
->     Your blades <--> VLANX/SubnetX
->       <--> [some L2 switch]
->            <--> VLANY/SubnetY <--> outside world
-> 
-> You probably have redundancy etc in some ATCA||2.16 setup with links
-> going to
-> two internal switches - but lets also ignore that - just assume the
-> simple
-> switch for now for sake of clarity. You may also have many VLANs
in/out
-> like you
-> said "signaling traffic, bearer traffic  and network mgmt traffic",
but
-> the
-> two internal vs external interfaces  i showed above should suffice to
-> indicate
-> the general picture. Agreed?
-> 
-> To sumarize, for you to get to/from the outside world to your blades
you
-> go
-> via L2 switch with a "few" interfaces to the ouside world.
-> In your case the "internal" interface is the VLANX port(s) facing the
-> switch.
-> The "external" interface is the port(s) on VLANY facing the outside.
-> 
-> 2) Note this is slightly different from Zdenek, which is:
-> 
->   Outside <->one or more interfaces <->  [LinecardX]
<-->[swicth/fabric]
->   Outside <->one or more interfaces <->  [LinecardY]
<-->[swicth/fabric]
->   .
->   .
-> 
-> In other words each line card  has many interfaces that come into the
-> box.
-> It is not unusual to find 12-48 interface line cards.  The "switch"
aka
-> "fabric"
-> connects these line cards (and perhaps some  control plane blade(s)).
-> Typically such
-> a switch will not run IP but rather some other internal thing like
CSIX
-> or SPI-x etc.
-> 
-> In both setups, if you do run IP internally, it does make sense not
-> "leak" internal
-> traffic to the outside world with such addresses.
-> In both cases you both try hard (and i am sure succeed) to not leak
those
-> packets
-> out - In your case its a simple separation of collision domains. The
only
-> way you can
-> get from internal to external is if infact you have L2 connectivity
-> between the two
-> (since you said you dont have L3 switching in your chasis).
-> 
-> By making the 127.x routable in linux of all places - which is where
i
-> started
-> disagreeing, you introduce some challenges with hope that 127.x
obscurity
-> is
-> going to help.
-> 
-> To avoid confusion and have Zdenek respond when i am talking to you
or
-> viceversa
-> lets make the two as separate issues:
-> 
-> 1) In your case i saw no reason for you to use 127.x - you could have
-> achieved the
-> same with 10.x. Your internal packets will never leak out. You say
you
-> will have collisions
-> with customer; but then if i understood correctly you said these
internal
-> packets never
-> the box.  So my conclusion was you didnt need the hack.
-> 
-> 2)Zdenek's case
-> 
-> Just avoiding the leak is not good enough if the 127.x is routable
and
-> someone else
-> is using it and he has to route such packets. In such a case, even if
-> Zdenek  hides
-> the internal network at some point  he will have to route a  packet
-> coming into
-> linecardX, port A to linecardY, port B.
-> And for this reason he cant totaly avoid collision. This is why i
called
-> it survival
-> via obscurity.
-> 
-> Note: I am not questioning his technique but i would never use it
-> myself. Lets say we can achieve the same goal in a different way.
-> 
-> > Again, if you can show me a way of doing this, I'm all ears, but so
-> far,
-> > you haven't shown me any other way around it.  Believe me.  I've
tried
-> > and tried to find another solution to this problem.
-> >
-> 
-> Lets talk about this when we are clear what the problem is. Fix up
the
-> diagram above if it is wrong, then we can talk.
-> 
-> cheers,
-> jamal
