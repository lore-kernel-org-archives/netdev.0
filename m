From: Amir Vadai <amirv@mellanox.com>
Subject: [RFC 0/2] pm,net: Introduce QoS requests per CPU
Date: Tue, 25 Mar 2014 15:18:23 +0200
Message-ID: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
Cc: linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49060 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752700AbaCYNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 09:19:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch is a preliminary work to add power management reqeusts per
core. The patch does compile, but I still need to work on it to make it
a non RFC. Please look at it as a reference, I would like to prepare the
final implementation after having a discussion in the community.

The problem
-----------
I'm maintaining Mellanox's network driver (mlx4_en) in the kernel.

The current pm_qos implementation has a problem. During a short pause in a high
bandwidth traffic, the kernel can lower the c-state to preserve energy.
When the pause ends, and the traffic resumes, the NIC hardware buffers may be
overflowed before the CPU starts to process the traffic due to the CPU wake-up
latency.

The driver can add a request to have constraint on the c-state during high
bandwidth traffic - but pm_qos only allows a global constraint for all the
CPU's.  While this fixes the problem of the wakeup latency, it is bad for power
consumption of the server.

Suggested solution
------------------
The idea is to extend the current pm_qos_request API - to have pm_qos_request
per core.
The networking driver will add a request on the CPU which handles the traffic,
to prevent it from getting into a low c-state. The request will be deleted once
there is no need to keep the CPU active.

The governor select the next idle state by looking at the target value of the
specific core in addition to the global target value, instead of using only the
global one.
If a global request is added/removed/updated, the target values of all the CPUs
are re-calculated.

When a CPU specific request is added/removed/updated, the target value of the
specific core is re-calculated to be the min/max (according to the constrain
type) value of all the global and the CPU specific constraints.

During initialization, before the CPU specific data structures are allocated
and initialized, only global target value is begin used.

I added to this patchset a preliminary work on mlx4_en. In this version the
driver restrict the c-state of all the CPU's during high bandwidth traffic. In
the final version this patch will use the new API and restrict only the
relevant CPU's c-state

TODO's
------
- Use cpumask instead of int, to enable add/del/modify request for
  cpusets in order to specificy a set of cpus, i.e a numa node.
- Update Documentation/tracing

Thanks,
Amir

Amir Vadai (2):
  pm: Introduce QoS requests per CPU
  net/mlx4_en: Use pm_qos API to avoid packet loss in high CPU c-states

 Documentation/trace/events-power.txt            |   2 +
 drivers/base/power/qos.c                        |   6 +-
 drivers/cpuidle/governors/menu.c                |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  37 ++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  40 +++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   7 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  13 ++
 include/linux/pm_qos.h                          |  22 ++-
 include/trace/events/power.h                    |  20 ++-
 kernel/power/qos.c                              | 221 ++++++++++++++++++------
 10 files changed, 302 insertions(+), 68 deletions(-)

-- 
1.8.3.4
