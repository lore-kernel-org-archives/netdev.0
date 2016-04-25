From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/8] Fix Tunnel features and enable GSO partial for
 Mellanox adapters
Date: Mon, 25 Apr 2016 11:30:54 -0700
Message-ID: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34696 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbcDYSa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:30:57 -0400
Received: by mail-pf0-f174.google.com with SMTP id y69so50007515pfb.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to allow us to get the best performance possible
for Mellanox ConnectX-3/4 adapters in terms of VXLAN tunnels.

The first few patches address issues I found when just trying to collect
performance numbers.  Specifically I was unable to get rates of any more
than 1 or 2 Mb/s if I was using a tunnel that ran over IPv6.  In addition I
found a few other items related to GSO_PARTIAL and the TSO_MANGLEID that
needed to be addressed.

The last 4 patches go through and enable GSO_PARTIAL for tunnels that have
an outer checksum enabled, and then enable IPv6 support where we can.  In
my tests I found that the mlx4 doesn't support outer IPv6 but the mlx5 did
so the code is updated to reflect that in the patches that enable IPv6
support.

---

Alexander Duyck (8):
      net: Disable segmentation if checksumming is not supported
      gso: Only allow GSO_PARTIAL if we can checksum the inner protocol
      net: Fix netdev_fix_features so that TSO_MANGLEID is only available with TSO
      vxlan: Add checksum check to the features check function
      mlx4: Add support for UDP tunnel segmentation with outer checksum offload
      mlx4: Add support for inner IPv6 checksum offloads and TSO
      mlx5e: Add support for UDP tunnel segmentation with outer checksum offload
      mlx5e: Fix IPv6 tunnel checksum offload


 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   38 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   15 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   10 ++++--
 include/linux/if_ether.h                          |    5 +++
 include/net/vxlan.h                               |    4 ++
 net/core/dev.c                                    |    6 +++
 net/core/skbuff.c                                 |    6 ++-
 7 files changed, 67 insertions(+), 17 deletions(-)
