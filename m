From: jamal <hadi@cyberus.ca>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: 09 Mar 2005 11:00:01 -0500
Message-ID: <1110384000.1077.33.camel@jzny.localdomain>
References: <B8561865DB141248943E2376D0E85215FFE1C8@DHOST001-17.DEX001.intermedia.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>, Martin Mares <mj@ucw.cz>,
        Zdenek Radouch <zdenek@rcn.com>, Eran Mann <emann@mrv.com>,
        Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <B8561865DB141248943E2376D0E85215FFE1C8@DHOST001-17.DEX001.intermedia.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-09 at 10:01, Steve Iribarne wrote:
> First off, apologies for the all the cc's on this.  I hate doing it, but
> I will only do it for this post!
> 

I am not on linux-net - if you insist that i join just so i can see your
post then you are being unreasonable. I am not on Linux kernel either. 

Theres other reasons why multi CCs are useful. Sometimes the list never
echoes back the response - case in point my post this morning that was
responded to by Zdenek was not echoed upto this point on netdev - it may
show up sometime tonight.

> -> 1) Addresses for intra-chasis communication.
> -> The addresses used by the blades are intrachasis relevant only and
> the
> -> packets never leave the box. The blades are interconnected via some
> -> L2/VLAN/bridge within the chasis.
> -> 
> 
> Big assumption here.  The VLAN/Bridge/Router that I have in my chassis
> is hooked up to a switch.  The switch will NOT send the packets on my
> mgmt VLAN out over the network.  
> 
> (see below for more details on this.. in the "what am I missing" section
> )
> 

Your blades --> VLANX/SubnetX 
     --> [some L3 switch] 
             -->VLANY/SubnetY 
                    -->outside

The Blades discovery etc happens within the collision domain of VLANX. 
To go across from VLANX<->VLANY you may need either to L3 forward, NAT,
tunnel etc. If you do pure L3 forwarding then your blades addresses are
accessible outside. 
In other words all this is a config choice.
You may have more than one VLAN for management etc within your blades
but thats beside the point.

> 
> -> Conclusion:
> -> If these packets never leave the box - no ARP will ever see them and
> no
> -> dynamic routing protocol will ever advertise them - therefore no IP
> -> address collision. You can use _whatever_ address you want, private
> -> public, IBMs, intels etc. Do we agree on this? In other words hack
> not
> -> needed here.
> 
> Wrong.  Packets need to leave each blade.  You cannot treat the blades
> as a private entity.  You must ARP to find out the other blades MAC
> address.
> 

Read what i wrote again and cross reference with the diagram. ARP is
only L2 switched. It would be wise to configure the blade IP addresses
to be within the same subnet - in which case the only route you need on
your blades is a link scope one and perhaps a default GW pointing to
your L3 device.

> -> thats going to collide use 10.0.0.0/28"
> -> Summary: You may need to go to your box and reconfigure its external
> -> looking
> -> addresses.
> -> 
> 
> I _use_ to do exactly what you stated above.  When RFC 1918 first came
> out I used the 10 net.  

[..]

> Solution to bug1:  Easy, let the user configure the mgmt network ip
> address.
> Customers answer to bug1 solution:  Get the hell out of here; you don't
> do out-of-band mgmt.  Do you know what a security risk this is for me?
> Blah blah blah....  Even though all inter-chassis communication was done
> securely, I couldn't convince them. I had a customer boot me out of his
> office and boot our company out **because** of my design.  Not a good
> feeling.

A customer should be able to say, "heres an address you can use for
management". The rest of it is your problem really. There are no bugs,
but there are config issues.
 
> 
> -> a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet"
> -> they say either "sorry, our routers cant route 127.x" or "no Zdenek
> -> was here before you, thats going to collide use 127.0.0.0/28"
> -> 
> 
> This is __EXACTLY__ the behavior we want.  I want routers to drop those
> packets.  My inter-chassis communication better NOT go through a router.
> 

The interchassis does not go through a router at all (other than the one
in your chasis which may be used to do L3). Let me draw that diagram
again:

  Your blades --> VLANX/SubnetX 
     --> [some L3 switch] 
             -->VLANY/SubnetY 
                    -->outside

i.e the only way it would fo out is if you allowed it at the L3 switch
or NAT device etc.

So let me quote you above:

---
I _use_ to do exactly what you stated above.  When RFC 1918 first came
out I used the 10 net.  
---

Its just a matter of time before you say "oh, thats what i do now for
127.x". This is the point i have been trying to make all along.

> -> So tell me what i am missing!
> -> 
> 
> Experience.  

I think you are making some very big assumption ;-> Please dont go this
path unless you wish to end this thread.

Btw, i do believe what you and Zdenek are trying to solve are _very_
different problems. He is trying to build a distributed router of some
form; i.e his blades are infact line-cards where traffic comes in.
You on the other hand seem to have the blades doing computes (i.e they
are not router line cards). 

The point is this: Whatever you folks are doing, probably inherited from
some other projects more than likely using some other OS is not
necessary in Linux. I respect your desire to use those addresses if it
makes you comfortable - I just vehemently disagree it is needed.
So i hope you dont show up with the patch and ask for its inclusion.

cheers,
jamal
