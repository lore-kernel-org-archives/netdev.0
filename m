From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: [RFC net-next 0/3] Proposal for VRF-lite
Date: Mon,  8 Jun 2015 11:35:31 -0700
Message-ID: <cover.1433561681.git.shm@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33261 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752405AbbFHSfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:35:52 -0400
Received: by qkhg32 with SMTP id g32so82489556qkh.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:35:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrijeet Mukherjee <shm@cumulusnetworks.com>

In the context of internet scale routing a requirement that always
comes up is the need to partition the available routing tables into
disjoint routing planes. A specific use case is the multi-tenancy
problem where each tenant has their own unique routing tables and in
the very least need different default gateways.

This is an attempt to build the ability to create virtual router
domains aka VRF's (VRF-lite to be specific) in the linux packet
forwarding stack. The main observation is that through the use of
rules and socket binding to interfaces, all the facilities that we
need are already present in the infrastructure. What is missing is a
handle that identifies a routing domain and can be used to gather
applicable rules/tables and uniqify neighbor selection. The scheme
used needs to preserves the notions of ECMP, and general routing
principles.

This driver is a cross between functionality that the IPVLAN driver
and the Team drivers provide where a device is created and packets
into/out of the routing domain are shuttled through this device. The
device is then used as a handle to identify the applicable rules. The
VRF device is thus the layer3 equivalent of a vlan device.

The very important point to note is that this is only a Layer3 concept
so LLDP like tools do not need to be run in each VRF, processes can
run in unaware mode or select a VRF to be talking through. Also the
behavioral model is a generalized application of the familiar VRF-Lite
model with some performance paths that need optimization. (Specifically
the output route selector that Roopa, Robert, Thomas and EricB are
currently discussing on the MPLS thread)

High Level points

1. Simple overlay driver (minimal changes to current stack)
   * uses the existing fib tables and fib rules infrastructure
2. Modelled closely after the ipvlan driver
3. Uses current API and infrastructure.
   * Applications can use SO_BINDTODEVICE or cmsg device indentifiers
     to pick VRF (ping, traceroute just work)
   * Standard IP Rules work, and since they are aggregated against the
     device, scale is manageable
4. Completely orthogonal to Namespaces and only provides separation in
   the routing plane (and ARP)
5. Debugging is built-in as tcpdump and counters on the VRF device
   works as is.

                                                 N2
           N1 (all configs here)          +---------------+
    +--------------+                      |               |
    |swp1 :10.0.1.1+----------------------+swp1 :10.0.1.2 |
    |              |                      |               |
    |swp2 :10.0.2.1+----------------------+swp2 :10.0.2.2 |
    |              |                      +---------------+
    | VRF 0        |
    | table 5      |
    |              |
    +---------------+
    |              |
    | VRF 1        |                             N3
    | table 6      |                      +---------------+
    |              |                      |               |
    |swp3 :10.0.2.1+----------------------+swp1 :10.0.2.2 |
    |              |                      |               |
    |swp4 :10.0.3.1+----------------------+swp2 :10.0.3.2 |
    +--------------+                      +---------------+


Given the topology above, the setup needed to get the basic VRF
functions working would be

# Create the VRF devices
ip link add vrf0 type vrf table 5
ip link add vrf1 type vrf table 6

# Enslave the routing member interfaces
ip link set swp1 master vrf0
ip link set swp2 master vrf0
ip link set swp3 master vrf1
ip link set swp4 master vrf1

ip link set vrf0 up
ip link set vrf1 up

# move the connected routes from the main table to the 
# correct table

# move vrf0 connected routes from main to table 5
ip route del 10.0.1.0/24
ip route del 10.0.2.0/24
ip route add 10.0.1.0/24 dev swp1 table 5
ip route add 10.0.2.0/24 dev swp2 table 5

# move vrf1 connected routes from main to table 6
ip route del 10.0.2.0/24
ip route del 10.0.3.0/24
ip route add 10.0.3.0/24 dev swp4 table 6
ip route add 10.0.2.0/24 dev swp3 table 6

# Install the lookup rules that map table to VRF domain
ip rule add pref 200 oif vrf0 lookup 5
ip rule add pref 200 iif vrf0 lookup 5
ip rule add pref 200 oif vrf1 lookup 6
ip rule add pref 200 iif vrf1 lookup 6

# ping using VRF0 is simply
ping -I vrf0 -I <optional-src-addr> 10.0.1.2

