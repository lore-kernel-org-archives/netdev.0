From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V6 0/2] cpumask,net: Affinity hint helper function
Date: Sun, 25 May 2014 17:47:25 +0300
Message-ID: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37315 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751396AbaEYOry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2014 10:47:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset will set affinity hint to influence IRQs to be allocated on the
same NUMA node as the one where the card resides. As discussed in
http://www.spinics.net/lists/netdev/msg271497.html

If the number of IRQs allocated is greater than the number of local NUMA cores, all
local cores will be used first, and the rest of the IRQs will be on a remote
NUMA node.
If no NUMA support - IRQ's and cores will be mapped 1:1

Since the utility function to calculate the mapping could be useful in other mq
drivers in the kernel, it was added to cpumask.[ch]

This patchset was tested and applied on top of net-next since the first
consumer is a network device (mlx4_en).  Over commit 506724c: "tg3: Override
clock, link aware and link idle mode during NVRAM dump"

I couldn't find a maintainer for cpumask.c, so only added the kernel mailing
list

Amir

Changes from V5:
- Moved the utility function from kernel/irq/manage.c to lib/cpumask.c, and
  renamed it's name accordingly to cpumask_set_cpu_local_first()
- Added some comments as Thomas Gleixner suggested
- Changed -EINVAL to -EAGAIN, that describes the error situtation better.

Changes from V4:
- Patch 1/2: irq: Utility function to get affinity_hint by policy
  Thank you Ben for the great review:
  - Moved the function it kernel/irq/manage.c since it could be useful for
    block mq devices
  - Fixed Typo's
  - Use cpumask_t * instead of cpumask_var_t in function header  
  - Restructured the function to remove NULL assignment in a cpumask_var_t
  - Fix for offline local CPU's

Changes from V3:
- Patch 2/2: net/mlx4_en: Use affinity hint
  - somehow patch file was corrupted

Changes from V2:
- Patch 1/2: net: Utility function to get affinity_hint by policy
  - Fixed style issues

Changes from V1:
- Patch 1/2: net: Utility function to get affinity_hint by policy
  - Fixed error flow to return -EINVAL on error (thanks govind)
- Patch 2/2: net/mlx4_en: Use affinity hint
  - Set ring->affinity_hint to NULL on error

Changes from V0:
- Fixed small style issues


Amir Vadai (1):
  cpumask: Utility function to set n'th cpu - local cpu first

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 30 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 13 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/cpumask.h                        |  2 +
 include/linux/mlx4/device.h                    |  2 +-
 lib/cpumask.c                                  | 64 ++++++++++++++++++++++++++
 8 files changed, 116 insertions(+), 4 deletions(-)

-- 
1.8.3.4
