From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: controlling ARP Proxy scope?
Date: Wed, 06 Jul 2005 00:32:44 -0400
Message-ID: <3u3gb7$1npg80__38599.6658624665$1120625064$gmane$org@smtp05.mrf.mail.rcn.net>
References: <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net> <Pine.LNX.4.61.0507060405300.26027@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0507060405300.26027@filer.marasystems.com>
References: <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 04:20 AM 7/6/05 +0200, Henrik Nordstrom wrote:
>On Tue, 5 Jul 2005, Zdenek Radouch wrote:
>
>>> proxy_arp simply ARPs if there is a route for the requested destination
>>> going out on another interface than where the ARP was seen.
>>
>> In my case, the proxy replies to a request seen on the very same interface
>> to which the route points to.
>
>Are you really sure on this? This part has always worked fine for me with 
>Linux proxy-arp and a large variety of different kernels.

Yes, I am very sure about it.  Of all attached networks, only one is a 10.*
network, and the address answered, 10.1.2.1 happens to be the main
router/gateway
to the rest of the world.  My machine (with proxy arp) answers
incorrectly the ARP requests (for 10.1.2.1) from other machines on the
10.1.2.* subnet.  Once it steals the role of the gateway, my machine then
forwards the packets to its own default gateway which is behind the proxied
machines.
As a result of this mess, I see foreign traffic diverted through my proxy
server
via a private network to another gateway on the other side.

>
>> I find the idea to proxy based on routing tables quite questionable.
>
>So do I. The manual proxy-arp entries method suits me much better, but is 
>a pain due to lack of range support (probably why it got removed in 2.4)
>
>> It may work is some pretty trivial cases, but will very obviously fail 
>> with a more complex configuration.
>
>Haven't managed to find a single situation not solveable yet.. and this 
>involves pretty complex configurations..  I don't remember which of the 

>sysctls mentioned earlier did the trick, but once enabled things starts to 
>behave quite sanely even when there is multiple foreign networks 
>unexpectedly carried on the same Ethernet. IIRC the settings I settled for 
>was
>
>   arp_ignore = 1
>   arp_announce = 1
>
>> I have seven or eight networks attached to the node, and I certainly do 
>> not want to proxy for every single address one may find in the routing 
>> tables.
>
>Then don't.

Well, how do I tell it that I want to proxy for all machines on the 
192.168.13.128/29 net attached to eth0.5, but not for any of
the machines on 192.168.2.0/24 attached to eth0.6 ?

It just occured to me that if I misunderstood the semantics, the setup
may be wrong.  I assumed that turning the proxy arp on on interface X
would make the interface X answer (proxy) the ARP queries.
Is that correct?
(The alternative would be that turning the bit on interface X would
make all other interfaces answer on behalf of X).


>
>> It is equally mind boggling to me how this could ever work with a stack 
>> allowing source-based routing, that is, a stack allowing coexistence of 
>> multiple, possibly conflicting routing tables.
>
>Why not?

Because in rule-based routing, a table entries are only valid when the
corresponding
rule hits, based on the source address.  In the absence of a source address
as is the case of an ARP request, how could you possibly determine which
of the routing tables should be consulted to decide whether the ARP query
should be answered?

>
>> Sounds to me like I am going to have to rewrite the module.  It needs to be
>> configured manually
>
>Well, for most setups it does work automagically. Just bring up the 
>interfaces with the same IP, route the network out on the "main" interface 
>having most hosts and host (or subnet) route the other out the other 
>interface. ARP then follows automatically.
>
>But in messy networks or when your routing table is not correct then 
>sysctls is needed to restrict when to respond to stop you from responding 
>to ARP requests to outside/foreign networks.
>
>Probably isn't very hard to bring back the support for published proxy-arp 
>entries if needed. But without range support it's a pain to maitain in 
>most setups requiring proxy-arp as you then need an ARP entry for every 
>"other" station on each interface involved in proxy-arp, meaning that if 
>you proxy-arp a /24 network then you need 253 proxy-arp entries (one per 
>station, defining which interface it belongs on). In the normal situation 
>that you only act as a proxy-arp gateway for less than a handful stations 
>this is a significant administrative overhead compared to just configuring 
>routing which is required anyway.

I agree that you wouldn't want to enter discrete addresses.
But it could be a simple command using the standard subnet notation:

arp_proxy --add 10.1.2.0/24 [11:22:33:44:55:66]
(optional Eth address for 3rd party proxy ARP).

Regards
-Zdenek
