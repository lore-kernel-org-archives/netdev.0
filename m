From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 0/3] net: ethernet: ti: cpts: fix tx timestamping timeout
Date: Tue, 25 Jul 2017 15:24:17 -0500
Message-ID: <20170725202420.28229-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:58693 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751930AbdGYUYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 16:24:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Patch3 - With the low Ethernet connection speed cpdma notification about packet
processing can be received before CPTS TX timestamp event, which is set
when packet actually left CPSW while cpdma notification is sent when packet
pushed in CPSW fifo. As result, when connection is slow and CPU is fast
enough TX timestamping is not working properly.
Issue was discovered using timestamping tool on am57x boards with Ethernet link
speed forced to 100M and on am335x-evm with Ethernet link speed forced to 10M.

This series fixes it by introducing TX SKB queue to store PTP SKBs for which
Ethernet Transmit Event hasn't been received yet and then re-check this queue
with new Ethernet Transmit Events by scheduling CPTS overflow
work more often until TX SKB queue is not empty.

Patch 1,2 - As CPTS overflow work is time critical task it important to ensure
that its scheduling is not delayed. Unfortunately, There could be significant
delay in CPTS work schedule under high system load and on -RT which could cause
CPTS misbehavior due to internal counter overflow and there is no way to tune
CPTS overflow work execution policy and priority manually. The kthread_worker
can be used instead of workqueues, as it creates separate named kthread for
each worker and its its execution policy and priority can be configured
using chrt tool. Instead of modifying CPTS driver itself it was proposed to
it was proposed to add PTP auxiliary worker to the PHC subsystem [1], so
other drivers can benefit from this feature also.

[1] https://www.spinics.net/lists/netdev/msg445392.html

changes in v2:
- added PTP auxiliary worker to the PHC subsystem

Link on v1:
- https://www.spinics.net/lists/netdev/msg445387.html

Grygorii Strashko (3):
  ptp: introduce ptp auxiliary worker
  net: ethernet: ti: cpts: convert to use ptp auxiliary worker
  net: ethernet: ti: cpts: fix tx timestamping timeout

 drivers/net/ethernet/ti/cpts.c   | 111 +++++++++++++++++++++++++++++++++------
 drivers/net/ethernet/ti/cpts.h   |   2 +-
 drivers/ptp/ptp_clock.c          |  40 ++++++++++++++
 drivers/ptp/ptp_private.h        |   3 ++
 include/linux/ptp_clock_kernel.h |  19 +++++++
 5 files changed, 158 insertions(+), 17 deletions(-)

-- 
2.10.1
