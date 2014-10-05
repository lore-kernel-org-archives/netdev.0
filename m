From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/2] Add pgtable API to query if write combining is available
Date: Sun,  5 Oct 2014 11:22:20 +0300
Message-ID: <1412497342-12451-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41766 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750907AbaJEIWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 04:22:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel write-combining interface provides a best effort
mechanism in which the caller simply invokes pgprot_writecombine().

If write combining is available, the region is mapped for it, otherwise
the region is (silently) mapped as non-cached. In some cases, however, 
the calling driver must know if write combining is available, so a silent 
best effort mechanism is not sufficient. Add writecombine_available(), which 
returns 1 if the system supports write combining and 0 if it doesn't.

In mlx4 for better latency, we write send descriptors to a write-combining
(WC) mapped buffer instead of ringing a doorbell and having the HW fetch
the descriptor from system memory.

However, if write-combining is not supported on the host, then we
obtain better latency by using the doorbell-ring/HW fetch mechanism.

This series from Moshe and Jack adds the API and uses in in mlx4.

We are sending through netdev to get feedback from the networking 
community and extend the reviewer audience if required.

Per the reviewers request, here are some results from these 
three different configurations:

[1] bf=on with wc
[2] bf=on without wc
[3] bf=off and doorbell 

The 1st set of results was obtained from running latency test 
with the HCA being passthrough-ed into VM running over KVM 
host -- so WC isn't available.

The problematic range is 32-128B, for example with 128 bytes 
message, using BF has latency of 1.47us and no usage of BF 
only 1us. When WC isn't really available every write of 64B
would actually translate into 8 writes of 8 bytes which obviously
hurts the latency.

# /usr/bin/taskset -c 0 ib_write_lat -d mlx4_0 -i 1  -F -a -n 1000000

[2] BF on without WC 
 #bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]
 2       1000000          0.74           186.16       0.79
 4       1000000          0.70           103.62       0.78
 8       1000000          0.74           77.02        0.78
 16      1000000          0.65           640.75       0.86
 32      1000000          0.90           134.63       0.96
 64      1000000          1.05           808.52       1.11
 128     1000000          1.05           405.58       1.47
 
[3] BF off and using doorbell
 #bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]
 2       1000000          0.85           107.29       0.89
 4       1000000          0.84           705.90       0.89
 8       1000000          0.85           457.72       0.89
 16      1000000          0.85           1041.43      0.90
 32      1000000          0.88           773.67       0.92
 64      1000000          0.90           82.70        0.93
 128     1000000          0.96           78.20        1.00

The 2nd set of results was obtained from running latency test 
over bare-metal host where WC is available. Clearly we gain
better latency when BF is used vs. the doorbell base.

# /usr/bin/taskset -c 0 ib_write_lat -d mlx4_0 -i 1  -F -a -n 1000000

[1] BF on, WC available
#bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]
 2       1000000          0.74           131.62       0.79
 4       1000000          0.74           134.51       0.79
 8       1000000          0.74           154.30       0.79
 16      1000000          0.74           1437.57      0.79
 32      1000000          0.79           138.23       0.83
 64      1000000          0.82           135.86       0.85
 128     1000000          0.94           131.11       0.98

[3] BF off and using doorbell
#bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]
 2       1000000          1.05           137.55       1.10
 4       1000000          1.04           422.50       1.10
 8       1000000          1.05           141.26       1.10
 16      1000000          1.06           1261.99      1.11
 32      1000000          1.09           141.47       1.14
 64      1000000          1.11           435.44       1.16
 128     1000000          1.22           212.19       1.27

Moshe and Or.

changes from V0:
  - changed the WC helper to return bool value


Moshe Lazer (2):
  pgtable: Add API to query if write combining is available
  net/mlx4_core: Disable BF when write combining is not available

 arch/arm/include/asm/pgtable.h          |    6 ++++++
 arch/arm64/include/asm/pgtable.h        |    5 +++++
 arch/ia64/include/asm/pgtable.h         |    6 ++++++
 arch/powerpc/include/asm/pgtable.h      |    6 ++++++
 arch/x86/include/asm/pgtable_types.h    |    2 ++
 arch/x86/mm/pat.c                       |    9 +++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c |    2 +-
 include/asm-generic/pgtable.h           |    8 ++++++++
 8 files changed, 43 insertions(+), 1 deletions(-)
