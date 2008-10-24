From: "Joerg M. Sigle" <joerg.sigle@jsigle.com>
Subject: Re: Problem: ip_forward in 2.6.27 via realtek 8169 and rt2500pci
 needs mtu 185 on machines in LAN
Date: Fri, 24 Oct 2008 14:54:39 +0200
Message-ID: <4901C58F.9060402@jsigle.com>
References: <490127D6.8080201@jsigle.com> <20081024062820.GA9321@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:52807 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbYJXM5c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 08:57:32 -0400
In-Reply-To: <20081024062820.GA9321@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Evgeniy!

Thank you for your quick reply.

 > Let me clarify the problem. Traffic fom linux clients only goes thro=
ugh
 > above setup if mtu on the USR8054 lan device is 185 bytes, correct?

No, not correct.

Traffic from client1 goes through if mtu on client1 eth0 is 185,
traffic from client2 goes through if mtu on client2 eth0 is 185.

The setting on the USR8054 cannot be changed (to my knowledge).

Changing the mtu on linux routerbox wlan0 can *improve* the situation
for some www sites as described, but *not completely* correct it.
(Because the rt2500pci wlan0 mtu goes down to 256 only, not further.
  That lets many more, but not all, packets get through.)

Setting routerbox eth0 mtu to 185 does not help anything.

 > Can you run network traffic with big mtu (normal 1500 bytes) between
 > linux router and clients? Between clients?

Yes.

All traffic that does NOT include routerbox is ok.

All traffic that does NOT include (external) ip_forwarding in routerbox=
 is ok
(To and from both interfaces: eth0 or wlan0, large pings are ok;
  even large pings to the opposite interface of routerbox are ok:
  client1 $ ping -s 1024 192.168.2.40 <--wlan0 side of routerbox from L=
AN, ok
  vbox >    ping -l 1024 192.168.1.40 <--eth0 side of routerbox from WL=
AN, ok,
            see below for vbox details
  but NOT large pings which must *leave* routerbox on the other side ag=
ain.)

All traffic that DOES use ip_forwarding, and thus, both physical interf=
aces,
in routerbox, has a problem with large packages.

---

Sorry, in my previous posting I "improved" some of the
names given to the machines just before sending -
incompletely done. Below are all equivalents I used.

Linux box1 =3D client1
eth0:192.168.1.1 (3com Vortex or so)
   |
   |    Linux box2 =3D client2
   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
   |      |
SimpleSwitch
   |
eth0:192.168.1.40 (Realtek 8169 onboard)
Linux routerbox =3D router
wlan0:192.168.2.40 (Ralink rt2500 PCI)
   |
wlan: 192.168.2.253
USR8054 dedicated WLAN-Router
WAN: dhcp         lan: 192.168.2.253
   |
Internet (or so).

The WAN/Internet side of USR8054 is unimportant, as the
problem can be demonstrated already when I access the
USR builtin httpd from client1 or client2 accross routerbox.

Btw., direct access to USR builtin httpd is ok (and has
been for years) from any of the machines (including from
a browser running ON, not BEHIND, routerbox).

-------------------------------------------------------

New, additional testing done right now.


Question: Do the same ip_forwarding problems appear
on another machine, with other networking cards?


Method: So I change the configuration of client1 and
give it a second network card, and use another machine,
xpbox, to try out ip_forwarding behaviour accross client1
(instead of accross routerbox).



Extended setup:
---------------

xpbox                                              <-- new
eth1:192.168.4.71/24 (built in WLAN adhoc open)    <-- new
   |
eth1:192.168.4.1/24 (Aironet WLAN adhoc open)      <-- new
Linux box1 =3D client1 (2.6.27 with ip_forwarding)
eth0:192.168.1.1/24 (3com Vortex or so)
   |
   |    Linux box2 =3D client2
   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
   |      |
SimpleSwitch
   |
eth0:192.168.1.40/24 (Realtek 8169 onboard)
Linux routerbox =3D router (2.6.27 with ip_forwarding)
wlan0:192.168.2.40/24 (Ralink rt2500 PCI)
   |
wlan: 192.168.2.253
USR8054 dedicated WLAN-Router
   |
Internet


Routing configuration additions:
xpbox     : default gw 192.168.4.1; dns server 192.168.2.253
client1   : ip_forward:=3D1
routerbox : route add 192.168.4.71 gw 192.168.1.1
USR8054   : static route 192.168.4.0/24 -> 192.168.2.40


Results:

ip_forwarding for small packets via client1 and via routerbox:

routerbox $ ping 192.168.2.253     ok (USR8054)

client1 $   ping 192.168.1.1       ok (itself)
client1 $   ping 192.168.1.4       ok (client2)
client1 $   ping 192.168.1.40      ok (routerbox)
client1 $   ping 192.168.4.71      ok (xpbox)
client1 $   ping 192.168.2.253     ok (USR8054, via routerbox)
client1 $   ping www.kernel.org    ok (via routerbox and USR8054)

xpbox >     ping 192.168.4.71      ok (itself)
xpbox >     ping 192.168.1.1       ok (client1)
xpbox >     ping 192.168.1.4       ok (client2)
xpbox >     ping 192.168.1.40      ok (routerbox, via client1)
xpbox >     ping 192.168.2.253     ok (USR8054, via client1 and routerb=
ox)
xpbox >     ping www.kernel.org    ok (via client1 and routerbox and US=
R8054)

