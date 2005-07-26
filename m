From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Linux Policy Routing-Based IDS Load Balancer HOWTO
Date: Tue, 26 Jul 2005 09:46:36 -0500
Message-ID: <200507260946.38894.jeremy.guthrie@berbee.com>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1281510.49u6NrilRT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1281510.49u6NrilRT
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Linux Policy Routing-Based IDS Load Balancer HOWTO

What you say?  Well, some of you may have remember in early January of this=
=20
year I was spamming the list pretty hard trying to get a host to route quit=
e=20
a bit of data.  Turns out it was for an Linux based IDS load balancer.  I a=
m=20
80-90% done and I'd like to get your feed back as to how bad I've horked=20
this.  Specifically are there descriptions for things like gc_interval and=
=20
the like that are so technically wrong I should be slapped with a wet=20
penguin?

Obvious things I have not completed yet:
1.  spell checker, that will come after the list has beaten this up
2.  formatting, I gave up on general formatting till the very end
3.  the TOC isn't finished yet

If you could please, review the tuning/performance enhancing sections.

BTW, my first howto....

ids-load-balancing-HOWTO

Jeremy M. Guthrie

 jeremy.guthrie@berbee.com

=46ebruary 2004

Version 1.0
 Jeremy M. Guthrie
 2-5-2005

=2D------------------------------------------------------------------------=
=2D---
Table of Contents

0. Credit and Notes About the Author
1. Terms
1. The Example Problem
2. Possible Solutions
3. The Linux Answer
    3.1. Further Example Details
    3.2. Needed Software Updates & Other Requirements
    3.3. Notes About Limitations
    3.4. It's All About the 'IP'
    3.5. Other assumptions
    3.6. L2CC vs EBTables & L2-NAT
    3.6.1 L2CC Config
    3.6.2 EBTables & L2-NAT
    3.7. The Policy Router Config
4. Performance Tuning
5. Copyright
    5.1. GNU Free Documentation License
    5.2. PREAMBLE
    5.3. APPLICABILITY AND DEFINITIONS
    5.4. VERBATIM COPYING
    5.5. COPYING IN QUANTITY
    5.6. MODIFICATIONS
    5.7. COMBINING DOCUMENTS
    5.8. COLLECTIONS OF DOCUMENTS
    5.9. AGGREGATION WITH INDEPENDENT WORKS
    5.10. TRANSLATION
    5.11. TERMINATION
    5.12. FUTURE REVISIONS OF THIS LICENSE
    5.13. How to use this License for your documents
  =20
=2D------------------------------------------------------------------------=
=2D---

0.  Credit and Notes About the Author

  First and foremost this document would not be possible if it were not for=
=20
Jim Leu, Robert Olsson, Stephen Hemminger, David Miller, Jesse Brandeburg,=
=20
Chris Gerg, and Jon Vanderhill.  All of these people were instrumental in=20
providing code, feedback, resources, or other critical input to help get th=
is=20
document and system where it is today.
=20
  I myself am a network engineer.  I have been building or managing network=
s=20
since 1992.  I have been a Linux advocate since late 1995.  It is my primar=
y=20
OS for what I do.  I am not a kernel developer though I have written other=
=20
software packages.  I make no claim that I am the final authority on system=
s=20
I reference within.  I am providing descriptions of the bits and pieces bas=
ed=20
on existing documentation or discussions I have had with other persons.  IO=
W,=20
if you see a blatant error or a feature omission, it is not on purpose and=
=20
would love the feedback to correct this documentation.
 =20
=2D------------------------------------------------------------------------=
=2D---

1.  Terms

  EBTables:  A Layer-2 filtering technology in the Linux V2.6 kernel.

  Linear Search:  The process of one-by-one searching through the hash=20
collision buckets.

  L2CC:  Layer Two Cross Connect:  A software patch created by Jim Leu that
         takes all input frames from an ethernet controller and NATs the=20
         destination MAC address to be that of some host on an outbound=20
  port.
        =20
  L2XC:  Another name for the L2CC software.

  Innovation:  "the introduction of something new" as defined by=20
               Merriam-Webster Online(www.m-w.com).
   =20
  MAC-Munger:  Another name for the L2CC software.

  Policy-Router:  A router which routes because of a dictated policy rather
         than by normal IPV4 per-hop-behavior.  ie.  route all port 80
         out my DSL link, all SMTP traffic out my cable link vs. default=20
         route traffic via my cable.

  SPAN:  Switch port analyzer.  Think of it as a port which mirrors traffic
         off of a VLAN or switchport out another port.  ie.  mirror all
         all traffic going in/out of the Firewall's inside interface to the
         SPAN port.

=2D------------------------------------------------------------------------=
=2D---

1.  The Example Problem

  You are a large business with a lot of Internet bandwidth.  Your IDS is
  capable of dealing with some subset of your traffic volume but it cannot
  handle it by itself.  It also would cost too much money to buy a bigger,
  faster, IDS.  You want to buy the same model as you already have.  The two
  IDSes together can handle the volume but now you have to figure out how to
  divide the traffic up between the two.

  Sounds simple doesn't it? =20

  Example bandwidth, 800 megabit per second.  Assume you are using Cisco IDS
  4255 where each IDS lists at $25,000 a piece.  A 4255 is supposed to be
  capable of 600mbps.  Remember, you want the IDS to see all of the data in
  a flow, not just one half!  So you cannot just break up the flow without
  some thought.=20

=2D------------------------------------------------------------------------=
=2D---
 =20
2.  Possible Solutions

   F5, Radware, and Top Layer networks all make boxes that will split data
   appart.  All of these are commercial products that help load balance
   flows for IDSs or traffic management.  They are not cheap and in some ca=
ses
   are budget busters.
  =20
   The example network hardware I reference in here will be Cisco platforms
   as that is what I am most familiar with.

=2D------------------------------------------------------------------------=
=2D---
  =20
3.  The Linux Answer

   The good news is that Linux has an answer with L2CC/EBTables and Policy=
=20
Routing.  The two main components run in the kernel so they operate securel=
y. =20
I will detail scaling the solution upward as it should be able to meet the=
=20
needs of most any bandwidth.

   The Linux solution identified herein has been dubbed by Chris Gerg as th=
