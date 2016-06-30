From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 0/4]  net: ethernet: ti: cpsw: add multi-queue support
Date: Thu, 30 Jun 2016 22:04:34 +0300
Message-ID: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is intended to allow cpsw driver to use its ability of h/w
shaper to send/receive data with up to 8 tx and rx queues. This series
doesn't contain interface to configure h/w shaper itself, it contains
only multi queue support part and ability to configure number of tx/rx
queues with ethtool. Default shaper mode - priority mode. The h/w
shaper configuration will be added with separate patch series.
This series doesn't affect on net throughput.

Tested on:
am572x-idk, 1Gbps link
am335-boneblack, 100Mbps link.

Based on:
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

A simple example for splitting traffic on queues:

#check how many queues are supported and active:
$ ethtool -l eth0

#increase number of active rx and tx queues,
#by default 1 rx and 1 tx queue
#can be set any combination of 0 < rx <= 8 and 0 < tx <= 8
$ ethtool -L eth0 rx 8 tx 8

#set multi-queue-aware queuing discipline
$ tc qdisc add dev eth0 root handle 1: multiq

#send packets with ip 172.22.39.12 to queue #5 which can be
#prioritized or throughput limited by h/w shaper.
$ tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
    match ip dst 172.22.39.12 \
    action skbedit queue_mapping 5

#get statistic for active channels:
ethtool -S eth0

Ivan Khoronzhuk (4):
  net: ethernet: ti: davinci_cpdma: split descs num between all channels
  net: ethernet: ti: cpsw: add multi queue support
  net: ethernet: ti: davinci_cpdma: move cpdma channel struct macroses
    to internals
  net: ethernet: ti: cpsw: add ethtool channels support

 drivers/net/ethernet/ti/cpsw.c          | 533 +++++++++++++++++++++++++-------
 drivers/net/ethernet/ti/davinci_cpdma.c |  79 ++++-
 drivers/net/ethernet/ti/davinci_cpdma.h |  13 +-
 drivers/net/ethernet/ti/davinci_emac.c  |   8 +-
 4 files changed, 505 insertions(+), 128 deletions(-)

-- 
1.9.1
