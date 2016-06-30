From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] Add option to specify PF parameter for IFLA_VF_MAC
Date: Thu, 30 Jun 2016 16:30:46 +0530
Message-ID: <1467284449-28499-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:52246 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751810AbcF3LEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 07:04:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We're struggling to implement the PCI SR-IOV management features for
administering Virtual Functions which represent networking devices using
the current Linux APIs. The problem is that these APIs incorporate all
sorts of assumptions which don't match chelsio networking cards.

For instance, the current APIs assume a 1-to-1 mapping of Network Ports,
Physical Functions and the SR-IOV Virtual Functions of those Physical
Functions. This is not the case with our cards where any Virtual Function
can be hooked up to any Port -- or any number of Ports the current Linux
APIs also assume only 1 Network Interface/Port can be accessed per Virtuali
Function.

Another issue is that these APIs assume that the Administrative Driver is
attached to the Physical Function Associated with a Virtual Function. This
is not the case with our card where all administration is performed by a
Driver which is not attached to any of the Physical Functions which have
SR-IOV PCI Capabilities.

Another consequence of these assumptions is the inability to utilize all
of the cards SR-IOV resources. For instance, our cards have SR-IOV
Capabilities on Physical Functions 0..3 and the administrative Driver
attaches to Physical Function 4. Each of the Physical Functions 0..3 can
support up to 16 Virtual Functions. With the current Linux APIs, a 2-Port
card would only be able to use the Virtual Functions on Physical
Function 0..1 and not allow the Virtual Functions on Physical
Functions 2..3 to be used since there are no Ports 2..3 on a 2-Port card.

To start with we have just modified the code to add support for
ndo_set_vf_mac to work with chelsio adapter. And once this gets merged,
will submit patches for reset of the IFLA_VF API's. 

This patch 1/3 and 2/3 has been created against net-next tree, and
patch 3/3 has been created against iproute2 tree.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  net: Add provision to specify pf number while assigning VF mac
  cxgb4/cxgb4vf: Add set VF mac address support

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   33 ++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   42 +++++++++++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   24 ++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    3 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   63 ++++++++++++++++++--
 drivers/net/ethernet/cisco/enic/enic_main.c        |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h           |    3 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |    3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    2 +-
 drivers/net/ethernet/sfc/sriov.c                   |    3 +-
 drivers/net/ethernet/sfc/sriov.h                   |    3 +-
 include/linux/netdevice.h                          |    2 +-
 include/uapi/linux/if_link.h                       |    1 +
 net/core/rtnetlink.c                               |    4 +-
 28 files changed, 193 insertions(+), 30 deletions(-)

Hariprasad Shenai (1):
  ip: Add option to specify PF number associated with the VF

 include/linux/if_link.h |    1 +
 ip/ipaddress.c          |    3 +++
 ip/iplink.c             |   21 ++++++++++++++-------
 man/man8/ip-link.8.in   |   15 +++++++++++++--
 4 files changed, 31 insertions(+), 9 deletions(-)

-- 
1.7.3
