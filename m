From: jamal <hadi@cyberus.ca>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: 09 Mar 2005 14:40:31 -0500
Message-ID: <1110397231.1078.143.camel@jzny.localdomain>
References: <B8561865DB141248943E2376D0E85215FFE21C@DHOST001-17.DEX001.intermedia.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>, Martin Mares <mj@ucw.cz>,
        Zdenek Radouch <zdenek@rcn.com>, Eran Mann <emann@mrv.com>,
        Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <B8561865DB141248943E2376D0E85215FFE21C@DHOST001-17.DEX001.intermedia.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-09 at 12:33, Steve Iribarne wrote:
> -> Your blades --> VLANX/SubnetX
> ->      --> [some L3 switch]
> 
> umm.. I have a L2 switch... not L3 switch.
> 

Lets go over this slowly so we can hopefully resolve why we dont see eye
to eye. I am not sure why i am spending all this energy on this.

Lets get the diagrams better:

1) your case:
    Your blades <--> VLANX/SubnetX
      <--> [some L2 switch]
           <--> VLANY/SubnetY <--> outside world

You probably have redundancy etc in some ATCA||2.16 setup with links going to 
two internal switches - but lets also ignore that - just assume the simple 
switch for now for sake of clarity. You may also have many VLANs in/out  like you 
said "signaling traffic, bearer traffic  and network mgmt traffic", but the 
two internal vs external interfaces  i showed above should suffice to indicate 
the general picture. Agreed?

To sumarize, for you to get to/from the outside world to your blades you go 
via L2 switch with a "few" interfaces to the ouside world.
In your case the "internal" interface is the VLANX port(s) facing the switch.
The "external" interface is the port(s) on VLANY facing the outside.

2) Note this is slightly different from Zdenek, which is:

  Outside <->one or more interfaces <->  [LinecardX] <-->[swicth/fabric]
  Outside <->one or more interfaces <->  [LinecardY] <-->[swicth/fabric]   
  .
  .

In other words each line card  has many interfaces that come into the box. 
It is not unusual to find 12-48 interface line cards.  The "switch" aka "fabric"  
connects these line cards (and perhaps some  control plane blade(s)). Typically such 
a switch will not run IP but rather some other internal thing like CSIX or SPI-x etc.

In both setups, if you do run IP internally, it does make sense not "leak" internal 
traffic to the outside world with such addresses. 
In both cases you both try hard (and i am sure succeed) to not leak those packets 
out - In your case its a simple separation of collision domains. The only way you can
get from internal to external is if infact you have L2 connectivity between the two
(since you said you dont have L3 switching in your chasis). 

By making the 127.x routable in linux of all places - which is where i started 
disagreeing, you introduce some challenges with hope that 127.x obscurity is
going to help.

To avoid confusion and have Zdenek respond when i am talking to you or viceversa
lets make the two as separate issues:

1) In your case i saw no reason for you to use 127.x - you could have achieved the 
same with 10.x. Your internal packets will never leak out. You say you will have collisions
with customer; but then if i understood correctly you said these internal packets never 
the box.  So my conclusion was you didnt need the hack.

2)Zdenek's case 

Just avoiding the leak is not good enough if the 127.x is routable and someone else
is using it and he has to route such packets. In such a case, even if Zdenek  hides 
the internal network at some point  he will have to route a  packet coming into 
linecardX, port A to linecardY, port B. 
And for this reason he cant totaly avoid collision. This is why i called it survival 
via obscurity.

Note: I am not questioning his technique but i would never use it
myself. Lets say we can achieve the same goal in a different way.

> Again, if you can show me a way of doing this, I'm all ears, but so far,
> you haven't shown me any other way around it.  Believe me.  I've tried
> and tried to find another solution to this problem.  
> 

Lets talk about this when we are clear what the problem is. Fix up the
diagram above if it is wrong, then we can talk.

cheers,
jamal
