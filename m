From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v12 0/3] add hisilicon hip04 ethernet driver
Date: Tue, 13 Jan 2015 17:11:27 +0800
Message-ID: <1421140290-5492-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: <arnd-r2nGTMty4D4@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <agraf-l3A5Bk7waGM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v12:
- According Alex's suggestion, modify the changelog and add MODULE_DEVICE_TABLE
  for hip04 ethernet.

v11:
- Add ethtool support for tx coalecse getting and setting, the xmit_more
  is not supported for this patch, but I think it could work for hip04,
  will support it later after some tests for performance better.

  Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
  it looks that the performance and latency is more better by tx_coalesce_frames/usecs.

  - Before:
    $ ping 192.168.1.1 ...
    === 192.168.1.1 ping statistics ===
    24 packets transmitted, 24 received, 0% packet loss, time 22999ms
    rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms

    $ iperf -c 192.168.1.1 ...
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec

  - After:
    $ ping 192.168.1.1 ...
    === 192.168.1.1 ping statistics ===
    24 packets transmitted, 24 received, 0% packet loss, time 22999ms
    rtt min/avg/max/mdev = 0.178/0.190/0.380/0.041 ms

    $ iperf -c 192.168.1.1 ...
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0- 1.0 sec   115 MBytes   965 Mbits/sec

v10:
- According Arnd's suggestion, remove the skb_orphan and use the hrtimer
  for the cleanup of the TX queue and add some modification for the hip04
  drivers.
  1) drop the broken skb_orphan call
  2) drop the workqueue
  3) batch cleanup based on tx_coalesce_frames/usecs for better throughput
  4) use a reasonable default tx timeout (200us, could be shorted
     based on measurements) with a range timer
  5) fix napi poll function return value
  6) use a lockless queue for cleanup

v9:
- There is no tx completion interrupts to free DMAd Tx packets, it means taht
  we rely on new tx packets arriving to run the destructors of completed packets,
  which open up space in their sockets's send queues. Sometimes we don't get such
  new packets causing Tx to stall, a single UDP transmitter is a good example of
  this situation, so we need a clean up workqueue to reclaims completed packets,
  the workqueue will only free the last packets which is already stay for several jiffies.
  Also fix some format cleanups.

v8:
- Use poll to reclaim xmitted buffer as workaround since no tx done interrupt 

v7:
- Remove select NET_CORE in 0002

v6:
- Suggest by Russell: Use netdev_sent_queue & netdev_completed_queue to solve latency issue 
  Also shorten the period of timer, which is used to wakeup the queue since no
  tx completed interrupt.

v5:
- no big change, fix typo

v4:
- Modify accoringly to the suggetion from Arnd, Florian, Eric, David
  Use of_parse_phandle_with_fixed_args & syscon_node_to_regmap get ppe info
  Add skb_orphan() and tx_timer for reclaim since no tx_finished interrupt
  Update timeout, and move of_phy_connect to probe to reuse open/stop

v3:
- Suggest from Arnd, use syscon & regmap_write/read to replace static void __iomem *ppebase.
  Modify hisilicon-hip04-net.txt accrordingly to suggestion from Florian and Sergei.

v2:
- Got many suggestions from Russell, Arnd, Florian, Mark and Sergei
  Remove memcpy, use dma_map/unmap_single, use dma_alloc_coherent rather than dma_pool, etc.
  Refer property in ethernet.txt, change ppe description, etc.

Ding Tianhong (1):
  net: hisilicon: new hip04 ethernet driver

Zhangfei Gao (2):
  Documentation: add Device tree bindings for Hisilicon hip04 ethernet
  net: hisilicon: new hip04 MDIO driver

 .../bindings/net/hisilicon-hip04-net.txt           |  88 ++
 drivers/net/ethernet/hisilicon/Kconfig             |   9 +
 drivers/net/ethernet/hisilicon/Makefile            |   1 +
 drivers/net/ethernet/hisilicon/hip04_eth.c         | 968 +++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hip04_mdio.c        | 186 ++++
 5 files changed, 1252 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c

-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
