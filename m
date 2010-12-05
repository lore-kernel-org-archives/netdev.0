From: Michael Tokarev <mjt@tls.msk.ru>
Subject: weird network problem - stalls, reload works
Date: Mon, 06 Dec 2010 01:52:40 +0300
Message-ID: <4CFC17B8.4050908@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:44048 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab0LEWwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Dec 2010 17:52:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I've a weird networking problem here, which I'm
trying to hunt for some time.

Small LAN, just 3 machines and a server, all in
single small room, all connected to a 100Mbps switch.

Sometimes, network between the (linux) server and
workstations just stops.  It may happen after
transferring a few megabytes of data (rare), or
whole thing may work for several days or even
weeks in a row, but end result is the same: at
some point it stalls.

Reloading the interface in question, like this:

 ifdown eth0; sleep 2; ifup eth0

restores the network back, till it breaks again.
Note here that, say, sleep 1 is not sufficient
to restore the functionality, it has little effect.
No sleep at all makes almost no difference, ie,
such reload does not help.

The stalls looks like the server is suffering from
massive packet loss in receive path.  It does not
lose all packets, and the amount of lost packets
increases with time, in a timeframe of several
minutes.

Doing a data transfer from a client machine to this
linux box, it goes at full ~10MB/s speed, next when
the stall is about to happen the speed drops to 6MB/s,
4, 1MB/s, 600KB/s, till eventually the connection just
times out.

The interesting data point is that the NIC does not
generate any interrupts during such stalls, as if
there's no packets are coming from the network at
all - even if during that time, the client workstations
are sending ARP requests (if nothing more).

Here's how ping on the server looks like (pinging one
of the machine on the LAN):

64 bytes from 192.168.78.20: icmp_seq=1 ttl=128 time=5008 ms
64 bytes from 192.168.78.20: icmp_seq=2 ttl=128 time=5000 ms
64 bytes from 192.168.78.20: icmp_seq=3 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=4 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=5 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=6 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=7 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=8 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=9 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=10 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=11 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=12 ttl=128 time=6320 ms
64 bytes from 192.168.78.20: icmp_seq=13 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=14 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=15 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=16 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=17 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=18 ttl=128 time=6000 ms
64 bytes from 192.168.78.20: icmp_seq=19 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=20 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=21 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=22 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=23 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=24 ttl=128 time=6007 ms
64 bytes from 192.168.78.20: icmp_seq=25 ttl=128 time=6001 ms
64 bytes from 192.168.78.20: icmp_seq=26 ttl=128 time=6010 ms
64 bytes from 192.168.78.20: icmp_seq=27 ttl=128 time=5014 ms
64 bytes from 192.168.78.20: icmp_seq=28 ttl=128 time=5011 ms
64 bytes from 192.168.78.20: icmp_seq=29 ttl=128 time=5020 ms
64 bytes from 192.168.78.20: icmp_seq=30 ttl=128 time=5020 ms
64 bytes from 192.168.78.20: icmp_seq=31 ttl=128 time=6018 ms
64 bytes from 192.168.78.20: icmp_seq=32 ttl=128 time=7010 ms
64 bytes from 192.168.78.20: icmp_seq=33 ttl=128 time=7008 ms
64 bytes from 192.168.78.20: icmp_seq=34 ttl=128 time=7000 ms
64 bytes from 192.168.78.20: icmp_seq=35 ttl=128 time=7000 ms

It looks like the NIC does not deliver any packets by its
own, but notices something arrived when you actually try
to _send_ sometihng - hence the delays above, almost whole
seconds (since ping sends data with 1sec intervals).

Here's normal ping output right after "restarting" the interface:

64 bytes from 192.168.78.20: icmp_seq=1 ttl=128 time=0.161 ms
64 bytes from 192.168.78.20: icmp_seq=2 ttl=128 time=0.119 ms
64 bytes from 192.168.78.20: icmp_seq=3 ttl=128 time=0.117 ms
64 bytes from 192.168.78.20: icmp_seq=4 ttl=128 time=0.381 ms
64 bytes from 192.168.78.20: icmp_seq=5 ttl=128 time=0.131 ms
64 bytes from 192.168.78.20: icmp_seq=6 ttl=128 time=0.133 ms

And at restart, the following gets printed in dmesg:

[ 3439.360831] forcedeth 0000:00:0a.0: irq 47 for MSI/MSI-X


So far we tried to replace everything in this network:
started with the NIC on the server, all wires, the switch,
and even replaced the client computers (upgraded them from
some old to current hardware).  Even changing the NIC on
the server did not help - rtl8139 behaves the same way,
but it needs a bit more time to trigger the issue.

The problem happens with several different kernels - at
least 2.6.27 triggers it, 2.6.32 and 2.6.35 all behaves
the same, 32 or 64bit.

The machine is based on Asus M2N-VM DVI motherboard, which
is nVidia MCP67-based system.  The NIC is on-board forcedeth
(and as I mentioned above the same prob happens with rtl8139
card).

This machine has 2 more NICs inserted (used for WAN link and
for another tiny LAN segment) - these does not show the issue,
but they both run at 10Mbps, so maybe it needs 10x more time.
When the eth0 LAN segment stops working, the rest of the system
works just fine, including these 2 NICs and hard drives.

I also tried to disable MSI, loading forcedeth with msi=0, -
this results in usage of IO-APIC-fasteoi for the NIC instead
of usual PCI-MSI-edge, but does not change the situation.

So I'm quite stuck here, and don't know what to do next.
My next bet is to try another motherboard, in a hope that
this is just some broken interrupt controller, but it is
a bit too unreal...

Any hints on what to try are greatly apprecated...

Thanks!

/mjt
