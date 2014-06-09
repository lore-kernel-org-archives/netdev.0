From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V7 0/2] cpumask,net: affinity hint helper function
Date: Mon,  9 Jun 2014 10:24:37 +0300
Message-ID: <1402298679-22038-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46729 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753635AbaFIH0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 03:26:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset will set affinity hint to influence IRQs to be allocated on the
same NUMA node as the one where the card resides. As discussed in
http://www.spinics.net/lists/netdev/msg271497.html

If number of IRQs allocated is greater than the number of local NUMA cores, all
local cores will be used first, and the rest of the IRQs will be on a remote
NUMA node.
If no NUMA support - IRQ's and cores will be mapped 1:1

Since the utility function to calculate the mapping could be useful in other mq
drivers in the kernel, it was added to cpumask.[ch]

This patchset was tested and applied on top of net-next since the first
consumer is a network device (mlx4_en).  Over commit fff1f59 "mac802154:
llsec: add forgotten list_del_rcu in key removal"

Amir

Changes from V6:
- Patch 1/2: cpumask: Utility function to set n'th cpu - local cpu first
  - Add a stub for cpumask_set_cpu_local_first() when SMP is not set
  - Move cpumask_set_cpu_local_first() definition out of #ifdef
    CONFIG_CPUMASK_OFFSTACK
- Patch 2/2: net/mlx4_en: Use affinity hint
  - cpumask_var_t is not a pointer when CONFIG_CPUMASK_OFFSTACK is not
    set. Instead of adding affinity_mask as an argument to
    mlx4_assign_eq() and using it only when not NULL - use affinity_mask
    only for rx ring IRQ at mlx4_en_activate_cq() this also made the
    code much simpler and elegant.

Amir Vadai (1):
  cpumask: Utility function to set n'th cpu - local cpu first

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/net/ethernet/mellanox/mlx4/en_cq.c     | 12 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 35 +++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/cpumask.h                        |  8 ++++
 lib/cpumask.c                                  | 63 ++++++++++++++++++++++++++
 5 files changed, 117 insertions(+), 2 deletions(-)

-- 
1.8.3.4
