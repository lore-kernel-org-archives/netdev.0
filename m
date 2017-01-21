From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata support
Date: Fri, 20 Jan 2017 21:46:51 -0800
Message-ID: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36536 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750800AbdAUFrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 00:47:02 -0500
Received: by mail-pf0-f178.google.com with SMTP id 189so27521808pfu.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 21:47:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

High level summary:
lwt and dst_metadata/collect_metadata have enabled vxlan l3 deployments
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
by adding the local ports and vxlan netdevs into a vlan filtering bridge.
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
scalability problem with using a single vxlan netdev for each vni.

Solution in this patch series:
The Goal is to use a single vxlan device to carry all vnis similar
to the vxlan collect metadata mode but vxlan driver still carrying all
the forwarding information.
- vxlan driver changes:
    - enable collect metadata mode device to be used with learning,
      replication, fdb
    - A single fdb table hashed by (mac, vni)
    - rx path already has the vni
    - tx path expects a vni in the packet with dst_metadata and vxlan
      driver has all the forwarding information for the vni in the
      dst_metadata.

- Bridge driver changes: per vlan LWT and dst_metadata support:
    - Our use case is vxlan and 1-1 mapping between vlan and vni, but I have
      kept the api generic for any tunnel info
    - Uapi to configure/unconfigure/dump per vlan tunnel data
    - new bridge port flag to turn this feature on/off. off by default
    - ingress hook:
        - if port is a lwt tunnel port, use tunnel info in
          attached dst_metadata to map it to a local vlan
    - egress hook:
        - if port is a lwt tunnel port, use tunnel info attached to vlan
          to set dst_metadata on the skb

Other approaches tried and vetoed:
- tc vlan push/pop and tunnel metadata dst:
    - posses a tc rule scalability problem (2 rules per vni)
    - cannot handle the case where a packet needs to be replicated to
      multiple vxlan remote tunnel end-points.. which the vxlan driver
      can do today by having multiple remote destinations per fdb.
- making vxlan driver understand vlan-vni mapping:
    - I had a series almost ready with this one but soon realized
      it duplicated a lot of vlan handling code in the vxlan driver

This series is briefly tested for functionality. Sending it out as RFC while
I continue to test it more. There are some rough edges which I am in the process
of fixing.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (5):
  ip_tunnels: new IP_TUNNEL_INFO_BRIDGE flag for ip_tunnel_info mode
  vxlan: make COLLECT_METADATA mode bridge friendly
  bridge: uapi: add per vlan tunnel info
  bridge: vlan lwt and dst_metadata netlink support
  bridge: vlan lwt dst_metadata hooks in ingress and egress paths

 drivers/net/vxlan.c            |  209 ++++++++++++--------
 include/linux/if_bridge.h      |    1 +
 include/net/ip_tunnels.h       |    1 +
 include/uapi/linux/if_bridge.h |   11 ++
 include/uapi/linux/if_link.h   |    1 +
 include/uapi/linux/neighbour.h |    1 +
 net/bridge/br_input.c          |    5 +
 net/bridge/br_netlink.c        |  410 ++++++++++++++++++++++++++++++++++------
 net/bridge/br_private.h        |   22 +++
 net/bridge/br_vlan.c           |  193 ++++++++++++++++++-
 10 files changed, 717 insertions(+), 137 deletions(-)

-- 
1.7.10.4