# tcp/udp applications specify the interface using SO_BINDTODEVICE or
cmsg hdr pointing to the desired vrf device.


Design Highlights

1. RX path

The Basic action here is that for IP traffic (arp_rcv, icmp_rcv and
ip_rcv) we check the incoming interface to see if it is enslaved. If
enslaved, then the master device is used as the device for all lookups
allowing the routing table for the lookup to be selected by the IIF
rule

1.a Forwarded Traffic

In ip_route_input_slow we move the IIF to be that of the master
device. This causes the IIF rule that maps to the VRF device to be
applied forcing the packet to be looked up by the table that is
associated with that device. For forwarded traffic the VRF device
provides a convenient hook to group the forwarding action for a group
of inbound ports.

1.b Locally terminated traffic

Packets are checked in arp_rcv, icmp_rcv and ip_rcv and the IIF is
moved to the VRF device if the current IIF is enslaved. for LOCAL
traffic this has two implications.

We need the LOCAL table entries in the actual VRF device's routing
table as well, and if that is present then we will match in the flow
hashes using the device which the socket is bound to. Since using
VRF's requires the socket to bind to an interface (netdev) that is
what receive hash is going to resolve to.  all incoming frames
destined to LOCAL will need to have it's iff changed

2. TX path

2.a Locally originated traffic

The Basic point is here the oif override option that already exists in
the linux kernel. Currently if the destination device exists (and thus
is local), the flow_output_key functions generate a route to send the
pkt towards the device. Leveraging that scheme (this can be
optimized), we send the outbound pkts directly to the VRF device's
xmit function. Since we can only specify one interface there is no
concerns over ECMP, or missing pkts. Once the packet lands, the xmit
function marks the pkt so that it hits the OIF rule for that VRF
device and the proper table lookup happens and the pkt is sent along
by normal fwding actions. The only change needed in the stack (with no
added cost) is to check a FL4 flag that indicates it was originated by
the VRF driver and the oif hint is to be ignored

2.b Overlapping neighbor entries

Since the outgoing packet (socket) needs to specify the VRF domain and
we reject fwding through a device that is not enslaved, by picking the
VRF device we decide which path the packet will go through.

Considerations

ARP

The LOCAL table here is a pain, and needs to be melded into the main
table that will require special handling of ARP. ARP replies are sent
to the generic stack, and need to be accepted by hitting a LOCAL
route. If the LOCAL route is in a VRF table, then ARP replies miss
classification and end up being fwded through to the default route. If
the ARP replies are redirected to be seen as received on the VRF
device then the ARP entry is registered against the VRF device and
final forwarding using physical ports will not complete. Currently
enslaving will install the "local" route into the table associated
with the VRF device. Un-enslave will put the local route back into
LOCAL table. Hannes has a plan to work this into a per VRF local table
concept. Update : fixed this with a specific change into the arp stack

Route Leaking and Policy Routing

Policy Routing needs standard rule precedence and using fw_mark to
selective apply policies just work.  Route Leaking is an interesting
angle. Since the Nexthops used in the final forwarding step all belong
to the same namespace, there is no restriction on which Nexthop can be
used in which table. The route lookup in the context of the VRF table
enforces that it does not forward through non-slave interfaces, so
that it does not accidentally leak.
However since we are using the standard fib rules on a mismatch in the
route table that a VRF is pointing to, an attempt will be made to fwd
the packet from the next routing table (in the example shown above it
will end up on the default route of the main table)

Connected route management is still a little fragile ..

Bug-Fixes,Ideas from Hannes, David Ahern, Roopa Prabhu, Jon Toppins
                     Jamal

Shrijeet Mukherjee (3):
  Symbol preparation for VRF driver
  VRF driver and needed infrastructure
  rcv path changes for vrf traffic

 drivers/net/Kconfig          |    6 +
 drivers/net/Makefile         |    1 +
 drivers/net/vrf.c            |  654 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h    |   10 +
 include/net/flow.h           |    1 +
 include/net/vrf.h            |   19 ++
 include/uapi/linux/if_link.h |    9 +
 net/ipv4/fib_frontend.c      |   15 +-
 net/ipv4/fib_trie.c          |    9 +-
 net/ipv4/icmp.c              |    6 +
 net/ipv4/route.c             |    3 +-
 11 files changed, 727 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/vrf.c
 create mode 100644 include/net/vrf.h

-- 
1.7.10.4
