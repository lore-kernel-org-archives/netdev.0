From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 0/5] net: ethernet: ti: cpsw: add cpdma multi-queue support
Date: Tue, 16 Aug 2016 02:25:44 +0300
Message-ID: <1471303549-4134-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	nsekhar@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is intended to allow cpsw driver to use cpdma ability of
h/w shaper to send/receive data with up to 8 tx and 8 rx queues. This
series doesn't contain interface to configure h/w shaper itself, it
contains only multi-queue support part and ability to configure number
of tx/rx queues with ethtool, it also doesn't contain mapping of input
traffic to rx queues, as it can depend on usage and requires separate
interface for setup.

Default shaper mode - priority mode. The h/w shaper configuration will
be added with separate patch series. This series doesn't affect on net
throughput.

Tested on:
am572x-idk, 1Gbps link
am335-boneblack, 100Mbps link.

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

Based on: net-next/master
V1: https://lkml.org/lkml/2016/6/30/603

Since v2:
- added new patch to avoid warn while ctrl stop

  net: ethernet: ti: cpsw: add ethtool channels support
- enable ctrl in case at least one interface is running

Since v1:
- removed cpdam_check_free_desc function
- remove pm_runtime calls as they are used in begin/complete ethtool calls now
- removed change of driver version. it can be done later
- corrected setup of channels for dual_emac mode with ethtool

Ivan Khoronzhuk (5):
  net: ethernet: ti: davinci_cpdma: split descs num between all channels
  net: ethernet: ti: davinci_cpdma: fix locking while ctrl_stop
  net: ethernet: ti: cpsw: add multi queue support
  net: ethernet: ti: davinci_cpdma: move cpdma channel struct macroses
    to internals
  net: ethernet: ti: cpsw: add ethtool channels support

 drivers/net/ethernet/ti/cpsw.c          | 488 +++++++++++++++++++++++++-------
 drivers/net/ethernet/ti/davinci_cpdma.c |  73 ++++-
 drivers/net/ethernet/ti/davinci_cpdma.h |  13 +-
 drivers/net/ethernet/ti/davinci_emac.c  |   8 +-
 4 files changed, 459 insertions(+), 123 deletions(-)

-- 
1.9.1
