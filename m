From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 0/6] Proposal for VRF-lite - v2
Date: Mon,  6 Jul 2015 09:03:14 -0600
Message-ID: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36753 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbGFPD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:29 -0400
Received: by igrv9 with SMTP id v9so155738760igr.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

In this version connected routes are automatically moved from main table
to VRF table.

ping using VRF0 is simply
    ping -I vrf0 -I <optional-src-addr> 10.0.1.2

Or using the task context and a command such as the example chvrf in
patch 6 unmodified applications are run in a VRF context using:
   chvrf -v 1 ping 10.0.1.2


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

TO-DO
=====
1. ipv4 multicast

2. ICMP and error path handling on connection attempts
   - e.g., connection attempt to a port with no listener

3. IPv6

4. netfilter integration

5. listen filter to restrict VRF connections
   - i.e., bind to VRF's a, b, c only or NOT VRFs e, f, g


Bug-Fixes and ideas from Hannes, Roopa Prabhu, Jon Toppins, Jamal

Patches can also be pulled from:
    https://github.com/dsahern/linux.git, vrf-dev-4.1 branch
    https://github.com/dsahern/iproute2,  vrf-dev-4.1 branch


Shrijeet Mukherjee and David Ahern (6):
  fib: export symbols
  net: Preparation for vrf device
  net: Introduce VRF device driver - v2
  net: Modifications to ipv4 stack for VRF devices
  net: Add sk_bind_dev_if to task_struct
  net: Add chvrf command

 drivers/net/Kconfig           |   7 +
 drivers/net/Makefile          |   1 +
 drivers/net/vrf.c             | 486 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h     |  21 ++
 include/linux/sched.h         |   3 +
 include/net/flow.h            |   1 +
 include/net/inet_hashtables.h |   9 +-
 include/net/route.h           |   4 +
 include/net/vrf.h             |  71 ++++++
 include/uapi/linux/if_link.h  |   9 +
 include/uapi/linux/prctl.h    |   4 +
 kernel/fork.c                 |   2 +
 kernel/sys.c                  |  35 +++
 net/ipv4/af_inet.c            |   1 +
 net/ipv4/fib_frontend.c       |  31 ++-
 net/ipv4/fib_semantics.c      |  25 ++-
 net/ipv4/fib_trie.c           |   8 +-
 net/ipv4/icmp.c               |   4 +
 net/ipv4/ping.c               |   3 +-
 net/ipv4/raw.c                |   5 +-
 net/ipv4/route.c              |  12 +-
 net/ipv4/syncookies.c         |   4 +-
 net/ipv4/tcp_input.c          |   6 +-
 net/ipv4/tcp_ipv4.c           |   6 +-
 net/ipv4/udp.c                |   2 +
 net/ipv6/af_inet6.c           |   1 +
 tools/net/Makefile            |   6 +-
 tools/net/chvrf.c             | 225 +++++++++++++++++++
 28 files changed, 962 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/vrf.c
 create mode 100644 include/net/vrf.h
 create mode 100644 tools/net/chvrf.c

-- 
2.3.2 (Apple Git-55)
