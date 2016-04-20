From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 00/11] Mellanox 100G mlx5 driver receive path optimizations
Date: Wed, 20 Apr 2016 22:02:08 +0300
Message-ID: <1461178939-20687-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59389 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751535AbcDTTDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 15:03:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

Changes from V2:
	- Rebased to 46e7b8d8d53b ("net: dsa: kill circular reference with slave priv")
	- Updated: ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
		* Per Eric Dumazet comment we changed the driver memory handling scheme to 
		work with order-0 pages rather than order-5 via split_page().
		* This means that now a mlx5e rx skb can hold one or (more in case of HW LRO)
                skb frag each pointing to a 4K order-0 page rather than one frag with order-5 page.
	- Updated: ("net/mlx5e: Add fragmented memory support for RX multi packet WQE")
		* Code refactoring and code reuse due the split_page() mechanism,
		  now the MPWQE and fragmented MPWQE handling almost look the same,
		  and share most of the code.
	- In some cases we see 2%-3% packet rate degradation in comparison to the order-5 pages approach,
	  due to split_page() cpu consumption, but still we do see 3%-10% improvement in comparison to the 
          current linear SKB approach.
	- We do believe that now the driver memory scheme is significantly less vulnerable 
	  to the memory DOS attack Eric pointed at.

Changes from V1:
	- Rebased to efde611b0afa ("Merge branch 'nfp-next'")
	- Dropped: ("net/mlx5: Refactor mlx5_core_mr to mkey")
                Already merged into 4.6 from rdma tree. 
	- Dropped: ("net/mlx5_core: Add ConnectX-5 to list of supported devices")
                Will be pushed to net as we want it in 4.6 release.
	- Dropped: ("net/mlx5e: Change RX moderation period to be based on CQE")
                Will be pushed in a later series with full software based adaptive moderation.
	- Added: ("net/mlx5e: Delay skb->data access")
		Small trivial optimization.
	- Updated: ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
	 	Changed Striding RQ defaults to:
			> 	NUM WQEs = 16
			> 	Strides Per WQE = 1024
			> 	Stride Size = 128 
	- Updated: ("net/mlx5e: Use napi_alloc_skb for RX SKB allocations")
		Consider the IP packet alignment already done in napi_alloc_skb.	

Changes from V0:
	- Fixed a typo in commit message reported by Sergei
	- Align SKB fragments truesize to stride size
	- Use skb_add_rx_frag and remove the use of SKB_TRUESIZE
	- Fix: # MTTs alignment on Power PC
	- Fix: Free original (unaligned) pointer of MTT array
	- Use dev_alloc_pages and dev_alloc_page
	- Extend the stats.buff_alloc_err counter
	- Reform the copying of packet header into skb linear data
	- Add compiler hints for conditional statements
	- Prefetch skd->data prior to copying packet header into it
	- Rework: mlx5e_complete_rx_fragmented_mpwqe
	- Handle SKB fragments before linear data
	- Dropped ("net/mlx5e: Prefetch next RX CQE") for now 
	- Added a small patch that Adds ConnectX-5 devices to the list of supported devices
	- Rebased to 1cdba5505555 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next")

This series includes Some RX modifications and optimizations for
the mlx5 Ethernet driver. 

>From Rana, we have one patch that adds the support for Connectx-4
queue counters.

>From Tariq, several patches that are centralized around improving
RX path message rate, CPU and Memory utilization, in each patch
commit message you will find the performance improvements numbers
related to that specific patch.

In the 2nd patch we used a queue counter to report "out of buffer" 
dropped packet count, "Dropped packets due to lack of software resources"

3rd patch modifies the driver's to RSS default value to be spread along the
close NUMA node cores only for better out of the box experience.

In the 4th and 5th patches we utilized the use of RX multi-packet WQE
(Striding RQ) for better memory utilization especially in case of hardware
LRO is enabled and for better message rate for small packets.

In the 6th and 7th patches we added a fallback mechanism to use fragmented
memory when allocating large WQE strides fails, using UMR
(User Memory Registration) and ICO (Internal Control Operations) SQs.

In the 8th to 11th patches we did some small modification which show some small
extra improvements.

Thanks,
Saeed



Rana Shahout (1):
  net/mlx5e: Allocate set of queue counters per netdev

Saeed Mahameed (1):
  net/mlx5e: Delay skb->data access

Tariq Toukan (9):
  net/mlx5: Introduce device queue counters
  net/mlx5e: Use only close NUMA node for default RSS
  net/mlx5e: Use function pointers for RX data path handling
  net/mlx5e: Support RX multi-packet WQE (Striding RQ)
  net/mlx5e: Added ICO SQs
  net/mlx5e: Add fragmented memory support for RX multi packet WQE
  net/mlx5e: Use napi_alloc_skb for RX SKB allocations
  net/mlx5e: Remove redundant barrier
  net/mlx5e: Add ethtool counter for RX buffer allocation failures

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  202 +++++++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   28 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  361 +++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  566 ++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   59 ++-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   68 +++
 include/linux/mlx5/device.h                        |   39 ++-
 include/linux/mlx5/qp.h                            |    6 +
 9 files changed, 1202 insertions(+), 133 deletions(-)
