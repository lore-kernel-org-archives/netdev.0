From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 0/7] Generic UDP Encapsulation
Date: Thu, 2 Jan 2014 14:12:06 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021400260.32181@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f201.google.com ([209.85.161.201]:64552 "EHLO
	mail-gg0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABWMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:12:07 -0500
Received: by mail-gg0-f201.google.com with SMTP id k5so955723ggd.4
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:12:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements Generic UDP Encapsulation (GUE).
Intelligently encapsulating packets in UDP leverages device
support for UDP flows. The 5-tuple hash can be computed for UDP
to provide good ECMP, RSS, or link aggregation port selection.

Generic UDP encapsulation refers to encapsulating packets of
arbitray IP protocols in UDP packets. Two flavors of GUE
are implemented in these patches:

1) Direct protocol encapsulation
2) Encapsualtion in generic UDP encapsulation 

---------------------------------
Direct protocol encapsualation

Direct protocol encapsulation is done by encapsulating a
packet directly as the payload of UDP packet. The protocol
of the packet is implied by the destination port. Source port
is a hash value for the inner packet.

+-------------+
|   UDP/IP    |
+-------------+
|   Packet    |
+-------------+

The packet can be of any IP protocol (L2, L3, or L4). The protocol
is transparent to the encapsulation, there are no per protocol
semantics in the encapsulation.

These should implement GRE in UDP encapsulation:
http://tools.ietf.org/html/draft-yong-tsvwg-gre-in-udp-encap-02

---------------------------------
Encapsulation in generic UDP encapsulation

http://tools.ietf.org/html/draft-herbert-gue-00 defines an extensible
method for generic UDP encapsulation of IP protocols. In this
case a GUE header is between the UDP header and encapsulated packet.

+-------------+
|   UDP/IP    |
+-------------+
|    GUE      |
+-------------+
|   Packet    |
+-------------+

The GUE header provides the protocol number of the encapsulated packet
so encapsulation of verious IP protocols can be multiplexed over a
single UDP socket. Again, we assume there are no per protocol
semantics in the encapsulation.

---------------------------------
Implementation

There are three potential uses for GUE
1) Encapsulate L2, L3 protocols for network tunnels (IPIP, SIT,
   GRE, ...).
2) Layer 4 protocols other than TCP UDP (AH, experimental, ...)
3) Encapsulation for network virtualization

For case 1) and case 2), these patches support the RX path using the
xfrm encap_recv function. On receive the encapsulation headers are
removed, and the protocol of the encapsulated packet is returned. The
protocol is deduced from the destination port in the case of direct
protocol encapsulation, or the protocol in the GUE header.

For the TX path in case 1), I modified ip_tunnel code to optionally
provide UDP encapsulation. This covers support for IPIP, SIT, and GRE.
An ioctl enables UDP encapsulation, parameters include the destination
port to send on. The source port is simple the lower order bytes of
the TX hash (sk_hash) of the packet being tunneled.

For TX case in case 2, I beleive TX xfrm can be done (similar to ESP).

For case 3, the GUE header would be used with a virtual network
identifier (VNID). It should be possible to simple enough to divert
packets with a VNID in the network virtualization path (like OVS).

---------------------------------
Configuration

A new module gue implements RX GUE header encapsulation. This takes
a module parameter which is the UDP port to listen on for GUE
encapsulated packets.

The GRE module was modified to take a port to listen on RX for direct
encapsulation of GRE/UDP.

Configuring tunnel (IPIP, SIT, or GRE) to use UDP encapsulation should
be new options to iptunnel. I haven't implemented that yet, just used
a simple program for testing.

---------------------------------
Test results

Running on 32 CPU system with bnx2x, this is configured with four
queues. Using 'ethtool -N eth0 rx-flow-hash udp4 sdfn' to enable UDP
RSS.

Native (no tunnel)
68.78% CPU utilization
4 interrupting CPUs ~95% utilized
113/155/223 90/95/99% latencies
1.66547e+06 tps
24214 tps/CPU

IPIP
51.17% CPU utilization
1 interrpting CPU ~95%
171/248/365 90/95/99% latencies
1.10803e+06
21653 tps/CPU

IPIP in GUE
75.20% CPU utilization
145/197/273 90/95/99% latencies
1.315e+06
17486 tps/CPU

GRE (with bnx2x RSS support)
71.22% CPU utilization
138/180/244 90/95/99% latencies 
1.30465e+06 CPU/tps
18318 tps/CPU

GRE-GUE
75.96% CPU utilization
145/196/271 90/95/99% latencies
1.31427e+06
17302 CPU/tps

---------------------------------
Continuing work

I have not yet looked at the interactions with the common offloads
(except the RSS). I think we'll want a generalized implementation of GRO
and GSO for UDP encapsulation. I'm hoping that the csum offloads
is general enough to work with GUE, and possibly the same story for
TSO (LRO still seems like the hardest to generalize). The appendix
in the Generic UDP Encapsulation I-D has a description of how NIC
offloads may be supported with GUE.

I believe there is a good chance that UDP encapsulation (like GUE)
could become common place within a data center (driven by requirements
for security and for increased use of non-TCP protocols). In light of
this, the overhead of processing UDP becomes significant. In the
testing above, the cost of UDP encapsulation is demonstrated in the
GRE vs. GUE-GRE cases (about a 6% increase in CPU utilization for same
packet throughput). I suspect nearly all of this additional cost is on
is on the receive side, we may want to consider a fast path for
UDP encapsulation in the receve path.