e=20
(I(DS)^2).  However I will to  the whole system as the IDS load balancer he=
re=20
after.

   The concept is simple:
                                (or EBTables)
   +---------------+                +---+
   | Catalyst 6509 |-[1000SX-SPAN]->| l |           +---------------+
   +---------------+                | 2 |-[1000SX]->| Policy Router |
   +---------------+                | c |           +-+-----+-------+
   | Catalyst 6509 |-[1000SX-SPAN]->| c |                   |
   +---------------+                +---+                   |[1000SX]
                                                            v
                                                  +-------------------+
                                                  | Catalyst 3750 Gig |
                                                  +---+------------+--+
                                                      |            |
                                                      |<--1000TX-->|
                                                  +---+---+        |
                                                  | IDS A |        |
                                                  +-------+        |
                                                               +---+---+
                                                               | IDS A |
                                                               +-------+

   There is a highly available network with two enterprise class switches=20
front-ending the network.  Each switch hands off a SPAN port to the Layer T=
wo=20
Cross Connect(l2cc/l2xc) host AKA EBTables Host.  The SPAN data is an=20
identical copy of the data from the ports they mirror. =20
  =20
   If the destination MAC address of an example packet is 05:05:05:03:03:03=
,=20
then we to NAT this to an address of the policy router's outside interface=
=20
MAC address.  Why?  Normal routers will not route data unless the layer two=
=20
destination address matches their own MAC address.  The l2cc host=20
changes/L2-NATs the destination MAC address to be that of the Policy Router=
's=20
'outside' interface.  When the data arrives at the policy router, it looks =
in=20
its ip routing ruleset to determine what 'table' to use to forward the=20
incoming packets.  Once a table is found and selected, that table is then=20
used to define the per-hop-behavior at that point in time for that packet.

   3.1. Further Example Details
  =20
   Time to add yet another layer of detail to the example.  We will assume =
we=20
want to run Snort or NTOP against all traffic coming through our network.  =
In=20
this example we will assume that we have 1.0.0.0/16 assigned to us.  We als=
o=20
know that we have a pretty good distribution of traffic such that 1.0.0.0/1=
7=20
gets about 350mbps and 1.0.128.0/17 gets about 450 mbps.
  =20
   What we also know is that because of the network that traffic to/from=20
both /17 subnets comes in over both SPANs but is NOT duplicate traffic.  Th=
is=20
can because of things like per-packet or per-flow routing decisions made by=
=20
downstream equipment.
  =20
   3.2. Needed Software Updates & Other Requirements
  =20
   You will want to make sure you have the latest tools for the job.  I hav=
e=20
only ever worked this solution using Intel Gig NICs.  Others should work bu=
t=20
I have never tested them.
  =20
   Software to get:
   1. Latest Intel E1000 drivers
   http://sourceforge.net/projects/e1000/
  =20
   2.  Latest IPRoute2 utilities:
   http://www.policyrouting.org/

   3.  Latest L2CC software:
   http://mpls-linux.sf.net/
  =20
   4.  A V2.4 & V2.6 Linux Kernel:
   http://www.kernel.org/
   L2CC requires V2.4 and you should use V2.6 for your policy router.
  =20
   5.  Schedutils
   http://tech9.net/rml/schedutils/

   6.  EBTables
   http://ebtables.sourceforge.net/
  =20
   As for other requirements....

   I HIGHLY recommend a multi-CPU box.  Hyperthread has shown advantages an=
d=20
works well in our implementation.  I typically assign one CPU per NIC on=20
either the EBTables box and/or Policy Router.  Your mileage will vary but u=
se=20
common sense.  If you have a dual 3.2 ghz P4 w/ Hyperthreading then that wi=
ll=20
have enough horse power to handle large data volumes.  In some cases you=20
could easily assign more than one NIC to a CPU.

   3.3. Notes About Limitations
  =20
   Every piece of hardware or software has limits.  Keep this in mind when=
=20
deploying your system.  I will show you where counters are instrumented and=
=20
generically how to manage them.  Like any good system administrator, you wi=
ll=20
have to manage your system.
  =20
   3.4. It's All About the 'IP'
  =20
   ifconfig, netstat, and other old-style utilities are being phased out=20
slowly.  Familiarize yourself with the 'ip' utility from the iproute2 packa=
ge=20
as it replaces the prior listed programs.  The iproute2 package includes=20
other programs that will help in providing access to critical performance=20
information.  'lnstat' and 'rtstat' can be used to poll routing performance=
=20
information from your kernel DEPENDING on which kernel release you are=20
running.   =20
  =20
   3.5. Other assumptions
  =20
   Going forward it will be assumed that you have the appropriate kernels=20
and/or features installed unless we talk explicitly about a feature.
  =20
   3.6 L2CC vs EBTables & L2-NAT

   L2CC was the only option available when this document was first written =
but=20
now EBTables is available.  EBTables was beaten up a quite bit in the May=20
2005 Networld+Interop in Vegas.  EBTables proved to be a very reliable bit =
of=20
software.  L2CC has more burn in time for my organization but we are in the=
=20
process of migrating.  This document will provide examples for both L2CC &=
=20
EBTables.

   3.6.1 L2CC Config
  =20
   The example L2CC host has three Gig NICs.  eth0-1 are gathering SPAN dat=
a=20
while eth2 is the output port.  The Policy router's eth0 MAC address is=20
01:01:01:10:10:10. =20
  =20
   The L2CC host will need the L2CC patch applied against the V2.4 kernel. =
=20
=46rom there do the following:
   make menuconfig
   Select "Networking Options"
   Compile in "Layer 2 Cross Connectr (EXPERIMENTAL)", do not build as a=20
module.
   Rebuild your kernel and reboot.
  =20
   #add two entries, one for each NIC
   l2cc -a -i eth0 -o eth2 -m 01:01:01:10:10:10
   l2cc -a -i eth1 -o eth2 -m 01:01:01:10:10:10
  =20
   #delete two entries, one for each NIC
   l2cc -d -i eth0 -o eth2 -m 01:01:01:10:10:10
   l2cc -d -i eth1 -o eth2 -m 01:01:01:10:10:10
  =20
   *WARNING* Test that your configuration is working using TCPDump in an=20
ISOLATED network. =20

   In the above example, I should be able to run three instances of TCPDump=
=20
and see that data coming in eth0 & eth1 is having its MAC address NAT'd whe=
n=20
being transmitted out eth2.

   3.6.2 EBTables & L2-NAT

   The example EBTables host has three Gig NICs.  eth0-1 are gathering SPAN=
