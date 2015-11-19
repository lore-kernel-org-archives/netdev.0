From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 00/15] net: The beginning of the end for NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM
Date: Thu, 19 Nov 2015 11:55:46 -0800
Message-ID: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1961 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754580AbbKST4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:11 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrA8G032534
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:10 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6nbq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:10 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 936f72908ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:08 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Background:

This patch set starts to address one front in the battle against
protocol ossification. Protocol ossification describes the state
that we have arrived at in the evolution of the Internet where we are
materially limited to only using a very narrow range of protocols
and protocol features. For instance, only TCP and UDP is sufficiently
supported on the Internet so that deploying alternative protocols,
such as SCTP and DCCP, are non-starters. Similarly, IP options and IPv6
extension headers are typically not considered feasible for wide
deployment, so we have loss the extensibility of IP protocols.

Protocol ossification is not only a problem on the Internet, but in
the data center as well. The root cause of this seems to be narrow,
protocol specific optimizations implemented in switches (for doing
EMCP) and in NICs (NIC offloads). These tend to be performance
optimization around TCP and UDP packets, and these have become
requirements to implement performant network solutions at scale.

Attempts to deal with protocol ossification in data center have yielded
ad hoc, sub-optimal solutions. A main driver of foo-over-UDP (e.g.
GRE/UDP, MPLS/UDP) is to leverage the existing EMCP and RSS support for
UDP by setting the source port as an entropy value. This has seen some
success, but the cost of additional overhead and layering limits its
usefulness.  An even more extreme solution is STT where non-TCP packets
are spoofed as TCP to leverage NIC offloads.

This patch set endeavours to address protocol ossification caused by
techniques used in transmit checksum offload for NICs. Future work
will address protocol ossification in the other primary NIC offloads--
namely receive checksum offload, LSO, LRO, and RSS.

NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM:

NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM exemplify the problem of protocol
ossification. These features are relics from a simpler time in the
Internet, before encapsulation, before GRE and  IPIP. Many hardware
vendors only saw the need to provide checksum offload for simple UDP and
TCP packets over IPv4 (IPv6 support is an afterthought also). In today's
Internet and data centers, checksum offload is well established as a
valuable feature, but we can no longer afford to be contsrained to
use a handful of protocols and features that are supported at the
discretion of NIC vendors. Generic and protocol agnostic methods are
needed.

The actual interface that the stack uses with drivers for checksum
offload is CHECKSUM_PARTIAL. This is a generic and protocol agnostic
interface. A driver for a device that supports this generic
interface advertises NETIF_F_HW_CSUM.

Goals of this patch set:

We propose that drivers advertise NETIF_F_HW_CSUM instead of protocol
specific values of NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.  If the
driver's device is constrained (for instance it can only offlaod simple
IPv4 and IPv6 packets) then these constraints can be checked in the
transmit path and skb_checksum_help would be called for packets that the
driver is unable to offload. In order to facilitate this, we add some
helper functions that takes a specification argument indicating the
type of packets a device is able to offload. If a packet does not match
the specification, the helper function calls skb_checksum_help.

Benefits of this approach are:
  - Simplify the stack and clarify the interface for checksum offload
  - Encourage NIC vendors to implement the generic. protocol agnostic
    checksum offload methods in hardware
  - Encourage feature parity in NIC offloads for IPv4 and IPv6

Many drivers advertise NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM and it
probably isn't feasible to convert them all in a given time frame
(although if we could this would be a great simplification to the
stack). A reasonable direction may be to declare that new drivers must
use NETIF_F_HW_CSUM as NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM are
considered deprecated.

There is a class of drivers that should now be converted to advertise
NETIF_F_HW_CSUM, namely those that support offload of ecapsulated
checksums. These drivers have to date been using skb->encapsulation
to infer that checksum offload is being performed for an encapsulated
checksum. This is strictly not correct. skb->encapsulation
indicates that the inner headers are valid in the skbuff, whereas
the stack indicates checksum offload arguments exclusively in csum_start
and csum_offset. At some point we may want to set the inner headers for
an skbuff but offload the outer transport checksum, so this needs to be
fixed.

