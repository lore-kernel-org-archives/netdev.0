From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 0/6] net: reducing memory footprint of network devices
Date: Sat,  6 May 2017 10:07:28 -0600
Message-ID: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34471 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdEFQHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:40 -0400
Received: by mail-pf0-f193.google.com with SMTP id d1so4395067pfe.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I have mentioned many times[1], at ~43+kB per instance the use of
net_devices does not scale for deployments needing 10,000+ devices. At
netconf 1.2 there was a discussion about using a net_device_common for
the minimal set of common attributes with other structs built on top of
that one for "full" devices. It provided a means for the code to know
"non-standard" net_devices. Conceptually, that approach has its merits
but it is not practical given the sweeping changes required to the code
base. More importantly though struct net_device is not the problem; it
weighs in at less than 2kB so reorganizing the code base around a
refactored net_device is not going to solve the problem. The primary
issue is all of the initializations done *because* it is a struct
net_device -- kobject and sysfs and the protocols (e.g., ipv4, ipv6,
mpls, neighbors).

So, how do you keep the desired attributes of a net device -- network
addresses, xmit function, qdisc, netfilter rules, tcpdump -- while
lowering the overhead of a net_device instance and without sweeping
changes across net/ and drivers/net/?

This patch set introduces the concept of labeling net_devices as
"lightweight", first mentioned at netdev 1.1 [1]. Users have to opt
in to lightweight devices by passing a new attribute, IFLA_LWT_NETDEV,
in the new link request. This lightweight tag is meant for virtual
devices such as vlan, vrf, vti, and dummy where the user expects to
create a lot of them and does not want the duplication of resources.
Each device type can always opt out of a lightweight label if necessary
by failing device creates.

Labeling a virtual device as "lightweight" reduces the footprint for
device creation from ~43kB to ~6kB. That reduction in memory is obtained
by:
1. no entry in sysfs
   - kobject in net_device.device is not initialized

2. no entry in procfs
   - no sysctl option for these devices

3. deferred ipv4, ipv6, mpls initialization
   - network layer must be enabled before an address can be assigned
     or mpls labels can be processed
   - enables what Florian called L2 only devices [2]

Once the core premise of a lightweight device is accepted, follow on
patches can reduce the overhead of network initializations. e.g.,

1. remove devconf per device (ipv4 and ipv6)
   - lightweight devices use the default settings rather than replicate
     the same data for each device

2. reduce / remove / opt out of snmp mibs
   - snmp6_alloc_dev and icmpv6msg_mib_device specifically is a heavy
     hitter

Patches can also be found here:
    https://github.com/dsahern/linux lwt-dev-rfc

And iproute2 here:
    https://github.com/dsahern/iproute2 lwt-dev

Example:
    ip li add foo lwd type vrf table 123

- creates VRF device 'foo' as a lightweight netdevice.


[1] http://www.netdevconf.org/1.1/proceedings/slides/ahern-aleksandrov-prabhu-scaling-network-cumulus.pdf
[2] https://www.spinics.net/lists/netdev/msg340808.html
David Ahern (6):
  net: Add accessor for kboject in a net_device
  net: Add flags argument to alloc_netdev_mqs
  net: Introduce IFF_LWT_NETDEV flag
  net: Do not intialize kobject for lightweight netdevs
  net: Delay initializations for lightweight devices
  net: add uapi for creating lightweight devices

 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c |  2 +-
 drivers/net/ethernet/tile/tilegx.c              |  2 +-
 drivers/net/tun.c                               |  2 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c |  2 +-
 include/linux/netdevice.h                       | 27 ++++++++--
 include/uapi/linux/if_link.h                    |  1 +
 net/batman-adv/sysfs.c                          | 13 ++++-
 net/bridge/br_if.c                              | 12 +++--
 net/bridge/br_sysfs_br.c                        | 17 +++---
 net/bridge/br_sysfs_if.c                        |  8 ++-
 net/core/dev.c                                  | 71 ++++++++++++++++++-------
 net/core/neighbour.c                            |  3 ++
 net/core/net-sysfs.c                            | 25 ++++++---
 net/core/rtnetlink.c                            | 10 +++-
 net/ethernet/eth.c                              |  2 +-
 net/ipv4/devinet.c                              | 18 ++++++-
 net/ipv6/addrconf.c                             |  9 ++++
 net/mac80211/iface.c                            |  2 +-
 net/mpls/af_mpls.c                              |  6 +++
 net/wireless/core.c                             | 15 ++++--
 20 files changed, 190 insertions(+), 57 deletions(-)

-- 
2.11.0 (Apple Git-81)
