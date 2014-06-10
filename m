From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v4 0/6] net: fec: Enable Software TSO to improve the tx performance
Date: Tue, 10 Jun 2014 17:32:18 +0800
Message-ID: <1402392744-24368-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0144.outbound.protection.outlook.com ([207.46.163.144]:53500
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751013AbaFJK5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 06:57:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SG and software TSO support for FEC.
This feature allows to improve outbound throughput performance.
Tested on imx6dl sabresd board, running iperf tcp tests shows:
        * 82% improvement comparing with NO SG & TSO patch

$ ethtool -K eth0 sg on
$ ethtool -K eth0 tso on
[  3] local 10.192.242.108 port 35388 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec   181 MBytes   506 Mbits/sec
* cpu loading is 30%

$ ethtool -K eth0 sg off
$ ethtool -K eth0 tso off
[  3] local 10.192.242.108 port 52618 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec  99.5 MBytes   278 Mbits/sec

FEC HW support IP header and TCP/UDP hw checksum, support multi buffer descriptor transfer
one frame, but don't support HW TSO. And imx6q/dl SOC FEC Gbps speed has HW bus Bandwidth
limitation (400Mbps ~ 700Mbps), imx6sx SOC FEC Gbps speed has no HW bandwidth limitation.

The patch set just enable TSO feature, which is done following the mv643xx_eth driver.

Test result analyze:
imx6dl sabresd board: there have 82% improvement, since imx6dl FEC HW has bandwidth limitation,
                      the performance with SW TSO is a milestone.

Addition test:
imx6sx sdb board:
upstream still don't support imx6sx due to some patches being upstream... they use same FEC IP.
Use the SW TSO patches test imx6sx sdb board in internal kernel tree:
No SW TSO patch: tx bandwidth 840Mbps, cpu loading is 100%.
SW TSO patch:    tx bandwidth 942Mbps, cpu loading is 65%.
It means the patch set have great improvement for imx6sx FEC performance.

V2:
* From Frank Li's suggestion:
	Change the API "fec_enet_txdesc_entry_free" name to "fec_enet_get_free_txdesc_num".
* Summary David Laight and Eric Dumazet's thoughts:
	RX BD entry number change to 256.
* From ezequiel's suggestion:
	Follow the latest TSO fixes from his solution to rework the queue stop/wake-up.
	Avoid unmapping the TSO header buffers.
* From Eric Dumazet's suggestion:
	Avoid more bytes copy, just copying the unaligned part of the payload into first
	descriptor. The suggestion will bring more complex for the driver, and imx6dl FEC
	DMA need 16 bytes alignment, but cpu loading is not problem that cpu loading is
	30%, the current performance is so better. Later chip like imx6sx Gigbit FEC DMA
	support byte alignment, so there don't exist memory copy. So, the V2 version drop
	the suggestion.
	Anyway, thanks for Eric's response and suggestion.

V3:
* From David Laight's feedback:
	Decide to drop RX BD entry number change for the SW TSO patch set.
	I will generate one separate patch to increase RX BDs entry for interrupt coalescing feature which
	will be supported in my later patch set.

V4:
* From David Laight's feedback:
	Remove the conditional in .fec_enet_get_bd_index().


Thanks for Eric and ezequiel's help and idea.


Fugang Duan (6):
  net: fec: Factorize the .xmit transmit function
  net: fec: Enable IP header hardware checksum
  net: fec: Factorize feature setting
  net: fec: Increase buffer descriptor entry number
  net: fec: Add Scatter/gather support
  net: fec: Add software TSO support

 drivers/net/ethernet/freescale/fec.h      |   12 +-
 drivers/net/ethernet/freescale/fec_main.c |  548 ++++++++++++++++++++++++-----
 2 files changed, 460 insertions(+), 100 deletions(-)

-- 
1.7.8
