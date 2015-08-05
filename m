From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 00/10] VRF-lite - v4
Date: Wed,  5 Aug 2015 11:14:43 -0600
Message-ID: <1438794894-70217-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34995 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbHERQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 13:16:20 -0400
Received: by iodd187 with SMTP id d187so55946107iod.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 10:16:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the context of internet scale routing a requirement that always comes
up is the need to partition the available routing tables into disjoint
routing planes. A specific use case is the multi-tenancy problem where
each tenant has their own unique routing tables and in the very least
need different default gateways.

This patch allows the ability to create virtual router domains (aka VRFs
(VRF-lite to be specific) in the linux packet forwarding stack. The main
observation is that through the use of rules and socket binding to interfaces,
all the facilities that we need are already present in the infrastructure. What
is missing is a handle that identifies a routing domain and can be used to
gather applicable rules/tables and uniqify neighbor selection. The scheme used
needs to preserves the notions of ECMP, and general routing principles.

This driver is a cross between functionality that the IPVLAN driver
and the Team drivers provide where a device is created and packets
into/out of the routing domain are shuttled through this device. The
device is then used as a handle to identify the applicable rules. The
VRF device is thus the layer3 equivalent of a vlan device.

The very important point to note is that this is only a Layer3 concept
so L2 tools (e.g., LLDP) do not need to be run in each VRF, processes can
run in unaware mode or select a VRF to be talking through. Also the
behavioral model is a generalized application of the familiar VRF-Lite
model with some performance paths that need optimization. (Specifically
the output route selector that Roopa, Robert, Thomas and EricB are
currently discussing on the MPLS thread)

High Level points
=================
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

                                                 N2
           N1 (all configs here)          +---------------+
    +--------------+                      |               |
    |swp1 :10.0.1.1+----------------------+swp1 :10.0.1.2 |
    |              |                      |               |
    |swp2 :10.0.2.1+----------------------+swp2 :10.0.2.2 |
    |              |                      +---------------+
    | VRF 1        |
    | table 5      |
    |              |
    +---------------+
    |              |
    | VRF 2        |                             N3
    | table 6      |                      +---------------+
    |              |                      |               |
    |swp3 :10.0.2.1+----------------------+swp1 :10.0.2.2 |
    |              |                      |               |
    |swp4 :10.0.3.1+----------------------+swp2 :10.0.3.2 |
    +--------------+                      +---------------+


Given the topology above, the setup needed to get the basic VRF
functions working would be

Create the VRF devices and associate with a table
    ip link add vrf1 type vrf table 5
    ip link add vrf2 type vrf table 6

Install the lookup rules that map table to VRF domain
    ip rule add pref 200 oif vrf1 lookup 5
    ip rule add pref 200 iif vrf1 lookup 5
    ip rule add pref 200 oif vrf2 lookup 6
    ip rule add pref 200 iif vrf2 lookup 6

    ip link set vrf1 up
    ip link set vrf2 up

Enslave the routing member interfaces
    ip link set swp1 master vrf1
    ip link set swp2 master vrf1
    ip link set swp3 master vrf2
    ip link set swp4 master vrf2

Connected and local routes are automatically moved from main and local
tables to the VRF table.

ping using VRF0 is simply
    ping -I vrf0 10.0.1.2


Design Highlights
=================
If a device is enslaved to a VRF device (ie., associated with a VRF)
then:
1. Rx path
   The master device index is used as the iif for all lookups.

2. Tx path
   Similarly, for Tx the VRF device oif is used in the flow to direct
   lookups to the table associated with the VRF via its rule. From there
   the FLOWI_FLAG_VRFSRC flag is used to indicate that the oif should
   not be used for FIB table lookups.

3. Connected and local routes
   On link up for a device, connected and local routes are added to the
   table associated with the VRF device, rather than the local and main
   tables.

4. Socket lookups
   Socket lookups use the VRF device for comparison with sk_bound_dev_if.
   If a socket is not bound to a device a socket match can happen based
   on destination address, port and protocol in which case a VRF global
   or agnostic process handles the connection (ie., this allows 1 listener
   socket to handle connections across VRFs). The child socket becomes
   bound to the VRF (sk_bound_dev_if is set to the VRF device).

5. Neighbor entries
   Neighbor entries are not impacted by the VRF device. Entries are
   associated with a particular interface; the VRF association is indirect
   via the interface-to-VRF device enslavement.


Version 4
- builds are clean with and without VRF device enabled (no, yes and module)

- tightened the driver implementation
  + device add/delete, slave add/remove, and module unload are all clean

- fixed RCU references
  + with RCU and lock debugging enabled changes are clean through the
    suite of tests

- TX path uses custom dst, so patch refactoring rtable allocation is
  dropped along with the patch adding rt_nexthop helper

- dropped the task patch that adds default bind to interface for sockets
  and the associated chvrf example command
  + the patches are a convenience for running unmodified code. They
    are not needed for the core functionality. Any application with
    support for SO_BINDTODEVICE works properly with this patch set.


Version 3
- addressed comments from first 2 RFCs with the exception of the name
  Nicolas: We will do the name conversion once we agree on what the
           correct name should be (vrf, mrf or something else)

-  packets flow through the VRF device in both directions allowing the
   following:
   - tcpdump -i vrf<n>
   - tc rules on vrf device
   - netfilter rules on vrf device


TO-DO
=====
1. IPv6

2. ip fragments

3. ipsec, xfrms

4. listen filter to restrict VRF connections
   - i.e., bind to VRF's a, b, c only or NOT VRFs e, f, g


Eric B:
  I think I understand your points regarding ip fragments and ipsec now.
  I will release additional patches for both, but it takes time. For
  example, I have ipsec working with VRFs implemented using the VRF
  driver but more changes are needed. Once I have multiple tunnels with
  overlapping network spaces working I will be sending out patches for
  review.


Thanks to Nikolay for his many, many code reviews whipping the device
driver into shape, and bug-Fixes and ideas from Hannes, Roopa Prabhu,
Jon Toppins, Jamal.

Patches can also be pulled from:
    https://github.com/dsahern/linux.git, vrf-dev-v4 branch
    https://github.com/dsahern/iproute2,  vrf-dev-v4 branch

David Ahern (10):
  net: Introduce VRF related flags and helpers
  net: Use VRF device index for lookups on RX
  net: Use VRF device index for lookups on TX
  udp: Handle VRF device
  net: Add inet_addr lookup by table
  net: Fix up inet_addr_type checks
  net: Add routes to the table associated with the device
  net: Use passed in table for nexthop lookups
  net: Use VRF device index for socket lookups
  net: Introduce VRF device driver

 drivers/net/Kconfig          |   7 +
 drivers/net/Makefile         |   1 +
 drivers/net/vrf.c            | 715 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h    |  20 ++
 include/net/flow.h           |   1 +
 include/net/route.h          |   7 +
 include/net/vrf.h            | 176 +++++++++++
 include/uapi/linux/if_link.h |   9 +
 net/ipv4/af_inet.c           |  13 +-
 net/ipv4/arp.c               |  15 +-
 net/ipv4/fib_frontend.c      |  66 +++-
 net/ipv4/fib_semantics.c     |  44 ++-
 net/ipv4/fib_trie.c          |   7 +-
 net/ipv4/icmp.c              |   9 +-
 net/ipv4/route.c             |   8 +-
 net/ipv4/syncookies.c        |   5 +-
 net/ipv4/tcp_input.c         |   6 +-
 net/ipv4/tcp_ipv4.c          |  11 +-
 net/ipv4/udp.c               |  25 +-
 19 files changed, 1102 insertions(+), 43 deletions(-)
 create mode 100644 drivers/net/vrf.c
 create mode 100644 include/net/vrf.h

-- 
2.3.2 (Apple Git-55)
