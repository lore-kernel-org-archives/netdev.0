From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Problem: ip_forward in 2.6.27 via realtek 8169 and rt2500pci needs mtu 185 on machines in LAN
Date: Fri, 24 Oct 2008 18:30:05 +0400
Message-ID: <20081024143005.GA8271@ioremap.net>
References: <490127D6.8080201@jsigle.com> <20081024062820.GA9321@ioremap.net> <4901C58F.9060402@jsigle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Joerg M. Sigle" <joerg.sigle@jsigle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:59378 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454AbYJXOaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 10:30:08 -0400
Content-Disposition: inline
In-Reply-To: <4901C58F.9060402@jsigle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2008 at 02:54:39PM +0200, Joerg M. Sigle (joerg.sigle@jsigle.com) wrote:
> > Can you run network traffic with big mtu (normal 1500 bytes) between
> > linux router and clients? Between clients?
> 
> Yes.
> 
> All traffic that does NOT include routerbox is ok.
> 
> All traffic that does NOT include (external) ip_forwarding in routerbox is 
> ok
> (To and from both interfaces: eth0 or wlan0, large pings are ok;
>  even large pings to the opposite interface of routerbox are ok:
>  client1 $ ping -s 1024 192.168.2.40 <--wlan0 side of routerbox from LAN, ok
>  vbox >    ping -l 1024 192.168.1.40 <--eth0 side of routerbox from WLAN, 
>  ok,
>            see below for vbox details
>  but NOT large pings which must *leave* routerbox on the other side again.)
> 
> All traffic that DOES use ip_forwarding, and thus, both physical interfaces,
> in routerbox, has a problem with large packages.
> 
> ---
> 
> Sorry, in my previous posting I "improved" some of the
> names given to the machines just before sending -
> incompletely done. Below are all equivalents I used.
> 
> Linux box1 = client1
> eth0:192.168.1.1 (3com Vortex or so)
>   |
>   |    Linux box2 = client2
>   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
>   |      |
> SimpleSwitch
>   |
> eth0:192.168.1.40 (Realtek 8169 onboard)
> Linux routerbox = router
> wlan0:192.168.2.40 (Ralink rt2500 PCI)
>   |
> wlan: 192.168.2.253
> USR8054 dedicated WLAN-Router
> WAN: dhcp         lan: 192.168.2.253
>   |
> Internet (or so).

So, again, problem is not related to wlan traffic at all?

I.e. 192.168.1.1 -> 192.168.1.40 does not work ok with big mtu?
The same for 192.168.1.4 -> 192.168.1.40?

I.e. does ethernet connection work ok, or it is ralink problem?

> New, additional testing done right now.
> 
> 
> Question: Do the same ip_forwarding problems appear
> on another machine, with other networking cards?
> 
> 
> Method: So I change the configuration of client1 and
> give it a second network card, and use another machine,
> xpbox, to try out ip_forwarding behaviour accross client1
> (instead of accross routerbox).
> 
> 
> 
> Extended setup:
> ---------------
> 
> xpbox                                              <-- new
> eth1:192.168.4.71/24 (built in WLAN adhoc open)    <-- new
>   |
> eth1:192.168.4.1/24 (Aironet WLAN adhoc open)      <-- new
> Linux box1 = client1 (2.6.27 with ip_forwarding)
> eth0:192.168.1.1/24 (3com Vortex or so)
>   |
>   |    Linux box2 = client2
>   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
>   |      |
> SimpleSwitch
>   |
> eth0:192.168.1.40/24 (Realtek 8169 onboard)
> Linux routerbox = router (2.6.27 with ip_forwarding)
> wlan0:192.168.2.40/24 (Ralink rt2500 PCI)
>   |
> wlan: 192.168.2.253
> USR8054 dedicated WLAN-Router
>   |
> Internet
> 
> 
> Routing configuration additions:
> xpbox     : default gw 192.168.4.1; dns server 192.168.2.253
> client1   : ip_forward:=1
> routerbox : route add 192.168.4.71 gw 192.168.1.1
> USR8054   : static route 192.168.4.0/24 -> 192.168.2.40

