From: Tore Anderson <tore@fud.no>
Subject: Loose URPF (rp_filter=2) doesn't work correctly with tunnels
Date: Thu, 18 Aug 2016 08:46:27 +0200
Message-ID: <20160818084627.27909f5c@echo.ms.redpill-linpro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.145]:41391 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbcHRHEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2016 03:04:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've run into a bug when attempting to use rp_filter=2 in conjunction
with tunnel interfaces. Basically it behaves as the same as strict RPF
(rp_filter=1), discarding any packet arriving on the tunnel interface
even though a route to the packet's source address exists on a
different interface (which should have been sufficient to allow the
loose RPF check to pass).

This can be easily reproduced with the help of network namespaces. The
below recipe uses IPIP tunnels, but the same problem occurs with GRE
too, at least as of kernel 4.6.4-301.fc24.x86_64.

# Enable forwarding and loose-mode RPF on all interfaces
echo 1 | tee /proc/sys/net/ipv4/conf/*/forwarding
echo 2 | tee /proc/sys/net/ipv4/conf/*/rp_filter

# Add network namespace with a connecting veth link
ip netns add x
ip link add veth-outside type veth peer name veth-inside
ip link set dev veth-inside netns x
ip address add 10.0.0.1/30 dev veth-outside
ip netns exec x ip address add 10.0.0.2/30 dev veth-inside
ip link set dev veth-outside up
ip netns exec x ip link set dev veth-inside up

# Add ipip tunnel between the veth link addresses
ip tunnel add ipip-outside mode ipip local 10.0.0.1 remote 10.0.0.2
ip netns exec x ip tunnel add ipip-inside mode ipip local 10.0.0.2 remote 10.0.0.1
ip link set dev ipip-outside up
ip netns exec x ip link set dev ipip-inside up

# Add a route to some arbitrary external ip address to the ipip tunnel from
# inside the network namespace
ip netns exec x ip route add 192.168.1.1 dev ipip-inside

# Start some test traffic (will have src=10.0.0.2 dst=192.168.1.1)
# These will arrive in the outer/main network namespace on the
# "ipip-outside" network device, while the source address is routed
# to the "veth-outside" device.
ip netns exec x ping 192.168.1.1 & # leave running

At this point I'd expect the ping packets to be forwarded to "eth0" (or
whatever interface 192.168.1.1 is routed to). That doesn't happen, they
are instead discarded by the reverse path filter. That is, the test
packet don't show up in a "tcpdump -i eth0 host 192.168.1.1" until I
either:

1) Completely disable RPF checking on the "ipip-outside" interface:

echo 0 | tee /proc/sys/net/ipv4/conf/{all,ipip-outside}/rp_filter

Or:

2) Add a route to 10.0.0.2 to the "ipip-outside" interface (allowing a
strict mode RPF check to succeed):

ip route add 10.0.0.2 dev ipip-outside

Tore