=20
data while eth2 is the output port.  The Policy router's eth0 MAC address i=
s=20
01:01:01:10:10:10. =20

   EBTables will require a Linux host running with a V2.6 kernel.

   To build your Linux kernel with EBTables support:
   make menuconfig
   Select "Device Drivers"
   Select "Networking Support"  =20
   Select "Networking Options"
   Compile in "802.1d Ethernet Bridging"
   Select "Network packet filtering"
   Select "Bridge: Netfilter Configuration"
   Select "Ethernet Bridge tables (ebtables) support"
   Select "ebt: nat table support"
   Select "ebt: dnat target support"
   Select "ebt: snat target support"
   Rebuild your kernel and reboot.

   #prep your interfaces
   ifconfig eth0 up
   ifconfig eth1 up
   ifconfig eth2 up

   #create the br0 interface
   brctl addbr br0

   #turn off spanning-tree
   brctl stp br0 off

   #add interfaces to the br0 broadcast domain
   brctl addif br0 eth0
   brctl addif br0 eth1
   brctl addif br0 eth2

   #Prep ebtables
   ebtables -F INPUT
   ebtables -F OUTPUT
   ebtables -F FORWARD
   ebtables -t nat -F PREROUTING
  =20
   #NAT all incoming data on eth0 to 00:11:25:8c:8c:37
   ebtables -t nat -A PREROUTING -I eth0 -j dnat -to-destination=20
00:11:25:8c:8c:37
   #NAT all incoming data on eth1 to 00:11:25:8c:8c:37
   ebtables -t nat -A PREROUTING -I eth1 -j dnat -to-destination=20
00:11:25:8c:8c:37

   #Tell EBTables to route/bridge data destined to 00:11:25:8c:8c:37 out et=
h2
   ebtables -A OUTPUT -o eth2 -d 00:11:25:8c:8c:37 -j ACCEPT =20

   *WARNING* Test that your configuration is working using TCPDump in an=20
ISOLATED network. =20

   In the above example, I should be able to run three instances of TCPDump=
=20
and see that data coming in eth0 & eth1 is having its MAC address NAT'd whe=
n=20
being transmitted out eth2.
  =20
   3.7.  The Policy Router Config
  =20
   I am going to assume you have the appropriate iproute2 package for your=
=20
kernel.  You may need a newer version of the iproute2 utilities. =20
   ie. V2.6.9 kernel  =20
   strace -f rtstat ...
   --snip--
   open("/proc/net/rt_cache_stat", O_RDONLY) =3D -1 ENOENT (No such file or=
=20
directory)
   --snip--
   In this case I would need the latest iproute2 code to use=20
the  /proc/net/stat/rt_cache instead.  In fact, rtstat may also be called=20
'lnstat'.
  =20
   *ASSUMPTION* This policy router config assumes there are no overlapping=
=20
subnets.  Overlapping subnets mean you must order your policy rules=20
appropriately for them to work.  Overlapping IP examples: 192.168.0.0/16 &=
=20
192.168.0.0/24
  =20
   The policy router is made up of several components.  The policy router u=
ses=20
rules and tables.  Rules are used to classify which traffic belongs to whic=
h=20
table.  This is where the policy in policy routing comes from.  You define=
=20
what policies you want to implement.
  =20
   Tables are routing tables used to device the per-hop-behavior for the=20
packet being routed via that table.  Shortly you will see how the combinati=
on=20
of rules with tables are combined to split traffic.
  =20
   In our example, we want to split traffic of two /17s to the two sensors.=
 =20
With that in mind we will add rules to do the actual policy mapping.
  =20
   Eth0 is our input device while eth1 is our output device.  Eth0 will hav=
e=20
an IP address of 10.0.0.1/32.  An IP address is required otherwise the Linu=
x=20
kernel will not policy-route for the interface.  Eth1 will have an IP addre=
ss=20
of 10.0.1.1/24.  Sensor 1 will have an IP address of 10.0.1.10, Sensor 2 wi=
ll=20
have an IP address of 10.0.1.11.
  =20
   Routing at high speed means any hiccup, EVEN SMALL ones, result in lost=
=20
packets as recieve rings for network cards can be overrun quickly.  Thus we=
=20
have to minimize any hiccups.  One hiccup is ARP.  Sensors NEVER transmit a=
nd=20
we will always have data to send to them.  You will see several changes we=
=20
will make to account for this.
  =20
   #First, turn off IP forwarding before we configure routing
   echo 0 > /proc/sys/net/ipv4/ip_forward
  =20
   #Add static ARP entries as we should ALWAYS know what MAC
   #address to associate with our Sensor IPS
   arp -s 10.0.1.10 00:02:50:98:DC:1C
   arp -s 10.0.1.11 00:02:50:A1:5D:5A
  =20
   #send any traffic to/from 1.0.0.0/17 to table 15
   ip rule add type unicast dev eth0 from 1.0.0.0/17 table 15
   ip rule add type unicast dev eth0 to 1.0.0.0/17 table 15
  =20
   #send any traffic to/from 1.0.128.0/17 to table 16
   ip rule add type unicast dev eth0 from 1.0.128.0/17 table 16
   ip rule add type unicast dev eth0 to 1.0.128.0/17 table 16
  =20
   #Tell policy routing code that the only path in table 15 is via Sensor 1!
   ip route add default via 10.1.0.10 dev eth1 table 15
  =20
   #Tell policy routing code that the only path in table 16 is via Sensor 2!
   ip route add default via 10.1.0.11 dev eth1 table 16
  =20
   #When done with our changes, flush the cache
   ip route flush cache
  =20
   #Lastly, turn on IP forwarding
   echo 1 > /proc/sys/net/ipv4/ip_forward
  =20
   This is all you actually 'have to do' to enable a working system.  There=
=20
are however other changes you SHOULD make to help with performance.
  =20
   For one, if you left IP forwarding on and blew away the policy routing=20
table, all traffic would then follow your normal default route on the=20
box!!!!!! =20
  =20
   *WARNING*
   Let's complicate our policy router by adding another interface,=20
eth3->192.168.10.5 with a default gw to a firewall so we can remotely manag=
e=20
the system.  In our example, we had 800mbps heading towards our policy=20
router.  If we turn off policy routing but left IP forwarding on, the Linux=
=20
host will try to forward >>>>800mbps<<<< of traffic towards the firewall on=
=20
the 192.168.10.0/24 network thereby killing it.  Okay?! Follow?  If not,=20
re-read till you do. =20
  =20
   Hint:  If your firewall has a 100mbps interface and you fire 800mbps at =
it,=20
the firewall will stop working because you will overload its interface with=
=20
bandwidth.
  =20
   There are then two ways to protect yourself:
   A)  Always turn off IP forwarding before making ANY changes to the polic=
y=20
router.=20
   B)  Turn on iptables filtering.  Here is a quick an dirty example of an=
