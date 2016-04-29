From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 0/9] Fix Tunnel features and enable GSO partial
 for several drivers
Date: Fri, 29 Apr 2016 15:43:02 -0700
Message-ID: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36287 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbcD2WnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:05 -0400
Received: by mail-pf0-f179.google.com with SMTP id c189so54617738pfb.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to allow us to get the best performance possible
for Mellanox ConnectX-3/4 and Broadcom NetXtreme-C/E adapters in terms of
VXLAN and GRE tunnels.

The first few patches address issues I found when just trying to collect
performance numbers.  Specifically I was unable to get rates of any more
than 1 or 2 Mb/s if I was using a tunnel that ran over IPv6.  In addition I
found a few other items related to GSO_PARTIAL and the TSO_MANGLEID that
needed to be addressed.

The next 4 patches go through and enable GSO_PARTIAL for VXLAN tunnels that
have an outer checksum enabled, and then enable IPv6 support where I can.
One outstanding issue is that I wasn't able to get offloads working with
outer IPv6 headers on mlx4.  However that wasn't a feature that was enabled
before so it isn't technically a regression, however I believe Engineers
from Mellanox said they would look into it since they thought it should be
supported.

The last patch enables GSO_PARTIAL for VXLAN and GRE tunnels on the bnxt
driver.  One piece of feedback I received on the patch was that the
hardware has globally set IPv6 UDP tunnels to always have the checksum
field computed.  I plan to work with Broadcom to get that addressed so that
we only populate the checksum field if it was requested by the network
stack.

v2: Rebased patches off of latest changes to the mlx4/mlx5 drivers.
    Added bnxt driver patch as I received feedback on the RFC.

    There are outstanding issues that need to be addressed, however they
    were present before these patches so it isn't as if they introduce a
    regression.  In addition gains can be easily seen so there should be no
    issue with applying the driver patches while the IPv6 mlx4 and bnxt
    issues are being researched.

---

Alexander Duyck (9):
      net: Disable segmentation if checksumming is not supported
      gso: Only allow GSO_PARTIAL if we can checksum the inner protocol
      net: Fix netdev_fix_features so that TSO_MANGLEID is only available with TSO
      vxlan: Add checksum check to the features check function
      mlx4: Add support for UDP tunnel segmentation with outer checksum offload
      mlx4: Add support for inner IPv6 checksum offloads and TSO
      mlx5e: Add support for UDP tunnel segmentation with outer checksum offload
      mlx5e: Fix IPv6 tunnel checksum offload
      bnxt: Add support for segmentation of tunnels with outer checksums


 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    9 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   38 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   15 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   10 ++++--
 include/linux/if_ether.h                          |    5 +++
 include/net/vxlan.h                               |    4 ++
 net/core/dev.c                                    |    6 +++
 net/core/skbuff.c                                 |    6 ++-
 8 files changed, 74 insertions(+), 19 deletions(-)