So far so good, these were all small packets,
and all that works with mtu=3D1500 on client1.


ip_forwarding for large packets via client1 and via routerbox
for mtu=3D1500 on client1:

routerbox $ ping 192.168.2.253 -s 1024       ok (USR8054 directly via w=
lan0, WPA-PSK)
client1   $ ping 192.168.2.253 -s 1024       timeout (via routerbox, kn=
own large packet problem)

xpbox >     ping -l 1024 192.168.1.1         ok (client1 via open adhoc=
 WLAN)
xpbox >     ping -l 1024 192.168.1.4         ok (client2 via client1; i=
p_forwarding in client1 ok)
xpbox >     ping -l 1024 192.168.1.40        ok (routerbox via client1;=
 ip_forwarding in client1 ok)
xpbox >     ping -l 1024 192.168.2.253       timeout (via client1 and r=
outerbox; ip_forwarding in routerbox problematic)


ip_forwarding for large packets via client1 and via routerbox
for mtu=3D185 on client1 eth0 (points towards routerbox):

xpbox >     ping -l 1024 192.168.2.253       ok (via client1 and router=
box; client1 eth0 mtu=3D185)

My interpretation of these findings:

So ip_forwarding for large packages works accross client1,
while it is problematic accross routerbox.

Well, the kernel on client1 has probably more options
activated than the further stripped down kernel on routerbox,
but they were similarly configured when the problem first occured.
At some time during testing, routerbox had all (or so) available option=
s ON,
and the problem still occured.

In particular, networking options "Large Receive Offload (ipv4/tcp)"
is OFF on client1 (for no other reason than lack of time...),
whereas it is marked as "M"odule on routerbox.

I just checked routerbox for that: inet_lro was NOT loaded during
the above tests, and loading it did NOT improve the ip_forwarding
for large packages. IMHO that makes this option at least less
probable as source of the problem.

So... all this supports my idea that there's some problem
with ip_forwarding *and* at least one of the network cards
in routerbox.

I *could* try what happens when I replace the network cards in
routerbox, but not before ca. 2 weeks from now, maybe even later.

-------------------------------------------------------

Some more new testing, done right now, with another machine.

[Test setup does not behave as expected. Results indicate another,
  possibly losely related problem (but possibly configuration or
  firewall or other-os related). Not to be of primary interest
  right now, findings mainly posted for reference and completeness.]

Linux box1 =3D client1
eth0:192.168.1.1/24 (3com Vortex or so)
gw=3D192.168.1.40
   |
   |    Linux box2 =3D client2
   |    eth0:192.168.1.4/24 (Ne2000 PCMCIA)
   |    gw=3D192.168.1.40
   |      |
SimpleSwitch
   |
eth0:192.168.1.40/24 (Realtek 8169 onboard)
Linux routerbox =3D router (2.6.27 with ip_forwarding)
gw=3D192.168.2.253
wlan0:192.168.2.40/24 (Ralink rt2500 PCI)
   |
wlan: 192.168.2.253
static route: 192.168.1.0->192.168.2.40
USR8054 dedicated WLAN-Router
wan: dhcp         lan: 192.168.2.253
   |                  |
   |               eth0: 192.168.2.100 (dhcp) <-- new
   |               vbox (Vista)               <-- new
   |
Internet

I wanted to test whether vbox would receive large
packages from client1; in order to check whether the
routerbox problem occurs in both directions.

However, in preparation, I found:

vbox can ping 192.168.2.253, 192.168.2.40, 192.168.1.40
vbox cannot ping 192.168.1.1 or 192.168.1.4 (nor 192.168.4.71)

Hmmm. The "ARP who has 192.168.1.1?" from vbox is
forwarded by USR8054 to routerbox, it appears on wlan0.
routerbox itself sends an "ARP who has 192.168.1.1?"
on its eth0, and receives an answer from client1.
But routerbox never sends back that answer towards wlan0.
Is that correct behaviour, even if ip_forwarding is on?
Why is that? Because "bridge" kernel option is disabled?

Moreover, routerbox does not receive ping answers from vbox,
but I guess that's because vbox doesn't want to send them
(Windows default config, IIRC).

routerbox receives a correct ARP broadcast reply for vbox
from USR8054 at least, and pings between routerbox and
URS8054 work either way.

vbox has an old smbserver entry for client1, which probably
says that it could see client1 yesterday while routerbox was
running w2k, but not right now. I can see that BROWSER
announcements which appear on one side of routerbox right
now do NOT go out on the other side (but ip_forward is 1).

Hmm. This test which was originally made just to test
whether traffic in the other direction accross routerbox
also would have problems with large packets, shows that
indeed, it may have problems with ARP request forwarding.
Or I don't know enough about the issue... Maybe it was
a temporary problem due too much network structure changes
per time. This adds complication, not clarity. Sorry.

-------------------------------------------------------

Ok, hope this additional info is helpful.
Sorry for the long text, I think detail is helpful here,
and I will not be able to continue testing/reporting
at least over the next week (systems out of reach).

Good success + best regards, Joerg

--=20
-------------------------------------------------------------------
Dr. med. J=C3=B6rg M. Sigle                              +41-76-276-869=
4
http://www.ql-recorder.com                         +49-163-143-7876
http://www.jsigle.com       Have a lovely day...  +49-176-964-35413

