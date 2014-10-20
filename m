From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Routing BUG with ppp over l2tp
Date: Mon, 20 Oct 2014 15:45:23 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1410201414500.2403-100000@iolanthe.rowland.org>
References: <5445442C.8080508@workingcode.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Chapman <jchapman@katalix.com>, <linux-ppp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: James Carlson <carlsonj@workingcode.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5445442C.8080508@workingcode.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2014, James Carlson wrote:

> On 10/20/14 12:39, Alan Stern wrote:
> > As far as I can tell, the problem is caused by bad routing.  The kernel
> > gets confused because the IP address assigned by the VPN server to the
> > server's end of the ppp tunnel is the _same_ as the server's actual IP
> > address.
> 
> Indeed!  That's pretty darned lame behavior by that peer.  It would
> probably be workable if you had a virtual router instance and were able
> to put the L2TP connection in one routing instance and the PPP
> connection in another routing instance, but that's likely not at all
> simple to achieve.

I'd like to find the simplest solution.  Ideally it should "just work", 
like the Windows and OS-X clients do.

> > Unfortunately, I can't work around this problem by reconfiguring the
> > VPN server -- there's no way to tell it to use a different IP address
> > for its end of the VPN tunnel.  Furthermore, the server works just fine
> > with clients running Windows or OS-X.
> 
> Really?  That seems ... improbable.

I guess that depends on how you judge probabilities.  :-)

As evidence to convince you, here's a log of a session on a rather old
Mac Powerbook G4 running OS 10.4.11.  The situation isn't exactly the
same as with my Linux system, because for this test the client and the
VPN server are on the same subnet -- I don't think that should make any
difference.  The client's IP address is 140.247.233.41, the server's is
.37, and the router to the outside world is .33.  The client's ppp IP
address (assigned by the server) is 10.170.30.1.

The following commands were carried out while the VPN was connected:


------------------------------------------------------------------------
michael-burns-powerbook-g4:~ stern$ netstat -rn -f inet
Routing tables

Internet:
Destination        Gateway            Flags    Refs      Use  Netif Expire
default            140.247.233.37     UGSc        2        4   ppp0
10                 ppp0               USc         1        0   ppp0
127                127.0.0.1          UCS         0        0    lo0
127.0.0.1          127.0.0.1          UH         12     2278    lo0
140.247.233.32/27  link#4             UCS         2        0    en0
140.247.233.33     0:8:e3:ff:fc:b8    UHLW        0        0    en0   1198
140.247.233.37     0:1e:f7:15:53:a8   UHLW        3       10    en0   1153
140.247.233.37/32  link#4             UCS         1        0    en0
140.247.233.41     127.0.0.1          UHS         0        0    lo0
169.254            link#4             UCS         0        0    en0

michael-burns-powerbook-g4:~ stern$ ping -c1 -n 10.160.0.2
PING 10.160.0.2 (10.160.0.2): 56 data bytes
64 bytes from 10.160.0.2: icmp_seq=0 ttl=64 time=1.368 ms

--- 10.160.0.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 1.368/1.368/1.368/nan ms

michael-burns-powerbook-g4:~ stern$ ifconfig en0
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        inet 140.247.233.41 netmask 0xffffffe0 broadcast 140.247.233.63
        ether 00:03:93:12:da:48 
        media: autoselect (100baseTX <full-duplex>) status: active
        supported media: none autoselect 10baseT/UTP <half-duplex> 10baseT/UTP <full-duplex> 10baseT/UTP <full-duplex,hw-loopback> 100baseTX <half-duplex> 100baseTX <full-duplex> 100baseTX <full-duplex,hw-loopback>

michael-burns-powerbook-g4:~ stern$ ifconfig ppp0
ppp0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1280
        inet 10.170.30.1 --> 140.247.233.37 netmask 0xff000000 
------------------------------------------------------------------------


I don't understand (and can't be bothered to look up) those arcane
symbols in the netstat output.  The IP address used for the ping test
(10.160.0.2) is a system on the VPN's private network.

Here's comparable output for a connection from a computer running 
Windows 7 (same IP addresses as before):


