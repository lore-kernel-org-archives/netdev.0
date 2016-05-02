From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 0/8] Fix Tunnel features and enable GSO partial
 for several drivers
Date: Mon, 02 May 2016 09:38:06 -0700
Message-ID: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35186 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbcEBQiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:08 -0400
Received: by mail-pa0-f53.google.com with SMTP id iv1so76115953pac.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to allow us to get the best performance possible
for Mellanox ConnectX-3/4 and Broadcom NetXtreme-C/E adapters in terms of
VXLAN and GRE tunnels.

The first 3 patches address issues I found in regards to GSO_PARTIAL and
TSO_MANGLEID.

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
v3: Moved 2 patches into series for net as they were generic fixes.
    Added patch to disable GSO partial if frame is less than 2x size of MSS

    There are outstanding issues as called out above that need to be
    addressed, however they were present before these patches so it isn't
    as if they introduce a regression.  In addition gains can be easily
    seen so there should be no issue with applying the driver patches while
    the IPv6 mlx4_en and bnxt issues are being researched.

---

Alexander Duyck (8):
      gso: Do not perform partial GSO if number of partial segments is 1 or less
      gso: Only allow GSO_PARTIAL if we can checksum the inner protocol
      net: Fix netdev_fix_features so that TSO_MANGLEID is only available with TSO
      net/mlx4_en: Add support for UDP tunnel segmentation with outer checksum offload
      net/mlx4_en: Add support for inner IPv6 checksum offloads and TSO
      net/mlx5e: Add support for UDP tunnel segmentation with outer checksum offload
      net/mlx5e: Fix IPv6 tunnel checksum offload
      bnxt: Add support for segmentation of tunnels with outer checksums


 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    9 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   38 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   15 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   10 ++++--
 net/core/dev.c                                    |    4 ++
 net/core/skbuff.c                                 |   11 ++++--
 6 files changed, 69 insertions(+), 18 deletions(-)
