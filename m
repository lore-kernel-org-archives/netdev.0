From: Daniel Risacher <magnus@alum.mit.edu>
Subject: Unexpected bridge behavior (Bug? You decide.)
Date: Sat, 22 Jan 2005 19:36:51 -0500
Message-ID: <E1CsVkJ-0004R5-00@m5.risacher.org>
Reply-To: magnus@alum.mit.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: bridge@osdl.org, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


While using the linux bridge module in 2.6.10, the kernel seems to
munge the source IP address of broadcast UDP packets if they come from
"0.0.0.1", and sticks on an address of the linux host.

I humbly submit that re-writing the source address of packets is not
proper behavior for a bridge, even if those source addresses are not
traditionally valid.

Sure, 0.0.0.1 isn't a valid address, but it's used by the XBOX games
for "System Link" play.  See http://caia.swin.edu.au/genius/020802A/
for more details, but basically XBOXes talk to each other by sending
UDP port 3074 packets with 0.0.0.1 as the source address.  When
searching for other XBOX systems, these are broadcast packets
addressed to 255.255.255.255/ff:ff:ff:ff:ff:ff.

So I was trying to get two XBOXes to talk to each other through a
Linux machine configured as a bridge, (mostly so I could watch the
traffic) and it didn't work.  Here's what tcpdump saw:

$ sudo brctl show br0
bridge name     bridge id               STP enabled     interfaces
br0             8000.00112f9de921       yes             eth0
                                                        eth2

$ sudo tcpdump -n -e -i eth0 port 3074
tcpdump: WARNING: eth0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
19:28:27.715755 00:50:f2:f1:fb:07 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 102: IP 0.0.0.1.3074 > 255.255.255.255.3074: UDP, length: 60
### line above appears to be xbox 1 broadcasting to find other hosts
19:28:28.772223 00:50:f2:ba:39:89 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 102: IP 66.92.162.116.3074 > 255.255.255.255.3074: UDP, length: 60
### line above is linux bridge forwarding packet from xbox 2, I think. Note IP address is of linux box, not 0.0.0.1

$ sudo tcpdump -n -e -i eth2 port 3074
tcpdump: WARNING: eth2: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 96 bytes
19:28:27.715816 00:50:f2:f1:fb:07 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 102: IP 66.92.162.116.3074 > 255.255.255.255.3074: UDP, length: 60
### line above is linux bridge forwarding packet from xbox 1. Note IP address is of linux box, not 0.0.0.1
19:28:28.772135 00:50:f2:ba:39:89 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 102: IP 0.0.0.1.3074 > 255.255.255.255.3074: UDP, length: 60
### line above is xbox 2 broadcasting to find other hosts