------------------------------------------------------------------------
C:\Users\stern>netstat -rn
===========================================================================
Interface List
 20...........................Rowland VPN
 10...00 1a 6b 57 30 02 ......Intel(R) 82566DM Gigabit Network Connection
  1...........................Software Loopback Interface 1
 11...00 00 00 00 00 00 00 e0 Microsoft ISATAP Adapter
 12...00 00 00 00 00 00 00 e0 Teredo Tunneling Pseudo-Interface
 19...00 00 00 00 00 00 00 e0 Microsoft 6to4 Adapter
 21...00 00 00 00 00 00 00 e0 Microsoft ISATAP Adapter #2
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0   140.247.233.33   140.247.233.41   4491
          0.0.0.0          0.0.0.0         On-link       10.170.30.1     11
      10.170.30.1  255.255.255.255         On-link       10.170.30.1    266
        127.0.0.0        255.0.0.0         On-link         127.0.0.1   4531
        127.0.0.1  255.255.255.255         On-link         127.0.0.1   4531
  127.255.255.255  255.255.255.255         On-link         127.0.0.1   4531
   140.247.233.32  255.255.255.224         On-link    140.247.233.41   4491
   140.247.233.37  255.255.255.255         On-link    140.247.233.41   4236
   140.247.233.41  255.255.255.255         On-link    140.247.233.41   4491
   140.247.233.63  255.255.255.255         On-link    140.247.233.41   4491
        224.0.0.0        240.0.0.0         On-link         127.0.0.1   4531
        224.0.0.0        240.0.0.0         On-link    140.247.233.41   4492
        224.0.0.0        240.0.0.0         On-link       10.170.30.1     11
  255.255.255.255  255.255.255.255         On-link         127.0.0.1   4531
  255.255.255.255  255.255.255.255         On-link    140.247.233.41   4491
  255.255.255.255  255.255.255.255         On-link       10.170.30.1    266
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0   140.247.233.33  Default
===========================================================================

C:\Users\stern>ping -n 1 10.160.0.2

Pinging 10.160.0.2 with 32 bytes of data:
Reply from 10.160.0.2: bytes=32 time<1ms TTL=64

Ping statistics for 10.160.0.2:
    Packets: Sent = 1, Received = 1, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms

C:\Users\stern>ipconfig /all

Windows IP Configuration

   Host Name . . . . . . . . . . . . : Windows-test
   Primary Dns Suffix  . . . . . . . : rowland.org
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No
   DNS Suffix Search List. . . . . . : rowland.org

PPP adapter Rowland VPN:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Rowland VPN
   Physical Address. . . . . . . . . :
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   IPv4 Address. . . . . . . . . . . : 10.170.30.1(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.255
   Default Gateway . . . . . . . . . : 0.0.0.0
   DNS Servers . . . . . . . . . . . : 10.160.0.2
                                       10.160.0.3
   Primary WINS Server . . . . . . . : 10.160.0.2
   NetBIOS over Tcpip. . . . . . . . : Disabled

Ethernet adapter Local Area Connection:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Intel(R) 82566DM Gigabit Network Connection
   Physical Address. . . . . . . . . : 00-1A-6B-57-30-02
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::1426:1891:bf83:3982%10(Preferred)
   IPv4 Address. . . . . . . . . . . : 140.247.233.41(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.224
   Default Gateway . . . . . . . . . : 140.247.233.33
   DHCPv6 IAID . . . . . . . . . . . : 234887787
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-1B-A2-3E-B1-00-1A-6B-57-30-02

   DNS Servers . . . . . . . . . . . : 8.8.8.8
   NetBIOS over Tcpip. . . . . . . . : Enabled
------------------------------------------------------------------------


Although the Windows ipconfig output doesn't show the IP address of the
server side of the ppp tunnel, it does show up in a Details window
under the Network control panel, and it is indeed set to
140.247.233.37.

> > So it looks like the problem has to be fixed either in the kernel or in 
> > the way pppd sets up its routing entry.  Can you guys help?
> 
> I think the easiest solution is to configure pppd to lie to the kernel
> about the remote address.  Who cares what the remote address is on a
> point-to-point link anyway?
> 
> There's currently no option to do this, but the code change in ipcp_up()
> in pppd/ipcp.c would be rather simple.  Just make the "noremoteip" code
> run all the time:
> 
> /* Deliberately falsify the remote address.  We don't care. */
> ho->hisaddr = htonl(0x0aa00002);
> 
> As long as you don't need to contact that specific remote server using
> the badly-assigned "internal" VPN address and can live with the fact
> that you'll either go through the regular Internet to that address or be
> forced to use some other address configured on that server, you should
> be good.
> 
> (The address I used above is 10.160.0.2.  That was one of the internal
> DNS server addresses provided in the log you posted.  It's not necessary
> that the address used here is exactly that, but it may well be helpful.)

That might work.  But using a nonstandard version of pppd would be
awkward, and I would prefer to avoid it.

> If you can't do that for some reason, then I suppose it would be
> possible to use IP Chains (or whatever the packet-modification tool du
> jure is used in your Linux distribution) to nail up an exception so that
> the outside packets go to the outside interface and the inside ones go
> to the PPP interface.  Doing that likely requires selecting on (at
> least!) source address, so it's messy and ugly and possibly error-prone,
> but it might be doable.

That sounds like a fairly easy thing to try.  But it would still 
require manual intervention instead of just working.  Fixing the kernel 
would be preferable, IMO.

> Otherwise, contact the maintainer of that VPN server.  It's just plain
> old broken, and life's too short for broken software.

It is an old Cisco security appliance, no doubt well past End-Of-Life.  
I'm starting to think it might be preferable to throw the thing away 
and start up a VPN server on the department's firewall (which is a 
Linux box) instead.

Alan Stern