In this patch set:

  - Rename some of constants involved in checksum offload to be more
    reflective of their function
  - Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM entirely as
    unnecessary convolutions
  - Fix conditions in tcp_sendpage and tcp_sendmsg to take IP protocol
    into account when determining if checksum offload can be done
  - Add driver helper functions for determining if a checksum can
    be offloaded to a device. If not, the helper function can call
    skb_checksum_help
  - Convert bnx2x, bnxt, emulex, fm10k, ixgbe, mlx4, and qlogic drivers
    to advertise NETIF_F_HW_CSUM. The helper functions are called
    to checksum device constraints (IP protocol, UDP or TCP, etc.)
  - Document the checksum offload interface between the stack and
    drivers with detail and specifics

Testing:

Have been testing ixgbe and mlx4. No noticeable regressions seen yet.

Tom Herbert (15):
  net: Add skb_inner_transport_offset function
  sctp: Rename NETIF_F_SCTP_CSUM to NETIF_F_SCTP_CRC
  fcoe: Use CHECKSUM_PARTIAL to indicate CRC offload
  net: Rename NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK
  net: Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM
  tcp: Fix conditions to determine checksum offload
  net: Add driver helper functions to determine checksum offloadability
  net: Elaborate on checksum offload interface description
  bnx2x: Convert to advertise NETIF_F_HW_CSUM
  bnxt: Convert to advertise NETIF_F_HW_CSUM
  emulex: Convert to advertise NETIF_F_HW_CSUM
  fm10k: Convert to advertise NETIF_F_HW_CSUM
  ixgbe: Convert to advertise NETIF_F_HW_CSUM
  mlx4: Convert to advertise NETIF_F_HW_CSUM
  qlogic: Convert to advertise NETIF_F_HW_CSUM

 drivers/net/bonding/bond_main.c                    |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  15 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   6 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  21 ++-
 drivers/net/ethernet/emulex/benet/be.h             |   1 +
 drivers/net/ethernet/emulex/benet/be_main.c        |  32 +++--
 drivers/net/ethernet/ibm/ibmveth.c                 |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c      |  16 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  47 +++++--
 drivers/net/ethernet/jme.c                         |   2 +-
 drivers/net/ethernet/marvell/sky2.c                |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   6 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  16 ++-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  10 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  16 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  10 +-
 drivers/net/ethernet/sfc/efx.c                     |   4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   4 +-
 drivers/net/ipvlan/ipvlan_main.c                   |   2 +-
 drivers/net/loopback.c                             |   2 +-
 drivers/net/macvlan.c                              |   4 +-
 drivers/net/macvtap.c                              |   2 +-
 drivers/net/team/team.c                            |   3 +-
 drivers/net/usb/r8152.c                            |   2 +-
 drivers/scsi/fcoe/fcoe.c                           |   2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   2 +-
 include/linux/if_vlan.h                            |   2 +-
 include/linux/netdev_features.h                    |  14 +-
 include/linux/netdevice.h                          | 118 ++++++++++++++--
 include/linux/skbuff.h                             | 143 +++++++++++++++----
 include/net/sock.h                                 |   9 ++
 include/net/vxlan.h                                |   2 +-
 net/8021q/vlan_dev.c                               |   4 +-
 net/core/dev.c                                     | 153 +++++++++++++++++++--
 net/core/ethtool.c                                 |   4 +-
 net/core/pktgen.c                                  |   4 +-
 net/ipv4/ip_output.c                               |   2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |   3 +-
 net/ipv4/tcp.c                                     |   4 +-
 net/ipv4/udp.c                                     |   3 +-
 net/ipv4/udp_offload.c                             |   5 +-
 net/ipv6/ip6_output.c                              |   2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |   3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c              |   2 +-
 net/sctp/output.c                                  |   2 +-
 50 files changed, 571 insertions(+), 166 deletions(-)

-- 
2.4.6
