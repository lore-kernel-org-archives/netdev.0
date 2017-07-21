From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 0/2] net: ethernet: ti: cpts: fix tx timestamping timeout
Date: Fri, 21 Jul 2017 18:49:41 -0500
Message-ID: <20170721234943.3841-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the low Ethernet connection speed cpdma notification about packet
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
The internal CPTS workqueues are also converted to use kthread_worker.

Grygorii Strashko (2):
  net: ethernet: ti: cpts: convert to use kthread_worker
  net: ethernet: ti: cpts: fix tx timestamping timeout

 drivers/net/ethernet/ti/cpts.c | 112 +++++++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/ti/cpts.h |   5 +-
 2 files changed, 106 insertions(+), 11 deletions(-)

-- 
2.10.1