=20
IPtables filter to apply to this example host:
  =20
   #The only data that will be allowed in or out of eth3 will be traffic
   #to or from 192.168.10.5.  So even if you accidentally leave IP forwardi=
ng
   #on, you can trust that IP Tables it stemming the flow from burrying your
   #gateway/firewall.
   iptables -F
   iptables -A FORWARD -s 192.168.10.5 -o eth3 -j ACCEPT
   iptables -A FORWARD -o eth0 -j DROP
   iptables -A OUTPUT -s 192.168.10.5 -o eth3 -j ACCEPT
   iptables -A OUTPUT -o eth0 -j DROP
  =20
   The switches will need some adjustments to make sure that the switch kno=
ws=20
exactly where the sensors are.  If the sensors never transmit data on their=
=20
ports then the switches turn act as hubs which is exactly what we don't wan=
t.
  =20
   #3750 config:
   interface GigabitEthernet1/0/1
   description Eth0 of Sensor 1
   switchport access vlan 100
   switchport trunk native vlan 100
   switchport trunk allowed vlan none
   switchport mode access
   switchport nonegotiate
   load-interval 30
   no cdp enable
   !
   interface GigabitEthernet1/0/2
   description Eth0 of Sensor 2
   switchport access vlan 100
   switchport trunk native vlan 100
   switchport trunk allowed vlan none
   switchport mode access
   switchport nonegotiate
   load-interval 30
   no cdp enable
   !
   interface GigabitEthernet1/0/28
   description Eth1 of Policy Router
   switchport access vlan 100
   switchport trunk native vlan 100
   switchport trunk allowed vlan none
   switchport mode access
   switchport nonegotiate
   load-interval 30
   no cdp enable
   !
   mac-address-table static 0002.5098.DC1C vlan 100 interface=20
GigabitEthernet1/0/1
   mac-address-table static 0002.50A1.5D5A vlan 100 interface=20
GigabitEthernet1/0/2=20
  =20
   That's it?  Right?  Well, sure.  If your system is blazing fast and does=
=20
not require any tuning.  This assumes your system defaults are adequate. =20
That may not be the case.  The rest of this document will be dedicated to=20
discussing eliminating the bottlenecks.
  =20
=2D------------------------------------------------------------------------=
=2D---

4. Performance Tuning

   Jumping back to a prior statement, you need to be aware of the limits of=
=20
the policy routing system.  I will list them out here and we will discuss h=
ow=20
to go about addressing them.  Some are easy to update, others are what they=
=20
are.
  =20
4.1. General Limits
  =20
   Kernel Limits:
   Max # of Policy Routing Rules:  32768 - some are reserved
   Max # of Policy Routing Tables:  256 - some are reserved
   Max # of Interfaces in V2.6 Kernel:  4096
   Max # of Interfaces in V2.4 Kernel:  256
  =20
   IP Route Hash Limits:
  =20
   Card Limits:
   Intel EtherExpress RX/TX Buffer Count:  256 packets
    Max RX/TX Buffer Count:  4096 packets

4.2.  Instrumentation

   Knowing that any system is running well can take a bit to figure out. =20
There will be a few places that we concentrate on monitoring.  Memory, CPU=
=20
utilization, interrupt distribution, network stack drops, network card drop=
s,=20
# of routes, garbage collection, routing packets per second, # of hash=20
entries, and others.
=20
4.2.1.  rtstat or lnstat in the land of iproute2

   Rtstat and lnstat are two tools used to watch routing activity within th=
e=20
Linux kernel.  Kernels prior to approximately V2.6.9 will use rtstat.  Afte=
r=20
2.6.9 iproute2 uses lnstat to gather routing detail.  You can tell if your=
=20
kernel works with rtstat or lnstat by trying the existing install of rtstat=
=2E =20
Both tools pull data from /proc, it is a question of which one.
  =20
   ie.
   [plato jguthrie 10:29am]~-> rtstat
   fopen: No such file or directory
  =20
4.2.2  Important /proc files for your reference.

   #Data on each route cache entries/hashes
   /proc/net/rt_cache
  =20
   #Aggregate statistics on route cache entries/hashes
   /proc/net/stat/rt_cache
  =20
   #General information about the network stack on a per-cpu basis
   /proc/net/softnet_stat

   We will examine each of the files to examine what they can tell us.

4.2.2.1.  /proc/net/softnet_stat

   cat /proc/net/softnet_stat
   00000130 00000034 00000000 00000000 00000000 00000000 00000000 00000000=
=20
00000000
   00000150 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
=20
00000000
  =20
   The basic idea behind softnet_stat is that we use it as a way to tell us=
 if=20
the Kernel itself is dropping packets.  The second field in the list of nin=
e=20
is the packet drop count.  You can see in this example that we have dropped=
=20
0x34 packets.  Look into using NAPI or other network card features to=20
possibly relieve CPU overhead.

4.2.3  CPUs, Memory, and Interrupts & the Rules To Follow

   As with any rules here, all can be affected by your budget.

   1.  Assume that each CPU on your box will be handling only one NIC's=20
interrupts.
   2.  Assume that you will be using 'taskset' to keep non-kernel routing=20
functions assigned to a specific CPU.
   3.  EBTables uses little memory, you can skimp here
   4.  Policy Routing Chews Memory, you cannot skimp here - minimum 1 Gigab=
yt=20
of RAM ***HIGHLY*** recommended

4.2.3.1  CPUs should only following one NIC.

   If you look at the output below you can see that CPU0 is taking the=20
interrupts for eth3.  CPU1 is taking interrupts for eth2 & eth0.  Optimisin=
g=20
any system relies on keep thrashing to a minimum.  As a result I highly=20
recommend disable IRQ Balancing.

   make menuconfig for your kernel config
   Select "Processor type and features"
   Disable "Enable kernel irq balancing"
   Rebuild your kernel and reboot.

   You will have to poke around /proc to set which CPU an interrupt binds t=
o. =20
Here is what was used to set the interrupt/CPU bindings down below:
   echo 01 > /proc/irq/18/smp_affinity
   echo 02 > /proc/irq/20/smp_affinity

   The value used is expressed in powers of two.  ie. CPU3 would actually b=
e=20
04.

   cat /proc/interrupts
           CPU0       CPU1
  0: 3184569581 1789102599    IO-APIC-edge  timer
  1:       1005        218    IO-APIC-edge  i8042
  7:          0          0   IO-APIC-level  ohci_hcd
  8:          1          1    IO-APIC-edge  rtc
 12:        122         74    IO-APIC-edge  i8042
 14:          2          0    IO-APIC-edge  ide0
 18:  995373697       5139   IO-APIC-level  eth3
 20:          2 1378253801   IO-APIC-level  eth2
 27:    7542100    9352305   IO-APIC-level  eth0
 28:    4150402   13187680   IO-APIC-level  aic7xxx
 30:          0          0   IO-APIC-level  acpi
