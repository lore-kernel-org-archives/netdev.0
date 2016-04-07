From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 00/11] GSO partial and TSO FIXEDID support
Date: Thu, 07 Apr 2016 18:31:51 -0400
Message-ID: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34172 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbcDGWb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:31:56 -0400
Received: by mail-pf0-f182.google.com with SMTP id c20so63709534pfc.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:31:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series represents my respun version of the GSO partial work.
The major changes from the first version is that we are no longer making
the decision to mangle IP IDs transparently at the device.  Instead it is
now pushed up to the tunnel layer itself so that the tunnel is not
responsible for deciding if the IP IDs will be static or fixed for a given
TSO.

I'm a bit jammed up at the moment as I am trying to determine the best spot
to make the same change I currently am for VXLAN and GENEVE with GRE and
IPIP tunnels.  I'm assuming the correct spot would be somewhere near
iptunnel_handle_offload as I did for the other two tunnel types I have
already updated, but the flow based tunnels for GRE seem to be making it a
bit more complicated as I am not sure if a tunnel dev actually exists for
those tunnels.

This patch series is meant to apply to the dev-queue branch Jeff Kirsher's
next-queue tree at:
https://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git

I chose his tree as the Intel driver patches would not apply otherwise.

Patch 1 from the series is a copy of the patch recently accepted for the
net tree.  It is needed in this series to avoid merge conflicts later on as
we were making other changes in the GRO code.

---

Alexander Duyck (11):
      GRE: Disable segmentation offloads w/ CSUM and we are encapsulated via FOU
      ethtool: Add support for toggling any of the GSO offloads
      GSO: Add GSO type for fixed IPv4 ID
      GRO: Add support for TCP with fixed IPv4 ID field, limit tunnel IP ID values
      GSO: Support partial segmentation offload
      VXLAN: Add option to mangle IP IDs on inner headers when using TSO
      GENEVE: Add option to mangle IP IDs on inner headers when using TSO
      Documentation: Add documentation for TSO and GSO features
      i40e/i40evf: Add support for GSO partial with UDP_TUNNEL_CSUM and GRE_CSUM
      ixgbe/ixgbevf: Add support for GSO partial
      igb/igbvf: Add support for GSO partial


 Documentation/networking/segmentation-offloads.txt |  127 ++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |    6 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |    7 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |    7 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |    6 +
 drivers/net/ethernet/intel/igb/igb_main.c          |  119 ++++++++++---
 drivers/net/ethernet/intel/igbvf/netdev.c          |  180 ++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  115 +++++++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  122 +++++++++++---
 drivers/net/geneve.c                               |   24 ++-
 drivers/net/vxlan.c                                |   16 ++
 include/linux/netdev_features.h                    |    8 +
 include/linux/netdevice.h                          |   11 +
 include/linux/skbuff.h                             |   27 ++-
 include/net/udp_tunnel.h                           |    8 -
 include/net/vxlan.h                                |    1 
 include/uapi/linux/if_link.h                       |    2 
 net/core/dev.c                                     |   33 ++++
 net/core/ethtool.c                                 |    4 
 net/core/skbuff.c                                  |   29 +++
 net/ipv4/af_inet.c                                 |   70 ++++++--
 net/ipv4/fou.c                                     |    6 +
 net/ipv4/gre_offload.c                             |   35 +++-
 net/ipv4/ip_gre.c                                  |   13 +
 net/ipv4/tcp_offload.c                             |   30 +++
 net/ipv4/udp_offload.c                             |   27 ++-
 net/ipv6/ip6_offload.c                             |   21 ++
 27 files changed, 837 insertions(+), 217 deletions(-)
 create mode 100644 Documentation/networking/segmentation-offloads.txt
