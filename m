From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 0/9] RFC6864 compliant GRO and GSO partial offload
Date: Fri, 18 Mar 2016 16:24:38 -0700
Message-ID: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34703 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbcCRXYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:24:40 -0400
Received: by mail-pf0-f178.google.com with SMTP id x3so186091398pfb.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:24:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses two things.

First it enables what I am calling RFC6864 compliant GRO.  Basically what
I am doing is allowing one of two patterns for incoming frames.  Either the
IP ID will increment, or if the DF bit is set it can either increment or
stay the same value.  This allows us to perform GRO if the IP ID is forced
to stay at a static value as may occur if we are replicating an IP header
instead of actually having it offloaded.

The last 3 patches introduce what I am calling GSO partial.  The best way
to describe it is that it is a GSO offload in which the portion pointed to
by csum_start must be handled by the hardware, and the region before that
can be optionally handled.  So for example with i40e the only pieces it was
missing from the full offload was the checksum so this is computed in
software and the hardware will update inner and outer IP headers.  In the
example for ixgbe the hardware will only update the outer IP header.  The
outer UDP or GRE header and inner IP header are unmodified.

The bits remaining to be worked out are what to do about drivers that
wouldn't be able to handle updating the outer IP header.  So for example
should I require the driver to have to update the outer IP header or handle
it in software.  The one concern here is that if the outer IP header does
not have the DF bit set and does not update the IP ID field we run the risk
of causing all sorts of problems if the packet is fragmented in flight.

---

Alexander Duyck (9):
      ipv4/GRO: Allow multiple frames to use the same IP ID
      gre: Enforce IP ID verification on outer headers
      geneve: Enforce IP ID verification on outer headers
      vxlan: Enforce IP ID verification on outer headers
      gue: Enforce IP ID verification on outer headers
      ethtool: Add support for toggling any of the GSO offloads
      GSO: Support partial segmentation offload
      i40e/i40evf: Add support for GSO partial with UDP_TUNNEL_CSUM and GRE_CSUM
      ixgbe/ixgbevf: Add support for GSO partial


 drivers/net/ethernet/intel/i40e/i40e_main.c       |    8 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |   14 +++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |   14 +++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |    8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   72 +++++++++++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   77 ++++++++++++++-------
 drivers/net/geneve.c                              |   14 ++++
 drivers/net/vxlan.c                               |   14 ++++
 include/linux/netdev_features.h                   |    7 ++
 include/linux/netdevice.h                         |    7 ++
 include/linux/skbuff.h                            |    7 ++
 net/core/dev.c                                    |   31 ++++++++
 net/core/ethtool.c                                |    4 +
 net/core/skbuff.c                                 |   21 +++++-
 net/ipv4/af_inet.c                                |   20 ++++-
 net/ipv4/fou.c                                    |   14 ++++
 net/ipv4/gre_offload.c                            |   37 +++++++++-
 net/ipv4/tcp_offload.c                            |   25 ++++++-
 net/ipv4/udp_offload.c                            |   20 ++++-
 net/ipv6/ip6_offload.c                            |    9 ++
 20 files changed, 344 insertions(+), 79 deletions(-)