> ip_forwarding for large packets via client1 and via routerbox
> for mtu=1500 on client1:
> 
> routerbox $ ping 192.168.2.253 -s 1024       ok (USR8054 directly via 
> wlan0, WPA-PSK)
> client1   $ ping 192.168.2.253 -s 1024       timeout (via routerbox, known 
> large packet problem)
> 
> xpbox >     ping -l 1024 192.168.1.1         ok (client1 via open adhoc 
> WLAN)
> xpbox >     ping -l 1024 192.168.1.4         ok (client2 via client1; 
> ip_forwarding in client1 ok)
> xpbox >     ping -l 1024 192.168.1.40        ok (routerbox via client1; 
> ip_forwarding in client1 ok)
> xpbox >     ping -l 1024 192.168.2.253       timeout (via client1 and 
> routerbox; ip_forwarding in routerbox problematic)
 
'-l' option does not specify size parameters, but number of packets to
send without waiting for reply before starting to wait.

> ip_forwarding for large packets via client1 and via routerbox
> for mtu=185 on client1 eth0 (points towards routerbox):
> 
> xpbox >     ping -l 1024 192.168.2.253       ok (via client1 and routerbox; 
> client1 eth0 mtu=185)
> 
> My interpretation of these findings:
> 
> So ip_forwarding for large packages works accross client1,
> while it is problematic accross routerbox.
> 
> Well, the kernel on client1 has probably more options
> activated than the further stripped down kernel on routerbox,
> but they were similarly configured when the problem first occured.
> At some time during testing, routerbox had all (or so) available options ON,
> and the problem still occured.
> 
> In particular, networking options "Large Receive Offload (ipv4/tcp)"
> is OFF on client1 (for no other reason than lack of time...),
> whereas it is marked as "M"odule on routerbox.
> 
> I just checked routerbox for that: inet_lro was NOT loaded during
> the above tests, and loading it did NOT improve the ip_forwarding
> for large packages. IMHO that makes this option at least less
> probable as source of the problem.
> 
> So... all this supports my idea that there's some problem
> with ip_forwarding *and* at least one of the network cards
> in routerbox.
> 
> I *could* try what happens when I replace the network cards in
> routerbox, but not before ca. 2 weeks from now, maybe even later.

To check this theory you only need to determine if ethernet or wlan
ralink card works bad, namely pinging via ethernet, which (if you
mistyped '-s' with '-l' in above explaination) works ok, so apparently
ralink driver makes something bad. Can you run ping with big mtu from
routerbox (192.168.2.40 to some host in the same 192.168.2.0 subnet,
like 192.168.2.253)?

> Linux box1 = client1
> eth0:192.168.1.1/24 (3com Vortex or so)
> gw=192.168.1.40
>   |
>   |    Linux box2 = client2
>   |    eth0:192.168.1.4/24 (Ne2000 PCMCIA)
>   |    gw=192.168.1.40
>   |      |
> SimpleSwitch
>   |
> eth0:192.168.1.40/24 (Realtek 8169 onboard)
> Linux routerbox = router (2.6.27 with ip_forwarding)
> gw=192.168.2.253
> wlan0:192.168.2.40/24 (Ralink rt2500 PCI)
>   |
> wlan: 192.168.2.253
> static route: 192.168.1.0->192.168.2.40
> USR8054 dedicated WLAN-Router
> wan: dhcp         lan: 192.168.2.253
>   |                  |
>   |               eth0: 192.168.2.100 (dhcp) <-- new
>   |               vbox (Vista)               <-- new
>   |
> Internet
> 
> I wanted to test whether vbox would receive large
> packages from client1; in order to check whether the
> routerbox problem occurs in both directions.
> 
> However, in preparation, I found:
> 
> vbox can ping 192.168.2.253, 192.168.2.40, 192.168.1.40
> vbox cannot ping 192.168.1.1 or 192.168.1.4 (nor 192.168.4.71)

Let's not mix different problems in the same task, this one is likely
because you run nat on routerbox, so client1 and vbox are in different
subnets and you can only initiate connections from client1.


Very likely your problem is not related to forwarding, but only to how
ralink works, and there is a possibility to have some kind of a
driver/hardware bug, which does not work work reliably with big-enough
mtu. Please test this theory by pinging from routerbox to some host via
ralink inteface (wlan router or vista box).

-- 
	Evgeniy Polyakov
