From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 00/17] Future-proof tunnel offload handlers
Date: Wed, 15 Jun 2016 15:07:15 -0700
Message-ID: <20160615220449.15575.17031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36054 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcFOWHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:07:18 -0400
Received: by mail-pf0-f179.google.com with SMTP id t190so12742038pfb.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:07:18 -0700 (PDT)
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

v2:
I did my best to remove the word "offload" from any of the calls or
notifiers as this isn't really an offload.  It is a workaround for the fact
that the drivers don't provide basic features like CHECKSUM_COMPLETE.  I
also added a disclaimer to the section defining the function prototypes
explaining that these are essentially workarounds.

I ended up going through and stripping all of the VXLAN and GENEVE build
flags from the drivers.  There isn't much point in carrying them.  In
addition I dropped the use of the vxlan.h or geneve.h header files in favor
of udp_tunnel.h in the cases where a driver didn't need anything from
either of those headers.

I updated the tunnel add/del functions so that they pass a udp_tunnel_info
structure instead of a list of arguments.  This way we should be able to
add additional information in the future with little impact on the other
drivers.

I updated bnxt so that it doesn't use a hard-coded port number for GENEVE.

I have been able to test mlx4e, mlx5e, and i40e and verified functionality
on these drivers.  I submitted patches to the net tree for i40e and mlx4e
drivers due to unrelated bugs I found while testing.

---

Alexander Duyck (17):
      vxlan/geneve: Include udp_tunnel.h in vxlan/geneve.h and fixup includes
      net: Combine GENEVE and VXLAN port notifiers into single functions
      net: Merge VXLAN and GENEVE push notifiers into a single notifier
      bnx2x: Move all UDP port notifiers to single function
      bnxt: Update drivers to support unified UDP encapsulation offload functions
      bnxt: Move GENEVE support from hard-coded port to using port notifier
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


 drivers/net/ethernet/broadcom/Kconfig              |   21 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   94 ++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  104 ++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |    3 
 drivers/net/ethernet/emulex/benet/Kconfig          |    8 -
 drivers/net/ethernet/emulex/benet/be_main.c        |   32 ++-
 drivers/net/ethernet/intel/Kconfig                 |   43 -----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |   36 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  186 +++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   57 +++---
 drivers/net/ethernet/mellanox/mlx4/Kconfig         |    7 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   41 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   20 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   22 ++
 drivers/net/ethernet/qlogic/Kconfig                |   30 ---
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  115 +++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   30 ++-
 drivers/net/geneve.c                               |   51 +----
 drivers/net/vxlan.c                                |   73 ++------
 include/linux/netdevice.h                          |   58 ++----
 include/net/geneve.h                               |    9 -
 include/net/udp_tunnel.h                           |   42 +++++
 include/net/vxlan.h                                |   13 -
 net/ipv4/udp_tunnel.c                              |   61 +++++++
 27 files changed, 477 insertions(+), 687 deletions(-)