NMI:          0          0
LOC:  679927478  679903506
ERR:          0
MIS:          0

4.2.3.2  Taskset is your friend.

   Taskset allows an administrator to bind a software process to a specific=
=20
processor on a box.  By using taskset you help cut down on CPU cache=20
thrashing.  If your hosts will be running SNMP daemons, snort, etc, then yo=
u=20
will want to bind snort to the least used CPU.  You want to keep your base=
=20
load balancing system predictable.

4.3  Tune your routing!

   The Linux kernel defaults for routing work great in a lot of situations =
and=20
unfortunately this is not one of them.  You will find that the Linux kernel=
=20
will take some tuning to get the performance you want.

   The kernel counts on route hash entries to track existing conversations.=
 =20
One route hash entry is used per host-host communication.  ie.
   Entry 1:  192.168.1.1 -> 192.168.2.2
   Entry 2:  192.168.2.4 -> 192.168.7.5

   Imagine HOW MANY of these you might have given your volumes of traffic. =
=20
Also imagine that the kernel has NO WAY to tell when a conversation is over=
=2E =20
The kernel is not following TCP/UDP conversations thus entries age out of=20
existence.  You will need to conduct performance testing to confirm how wel=
l=20
your environment runs.  Just be warned that the more route hash entries you=
=20
run, the more RAM the kernel WILL use.

   Example 'free' from your Policy router:
   /proc/sys/net/ipv4/route/gc_thresh:  786432
             total       used       free     shared    buffers     cached
Mem:       1034088    1007112      26976          0     310840     217220
=2D/+ buffers/cache:     479052     555036
Swap:      1028120          0    1028120

4.3.1  Adjust one kernel parameter and reboot.

   You will need to bump up the maximum number of supported route hash entr=
ies=20
the kernel supports.  I recommend setting this rather high and using anothe=
r=20
parameter to set your ceiling.  Add the following to your boot config kerne=
l=20
parameters:
 rhash_entries=3D2400000

4.3.2  Adjust /proc/sys/net/... to tune your routing

   The Linux kernel uses six parameters to adjust how it handles managing t=
he=20
routing hashes, collisions, and aging. =20

   gc_elesticity can best be described as the average bucket depth the kern=
el=20
will accept before it starts expiring route hash entries.  This will help=20
maintain the upper limit of active routes.
   echo 8 > /proc/sys/net/ipv4/route/gc_elasticity

   I had limited success playing with these next two entries seeing as I co=
uld=20
find little information on the effect of either one.
   echo 60 > /proc/sys/net/ipv4/route/gc_interval
   echo 0 > /proc/sys/net/ipv4/route/gc_min_interval

   gc_thresh is another limiting factor in controlling how much RAM your=20
policy routing will eat up.  This number cannot be greater than the=20
rhash_entries kernel parameter.  As a rule of thumb, set your rhash_entries=
=20
parameter REALLY high(mine is 2.4million) and control your running limit wi=
th=20
gc_thresh.
   echo 1048576 > /proc/sys/net/ipv4/route/gc_thresh

   This parameter needs better kernel docs.
   echo 300 > /proc/sys/net/ipv4/route/gc_timeout

   The secret_interval instructs the kernel how often to blow away ALL rout=
