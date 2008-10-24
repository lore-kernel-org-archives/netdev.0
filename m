From: "Joerg M. Sigle" <joerg.sigle@jsigle.com>
Subject: Problem: ip_forward in 2.6.27 via realtek 8169 and rt2500pci needs
 mtu 185 on machines in LAN
Date: Fri, 24 Oct 2008 03:41:42 +0200
Message-ID: <490127D6.8080201@jsigle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:53199 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbYJXBoe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 21:44:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Here is a very brief possible error report.

I've done a *brief* search in WWW and Usenet before filing it.
I'm sending this report here upon advice from kernelnewbies.org.
Please forgive me if I'm posting things you already know -
in that case, however, I'd appreciate your feedback.


Problem:
---------

When I route two linux boxen (client1, client2) Ethernet ipv4
from LAN to WLAN through another linux box (routerbox),
I must set mtu 185 (or lower...) on the clients.

Otherwise some responses (specifically, packets above some size)
to the clients will never arrive from servers in WLAN/Internet.

The problem is not resolved by info regarding TCPMSS etc.,
and apparently caused somewhere in routerbox under Linux 2.6.27.

Details below.


Question:
---------

Is there anything
in the rt2500pci WLAN driver included in this kernel,
or in the ip_forwarder,
or in the Realtek 8169 Gigabit Ethernet driver,
that fails for packets larger than 185 bytes?


Setup:
------

Linux box1
eth0:192.168.1.1 (3com Vortex or so)
   |
   |
   |
   |    Linux Box2
   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
   |      |
   |      |
   |      |
SimpleSwitch
   |
   |
   |
eth0:192.168.1.40 (Realtek 8169 onboard)
Linux routerbox (Plain vanilla 2.6.27 SMP)
wlan0:192.168.2.40 (Ralink rt2500 PCI)
   |
   |
   |
USR8054 dedicated WLAN-Router
   |
   |
   |
Internet (or so).


Notes/previous research:
------------------------

- The necessity to reduce the mtu on the clients goes away, when router=
box runs w2k,
   so the problem is definitely not in hardware nor the environment nor=
 the clients.
   (Well, in that world, the WLAN connection goes down for some secs an=
d back up from
    time to time, and I'm unhappy that I had to download a 32MB!! drive=
r!! package...)

- A browser on router itself has no problem to contact anything outside=
=2E

- Routing on USR-WLAN-router, on router itself, and on clients is IMHO
   all configured ok. There's no problem with DNS, or getting standard =
pings
   or even an ftp login through to the Internet. The problem is only
   getting large packages through (or probably: back), I verified that
   also with ping -size and -M do|want|don't.

- Watching traffic with 3 instances of ethereal,
   e.g. when client requests a WWW page from the Internet, I can see:

   client looks up WWW server IP from DNS - all ok
   client contacts WWW server, ack, ack - all ok
   client sends HTTP GET request: this goes out from client eth0,
   comes in at router eth0, goes out at router wlan0.
   But the response from server never arrives
   (does not get visible in router wlan0 incoming traffic).
   (and a bit later, client sends its repeated request)

- The simplest testcase is:
   try to contact the http server in the USR8054 wlan-router,
   (dedicated hardware, has current firmware).
   The attempt to see the configuration page will fail as described,
   when the client mtu is above 185 (tried from box1 and box2).
   This shows there's NO problem with any Internet
   provider messing with package sizes, fragmentation etc.
   (And what I tried as recommended in CONFIG_NETFILTER_XT_TARGET_TCPMS=
S
    help, before I saw the problem appeared as well for
    the server in USR8054, and when routerbox was in NAT mode,
    did apparently NOT affect the observed problem at all).

- It doesn't matter whether router just forwards packages,
   or works as a masquerading firewall, and it does not help
   to enable "WAN bridging" - I tried all of these.

- I tried other options like using a netmask of 255.255.0.0,
   and having all networking cards in 192.168.1.0, to no avail
   (and I don't want such a thing anyway...)

- Reducing the mtu on router's wlan0 to about 510 lets some but
   not all web pages from the Internet successfuly appear on clients
   box1 and box2.
   Further reduction improves results.
   At about mtu=3D360, most pages come through, but
   e.g. apt-get update on client or large ping still stalls.
   Only mtu=3D185 on either client results in a *perfectly* stable resu=
lt,
   no matter what mtu is set on router's wlan0.

- mtu=3D186 on the clients is not sufficient.
   It must be 185 (or lower, I guess).

- Sorry, at the moment most of my hardware is somewhere else -
   so I did not replace any of router's network cards by another one
   to further track down the problem. Neither can I look at the
   traffic in the WLAN in detail at the moment. My time for
   experiments is sadly limited as well...


=46urther info:
-------------

Router uses a WPA connection, and wireless_tools and wpa_supplicant
are the most recent versions I could get to work with this system.

Alternative available Ralink drivers would not compile with 2.6.27,
and I cannot try older kernels now or soon.

I disabled many options when trying to isolate the source of the error.
The current 2.6.27 Kernel configuration on router has enabled ONLY:

Networking support:

Networking options:
   Packet socket, mmapped
   Unix domain sockets
   Transformation user config if
   PF_KEY sockets
   TCP/IP networking
     IP: multicasting
     IP: advanced router
     IP: TCP syncookie support (disabled per default)
     Large Receive Offload (ip4/tcp)  <-------- uneducated guess: possi=
ble problem?
     INET: socket monitoring
   Network packet filtering (Netfiler)
     Advanced netfilter configuration
       Core: NFQUEUE + LOG over NFNETLINK
             Connection tracking flow..., mark..., tracking...
             FTP, H.323, IRC, SIP protocols support
             Conection tracking netlink interface
             Netfilter Xtables support
             state match support
       IP:   IPv4 connection tracking
             proc/sysctl compat
             IP tables support
             Packet filtering: REJECT, LOG, ULOG, Full NAT, MASQ, REDIR=
ECT
IPX
Bluetooth,
wireless: Improved API,
           new netlink interface,
           wext, wext sysfs,
           Gen. 802.11 (mac8022),
           Gen. 802.11 (DEPR), WEP, CCMP, TKIP
+RF switch subsystem

(As mentioned above, the problem occurs in simple ip_forwarding as well
  as in NAT mode, so these options are probably overkill for the simple=
st
  test setup.)



Network device drivers (all as modules):

Dummy,
Bonding,
EQL,
Universal TUN/TAP,
Surfboard 1000
eth10/100: Generic Media Inep Interf and nForce Ethernet
eth1000:   Realtek 8169 and Yukon2 Gigabit Ethernet
wireless:  Ralink driver support, Ralink rt2500 (PCI/PCMCIA), rfkill, l=
eds
Network console logging support.

(Other drivers than 8169/rt2500 not really needed, but leftovers.)

(Apart from this peculiarity, the systems apparently are stable;
  I could work with mtu=3D185, but I don't like the issue looming aroun=
d,
  neither the tx/rx graph showing the extra handshaking traffic...)


Closing:
--------

I hope that the problem is not caused by faulty configuration,
and that this report is useful for you in fixing it. Good luck!

Thanks for your reading time, thanks for doing a lot
of great work and keeping that up over the years!

Best wishes, Joerg

--=20
-------------------------------------------------------------------
Dr. med. J=F6rg M. Sigle
http://www.ql-recorder.com
http://www.jsigle.com                          Have a lovely day...

