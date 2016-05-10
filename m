From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/3] Mellanox 100G mlx5 CQE compression
Date: Wed, 11 May 2016 00:29:13 +0300
Message-ID: <1462915756-18180-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52808 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753071AbcEJVc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Introducing ConnectX-4 CQE (Completion Queue Entry) compression feature
for mlx5 etherent driver.

CQE Compressing reduces PCI overhead by coalescing and compressing multiple CQEs into a
single merged CQE.  Successful compressing improves message rate especially for small packet
traffic.

CQE Compressing in details:

Instead of writing full CQEs to memory, multiple almost identical CQEs are merged and compressed.
Information that is shared between the CQEs is written once, regardless of the number of
compressed CQEs.  In addition, only the unique information (small amount of bytes compared to
full CQE size) is written per CQE. 


CQE Compression Block:

This block contains multiple compressed CQEs.  CQE Compression Block contains a single copy
of CQEs properties which are shared between all the compressed CQEs (called Title, see below)
and multiple mini CQEs (CQEs in compressed form).


Title:

The Title holds information which is shared between all the compressed CQEs in the CQE Compression
Block.  In each Compression Block there is only a single Title regardless of the number
of compressed CQEs.


Mini CQE:

A CQE in compressed form that holds some data needed to extract a single full CQE, for example
8 Bytes instead of 64 Bytes.
The shared information between all compressed CQEs, which belong to the same CQE Compression
Block called Title, is written once, and only the unique information in each compressed
CQE, for example 8 bytes, is written per compressed CQE, called mini CQE.


Since CQE Compression can add overhead to the software (CPU),
it will be only enabled on "weak/slow" PCI slots, where it can actually help.

Applied on top: c047c3b1af62 ('netfilter: conntrack: remove uninitialized shadow variable')

Thanks,
Saeed.

Saeed Mahameed (1):
  net/mlx5e: Enable CQE compression when PCI is slower than link

Tariq Toukan (2):
  net/mlx5e: CQE compression
  net/mlx5e: Expand WQE stride when CQE compression is enabled

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  24 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   4 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  19 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  81 ++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 188 ++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   8 +
 include/linux/mlx5/device.h                        |  34 ++++
 7 files changed, 328 insertions(+), 30 deletions(-)

-- 
2.8.0