e=20
hash entries regardless of how new/old they are.  In our environment this i=
s=20
generally bad.  The CPU will be busy rebuilding thousands of entries per=20
second every time the cache is cleared.  However we set this to run once a=
=20
day to keep memory leaks at bay(though we've never had one).
   echo 86400 > /proc/sys/net/ipv4/route/secret_interval

4.3.3  Basic scripts

   These aren't perfect but then again, what is....

4.3.3.1  watcherrors

#!/bin/tcsh
set interval=3D15
set argc=3D`echo $argv | wc -w | tr -s " " "\t" | cut -f2`
if ( $argc > 0 ) then
        set interval=3D$argv[1]
endif

set stats=3D`ifconfig eth3 | egrep 'RX packets:' | tr -s ": " "\t" | cut -f=
4,6`
set interrupts=3D`cat /proc/interrupts | egrep "eth[23]" | tr -s " " "\t" |=
 cut=20
=2Df 3,4`
while ( 1 )
        sleep $interval
        set newstats=3D`ifconfig eth3 | egrep 'RX packets:' | tr -s ": " "\=
t" |=20
cut -f4,6`
        set packets=3D`expr $newstats[1] - $stats[1]`
        set errors=3D`expr $newstats[2] - $stats[2]`
        set percentage=3D`expr $errors "*" 10000 / $packets`
        set packetspersec=3D`expr $packets / $interval `
        set date=3D`date "+%m/%d/%y %H:%M:%S"`
        set entries=3D`cat /proc/net/stat/rt_cache | tr -s " " "\t" | cut -=
f 1 |=20
head -n 2 | tail -n 1`
        set newinterrupts=3D`cat /proc/interrupts | egrep "eth[23]" | tr -s=
 " "=20
"\t" | cut -f 3,4`
        set eth3int=3D`expr $newinterrupts[1] - $interrupts[1]`
        set eth2int=3D`expr $newinterrupts[4] - $interrupts[4]`
        echo "$date entries:  $entries  Pkts:  $packets  Err:  $errors  PPS=
: =20
$packetspersec  Drop %:  0.$percentage%  Eth3RXInt:  $eth3int  Eth2TXInt: =
=20
$eth2int"
        set stats=3D( $newstats )
        set interrupts=3D( $newinterrupts )
end

4.3.3.2  Policy Routing Control Script

   This script assumes that you will have two files, a policy route file, a=
nd=20
policy rule file.

   The ROUTE file should have the following format:
   [ip of next hop] [outgoing interface] [table #]

   Example 'routefile' contents:
   10.0.1.10     eth2    31
   10.0.1.11     eth2    32

   The RULE file should have the following format:
   [CIDR BLOCK] [table #]

   Example 'rulefile' contents:
   172.30.0.0/24 31
   172.16.0.0/22 32

   Data to/from 172.30.0.0/24 would be sent to sensor 10.0.1.10.  Data to/f=
rom=20
172.16.0.0/22 would be sent to sensor 10.0.1.11.


#POLICY V1.0 script
#!/bin/tcsh
set policyrulefile=3D/opt/bin/policyrules
set policyroutefile=3D/opt/bin/policyroutes

set argc=3D`echo $argv | wc -w | tr -s " " "\t" | cut -f2`
if ( $argc < 3 ) then
        echo Policy V1.00
        echo "Usage:  policy [add|delete|show] [routefile] [rulefile]"
        exit
endif
set command=3D`echo $1 | tr "[a-z]" "[A-Z"`
if ( ( $command =3D=3D "ADD" ) || ( $command =3D=3D "DELETE" ) ) then
        if ( ! -e $argv[2] ) then
                echo Route file $argv[2] does not exist
                exit
        endif
        if ( ! -e $argv[3] ) then
                echo Rule file $argv[3] does not exist
                exit
        endif
endif

set policyroutefile=3D$argv[2]
set policyrulefile=3D$argv[3]

set policyrulecount=3D`egrep "[0-9]\/[0-9]" $policyrulefile | wc -l | tr -s=
 " "=20
"\t" | cut -f2`
set policyrules=3D`egrep "[0-9]\/[0-9]" $policyrulefile | tr -s " " "\t"`

set policyroutecount=3D`egrep "[0-9]      eth" $policyroutefile | wc -w | t=
r -s=20
" " "\t" | cut -f2`
set policyroutes=3D`egrep "[0-9]  eth" $policyroutefile | tr -s " " "\t"`

if ( $command =3D=3D "ADD" ) then
        echo -n "Turning up..."
        set alternate=3D0
        foreach policyrule ($policyrules )
                if ( $alternate ) then
                        set alternate=3D0
                        set table=3D$policyrule
                        #       echo "Adding rule:  $range $table"
                        echo -n "."
                        /sbin/ip rule add type unicast dev eth3 from $range=
=20
table $table
                        /sbin/ip rule add type unicast dev eth3 to $range=20
table $table
                else
                        set alternate=3D1
                        set range=3D$policyrule
                endif
        end
        set loop=3D0
        while ( $loop !=3D $policyroutecount )
                set loop=3D`expr $loop + 1`
                set gw=3D$policyroutes[$loop]
                set loop=3D`expr $loop + 1`
                set device=3D$policyroutes[$loop]
                set loop=3D`expr $loop + 1`
                set table=3D$policyroutes[$loop]
                #echo "Adding default route:  $gw $device $table"
                echo -n "+"
                /sbin/ip route add default via $gw dev $device table $table
        end
        /sbin/ip route flush cache
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo ""
endif

if ( $command =3D=3D "DELETE" ) then
        echo -n "Turning down..."
        echo 0 > /proc/sys/net/ipv4/ip_forward
        set alternate=3D0
        foreach policyrule ($policyrules )
                if ( $alternate ) then
                        set alternate=3D0
                        set table=3D$policyrule
                        #echo "Deleting rule:  $range $table"
                        echo -n "."
                        /sbin/ip rule delete type unicast dev eth3 from $ra=
nge=20
table $table
                        /sbin/ip rule delete type unicast dev eth3 to $rang=
e=20
table $table
                else
                        set alternate=3D1
                        set range=3D$policyrule
                endif
        end
        set loop=3D0
        while ( $loop !=3D $policyroutecount )
                set loop=3D`expr $loop + 1`
                set gw=3D$policyroutes[$loop]
                set loop=3D`expr $loop + 1`
                set device=3D$policyroutes[$loop]
                set loop=3D`expr $loop + 1`
                set table=3D$policyroutes[$loop]
                #echo "Deleting default route:  $gw $device $table"
                echo -n "+"
                /sbin/ip route delete default via $gw dev $device table $ta=
ble
        end
        /sbin/ip route flush cache
        echo ""
endif

if ( $command =3D=3D "SHOW" ) then
        set tables=3D`cat $policyroutefile | egrep "[0-9]" | tr -s " " "\t"=
 |=20
cut -f3 | sort -u`
        ip rule list
        foreach table ($tables)
                ip route list table $table
        end
endif



=2D------------------------------------------------------------------------=
=2D---

5. Copyright

Copyright =A9 2005 Jeremy M. Guthrie

Permission is granted to copy, distribute and/or modify this document under
the terms of the GNU Free Documentation License, Version 1.1 or any later
version published by the Free Software Foundation; with no Invariant
Sections, no Front-Cover Texts and no Back-Cover Texts. A copy of the licen=
se
is included in the section entitled "GNU Free Documentation License".

=2D------------------------------------------------------------------------=
=2D---

5.1. GNU Free Documentation License

Version 1.1, March 2000

  =20
    Copyright (C) 2000 Free Software Foundation, Inc. 59 Temple Place, Suite
    330, Boston, MA 02111-1307 USA Everyone is permitted to copy and
    distribute verbatim copies of this license document, but changing it is
    not allowed.
  =20
=2D------------------------------------------------------------------------=
=2D---
5.2. PREAMBLE

The purpose of this License is to make a manual, textbook, or other written
document "free" in the sense of freedom: to assure everyone the effective
freedom to copy and redistribute it, with or without modifying it, either
commercially or noncommercially. Secondarily, this License preserves for the
author and publisher a way to get credit for their work, while not being
considered responsible for modifications made by others.

This License is a kind of "copyleft", which means that derivative works of
the document must themselves be free in the same sense. It complements the
GNU General Public License, which is a copyleft license designed for free
software.

We have designed this License in order to use it for manuals for free
software, because free software needs free documentation: a free program
should come with manuals providing the same freedoms that the software does.
But this License is not limited to software manuals; it can be used for any
textual work, regardless of subject matter or whether it is published as a
printed book. We recommend this License principally for works whose purpose
is instruction or reference.
=2D------------------------------------------------------------------------=
=2D---

5.3. APPLICABILITY AND DEFINITIONS

This License applies to any manual or other work that contains a notice
placed by the copyright holder saying it can be distributed under the terms
of this License. The "Document", below, refers to any such manual or work.
Any member of the public is a licensee, and is addressed as "you".

A "Modified Version" of the Document means any work containing the Document
or a portion of it, either copied verbatim, or with modifications and/or
translated into another language.

A "Secondary Section" is a named appendix or a front-matter section of the
Document that deals exclusively with the relationship of the publishers or
authors of the Document to the Document's overall subject (or to related
matters) and contains nothing that could fall directly within that overall
subject. (For example, if the Document is in part a textbook of mathematics,
a Secondary Section may not explain any mathematics.) The relationship could
be a matter of historical connection with the subject or with related
matters, or of legal, commercial, philosophical, ethical or political
position regarding them.

The "Invariant Sections" are certain Secondary Sections whose titles are
designated, as being those of Invariant Sections, in the notice that says
that the Document is released under this License.

The "Cover Texts" are certain short passages of text that are listed, as
=46ront-Cover Texts or Back-Cover Texts, in the notice that says that the
Document is released under this License.

A "Transparent" copy of the Document means a machine-readable copy,
represented in a format whose specification is available to the general
public, whose contents can be viewed and edited directly and
straightforwardly with generic text editors or (for images composed of
pixels) generic paint programs or (for drawings) some widely available
drawing editor, and that is suitable for input to text formatters or for
automatic translation to a variety of formats suitable for input to text
formatters. A copy made in an otherwise Transparent file format whose markup
has been designed to thwart or discourage subsequent modification by readers
is not Transparent. A copy that is not "Transparent" is called "Opaque".

Examples of suitable formats for Transparent copies include plain ASCII
without markup, Texinfo input format, LaTeX input format, SGML or XML using=
 a
publicly available DTD, and standard-conforming simple HTML designed for
human modification. Opaque formats include PostScript, PDF, proprietary
formats that can be read and edited only by proprietary word processors, SG=
ML
or XML for which the DTD and/or processing tools are not generally availabl=
e,
and the machine-generated HTML produced by some word processors for output
purposes only.

The "Title Page" means, for a printed book, the title page itself, plus such
following pages as are needed to hold, legibly, the material this License
requires to appear in the title page. For works in formats which do not have
any title page as such, "Title Page" means the text near the most prominent
appearance of the work's title, preceding the beginning of the body of the
text.
=2D------------------------------------------------------------------------=
=2D---

5.4. VERBATIM COPYING

You may copy and distribute the Document in any medium, either commercially
or noncommercially, provided that this License, the copyright notices, and
the license notice saying this License applies to the Document are reproduc=
ed
in all copies, and that you add no other conditions whatsoever to those of
this License. You may not use technical measures to obstruct or control the
reading or further copying of the copies you make or distribute. However, y=
ou
may accept compensation in exchange for copies. If you distribute a large
enough number of copies you must also follow the conditions in section 3.

You may also lend copies, under the same conditions stated above, and you m=
ay
publicly display copies.
=2D------------------------------------------------------------------------=
=2D---

5.5. COPYING IN QUANTITY

If you publish printed copies of the Document numbering more than 100, and
the Document's license notice requires Cover Texts, you must enclose the
copies in covers that carry, clearly and legibly, all these Cover Texts:
=46ront-Cover Texts on the front cover, and Back-Cover Texts on the back co=
ver.
Both covers must also clearly and legibly identify you as the publisher of
these copies. The front cover must present the full title with all words of
the title equally prominent and visible. You may add other material on the
covers in addition. Copying with changes limited to the covers, as long as
they preserve the title of the Document and satisfy these conditions, can be
treated as verbatim copying in other respects.

If the required texts for either cover are too voluminous to fit legibly, y=
ou
should put the first ones listed (as many as fit reasonably) on the actual
cover, and continue the rest onto adjacent pages.

If you publish or distribute Opaque copies of the Document numbering more
than 100, you must either include a machine-readable Transparent copy along
with each Opaque copy, or state in or with each Opaque copy a
publicly-accessible computer-network location containing a complete
Transparent copy of the Document, free of added material, which the general
network-using public has access to download anonymously at no charge using
public-standard network protocols. If you use the latter option, you must
take reasonably prudent steps, when you begin distribution of Opaque copies
in quantity, to ensure that this Transparent copy will remain thus accessib=
le
at the stated location until at least one year after the last time you
distribute an Opaque copy (directly or through your agents or retailers) of
that edition to the public.

It is requested, but not required, that you contact the authors of the
Document well before redistributing any large number of copies, to give them
a chance to provide you with an updated version of the Document.
=2D------------------------------------------------------------------------=
=2D---

5.6. MODIFICATIONS

You may copy and distribute a Modified Version of the Document under the
conditions of sections 2 and 3 above, provided that you release the Modified
Version under precisely this License, with the Modified Version filling the
role of the Document, thus licensing distribution and modification of the
Modified Version to whoever possesses a copy of it. In addition, you must do
these things in the Modified Version:

 A. Use in the Title Page (and on the covers, if any) a title distinct from
    that of the Document, and from those of previous versions (which should,
    if there were any, be listed in the History section of the Document). Y=
ou
    may use the same title as a previous version if the original publisher =
of
    that version gives permission.
  =20
 B. List on the Title Page, as authors, one or more persons or entities
    responsible for authorship of the modifications in the Modified Version,
    together with at least five of the principal authors of the Document (a=
ll
    of its principal authors, if it has less than five).
  =20
 C. State on the Title page the name of the publisher of the Modified
    Version, as the publisher.
  =20
 D. Preserve all the copyright notices of the Document.
  =20
 E. Add an appropriate copyright notice for your modifications adjacent to
    the other copyright notices.
  =20
 F. Include, immediately after the copyright notices, a license notice givi=
ng
    the public permission to use the Modified Version under the terms of th=
is
    License, in the form shown in the Addendum below.
  =20
 G. Preserve in that license notice the full lists of Invariant Sections and
    required Cover Texts given in the Document's license notice.
  =20
 H. Include an unaltered copy of this License.
  =20
 I. Preserve the section entitled "History", and its title, and add to it an
    item stating at least the title, year, new authors, and publisher of the
    Modified Version as given on the Title Page. If there is no section
    entitled "History" in the Document, create one stating the title, year,
    authors, and publisher of the Document as given on its Title Page, then
    add an item describing the Modified Version as stated in the previous
    sentence.
  =20
 J. Preserve the network location, if any, given in the Document for public
    access to a Transparent copy of the Document, and likewise the network
    locations given in the Document for previous versions it was based on.
    These may be placed in the "History" section. You may omit a network
    location for a work that was published at least four years before the
    Document itself, or if the original publisher of the version it refers =
to
    gives permission.
  =20
 K. In any section entitled "Acknowledgements" or "Dedications", preserve t=
he
    section's title, and preserve in the section all the substance and tone
    of each of the contributor acknowledgements and/or dedications given
    therein.
  =20
 L. Preserve all the Invariant Sections of the Document, unaltered in their
    text and in their titles. Section numbers or the equivalent are not
    considered part of the section titles.
  =20
 M. Delete any section entitled "Endorsements". Such a section may not be
    included in the Modified Version.
  =20
 N. Do not retitle any existing section as "Endorsements" or to conflict in
    title with any Invariant Section.
  =20

If the Modified Version includes new front-matter sections or appendices th=
at
qualify as Secondary Sections and contain no material copied from the
Document, you may at your option designate some or all of these sections as
invariant. To do this, add their titles to the list of Invariant Sections in
the Modified Version's license notice. These titles must be distinct from a=
ny
other section titles.

You may add a section entitled "Endorsements", provided it contains nothing
but endorsements of your Modified Version by various parties--for example,
statements of peer review or that the text has been approved by an
organization as the authoritative definition of a standard.

You may add a passage of up to five words as a Front-Cover Text, and a
passage of up to 25 words as a Back-Cover Text, to the end of the list of
Cover Texts in the Modified Version. Only one passage of Front-Cover Text a=
nd
one of Back-Cover Text may be added by (or through arrangements made by) any
one entity. If the Document already includes a cover text for the same cove=
r,
previously added by you or by arrangement made by the same entity you are
acting on behalf of, you may not add another; but you may replace the old
one, on explicit permission from the previous publisher that added the old
one.

The author(s) and publisher(s) of the Document do not by this License give
permission to use their names for publicity for or to assert or imply
endorsement of any Modified Version.
=2D------------------------------------------------------------------------=
=2D---

5.7. COMBINING DOCUMENTS

You may combine the Document with other documents released under this
License, under the terms defined in section 4 above for modified versions,
provided that you include in the combination all of the Invariant Sections =
of
all of the original documents, unmodified, and list them all as Invariant
Sections of your combined work in its license notice.

The combined work need only contain one copy of this License, and multiple
identical Invariant Sections may be replaced with a single copy. If there a=
re
multiple Invariant Sections with the same name but different contents, make
the title of each such section unique by adding at the end of it, in
parentheses, the name of the original author or publisher of that section if
known, or else a unique number. Make the same adjustment to the section
titles in the list of Invariant Sections in the license notice of the
combined work.

In the combination, you must combine any sections entitled "History" in the
various original documents, forming one section entitled "History"; likewise
combine any sections entitled "Acknowledgements", and any sections entitled
"Dedications". You must delete all sections entitled "Endorsements."
=2D------------------------------------------------------------------------=
=2D---

5.8. COLLECTIONS OF DOCUMENTS

You may make a collection consisting of the Document and other documents
released under this License, and replace the individual copies of this
License in the various documents with a single copy that is included in the
collection, provided that you follow the rules of this License for verbatim
copying of each of the documents in all other respects.

You may extract a single document from such a collection, and distribute it
individually under this License, provided you insert a copy of this License
into the extracted document, and follow this License in all other respects
regarding verbatim copying of that document.
=2D------------------------------------------------------------------------=
=2D---

5.9. AGGREGATION WITH INDEPENDENT WORKS

A compilation of the Document or its derivatives with other separate and
independent documents or works, in or on a volume of a storage or
distribution medium, does not as a whole count as a Modified Version of the
Document, provided no compilation copyright is claimed for the compilation.
Such a compilation is called an "aggregate", and this License does not apply
to the other self-contained works thus compiled with the Document, on accou=
nt
of their being thus compiled, if they are not themselves derivative works of
the Document.

If the Cover Text requirement of section 3 is applicable to these copies of
the Document, then if the Document is less than one quarter of the entire
aggregate, the Document's Cover Texts may be placed on covers that surround
only the Document within the aggregate. Otherwise they must appear on covers
around the whole aggregate.
=2D------------------------------------------------------------------------=
=2D---

5.10. TRANSLATION

Translation is considered a kind of modification, so you may distribute
translations of the Document under the terms of section 4. Replacing
Invariant Sections with translations requires special permission from their
copyright holders, but you may include translations of some or all Invariant
Sections in addition to the original versions of these Invariant Sections.
You may include a translation of this License provided that you also include
the original English version of this License. In case of a disagreement
between the translation and the original English version of this License, t=
he
original English version will prevail.
=2D------------------------------------------------------------------------=
=2D---

5.11. TERMINATION

You may not copy, modify, sublicense, or distribute the Document except as
expressly provided for under this License. Any other attempt to copy, modif=
y,
sublicense or distribute the Document is void, and will automatically
terminate your rights under this License. However, parties who have received
copies, or rights, from you under this License will not have their licenses
terminated so long as such parties remain in full compliance.
=2D------------------------------------------------------------------------=
=2D---

5.12. FUTURE REVISIONS OF THIS LICENSE

The Free Software Foundation may publish new, revised versions of the GNU
=46ree Documentation License from time to time. Such new versions will be
similar in spirit to the present version, but may differ in detail to addre=
ss
new problems or concerns. See [http://www.gnu.org/copyleft/] http://
www.gnu.org/copyleft/.

Each version of the License is given a distinguishing version number. If the
Document specifies that a particular numbered version of this License "or a=
ny
later version" applies to it, you have the option of following the terms and
conditions either of that specified version or of any later version that has
been published (not as a draft) by the Free Software Foundation. If the
Document does not specify a version number of this License, you may choose
any version ever published (not as a draft) by the Free Software Foundation.
=2D------------------------------------------------------------------------=
=2D---

5.13. How to use this License for your documents

To use this License in a document you have written, include a copy of the
License in the document and put the following copyright and license notices
just after the title page:

  =20
    Copyright (c) YEAR YOUR NAME. Permission is granted to copy, distribute
    and/or modify this document under the terms of the GNU Free Documentati=
on
    License, Version 1.1 or any later version published by the Free Software
    Foundation; with the Invariant Sections being LIST THEIR TITLES, with t=
he
    Front-Cover Texts being LIST, and with the Back-Cover Texts being LIST.=
 A
    copy of the license is included in the section entitled "GNU Free
    Documentation License".
  =20
If you have no Invariant Sections, write "with no Invariant Sections" inste=
ad
of saying which ones are invariant. If you have no Front-Cover Texts, write
"no Front-Cover Texts" instead of "Front-Cover Texts being LIST"; likewise
for Back-Cover Texts.

If your document contains nontrivial examples of program code, we recommend
releasing these examples in parallel under your choice of free software
license, such as the GNU General Public License, to permit their use in free
software.


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1281510.49u6NrilRT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBC5kzOqtjaBHGZBeURArqzAJ9lOTtI67pPPY1cLYlLsyrChzVDvgCfZI9a
hR8tLmJkuzSaB07mx6SQSew=
=/n6m
-----END PGP SIGNATURE-----

--nextPart1281510.49u6NrilRT--
