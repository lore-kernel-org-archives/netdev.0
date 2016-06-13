From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 00/15] Future-proof tunnel offload handlers
Date: Mon, 13 Jun 2016 10:47:44 -0700
Message-ID: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34338 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbcFMRru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:47:50 -0400
Received: by mail-pa0-f54.google.com with SMTP id bz2so47750320pad.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:47:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to address two things.  First we are currently using
the ndo_add/del_vxlan_port calls with VXLAN-GPE tunnels and we cannot
really support that as it is likely to cause more harm than good since
VXLAN-GPE can support tunnels without a MAC address on the inner header.

As such we need to add a new offload to advertise this, but in doing so it
would mean introducing 3 new functions for the driver to request the ports,
and then for the tunnel to push the changes to add and delete the ports to
the device.  However instead of taking that approach I think it would be
much better if we just made one common function for fetching the ports, and
provided a generic means to push the tunnels to the device.  So in order to
make this work this patch set does several things.

First it merges the existing VXLAN and GENEVE functionality into one set of
functions and passes an enum in order to specify the type of tunnel we want
to offload.  By doing this we only have to extend this enum in the future
if we want to add additional types.

Second it goes through the drivers replacing all of the tunnel specific
offload calls with implementations that support the generic calls so that
we can drop the VXLAN and GENEVE specific calls entirely.

Finally I go through in the last patch and replace the VXLAN specific
offload request that was being used for VXLAN-GPE with one that specifies
if we want to offload VXLAN or VXLAN-GPE so that the hardware can decide if
it can actually support it or not.

I also ended up with some minor clean-up built into the driver patches for
this.  Most of it is to either fix misuse of build flags, specifying a type
to ignore instead of the type that should be used, or in the case of ixgbe
I actually moved a rtnl_lock/unlock in order to avoid taking it unless it
was actually needed.

---

Alexander Duyck (15):
      net: Combine GENEVE and VXLAN port offload notifiers into single functions
      net: Merge VXLAN and GENEVE push notifiers into a single notifier
      bnx2x: Move all UDP port notifiers to single function
      bnxt: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      benet: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      fm10k: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      i40e: Move all UDP port notifiers to single function
      ixgbe: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      mlx4_en: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      mlx5_en: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      nfp: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      qede: Move all UDP port notifiers to single function
      qlcnic: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
      net: Remove deprecated tunnel specific UDP offload functions
      vxlan: Add new UDP encapsulation offload type for VXLAN-GPE


 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   96 ++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |   22 ++-
 drivers/net/ethernet/emulex/benet/be_main.c        |   16 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |   18 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  148 +++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   36 +++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   30 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   18 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   18 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  113 ++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   18 ++
 drivers/net/geneve.c                               |   50 +------
 drivers/net/vxlan.c                                |   56 ++------
 include/linux/netdevice.h                          |   19 +--
 include/net/geneve.h                               |    9 -
 include/net/udp_tunnel.h                           |   19 +++
 include/net/vxlan.h                                |    7 -
 net/ipv4/udp_tunnel.c                              |   52 +++++++
 18 files changed, 357 insertions(+), 388 deletions(-)
