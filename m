From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] bridge: per vlan dst_metadata support
Date: Mon, 30 Jan 2017 21:57:10 -0800
Message-ID: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36557 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdAaF6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 00:58:49 -0500
Received: by mail-pf0-f170.google.com with SMTP id 189so100262027pfu.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 21:57:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

High level summary:
lwt and dst_metadata have enabled vxlan l3 deployments
to use a single vxlan netdev for multiple vnis eliminating the scalability
problem with using a single vxlan netdev per vni. This series tries to
do the same for vxlan netdevs in pure l2 bridged networks.
Use-case/deployment and details are below.

Deployment scerario details:
As we know VXLAN is used to build layer 2 virtual networks across the
underlay layer3 infrastructure. A VXLAN tunnel endpoint (VTEP)
originates and terminates VXLAN tunnels. And a VTEP can be a TOR switch
or a vswitch in the hypervisor. This patch series mainly
focuses on the TOR switch configured as a Vtep. Vxlan segment ID (vni)
along with vlan id is used to identify layer 2 segments in a vxlan
overlay network. Vxlan bridging is the function provided by Vteps to terminate
vxlan tunnels and map the vxlan vni to traditional end host vlan. This is
covered in the "VXLAN Deployment Scenarios" in sections 6 and 6.1 in RFC 7348.
To provide vxlan bridging function, a vtep has to map vlan to a vni. The rfc
says that the ingress VTEP device shall remove the IEEE 802.1Q VLAN tag in
the original Layer 2 packet if there is one before encapsulating the packet
into the VXLAN format to transmit it through the underlay network. The remote
VTEP devices have information about the VLAN in which the packet will be
placed based on their own VLAN-to-VXLAN VNI mapping configurations.

Existing solution:
Without this patch series one can deploy such a vtep configuration by
adding the local ports and vxlan netdevs into a vlan filtering bridge.
The local ports are configured as trunk ports carrying all vlans.
A vxlan netdev per vni is added to the bridge. Vlan mapping to vni is
achieved by configuring the vlan as pvid on the corresponding vxlan netdev.
The vxlan netdev only receives traffic corresponding to the vlan it is mapped
to. This configuration maps traffic belonging to a vlan to the corresponding
vxlan segment.

          -----------------------------------
         |              bridge               |
         |                                   |
          -----------------------------------
            |100,200       |100 (pvid)    |200 (pvid)
            |              |              |
           swp1          vxlan1000      vxlan2000
                    
This provides the required vxlan bridging function but poses a
scalability problem with using a separate vxlan netdev for each vni.

Solution in this patch series:
The Goal is to use a single vxlan device to carry all vnis similar
to the vxlan collect metadata mode but additionally allowing the bridge
and vxlan driver to carry all the forwarding information and also learn.
This implementation uses the existing dst_metadata infrastructure to map
vlan to a tunnel id.
- vxlan driver changes:
    - enable collect metadata mode to be used with learning,
      replication and fdb
    - A single fdb table hashed by (mac, vni)
    - rx path already has the vni
    - tx path expects a vni in the packet with dst_metadata and relies
      on learnt or static forwarding information table to forward the packet

- Bridge driver changes: per vlan dst_metadata support:
    - Our use case is vxlan and 1-1 mapping between vlan and vni, but I have
      kept the api generic for any tunnel info
    - Uapi to configure/unconfigure/dump per vlan tunnel data
    - new bridge port flag to turn this feature on/off. off by default
    - ingress hook:
        - if port is a tunnel port, use tunnel info in
          attached dst_metadata to map it to a local vlan
    - egress hook:
        - if port is a tunnel port, use tunnel info attached to vlan
          to set dst_metadata on the skb

Other approaches tried and vetoed:
- tc vlan push/pop and tunnel metadata dst:
    - though tc can be used to do part of this, these patches address a deployment
      case where bridge driver vlan filtering and forwarding information
      database along with vxlan driver forwarding information table and learning
      are required.
- making vxlan driver understand vlan-vni mapping:
    - I had a series almost ready with this one but soon realized
      it duplicated a lot of vlan handling code in the vxlan driver

Roopa Prabhu (5):
  ip_tunnels: new IP_TUNNEL_INFO_BRIDGE flag for ip_tunnel_info mode
  vxlan: support fdb and learning in COLLECT_METADATA mode
  bridge: uapi: add per vlan tunnel info
  bridge: per vlan dst_metadata netlink support
  bridge: vlan dst_metadata hooks in ingress and egress paths

 drivers/net/vxlan.c            |  211 +++++++++++++++++-----------
 include/linux/if_bridge.h      |    1 +
 include/net/ip_tunnels.h       |    1 +
 include/uapi/linux/if_bridge.h |   11 ++
 include/uapi/linux/if_link.h   |    1 +
 include/uapi/linux/neighbour.h |    1 +
 net/bridge/Makefile            |    5 +-
 net/bridge/br_forward.c        |    2 +-
 net/bridge/br_input.c          |    8 +-
 net/bridge/br_netlink.c        |  140 +++++++++++++------
 net/bridge/br_netlink_tunnel.c |  296 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h        |   12 ++
 net/bridge/br_private_tunnel.h |   47 +++++++
 net/bridge/br_vlan.c           |   24 +++-
 net/bridge/br_vlan_tunnel.c    |  203 +++++++++++++++++++++++++++
 15 files changed, 837 insertions(+), 126 deletions(-)
 create mode 100644 net/bridge/br_netlink_tunnel.c
 create mode 100644 net/bridge/br_private_tunnel.h
 create mode 100644 net/bridge/br_vlan_tunnel.c

-- 
1.7.10.4
